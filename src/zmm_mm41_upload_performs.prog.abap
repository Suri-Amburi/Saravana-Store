*&---------------------------------------------------------------------*
*& Include          ZMM_MM41_UPLOAD_PERFORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
*FORM get_filename  CHANGING p_p_file.
*  DATA: li_filetable    TYPE filetable,
*        lx_filetable    TYPE file_table,
*        lv_return_code  TYPE i,
*        lv_window_title TYPE string.
*
*  CALL METHOD cl_gui_frontend_services=>file_open_dialog
*    EXPORTING
*      window_title            = lv_window_title
*    CHANGING
*      file_table              = li_filetable
*      rc                      = lv_return_code
*    EXCEPTIONS
*      file_open_dialog_failed = 1
*      cntl_error              = 2
*      error_no_gui            = 3
*      not_supported_by_gui    = 4
*      OTHERS                  = 5.
*
*  READ TABLE  li_filetable INTO lx_filetable INDEX 1.
*  p_p_file = lx_filetable-filename.
*
*
**  SPLIT fp_p_file AT '.' INTO fname ename.
**  SET LOCALE LANGUAGE sy-langu.
**  TRANSLATE ename TO UPPER CASE.
*
**move: p_matnr to wa_head-material,
**      'X' to wa_head-basic_view.
**
***&-- Custom field value
**move: p_matnr to wa_clientext-material,
**      'A' to wa_clientext-field1.
**append wa_clientext to it_clientext.
**clear wa_clientext.
*
**&-- Set check box to update the specific custom fields
**move: p_matnr to wa_clientextx-material,
**      'X' to wa_clientextx-field1.
**append wa_clientextx to it_clientextx.
**clear wa_clientextx.
*
*
*
*
*  CALL FUNCTION 'BAPI_MATERIAL_MAINTAINDATA_RT'
*    EXPORTING
*      headdata   = wa_head
*    IMPORTING
*      return     = wa_return
*    TABLES
*      clientext  = it_clientext
*      clientextx = it_clientextx.
*
*  IF wa_return-type EQ 'E'.
*    WRITE:/ 'Error in updating the Material'.
*  ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*    WRITE:/ 'Updating the Material is Successful'.
*  ENDIF.
*ENDFORM.

FORM get_filename  CHANGING fp_p_file TYPE string.

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

  DATA : i_type    TYPE truxs_t_text_data.

  DATA:lv_file TYPE rlgrap-filename.


*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.

    REFRESH ta_flatfile[].

    lv_file = p_file.

*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = ta_flatfile[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.


    DELETE ta_flatfile FROM 1 TO 2.

  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF ta_flatfile IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

*wa_head-material =   wa_t_flatfile-mtart .
**      'X' to wa_head-basic_view.
**
***&-- Custom field value
**move: p_matnr to wa_clientext-material,
**      'A' to wa_clientext-field1.
**append wa_clientext to it_clientext.
**clear wa_clientext.
*
**&-- Set check box to update the specific custom fields
**move: p_matnr to wa_clientextx-material,
**      'X' to wa_clientextx-field1.
**append wa_clientextx to it_clientextx.
**clear wa_clientextx.
    CALL FUNCTION 'BAPI_MATERIAL_MAINTAINDATA_RT'
    EXPORTING
      headdata   = wa_head
    IMPORTING
      return     = wa_return
    TABLES
      clientext  = it_clientext
      clientextx = it_clientextx.

  IF wa_return-type EQ 'E'.
    WRITE:/ 'Error in updating the Material'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    WRITE:/ 'Updating the Material is Successful'.
  ENDIF.

ENDFORM.                    " GET_FILENAME

FORM get_data  CHANGING ta_flatfile TYPE ta_t_flatfile.



ENDFORM.
