*----------------------------------------------------------------------*
*       FORM MERGE_ALLKSSK_ALLAUSP
*----------------------------------------------------------------------*
*       Merge allocation and valuation tables from user exit (L_*)
*       with corresponding tables in standard program (G_*).
*----------------------------------------------------------------------*
form merge_allkssk_allausp tables g_allkssk structure rmclkssk
                                  l_allkssk structure rmclkssk
                                  g_allausp structure rmclausp
                                  l_allausp structure rmclausp .

  data: l_subrc      like sy-subrc,
        l_subrc_rd   like sy-subrc,
        l_tabix      like sy-tabix,
        l_datuv      like klah-vondt,
        l_text       like rmclf-ktext,
        l_inobj      like inob-cuobj,
        l_multi_obj  like tcla-multobj.
  DATA:                                                        "1167642
    lv_smsgv TYPE sy-msgv1.                                    "1167642

  data:   lt_cabn    like cabn occurs 0 with header line.
  ranges: r_cabn     for ksml-imerk.

*---------------------------------------------------------------------
* 0. sort to allow binary search

SORT l_allkssk BY objek clint klart mafid adzhl.               "1145462
SORT l_allausp BY objek atinn atzhl klart mafid.               "1145462

* KLASTAB keeps indices to ALLKSSK entries                     v 2485010
* -> sequence of entries must not be changed
* SORT g_allkssk BY objek clint klart mafid adzhl.    "2286724 ^ 2485010
SORT g_allausp BY objek atinn atzhl klart mafid.               "2286724

*---------------------------------------------------------------------
* 1. Abmischen L_ALLKSSK und G_ALLKSSK

  l_datuv = rmclf-datuv1.
  if l_datuv is initial.
    l_datuv = sy-datum.
  endif.

* remove entries that are removed in user exit (l_allkssk)
  loop at g_allkssk where vbkz <> space.
    read table l_allkssk with key
                         objek  = g_allkssk-objek
                         clint  = g_allkssk-clint
                         klart  = g_allkssk-klart
                         mafid  = g_allkssk-mafid
                         adzhl  = g_allkssk-adzhl
                         BINARY SEARCH.                        "1145462
    if sy-subrc > 0.
      delete g_allkssk.
      delete ghcli where klart = g_allkssk-klart            " 812983
                     and clas2 = g_allkssk-class
                     and objek = g_allkssk-objek.
    endif.
  endloop.

* transfer allocations added/changed in user exit (l_allkssk)
  loop at l_allkssk.
    read table iklart with key klart = l_allkssk-klart.
    if sy-subrc is initial.
      l_multi_obj = iklart-multobj.
    else.
      raise cust_exit_kssk1.
    endif.

    read table g_allkssk with key
                         objek  = l_allkssk-objek
                         clint  = l_allkssk-clint
                         klart  = l_allkssk-klart
                         mafid  = l_allkssk-mafid
                         adzhl  = l_allkssk-adzhl.
    l_tabix = sy-tabix.
    if sy-subrc = 0.
*     update old entry
      l_allkssk-updat = space.
      l_allkssk-class = g_allkssk-class.
      l_allkssk-sicht = g_allkssk-sicht.
      l_allkssk-praus = g_allkssk-praus.
      l_allkssk-vwstl = g_allkssk-vwstl.
      l_allkssk-cuobj = g_allkssk-cuobj.
      g_allkssk       = l_allkssk.
      modify g_allkssk index l_tabix.

*     GHCLI: table for multiple classification (->CTMS)
      if g_allkssk-vbkz = space.
*       deleted class assignment could be fetched back
        if not iklart-mfkls is initial.
          read table ghcli with key klart = g_allkssk-klart
                                    clas2 = g_allkssk-class
                                    objek = g_allkssk-objek
                                    binary search.
          if sy-subrc = 0.
            ghcli-delkz = space.
            modify ghcli index sy-tabix transporting delkz.
          endif.
        endif.

      elseif g_allkssk-vbkz = c_delete.
*       class assignment deleted
        if not iklart-mfkls is initial.
          read table ghcli with key klart = g_allkssk-klart
                                    clas2 = g_allkssk-class
                                    objek = g_allkssk-objek
                                    binary search.
          if sy-subrc = 0.
            ghcli-delkz = kreuz.
            modify ghcli index sy-tabix transporting delkz.
          else.
            clear ghcli.
            ghcli-mklas = kreuz.
            ghcli-klart = g_allkssk-klart.
            ghcli-clas2 = g_allkssk-class.
            ghcli-clin2 = g_allkssk-clint.
            ghcli-cltx2 = g_allkssk-kschl.
            ghcli-objek = g_allkssk-objek.
            ghcli-delkz = kreuz.
            append ghcli.
            sort ghcli by klart clas2 objek delkz.
          endif.
        endif.
        delete klastab where objek = g_allkssk-objek
                         and mafid = g_allkssk-mafid
                         and clint = g_allkssk-clint.
      endif.

    else.
*     insert new entry from user exit
      l_subrc_rd = sy-subrc.
      clear l_inobj.
      call function 'CLMA_CLASS_EXIST'
           exporting
                classtype             = l_allkssk-klart
                class                 = l_allkssk-class
                classify_activity     = tcd_stat
                classnumber           = l_allkssk-clint
                date                  = l_datuv
                language              = g_language
                mode                  = mode  " 'K'
                no_description        = space
           importing
                class_description     = l_text
                not_valid             = no_datum
                no_active_status      = no_status
                no_authority_classify = no_classify
                ret_code              = l_subrc
                xklah                 = klah
           exceptions
                no_valid_sign         = 20.
      if sy-subrc > 0 or
         l_subrc > 1.
*       something wrong with class
        raise class_not_valid.
      endif.
      CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'        "begin 1141804
        EXPORTING
          iv_enqmode           = 'S'
          iv_klart             = l_allkssk-klart
          IV_CLASS             = klah-class
          IV_MAFID             = mafido
          IV_OBJEK             = l_allkssk-objek
        EXCEPTIONS
          FOREIGN_LOCK         = 1
          SYSTEM_FAILURE       = 2.
      case sy-subrc.                                       "end 1141804
        WHEN 1.                                          "begin 1167642
          IF sy-msgv1 IS INITIAL.
*           "classification not possible at the moment"
            MESSAGE s517
                    RAISING foreign_lock.
          ELSE.
*           "class type & : class & locked by user &"
            lv_smsgv = sy-msgv1.
            MESSAGE s518
                    WITH l_allkssk-klart
                         klah-class
                         lv_smsgv
                    RAISING foreign_lock.
          ENDIF.
          EXIT.
        WHEN 2.
*         "locking errors"
*          MESSAGE e519.                                    "end 1167642
          MESSAGE e519 raising system_failure.             "Note 1521560
      endcase.

      if l_multi_obj = kreuz.
        all_multi_obj = kreuz.         " necessary only here
        if l_allkssk-mafid = mafido.
*         check existence of inob-cuobj
          call function 'CUOB_GET_NUMBER'
               exporting
                    class_type       = l_allkssk-klart
                    object_id        = l_allkssk-objek
                    table            = l_allkssk-obtab
               importing
                    object_number    = l_inobj
               exceptions
                    lock_problem     = 1
                    object_not_found = 2
                    others           = 3.
          if l_inobj is initial.
            call function 'CUOB_GET_NEW_NUMBER'
                 exporting
                      class_type    = l_allkssk-klart
                      object_id     = l_allkssk-objek
                      table         = l_allkssk-obtab
                      with_commit   = space
                 importing
                      object_number = l_inobj
                 exceptions
                      lock_problem  = 1.
          endif.
        endif.
      endif.

      g_allkssk       = l_allkssk.
      g_allkssk-updat = space.
      g_allkssk-class = klah-class.
      g_allkssk-kschl = l_text.
      g_allkssk-sicht = klah-sicht.
      g_allkssk-praus = klah-praus.
      g_allkssk-vwstl = klah-vwstl.
      if g_allkssk-zaehl is initial.
        g_allkssk-zaehl = c_zaehl_start.
      endif.
      if l_inobj is initial.
        clear g_allkssk-cuobj.
      else.
        g_allkssk-cuobj = l_inobj.
      endif.
      g_allkssk-vbkz = c_insert.
      append g_allkssk.
      l_tabix = sy-tabix.
      if g_allkssk-klart = rmclf-klart.
        move-corresponding g_allkssk to klastab.
        klastab-index_tab = l_tabix.
        append klastab.
      endif.
      if not iklart-mfkls is initial.
*       GHCLI: table for multiple classification
        clear ghcli.
        ghcli-mklas = kreuz.
        ghcli-klart = g_allkssk-klart.
        ghcli-clas2 = g_allkssk-class.
        ghcli-clin2 = g_allkssk-clint.
        ghcli-cltx2 = g_allkssk-kschl.
        ghcli-objek = g_allkssk-objek.
        append ghcli.
        sort ghcli by klart clas2 objek delkz.
      endif.
    endif.                             " read g_allkssk
  endloop.                             " l_allkssk

*---------------------------------------------------------------------
* 2. Abmischen L_ALLAUSP und G_ALLAUSP

  clear r_cabn.
  r_cabn-sign   = incl.
  r_cabn-option = equal.

* remove entries that are removed in user exit (l_allausp)
  loop at g_allausp where statu <> space.
    read table l_allausp with key
                         objek = g_allausp-objek
                         atinn = g_allausp-atinn
                         atzhl = g_allausp-atzhl
                         klart = g_allausp-klart
                         mafid = g_allausp-mafid
*                        statu = g_allausp-statu               "1504264
                         BINARY SEARCH.                        "1145462
    if sy-subrc > 0.
      delete g_allausp.
    endif.
  endloop.

* transfer valuations added/changed in user exit (l_allausp)
  loop at l_allausp.
    clear g_allausp.
    read table g_allausp with key
                         objek = l_allausp-objek
                         atinn = l_allausp-atinn
                         atzhl = l_allausp-atzhl
                         klart = l_allausp-klart
                         mafid = l_allausp-mafid
                         binary search.
    l_subrc_rd = sy-subrc.
    l_tabix    = sy-tabix.

*   check if status of next entry fits better                  v 1251764
    if L_SUBRC_RD is initial and
       G_ALLAUSP-STATU <> L_ALLAUSP-STATU.

      data WA_ALLAUSP like G_ALLAUSP.
      WA_ALLAUSP = G_ALLAUSP.

      L_TABIX = L_TABIX + 1.
      read table G_ALLAUSP index L_TABIX.
      if not SY-SUBRC is initial or
             SY-SUBRC is initial and
             ( G_ALLAUSP-OBJEK <> L_ALLAUSP-OBJEK or
               G_ALLAUSP-ATINN <> L_ALLAUSP-ATINN or
               G_ALLAUSP-ATZHL <> L_ALLAUSP-ATZHL or
               G_ALLAUSP-KLART <> L_ALLAUSP-KLART or
               G_ALLAUSP-MAFID <> L_ALLAUSP-MAFID or
               G_ALLAUSP-STATU <> L_ALLAUSP-STATU ).
*       no further entry or next entry doesn't fit better
*       -> reset to previously found entry
        G_ALLAUSP = WA_ALLAUSP.
        L_TABIX = L_TABIX - 1.
      endif.
    endif.                                                    "^ 1251764

    if l_allausp-statu = space and
       l_subrc_rd is initial and      " g_allausp entry exists   1679141
       g_allausp-statu = space.
*     nothing to transfer
      continue.
    endif.
    if l_allausp-atcod na '123456789'.
      raise cust_exit_ausp3.
    endif.

    if l_subrc_rd = 0 and                                      "1504264
      ( g_allausp-statu = space or                             "1504264
        g_allausp-statu = l_allausp-statu ).                   "1504264
*     update old entry
      l_allausp-updat = space.
      l_allausp-delkz = space.
      l_allausp-cuobj = g_allausp-cuobj.
      l_allausp-aennr = g_allausp-aennr.
      clear l_allausp-datuv.
      g_allausp       = l_allausp.
      modify g_allausp index l_tabix.

    else.
*     insert new entry from user exit
      clear l_inobj.
      read table iklart with key klart = l_allausp-klart.
      if sy-subrc is initial.
        l_multi_obj = iklart-multobj.
      else.
        raise cust_exit_kssk1.
      endif.
*     check characteristic
      refresh r_cabn.
      r_cabn-low = l_allausp-atinn.
      append r_cabn.
      call function 'CLSE_SELECT_CABN'
           exporting
                key_date       = l_datuv
           tables
                in_cabn        = r_cabn
                t_cabn         = lt_cabn
           exceptions
                no_entry_found = 1
                others         = 2.
      if sy-subrc > 0.
*       characteristic not defined
        raise cust_exit_ausp1.
      endif.
      if l_multi_obj = kreuz.
        if l_allausp-mafid = mafido.
          call function 'CUOB_GET_NUMBER'
               exporting
                    class_type       = l_allausp-klart
                    object_id        = l_allausp-objek
                    table            = l_allausp-obtab
               importing
                    object_number    = l_inobj
               exceptions
                    lock_problem     = 1
                    object_not_found = 2
                    others           = 3.
          check sy-subrc is initial.
        endif.
      endif.

      g_allausp       = l_allausp.
*     g_allausp-statu = hinzu.                             "1478258
      g_allausp-statu = l_allausp-statu.                   "1478258
      g_allausp-updat = space.
      g_allausp-delkz = space.
      if l_inobj is initial.
        clear g_allausp-cuobj.
      else.
        g_allausp-cuobj = l_inobj.
      endif.
      clear g_allausp-aennr.
      clear g_allausp-datuv.
      insert g_allausp index l_tabix.
    endif.                             " read g_allausp

  endloop.                             " l_allausp

endform.
