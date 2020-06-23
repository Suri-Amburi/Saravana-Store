*§-----------------------------------------------------------------*
*  FORM BUILD_ALL_TABS                                             *
*------------------------------------------------------------------*
*  STATUS 1: called in clfm_object_classif.
*  STATUS 2: called in old_class_handling.
*
*  Adjust allkssk, klastab, viewk.
*  If entry in allkssk, add corresp. one to klastab.
*------------------------------------------------------------------*
form build_all_tabs using klasse      like klah-class
                          standardflg like space
                          text        like rmclf-ktext.

  data: l_datum  like rmclf-datuv1,
        l_text   like rmclf-ktext,
        l_subrc  like sy-subrc,
        l_tabix  like sy-tabix.
  DATA:                                                        "1167642
    lv_smsgv TYPE sy-msgv1.                                    "1167642

  clear klah-clint.
  clear no_datum.
  clear no_status.
  clear no_classify.
  if rmclf-datuv1 is initial.
    l_datum = syst-datum.
  else.
    l_datum = rmclf-datuv1.
  endif.

  call function 'CLMA_CLASS_EXIST'
       exporting
            classtype             = rmclf-klart
            class                 = klasse
            classify_activity     = tcd_stat
            classnumber           = klah-clint
            language              = sy-langu
            description_only      = space
            mode                  = mode
            date                  = l_datum
       importing
            class_description     = l_text
            not_valid             = no_datum
            no_active_status      = no_status
            no_authority_classify = no_classify
            ret_code              = l_subrc
            xklah                 = klah
       exceptions
            no_valid_sign         = 20
            others                = 21.
  if l_subrc = 2.
*   Klasse nicht vorhanden
    message e503 with rmclf-klart klasse
            raising class_not_found.
  endif.
  if syst-subrc = 20.
    raise class_not_valid.             "keine gültige Zeichen
  endif.
  if no_classify = kreuz.
    message e532 with klasse
    raising class_not_valid.           "keine Berechtigung zum
                                       "Klassifizieren
  endif.
  if no_status  = kreuz.
    message e531 with rmclf-klart klasse
    raising class_not_valid.           "Klasse hat keinen gültigen
                                       "Status
  endif.
  if no_datum = kreuz.
    message e530 with rmclf-klart klasse
    raising class_not_valid.           "Klasse nicht gültig
  endif.

*----------------------------------------------------------------------
* class 'klasse' ok

    if classif_status <> c_display.
*     lock relation objekt/class
      CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'        "begin 1141804
        EXPORTING
          iv_enqmode           = 'S'
          iv_klart             = rmclf-klart
          IV_CLASS             = klah-class
          IV_MAFID             = mafido
          IV_OBJEK             = rmclf-objek
        EXCEPTIONS
          FOREIGN_LOCK         = 1
          SYSTEM_FAILURE       = 2.                        "end 1141804
      case sy-subrc.
        WHEN 1.                                          "begin 1167642
          IF sy-msgv1 IS INITIAL.
*           "classification not possible at the moment"
            MESSAGE e517
                    RAISING foreign_lock.
          ELSE.
*           "class type & : class & locked by user &"
            lv_smsgv = sy-msgv1.
            MESSAGE e518
                    WITH rmclf-klart
                         klah-class
                         lv_smsgv
                    RAISING foreign_lock.
          ENDIF.
        WHEN 2.
*         "locking errors"
          MESSAGE e519
                  RAISING system_failure.                  "end 1167642
      endcase.
    endif.

    text = l_text.
    gt_log_allkssk[] = allkssk[].                              "1022419
    read table allkssk with key
                            objek = rmclf-objek
                            clint = klah-clint
                            klart = rmclf-klart
                            mafid = mafido .
    l_tabix = sy-tabix.
    if sy-subrc = 0.
*--   add corresponding entry to klastab
      inobj = allkssk-cuobj.
      read table klastab with key
                              objek = rmclf-objek
                              clint = klah-clint.
      if sy-subrc <> 0.
        move-corresponding allkssk to klastab.
        klastab-index_tab = l_tabix.
        append klastab.
      endif.
      read table viewk with key
                            klart = rmclf-klart
                            class = klasse binary search.
      if sy-subrc > 0.
        perform build_viewtab using allkssk-clint klasse.
      endif.

    else.
*--   add entries to tables allkssk, klastab

      if multi_obj = kreuz.
        if inobj is initial.
*         test-read:  entry in INOB ?
          call function 'CUOB_GET_NUMBER'
               exporting
                    class_type       = rmclf-klart
                    object_id        = rmclf-objek
                    table            = sobtab
               importing
                    object_number    = inobj
               exceptions
                    lock_problem     = 1
                    object_not_found = 2
                    others           = 3.
          if inobj is initial.
            call function 'CUOB_GET_NEW_NUMBER'
                 exporting
                      class_type    = rmclf-klart
                      object_id     = rmclf-objek
                      table         = sobtab
                      with_commit   = ' '
                 importing
                      object_number = inobj
                 exceptions
                      lock_problem  = 01.
          endif.
        endif.
      endif.

      clear allkssk.
      allkssk-objek  = rmclf-objek.
      allkssk-clint  = klah-clint.
      allkssk-klart  = rmclf-klart.
      allkssk-mafid  = mafido.
      allkssk-zaehl  = eins.
      allkssk-stdcl  = standardflg.
      allkssk-statu  = cl_statusf.     " 1 = free
      allkssk-class  = klasse.
      allkssk-kschl  = l_text.
      allkssk-statu  = cl_statusf.
      allkssk-sicht  = klah-sicht.
      allkssk-lock   = kreuz.
      allkssk-praus  = klah-praus.
      allkssk-obtab  = sobtab.
      if not inobj is initial.
        allkssk-cuobj = inobj.
      endif.
      allkssk-vbkz   = c_insert.
      append allkssk .

      describe table allkssk lines l_tabix.
      clear klastab.
      move-corresponding allkssk to klastab.
      klastab-index_tab = l_tabix.
      append klastab.

      perform build_viewtab using klastab-clint klasse.
    endif.                             " sy-subrc
    rmclf-paganz = 1.

endform.                               " build_all_tabs
