*------------------------------------------------------------------*
*       MODULE OK_BEENDEN_WIN                                      *
*------------------------------------------------------------------*
*       Exit-Command für Windows                                   *
*------------------------------------------------------------------*
module ok_beenden_win input.
  sokcode = okcode.
  clear okcode.
  zeile = 0.
  if sy-dynnr = dy605.
*-- Rücknahme der VIEW-Definitionen
    g_sicht_akt = G_VIEW_BUP.
    set parameter id c_param_view field G_VIEW_BUP.
  endif.
  set screen dy000.
  leave screen.
endmodule.
