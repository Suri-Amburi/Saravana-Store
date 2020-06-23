function ZCLFM_WWS_CLASSIFICATION.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CLASS) LIKE  KLAH-CLASS
*"     VALUE(CLASS_TEXT) LIKE  RMCLF-KLTXT
*"     VALUE(UPPER_CLASS) LIKE  KLAH-CLASS
*"     VALUE(UPPER_CLINT) LIKE  KLAH-CLINT
*"     VALUE(UPPER_CLASS_TEXT) LIKE  RMCLF-KLTXT
*"     VALUE(STATUS)
*"     VALUE(NO_F11) DEFAULT SPACE
*"     VALUE(AEBELEGE) LIKE  TCLA-AEBLGZUORD DEFAULT SPACE
*"     VALUE(WWS_CLASS_IND) LIKE  KLAH-WWSKZ
*"     VALUE(PBATCH) OPTIONAL
*"  EXPORTING
*"     VALUE(UPDATEFLAG) LIKE  RMCLK-UPDAT
*"     VALUE(OKCODE) LIKE  SY-UCOMM
*"--------------------------------------------------------------------
*-- (lokale) Konstanten
  data: dynp0001 like syst-dynnr value '0001'.
  data: dynp0003 like syst-dynnr value '0003'.
  data: dynp0004 like syst-dynnr value '0004'.
  data: dynp0005 like syst-dynnr value '0005'.
  data: vier(1)                  value '4'.
*-- Lokale Variablen
  data: l_subrc       like sy-subrc.
  data: l_tabix       like sy-tabix.
*
*
  data: begin of skssk occurs 0.
          include structure kssk.
  data:  end of skssk.
* Anfang Eingefügt Kabuth 28.04.97
  clear sokcode.
  if not pbatch is initial.            "cfo/4.0 für Datenübernahme
    pm_batch = pbatch.                                      "
  else.                                                     "
    clear pm_batch.
  endif.                               "cfo/4.0
  clear nodisplay.
  clear aenderflag.
* Ende Eingefügt Kabuth 28.04.97
  clear delcl.
  clear nof11.
  clear allkssk.
  clear viewk.
  refresh viewk.
  refresh klastab.
  clear allausp.
  clear pm_inobj.                      "WFS 28.7.
  clear updateflag.
  clear okcode.                        "cfo/4.0
  pm_depart   = kreuz.
  pm_objek    = class.
  pm_class    = upper_class.
  pm_clint    = upper_clint.
  rmclf-objek = class.
  rmclf-class = upper_class.
*-- Eingefügt: Applikationskennzeichen W (Sottong, 12.5.97)
  g_appl = konst_w.
  g_no_lock_klart = 'X'.               "cfo/4.0 Klassenart
                                       "nur shared sperren

* Anfang Kabuth 29.09.97
* Der Parameter SUPPRESSD wird initialisiert, da ansonsten SOKCODE immer
* auf SAVE steht.
  clear suppressd.
* Ende Kabuth 29.09.97
  if not no_f11 is initial.
    nof11 = no_f11.
  endif.
* Prüfe WWS-Klassenart
  sobtab = tabmara.
  select single * from tcla
    where klart = '026'.
  if syst-subrc ne 0.
    exit.
  endif.
  clhier      = tcla-hierarchie.
  rmclf-klart = tcla-klart.
*
  if status ne drei.
*--> Commented by -> sjena <- 01.02.2020 14:42:37
***    CALL FUNCTION 'CLEN_ENQUEUE_CLASSIFICATION'          "begin 1141804
***      EXPORTING
***        iv_enqmode           = 'E'
***        iv_klart             = rmclf-klart
***        IV_CLASS             = class
***      EXCEPTIONS
***        FOREIGN_LOCK         = 1
***        SYSTEM_FAILURE       = 2.
***    case sy-subrc.                                         "end 1141804
***      when 1.
***        message e517.
***      when 2.
***        message e519.
***    endcase.
  endif.
*
  if status ne vier.
*   select include screen
    call function 'CLTB_GET_FUNCTIONS'
      exporting
        i_obtab           = 'MARA'
      importing
        e_function_import = tclfm-fbs_import
        e_function_export = tclfm-fbs_export
        e_function_pool   = tclfm-repid
      exceptions
        not_found         = 1
        others            = 2.
    pm_header-report = tclfm-repid.

    case wws_class_ind.
      when '1'.                        " 1 = Hierarchie  --> Warengruppe
        pm_header-dynnr = dynp0003.    "Bildbaustein Hierarchie-Warengr
        rmclf-wargr     = class.
        rmclf-wghie     = upper_class.
        call function 'CLSE_SELECT_KSSK_0'       "hat die Hierarchie
          exporting  mafid          = mafidk     "schon eine Hierarchie
                     klart          = rmclf-klart "zugeordnet?
                     clint          = upper_clint
                     refresh        = kreuz
                     key_date       = rmclf-datuv1
          tables     exp_kssk       = skssk
          exceptions no_entry_found = 1.
        if syst-subrc ne 1.
          clear   iklah.
          refresh iklah.
          loop at skssk.
            iklah-clint = skssk-objek.
            append iklah.
          endloop.
          call function 'CLSE_SELECT_KLAH'
               tables
                    imp_exp_klah   = iklah
               exceptions
                    no_entry_found = 01.
          loop at iklah where wwskz = '0'.      "0=Hierarchie
            exit.
          endloop.
          if syst-subrc = 0.
            if status ne drei.
*             Sperre zurücknehmen                        "begin 1141804
              CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'
                EXPORTING
                  iv_enqmode = 'E'
                  iv_klart   = rmclf-klart
                  iv_class   = class.                      "end 1141804
            endif.
            message e560 with iklah-class rmclf-wghie. "ERROR
          endif.
        endif.
      when '2'.              " 2 = Warengruppe --> Merkmalprofil
        pm_header-dynnr = dynp0001.    "Bildbaustein Warengruppe-Profil
        rmclf-bsstr     = class.
        rmclf-wargr     = upper_class.
      when '3'.               " 3 = merkmalprof --> Sammelartikel
        nof11           = kreuz.       "Sichern bei Bewertung wegneh.
        pm_header-dynnr = dynp0004.    "Bildbaustein Profil.-Sammelart
        rmclf-satnr     = class.
        rmclf-bsstr     = upper_class.
      when '4'.               " 4 = Warengruppe --> Sammelartikel
        nof11           = kreuz.       "Sichern bei Bewertung wegneh.
        pm_header-dynnr = dynp0005.    "Bildbaustein Wareng.-Sammelart
        rmclf-satnr     = class.
        rmclf-wargr     = upper_class.
      when others.
        if status ne drei.
          CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'    "begin 1141804
            EXPORTING
              iv_enqmode = 'E'
              iv_klart   = rmclf-klart
              iv_class   = class.                          "end 1141804
        endif.
        exit.
    endcase.
    rmclf-kltxt = class_text.
    rmclf-ktext = upper_class_text.
    mafid       = mafidk.
    nof8        = kreuz.
    index_neu    = 1.
    rmclf-pagpos = 1.
    refresh klastab.
    refresh itclc.
* Lesen Statustabelle
    if cl_statusf is initial.
      perform lesen_tclc using rmclf-klart.
    endif.
    if cl_statusf is initial.
      if status ne drei.
        CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'      "begin 1141804
          EXPORTING
            iv_enqmode = 'E'
            iv_klart   = rmclf-klart
            iv_class   = class.                            "end 1141804
      endif.
      message e541 with rmclf-klart.
    endif.
  endif.
*
  classif_status = status.
  call function 'CLMA_CLASS_EXIST'
       exporting
            class         = class
            classtype     = rmclf-klart
       importing
            xklah         = klah
       exceptions
            no_valid_sign = 1
            others        = 2.
  pm_clint  = klah-clint.
  pm_clint1 = klah-clint.

  case status.
* Status eins eingefügt KAbuth 07.04.97
    when eins.
      if wws_class_ind = 2.
        multi_class = kreuz.
*--> Commented -> sjena <- 01.02.2020 20:10:02  "Read KSSK
     "Only Processing new entries coz data processing takes longer time to prepare alkssk for old records
     "Validated Existanse in custom program before processing this entry
***        perform lesen_kssk.            "gehe auf Datenbank
        allkssk-objek    = class.
        allkssk-oclint   = pm_clint.
        allkssk-clint    = upper_clint.
        allkssk-klart    = rmclf-klart.
        allkssk-mafid    = mafidk.
        allkssk-statu    = cl_statusf.
        allkssk-stdcl    = space.
        allkssk-class    = upper_class.
        allkssk-kschl    = upper_class_text.
        allkssk-vbkz     = c_insert .
        allkssk-obtab    = sobtab.
        append allkssk.

        pkssk-klart  = allkssk-klart.  "Klassenart
        pkssk-oclass = upper_class.    "Oberklasse
        pkssk-oclint = upper_clint.    "Int. Klassennummer oclass
        pkssk-uclass = class.          "Unterklasse
        pkssk-uclint = pm_clint.       "Int. Klassennummer uclass
        append pkssk.

        sort allkssk by objek clint klart mafid.
        perform build_viewtab using upper_clint pm_class.
* Achtung: Hier Performancehinweis 487720 BKE
*       perform klassifizieren.
        aenderflag = kreuz.

        read table pkssk index 1.
        if syst-subrc = 0.
          loop at allausp where mafid = mafidk
                            and klart = rmclf-klart
                            and objek = class.
            move-corresponding allausp to pausp.
            pausp-objek = pm_clint.
            append pausp.
          endloop.
        endif.
      endif.
***ENDE EINFÜGUNG Kabuth 07.04.97

    when zwei.
*-- Prüfen, ob ALLKSSK etc. neu aufgebaut werden müssen
      clear l_subrc.
      read table  allkssk with key
                objek    = class
                oclint   = pm_clint
                clint    = upper_clint
                klart    = rmclf-klart
                mafid    = mafidk.
      if not sy-subrc is initial.
        perform lesen_kssk.            "gehe auf Datenbank
        read table  allkssk with key
                objek    = class
                oclint   = pm_clint
                clint    = upper_clint
                klart    = rmclf-klart
                mafid    = mafidk.
        if not sy-subrc is initial.
          l_subrc = 4.
        endif.
      endif.
      if not l_subrc is initial .
        allkssk-objek    = class.
        allkssk-oclint   = pm_clint.
        allkssk-clint    = upper_clint.
        allkssk-klart    = rmclf-klart.
        allkssk-mafid    = mafidk.
        allkssk-statu    = cl_statusf.
        allkssk-stdcl    = space.
        allkssk-class    = upper_class.
        allkssk-kschl    = upper_class_text.
        allkssk-vbkz     = c_insert.
        allkssk-obtab    = sobtab.
        append allkssk.
        pkssk-klart  = allkssk-klart.  "Klassenart
        pkssk-oclass = upper_class.    "Oberklasse
        pkssk-oclint = upper_clint.    "Int. Klassennummer oclass
        pkssk-uclass = class.          "Unterklasse
        pkssk-uclint = pm_clint.       "Int. Klassennummer uclass
        append pkssk.
      endif.

      sort allkssk by objek clint klart mafid.
      perform build_viewtab using upper_clint pm_class.
      perform klassifizieren.
* If-Abfrage raus, da auch eine neue Zuordnung eine Änderung ist und
* nicht nur eine Änderung der Bewertung. Kabuth 24.10.97
*-- Falls keine Bewertungen bearbeitet wurden: FLAG abfragen
*     IF NOT G_NO_VALUATION IS INITIAL.
      aenderflag = kreuz.
*     ENDIF.

      read table pkssk index 1.
      if syst-subrc = 0.
        loop at allausp where mafid = mafidk
                          and klart = rmclf-klart
                          and objek = class.
          move-corresponding allausp to pausp.
          pausp-objek = pm_clint.
          append pausp.
        endloop.
      endif.

    when drei.
* cfo/4.0-A Auch im Anzeigefall erst die KSSK im Puffer suchen
      read table  allkssk with key
                objek    = class
                oclint   = pm_clint
                clint    = upper_clint
                klart    = rmclf-klart
                mafid    = mafidk.
      if not sy-subrc is initial.
* cfo/4.0-E
        perform lesen_kssk.            "gehe auf Datenbank
        describe table klastab lines l_tabix.
* cfo/4.0-A
      else.
        l_tabix = sy-tabix.
      endif.
* cfo/4.0-E
      if l_tabix = 0.
        exit.
      else.
        sort allkssk by objek clint klart mafid.
        perform build_viewtab using upper_clint pm_class.
        perform klassifizieren.
        exit.
      endif.

    when vier.
      skssk-objek = pm_clint.
      call function 'CLSE_SELECT_KSSK_0'
           exporting
                clint          = upper_clint
                klart          = rmclf-klart
                mafid          = mafidk
                objek          = skssk-objek
                neclint        = ' '
                key_date       = rmclf-datuv1
           tables
                exp_kssk       = skssk
           exceptions
                no_entry_found = 01.
      if syst-subrc = 1.
        clear updateflag.
        CALL FUNCTION 'CLEN_DEQUEUE_CLASSIFICATION'      "begin 1141804
          EXPORTING
            iv_enqmode = 'E'
            iv_klart   = rmclf-klart
            iv_class   = class.                            "end 1141804
        exit.
      endif.
      read table skssk index 1.
      select atinn from ausp into table auspmerk
        where objek = skssk-objek
          and mafid = skssk-mafid
          and klart = skssk-klart.
      if syst-subrc = 0.
        sort auspmerk by atinn.
        delete adjacent duplicates from auspmerk.
        loop at auspmerk.
          delcl-mafid = skssk-mafid.
          delcl-klart = skssk-klart.
          delcl-objek = class.
          delcl-clint = skssk-clint.
          delcl-merkm = auspmerk-atinn.
          delcl-obtab = tcla-obtab.
          append delcl.
        endloop.
      else.
        delcl-mafid = skssk-mafid.
        delcl-klart = skssk-klart.
        delcl-objek = class.
        delcl-clint = skssk-clint.
        clear delcl-merkm.
        delcl-obtab = tcla-obtab.
        append delcl.
      endif.
      perform cust_exit_post USING ' '.                       "  2241496
      perform delete_classification on commit.
      updateflag = kreuz.
      exit.
  endcase.

* wfs/1.2B2-A Falls etwas geändert wurde: AENDERFLAG ist gesetzt
  updateflag = aenderflag .
  okcode = sokcode.                    "cfo/4.0
  if sokcode = oksave
    or not aenderflag is initial.
    perform cust_exit_post USING ' '.                         "  2241496
    perform insert_classification on commit.
  endif.
* wfs/1.2B2-E

endfunction.
