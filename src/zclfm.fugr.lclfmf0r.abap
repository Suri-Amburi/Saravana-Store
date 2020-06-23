*&---------------------------------------------------------------------*
*&      Form  OKB_LOES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_loes.

  data: l_idx like sy-stepl.

  if syst-dynnr = dy602.
    import rmclindx from database indx(cf) id relid.
    check syst-subrc = 0.
    clear rmclindx-zeile1.
    export rmclindx to database indx(cf) id relid.
    clear zeile1.
    loop at redun where radio = punkt.
      clear redun-radio.
      modify redun.
      exit.
    endloop.
    leave screen.

  else.
    if cn_mark > 0.
*-- Es gibt Markierungen
      clear cn_mark.
      clear fname.
      clear markzeile1.
      index_neu = 1.
*-- Der erste Eintrag wird gesetzt
      antwort = kreuz.
      loop at klastab where markupd = kreuz.
*-- Markierungen werden zurückgenommen (weshalb??)
*-- Nach Problem mit Retail: Markierung wird für WWS gelassen
        if g_appl ne konst_w.
          clear klastab-markupd.
          modify klastab.
        endif.
        l_idx = syst-tabix.
*-- Akt. Zeile wird gesetzt.
        g_clint = pm_clint.
        perform auswahl using antwort l_idx.
        perform popup_loeschen.
        pm_clint = g_clint .
      endloop.
      clear zeile.
    else.
      check zeile ne 0.
*-- Keine Markierungen gesetzt: ZEILE wird genommen
      antwort = kreuz.
      g_clint = pm_clint.
      l_idx = index_neu + zeile - 1.
      perform auswahl using antwort l_idx.
*     zeile = zeile - index_neu + 1.
      if antwort = kreuz.
        message s501.
        leave screen.
      endif.
      perform popup_loeschen.
      pm_clint = g_clint .
    endif.
  endif.

endform.                               " OKB_LOES
