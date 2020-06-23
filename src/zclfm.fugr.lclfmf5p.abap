*&---------------------------------------------------------------------*
*&      Form  OK_BLOC
*&---------------------------------------------------------------------*
*       Mark bloc of lines.
*----------------------------------------------------------------------*
form ok_bloc.

  if markzeile1 is initial.
*-- erste Zeile markieren
    markzeile1 = zeile + index_neu - 1.
    read table klastab index markzeile1.
    check syst-subrc eq 0.
    if klastab-markupd <> kreuz.
      klastab-markupd = kreuz.
      modify klastab index markzeile1.
      cn_mark = cn_mark + 1.
    endif.
    message s059(c1).

  else.
*-- erste Zeile des Blocks bereits markiert, nun die 2.
    markzeile = zeile + index_neu - 1.
    if markzeile < markzeile1.
*-- Eintrag mit MARKZEILE1 ist bereits markiert!
      zeile1    = markzeile - 1.
      markzeile = markzeile1 - 1.
    else.
      zeile1 = markzeile1.
    endif.
    do.
      zeile1 = zeile1 + 1.
      if zeile1 > markzeile.
        exit.
      endif.
      read table klastab index zeile1.
      check syst-subrc eq 0.
      if klastab-markupd ne kreuz.
        klastab-markupd = kreuz.
        modify klastab index zeile1.
        cn_mark = cn_mark + 1.
      endif.
    enddo.
    clear markzeile1.
  endif.

endform.
