*&---------------------------------------------------------------------*
*& Include          ZMM_EMP_VEND_BANK_UPD_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
FORM get_filename  CHANGING fp_p_file TYPE  rlgrap-filename.

  DATA: li_filetable    TYPE filetable,
        lx_filetable    TYPE file_table,
        lv_return_code  TYPE i,
        lv_window_title TYPE string.

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

  READ TABLE  li_filetable INTO lx_filetable INDEX 1.
  fp_p_file = lx_filetable-filename.


  SPLIT fp_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDFORM.                    " GET_FILENAME


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_EXCELTAB  text
*----------------------------------------------------------------------*
FORM get_data  CHANGING ta_flatfile TYPE ty_flatfile.

  DATA : i_type    TYPE truxs_t_text_data.

  DATA:lv_file TYPE rlgrap-filename.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.

    REFRESH supl_data[].

    lv_file = p_file.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = supl_data[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    DELETE supl_data FROM 1 TO 2.

  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF supl_data[] IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

ENDFORM.                    " GET_DATA


*&---------------------------------------------------------------------*
*&      Form  CHECK_FILE_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_file_path .

  DATA:lv_file TYPE string,
       lv_res  TYPE char1.


  CHECK sy-batch = ' '.

  lv_file = p_file.

  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file                 = lv_file
    RECEIVING
      result               = lv_res
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      wrong_parameter      = 3
      not_supported_by_gui = 4
      OTHERS               = 5.

  IF lv_res = ' '.
    MESSAGE 'Check File Path'  TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_SUPL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_supl_data .
  DATA : sno TYPE int4 .
  maxline = lines( supl_data[] ) .
  lv_count = maxline / 10 .
  curline  = lv_count .
  LOOP AT supl_data .

**-> Data_processing -> sjena <- 11.04.2019 01:40:11
    text = TEXT-101 .
    IF curline = sy-tabix .
      ADD lv_count TO curline .
      perc = ( curline * 100 ) / maxline.
      PERFORM gui_status_display USING perc text.
    ENDIF.

    sbusinesspartner =  |{ supl_data-lifnr ALPHA = IN }| .
    sbankdetailid = '0001' .
*--> Bank_country -> sjena <- 18.05.2019 20:27:43
    sbankdetaildata-bank_ctry = supl_data-banks .
*--> Bank_key -> sjena <- 18.05.2019 20:27:52
    sbankdetaildata-bank_key = supl_data-bankl .
*--> Bank_account -> sjena <- 18.05.2019 20:28:01
    sbankdetaildata-bank_acct = supl_data-bankn .

    CALL FUNCTION 'BAPI_BUPA_BANKDETAIL_ADD'
      EXPORTING
        businesspartner = sbusinesspartner
        bankdetailid    = sbankdetailid
        bankdetaildata  = sbankdetaildata
*       IMPORTING
*       bankdetailidout =
      TABLES
        return          = sreturn.
    IF  sreturn[] IS INITIAL.
      ADD 1 TO sno .
      slogt-sno = sno .
      slogt-lifnr = supl_data-lifnr .
      slogt-message = 'Bank Details Updated' .
      APPEND slogt .
*--> Commit_work -> sjena <- 18.05.2019 20:38:27
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X' .

    ELSE .
      READ TABLE sreturn WITH KEY type = 'E'.
      IF sy-subrc IS INITIAL.
        ADD 1 TO sno .
        slogt-sno = sno .
        slogt-lifnr = supl_data-lifnr .
        slogt-message = sreturn-message .
        APPEND slogt .
      ELSE .
        ADD 1 TO sno .
        slogt-sno = sno .
        slogt-lifnr = supl_data-lifnr .
        slogt-message = 'Bank Details Updated' .
        APPEND slogt .
*--> Commit_work -> sjena <- 18.05.2019 20:38:27
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X' .
      ENDIF.
    ENDIF.
    REFRESH sreturn .
    CLEAR : sbusinesspartner,sbankdetaildata,sbankdetailid.
  ENDLOOP .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_result .
  TRY.
      cl_salv_table=>factory(
  EXPORTING
  list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
*    r_container    =     " Abstract Container for GUI Controls
*    container_name =
        IMPORTING
        r_salv_table   = lr_alv   " Basis Class Simple ALV Tables
        CHANGING
        t_table        = slogt[]
                                ).

      lo_cols = lr_alv->get_columns( ).

*    *   set the Column optimization
      lo_cols->set_optimize( 'X' ).
      gr_display = lr_alv->get_display_settings( ).
      gr_display->set_striped_pattern( cl_salv_display_settings=>true ).

** header object
*      CREATE OBJECT lo_header.
*      lo_h_label = lo_header->create_label( row = 1 column = 1 ).
*      lo_h_label->set_text( 'Incomplete Pallet Carton Details' ).
*      lr_alv->set_top_of_list( lo_header ).

*      GET layout object
      lo_layout = lr_alv->get_layout( ).
*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
      ls_key-report = sy-repid.
      lo_layout->set_key( ls_key ).
*   2. Remove Save layout the restriction.
*    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).

*      CALL METHOD lr_alv->set_screen_status(
*        EXPORTING
*          report        = sy-repid
*          pfstatus      = 'PF_STAT'
*          set_functions = lr_alv->c_functions_all ).

    CATCH cx_salv_msg.    "
  ENDTRY .
  lr_alv->display( ).
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GUI_STATUS_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->p_perc text
*      -->p_text text
*&---------------------------------------------------------------------*
FORM gui_status_display USING p_perc TYPE i
                              p_text TYPE text100.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = p_perc
      text       = p_text.


ENDFORM.
