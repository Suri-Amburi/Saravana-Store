*&---------------------------------------------------------------------*
*& Include          SAPMZLOAD_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS '9001'.
  SET TITLEBAR '9001'.

  CLEAR ok_code1.

 IF gv_x IS NOT INITIAL.
   LOOP AT SCREEN .
     IF screen-name = 'GV_EXIDV'.
      screen-input  = '0' .
      screen-active = '1'.
      MODIFY SCREEN .
    ENDIF.
  ENDLOOP.
 ENDIF.

  ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9999 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9999 OUTPUT.
  SET PF-STATUS '9999'.
  SET TITLEBAR '9999'.

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
