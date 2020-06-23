*&---------------------------------------------------------------------*
*& Include          ZEAN_POS_UPLOAD_F01
*&---------------------------------------------------------------------*

FORM get_filename  CHANGING fp_p_file.

  DATA: li_filetable    TYPE filetable,
        lx_filetable    TYPE file_table,
        lv_return_code  TYPE i,
        lv_window_title TYPE string.
*** File Path Selection
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
    CHANGING
      file_table              = li_filetable
      rc                      = lv_return_code
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF li_filetable IS NOT INITIAL.
    lx_filetable = li_filetable[ 1 ].
    fp_p_file = lx_filetable-filename.
  ENDIF.
  SPLIT fp_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FILE  text
*----------------------------------------------------------------------*
FORM get_data CHANGING p_file.

  DATA : i_type    TYPE truxs_t_text_data.
  DATA : lv_file TYPE rlgrap-filename.

  IF ename EQ 'XLSX' OR ename EQ 'XLS'.
    REFRESH gt_file[].
    lv_file = p_file.
***  FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = gt_file[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    DELETE gt_file[] FROM 1 TO 2.
    IF gt_file IS INITIAL.
      MESSAGE e070(zmsg_cls).
    ENDIF.
  ELSE.
    MESSAGE e069(zmsg_cls).
  ENDIF.
ENDFORM.


FORM process_data.
  FIELD-SYMBOLS :
    <ls_file> TYPE ty_file,
    <ls_ean>  TYPE zean_pos.

  REFRESH : gt_ean.

*** Get Existing Material data
  SELECT matnr,
         ean11
         INTO TABLE @DATA(lt_mara)
         FROM mara
         FOR ALL ENTRIES IN @gt_file
         WHERE ean11 = @gt_file-ean.

  SELECT matnr,
         ean
         INTO TABLE @DATA(lt_ean)
         FROM zean_pos
         FOR ALL ENTRIES IN @gt_file
         WHERE ean = @gt_file-ean.

  LOOP AT gt_file ASSIGNING <ls_file>.
*** Checking For Data Exist
    READ TABLE lt_mara ASSIGNING FIELD-SYMBOL(<ls_mara>) WITH KEY ean11 = <ls_file>-ean.
    IF sy-subrc = 0.
      <ls_file>-type = c_e.
      <ls_file>-message = 'EAN Already Exist in Masters with' && <ls_mara>-matnr.
      CONTINUE.
    ELSE.
      READ TABLE lt_ean ASSIGNING FIELD-SYMBOL(<ls_ean_m>) WITH KEY ean = <ls_file>-ean.
      IF sy-subrc = 0.
        <ls_file>-type = c_e.
        <ls_file>-message = 'EAN Already Exist in Masters with' && <ls_ean_m>-matnr.
        CONTINUE.
      ENDIF.
    ENDIF.

*** Sending Data to POS
    FREE : data_out ,data_in.
*** Creating Object for Logical Port
    CREATE OBJECT cl_proxy EXPORTING logical_port_name = 'ZZSAVE_UPC'.
    APPEND VALUE #( product_id = <ls_file>-matnr upc = <ls_file>-ean uo_m = <ls_file>-meins ) TO data_in-save_alternate_upc_s4hana-save_alternate_upc-alternate_upclist-upctranslation.
*** Calling Service Consumer
    TRY.
        CALL METHOD cl_proxy->save_alternate_upc_s4hana
          EXPORTING
            input  = data_in
          IMPORTING
            output = data_out.
      CATCH cx_ai_system_fault. " Communication Error
    ENDTRY.

    READ TABLE data_out-save_alternate_upc_s4hana_resp-save_alternate_upcresponse-save_alternate_upcresult-upctranslation ASSIGNING FIELD-SYMBOL(<ls_result>) INDEX 1.
    IF sy-subrc IS INITIAL.
      IF <ls_result>-message = 'Success'.
        <ls_file>-type = c_s.
        <ls_file>-message = <ls_result>-message.
*** Appending EAN data to update in Custom Table
        APPEND INITIAL LINE TO gt_ean ASSIGNING <ls_ean>.
        <ls_ean>-mandt      = sy-mandt.
        <ls_ean>-matnr      = <ls_file>-matnr.
        <ls_ean>-ean        = <ls_file>-ean.
        <ls_ean>-meins      = <ls_file>-meins.
        <ls_ean>-created_by = sy-uname.
        <ls_ean>-created_on = sy-datum.
      ELSE.
        <ls_file>-type = c_e.
        <ls_file>-message = <ls_result>-message.
      ENDIF.
    ELSE.
      <ls_file>-type = c_e.
      <ls_file>-message = 'Connection Error'.
    ENDIF.
  ENDLOOP.

  IF gt_ean IS NOT INITIAL.
    MODIFY zean_pos FROM TABLE gt_ean.
  ENDIF.
ENDFORM.


FORM display_data.
  DATA : lr_alv TYPE REF TO cl_salv_table.

*** local data
  DATA: lo_cols      TYPE REF TO cl_salv_columns,
        lr_functions TYPE REF TO cl_salv_functions,
        lr_layout    TYPE REF TO salv_s_layout.
*** Declaration for Global Display Settings
  DATA : gr_display TYPE REF TO cl_salv_display_settings.
*** declaration for ALV Columns
  DATA: lo_column TYPE REF TO cl_salv_column,
        lo_layout TYPE REF TO cl_salv_layout,
        ls_key    TYPE salv_s_layout_key.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
        IMPORTING
        r_salv_table   = lr_alv                       " Basis Class Simple ALV Tables
        CHANGING
        t_table        = gt_file ).

      lo_cols = lr_alv->get_columns( ).

***   Column optimization
      lo_cols->set_optimize( 'X' ).
      gr_display = lr_alv->get_display_settings( ).
      gr_display->set_striped_pattern( cl_salv_display_settings=>true ).

***   Get layout object
*** Material
      TRY.
          lo_column = lo_cols->get_column( 'MATNR' ).
          lo_column->set_long_text( 'Material' ).
          lo_column->set_medium_text( 'Material' ).
          lo_column->set_short_text('Material').
        CATCH cx_salv_not_found.
      ENDTRY.

*** EAN
      TRY.
          lo_column = lo_cols->get_column( 'EAN' ).
          lo_column->set_long_text( 'EAN' ).
          lo_column->set_medium_text( 'EAN' ).
          lo_column->set_short_text('EAN').
        CATCH cx_salv_not_found.
      ENDTRY.

*** UOM
      TRY.
          lo_column = lo_cols->get_column( 'UOM' ).
          lo_column->set_long_text( 'UOM' ).
          lo_column->set_medium_text( 'UOM' ).
          lo_column->set_short_text('UOM').
        CATCH cx_salv_not_found.
      ENDTRY.

*** Message Type
      TRY.
          lo_column = lo_cols->get_column( 'TYPE' ).
          lo_column->set_long_text( 'Msg Type' ).
          lo_column->set_medium_text( 'Msg Type' ).
          lo_column->set_short_text('Msg Type').
        CATCH cx_salv_not_found.
      ENDTRY.

*** Message
      TRY.
          lo_column = lo_cols->get_column( 'MESSAGE' ).
          lo_column->set_long_text( 'Message' ).
          lo_column->set_medium_text( 'Message' ).
          lo_column->set_short_text('Message').
        CATCH cx_salv_not_found.
      ENDTRY.

      lo_layout = lr_alv->get_layout( ).
***   Set Layout save restriction
***   1. Set Layout Key - Unique key identifies the Differenet ALVs
      ls_key-report = sy-repid.
      lo_layout->set_key( ls_key ).
***   2. Remove Save layout the restriction.
      lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).

    CATCH cx_salv_msg.
  ENDTRY .
  lr_alv->display( ).
ENDFORM.
