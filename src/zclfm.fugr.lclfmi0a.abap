*---------------------------------------------------------------------*
*       MODULE MMARKIEREN                                             *
*---------------------------------------------------------------------*
*       Markieren der Zeilen, die verschoben oder bewertet werden     *
*---------------------------------------------------------------------*
module mmarkieren.
  if markzeile1 is initial.
*-- ... nochmals aktuellen Stand KLASTAB lesen
    read table klastab index g_klastab_akt_index.
*-- Einzelsatz markieren
    check  not klastab-objek is initial.
    if klastab-markupd = kreuz.
      check rmclf-kreuz ne kreuz.
      clear klastab-markupd.
      modify klastab index  g_klastab_akt_index.
      cn_mark = cn_mark - 1.
    else.
      check rmclf-kreuz = kreuz.
      klastab-markupd = kreuz.
      modify klastab index g_klastab_akt_index.
      cn_mark = cn_mark + 1.
    endif.
  else.
*-- Block markieren: MARKZEILE1 = Blockende
    markzeile = index_neu.
    do.
      if markzeile = markzeile1.
        exit.
      endif.
      read table klastab index markzeile.
      check sy-subrc is initial and
        not klastab-objek is initial.
      klastab-markupd = kreuz.
      modify klastab index syst-tabix.
      cn_mark = cn_mark + 1.
      if markzeile < markzeile1.
        markzeile = markzeile + 1.
      else.
        markzeile = markzeile - 1.
      endif.
    enddo.
    clear markzeile.
    clear markzeile1.
  endif.
endmodule.
