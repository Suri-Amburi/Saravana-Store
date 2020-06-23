*§-----------------------------------------------------------------*
*        FORM AUSWAHL                                              *
*------------------------------------------------------------------*
*        Auswählen Zuordnung aus KLASTAB nach PICK-UP              *
*        Setzt Indices, pm_*
*------------------------------------------------------------------*
form auswahl
     using  zeile_leer     like g_flag
            value(p_index) like sy-tabix.

  data:
        lv_lock      type boole_d,                             "1442482
        dynp0002     like syst-dynnr value '0002',
        l_inob_init  like inob-cuobj,
        l_msgv1      like sy-msgv1,
        l_nochanges  like sy-batch,
        l_objek      like kssk-objek,
        l_used_aennr like rmclf-aennr1.

*---------------------------------------------------------------------
* 1. cl20/../cl23

  if g_zuord <> c_zuord_4.

    zeile_leer = kreuz.
    read table klastab index p_index .
    if syst-subrc = 0.
      g_klastab_akt_index = sy-tabix.
      read table allkssk index klastab-index_tab.
      if sy-subrc = 0.
        g_allkssk_akt_index = sy-tabix.
        clear zeile_leer.
      endif.
    endif.
    if zeile_leer <> space.
*     pm_clint1 muß gecleart sein, wenn EXIT prozessiert wird
      clear pm_clint1.
      exit.
    endif.

    pm_objek    = rmclf-objek.
    pm_class    = allkssk-class.
    g_sicht_akt = allkssk-sicht.
    pm_status   = allkssk-statu.
    rmclf-class = allkssk-class.
    rmclf-kltxt = allkssk-kschl.
    if g_zuord = c_zuord_2.
      pm_clint    = allkssk-oclint.
    else.
      pm_clint    = allkssk-clint.
      pm_inobj    = allkssk-cuobj.
      rmclf-stdcl = allkssk-stdcl.
    endif.

*   Sperre schon erfolgt, aber View-Tab noch nicht aufgebaut
    if klastab-lock is initial.        "View Tabelle gefüllt
      klastab-lock = kreuz.
      modify klastab index p_index.
      allkssk-lock = kreuz.
      modify allkssk index g_allkssk_akt_index.
    endif.
    perform build_viewtab using klastab-clint pm_class.
  endif.

*---------------------------------------------------------------------
* 2. cl24/25:
*    Screen Objekte einer Klasse
*    Objekt über Indextabelle holen

  if g_zuord = c_zuord_4 .
*   zuerst für dynpros *511, *512 ...
    clear pm_clint1.
    zeile_leer = kreuz.
    read table g_obj_indx_tab index p_index.
    if syst-subrc = 0.
      read table klastab index g_obj_indx_tab-index.
      if sy-subrc = 0.
        g_klastab_akt_index = sy-tabix.
        read table allkssk index klastab-index_tab .
        if sy-subrc = 0.
          g_allkssk_akt_index = sy-tabix.
          clear zeile_leer.
        endif.
      endif.
    endif.
    check zeile_leer = space.

    clear pm_inobj.
    mafid           = allkssk-mafid.
    rmclf-objek     = allkssk-objek.
    pm_objek        = allkssk-objek.
    pm_class        = allkssk-class.
    pm_status       = allkssk-statu.

    if mafid = mafido .
*     Objekte
      rmclf-class     = rmclf-clasn.
      rmclf-kltxt     = rmclf-ktext.
      rmclf-obtxt     = allkssk-kschl.
      objtype         = allkssk-obtab.

      if multi_obj = kreuz.
        pm_inobj = allkssk-cuobj.
        sobtab   = allkssk-obtab.
      endif.
      read table redun with key obtab = sobtab binary search.
      pm_header-dynnr = redun-dynnr4.

      call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
           exporting
                table          = sobtab
                rmclfstru      = rmclf
           importing
                rmclfstru      = rmclf
           tables
                lengthtab      = laengtab
           exceptions
                tclo_not_found = 1.
      if syst-subrc = 1.
        message e521 with sobtab.
      endif.
      refresh obj.
      obj-objek = rmclf-objek.
      append obj.

      if classif_status NE c_display.                    "begin 1442482
        lv_lock = kreuz.
      endif.                                               "end 1442482
*     Aufruf Funktionsbaustein OBJECT_CHECK_xxxx
*     xxxx = Stammdatentabelle
      call function 'CLOCH_OBJECT_CHECK'
           exporting
                i_obtab          = objtype
                called_from      = zwei
                language         = sy-langu
                lock             = lv_lock                     "1442482
                single           = kreuz
                date_of_change   = rmclf-datuv1
                i_auth_chk       = g_auth_obj_chk
           importing
                fault_text        = messagetext
                meins             = rmclf-meins
                message_type      = messagetype
                no_auth           = no_authority
                no_changes        = l_nochanges
*               distribution_lock =
           tables
                otab              = obj
           exceptions
                foreign_lock      = 1
                object_not_found  = 2
                system_failure    = 3
                others            = 4.
      case sy-subrc.
        when 1.
          if objtype = tabmara.
            l_msgv1 = sy-msgv1.
          else.
            l_msgv1 = sy-msgv2.
          endif.
          message e525 with l_msgv1.
        when 2.
          message e504.
        when 3.
          message e519.
      endcase.
      if not messagetype is initial.
        message id 'CL' type messagetype number '510'
                with messagetext.
      endif.
      if not no_authority is initial.
        message e534 with rmclf-objek.
      endif.

    else.
*     Klassen
      read table redun with key obtab = space binary search.
      pm_clint1   = allkssk-clint.
      rmclf-class = allkssk-objek.
      rmclf-kltxt = allkssk-kschl.
      pm_header-dynnr = dynp0497.
      if multi_obj = kreuz.
        sobtab = pobtab.
      endif.
    endif.

*   if g_obj_scr is initial.                                   "1772310
    if g_obj_scr is initial or SOKCODE = okloes.               "1772310
*-- ... nur für dynpro *511
      if redun-aediezuord = kreuz and classif_status <> c_display.
        if rmclf-aennr1 is initial and g_obj_indx_tab-showo <> kreuz.
          if mafid = mafido.
            save_objek = klastab-objek.
          else.
            save_objek = allkssk-oclint.
          endif.
          perform check_kssk_count using
                                   save_objek  rmclf-klart  mafid
                                   sobtab  l_inob_init  syst-subrc.
          if syst-subrc > 0.
            message w562.
            g_display_values = kreuz.
*           classif_status = c_display.              "1745182  "1772310
          endif.
        endif.
      endif.
      if rmclf-aennr1 <> space      and
         classif_status = c_change and
         g_effectivity_used is initial.
        if mafid = mafidk.                                     "v 919154
          l_objek = allkssk-oclint.
        elseif multi_obj = space.                              "^ 919154
          l_objek = pm_objek.
        else.
          l_objek = pm_inobj.
        endif.
        select aennr from kssk into l_used_aennr up to 1 rows
               where objek =  l_objek
                 and mafid =  mafid                            "  919154
                 and klart =  rmclf-klart
                 and datuv =  rmclf-datuv1
                 and aennr <> rmclf-aennr1.
        endselect.
        if sy-subrc > 0.
*         no entry in kssk with same date
          select aennr from ausp into l_used_aennr up to 1 rows
                 where objek =  l_objek
                   and mafid =  mafid                          "  919154
                   and klart =  rmclf-klart
                   and datuv =  rmclf-datuv1
                   and aennr <> rmclf-aennr1.
          endselect.
        endif.
        if sy-subrc = 0.
          message w182 with l_used_aennr.
          g_display_values = kreuz.
        endif.
      endif.

* Sperren Beziehung Klasse/Klasse
      check klastab-lock ne kreuz.
      klastab-lock = kreuz.
      modify klastab index g_klastab_akt_index.
      allkssk-lock = kreuz.
      modify allkssk index g_allkssk_akt_index.
    endif.
  endif.

*---------------------------------------------------------------------
* Nur Retail
  if g_zuord is initial and g_appl = konst_w.
    clear pm_clint1.
    zeile_leer = kreuz.
    read table klastab index p_index .
    if syst-subrc = 0.
      g_klastab_akt_index = sy-tabix.
      read table allkssk index klastab-index_tab.
      if sy-subrc = 0.
        g_allkssk_akt_index = sy-tabix.
        clear zeile_leer.
      endif.
    endif.
    check zeile_leer is initial.

    mafid           = allkssk-mafid.
    pm_objek        = allkssk-objek.
    rmclf-objek     = allkssk-objek.
    pm_class        = rmclf-clasn.
    pm_status       = allkssk-statu.
    pm_clint1       = allkssk-oclint.  " object clint !
    rmclf-class     = allkssk-class.
    rmclf-wghie1    = allkssk-objek.
    rmclf-ktext     = allkssk-kschl.
    pm_header-dynnr = dynp0002.
  endif.

endform.                               " auswahl
