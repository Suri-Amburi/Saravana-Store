*&---------------------------------------------------------------------*
*& Report ZMM_BATCH_KEY_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_batch_key_update.

*** Type Declearations
TYPES :
  BEGIN OF ty_file,
    charg(10),
    pos_key(16),
  END OF ty_file,

  BEGIN OF ty_result,
    charg   TYPE charg_d,
    pos_key TYPE zbatchsrl_informationkey,
    message TYPE etmessage,
  END OF ty_result.

*** Table Declearations
DATA :
  gt_file   TYPE TABLE OF ty_file,
  gs_file   TYPE ty_file,
  gt_result TYPE TABLE OF ty_result.

*** Data Declearations
DATA :
  gv_fname    TYPE localfile,  " File Name
  gv_ename(4),                 " Extenstion
  gv_a_file   TYPE string .    " Application File Path


*** Constants
CONSTANTS :
  c_x(1)       VALUE 'X',
  c_fail(6)    VALUE 'Fail',
  c_success(7) VALUE 'Success',
  c_job        TYPE tbtcjob-jobname    VALUE 'ZPOS_KEY_UPDATE',
  c_false      TYPE boolean VALUE space.

DATA : lv_charg TYPE charg_d.
PARAMETERS : p_file TYPE string.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.
***  Get Data from Xls to table
  PERFORM get_data_xls TABLES gt_file.
*** Upload Data
  PERFORM upload_data TABLES gt_file[].
*** Display Results
  PERFORM display_data.



FORM get_filename CHANGING fp_p_file.

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
  IF li_filetable IS NOT INITIAL.
    fp_p_file = li_filetable[ 1 ]-filename.
  ENDIF.
  SPLIT fp_p_file AT '.' INTO gv_fname gv_ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE gv_ename TO UPPER CASE.

ENDFORM.

FORM get_data_xls TABLES gt_file.

  DATA : lv_file TYPE rlgrap-filename,
         i_type  TYPE truxs_t_text_data.

***  PROCEED ONLY IF ITS A VALID FILETYPE
  IF gv_ename EQ 'XLSX' OR gv_ename EQ 'XLS'.
    REFRESH gt_file.
    lv_file = p_file.

***   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = gt_file[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    DELETE gt_file[] FROM 1 TO 1.
    IF gt_file[] IS INITIAL.
*** No records to upload
      MESSAGE e091(zmsg_cls).
    ENDIF.
  ELSE.
***   Invalid File type : only possible types XLS & XLSX
    MESSAGE e097(zmsg_cls).
  ENDIF.
ENDFORM.


FORM upload_data TABLES gt_file STRUCTURE gs_file.

  FIELD-SYMBOLS :
    <ls_mch1>   TYPE mch1,
    <ls_file>   TYPE ty_file,
    <ls_result> TYPE ty_result.
  DATA : ls_result TYPE ty_result.
  SELECT * FROM mch1 INTO TABLE @DATA(lt_mch1) FOR ALL ENTRIES IN @gt_file WHERE charg = @gt_file-charg.
  IF sy-subrc IS INITIAL.
    SORT lt_mch1 BY charg.
    SORT gt_file BY charg.
    LOOP AT lt_mch1 ASSIGNING <ls_mch1>.
      READ TABLE gt_file ASSIGNING <ls_file> WITH KEY charg = <ls_mch1>-charg.
      IF sy-subrc IS INITIAL.
        APPEND INITIAL LINE TO gt_result ASSIGNING <ls_result>.
        <ls_mch1>-zzbatchsrl_informationkey = <ls_file>-pos_key.
        <ls_result>-charg   = <ls_mch1>-charg.
        <ls_result>-pos_key = <ls_mch1>-zzbatchsrl_informationkey.
        <ls_result>-message = c_success.
      ENDIF.
    ENDLOOP.
    MODIFY mch1 FROM TABLE lt_mch1.
    IF sy-subrc IS INITIAL.
      ls_result-message = c_fail.
      MODIFY gt_result FROM ls_result TRANSPORTING message WHERE message = ''.
    ELSE.
      ls_result-message = c_fail.
      MODIFY gt_result FROM ls_result TRANSPORTING message.
    ENDIF.
  ELSE.
***  No data found for given input
    MESSAGE e011(zmsg_cls).
  ENDIF.
ENDFORM.


FORM display_data.
  DATA : lr_alv       TYPE REF TO cl_salv_table,
         lr_cols      TYPE REF TO cl_salv_columns,
         lr_col       TYPE REF TO cl_salv_column,
         lr_functions TYPE REF TO cl_salv_functions,
         lr_display   TYPE REF TO cl_salv_display_settings.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
        IMPORTING
        r_salv_table   = lr_alv                       " Basis Class Simple ALV Tables
        CHANGING
        t_table        = gt_result ).

***   Column optimization
      lr_cols = lr_alv->get_columns( ).
      lr_cols->set_optimize( c_x ).
      lr_display = lr_alv->get_display_settings( ).
      lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).

*** Batch
      lr_col = lr_cols->get_column( 'CHARG' ).
      lr_col->set_long_text('Batch' ).
      lr_col->set_medium_text('Batch' ).
      lr_col->set_short_text('Batch').

      lr_col = lr_cols->get_column( 'POS_KEY' ).
      lr_col->set_long_text('Pos Key' ).
      lr_col->set_medium_text('Pos Key' ).
      lr_col->set_short_text('Pos Key').

    CATCH cx_salv_msg.
  ENDTRY .
  lr_alv->display( ).
ENDFORM.
