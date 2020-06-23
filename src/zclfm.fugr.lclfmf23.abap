*------------------------------------------------------------------*
*        FORM DELETE_CLASSIFICATION                                *
*------------------------------------------------------------------*
*        Delete allocations.
*------------------------------------------------------------------*
form delete_classification.

  data:
    l_initialize            like sy-batch,
    l_delcl                 like rmcldel,
    l_subrc                 like sy-subrc.


* ensure final call to exit                                      2241496
  perform cust_exit_post USING 'X'.                           "  2241496

  if g_delete_classif_flg is initial.
    g_delete_classif_flg = kreuz.
  else.
*   Löschbaustein wurde schon aufgerufen
    exit.
  endif.

* adjust internal tables relating to DELOB
  perform check_delob_all_tabs.

* delete entries in table INOB.
* delete only, if change service is not used.
  if all_multi_obj = kreuz and
     rmclf-aennr1 is initial.
    clear l_delcl.
    sort delcl by mafid klart objek clint merkm.

    loop at delcl where delkssk = space.
      if delcl-cuobj <> l_delcl-cuobj and
         not delcl-cuobj is initial.

        if g_zuord = c_zuord_4.
          sort xkssk by objek mafid klart.
          xkssk-objek = delcl-cuobj.
          read table xkssk with key objek = xkssk-objek
                                    mafid = delcl-mafid
                                    klart = delcl-klart binary search.
        else.
          loop at allkssk transporting no fields
                          where mafid = delcl-mafid
                            and klart = delcl-klart
                            and objek = delcl-objek
                            and clint <> delcl-clint
                            and vbkz  <> c_delete.
            exit.
          endloop.
        endif.

        if sy-subrc <> 0.
          if delcl-klart <> l_delcl-klart.
            select single * from tclao
                            where klart = delcl-klart
                              and obtab = delcl-obtab.
          endif.
          if tclao-aediezuord is initial.
            l_subrc = 4.
          else.
*           Aend.dienst aktiv:
*           Prüfen auf weitere KSSK-Einträge mit Ännr ...
            select * from kssk up to 1 rows
                     where mafid =  delcl-mafid
                       and objek =  delcl-objek
                       and klart =  delcl-klart
                       and aennr <> space.
              exit.
            endselect.
            l_subrc = sy-subrc.
          endif.
          if l_subrc <> 0.
            call function 'CUOB_DELETE_OBJECT'
                 exporting
                      object_id = delcl-cuobj
                      on_commit = space
                 exceptions
                      locked    = 01.
          endif.
        endif.
      endif.                           " -cuobj
      l_delcl = delcl.
    endloop.
  endif.

* BTE interface
  perform open_fi_sfa.

*----------------------------------------------------------------

  if g_no_upd_task is initial.
    call function 'CLVF_VB_DELETE_CLASSIFICATION' in update task
         exporting
              change_service_number = rmclf-aennr1
              date_of_change        = rmclf-datuv1
              table                 = sobtab
         tables
              deletetab             = delcl.
  else.
*-- Nicht in Update Task ausführen
    call function 'CLVF_VB_DELETE_CLASSIFICATION'
         exporting
              change_service_number = rmclf-aennr1
              date_of_change        = rmclf-datuv1
              table                 = sobtab
         tables
              deletetab             = delcl.
  endif.

  g_no_upd_task_chg = kreuz.

* initialize, if no other data to update
* clap_init = x: called in CLFM functions
  if ( g_46_ta   is initial or not delcl[] is initial ) and   "  1682830
       clap_init is initial.
    read table delob index 1.
    if sy-subrc > 0.
      loop at allkssk transporting no fields
                      where vbkz <> space.
        exit.
      endloop.
      if sy-subrc > 0.
        loop at allausp transporting no fields
                        where statu <> space.
          exit.
        endloop.
        if sy-subrc > 0.
          call function 'CLAP_DDB_INIT_CLASSIFICATION'.
        endif.
      endif.
    endif.
  endif.                               " clap_init

  clear g_open_fi_sfa.

endform.                               " delete_classification
