*&---------------------------------------------------------------------*
*&      Form  OKB_RELE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_rele.
  perform release_marked using g_flag.
  if not g_flag is initial.
    aenderflag = kreuz.
  endif.

endform.                               " OKB_RELE
