*&---------------------------------------------------------------------*
*& Include          SAPMZ_TRASPORTER_DET_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  ok_code = sy-ucomm .
  CASE ok_code.
    WHEN 'INVOICE'.

      IF lv_invoice_no IS INITIAL AND it_final IS INITIAL. ""added
        MESSAGE 'Please enter the required fields'  TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.

      IF lv_invoice_no IS NOT INITIAL.
        MESSAGE 'Invoice is already posted' TYPE 'E' .
      ENDIF.
********INVOICE CREATION*********
      IF lv_bill IS INITIAL AND it_final IS NOT INITIAL ..
        MESSAGE 'Please enter bill number' TYPE 'I' DISPLAY LIKE 'E' .
      ELSEIF lv_invoice_no IS INITIAL AND it_final IS NOT INITIAL.
        PERFORM bapi_invoice_post.
      ENDIF.
*********PAYMENT CREATION********
    WHEN 'PAY'.
      IF lv_pmode IS INITIAL.
        MESSAGE 'Enter Mode Of Payment' TYPE 'E'.
      ENDIF.

      IF lv_payment IS INITIAL.
        PERFORM payment .
      ELSE.
        MESSAGE 'Payment is done for this Invoice' TYPE 'E' .
      ENDIF.

    WHEN  'CANCEL' OR 'EXIT' OR 'BACK'.
      LEAVE TO SCREEN 0 .
  ENDCASE.
  CLEAR : ok_code , sy-ucomm .
*  PERFORM GET_DATA.
*  IF IT_FINAL IS NOT INITIAL .
  IF grid IS BOUND.
*    DATA LS_STABLE TYPE LVC_S_STBL.

    CALL METHOD grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.

  IF container IS INITIAL.
    PERFORM setup_alv.
  ENDIF.
  PERFORM fill_grid.
*  ENDI F.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_MODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mode INPUT.

IF lv_pmode IS INITIAL.

  MESSAGE 'Enter Payment Mode' TYPE 'E'.

ENDIF.


ENDMODULE.
