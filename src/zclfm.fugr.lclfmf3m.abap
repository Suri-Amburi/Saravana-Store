*----------------------------------------------------------------------*
*   form  change_clfy_status
*----------------------------------------------------------------------*
*   Change classification status.
*   Indices g_* are just in module set_index_neu !
*
*   We are now in main screen, not in allocation subscreen !
*----------------------------------------------------------------------*
form change_clfy_status.

  data: l_idx         like sy-stepl,
        l_statu_input like rmclf-statu.

*  if p_newvalue is initial.
*    l_idx = index_neu + zeile - 1.
*  else.
*    l_idx = g_klastab_akt_index.
*  endif.

  l_statu_input = g_clfy_status_new.
  l_idx = index_neu + zeile - 1.
  clear antwort.
  perform auswahl using antwort l_idx. " supplies pm_* parameters
  check antwort is initial.
  check g_display_values is initial.   " only with change number

  if g_zuord = c_zuord_4.
*   change number: check and message in 'auswahl'
  else.
    klas_pruef = allkssk-praus.
  endif.

  if not change_subsc_act is initial.
    if not rmclf-aennr1 is initial.
      if rmclf-aennr1 <> allkssk-aennr.
        if allkssk-datuv = rmclf-datuv1 and
           g_effectivity_used is initial.
          message s564.
          exit.
        endif.
      endif.
    endif.
  endif.

  if g_clfy_status_new is initial.
*   coming from menu
*   open popup to select status, cl_status_neu is set !
    describe table itclc lines syst-tfill.
    x2 = syst-tfill + 4.
    if x2 > 14.
      x2 = 14.
    endif.
    call screen dy601 starting at 30 3
                      ending   at 68 x2.
    if sokcode = okabbr.
      exit.
    endif.
  else.
*   coming from subscreen
    cl_status_neu = l_statu_input.
    clear g_clfy_status_new.
  endif.

* status existing in customizing ? read table tclc
  check allkssk-statu <> space.
  check cl_status_neu <> allkssk-statu.

  if cl_status_neu = cl_statusus or
     cl_status_neu = cl_statuslv.
*   'status & may only be set by the system'
    message e542 with cl_status_neu.
  endif.
  read table xtclc with key mandt = sy-mandt
                            klart = rmclf-klart
                            statu = cl_status_neu.
  if sy-subrc > 0.
    perform lesen_tclc using rmclf-klart.
    read table xtclc with key mandt = sy-mandt
                              klart = rmclf-klart
                              statu = cl_status_neu.
    if sy-subrc <> 0.
      message e540 with cl_status_neu.
    endif.
  endif.
  if sy-subrc = 0.
    if not xtclc-frei is initial.
      cl_status_neu = xtclc-statu.
    endif.
    if not xtclc-gesperrt is initial.
      cl_status_neu = xtclc-statu.
    endif.
    if not xtclc-unvollstm is initial.
      cl_status_neu = xtclc-statu.
    endif.
  endif.
*-------------------------------------------------------------

  fname = 'RMCLF-STATU'.
  check cl_status_neu <> allkssk-statu.

  if cl_status_neu = cl_statusf.
*   first update subscreen to object that status has changed
    pm_status = cl_status_neu.
    call function 'CTMS_DDB_CLOSE'
      TABLES
        exp_selection  = sel
      EXCEPTIONS
        inconsistency  = 1
        incomplete     = 2
        verification   = 3
        not_assigned   = 4
        another_object = 5
        other_objects  = 6
        display_mode   = 7
        others         = 8.
    perform build_allausp.

*-- KLAS_PRUEF so setzen, daß SEL in STATUS_CHECK gelesen wird
    clear g_consistency_chk.
    g_klas_pruef = klas_pruef.
    klas_pruef = konst_w.
    perform status_check using allkssk-klart.
    klas_pruef = g_klas_pruef.
    perform classify.
  endif.

* update only if status is changed
  check cl_status_neu <> allkssk-statu.

  pm_status    = cl_status_neu.
  g_val-status = pm_status.

  clear allksskanfang.
  klastab-statu    = cl_status_neu.
  klastab-statuaen = kreuz.
  modify klastab index g_klastab_akt_index.
  allkssk-statu    = cl_status_neu.
  if allkssk-vbkz ne c_insert.
    allkssk-vbkz   = c_update.
  endif.
  modify allkssk index g_allkssk_akt_index.
  aenderflag = kreuz.

endform.                               " CHANGE_CLFY_STATUS
