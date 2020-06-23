*------------------------------------------------------------------*
*       MODULE GET_CURSOR INPUT                                    *
*------------------------------------------------------------------*
*       Cursorposition ermitteln                                   *
*------------------------------------------------------------------*
module get_cursor input.

  if g_46_ta = kreuz.
    get cursor field fname area g_tcname line zeile.
    if sy-subrc <> 0.
      clear zeile.
    endif.
    if g_zuord <> c_zuord_4.
      clear pm_depart.
    else.
      pm_depart = kreuz.
    endif.

*--------------------------------------------------------
  else.
    get cursor field fname line zeile.
    if syst-subrc ne 0.
      clear zeile.
    endif.
    if sokcode = okeint.
      clear fname.
*   zeile = 1.                                             "  4.6a
    endif.

*  Zeile:
*  zähle die aktuelle Zeile im table control (wie mit
*  get cusor bestimmt), der Index in einer
*  internen Tabelle ist nicht gemeint !
*  ZEILE = ZEILE + TC_OBJ_CLASS-TOP_LINE - 1 .

    if hzeile = zeile.
      pm_depart = kreuz.
      clear hzeile.
    else.
      if g_zuord ne c_zuord_4.
        clear pm_depart.
      endif.
    endif.
  endif.

endmodule.
