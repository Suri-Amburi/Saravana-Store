*&---------------------------------------------------------------------*
*&      Form  OKB_OBWE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_obwe.

*-- Kann eigentlich nur bei CL24 vorkommen
  import rmclindx from database indx(cf) id relid.
  zeile1 = rmclindx-zeile1.
  if zeile1 > 0.
    read table redun1 index zeile1.
    read table redun  index redun1-index.
    redun-radio = punkt.
    modify redun index redun1-index.
  endif.
  index_neu1 = 1.
  describe table redun1 lines x2.
  x2 = x2 + 10.
  call screen dy602                    "auswählen Klassen oder
      starting at 32 8                 "Objektzuordnung
      ending   at 79 x2.
  if sokcode = okabbr.
    clear okcode.
    leave screen.
  endif.
  clear anzzeilen.
  clear rmclf-paganz.
  pag_page     = 1.
  pag_pages    = 1.
  rmclf-pagpos = 0.
  index_neu    = 1.
  antwort = kreuz.
  loop at klastab where index_tab gt 0 .
    g_clint = pm_clint.
    zeile = syst-tabix.
    perform auswahl using antwort zeile.
    if syst-subrc = 0.
      perform ohne_bewertung.
    endif.
    read table klastab index g_klastab_akt_index.
    clear klastab-markupd.
    clear klastab-statuaen.
    modify klastab index g_klastab_akt_index.
    xzeile = xzeile + 1.
    pm_clint = g_clint .
  endloop.
  clear   klastab.
  zeile = 0.
  if not redun-obtab is initial.
    sokcode = okeint.
    sobtab = redun-obtab.
    set screen dy512.
  else.
    if clhier is initial.
      message e571 with rmclf-klart.
    endif.
    clear klastab.
    sobtab = pobtab.
    do anzloop times.
      append klastab.
    enddo.
    set screen dy510.
  endif.
  leave screen.

endform.                               " OKB_OBWE
