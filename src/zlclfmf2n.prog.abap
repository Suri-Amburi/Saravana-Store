*§-----------------------------------------------------------------*
*        FORM LESEN_KSSK                                           *
*------------------------------------------------------------------*
*        Lesen Zuordnungen zum Objekt (CL20/CL22)                  *
*        oder zur Klasse                                           *
*        (wird auch aus dem WWS-Baustein gerufen, also nicht       *
*        nur CL20/CL22 )                                           *
*------------------------------------------------------------------*
form lesen_kssk.

  data:
    l_aktiv(2)       type n,
    l_objnr          like kssk-objek,
    l_ikssk_v0       like kssk_v0 occurs 0 with header line,
    l_iswor          like swor occurs 0 with header line.
  DATA:                                                        "1167642
    lv_smsgv TYPE sy-msgv1.                                    "1167642

  refresh klastab.
  clear klastab.
  clear g_obj_not_dark.
  if mafid = mafido.
*   objects
    if multi_obj = space.
      l_objnr = rmclf-objek.
    else.
      call function 'CUOB_GET_NUMBER'
           exporting
                class_type       = rmclf-klart
                object_id        = rmclf-objek
                table            = sobtab
           importing
                object_number    = inobj
           exceptions
                lock_problem     = 01
                object_not_found = 02.
      if sy-subrc > 0.
        exit.
      endif.
      l_objnr = inobj.
    endif.
  else.
    l_objnr = pm_clint.
  endif.

*-- Lesen der Zuordnungen BOTTOM-UP
  call function 'CLSE_SELECT_KSSK'
       exporting
            mafid          = mafid
            klart          = rmclf-klart
            objek          = l_objnr
            view           = kreuz
            refresh        = kreuz
            key_date       = rmclf-datuv1
       tables
            exp_kssk       = l_ikssk_v0
       exceptions
            no_entry_found = 1.

  loop at l_ikssk_v0.
*--> Disabling Enqueue -> sjena <- 31.01.2020 21:52:34
***    if classif_status <> c_display.
***      CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'        "begin 1141804
***        EXPORTING
***          iv_enqmode           = 'S'
***          iv_klart             = rmclf-klart
***          IV_CLASS             = l_ikssk_v0-class
***          IV_MAFID             = mafid
***          IV_OBJEK             = rmclf-objek
***        EXCEPTIONS
***          FOREIGN_LOCK         = 1
***          SYSTEM_FAILURE       = 2.
***      case sy-subrc.                                       "end 1141804
****-- Es wird was gesperrt, Klassifizierung kann nicht vollst.erfolgen
***        WHEN 1.                                          "begin 1167642
***          IF sy-msgv1 IS INITIAL.
****           "classification not possible at the moment"
***            MESSAGE e517
***                    RAISING foreign_lock.
***          ELSE.
****           "class type & : class & locked by user &"
***            lv_smsgv = sy-msgv1.
***            MESSAGE e518
***                    WITH rmclf-klart
***                         l_ikssk_v0-class
***                         lv_smsgv
***                    RAISING foreign_lock.
***          ENDIF.                                           "end 1167642
***        when 2.
***          message e519 raising system_failure.
***      endcase.
***    endif.
    l_iswor-mandt = sy-mandt.
    l_iswor-clint = l_ikssk_v0-clint.
    l_iswor-spras = syst-langu.
    l_iswor-klpos = eins.
    append l_iswor.
  endloop.

  if syst-subrc = 0.
*-- Nachlesen Texte zu den Klassen
    call function 'CLSE_SELECT_SWOR'
         tables
              imp_exp_swor   = l_iswor
         exceptions
              no_entry_found = 04.
    sort l_iswor by clint.

    loop at l_ikssk_v0.
      clear allkssk.
      move-corresponding l_ikssk_v0 to allkssk.
      allkssk-objek = rmclf-objek.
      read table l_iswor with key mandt = syst-mandt
                                  clint = l_ikssk_v0-clint
                                  binary search.
      if sy-subrc = 0.
        allkssk-kschl = l_iswor-kschl.
      endif.
      if mafid = mafido.
        if not multi_obj is initial.
          allkssk-cuobj = l_objnr.
        endif.
      else.
        allkssk-oclint = pm_clint.
      endif.
      allkssk-obtab = sobtab.
      allkssk-vbkz  = space.
      append allkssk.
      if allkssk-stdcl = kreuz.
        standardklasse = 1.
        standardclass  = allkssk-class.
      endif.
      move-corresponding allkssk to klastab.
      klastab-index_tab = sy-tabix.
      append klastab.

* 772226
*     GHCLI: table for multiple classification
      read table ghcli with key klart = allkssk-klart
                                clas2 = allkssk-class
                                objek = allkssk-objek
                                binary search.
      if sy-subrc = 0.
        ghcli-delkz = space.
        modify ghcli index sy-tabix transporting delkz.
      else.
        clear ghcli.
        ghcli-mklas = kreuz.
        ghcli-klart = allkssk-klart.
        ghcli-clas2 = allkssk-class.
        ghcli-clin2 = allkssk-clint.
        ghcli-cltx2 = allkssk-kschl.
        ghcli-objek = allkssk-objek.
        append ghcli.
        sort ghcli by klart clas2 objek delkz.
      endif.
    endloop.                           " l_ikssk_v0

    describe table klastab lines syst-tfill.
    if syst-tfill = 0.
      g_obj_not_dark = kreuz.
    endif.
  endif.

  gt_log_allkssk[] = allkssk[].                                "1022419
  gt_log_ghcli[] = ghcli[].                                    "1022419

endform.
