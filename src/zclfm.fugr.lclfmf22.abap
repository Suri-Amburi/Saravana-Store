*------------------------------------------------------------------*
*        FORM DELETE_OBJ_CLASSIFICATION                            *
*------------------------------------------------------------------*
*        Delete classification data of an object:
*        all allocations, all valuations
*------------------------------------------------------------------*
form delete_obj_classification.


* ensure final call to exit                                      2241496
  perform cust_exit_post USING 'X'.                           "  2241496

* adjust internal tables relating to DELOB
  perform check_delob_all_tabs.

* BTE interface
  perform open_fi_sfa.

  if g_no_upd_task is initial.
    call function 'CLVF_VB_DELETE_OBJECT' in update task
         tables
              delob  = delob
         exceptions
              others = 1.
  else.
    call function 'CLVF_VB_DELETE_OBJECT'
         tables
              delob  = delob
         exceptions
              others = 1.
  endif.

  refresh delob.
  g_no_upd_task_chg = kreuz.

* initialisation possible or other data to update ?
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
      read table delcl index 1.
      if sy-subrc > 0.
        call function 'CLAP_DDB_INIT_CLASSIFICATION'.
* reset buffer data for CLO0                   "1602754
        CALL FUNCTION 'CLO0_DDB_INIT'   .      "1602754
      endif.
    endif.
  endif.

  clear g_open_fi_sfa.

endform.                               " delete_obj_classification
