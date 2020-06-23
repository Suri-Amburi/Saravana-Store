*&---------------------------------------------------------------------*
*& Include          ZB1_S4_MAP_VENDOR_UPDATE_SUB
*&---------------------------------------------------------------------*

FORM get_data  CHANGING git_file TYPE gty_t_file.

  DATA : i_type    TYPE truxs_t_text_data.
  DATA:lv_file TYPE rlgrap-filename.
*  PROCEED ONLY IF ITS A VALID FILETYPE
  IF ename EQ 'XLSX' OR ename EQ 'XLS'.
    REFRESH git_file[].
    lv_file = p_file.
*   FM TO UPLOAD DATA INTO INTERNAL TABLE FROM EXCEL
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_tab_raw_data       = i_type
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = git_file[]
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    DELETE git_file FROM 1 TO 1.

  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'  .
  ENDIF.

  IF git_file IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
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

*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT fp_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GIT_FILE
*&---------------------------------------------------------------------*
FORM process_data  USING git_file TYPE gty_t_file.

IF git_file IS NOT INITIAL.
 LOOP AT  git_file ASSIGNING FIELD-SYMBOL(<fs>).
   UPDATE zb1_s4_map SET b1_vendor = <fs>-lifnr WHERE b1_batch = <fs>-b1_batch.
 ENDLOOP.
ENDIF.

ENDFORM.
