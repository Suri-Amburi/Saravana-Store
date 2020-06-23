*&---------------------------------------------------------------------*
*&      Form  ok_UEB_BILD
*&---------------------------------------------------------------------*
*       Called after ok_wei1, ok_vobi. Only object transactions.
*       Go back to screen of object trx.
*----------------------------------------------------------------------*
form ok_ueb_bild .

  data: l_exit  type c.

  check g_cl_ta is initial.            " object transaction
  clear l_exit.

  if classif_status = c_display.
    l_exit = kreuz.
  else.
    perform leave_clfy changing l_exit.
  endif.

  if l_exit = kreuz.
    set screen dy000.
    leave screen.
  endif.

endform.                               " ok_UEB_BILD
