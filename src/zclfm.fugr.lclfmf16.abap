*&---------------------------------------------------------------------*
*&      Form  OKB_BLOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_bloc.

*--------- Block markieren: 4.0: Alles markieren
  if markzeile1 is initial.
*-- erste Zeile markieren (beim Blockmarkieren)
    if g_zuord eq c_zuord_4 and not g_obj_scr is initial .
      markzeile1 = zeile.
    else.
      get cursor field fname line markzeile1.
    endif.
    markzeile1 = markzeile1 + index_neu - 1.
    if g_zuord eq c_zuord_4.
*-- CL24: Innerhalb eines Objekttyps
      read table g_obj_indx_tab index markzeile1.
      check syst-subrc eq 0.
      markzeile1 = g_obj_indx_tab-index.
    endif.
    read table klastab index markzeile1.
    check syst-subrc eq 0.
    if klastab-markupd ne kreuz.
      klastab-markupd = kreuz.
      modify klastab index markzeile1.
      cn_mark = cn_mark + 1.
    endif.
    message s059(c1).
  else.
*-- es wurde bereits die erste Zeile des Blocks markiert, nun die 2.
    if g_obj_scr is initial.
      get cursor field fname line markzeile.
    endif.
    markzeile = markzeile + index_neu - 1.
    if  g_zuord eq c_zuord_4.
*-- ... wieder die CL24 zu einem Objekttyp
      read table g_obj_indx_tab index markzeile.
      check syst-subrc eq 0.
      markzeile = g_obj_indx_tab-index.
    endif.
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
