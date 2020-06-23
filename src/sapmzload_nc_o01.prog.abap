*&---------------------------------------------------------------------*
*& Include          SAPMZLOAD_NC_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_9001 output.
  set pf-status '9001'.
  set titlebar '9001'.

  clear ok_code1.
endmodule.
*&---------------------------------------------------------------------*
*& Module STATUS_9999 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_9999 output.
  set pf-status '9999'.
  set titlebar '9999'.

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
endmodule.
