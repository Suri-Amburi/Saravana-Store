*&---------------------------------------------------------------------*
*&      Form  ok_RELE
*&---------------------------------------------------------------------*
*       Release all allocations marked in table control.
*       Open / close valuations before status check.
*----------------------------------------------------------------------*
form ok_rele.

  data:
    l_allkssk      like rmclkssk,
    l_count        type n          value 0,
    l_objek_save   like rmclf-objek,
    l_subrc        like sy-subrc,
    l_tabix        like sy-tabix.


* first save previous value assignment
  perform close_prev_value_assmnt changing l_subrc.

  clear cn_mark.
  clear fname.
  l_objek_save = g_val-objek.

  loop at klastab where markupd = kreuz.
    check klastab-statu <> cl_statusf.
    check klastab-mafid =  mafido.
    clear l_allkssk.
    read table allkssk index klastab-index_tab
                       into l_allkssk.
    if sy-subrc = 0 and
       l_allkssk-statu <> cl_statusf.
*     allocation found
      g_allkssk_akt_index = klastab-index_tab.
      l_tabix             = klastab-index_tab.
      pm_objek  = l_allkssk-objek.
      pm_inobj  = l_allkssk-cuobj.
      pm_class  = l_allkssk-class.
      pm_status = cl_statusf.
      mafid     = mafido.
      perform classify.
      call function 'CLSE_CLFM_BUF_FLAGS'
        exporting
          i_ausp_flg = g_buffer_clse_active
          i_kssk_flg = space
        exceptions
          others     = 0.

*     klas_pruef set in CLFM-OBJECTS_CL
      g_consistency_chk = kreuz.
      clear cl_status_neu.
      perform status_check using l_allkssk-klart.
      if cl_status_neu is initial.
*       update status to 1
        l_allkssk-statu = cl_statusf.
      else.
*       no update to 1 possible: count
        l_allkssk-statu = cl_statusus.
        l_count = l_count + 1.
      endif.
      read table allkssk index l_tabix.
      if allkssk-statu <> l_allkssk-statu.
        allkssk-statu = l_allkssk-statu.
        if allkssk-vbkz <> c_insert.
          allkssk-vbkz = c_update.
        endif.
        modify allkssk index l_tabix
                       transporting statu vbkz.
        klastab-statu = l_allkssk-statu.
        modify klastab transporting statu.
        kssk_update = kreuz.
      endif.
    endif.
  endloop.

  if sy-subrc <> 0.
    message s234.                      " 'No line marked.'
  endif.
  if l_count > 0.
    message s498 with l_count.
  endif.

  if l_objek_save is initial.
    clear g_val-objek.
    clear g_klastab_val_idx.
    call function 'CTMS_DDB_INIT'.
  else.
*   valuation screen already called: recall to readjust
    loop at klastab where objek = l_objek_save.
      g_clint = pm_clint.
      perform auswahl using antwort sy-tabix.
      perform classify.
      pm_clint = g_clint .
      exit.
    endloop.
  endif.

endform.                               " ok_RELE
