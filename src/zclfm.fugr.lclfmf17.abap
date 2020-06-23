*&---------------------------------------------------------------------*
*&      Form  OKB_AUSW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_ausw.

  data: l_idx like sy-stepl.

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
      clear klastab-markupd.
      modify klastab.
      zeile = syst-tabix.
*-- Akt. Zeile wird gesetzt.
      g_clint = pm_clint.
      perform auswahl using antwort zeile.
      perform klassifizieren.
      pm_clint = g_clint .
    endloop.
    clear zeile.
  else.
    check zeile ne 0.
*-- Keine Markierungen gesetzt: mit ZEILE Index in klastab berechnen
    l_idx = index_neu + zeile - 1.
    g_clint = pm_clint.
    perform auswahl using antwort l_idx.
*   ZEILE = ZEILE - INDEX_NEU + 1.
    if antwort = kreuz.
*      if sy-binpt is initial.
        message s501.
        leave screen.
*      else.
*        sokcode = okabbr.
*        set screen dy000.
*        leave screen.
*      endif.
    endif.
    perform klassifizieren.
    pm_clint = g_clint .
  endif.
endform.
