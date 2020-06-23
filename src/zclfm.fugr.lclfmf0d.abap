*&---------------------------------------------------------------------*
*&      Form  OKB_STAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_stat.

  data: l_inob_init like inob-cuobj .

  zeile = zeile + index_neu - 1.
  if g_zuord = c_zuord_4.
    read table g_obj_indx_tab index zeile.
    zeile = zeile - index_neu + 1.
    if syst-subrc ne 0.
      leave screen.
    endif.

    read table klastab index g_obj_indx_tab-index.
    if syst-subrc ne 0.
      leave screen.
    endif.
*   ssytabix = syst-tabix.
    ssytabix   = klastab-index_tab.
    pm_objek = klastab-objek.
    pm_class = rmclf-clasn.
    mafid    = klastab-mafid.
    if klastab-mafid = mafido.
      read table redun with key klastab-obtab binary search.
    else.
      read table redun with key obtab = space binary search.
    endif.
    if redun-aediezuord = kreuz.
      if rmclf-aennr1 is initial and g_obj_indx_tab-showo ne kreuz.
        if klastab-mafid = mafidk.
          save_objek = klastab-clint.
        else.
          save_objek = klastab-objek.
        endif.
        mafid = klastab-mafid.
        perform check_kssk_count using
                             save_objek rmclf-klart mafid
                             sobtab l_inob_init syst-subrc.
        if syst-subrc > 0.
          message w562.
          g_display_values = kreuz.
        endif.
      endif.
    endif.
  else.
    read table klastab index zeile.
    zeile = zeile - index_neu + 1.
    if syst-subrc ne 0.
      leave screen.
    endif.
*   ssytabix   = syst-tabix.
    ssytabix   = klastab-index_tab.
    pm_objek   = rmclf-objek.
    pm_class   = klastab-objek.
    klas_pruef = klastab-praus.
  endif.

  if not change_subsc_act is initial.
*    IF G_ZUORD NE C_ZUORD_4.
*      READ TABLE ALLKSSK WITH KEY
*                              OBJEK = RMCLF-OBJEK
*                              CLINT = KLASTAB-CLINT
*                              KLART = RMCLF-KLART
*                              MAFID = KLASTAB-MAFID BINARY SEARCH.
*    ELSE.
*      READ TABLE ALLKSSK WITH KEY
*                              OBJEK = KLASTAB-OBJEK
*                              CLINT = PM_CLINT
*                              KLART = RMCLF-KLART
*                              MAFID = KLASTAB-MAFID.
*    ENDIF.
    if not rmclf-aennr1 is initial.
      if rmclf-aennr1 ne allkssk-aennr.
        if allkssk-datuv = rmclf-datuv1
                       and g_effectivity_used is initial.
          message s564.
          leave screen.
        endif.
      endif.
    endif.
  endif.

  read table allkssk index ssytabix.
  describe table itclc lines syst-tfill.
  x2 = syst-tfill + 4.
  if x2 > 14.
    x2 = 14.
  endif.
  call screen dy601 starting at 30 3
                    ending   at 68 x2.
  if sokcode = okabbr.
    leave screen.
  endif.
  fname = 'RMCLF-STATU'.
  check cl_status_neu <> allkssk-statu.
  if cl_status_neu = cl_statusf.
*-- KLAS_PRUEF so setzen, daß SEL in STATUS_CHECK gelesen wird
    g_klas_pruef = klas_pruef.
    klas_pruef = konst_w.
    g_consistency_chk = kreuz.
    perform status_check using allkssk-klart.
    klas_pruef = g_klas_pruef.
  endif.

  clear allksskanfang.
* klastab-statu    = cl_status_neu.
* modify klastab index ssytabix.
  allkssk-statu    = cl_status_neu.
  modify allkssk index ssytabix.
  klastab-statuaen = kreuz.
  aenderflag = kreuz.

endform.                               " OKB_STAT
