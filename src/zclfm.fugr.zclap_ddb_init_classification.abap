function ZCLAP_DDB_INIT_CLASSIFICATION.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INIT_ALL) LIKE  RMCLF-KREUZ OPTIONAL
*"     VALUE(IV_OBJEK) LIKE  KSSK-OBJEK DEFAULT SPACE
*"--------------------------------------------------------------------

* Begin of 1619964

data: lv_cuobj like inob-cuobj.

* Just remove one object from buffer
if iv_objek is not initial.

  read table allkssk with key objek = iv_objek.
  if sy-subrc = 0.
*   Delete CUOB buffer
    loop at allkssk where objek = iv_objek.
      CALL FUNCTION 'CUOB_DELETE_OBJECT_FROM_BUFFER'
           EXPORTING
                OBJECT_ID               = allkssk-cuobj
                object_key              = iv_objek
                IV_DELETE_UNCONDITIONED = 'X'.

      DELETE t_ausp WHERE objek = iv_objek.                    "2120752
    endloop.

*   Delete OBJEK from buffer
    delete allkssk where objek = iv_objek.
    delete allausp where objek = iv_objek.

* Delete CUOB buffer, even if there was no entry in ALLKSSK
  else.
    clear lv_cuobj.
    CALL FUNCTION 'CUOB_DELETE_OBJECT_FROM_BUFFER'
         EXPORTING
              OBJECT_ID               = lv_cuobj
              object_key              = iv_objek
              IV_DELETE_UNCONDITIONED = 'X'.
  endif.

* End of 1619964

* If no object was forwarded, we do a complete initialization  "1619964
else.                                                          "1619964

  clear:
       rmclf,
       g_effectivity_used ,                                 "WFS
       g_effectivity_date ,                                 "WFS
       objekt,                                              "WFS
       g_first_call_u01,
       clap_init,
       allkssk,
       allausp,
       delcl,
       sobtab,
       aedi_datuv,
       aedi_aennr,
       only_read,
       g_from_api,
       inobj,
       pm_inobj,
       all_multi_obj,
       multi_obj,
       t_ausp,
       view_complete,
       ghcli,
*+       STPOWA,
       kssk_update,
       del_counter,
       phydel_counter,
       g_open_fi_sfa,
       g_no_lock_klart,
       g_delete_classif_flg,
       redun.                                                  "2445408

  CLEAR hzaehl.                                                "1330405

  refresh allkssk.
  refresh pkssk.
  refresh allausp.
  refresh delcl.
  refresh t_ausp.
  refresh ghcli.
  refresh ghclh.
  refresh iklart.
*+  REFRESH STPOWA.
  refresh chars.
  refresh auspmerk.
  refresh delob.
  refresh gt_getlist.
  refresh redun.                                               "2445408

* multiple objects class types: delete INOB related tables
  if not init_all is initial.
    call function 'CUOB_INIT_DATA'.
  endif.

  call function 'CLSE_INIT_BUFFER'.    "CLSE-Puffer werden gelöscht

*-- Löschen/Rücksetzen auch der CTMS-Puffer und -Memories
  call function 'CTMS_CONFIGURATION_INITIALIZER'.

* reset buffer data for CTCV
  call function 'CTCV_INIT_USER_DATA'.

* reset buffer data for CTCF
  call function 'CTCF_INIT_DATA'.

* dequeue all classifications, which are (still) logged in CLEN
  CALL FUNCTION 'CLEN_DEQUEUE_ALL'                       "begin 1141804
    EXPORTING
      IV_ONLY_RESET       = space.                         "end 1141804

endif.                                                         "1619964

endfunction.
