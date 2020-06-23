*&---------------------------------------------------------------------*
*&      Form  OKB_MARK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_mark.

  if g_obj_scr is initial.
    get cursor field fname line markzeile.
  endif.
  if g_zuord eq c_zuord_4 .
*-- Markieren innerhalb eines Objekttyps der CL24
    steploop = markzeile + index_neu - 1.
    read table g_obj_indx_tab index steploop.
    if syst-subrc ne 0.
      exit.
    endif.
    steploop = g_obj_indx_tab-index.
  else.
    steploop = markzeile + index_neu - 1.
  endif.
  if syst-subrc ne 0.
    exit.
  endif.
  read table klastab index steploop.
  if syst-subrc ne 0.
    exit.
  endif.
  if klastab-markupd = kreuz.
    cn_mark = cn_mark - 1.
    clear klastab-markupd.
    if cn_mark is initial.
      clear markzeile1.
    endif.
  else.
    cn_mark = cn_mark + 1.
    klastab-markupd = kreuz.
  endif.
  modify klastab index syst-tabix.
  if markzeile1 > 0.
    read table klastab index markzeile1.
    clear klastab-markupd.
    modify klastab index syst-tabix.
    clear markzeile1.
    cn_mark = cn_mark - 1.
  endif.
endform.                               " OKB_MARK
