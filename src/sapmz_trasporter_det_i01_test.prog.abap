*&---------------------------------------------------------------------*
*& Include          SAPMZ_TRASPORTER_DET_I01_TEST
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  OK_CODE = SY-UCOMM .
  CASE OK_CODE.
    WHEN 'INVOICE' .
      IF LV_INVOICE_NO IS INITIAL AND IT_FINAL IS INITIAL .
        MESSAGE 'Please enter the required fields'  TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
      IF LV_INVOICE_NO IS NOT INITIAL.
        MESSAGE 'Invoice is already posted' TYPE 'E' .
      ENDIF.
********INVOICE CREATION*********
      IF LV_BILL IS INITIAL AND IT_FINAL IS NOT INITIAL .
        MESSAGE 'Please enter bill number' TYPE 'I' DISPLAY LIKE 'E' .
      ELSEIF LV_INVOICE_NO IS INITIAL AND IT_FINAL IS NOT INITIAL.
        PERFORM BAPI_INVOICE_POST.
      ENDIF.
*********PAYMENT CREATION********
    WHEN 'PAY'.
      IF LV_PAYMENT IS INITIAL.
        PERFORM PAYMENT .
      ELSE.
        MESSAGE 'Payment is done for this Invoice' TYPE 'E' .
      ENDIF.
    WHEN  'CANCEL' OR 'EXIT' OR 'BACK'.
      LEAVE TO SCREEN 0 .
    WHEN 'REF' .
      CALL TRANSACTION 'ZINV_TEST' .
  ENDCASE.
  CLEAR : OK_CODE , SY-UCOMM .
*  PERFORM GET_DATA.
*  IF IT_FINAL IS NOT INITIAL .
  IF GRID IS BOUND.
*    DATA LS_STABLE TYPE LVC_S_STBL.

    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        FINISHED  = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

  IF CONTAINER IS INITIAL.
    PERFORM SETUP_ALV.
  ENDIF.
  PERFORM FILL_GRID.
*  ENDI F.

ENDMODULE.
