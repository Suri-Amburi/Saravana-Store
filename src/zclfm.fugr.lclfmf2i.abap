*------------------------------------------------------------------*
*        FORM KLASSIFIZIEREN                                       *
*------------------------------------------------------------------*
*        Die Klassifizierung wird aufgerufen mit den Merkmalen     *
*        zur Klasse und den bereits vorhandenen AUSP-Sätzen.       *
*        Die neuen bzw. die geänderten Ausprägungen werden in die  *
*        Tabelle ALLAUSP geschrieben                               *
*------------------------------------------------------------------*
form klassifizieren.
*-- Modus für Authority-Check
  data: l_char(1),
        l_mode     like sy-batch   value 'K' ,
        l_subrc    like sy-subrc,
        l_tabix    like sy-tabix,
        l_tabix1   like sy-tabix,
        l_view     like rmclf-abtei,
*       button '<-' in valuation screen
        l_button_back   like sy-batch.


  data:
        l_obj_not_class type c,
        l_pm_mode(10)   type c,
        l_tcdcl24       type c,
        l_pm_output     type c,
        l_pm_title(3)   type c          value 'CLA',
        l_pm_statu(4)   type c          value 'OBJD',
        l_pm_obl(1)     type c          value 'X',
        l_pm_ewert(1)   type c          value 'X',
        l_obj_text      like rmclf-obtxt,
        l_objnr         like rmclf-objek,
        l_r_return      like syst-ucomm,
        l_new_status    like kssk-statu.

  data: begin of l_como.
          include structure ctms_01.
  data: end   of l_como.

  data: begin of l_iausp occurs 0.
          include structure ausp.
  data: end   of l_iausp.

  data: begin of l_mksel occurs 0,
          vatere      like      klah-class,    "Vater
          sohne       like      klah-class.    "Sohn
          include structure comw.
  data: end   of l_mksel.

  data: begin of l_ghclx occurs 0.
          include structure ghcl.
  data: end of l_ghclx.

  data: begin of l_ksskk,
          objek like kssk-objek,
          mafid like kssk-mafid,
          klart like kssk-klart,
          clint like kssk-clint.
  data: end   of l_ksskk.

*-- Berechtigungsprüfung für Merkmalsbild
  if not pm_class is initial.
*-- Klasse ermitteln
    clear iklah. refresh iklah.
    read table klastab with key pm_class.
    if sy-subrc is initial.
      move klastab-clint to iklah-clint.
      append iklah.
      call function 'CLSE_SELECT_KLAH'
           tables
                imp_exp_klah   = iklah
           exceptions
                no_entry_found = 1
                others         = 2.
*-- Tabelle auswerten
      if sy-subrc is initial.
        read table iklah index 1.
        check sy-subrc is initial.
*-- KLAH ist ermittelt: Nun AUTHORITY-Check
        call function 'CLMA_AUTHORITY_CHK'
             exporting
                  i_mode       = l_mode
                  i_bgrkl      = iklah-bgrkl
                  i_cl_act     = tcd_stat
             exceptions
                  no_authority = 1
                  others       = 2.
        if not sy-subrc is initial.
          message e532 with iklah-class.
        endif.

      endif.
    endif.
  endif.


  refresh merktab.
  clear merktab.
  refresh merkmtab.
  refresh sel.
  clear sel.
  merkmtab-sign   = incl.
  merkmtab-option = equal.
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
    merkmtab-low = viewk-merkm.
    append merkmtab.
  endloop.

  sort merktab by posnr.

  loop at allausp where objek = pm_objek
                    and mafid = mafid
                    and klart = rmclf-klart
                    and delkz = space.
    check allausp-statu ne loeschen.
*-- Prüfen, ob da schon was in DELCL steht. Wenn ja:
*-- Zuordnung wurde bereits gelöscht.
    read table delcl with key objek = pm_objek
                              merkm = allausp-atinn
                              klart = allausp-klart
                              mafid = allausp-mafid.
*-- Falls gefunden: Wert nicht übernehmen!
    if  sy-subrc is initial.
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
        if g_appl = konst_w.
*         Retail: pm_clint1, mafid=k vorher gesetzt.
          read table allkssk with key oclint = pm_clint1.
          l_objnr = pm_clint1.
        else.
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
*-- Nachgelesen: Prüfen, ob da schon was in DELCL steht. Wenn ja:
*-- Zuordnung wurde bereits gelöscht.
*>>> Ablösen durch LOOP über ALLKSSK mit VBKZ = D
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

*>>> LOOP über ALLKSSK mit VBKZ = D
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
      delete delcl.
      l_ksskk-objek = pm_objek.
      l_ksskk-clint = delcl-clint.
      l_ksskk-klart = delcl-klart.
      l_ksskk-mafid = mafid.
      on change of l_ksskk.
        read table allkssk with key
                                objek = pm_objek
                                clint = delcl-clint
                                klart = delcl-klart
                                mafid = mafid.
*+                              mafid = mafid binary search.
        allkssk-database = kreuz.
        modify allkssk index syst-tabix.
      endon.
    endif.
  endloop.
  move-corresponding rmclf to rmcbc.
  call function tclfm-fbs_export
       exporting
         ermcbc = rmcbc
         table  = sobtab.

  if pm_depart ne kreuz.
    perform build_sicht tables merktab using syst-subrc.
    if g_zuord eq c_zuord_4.
      pm_depart = kreuz.
    endif.
  endif.
  l_como-klart = rmclf-klart.
  l_como-class = pm_class.
  l_como-objek = pm_objek.
  l_como-mafid = mafid.
  l_como-objid = sobtab.
  if pm_inobj is initial.
    clear l_como-cuobj.
  else.
    l_como-cuobj = pm_inobj.
  endif.
  clear l_r_return.
  if mafid = mafido.
    l_obj_not_class = kreuz.
    l_obj_text      = rmclf-obtxt.
  else.
    clear l_obj_not_class.
    if g_zuord eq c_zuord_2.
      l_obj_text      = rmclf-ktext.
    else.
      l_obj_text      = rmclf-kltxt.
    endif.
  endif.
  if classif_status = drei.
    l_pm_output = kreuz.
  else.
    clear l_pm_output.
  endif.
  if g_zuord eq c_zuord_4 and tcd_stat eq kreuz.
    l_tcdcl24 = kreuz.
    if g_obj_indx_tab-showo = kreuz.
      l_pm_output = kreuz.
    endif.
*-- Zusätzlich: Wenn G_DISPLAY_VALUES sitzt (wg.Änderungsnummer)
    if l_pm_output is initial and not
       g_display_values is initial.
      l_pm_output = kreuz.
    endif.
  endif.
  if g_cl_ta eq kreuz or g_appl eq konst_w.
    nof8  = kreuz.
*-- Nicht bei Anzeigen
    if classif_status eq 3 or
       classif_status eq 4.
      nof11 = kreuz.
    endif.
  endif.
  if not multi_class is initial.
    loop at ghcli where klart =  rmclf-klart
                    and clas2 ne pm_class
                    and objek =  pm_objek
                    and delkz =  space .
      l_tabix = sy-tabix .
*-- Abgleich mit GHCLI-Löschsätzen
      read table ghcli with key klart = rmclf-klart
                                clas2 = ghcli-clas2
                                objek = pm_objek
                                delkz = kreuz  binary search.
      if sy-subrc is initial.
*-- Aus beiden wieder löschen
        delete ghcli index sy-tabix.
        delete ghcli index l_tabix.
      else.
        move-corresponding ghcli to l_ghclx.
        append l_ghclx.
      endif.
    endloop.
    describe table l_ghclx lines l_tabix.
    if l_tabix gt 0 .

      call function 'CLHI_DDB_SET_MULTIPLE_CLASSES'
           tables
                new_multiple_classes = l_ghclx
           exceptions
                others               = 1.
    endif.
    refresh l_ghclx.
    loop at ghcli where klart =  rmclf-klart
                    and clas2 ne pm_class
                    and objek =  pm_objek
                    and delkz =  kreuz .
      move-corresponding ghcli to l_ghclx.
      append l_ghclx.
    endloop.
    if sy-subrc is initial.

      call function 'CLHI_DDB_DEL_MULTIPLE_CLASSES'
           tables
                del_multiple_classes = l_ghclx
           exceptions
                others               = 1.
    endif.
  endif.

*-- Ggf. Sicht vorbelegen
  if g_sicht_akt is initial.
*-- Parameter VIEW lesen und in RMCLF-ABTEI übernehmen
    get parameter id c_param_view field g_sicht_akt.
  endif.
*-- Sichtenauswahl
  l_view = g_sicht_akt.
  if not department-sicht is initial.
    if l_view is initial.
      l_view = department-sicht.
    else.
*-- Schnittmenge bilden
      describe field department-sicht length l_tabix in character mode .
      clear l_tabix1.
      while l_tabix1 lt l_tabix.
        l_char = l_view+l_tabix1(1) .
        if not department-sicht  cs l_char .
          l_view+l_tabix1(1) = space.
        endif.
        l_tabix1 = l_tabix1 + 1.
      endwhile.
      condense l_view no-gaps.
    endif.
  endif.

  if g_language is initial.
    g_language = sy-langu .
  endif.
  if nof8 is initial.
    l_button_back = kreuz.
  endif.

  if pm_header-dynnr is initial or
   ( pm_header-dynnr le 1 and g_appl ne konst_w  ).
    if sy-binpt is initial.
      message w120 with l_como-objid.
      clear okcode.
      exit.
    endif.
  endif.
  call function 'CTMS_ENTER_VALUES'
       exporting
            ident                = pm_ident
            object               = l_como
            object_text          = l_obj_text
            object_not_class     = l_obj_not_class
            language             = g_language
            language_by_dialog   = by_dialog
            include_header       = pm_header
            mode                 = l_pm_mode
            obligatory           = l_pm_obl
            single_value         = l_pm_ewert
            titlebar             = l_pm_title
            pf_status            = l_pm_statu
            no_changes           = l_pm_output
            status               = pm_status
            called_from_cl24     = l_tcdcl24
            no_f8                = nof8
            one_node_back        = l_button_back
            no_f11               = nof11
            no_display           = nodisplay
            batch                = pm_batch
            key_date             = rmclf-datuv1
            change_number        = rmclf-aennr1
            hierarchy_allowed    = clhier
            multiple_allowed     = multi_class
            view                 = l_view
       importing
            return               = l_r_return
            new_language         = g_language
            new_status           = l_new_status
       tables
            selection            = sel
            mtable               = merktab
            passing_value        = l_mksel
*+          new_multiple_classes = l_ghclx
       exceptions
            no_characteristics   = 1.
  l_subrc = sy-subrc .
*-- Aktuelle Parameter (wie Sprachenabh. Bezeichnungen) übernehmen
  call function tclfm-fbs_import
       importing
            irmcbc = rmcbc.
  move-corresponding rmcbc to rmclf.

*-- zunächst initialisieren "g_no_valuation"
  clear g_no_valuation .
  clear g_display_values.
  if l_subrc = 1.
*-- ... dann setzen, wenn es keine Merkmale zu bewerten gab
    g_no_valuation = kreuz .
*-- ... Abfrage auf I_ASSGNMNT_SCREEN
    if not g_assgnmnt_screen is initial and
       not suppressd is initial.
      clear suppressd.
    endif.
    if not suppressd is initial.
      if classif_status ne drei.
        okcode = oksave.
        if suppressd = kreuz.
          leave screen.
        else.
          sokcode = oksave.
          exit.
        endif.
      else.
        if g_cl_ta eq kreuz.
          clear suppressd.
          exit.
        else.
          okcode = okende.
          leave screen.
        endif.
      endif.
    endif.
    if g_appl ne konst_w.
*-- Keine Meldung ausgeben, da nur Zuordnung gewollt
      message s511 with rmclf-klart pm_class.
      leave screen.                    "eingefügt Kabuth TEST
    endif.
  else.
*-- ALLAUSP steht jetzt im Puffer: Setzen Flag in CLSE
    call function 'CLSE_CLFM_BUF_FLAGS'
         exporting
              i_ausp_flg = g_buffer_clse_active
         exceptions
              others     = 0.
  endif.
* Der Status hat sich geändert
  if not l_new_status is initial.
    pm_status = l_new_status.
    read table allkssk index klastab-index_tab .
    check syst-subrc = 0.
    if allkssk-vbkz ne c_insert.
      allkssk-vbkz = c_update.
    endif.

    allkssk-statu = l_new_status.
    modify allkssk index syst-tabix.
  endif.

  if classif_status = drei.            "Transaktionsstatus = 3
    case l_r_return.
      when 'BACK'.                                          "F3
        sokcode = okende.
      when 'EOT'.                                           "F12
        sokcode = okabbr.
        if nof8 is initial.            "Anwendung sieht Klassifiz.
                                       "nicht als Hierarchie
          set screen dy000.            "Beenden Transaktion
          leave screen.
        endif.
      when 'ENDE'.                                          "F15
        sokcode = okleav.
        set screen dy000.              "Beenden Transaktion
        leave screen.
      when 'GOON'.
        sokcode = okweit.                                   "F8
        set screen dy000.              "Beenden Transaktion
        leave screen.
      when 'ONEB'.
        sokcode = okvobi.              "Ctrl-F8
        set screen dy000.              "Beenden Transaktion
        leave screen.                  "zu vorh. Bild im Mat.stamm
      when others.
        sokcode = okweit.
    endcase.
    if suppressd = kreuz.              "läuft im dunkeln
      set screen dy000.                "verlasse Klassifizierung
      leave screen.
    endif.
  endif.
  check classif_status ne drei.        "3 = reine Anzeige
  case l_r_return.
    when 'BACK'.                                            "F3
      sokcode  = okende.
    when 'EOT'.                                             "F12
      sokcode  = okabbr.
      if nof8 is initial.
        okcode   = okweit.
      endif.
    when 'ENDE'.                                            "F15
      sokcode  = okleav.
      okcode   = okweit.
    when 'GOON'.                                            "F8
      sokcode  = okweit.
      okcode   = okweit.
    when 'ONEB'.
      sokcode = okvobi.                "Beenden Transaktion
      set screen dy000.                "zu vorh. Bild im Mat.stamm
    when 'SAVE'.                                            "F11
      sokcode = oksave.
      okcode  = oksave.
  endcase.
  if not suppressd is initial.
    back_ok = sokcode.
    okcode  = oksave.
    sokcode = oksave.
  endif.

  perform build_allausp.
*-- Änderungsdienst: Wechsel Gültigkeit ggf. ausschließen
  if g_no_validity_chg is initial.
    g_no_validity_chg = kreuz.
    read table ex_pfstatus with key func = okaedi.
    if not sy-subrc is initial.
      ex_pfstatus-func = okaedi.
      append ex_pfstatus.
    endif.
    read table ex_pfstatus1 with key func = okaedi.
    if not sy-subrc is initial.
      ex_pfstatus1-func = okaedi.
      append ex_pfstatus1.
    endif.
  endif.


endform.
