*------------------------------------------------------------------*
*        FORM CLASSIFY
*------------------------------------------------------------------*
*        Die Klassifizierung wird aufgerufen mit den Merkmalen     *
*        zur Klasse und den bereits vorhandenen AUSP-Sätzen.       *
*        Die neuen bzw. die geänderten Ausprägungen werden in die  *
*        Tabelle ALLAUSP geschrieben                               *
*------------------------------------------------------------------*
form classify.

  data:
        l_display(1)    type c,
        l_objnr         like rmclf-objek,
        l_subrc         like sy-subrc,
        l_tabix         like sy-tabix,
        l_val_class     like allkssk-class,
        l_val_klart     like allkssk-klart,
        l_val_obtab     like allkssk-obtab,
        l_val_objek     like allkssk-objek.

  data: begin of l_iausp occurs 0.
          include structure ausp.
  data: end   of l_iausp.

*------------------------------------------------------------------

*-- Berechtigungsprüfung für Merkmalsbild
  if not pm_class is initial.
    if g_zuord <> c_zuord_4.
*      perform auth_check_class_maint                          "1697240
*              using klastab-clint                             "1697240
*                    pm_class                                  "1697240
*                       tcd_stat                               "1697240
*                       'E'             " msg type             "1697240
*              changing l_subrc..                              "1697240
      clear l_subrc.                                           "1697240
    endif.
  endif.

  read table allkssk index g_allkssk_akt_index.
  if sy-subrc = 0.
*   allkssk entry selected in auswahl.
*   Values can be changed, so save them for CTMS-call.
    l_val_class  = allkssk-class.
    l_val_klart  = allkssk-klart.
    if allkssk-mafid = mafido.
      l_val_obtab  = allkssk-obtab.
    else.
      l_val_obtab = 'KLAH'.
    endif.
    l_val_objek  = allkssk-objek.
    g_val-objek  = allkssk-objek.
    g_val-class  = allkssk-class.
    g_val-status = allkssk-statu.
*   index of allocation evaluated in character subscreen
    g_klastab_val_idx = g_klastab_akt_index.
  endif.

  refresh merktab.
  clear   merktab.
  refresh sel.
  clear   sel.

  loop at viewk where klart = rmclf-klart
                  and class = pm_class
                  and udefm is initial.                     "45A
    if viewk-merkm is initial.
      exit.
    endif.
    if not viewk-posnr is initial.
      merktab-imerk = viewk-merkm.
      merktab-omerk = viewk-omerk.
      merktab-abtei = viewk-abtei.
      merktab-posnr = viewk-posnr.
      append merktab.
    endif.
  endloop.

  sort merktab by posnr.

  loop at allausp where objek = pm_objek
                    and mafid = mafid
                    and klart = rmclf-klart
                    and delkz = space.
*   not: deleted valuations
    check allausp-statu <> loeschen.

    read table delcl with key objek = pm_objek
                              merkm = allausp-atinn
                              klart = allausp-klart
                              mafid = allausp-mafid.
    if  sy-subrc is initial.
*     not: valuations of deleted allocations
      clear allausp.
      modify allausp.
      continue .
    endif.

    read table sel with key
                   atinn = allausp-atinn
                   atzhl = allausp-atzhl binary search.
    if sy-subrc <> 0.
      move-corresponding allausp to sel.
      if sel-statu <> hinzu.
        clear sel-statu.
      endif.
      append sel.
    endif.
  endloop.

  if syst-subrc = 0.
    delete allausp where atinn is initial.
  else.
    if classif_status <> ein.
      if pm_inobj is initial.
*-- L_OBJNR festlegen
        read table allkssk index g_allkssk_akt_index.
        if g_zuord = c_zuord_4.
          if allkssk-mafid = mafidk.
            l_objnr = allkssk-oclint.
          else.
            l_objnr = allkssk-objek.
          endif.
        else.
          if g_zuord = c_zuord_2.
            l_objnr = allkssk-oclint.
          else.
            l_objnr = allkssk-objek.
          endif.
        endif.
      else.
        l_objnr = pm_inobj.
      endif.
      call function 'CLFM_SELECT_AUSP'
        exporting
          mafid              = mafid
          classtype          = rmclf-klart
          object             = l_objnr
          key_date           = rmclf-datuv1
          with_change_number = change_subsc_act
          i_aennr            = rmclf-aennr1
          i_atzhl_same_ini   = kreuz
        tables
          exp_ausp           = l_iausp
        exceptions
          no_values          = 01.

      loop at l_iausp.
*-- Nachgelesen: Prüfen, ob da schon was in DELCL steht.
*-- Wenn ja: Zuordnung wurde bereits gelöscht.
        read table delcl with key objek = pm_objek
                                  merkm = l_iausp-atinn
                                  klart = l_iausp-klart
                                  mafid = l_iausp-mafid.
*-- Falls gefunden: Wert nicht übernehmen!
        check not sy-subrc is initial.

*-- Bei AUSP_NEW : Es könnten weitere Löschsätze notwendig sein
        if l_iausp-klart is initial.
          move-corresponding l_iausp to allausp.
          read table allausp with key
                                  objek = pm_objek
                                  atinn = l_iausp-atinn
                                  atzhl = l_iausp-atzhl
                                  klart = rmclf-klart
                                  mafid = mafid binary search.
          if not pm_inobj is initial.
            allausp-cuobj = l_iausp-objek.
          endif.
          allausp-statu = loeschen .
          allausp-aennr = rmclf-aennr.
          allausp-klart = rmclf-klart.
          allausp-objek = pm_objek.
          allausp-obtab = sobtab.
          if syst-subrc = 0.
            modify allausp index syst-tabix.
          else.
            insert allausp index syst-tabix.
          endif.
*-- nächster Eintrag
          continue.
        endif.

        read table sel with key
                            atinn = l_iausp-atinn
                            atzhl = l_iausp-atzhl binary search.
        move-corresponding l_iausp to sel.
        if syst-subrc ne 0.
          append sel.
        endif.
        read table allausp with key
                                objek = pm_objek
                                atinn = l_iausp-atinn
                                atzhl = l_iausp-atzhl
                                klart = rmclf-klart
                                mafid = mafid binary search.
        clear allausp.
        move-corresponding l_iausp to allausp.
        if not pm_inobj is initial.
          allausp-cuobj = l_iausp-objek.
        endif.
        allausp-objek = pm_objek.
        allausp-obtab = sobtab.
        if syst-subrc = 0.
          modify allausp index syst-tabix.
        else.
          insert allausp index syst-tabix.
        endif.
      endloop.
    endif.
  endif.

  loop at delcl where mafid = mafid
                  and klart = rmclf-klart
                  and objek = pm_objek.
    read table merktab with key delcl-merkm.
    if syst-subrc = 0.
      loop at allausp where objek = pm_objek
                        and atinn = delcl-merkm
                        and klart = delcl-klart
                        and mafid = mafid.
        allausp-delkz = space.
        modify allausp.
        read table sel with key
                            atinn = allausp-atinn
                            atzhl = allausp-atzhl binary search.
        move-corresponding allausp to sel.
        if syst-subrc > 0.
          insert sel index syst-tabix.
        endif.
      endloop.
*     modify allkssk regarding to delcl when saving is started !
    endif.
  endloop.

  if pm_depart ne kreuz.
    perform build_sicht tables merktab using syst-subrc.
    if g_zuord eq c_zuord_4.
      pm_depart = kreuz.
    endif.
  endif.

* setup multiple classes in buffer
* if not multi_class is initial.                             "897461
    perform ddb_multiple_classes
            using rmclf-klart
                  pm_class
                  pm_objek.
* endif.                                                     "897461

  if g_language is initial.
    g_language = sy-langu .
  endif.
  if classif_status   =  c_display  or
     g_display_values <> space.
*   display mode if change number necessary
    l_display = kreuz.
  endif.

  move-corresponding rmclf to rmcbc.                        "H314444
  call function tclfm-fbs_export
    exporting
      ermcbc = rmcbc
      table  = sobtab.

*--- char. value assignment --------------------------

  call function 'CTMS_CLASS_OBJECT_DDB'
      exporting
*         BATCH                    = ' '
          class                    = l_val_class
          classtype                = l_val_klart
          status                   = pm_status
*         language                 = sy-langu                  "2360038
          language                 = g_language                "2360038
          objectid                 = l_val_obtab
          object                   = l_val_objek
          display                  = l_display
          key_date                 = rmclf-datuv1
          set_values_from_db       = space
          application              = space
*          APPL_INSTANCE            =
*          PROFILE                  =
*          ADDITIONAL_OBJECTID      =
*          ADDITIONAL_OBJECT        =
*          READONLY                 = ' '
*          UDEF_RST                 =
          i_load_customizing       = kreuz
          i_tabs_active            = kreuz
          i_include_header         = pm_header              "H314444
*      IMPORTING
*          INSTANCE                 =
*          TABLES
*          BUFF_KSSK                =
*          BUFF_AUSP                =
      exceptions
          not_found                = 1
          no_allocation_to_classes = 2
          others                   = 3.

  l_subrc = sy-subrc .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  call function 'CTMS_DDB_OPEN'
    exporting
      i_set_default_values = kreuz
    tables
      imp_selection        = sel.

*-- Kennzeichen setzen, daß in CLOSE_PREV ... BUILD_ALLAUSP gerufen wird
  g_build_allausp = kreuz.
  clear g_no_valuation .
  clear g_display_values.

  if l_subrc <> 1.
*   ALLAUSP steht jetzt im Puffer: Setzen Flag in CLSE
    call function 'CLSE_CLFM_BUF_FLAGS'
      exporting
        i_ausp_flg = g_buffer_clse_active
        i_kssk_flg = kreuz
      exceptions
        others     = 0.
  endif.

  if NOT gv_fill_log_tables is initial.                  "begin 1022419
    clear gv_fill_log_tables.
*   1826745 could destroy previous state and cause an incorrect CANCEL
*                                        solved differently with 2355069
    gt_log_allausp[] = allausp[].
  endif.                                                   "end 1022419

endform.                               " classify
