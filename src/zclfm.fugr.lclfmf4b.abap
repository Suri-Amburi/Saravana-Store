*&---------------------------------------------------------------------*
*&      Form  SAVE_ALL
*&---------------------------------------------------------------------*
*       Saves all changes.
*       Called in ok-forms like ok_ende, ok_save, ...
*       classif_status <> c_display  = (tcd_stat = x) !!
*       Return: p_subrc = 0   on-commit-calls called if there are
*                             data to save.
*                       = 4   nothing saved, stay in trx.
*----------------------------------------------------------------------*
form save_all
     changing p_subrc.

  data:                                                  "begin 1141804
    l_class   like rmclf-clasn,
    l_lines   like sy-tfill,
    lv_enqmode TYPE enqmode,
    lv_uname   TYPE sy-msgv1.                              "end 1141804

  p_subrc = 0.
  check classif_status <> c_display.

*--------------------------------------------------------------
* new allocations class/class: check cycles in class hierarchy
*-- Nur sperren, wenn nicht ausdrücklich ausgeschlossen  "begin 1141804
  IF NOT g_no_lock_klart IS INITIAL.
*-- Nur Shared-Sperre
    lv_enqmode = 'S'.
  ELSE.
    lv_enqmode = 'E'.
  ENDIF.

  if g_zuord = c_zuord_2.
    CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'
      EXPORTING
        iv_enqmode           = lv_enqmode
        iv_klart             = rmclf-klart
      EXCEPTIONS
        FOREIGN_LOCK         = 1
        SYSTEM_FAILURE       = 2.
    case sy-subrc.
      when 1.
        lv_uname = sy-msgv1.
        message e549 with lv_uname.                        "end 1141804
      when 2.
        message e519.
    endcase.

    loop at allkssk where vbkz = c_insert .
      perform rekursion_pruefen using allkssk-class
                                      rmclf-clasn
                                      syst-subrc.
      if syst-subrc = 1.
        CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'      "begin 1141804
          EXPORTING
            iv_enqmode       = lv_enqmode
            iv_klart         = rmclf-klart.                "end 1141804
        message s513 with rmclf-klart allkssk-class.
        p_subrc = 4.
        exit.
      endif.
    endloop.
  endif.
  check p_subrc is initial.

  if g_zuord = c_zuord_4.
    clear g_first_rec.
    loop at allkssk where vbkz  = c_insert
                      and mafid = mafidk.
      if g_first_rec = space.
        g_first_rec = kreuz.
        CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'      "begin 1141804
          EXPORTING
            iv_enqmode           = lv_enqmode
            iv_klart             = allkssk-klart
          EXCEPTIONS
            FOREIGN_LOCK         = 1
            SYSTEM_FAILURE       = 2.
        case syst-subrc.
          when 1.
            lv_uname = sy-msgv1.
            message e549 with lv_uname.                    "end 1141804
          when 2.
            message e519.
        endcase.
      endif.
      l_class = allkssk-objek.
      perform rekursion_pruefen using rmclf-clasn
                                      l_class
                                      syst-subrc.
      if syst-subrc = 1.
        CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'      "begin 1141804
          EXPORTING
            iv_enqmode       = lv_enqmode
            iv_klart         = allkssk-klart.              "end 1141804
        message s513 with allkssk-klart allkssk-class.
        p_subrc = 4.
        exit.
      endif.
    endloop.
  endif.
  check p_subrc is initial.

*--------- check allkssk --------------------------------------------

  loop at allkssk where objek = space.
    delete allkssk.
  endloop.

  LOOP at KLASTAB.                                             "1901791
    READ TABLE allkssk WITH KEY                                "1901791
            OBJEK = KLASTAB-OBJEK                              "1901791
            CLINT = KLASTAB-CLINT                              "1901791
            OBTAB = KLASTAB-OBTAB.                             "1901791
    KLASTAB-INDEX_TAB = SY-TABIX.                              "1901791
    MODIFY KLASTAB.                                            "1901791
  ENDLOOP.                                                     "1901791

  if g_zuord = c_zuord_4.
    if multi_obj = kreuz.
      loop at allkssk where vbkz = c_delete.
        call function 'CUOB_DELETE_OBJECT_FROM_BUFFER'
          exporting
            object_id = allkssk-cuobj.
      endloop.
    endif.
  else.
    loop at allkssk where objek = rmclf-objek
                      and klart = rmclf-klart
                      and vbkz  = c_delete .
      read table delcl with key mafid = allkssk-mafid
                                klart = allkssk-klart
                                objek = allkssk-objek
                                clint = allkssk-clint.
      if not sy-subrc is initial.
        delcl-mafid = allkssk-mafid.
        delcl-klart = allkssk-klart.
        delcl-objek = allkssk-objek.
        delcl-clint = allkssk-clint.
        delcl-delkssk = kreuz.
        delcl-cuobj = allkssk-cuobj.
        append delcl.
      endif.
      if not allkssk-cuobj is initial.
        call function 'CUOB_DELETE_OBJECT_FROM_BUFFER'
          exporting
            object_id = allkssk-cuobj.
      endif.
    endloop.
    delete allausp where objek =  rmclf-objek
                     and klart =  rmclf-klart
                     and delkz <> space.
  endif.

* Check/update classification status:
* Necessary if: classifying dark, other allocation deleted,
* but not in CL24N.

  if g_zuord <> c_zuord_4.
    loop at allkssk where objek =  rmclf-objek
                      and klart =  rmclf-klart
                      and vbkz  <> c_delete.
      if allkssk-statu = cl_statusf.
        if allkssk-vbkz <> space  or
           allkssk-praus = konst_e.
          pm_objek   = allkssk-objek.
          pm_class   = allkssk-class.
          pm_status  = cl_statusf.
          mafid      = allkssk-mafid.
          klas_pruef = allkssk-praus.
          g_consistency_chk = kreuz.
          clear cl_status_neu.
          perform status_check using allkssk-klart.
          if not cl_status_neu is initial.
*           set status to 5
            IF allkssk-vbkz IS INITIAL.                  "begin 1141059
              allkssk-vbkz  = c_update.
            ENDIF.                                         "end 1141059
            allkssk-statu = cl_status_neu.
            modify allkssk.
          endif.
        endif.
      endif.
    endloop.
  endif.

*--------- check allausp ---------------------------------------

  l_lines = 0.
  if g_zuord = c_zuord_4.
    loop at allausp transporting no fields
                    where statu <> space.
      l_lines = 1.
      exit.
    endloop.
  else.
    loop at allausp transporting no fields
                    where objek =  rmclf-objek
                      and klart =  rmclf-klart
                      and statu <> space.
      l_lines = 1.
      exit.
    endloop.
  endif.

*--------- updates ---------------------------------------------

  if l_lines = 0.
*   allausp: no updates for DB
*   allkssk: only deletions for DB ?
    loop at allkssk transporting no fields
                    where vbkz <> space.
      l_lines = 1.
      exit.
    endloop.
    if l_lines = 0.
      read table delcl index 1.
      if sy-subrc = 0.
        perform cust_exit_post USING ' '.                     "  2241496
        perform delete_classification on commit.
        kssk_update = kreuz.
      endif.
    endif.
  endif.

  if l_lines <> 0.
    perform cust_exit_post USING ' '.                         "  2241496
    perform insert_classification on commit.
    kssk_update = kreuz.
  endif.

  if g_cl_ta <> space.
*   Commit only in CL* - transaction (transaction finished).
*   Master data transactions:
*     Commit themselves.
*     No refresh: CLFM_OBJETC_CL. can be called for several objects !
    commit work.
    message s506.
    refresh allausp.
    clear   allausp.
  endif.

  p_subrc = 0.
  refresh sel.
  clear   sel.
  CALL FUNCTION 'CLEN_DEQUEUE_ALL'                       "begin 1141804
    EXPORTING
      iv_only_reset = kreuz.                               "end 1141804

endform.                               " SAVE_ALL
