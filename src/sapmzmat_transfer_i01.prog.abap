*&---------------------------------------------------------------------*
*& Include          SAPMZMAT_TRANSFER_I01
*&---------------------------------------------------------------------*

MODULE user_command_1000 INPUT.
  CASE sy-ucomm.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'EXEC'.
*      PERFORM excel.
      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
        EXPORTING
          i_line_header        = 'X'
          i_tab_raw_data       = gt_type
          i_filename           = p_file
        TABLES
          i_tab_converted_data = it_item
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.

      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

*    WHEN 'BATCH'.
*      PERFORM get_batch.
    WHEN 'POST'.
      PERFORM goods_mvt.
    WHEN 'DELT'.
      DELETE it_item WHERE sel EQ 'X'.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPD_TAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE upd_tab INPUT.
  MODIFY it_item  FROM wa_item INDEX tc1-current_line.
  IF sy-subrc NE 0.
    APPEND wa_item TO it_item.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_FILE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_file INPUT.
  DATA: li_filetable    TYPE filetable,
        lx_filetable    TYPE file_table,
        lv_return_code  TYPE i,
        lv_window_title TYPE string.

  lv_window_title = TEXT-002.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_window_title
*     DEFAULT_EXTENSION       =
*     DEFAULT_FILENAME        =
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    CHANGING
      file_table              = li_filetable
      rc                      = lv_return_code
*     USER_ACTION             =
*     FILE_ENCODING           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE   li_filetable INTO lx_filetable INDEX 1.
*
  p_file = lx_filetable-filename.



*  SPLIT FILENAME AND EXTENSION NAME TO VALIDATE FILETYPE
  SPLIT p_file AT '.' INTO fname ename.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE ename TO UPPER CASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_chain INPUT.
  CHECK sy-ucomm NE 'BACK' AND sy-ucomm NE 'CANCEL'.
  PERFORM validate_item.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_DATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_date INPUT.
  CALL FUNCTION 'F4_DATE'
    EXPORTING
      date_for_first_month = wa_header-budat
      display              = ' '
    IMPORTING
      select_date          = wa_header-budat
    EXCEPTIONS
      OTHERS               = 8.
ENDMODULE.
