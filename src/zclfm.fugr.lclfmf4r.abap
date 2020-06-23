*&---------------------------------------------------------------------*
*&      Form  ok_STCL
*&---------------------------------------------------------------------*
*       Change standard class. Only CL20N.
*----------------------------------------------------------------------*
form ok_stcl.

  zeile = zeile + index_neu - 1.
  read table klastab index zeile.
  zeile = zeile - index_neu + 1.
  ssytabix = syst-tabix.
  if syst-subrc <> 0.
    message s501.
    leave screen.
  endif.
  read table allkssk index klastab-index_tab.
  if not change_subsc_act is initial.
*   read table allkssk index klastab-index_tab.
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
  klastab-statuaen = kreuz.            "konst_z.
  modify klastab index ssytabix.
  allkssk-stdcl = klastab-stdcl.
  modify allkssk index klastab-index_tab.
  aenderflag = kreuz.

endform.                               " ok_STCL
