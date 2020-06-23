*----------------------------------------------------------------------*
*   INCLUDE LWPDAF14                                                   *
*----------------------------------------------------------------------*
* FORM-Routinen für Restart.
************************************************************************

************************************************************************
form restart_begin
     tables pit_wdlsp            structure wdlsp
            pit_wdlso            structure wdlso
            pxt_errors           structure wperror_rs
     using  pi_wdls              structure wdls
            pe_fehlercode        like      sy-subrc
            pi_generate_list     like      wpstruc-modus.
************************************************************************
* FUNKTION:
* Beginne den Restart für die Positionen einer selektierten Filiale.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WDLSP             : Positionsdaten der Filiale.
*
* PIT_WDLSO             : Aufzubereitende fehlerhafte Objekte der
*                         Filiale.
* PXT_ERRORS            : Fehlertabelle, falls Restart für bestimmte
*                         Filialen nicht möglich.
* PI_WDLS               : Statuskopfzeile der Filiale.
*
* PE_ERMOD              : Kennzeichen ob Protokollschreibung für diese
*                         Filiale aktiviert.
* PE_FEHLERCODE         : > 0, falls ein Fehler auftrat.
*                         Filiale aktiviert.
* PI_GENERATE_LIST      : = 'X', wenn Listausgabe erwünscht,
*                                sonst SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_wrgp,
        h_art,
        h_ean,
        h_sets,
        h_nart,
        h_wkurs,
        h_steuern,
        h_pdat,
        h_promo,
        h_loeschen,
        h_vkorg      like t001w-vkorg,
        h_vtweg      like t001w-vtweg,
        h_filia      like t001w-werks,
        h_datbis     like sy-datum.

data: begin of i_filia_const.
        include structure gi_filia_const.
data: end of i_filia_const.

data: begin of t_wrgp occurs 10.
        include structure wpmgot3.
data: end of t_wrgp.

data: begin of t_article occurs 10.
        include structure wpart.
data: end of t_article.

data: begin of t_kunnr occurs 10.
        include structure wppdot3.
data: end of t_kunnr.

data: begin of t_promo occurs 0.
        include structure wpromo.
data: end of t_promo.


* Analysiere die WDLSO-Daten und fülle die entsprechenden Parameter
* für den Aufruf des Restart FB MASTERIDOC_CREATE_RST_W_PDLD.
  perform parameters_for_restart_fill
          tables pit_wdlsp
                 pit_wdlso
                 t_wrgp
                 t_article
                 t_kunnr
                 t_promo
                 pxt_errors
          using  pi_wdls     h_wrgp     h_art
                 h_ean       h_sets     h_nart
                 h_wkurs     h_steuern  h_pdat
                 h_promo
                 h_loeschen  h_vkorg    h_vtweg
                 i_filia_const          pe_fehlercode
                 h_datbis               h_filia.

* Falls Fehler auftraten, ein Restart also nicht möglich ist, dann
* Abbruch für diese Filiale.
  if pe_fehlercode <> 0.
    exit.
  endif. " pe_fehlercode <> 0.

* Aufruf des Restart-FB.
  call function 'MASTERIDOC_CREATE_RST_W_PDLD'
       exporting
            pi_wrgp          = h_wrgp
            pi_art           = h_art
            pi_ean           = h_ean
            pi_sets          = h_sets
            pi_nart          = h_nart
            pi_wkurs         = h_wkurs
            pi_steuern       = h_steuern
            pi_pdat          = h_pdat
            pi_promo         = h_promo
            pi_vkorg         = h_vkorg
            pi_vtweg         = h_vtweg
            pi_filia         = h_filia
            pi_filia_const   = i_filia_const
            pi_wdls          = pi_wdls
            pi_loeschen      = h_loeschen
            pi_datum_ab      = sy-datum
            pi_datum_bis     = h_datbis
            pi_generate_list = pi_generate_list
       tables
            pit_artikel      = t_article
            pit_kunnr        = t_kunnr
            pit_wrgp         = t_wrgp
            pit_promo        = t_promo
       exceptions
            download_exit    = 1
            others           = 2.


endform. " restart_begin


*eject.
************************************************************************
form parameters_for_restart_fill
     tables pit_wdlsp       structure wdlsp
            pit_wdlso       structure wdlso
            pet_wrgp        structure wpmgot3
            pet_article     structure wpart
            pet_kunnr       structure wppdot3
            pet_promo       structure wpromo
            pxt_errors      structure wperror_rs
     using  pi_wdls         structure wdls
            pe_wrgp         like      wpstruc-modus
            pe_art          like      wpstruc-modus
            pe_ean          like      wpstruc-modus
            pe_sets         like      wpstruc-modus
            pe_nart         like      wpstruc-modus
            pe_wkurs        like      wpstruc-modus
            pe_steuern      like      wpstruc-modus
            pe_pdat         like      wpstruc-modus
            pe_promo        like      wpstruc-modus
            pe_loeschen     like      wpstruc-modus
            pe_vkorg        like      t001w-vkorg
            pe_vtweg        like      t001w-vtweg
            pe_filia_const  structure gi_filia_const
            pe_fehlercode   like      sy-subrc
            pe_datbis       like      sy-datum
            pe_filia        like      t001w-werks.
************************************************************************
* FUNKTION:
* Analysiere die WDLSO-Daten und fülle die entsprechenden Parameter
* für den Aufruf des Restart FB MASTERIDOC_CREATE_RST_W_PDLD.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WDLSP             : Positionsdaten der Filiale.
*
* PIT_WDLSO             : Aufzubereitende fehlerhafte Objekte der
*                         Filiale.
* PET_WRGP              : Aufzubereitende Warengruppen.
*
* PET_ARTICLE           : Aufzubereitende Artikelobjekte.
*
* PET_KUNNR             : Aufzubereitende Kundennummern.

* PET_PROMO             : Aufzubereitende Aktionsrabatte.
*
* PI_WDLS               : Statuskopfzeile der Filiale.
*
* PE_WRGP               : 'X': Warengruppen übertragen, sonst SPACE
*
* PE_ART                : 'X': Artikeldaten übertragen, sonst SPACE
*
* PE_EAN                : 'X': EAN-Referenzen übertragen, sonst SPACE
*
* PE_SETS               : 'X': Sets übertragen, sonst SPACE
*
* PE_NART               : 'X': Nachzugsartikel übertragen, sonst SPACE
*
* PE_WKURS              : 'X': Wechselkurse übertragen, sonst SPACE
*
* PE_STEUERN            : 'X': Steuern übertragen, sonst SPACE
*
* PE_PDAT               : 'X': Personendaten übertragen, sonst SPACE
*
* PE_PROMO              : 'X': Aktionsrabatte übertragen, sonst SPACE
*
* PE_LOESCHEN           : 'X': wenn Löschmodus (nur bei direkter
*                              Anforderung möglich).
* PE_VKORG              : Verkaufsorganisation der Filiale.
*
* PE_VTWEG              : Vertriebsweg der Filiale.
*
* PE_FILIA_CONST        : Feldleiste mit Filialkonstanten.
*
* PE_FEHLERCODE         : > 0, wenn Restart für diese Filiale
*                              nicht möglich.
* PE_DATBIS             : Ende des Betrachtungszeitraums.
*
* PE_FILIA              : Filialnummer.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_datum like sy-datum.

  data: begin of i_key_artstm,
          matnr like marm-matnr,
          vrkme like marm-meinh.
  data: end of i_key_artstm.

  data: begin of i_twpfi.
          include structure twpfi.
  data: end of i_twpfi.

  data: begin of t_matnr occurs 0.
          include structure gt_matnr.
  data: end of t_matnr.


* Rücksetze Tabelleninhalt.
  refresh: pet_article, pet_kunnr, pet_wrgp.
  clear:   pet_article, pet_kunnr, pet_wrgp.
  clear:   pe_filia_const, pe_fehlercode.


* Besorge den zugehörigen Satz aus der Werkstabelle.
  select * from t001w
         where kunnr = pi_wdls-empfn.
    exit.
  endselect. " * from t001w

* Setzen der Verkaufsorganisation, des Vertriebsweges und der Filiale.
  pe_vkorg = t001w-vkorg.
  pe_vtweg = t001w-vtweg.
  pe_filia = t001w-werks.

* Besorge die filialabhängigen Konstanten.
  move-corresponding t001w to pe_filia_const.

* Übernehme Währung der Kassensysteme aus WRF1
  clear: wrf1.
  select single * from wrf1
         where locnr = t001w-kunnr.

  if sy-subrc = 0.
    pe_filia_const-posws = wrf1-posws.
  endif. " sy-subrc = 0.

* Besorge das Kommunikationsprofil der Filiale.
  call function 'POS_CUST_COMM_PROFILE_READ'
       exporting
            i_locnr               = t001w-kunnr
       importing
            o_twpfi               = i_twpfi
       exceptions
            filiale_unbekannt     = 01
            komm_profil_unbekannt = 02.

* Falls Kommunikationsprofil vorhanden.
  if sy-subrc = 0.
*   Eventuelle NULL-Werte einiger Flags in SPACE konvertieren.
    if i_twpfi-promo_rebate <> 'X'.
      clear: i_twpfi-promo_rebate.
    endif.

    if i_twpfi-PRICING_DIRECT <> 'X'.
      clear: i_twpfi-PRICING_DIRECT.
    endif.

*   Preiskopie macht beim Restart keinen Sinn.
    clear: i_twpfi-PRICES_SITEINDEP.
    clear: i_twpfi-prices_in_a071.

*   Falls Empfängerermittlung aktiviert ist, dann darf kein
*   Triggerfile erzeugt werden.
    if not i_twpfi-recdt is initial.
      i_twpfi-no_trigger = 'X'.
    endif. " not i_twpfi-recdt is initial.

*   Übernehme Daten aus Kommunikationsprofil.
    move-corresponding i_twpfi to pe_filia_const.

*   Falls der Fabrikkalender ignoriert werden soll.
    if not i_twpfi-no_fabkl is initial.
      clear: pe_filia_const-fabkl.
    endif. " not i_twpfi-no_fabkl is initial.

* Falls kein Kommunikationsprofil vorhanden ist.
  elseif sy-subrc <> 0.
*   Setze Fehlercode.
    pe_fehlercode = 1.

*   Erzeuge einen entsprechenden Hinweissatz in Fehlertabelle.
    clear: pxt_errors.
    pxt_errors-dldnr = pi_wdls-dldnr.
    pxt_errors-filia = pi_wdls-empfn.
    pxt_errors-error = c_kein_kommunikationsprofil.
    append pxt_errors.

*   Abbruch des Restart für diese Filiale.
    exit.
  endif. " sy-subrc = 0.

* Falls es keine Protokollschreibung für diese Filiale
* gibt, dann kann auch kein Restart erfolgen.
  if pe_filia_const-ermod <> space.
*   Setze Fehlercode.
    pe_fehlercode = 1.

*   Erzeuge einen entsprechenden Hinweissatz in Fehlertabelle.
    clear: pxt_errors.
    pxt_errors-dldnr = pi_wdls-dldnr.
    pxt_errors-filia = pi_wdls-empfn.
    pxt_errors-error = c_keine_protokollschreibung.
    append pxt_errors.

*   Abbruch des Restart für diese Filiale.
    exit.
  endif. " pe_filia_const-ermod <> space.

* Bestimmung des Betrachtungszeitraums in G_DATAB und G_DATBIS.
  perform time_range_get using pi_wdls-erzdt           h_datum
                               pe_filia_const-vzeit
                               pe_filia_const-fabkl
                               g_datab       pe_datbis  sy-datum.

* Prüfe, ob das Ende des Betrachtungszeitraums überhaupt noch
* aktuell ist und somit ein Restart überhaupt noch möglich.
  if pe_datbis < sy-datum.
*   Setze Fehlercode.
    pe_fehlercode = 1.

*   Erzeuge einen entsprechenden Hinweissatz in Fehlertabelle.
    clear: pxt_errors.
    pxt_errors-dldnr = pi_wdls-dldnr.
    pxt_errors-filia = pi_wdls-empfn.
    pxt_errors-error = c_vorlaufzeit_zu_klein.
    append pxt_errors.

*   Abbruch des Restart für diese Filiale.
    exit.
  endif. " pe_datbis < sy-datum.

* Bestimme die Währung und das Kreditlimit zum Buchungskreis
* der Filiale:
* Bestimme mit Hilfe des Bewertungskreises den Buchungskreis
* der Filiale. Suche zunächst in der Kopfzeile der Tabelle.
  if t001k-bwkey = pe_filia_const-bwkey.
*   Bestimme die Buchungskreisdaten der Filiale.
*   Suche zunächst in der Kopfzeile der Tabelle.
    if t001k-bukrs = t001-bukrs.
*     Übernehme den BUKRS-Kreditkontrollbereich.
      pe_filia_const-kkber = t001-kkber.

*     Übernehme die Buchungskreiswährung
      pe_filia_const-waers = t001-waers.

*   Wenn falsche Kopfzeile, dann besorge BUKRS-Daten von DB.
    else. " t001k-bukrs <> t001-bukrs.
      select single * from t001
             where bukrs = t001k-bukrs.
*     Übernehme den BUKRS-Kreditkontrollbereich.
      pe_filia_const-kkber = t001-kkber.

*     Übernehme die Buchungskreiswährung
      pe_filia_const-waers = t001-waers.
    endif. " t001k-bukrs = t001-bukrs.

* Wenn falsche Kopfzeile, dann besorge Buchungskreis von DB.
  else. " t001k-bwkey <> pe_filia_const-bwkey.
    select single * from t001k
           where bwkey = pe_filia_const-bwkey.

*   Besorge die Buchungskreisdaten der Filiale.
*   Suche zunächst in der Kopfzeile der Tabelle.
    if t001k-bukrs = t001-bukrs.
*     Übernehme den BUKRS-Kreditkontrollbereich.
      pe_filia_const-kkber = t001-kkber.

*     Übernehme die Buchungskreiswährung
      pe_filia_const-waers = t001-waers.

*   Wenn falsche Kopfzeile, dann besorge Buchungskreis von DB.
    else. " t001k-bukrs <> t001-bukrs.
      select single * from t001
             where bukrs = t001k-bukrs.
*     Übernehme den BUKRS-Kreditkontrollbereich.
      pe_filia_const-kkber = t001-kkber.

*     Übernehme die Buchungskreiswährung
      pe_filia_const-waers = t001-waers.

    endif. " t001k-bukrs = t001-bukrs.
  endif. " t001k-bwkey = pe_filia_const-bwkey.

* Falls der Download durch eine direkte Anforderung entstanden ist.
  if pi_wdls-dlmod = c_direct_mode.
*   Prüfe, ob wenigsten ein Löschsatz vorhanden ist. (Kann nur bei
*   aktivierten Löschmodus entstehen).
    loop at pit_wdlso
         where loekz <> space.
*     Setze allgemeinen Löschmodus.
      pe_loeschen = 'X'.
      exit.
    endloop. " at pit_wdlso
  endif. " pi_wdls-dlmod = c_direct_mode.

* Analysiere die WDLSO-Daten.
  loop at pit_wdlsp.
*   Prüfe, ob zu dieser Positionszeile WDLSO-Daten existieren.
    read table pit_wdlso with key
         dldnr = pit_wdlsp-dldnr
         lfdnr = pit_wdlsp-lfdnr.

*   Falls WDLSO-Daten existieren, dann analysiere sie.
    if sy-subrc = 0.
*     IDOC-Typ abhängige Analyse.
      case pit_wdlsp-doctyp.
*       Falls es sich um Warengruppen handelt.
        when c_idoctype_wrgp.
          clear: pet_wrgp.
          pe_wrgp = 'X'.
          loop at pit_wdlso
               where dldnr = pit_wdlsp-dldnr
               and   lfdnr = pit_wdlsp-lfdnr.
*           Falls nur einzelne Objekte übertragen werden sollen
            if pit_wdlso-vakey <> c_whole_idoc.
              pet_wrgp-matkl = pit_wdlso-vakey.

*             Falls kein allgemeiner Löschmodus aktiv ist.
              if pe_loeschen is initial.
                move pit_wdlso-loekz to pet_wrgp-upd_flag.
              endif. " pe_loeschen is initial.

              append pet_wrgp.
            endif. " pit_wdlso-vakey <> c_whole_idoc.
          endloop. " at pit_wdlso

*       Falls es sich um Artikelstammdaten handelt
        when c_idoctype_artstm.
          clear: pet_article.
          pe_art = 'X'.
          loop at pit_wdlso
               where dldnr = pit_wdlsp-dldnr
               and   lfdnr = pit_wdlsp-lfdnr.
*           Falls nur einzelne Objekte übertragen werden sollen
            if pit_wdlso-vakey <> c_whole_idoc.
              clear: gi_object_key.
              pet_article-arttyp = c_artikeltyp.
              i_key_artstm = pit_wdlso-vakey.

*             Falls keine VRKME mitgegeben wurde.
              if i_key_artstm-vrkme is initial.
               refresh: t_matnr.
               append i_key_artstm-matnr to t_matnr.
               perform marm_select tables t_matnr
                                          gt_vrkme
                                   using  'X'   ' '   ' '.

*             Falls eine VRKME mitgegeben wurde.
              else. " not i_key_artstm-vrkme is initial.
               refresh: gt_vrkme.
               gt_vrkme = i_key_artstm.
               append gt_vrkme.
              endif. " i_key_artstm-vrkme is initial.

              loop at gt_vrkme.
                gi_object_key = gt_vrkme.
                move-corresponding gi_object_key to pet_article.

*               Falls kein allgemeiner Löschmodus aktiv ist.
                if pe_loeschen is initial.
                  move pit_wdlso-loekz to pet_article-loekz.
                endif. " pe_loeschen is initial.

                append pet_article.
              endloop. " at gt_vrkme.
            endif. " pit_wdlso-vakey <> c_whole_idoc.
          endloop. " at pit_wdlso

*       Falls es sich um EAN-Referenzen handelt
        when c_idoctype_ean.
          clear: pet_article.
          pe_ean = 'X'.
          loop at pit_wdlso
               where dldnr = pit_wdlsp-dldnr
               and   lfdnr = pit_wdlsp-lfdnr.
*           Falls nur einzelne Objekte übertragen werden sollen
            if pit_wdlso-vakey <> c_whole_idoc.
              clear: gi_object_key.
              pet_article-arttyp = c_eantyp.
              gi_object_key      = pit_wdlso-vakey.
              move-corresponding gi_object_key to pet_article.

*             Falls kein allgemeiner Löschmodus aktiv ist.
              if pe_loeschen is initial.
                move pit_wdlso-loekz to pet_article-loekz.
              endif. " pe_loeschen is initial.

              append pet_article.
            endif. " pit_wdlso-vakey <> c_whole_idoc.
          endloop. " at pit_wdlso

*       Falls es sich um Set-Zuordnungen handelt
        when c_idoctype_set.
          clear: pet_article.
          pe_sets = 'X'.
          loop at pit_wdlso
               where dldnr = pit_wdlsp-dldnr
               and   lfdnr = pit_wdlsp-lfdnr.
*           Falls nur einzelne Objekte übertragen werden sollen
            if pit_wdlso-vakey <> c_whole_idoc.
              clear: gi_object_key.
              pet_article-arttyp = c_settyp.
              gi_object_key      = pit_wdlso-vakey.
              move-corresponding gi_object_key to pet_article.

*             Falls kein allgemeiner Löschmodus aktiv ist.
              if pe_loeschen is initial.
                move pit_wdlso-loekz to pet_article-loekz.
              endif. " pe_loeschen is initial.

              append pet_article.
            endif. " pit_wdlso-vakey <> c_whole_idoc.
          endloop. " at pit_wdlso

*       Falls es sich um Nachzugsartikel handelt
        when c_idoctype_nart.
          clear: pet_article.
          pe_nart = 'X'.
          loop at pit_wdlso
               where dldnr = pit_wdlsp-dldnr
               and   lfdnr = pit_wdlsp-lfdnr.
*           Falls nur einzelne Objekte übertragen werden sollen
            if pit_wdlso-vakey <> c_whole_idoc.
              clear: gi_object_key.
              pet_article-arttyp = c_narttyp.
              gi_object_key      = pit_wdlso-vakey.
              move-corresponding gi_object_key to pet_article.

*             Falls kein allgemeiner Löschmodus aktiv ist.
              if pe_loeschen is initial.
                move pit_wdlso-loekz to pet_article-loekz.
              endif. " pe_loeschen is initial.

              append pet_article.
            endif. " pit_wdlso-vakey <> c_whole_idoc.
          endloop. " at pit_wdlso

*       Falls es sich um Wechselkurse handelt
        when c_idoctype_cur.
          pe_wkurs = 'X'.

*       Falls es sich um Steuern handelt
        when c_idoctype_steu.
          pe_steuern = 'X'.

*       Falls es sich um Personendaten handelt
        when c_idoctype_pers.
          clear: pet_kunnr.
          pe_pdat = 'X'.
          loop at pit_wdlso
               where dldnr = pit_wdlsp-dldnr
               and   lfdnr = pit_wdlsp-lfdnr.
*           Falls nur einzelne Objekte übertragen werden sollen
            if pit_wdlso-vakey <> c_whole_idoc.
              pet_kunnr-kunnr = pit_wdlso-vakey.

*             Falls kein allgemeiner Löschmodus aktiv ist.
              if pe_loeschen is initial.
                move pit_wdlso-loekz to pet_kunnr-upd_flag.
              endif. " pe_loeschen is initial.

              append pet_kunnr.
            endif. " pit_wdlso-vakey <> c_whole_idoc.
          endloop. " at pit_wdlso

*       Falls es sich um Aktionsrabatte handelt.
        when c_idoctype_prom.
* break-point.
          clear: pet_promo.
          pe_promo = 'X'.
          loop at pit_wdlso
               where dldnr = pit_wdlsp-dldnr
               and   lfdnr = pit_wdlsp-lfdnr.
*           Falls nur einzelne Objekte übertragen werden sollen
            if pit_wdlso-vakey <> c_whole_idoc.
              pet_promo-aktnr = pit_wdlso-vakey.

*             Falls kein allgemeiner Löschmodus aktiv ist.
*              if pe_loeschen is initial.
*                move pit_wdlso-loekz to pet_promo-upd_flag.
*              endif. " pe_loeschen is initial.

              append pet_promo.
            endif. " pit_wdlso-vakey <> c_whole_idoc.
          endloop. " at pit_wdlso

      endcase. " pit_wdlsp-doctyp.
    endif. " sy-subrc = 0.
  endloop. " at pit_wdlsp.


endform. " parameters_for_restart_fill


*eject.
************************************************************************
form wdls_get_and_analyse
     tables pet_wdls               structure wdls
            pet_wdlsp              structure wdlsp
            pet_errors             structure wperror_rs
     using  pi_dldnr               like wdls-dldnr
            pi_credat              like wpstruc-datum.
************************************************************************
* FUNKTION:
* Lese die zum Restart benötigten WDLS-Sätze und analysiere
* für jeden Satz, ob es noch weitere Downloads zur gleichen Filiale
* gibt, die jünger sind. In diesem Fall darf für den jeweiligen Satz
* kein Restart durchgeführt werden.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_WDLS              : Gesuchte Statuskopfzeilen.
*
* PET_WDLSP             : Gesuchte Statuspositionszeilen.
*
* PET_ERRORS            : Wird gefüllt, falls für einen WDLS-Satz
*                         kein Restart durchgeführt werden kann.
* PI_DLDNR              : Downloadnummer für die ein Restart
*                         durchgeführt werden soll.
* PI_CREDAT             : Datum für das ein Restart durchgeführt
*                         werden soll.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_credat like sy-datum.

  data: begin of t_wdls occurs 10.
          include structure wdls.
  data: end of t_wdls.

  data: begin of t_edidc occurs 10.
          include structure edidc.
  data: end of t_edidc.


* Falls Restart für mehrere Filialen.
  if not ( pi_credat is initial ) and
     pi_credat <> space.
*   Übernehme Erzeugungsdatum in Hilfsvariable.
    h_credat = pi_credat.

*   Besorge alle zu diesem Erzeugungsdatum gehörenden Restartrelevanten
*   WDLS-Sätze.
    select * from wdls into table pet_wdls
           where erzdt = pi_credat
           and   systp = c_pos
           and ( gesst = c_status_fehlende_daten   or
                 gesst = c_status_fehlende_idocs ).

*   Falls keine Filialen selektiert wurden.
    if sy-subrc <> 0.
      raise no_filia_found.
    endif. " sy-subrc <> 0.

*   Falls es zu einer Filiale mehrere Downloads zum gleichen Datum
*   gibt, dann wird nur der jüngste WDLS-Satz genommen.
    sort pet_wdls by empfn erzzt descending.
    delete adjacent duplicates from pet_wdls
           comparing empfn.

* Falls Restart für einzelne Filiale.
  else. " PI_CREDAT is initial or pi_credat = SPACE.
*   Besorge  den zugehörigen WDLS-Satz.
    select * from wdls into table pet_wdls
           where dldnr = pi_dldnr
           and ( gesst = c_status_fehlende_daten   or
                 gesst = c_status_fehlende_idocs ).

*   Falls keine Filiale selektiert wurde.
    if sy-subrc <> 0.
      raise no_filia_found.
    endif. " sy-subrc <> 0.

*   Übernehme Erzeugungsdatum in Hilfsvariable.
    read table pet_wdls index 1.
    h_credat = pet_wdls-erzdt.
  endif. " not ( PI_CREDAT is initial ).

* Besorge zu jeder gefundenen Filiale den zuletzt durch Initialisierung
* oder Änderungsfall erzeugten WDLS-Satz.
  select * from wdls into table t_wdls
         for all entries in pet_wdls
         where empfn =  pet_wdls-empfn
         and   systp =  c_pos
         and ( dlmod =  c_init_mode     or
               dlmod =  c_change_mode )
         and   erzdt >= h_credat.

* Daten sortieren
  sort t_wdls by empfn erzdt descending erzzt descending.

* Daten komprimieren.
  delete adjacent duplicates from t_wdls
         comparing empfn.

* Prüfe, ob ein Restart für die einzelnen Sätze in PET_WDLS
* durchgeführt werden darf.
  loop at pet_wdls.
*   Lese zugehörigen Satz in T_WDLS.
    read table t_wdls with key
         empfn = pet_wdls-empfn
         binary search.

*   Falls ein zugehöriger Satz gefunden wurde und
*   die Sätze nicht identisch sind, so heißt das, daß bereits ein
*   späterer Download für diese Filiale stattgefunden haben kann.
    if sy-subrc = 0 and pet_wdls-dldnr <> t_wdls-dldnr.
*     Falls tatsächlich ein späterer Download stattgefunden hat, dann
*     ist ein Restart nicht mehr möglich.
      if   pet_wdls-erzdt <  t_wdls-erzdt  or
         ( pet_wdls-erzdt =  t_wdls-erzdt and
           pet_wdls-erzzt <  t_wdls-erzzt ).
*       Erzeuge einen entsprechenden Hinweissatz in Fehlertabelle.
        clear: pet_errors.
        pet_errors-dldnr = pet_wdls-dldnr.
        pet_errors-filia = pet_wdls-empfn.
        pet_errors-error = c_juengerer_download_vorhanden.
        append pet_errors.

*       Lösche PET_WDLS-Satz und verhindere Restart für diese Filiale.
        delete pet_wdls.
      endif. " pet_wdls-erzdt <  t_wdls-erzdt  or ...
    endif. " sy-subrc = 0 and pet_wdls-dldnr <> t_wdls-dldnr.
  endloop. " at pet_wdls.

* Prüfe, ob noch Statuskopfzeilen übrig sind
  read table pet_wdls index 1.

* Falls noch Statuskopfzeilen übrig sind
  if sy-subrc = 0.
*   Prüfe, ob die übriggebliebenen Sätze bereits vom Konverter
*   bearbeitet wurden.
    perform status_check
            tables pet_wdls
                   pet_errors
                   pet_wdlsp.
  endif. " sy-subrc = 0.


endform. " wdls_get_and_analyse


*eject.
************************************************************************
form idoc_filenames_for_restart_get
     tables pit_wdlsp              structure gt_wdlsp_buf
            pit_edidc              structure edidc
            pet_partnr             structure edidc
            pet_pathname           structure edi_path
            pet_msgtype            structure wpmsgtype
     using  pi_dldnr               like wdls-dldnr
            pe_fehlercode          like wpstruc-counter.
************************************************************************
* FUNKTION:
* Lese die zum Restart benötigten EDIDC-Sätze und besorge die
* zugehörigen Pfadnamen zum Schreiben des Triggerfiles.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WDLSP             : Statuspositionszeilen.
*
* PIT_EDIDC             : EDIDC-Sätze.
*
* PET_PARTNR            : Tabelle mit Partnernummern und -arten.
*
* PET_PATHNAME          : Gesuchte Pfadnamen.
*
* PET_MSGTYPE           : Betroffene Nachrichtentypen.
*
* PI_DLDNR              : Downloadnummer für die der Restart
*                         durchgeführt werden soll.
* PE_FEHLERCODE         : > 0, wenn Fehler auftraten, sonst 0.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_lines like sy-tabix.


* Zum zwischenspeichern von EDIDC-Daten.
  data: begin of t_edidc occurs 20.
          include structure edidc.
  data: end of t_edidc.


* Rücksetze Tabelle für Partnernummern und -arten.
  refresh: pet_partnr.
  clear:   pet_partnr.

* Lese den eventuell modifizierten WDLS-Satz.
  select single * from wdls
         where dldnr = pi_dldnr.

* Prüfe, ob überhaupt IDOC's erzeugt wurden.
  loop at pit_wdlsp
       where vsest = c_datenuebergabe_ok.
    exit.
  endloop. " at pit_wdlsp

* Falls IDOC's erzeugt wurden.
  if sy-subrc = 0.
*   Prüfe, ob über das Verteilungskundenmodell versendet wurde.
*   READ TABLE PIT_EDIDC INDEX 1.

*   Falls nicht über das Verteilungskundenmodell versendet wurde.*
*   IF SY-SUBRC <> 0.
    pet_partnr-rcvprn = wdls-empfn.
    pet_partnr-rcvprt = c_kunde.
    append pet_partnr.

*     Bestimme EDIDC-Daten
      select * from  edidc into table t_edidc
             for all entries in pit_wdlsp
             where docnum = pit_wdlsp-docnum
             and   status = c_datenuebergabe_ok.

*   Falls über das Verteilungskundenmodell versendet wurde.
*   ELSE. " sy-subrc = 0.
*     LOOP AT PIT_EDIDC.
*       APPEND PIT_EDIDC TO PET_PARTNR.
*     ENDLOOP. " at pit_edidc.

*     Daten sortieren.
*     SORT PET_PARTNR BY RCVPRN RCVPRT.

*     Löschen alle doppelten Partnernummer-, Partnerartkombinationen.
*     DELETE ADJACENT DUPLICATES FROM PET_PARTNR
*            COMPARING RCVPRN RCVPRT.

*     Bestimme EDIDC-Daten
*     LOOP AT PIT_EDIDC
*          WHERE STATUS = C_DATENUEBERGABE_OK.
*       APPEND PIT_EDIDC TO T_EDIDC.
*     ENDLOOP. " at pit_edidc
*   ENDIF. " sy-subrc <> 0.

*   Besorge die Pfadnamen zum schreiben des Triggerfiles.
    perform pathnames_get
            tables t_edidc
                   pet_partnr
                   pet_pathname
                   pet_msgtype
            using  wdls
                   pe_fehlercode.

* Falls keine IDOC's erzeugt wurden.
  else. " sy-subrc <> 0.
    refresh: pet_pathname.
  endif. " sy-subrc = 0.

* Prüfe, ob Daten ans SCS übergeben wurden.
  describe table pet_pathname lines h_lines.

* Falls Daten ans SCS übergeben wurden.
  if h_lines > 0.
*   Setze Status auf 'An SCS übergeben'.
    wdls-vsest = c_an_scs_uebergeben.
    update wdls.
    commit work.

* Falls keine Daten ans SCS übergeben wurden.
  else. " h_lines = 0.
*   Fehlercode setzen.
    pe_fehlercode = 1.
  endif. " h_lines > 0.


endform. " idoc_filenames_for_restart_get


*eject.
************************************************************************
form status_check
     tables pxt_wdls     structure wdls
            pxt_errors   structure wperror_rs
            pet_wdlsp    structure wdlsp.
************************************************************************
* FUNKTION:
* Aktualisiere den Status der WDLSP-Sätze und eliminiere diejenigen
* WDLS-Sätze, die noch nicht vom Konverter bearbeitet werden konnten.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_WDLS              : Gesuchte Statuskopfzeilen.
*
* PXT_ERRORS            : Wird gefüllt, falls für einen WDLS-Satz
*                         kein Restart durchgeführt werden kann.
* PET_WDLSP             : WDLS-Sätze werden zur späteren Bearbeitung
*                         mit ausgegeben.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_all_data_ok like wdl_flag-xflag.


* Besorge zunächst alle zugehörigen Statuspositionszeilen
* zu denen IDOC's erzeugt wurden.
  select * from wdlsp into table pet_wdlsp
         for all entries in pxt_wdls
         where dldnr  =  pxt_wdls-dldnr
         and   rfpos  =  '000000'.

* Falls keine Sätze gefunden wurden, dann weitere Analyse nicht nötig.
  if sy-subrc <> 0.
    exit.
  endif. " sy-subrc <> 0.

* Daten sortieren.
  sort pet_wdlsp by dldnr lfdnr.

* Aktualisiere die Statusse.
  call function 'DOWNLOAD_EDI_STATUS_CONTROL'
       importing
            pe_all_already_ok = h_all_data_ok
       tables
            pi_t_wdls         = pxt_wdls
            pi_t_wdlsp        = pet_wdlsp
       exceptions
            no_edi_status     = 1
            others            = 2.

* Falls alle Sätze erfolgreich vom Konverter bearbeitet und
* weitergeleitet wurden, dann keine weitere Analyse nötig.
  if h_all_data_ok <> space.
    exit.
  endif. " h_all_data_ok <> space.

* Beginne Analyse.
  loop at pxt_wdls.
*   Falls diese Downloadnummer noch nicht vom Subsystem bearbeitet
*   wurde oder werden konnte, d. h. es gibt wenigstens einen Satz
*   der noch im Status 'An SCS Übergeben' steht.
    loop at pet_wdlsp
         where dldnr = pxt_wdls-dldnr
         and   vsest = c_an_scs_uebergeben. " ### später aktivieren
*        and   vsest = '11'.                " ### nur zum testen.
*     Erzeuge Satz in Fehlertabelle
      pxt_errors-dldnr = pxt_wdls-dldnr.
      pxt_errors-filia = pxt_wdls-empfn.
      pxt_errors-error = c_subsystem_noch_nicht_aktiv.
      append pxt_errors.

*     Lösche PXT_WDLS-Satz und verhindere Restart für diese Filiale.
      delete pxt_wdls.

*     Schleife verlassen.
      exit.
    endloop. " at pet_wdlsp
  endloop. " at pxt_wdls.


endform. " status_check
