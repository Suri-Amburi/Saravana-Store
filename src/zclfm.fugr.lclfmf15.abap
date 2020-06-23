*&---------------------------------------------------------------------*
*&      Form  OKB_EINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_eint.
  if g_zuord eq c_zuord_4.
    rmclf-pagpos = rmclf-paganz.
    clear fname.
    if rmclf-paganz is initial.
      index_neu = 1.
      zeile = 1.
    else.
      index_neu    = rmclf-paganz.
      zeile = 2.
    endif.
*+else.
*+  clear klastab.
*+  do anzloop times.
*+    append klastab.
*+  enddo.
  endif.

endform.                               " OKB_EINT
