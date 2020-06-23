*&---------------------------------------------------------------------*
*&      Form  OKB_STCL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_stcl.

  zeile = zeile + index_neu - 1.
  read table klastab index zeile.
  zeile = zeile - index_neu + 1.
  ssytabix = syst-tabix.
  if syst-subrc ne 0.
    leave screen.
  endif.
  if not change_subsc_act is initial.
    read table allkssk index klastab-index_tab.
    if not rmclf-aennr1 is initial.
      if rmclf-aennr1 ne allkssk-aennr.
        if allkssk-datuv = rmclf-datuv1.
          message s564.
          leave screen.
        endif.
      endif.
    endif.
  endif.
  clear allksskanfang.
  if allkssk-lock is initial.
    perform build_viewtab using allkssk-clint
                                allkssk-class.
  endif.
  klastab-lock = kreuz.
  if klastab-stdcl = kreuz.
    clear klastab-stdcl.
    clear standardklasse.
  else.
    if standardklasse = 0.
      standardklasse = 1.
      klastab-stdcl = kreuz.
    else.
      message i520.
    endif.
  endif.
  klastab-statuaen = konst_z.
  modify klastab index ssytabix.
  aenderflag = kreuz.

endform.                               " OKB_STCL
