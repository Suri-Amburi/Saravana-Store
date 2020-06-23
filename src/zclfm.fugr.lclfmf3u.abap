*&---------------------------------------------------------------------*
*&      Form  RMCLF_ABTEI_CHK
*&---------------------------------------------------------------------*
*       RMCLF-ABTEI wird nur noch als EA-Feld verwendet, g_sicht_akt
*       ist die echte globale Variable
*----------------------------------------------------------------------*
*  Lediglich globale Daten als Schnittstelle
*----------------------------------------------------------------------*
form rmclf_abtei_chk.
  data: l_end    like rmclf-kreuz,
        l_tabix  like sy-tabix,
        l_view(1) .
  clear department.
  clear : l_tabix, l_view, l_end.
  rmclf-abtei = g_sicht_akt.
  condense rmclf-abtei no-gaps.
  while l_end  is initial.
*-- View prüfen
    l_view = rmclf-abtei+l_tabix(1).
    if l_view is initial.
*-- Ende in RMCLF-ABTEI ist erreicht!
      l_end = kreuz.
      continue.
    else.
      if rmclf-abtei cs l_view.
*-- Gab es die View schon in RMCLF-ABTEI??
        if sy-fdpos lt l_tabix.
*-- ... gab es schon: Space!
          rmclf-abtei+l_tabix(1) = space.
          l_tabix = l_tabix + 1.
          continue.
        endif.
      endif.
    endif.
    l_tabix = l_tabix + 1.
    if l_tabix gt 10.
*-- Mehr als 10 gibts nicht!
      l_end = kreuz.
      continue.
    endif.
    select single * from tcls
     where klart eq rmclf-klart
      and  sicht eq l_view.
    if not sy-subrc is initial.
      message e001 with 'rmclf_abtei_chk'  'l_view'.
    endif.
  endwhile.
  condense rmclf-abtei no-gaps.
  set parameter id c_param_view field rmclf-abtei.
*-- g_sicht_akt anpassen
  g_sicht_akt = rmclf-abtei .

endform.                               " RMCLF_ABTEI_CHK
