*&---------------------------------------------------------------------*
*&      Form  OKB_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_view.

  data: l_clprof like clprof .

  g_view_BUP = g_sicht_akt.
  rmclf-abtei = g_sicht_akt.
  call screen dy605
       starting at 20 10.

endform.                               " OKB_VIEW
