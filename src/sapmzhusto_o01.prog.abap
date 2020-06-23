*&---------------------------------------------------------------------*
*& Include          SAPMZHUSTO_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
 SET PF-STATUS '1000'.
 SET TITLEBAR  '1000'.

IF WA_HDR-count IS NOT INITIAL.
  LOOP AT SCREEN.
   IF SCREEN-NAME = 'WA_HDR-TWERKS'.
    SCREEN-INPUT = 0.
    SCREEN-ACTIVE = 1.
    MODIFY SCREEN.
   ENDIF.
  ENDLOOP.
ENDIF.



CLEAR ok_code1.
SELECT SINGLE parva FROM usr05 INTO wa_hdr-werks WHERE bname = sy-uname AND parid = '/SAPAPO/WERKS'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9999 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9999 OUTPUT.
 SET PF-STATUS '9999'.
 SET TITLEBAR '9999'.

 clear ok_code2.

  if gw_mess-err = 'E'.
    gv_icon_name  = 'ICON_RED_LIGHT'.
    gv_text       = 'Error'.

  elseif gw_mess-err = 'W'.
    gv_icon_name = 'ICON_LED_YELLOW'.
    gv_text       = 'Warning'.

  elseif gw_mess-err = 'S'.
    gv_icon_name = 'ICON_GREEN_LIGHT'.
    gv_text       = 'Success'.
  endif.

  call function 'ICON_CREATE'
    exporting
      name       = gv_icon_name
*     text       = gv_text
      info       = 'Status'
      add_stdinf = 'X'
    importing
      result     = gv_icon_9999.


ENDMODULE.
