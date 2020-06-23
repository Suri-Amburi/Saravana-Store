*&---------------------------------------------------------------------*
*& Include          SAPMZRETPO_EAN_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
 SET PF-STATUS '1000'.
 SET TITLEBAR '1000' WITH sy-uname sy-datum.


CLEAR ok_code1.
SELECT SINGLE parva FROM usr05 INTO lv_werks WHERE bname = sy-uname AND parid = '/SAPAPO/WERKS'.


IF it_final IS NOT INITIAL.
  LOOP AT SCREEN.
    IF screen-name = 'LV_LIFNR'.
       screen-input = 0.
       screen-active = 1.
       MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
 SET PF-STATUS '9000'.
 SET TITLEBAR '9000'.

 CLEAR ok_code2.
  IF gw_mess-err = 'E'.
    gv_icon_name  = 'ICON_RED_LIGHT'.
    gv_text       = 'Error'.

  ELSEIF gw_mess-err = 'W'.
    gv_icon_name = 'ICON_LED_YELLOW'.
    gv_text       = 'Warning'.

  ELSEIF gw_mess-err = 'S'.
    gv_icon_name = 'ICON_GREEN_LIGHT'.
    gv_text       = 'Success'.
  ENDIF.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name       = gv_icon_name
*     text       = gv_text
      info       = 'Status'
      add_stdinf = 'X'
    IMPORTING
      result     = gv_icon_9999.
ENDMODULE.
