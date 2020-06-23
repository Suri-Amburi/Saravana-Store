*&---------------------------------------------------------------------*
*& Report ZMM_B_SAP_BATCHDATA_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_b_sap_batchdata_upload.

DATA: gt_file TYPE TABLE OF zb1_s4_map,
      fname   TYPE localfile,
      ename   TYPE char4.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_file TYPE string.  "rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename CHANGING p_file.

START-OF-SELECTION.
  PERFORM get_data CHANGING gt_file.

  IF gt_file IS NOT INITIAL.
    MODIFY zb1_s4_map FROM TABLE gt_file.
  ENDIF.


*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
FORM get_filename  CHANGING fp_p_file.

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
    lx_filetable = li_filetable[ 1 ].
    fp_p_file = lx_filetable-filename.

  ENDIF.
  SPLIT fp_p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_FILE
*&---------------------------------------------------------------------*
FORM get_data  CHANGING p_gt_file.
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
  ELSE.
    MESSAGE e398(00) WITH 'Invalid File Type'.
  ENDIF.
  IF gt_file IS INITIAL.
    MESSAGE 'No records to upload' TYPE 'E'.
  ENDIF.
ENDFORM.
