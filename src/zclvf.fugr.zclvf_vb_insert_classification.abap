function ZCLVF_VB_INSERT_CLASSIFICATION.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CALLED_FROM_CL) LIKE  TCLA-TRACL DEFAULT SPACE
*"     VALUE(CALLED_FROM_CU) LIKE  SY-BATCH DEFAULT SPACE
*"     VALUE(OBJECT) LIKE  KSSK-OBJEK DEFAULT SPACE
*"     VALUE(TABLE) LIKE  TCLT-OBTAB DEFAULT SPACE
*"     VALUE(CHANGE_SERVICE_NUMBER) LIKE  RMCLF-AENNR1 OPTIONAL
*"     VALUE(DATE_OF_CHANGE) LIKE  RMCLF-DATUV1 OPTIONAL
*"     VALUE(INSERT_MOD) LIKE  RMCLF-KREUZ DEFAULT SPACE
*"     VALUE(AFTER_OBJ_CREATE) LIKE  RMCLF-KREUZ DEFAULT SPACE
*"  TABLES
*"      AUSPTAB STRUCTURE  RMCLAUSP
*"      KSSKTAB STRUCTURE  RMCLKSSK
*"      I_MDCP STRUCTURE  CLMDCP OPTIONAL
*"--------------------------------------------------------------------
*
*
  data:
      exitflg        type c,
      laenge         type i,
      offset         type i,
      dispo_stufe    type c,
*-- l_adzhl_new: neuer adzhl-Wert für AUSP mit neuer Logik
      l_adzhl_new    like ausp-adzhl,
*-- l_atzhl: Gruppenwechsel in LOOP
      l_atzhl        like ausp-atzhl,
*-- l_klart_100 : Klassenart 100 kommt vor in AUSP
      l_klart_100    like rmclf-kreuz,
*-- l_*_tmp: object changed within loops,
*            another class type, mafid, object, characteristic
      l_klart_tmp    like kssk-klart,
      l_mafid_tmp    like kssk-mafid,
      l_object_tmp   like kssk-objek,
      l_atinn_tmp    like ausp-atinn,
      l_obtab        like tcla-obtab,
*-- L_SAME_AENNR ist ein Flag, um zu merken, daß zur selben ÄNNR einer
*-- Bewertung diese nochmals geändert wurde
      l_same_aennr   like rmclf-kreuz,
      l_subrc        like sy-subrc,
      l_tabix        like sy-tabix,
      l_atinn_sav    like ausp-atinn,
*-- l_delete_ausp  für Löschsatzbehandlung beim Hinzufügen
      l_delete_ausp  like ausp,
      sobjekt        like kssk-objek.

  DATA: lv_no_deletion_entry TYPE xfeld.                        "1571568

* table contains all new objects that are saved in gen tables
  data: lt_gentab like clobjgen occurs 0 with header line.
*
*-- Liste nicht genutzter ATZHLs je ATINN
  data: begin of l_free_atzhl_tab occurs 5,
          atinn like ausp-atinn,
          atzhl like ausp-atzhl,
          adzhl like ausp-adzhl,
        end of l_free_atzhl_tab .

* Feldsymbole
  field-symbols:
      <real>,
      <lf_ausp> like iausp.

***********************************************************************

  clear hkssk.
  refresh hkssk.
  clear vkssk.
  refresh vkssk.
  clear v1kssk.
  refresh v1kssk.
  refresh iklah.
  clear hausp.
  refresh hausp.
  clear vausp.
  refresh vausp.
  clear lausp.
  refresh lausp.
  clear abkssk.
  refresh abkssk.
  clear abausp.
  refresh abausp.
  xaennr = change_service_number.
  xdatuv = date_of_change.
  if xaennr is initial.
    clear xdatuv.
  endif.

  if not object is initial.            "Ansprung Klassifizierung
    if not object co space.            "aus Objektpflege mit interner
    endif.                             "Nummernvergabe
    offset = syst-fdpos.               "erste Stelle in OBJECT =/ SPACE
    if object cp '*# '.                "Nächste Stelle = SPACE
    endif.
    laenge = syst-fdpos - offset.      "Länge des Objektbestandteils
    assign object+offset(laenge) to <real>. "die intern Vergeben
  endif.

*--------------------------------------------------------------------
* 1. Hinzufügen / Verändern KSSK-Sätze

  loop at kssktab where vbkz <> space.

    rmclkssk = kssktab.
    clear hkssk.
    clear vkssk.
    clear ksskflag.

    if rmclkssk-klart <> l_klart_tmp.
*     another class type
      clear l_object_tmp.
      clear g_effectivity_used.
      clear g_effectivity_date.
      if not xaennr is initial.
        call function 'CLEF_EFFECTIVITY_USED'
          exporting
            i_aennr          = xaennr
            i_classtype      = rmclkssk-klart
          importing
            e_effe_datum     = g_effectivity_date
            e_effe_aennr     = g_effectivity_used
          exceptions
            klart_not_active = 1
            others           = 2.
      endif.
    endif.
    if rmclkssk-mafid <> l_mafid_tmp.
      clear l_object_tmp.
    endif.
    if not object is initial.
      write <real> to rmclkssk-objek+offset(laenge).
    endif.

*   get object key, read cust. class type
    if rmclkssk-mafid = mafidk.
      sobjekt        = rmclkssk-objek.
      rmclkssk-objek = rmclkssk-oclint.
      clear l_obtab.
    else.
      if rmclkssk-cuobj is initial.
        sobjekt = rmclkssk-objek.
      else.
        sobjekt = rmclkssk-cuobj.
      endif.
      l_obtab = rmclkssk-obtab.
    endif.
    read table redun with key klart = rmclkssk-klart
                              obtab = l_obtab
                              binary search.
    if sy-subrc <> 0.
      perform fill_redun using rmclkssk-klart l_obtab.
    endif.

    case rmclkssk-vbkz.
      when space.
      when 'U'.
        ksskflag = veraend.            "Veraendern KSSK
        if not g_effectivity_used is initial.
          perform pflegen_claennr using rmclkssk-klart
                                        rmclkssk-clint.
        endif.
      when 'I'.
        ksskflag = hinzu.              "neuer Satz
        if not g_effectivity_used is initial.
          perform pflegen_claennr using rmclkssk-klart
                                        rmclkssk-clint.
        endif.
    endcase.

    case ksskflag.
      when veraend.                    "alter KSSK-Satz verändern
        move-corresponding rmclkssk to vkssk.
        vkssk-mandt = sy-mandt.
        if not rmclkssk-cuobj is initial.
          vkssk-objek = rmclkssk-cuobj.
        endif.
        if xaennr is initial.          "ohne Änderungsnr
          append vkssk.
        else.
          if redun-aediezuord is initial.
            append vkssk.
          else.
*           change management
            if vkssk-aennr = xaennr.
*             same change number: just update
              append vkssk.
            else.
              v1kssk = vkssk.
              v1kssk-aennr = xaennr.
              if g_effectivity_used is initial.
                v1kssk-datuv = xdatuv.
              else.
                v1kssk-datuv = g_effectivity_date.
              endif.
              append v1kssk.           "Änderung an STDCL STATU
            endif.
          endif.
        endif.
* Änderungsbelege
        if redun-aeblgzuord = kreuz.
          move-corresponding vkssk to abkssk.
          abkssk-class = rmclkssk-class.
          abkssk-kz = veraend.
          append abkssk.
*-- Änderung wg. Performance
*+        select * from kssk up to 1 rows
*+          where objek = vkssk-objek
*+            and mafid = vkssk-mafid
*+            and klart = vkssk-klart
*+            and clint = vkssk-clint.
          select * from kssk
            where objek = vkssk-objek
              and mafid = vkssk-mafid
              and klart = vkssk-klart.
            check kssk-clint = vkssk-clint.
            move-corresponding kssk to yabkssk.
            yabkssk-class = rmclkssk-class.
            append yabkssk.
            exit.
          endselect.
        endif.

      when hinzu.                      "Hinzufügen KSSK
        move-corresponding rmclkssk to hkssk.
        hkssk-mandt = sy-mandt.
        if not rmclkssk-cuobj is initial.
          hkssk-objek = rmclkssk-cuobj.
        endif.
        if g_effectivity_used is initial.
          hkssk-datuv = xdatuv.
        else.
          hkssk-datuv = g_effectivity_date.
        endif.
        if rmclkssk-vwstl = kreuz.
*         class in BOM possible
          if object is initial.
            if table = tabmara or rmclkssk-obtab = tabmara
            or table = tabmarc or rmclkssk-obtab = tabmarc.
              dispo_stufe = kreuz.
              perform rek_stueckliste using kssktab-objek syst-subrc.
              if syst-subrc ne 0.      "Rekursivität erkannt
                hkssk-rekri = kreuz.   "setze Kennzeichen in KSSK
              endif.
            endif.
          endif.
        endif.
        if redun-aeblgzuord = kreuz.
*         change document
          move-corresponding hkssk to abkssk.
          abkssk-class = rmclkssk-class.
          abkssk-kz = hinzu.
          append abkssk.
        endif.

        if xaennr is initial.
          append hkssk.
        else.
*         with change number
          if redun-aediezuord is initial.
            clear hkssk-aennr.
            clear hkssk-datuv.
            append hkssk.
          else.
            hkssk-aennr = xaennr.
*-- Muß "umgestrickt" werden auf gleiche AENNR und Löschkennzeichen
            if  g_effectivity_used  is initial.
              select * from kssk up to 1 rows "gibt es einen KSSK-SATZ
                where objek =  hkssk-objek    "zum gleichen Tab mit
                  and mafid =  hkssk-mafid    "Löschkennzeichen
                  and klart =  hkssk-klart
                  and clint le hkssk-clint
                  and clint ge hkssk-clint
                  and datuv =  hkssk-datuv
                  and lkenz =  kreuz.
                exit.
              endselect.
            else.
*-- Auf gleiche Änderungsnummer abfragen
              select * from kssk up to 1 rows "gibt es einen KSSK-SATZ
                where objek =  hkssk-objek    "zum gleichen Tab mit
                  and mafid =  hkssk-mafid    "Löschkennzeichen
                  and klart =  hkssk-klart
                  and clint le hkssk-clint
                  and clint ge hkssk-clint
                  and aennr =  hkssk-aennr
                  and datuv =  g_effectivity_date
                  and lkenz =  kreuz.
                exit.
              endselect.
            endif.
            if syst-subrc = 0.         "JA---> dann verändern Satz
              vkssk       = hkssk.
              vkssk-adzhl = kssk-adzhl.
              append vkssk.
*             continue.
            else.
              select objek mafid klart clint max( adzhl )
                from kssk
                into (ks-objek,ks-mafid,ks-klart,ks-clint,ks-adzhl)
                where mafid =  hkssk-mafid
                  and klart =  hkssk-klart
                  and objek =  hkssk-objek
                  and clint le hkssk-clint
                  and clint ge hkssk-clint
                group by objek mafid klart clint.
                exit.
              endselect.
              if syst-subrc = 0.
                hkssk-adzhl = ks-adzhl + 1.
              else.
                clear hkssk-adzhl.
              endif.
              append hkssk.
            endif.
          endif.
        endif.
    endcase.

    if not ksskflag is initial.
*     Objekt = Material: Fortschreiben Materialstatus
      if rmclkssk-obtab = tabmara or table = tabmara.
        if called_from_cl = kreuz.
          if ksskflag = hinzu or
            ( ksskflag = veraend and rmclkssk-updat <> 'Z' ).
            if rmclkssk-objek <> l_object_tmp.
              if rmclkssk-mafid = mafido.
                lcl_material=>add( rmclkssk-objek ).          "  1984597
              endif.
            endif.
          endif.
        endif.
      endif.

      if redun-ausp_gen <> space.
*       get object for generated class tables (doubles are allowed)
        lt_gentab-klart  = rmclkssk-klart.
        lt_gentab-objek  = sobjekt.
        lt_gentab-mafid  = rmclkssk-mafid.
        append lt_gentab.
      endif.
      if rmclkssk-objek <> l_object_tmp.
*       another object: create ALE pointer
        if g_effectivity_used is initial.
          clear g_ale_datuv .
        else.
          g_ale_datuv = date_of_change.
        endif.
        perform fuellen_ale_tab using rmclkssk-objek
                                      rmclkssk-obtab
                                      rmclkssk-mafid
                                      rmclkssk-klart
                                      xaennr.
      endif.
    endif.

    l_object_tmp = rmclkssk-objek.
    l_mafid_tmp  = rmclkssk-mafid.
    l_klart_tmp  = rmclkssk-klart.
  endloop.                             " kssktab

*----------------------------------------------------------------------
* 2. Hinzufügen / Verändern / Löschen AUSP-Sätze

  lcl_material=>sort( ).                                      "  1984597
  read table ausptab index 1 transporting no fields.
  if sy-subrc = 0.
    sort kssktab by objek klart mafid.
    clear l_klart_tmp.
    sort ausptab by klart mafid objek atinn atzhl statu descending.

    loop at ausptab where statu <> space.
      rmclausp = ausptab.

      if rmclausp-klart <> l_klart_tmp.
*       another class type
        l_klart_tmp = rmclausp-klart.
        clear l_object_tmp.
        if rmclausp-klart eq '100' and
           G_FLG_EHS_MOD_ACTIVE = 'X'. "note 701214
*         Sonderlogik EH&S
          l_klart_100 = 'X'.
        endif.
*       Nachlesen Klassenart, um TCLA-EFFE_ACT zu ermitteln
        clear g_effectivity_used .
        clear g_effectivity_date .
        if not xaennr is initial.
          call function 'CLEF_EFFECTIVITY_USED'
            exporting
              i_aennr          = xaennr
              i_classtype      = l_klart_tmp
            importing
              e_effe_datum     = g_effectivity_date
              e_effe_aennr     = g_effectivity_used
            exceptions
              klart_not_active = 1
              others           = 2.
        endif.
      endif.
      if rmclausp-mafid <> l_mafid_tmp.
*       another allocation type K/O
        l_mafid_tmp = rmclausp-mafid.
        clear l_object_tmp.
      endif.
      if not object is initial.
        write <real> to rmclausp-objek+offset(laenge).
      endif.

      if rmclausp-objek <> l_object_tmp.
*       process only for another object
        l_object_tmp = rmclausp-objek.
        clear l_atinn_tmp.

*       get object key, read cust. class type
        if rmclausp-mafid = mafidk.
          sobjekt = rmclausp-objek.
          clear l_obtab.
        else.
          if rmclausp-cuobj is initial.
            sobjekt = rmclausp-objek.
          else.
            sobjekt = rmclausp-cuobj.
          endif.
          l_obtab = rmclausp-obtab.
        endif.
        read table redun with key klart = rmclausp-klart
                                  obtab = l_obtab
                                  binary search.
        if sy-subrc <> 0.
          perform fill_redun using rmclausp-klart l_obtab.
        endif.
        if xaennr is initial.
          clear redun-aediezuord.
        endif.

        if redun-ausp_gen <> space.
*         get object for generated class tables (doubles are allowed)
          lt_gentab-klart  = rmclausp-klart.
          lt_gentab-objek  = sobjekt.
          lt_gentab-mafid  = rmclausp-mafid.
          append lt_gentab.
        endif.
*       create ALE pointer
        if g_effectivity_used is initial.
          clear g_ale_datuv.
        else.
          g_ale_datuv = date_of_change.
        endif.
        perform fuellen_ale_tab using rmclausp-objek
                                      rmclausp-obtab
                                      rmclausp-mafid
                                      rmclausp-klart
                                      xaennr.

*       Objekt = Material: Fortschreiben Materialstatus
        if called_from_cl = kreuz.
          if ausptab-mafid = mafido.
            clear kssktab.
            if table <> tabmara.
              read table kssktab with key objek = ausptab-objek
                                          klart = ausptab-klart
                                          mafid = ausptab-mafid
                                          binary search.
            endif.
            if table = tabmara or kssktab-obtab = tabmara.
              lcl_material=>add( ausptab-objek ).             "  1984597
            endif.
          endif.
        endif.

        if insert_mod is initial.
          select * from ausp into table iausp
                        where objek = sobjekt
                          and klart = ausptab-klart
                          and mafid = ausptab-mafid.
          if syst-subrc = 0.
            if xaennr is initial.
              sort iausp by atinn atzhl.
            else.
              sort iausp by atinn
                            atzhl descending
                            adzhl descending.
            endif.
          endif.
        endif.
      endif.                           " if another object

      if rmclausp-atinn <> l_atinn_tmp.
*       another characteristic
        l_atinn_tmp = rmclausp-atinn.
        clear max_atzhl.
        if not redun-ausp_new is initial.
*         AUSP: neue Logik, für alle Bewertungen eines objek/atinn:
*         - adzhl = alter Maxwert + 1, keine Wiederverwendung.
*         - verwenden in allen folgenden case/when
*         - atzhl: Maxwert für diese Gruppe festhalten.
          l_adzhl_new = c_adzhl_start - 1.
          max_atzhl   = c_atzhl_mult - 1.
          read table iausp with key
                                atinn = rmclausp-atinn
                                binary search.
          if sy-subrc = 0.
            max_atzhl = iausp-atzhl.
            if not redun-aediezuord is initial.
*             Wiederverwendbare atzhl in l_free_atzhl_tab schreiben.
*             Nur bei mehrwertigen Merkmalen und neuer Logik !
              refresh l_free_atzhl_tab.
              l_free_atzhl_tab-atinn = rmclausp-atinn.
              if iausp-atzhl = c_atzhl_single.
                l_atzhl = iausp-atzhl.
              else.
                l_atzhl = iausp-atzhl + 1.
              endif.

              loop at iausp assigning <lf_ausp> from sy-tabix.
                if <lf_ausp>-atinn <> rmclausp-atinn.
                  exit.
                endif.
                if <lf_ausp>-adzhl  >  l_adzhl_new.
                  l_adzhl_new = <lf_ausp>-adzhl.
                endif.

                if <lf_ausp>-atzhl <> l_atzhl.
                  l_atzhl = l_atzhl - 1.
                  if <lf_ausp>-atzhl < l_atzhl.
*                   L_ATZHL kommt überhaupt nicht vor:  Merken
                    clear l_free_atzhl_tab-adzhl.
                    while ( <lf_ausp>-atzhl < l_atzhl ).
                      l_free_atzhl_tab-atzhl = l_atzhl.
                      append l_free_atzhl_tab.
                      l_atzhl = l_atzhl - 1.
                    endwhile.
                  elseif
                     <lf_ausp>-atzhl =  l_atzhl and
                     <lf_ausp>-lkenz =  kreuz and
                     <lf_ausp>-datuv <= xdatuv.
*                   gleiches L_ATZHL, Löschsatz und
*                   Datuv in Vergangenheit:  Merken
                    l_free_atzhl_tab-atzhl = l_atzhl.
                    l_free_atzhl_tab-adzhl = <lf_ausp>-adzhl.
                    append l_free_atzhl_tab.
                  endif.
                endif.
              endloop.                 "iausp
              sort l_free_atzhl_tab by atinn atzhl.
            endif.
          endif.
        endif.                         " neue Logik
      endif.                           " if another characteristic

*--------------------------------------------------------------------
      IF rmclausp-statu = hinzu                          "begin 1520361
               AND xaennr IS NOT INITIAL.
        READ TABLE iausp WITH KEY
                              atinn = rmclausp-atinn
                              atzhl = rmclausp-atzhl
                              adzhl = rmclausp-adzhl
                              atwrt = rmclausp-atwrt
                              atflv = rmclausp-atflv
                              atflb = rmclausp-atflb
                              aennr = xaennr.
        IF sy-subrc IS INITIAL.
          rmclausp-statu  = veraend.
          rmclausp-datuv  = iausp-datuv.
          rmclausp-aennr  = iausp-aennr.
        ENDIF.
      ENDIF.                                               "end 1520361

      case rmclausp-statu.
        when hinzu.
          clear hausp.
          move-corresponding rmclausp to hausp.
          hausp-mandt = syst-mandt.
          if not rmclausp-cuobj is initial.
            hausp-objek = rmclausp-cuobj.
          endif.

          if not redun-aediezuord is initial.
*-- Änderungsdienst aktiv
*-- Hier wichtig: Enthält HAUSP bereits die aktuelle AENNR?
            clear l_same_aennr .
            if hausp-aennr = xaennr.
              l_same_aennr = kreuz.
            else.
              hausp-aennr = xaennr.
            endif.
            if not g_effectivity_used is initial.
              hausp-datuv = g_effectivity_date.
            else.
              hausp-datuv = xdatuv.
            endif.

            if redun-ausp_new is initial.
*-- AUSP: alte Logik
              read table iausp with key
                                    atinn = hausp-atinn
                                    binary search.
              if sy-subrc is initial.
*               iausp sorted by atzhl desc !
                if max_atzhl is initial.
                  max_atzhl = iausp-atzhl.
                endif.
              endif.
              max_atzhl = max_atzhl + 1.    "neuer ATZHL
              hausp-atzhl = max_atzhl.
              clear hausp-adzhl.

            else.
*-- AUSP: neue Logik
*--     adzhl als Flag interpretieren:
*       initial: atzhl neu vergeben oder 'alte' wiederverwenden
*--     sonst:   atzhl aus ausptab übernehmen
              if hausp-adzhl is initial.
                if hausp-atzhl > c_atzhl_single.
*                 mehrwertiges Merkmal
                  read table l_free_atzhl_tab with key
                             atinn = hausp-atinn.
                  if sy-subrc is initial and
                              l_free_atzhl_tab-atzhl > 1.
                    hausp-atzhl = l_free_atzhl_tab-atzhl.
                    delete l_free_atzhl_tab index sy-tabix .
                  else.
                    max_atzhl = max_atzhl + 1.
                    hausp-atzhl = max_atzhl.
                  endif.
                else.
*                 einwertiges Merkmal
                  hausp-atzhl = c_atzhl_single.
                endif.
              endif.                   " end hausp-adzhl

              if not l_same_aennr is initial.
*-- zur gleichen AENNR wird der alte Eintrag überschrieben
                vausp = hausp.
                append vausp.
* Änderungsbelege
                if redun-aeblgzuord = kreuz.
                  move-corresponding hausp to abausp.
                  abausp-kz = konst_i.
                  append abausp.
                  move-corresponding iausp to abausp.
                  abausp-kz = konst_d.
                  append abausp.
                endif.
                continue.
              endif.

*             neue ADZHL (ein/mehr) oben ermittelt: In HAUSP übernehmen
*             mehrwertig: ATZHL werden wieder verwendet -> adzhl+1
              l_adzhl_new = l_adzhl_new + 1.
              hausp-adzhl = l_adzhl_new.
            endif.                     " alte/neue Logik
          else.

*-- Änderungsdienst ist nicht aktiv !!! -----------------
*   If xaennr supplied, ignore it (classification is copied).
            read table iausp with key
                                  mandt = hausp-mandt
                                  objek = hausp-objek
                                  atinn = hausp-atinn
                                  atzhl = hausp-atzhl
                                  mafid = hausp-mafid
                                  klart = hausp-klart
                                  binary search.
            if syst-subrc = 0.
*-- Alter Eintrag existiert: update, keinen neuen Satz anlegen
*               adzhl: In neuer Logik könnte adzhl auf 0 stehen,
*               wenn eine Bewertung zweimal geändert wurde !
              hausp-adzhl = iausp-adzhl.
              vausp = hausp.
              append vausp.
*             Änderungsbelege
              if redun-aeblgzuord = kreuz.
                move-corresponding hausp to abausp.
                abausp-kz = konst_i.
                append abausp.
                move-corresponding iausp to abausp.
                abausp-kz = konst_d.
                append abausp.
              endif.
              continue.
            else.
*-- Ganz neuer Eintrag (ohne Änd.dienst, ein- oder mehrwertig)
              if not redun-ausp_new is initial.
*               AUSP: neue Logik
                hausp-adzhl = c_adzhl_start.
              endif.
            endif.
          endif.                       " if/else  Änderungsdienst

* Änderungsbelege ?
          if redun-aeblgzuord = kreuz.
            move-corresponding hausp to abausp.
            abausp-kz = hinzu.
            append abausp.
          endif.
          append hausp.                " neuen Satz speichern

          if not redun-aediezuord is initial and
                 redun-ausp_new is initial.
*--         Entfällt bei AUSP mit neuer Logik
*--         (Keine zuk. Löschsätze mehr erforderlich).
            clear l_delete_ausp.
            if hausp-mafid = mafido
                           and hausp-klart ne '029'.
              l_delete_ausp-datuv = '99991231' .
              loop at iausp where objek = hausp-objek
                              and atinn = hausp-atinn
                              and datuv gt xdatuv
                              and mafid = hausp-mafid
                              and klart = hausp-klart.
                if     iausp-datuv lt l_delete_ausp-datuv .
                  l_delete_ausp = iausp.
                else.
*-- Falls auch schon gleiche ATZHL zum n.Datum: nichts mehr einfügen
                  if  iausp-datuv eq l_delete_ausp-datuv
                    and iausp-atzhl eq hausp-atzhl.
                    l_delete_ausp = iausp.
                  endif.
                endif.
              endloop.
            endif.
            if not l_delete_ausp-atinn is initial and
               hausp-atzhl  ne l_delete_ausp-atzhl .
              move l_delete_ausp-datuv to hausp-datuv.
              move kreuz               to hausp-lkenz.
              move l_delete_ausp-aennr to hausp-aennr.
              hausp-adzhl = hausp-adzhl + 1 .
              append hausp.
            endif.
          endif.                       " Ende when hinzu
*
        when veraend.
          clear vausp.
          move-corresponding rmclausp to vausp.
          vausp-mandt = syst-mandt.
          if not rmclausp-cuobj is initial.
            vausp-objek = rmclausp-cuobj.
          endif.

          if redun-aediezuord is initial.
            append vausp.
          else.
*           change management
            if redun-ausp_new is initial.
*             AUSP: alte Logik
              loop at iausp where atinn = vausp-atinn
                              and atzhl = vausp-atzhl
                              and mafid = vausp-mafid
                              and klart = vausp-klart
                              and adzhl = vausp-adzhl
                              and aennr = xaennr.
                exit.
              endloop.
              if syst-subrc = 0.
                append vausp.
              else.
*--             Satz hinzufügen
                vausp-aennr = xaennr.  "ja ---> Nummer übern.
                vausp-datuv = xdatuv.
                loop at iausp where objek = vausp-objek
                                and atinn = vausp-atinn
                                and atzhl = vausp-atzhl
                                and mafid = vausp-mafid
                                and klart = vausp-klart.
                  max_adzhl   = iausp-adzhl + 1.
                  vausp-adzhl = max_adzhl.
                  exit.
                endloop.
                hausp = vausp.
                append hausp.
              endif.
            else.
*             AUSP: neue Logik
              loop at iausp where atinn = vausp-atinn
                              and atzhl = vausp-atzhl
                              and mafid = vausp-mafid
                              and adzhl = vausp-adzhl
                              and aennr = xaennr.
                exit.
              endloop.
              if syst-subrc = 0.
                append vausp.
              else.
                if not g_effectivity_used is initial.
                  vausp-datuv = g_effectivity_date.
                else.
                  vausp-datuv = xdatuv.
                endif.
                l_adzhl_new   = l_adzhl_new + 1.
                vausp-aennr   = xaennr.
                vausp-adzhl   = l_adzhl_new.
                hausp = vausp.
                append hausp.
              endif.
            endif.
          endif.                       " ÄDienst
*
        when loeschen.
          clear lausp.
          move-corresponding rmclausp to lausp.
          lausp-mandt = syst-mandt.
          if not rmclausp-cuobj is initial.
            lausp-objek = rmclausp-cuobj.
          endif.

          if redun-aediezuord is initial.
*--         ohne Änderungsdienst: Satz löschen !
            if lausp-adzhl = 0.
*             möglich, wenn von CACL_* kommend.
              read table iausp with key
                                    mandt = lausp-mandt
                                    objek = lausp-objek
                                    atinn = lausp-atinn
                                    atzhl = lausp-atzhl
                                    mafid = lausp-mafid
                                    klart = lausp-klart
                                    binary search.
              lausp-adzhl = iausp-adzhl.
            endif.
            append lausp.

          else.
*--         Änderungsdienst aktiv.
*           Ein Satz, der bereits auf der DB war und die GLEICHE
*           Änderungsnummer hatte, wird entfernt.
*           Sonst Löschsatz einfügen: lausp -> hausp

            if redun-ausp_new is initial.
*             AUSP: alte Logik
              if lausp-aennr = xaennr.
                append lausp.
*                continue.                                  "HW_717687
*              endif.                                       "HW_717687
               else.                                        "HW_717687

                CLEAR: lv_no_deletion_entry.              "begin 1571568
*             ... Löschsatz einfügen!
                lausp-aennr = xaennr.
                lausp-datuv = xdatuv.
                lausp-lkenz = kreuz.

                LOOP AT iausp WHERE atinn = lausp-atinn
                                AND atzhl = lausp-atzhl.
                  max_adzhl = iausp-adzhl + 1.

                  lausp-adzhl = iausp-adzhl.
                  IF lausp = iausp.
*deletion entry already exists in AUSP, do not create a second one.
                   lv_no_deletion_entry = 'X'.
                  ELSE.
                    lausp-adzhl = max_adzhl.
                  ENDIF.
                  EXIT.
                ENDLOOP.

                IF lv_no_deletion_entry IS INITIAL.
                  hausp = lausp.
                  APPEND hausp.
                ENDIF.
              ENDIF.                                        "end 1571568

            else.
*             AUSP: neue Logik
              if lausp-aennr is initial.
*               in API-case: aennr empty, get old change number
                read table iausp with key
                                      atinn = lausp-atinn
                                      atzhl = lausp-atzhl
                                      adzhl = lausp-adzhl.
                if sy-subrc = 0.
                  lausp-aennr = iausp-aennr.
                endif.
              endif.
              if lausp-aennr = xaennr.
                append lausp.
*               continue.                                   "HW_717687
*             endif.                                        "HW_717687
               else.                                        "HW_717687


*             ... Löschsatz einfügen!
              l_adzhl_new = l_adzhl_new + 1.
              lausp-aennr = xaennr.
              lausp-lkenz = kreuz.
*              lausp-adzhl = l_adzhl_new.                      "2187302
              if g_effectivity_used is initial.
                lausp-datuv = xdatuv.
              else.
                lausp-datuv = g_effectivity_date.
              endif.

              CLEAR: lv_no_deletion_entry.               "Begin 2187302
              LOOP AT iausp WHERE atinn = lausp-atinn
                              AND atzhl = lausp-atzhl.

                lausp-adzhl = iausp-adzhl.
                IF lausp = iausp.
*deletion entry already exists in AUSP, do not create a second one.
                 lv_no_deletion_entry = 'X'.
                ELSE.
                  lausp-adzhl = l_adzhl_new.
                ENDIF.
                EXIT.
              ENDLOOP.
              if lv_no_deletion_entry is initial.          "End 2187302
              hausp = lausp.                                "HW_717687
              append hausp.                                 "HW_717687
              endif.                                           "2187302
              endif.                                        "HW_717687

            endif.
*            hausp = lausp.                                 "HW_717687
*            append hausp.                                  "HW_717687
          endif.

*--       Änderungsbelege
          if redun-aeblgzuord = kreuz.
            move-corresponding lausp to abausp.
* remove change of note 1744625                                  1827093
* as it may suppress the logging of deletion of valuations       1827093
            abausp-kz = loeschen.
            append abausp.
          endif.

      endcase.
    endloop.                           " loop at ausptab
  endif.
*---------------------------------------------------------------------

  perform pflegen_all_tabs
          tables ausptab
          using  l_klart_100
*                called_from_cu.                               "876810
                 'X'                                           "876810
                 after_obj_create.

  if not lt_gentab[] is initial.
*   save records in generated tables
    call function 'CLGT_UPDATE_CLASSIFICATION'
      tables
        it_objects = lt_gentab.

*   save records in external index
    call function 'CLINDEX_UPDATE_PROTTABLE'
      tables
        it_object_keys = lt_gentab.
  endif.

  perform schreiben_ale_pointer.
  perform schreiben_aebeleg.
*---------------------------------------------------------------------

  if dispo_stufe = kreuz.              "Setzen DISPO-Stufe,  4.5B
    call function 'FUNCTION_EXISTS'
      exporting
        funcname           = 'CS_RC_DISST_SET'
      exceptions
        function_not_exist = 1
        others             = 2.

    if sy-subrc is initial.
      call function 'CS_RC_DISST_SET'.                       "#EC EXISTS
    endif.

  endif.

* Dispo-Sätze erstellen.
  call function 'FUNCTION_EXISTS'
    exporting
      funcname           = 'CLEX2_DISPSATZ_ERSTELLEN'
    exceptions
      function_not_exist = 1
      others             = 2.

  if sy-subrc is initial.
    describe table i_mdcp lines syst-tfill.
    if syst-tfill > 0.
      loop at i_mdcp.
        call function 'CLEX2_DISPSATZ_ERSTELLEN'             "#EC EXISTS
          exporting
            mdcp_imp = i_mdcp.
      endloop.
    endif.
  endif.

  CALL FUNCTION 'CLVF_BADI_AFTER_UPDATE'.

endfunction.
