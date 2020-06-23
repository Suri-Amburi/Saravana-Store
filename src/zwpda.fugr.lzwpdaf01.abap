*----------------------------------------------------------------------*
*   INCLUDE LWPDAF01                                                   *
*----------------------------------------------------------------------*
* Allgemeine FORM-Routinen für POS-Schnittstelle.
************************************************************************


************************************************************************
FORM filia_const_get
     USING  pi_filia       LIKE       wpfilia-filia
            px_dldnr       LIKE       wdls-dldnr
   CHANGING pe_filia_const STRUCTURE  gi_filia_const
            pi_erstdat     LIKE       g_erstdat
            pi_erstzeit    LIKE       g_erstzeit
            pi_mode        LIKE       wpstruc-modus
            VALUE(pe_fehlercode) LIKE g_returncode.
************************************************************************
* FUNKTION:                                                            *
* Besorge einige filialabhängigen Konstanten.                          *
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_FILIA      : Filiale, für die die Konstanten besorgt werden sollen.

* PX_DLDNR      : Downloadnummer für Statusverfolgung.

* PE_FILIA_CONST: Feldleiste mit Filialkonstanten.

* PI_ERSTDAT     : Beginndatum des Downloads.

* PI_ERSTZEIT    : Beginnzeit des Downloads.

* PI_MODE        : = 'I', wenn Initialisierungsmodus, 'A' = direkte
*                  Anforderung.
* PE_FEHLERCODE : > 0, wenn Fehler auftraten, sonst 0.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: fehlercode LIKE g_returncode.


  DATA: BEGIN OF i_twpfi.
      INCLUDE STRUCTURE twpfi.
  DATA: END OF i_twpfi.

* Rücksetze Fehlercode.
  CLEAR: pe_fehlercode.

  CALL FUNCTION 'LOCATION_SELECT_PLANT'
    EXPORTING
      i_werks = pi_filia
    IMPORTING
      o_t001w = t001w.

  MOVE-CORRESPONDING t001w TO pe_filia_const.

* transfer currency of POS-system from WRF1:
  CLEAR: wrf1.
  CALL FUNCTION 'LOCATION_WRF1_SELECT'
    EXPORTING
      i_locnr        = t001w-kunnr
    IMPORTING
      a_wrf1         = wrf1
    EXCEPTIONS
      no_entry_found = 1
      OTHERS         = 2.
  IF sy-subrc = 0.
    pe_filia_const-posws = wrf1-posws.
  ENDIF.

* Besorge das Kommunikationsprofil der Filiale.
  CALL FUNCTION 'POS_CUST_COMM_PROFILE_READ'
    EXPORTING
      i_locnr               = t001w-kunnr
    IMPORTING
      o_twpfi               = i_twpfi
    EXCEPTIONS
      filiale_unbekannt     = 01
      komm_profil_unbekannt = 02.

* Falls alles OK.
  IF sy-subrc = 0 AND i_twpfi-vzeit <> 0.
*   Eventuelle NULL-Werte einiger Flags in SPACE konvertieren.
    IF i_twpfi-promo_rebate <> 'X'.
      CLEAR: i_twpfi-promo_rebate.
    ENDIF.

    IF i_twpfi-pricing_direct <> 'X'.
      CLEAR: i_twpfi-pricing_direct.
    ENDIF.

    IF i_twpfi-prices_siteindep <> 'X'.
      CLEAR: i_twpfi-prices_siteindep.
    ENDIF.

    IF i_twpfi-prices_in_a071 <> 'X'.
      CLEAR: i_twpfi-prices_in_a071.
    ELSE.
*     Setze Flag für Preiskopie.
      i_twpfi-prices_siteindep = 'X'.
    ENDIF.

*   Falls Empfängerermittlung aktiviert ist und die Trigger-Info nicht
*   via RFC verschickt werden soll, dann darf keine Trigger-Info
*   erzeugt werden.
    IF NOT i_twpfi-recdt          IS INITIAL   AND
           c_trigger_send_via_rfc IS INITIAL.
      i_twpfi-no_trigger = 'X'.
    ENDIF. " not i_twpfi-recdt is initial...

*   Übernehme Daten aus Kommunikationsprofil.
    MOVE-CORRESPONDING i_twpfi TO pe_filia_const.

*   Falls der Fabrikkalender ignoriert werden soll.
    IF NOT i_twpfi-no_fabkl IS INITIAL.
      CLEAR: pe_filia_const-fabkl.
    ENDIF. " not i_twpfi-no_fabkl is initial.

*   Bestimme die Währung und das Kreditlimit zum Buchungskreis
*   der Filiale:
*   Bestimme mit Hilfe des Bewertungskreises den Buchungskreis
*   der Filiale. Suche zunächst in der Kopfzeile der Tabelle.
    IF t001k-bwkey = pe_filia_const-bwkey.
*     Bestimme die Buchungskreisdaten der Filiale.
*     Suche zunächst in der Kopfzeile der Tabelle.
      IF t001k-bukrs = t001-bukrs.
*       Übernehme den BUKRS-Kreditkontrollbereich.
        pe_filia_const-kkber = t001-kkber.

*       Übernehme die Buchungskreiswährung
        pe_filia_const-waers = t001-waers.

*     Wenn falsche Kopfzeile, dann besorge BUKRS-Daten von DB.
      ELSE. " t001k-bukrs <> t001-bukrs.
        SELECT SINGLE * FROM t001
               WHERE bukrs = t001k-bukrs.
*       Übernehme den BUKRS-Kreditkontrollbereich.
        pe_filia_const-kkber = t001-kkber.

*       Übernehme die Buchungskreiswährung
        pe_filia_const-waers = t001-waers.
      ENDIF. " t001k-bukrs = t001-bukrs.

*   Wenn falsche Kopfzeile, dann besorge Buchungskreis von DB.
    ELSE. " t001k-bwkey <> pe_filia_const-bwkey.
      SELECT SINGLE * FROM t001k
             WHERE bwkey = pe_filia_const-bwkey.

*     Besorge die Buchungskreisdaten der Filiale.
*     Suche zunächst in der Kopfzeile der Tabelle.
      IF t001k-bukrs = t001-bukrs.
*       Übernehme den BUKRS-Kreditkontrollbereich.
        pe_filia_const-kkber = t001-kkber.

*       Übernehme die Buchungskreiswährung
        pe_filia_const-waers = t001-waers.

*     Wenn falsche Kopfzeile, dann besorge Buchungskreis von DB.
      ELSE. " t001k-bukrs <> t001-bukrs.
        SELECT SINGLE * FROM t001
               WHERE bukrs = t001k-bukrs.
*       Übernehme den BUKRS-Kreditkontrollbereich.
        pe_filia_const-kkber = t001-kkber.

*       Übernehme die Buchungskreiswährung
        pe_filia_const-waers = t001-waers.

      ENDIF. " t001k-bukrs = t001-bukrs.
    ENDIF. " t001k-bwkey = pe_filia_const-bwkey.

* Falls Fehler auftraten.
  ELSEIF sy-subrc <> 0 OR i_twpfi-vzeit = 0.
    IF sy-subrc <> 0.
*     Zwischenspeichern des Returncodes.
      pe_fehlercode = sy-subrc.
    ELSE. " sy-subrc = 0.
*     Setze Fehlercode auf "fehlerhaft".
      pe_fehlercode = 3.
    ENDIF." sy-subrc <> 0.

*   Aufbereiten der Parameter zum schreiben der Status-Kopfzeile.
    CLEAR: gi_status_header.
    gi_status_header-empfn = pe_filia_const-kunnr.
    gi_status_header-systp = c_pos_systemtyp.
    gi_status_header-ersab = pi_erstdat.
    gi_status_header-ersbi = pi_erstdat.
    gi_status_header-erzab = pi_erstzeit.
    gi_status_header-erzbi = pi_erstzeit.
    gi_status_header-gesst = c_status_fehlende_idocs.
    gi_status_header-dlmod = pi_mode.

*   Schreibe Status-Kopfzeile.
    PERFORM status_write_head USING  ' '  gi_status_header  px_dldnr
                                          fehlercode.

*   Falls noch keine Initialisierung des allgemeinen Fehlerprotokolls.
    IF g_init_log_dld = space.
*     Aufbereitung der Parameter zum schreiben des Headers des
*     Fehlerprotokolls.
      CLEAR: gi_errormsg_header.
      gi_errormsg_header-object    = c_applikation.
      gi_errormsg_header-subobject = c_download.
      gi_errormsg_header-aluser    = sy-uname.

*     Initialisiere Fehlerprotokoll und erzeuge Header.
      CALL FUNCTION 'APPL_LOG_INIT'
        EXPORTING
          object              = c_applikation
          subobject           = c_download
        EXCEPTIONS
          object_not_found    = 01
          subobject_not_found = 02.

*     Setze Zeitstempel für Nachricht.
      gi_errormsg_header-aldate = sy-datum.
      gi_errormsg_header-altime = sy-uzeit.

*     Erzeuge Nachrichten-Header.
      CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
        EXPORTING
          header              = gi_errormsg_header
        EXCEPTIONS
          object_not_found    = 01
          subobject_not_found = 02.

*     Merke, daß allgemeines Fehlerprotokoll initialisiert wurde.
      g_init_log_dld = 'X'.
    ENDIF. " g_init_log_dld = space.

*   Bereite Parameter zum schreiben der Fehlerzeile auf.
    CLEAR: gi_message.
    gi_message-msgty     = c_msgtp_error.
    gi_message-msgid     = c_message_id.
    gi_message-probclass = c_probclass_sehr_wichtig.

    IF pe_fehlercode < 3.
*     'Kein Kommunikationsprofil für Filiale & gepflegt'.
      gi_message-msgno     = '110'.
      gi_message-msgv1     = pi_filia.
    ELSEIF pe_fehlercode = 3.
*     'Die Vorlaufzeit für Filiale & wurde nicht gepflegt'.
      gi_message-msgno     = '148'.
      gi_message-msgv1     = pi_filia.
    ENDIF. " pe_fehlercode < 3.

*   Schreibe Fehlerzeile.
    CALL FUNCTION 'APPL_LOG_WRITE_SINGLE_MESSAGE'
      EXPORTING
        object              = c_applikation
        subobject           = c_download
        message             = gi_message
        update_or_insert    = c_insert
      EXCEPTIONS
        object_not_found    = 01
        subobject_not_found = 02.

  ENDIF.      " sy-subrc = 0 and i_twpfi-vzeit <> 0.


ENDFORM.                               " FILIA_CONST_GET


*eject
************************************************************************
FORM idoc_create
     USING    pxt_idoc_data      TYPE      short_edidd
              pi_mestype         LIKE      edimsg-mestyp
              pi_doctype         LIKE      edimsg-idoctyp
              px_segment_counter LIKE      g_segment_counter
              pi_err_counter     LIKE      g_err_counter
              pi_firstkey        LIKE      wdlsp-stkey
              pi_lastkey
              pi_dldnr           LIKE      wdls-dldnr
              pi_dldlfdnr        LIKE      wdlsp-lfdnr
              pi_filia           LIKE      t001w-werks
              pi_filia_const     STRUCTURE wpfilconst.
************************************************************************
* FUNKTION:
* Erzeuge IDOC.
* ----------------------------------------------------------------------
* PARAMETER:
*
* PXT_IDOC_DATA     : Tabelle der IDOC-Daten.

* PI_DOCTYPE        : Name der Original Zwischenstruktur.

* PI_MESTYPE        : Logischer Nachrichtentyp.

* PX_SEGMENT_COUNTER: Segmentzähler

* PI_ERR_COUNTER    : Zähler für Fehlermeldungen

* PI_FIRSTKEY       : Erster Key des IDOC's

* PI_LASTKEY        : Letzter Key des IDOC's

* PI_DLDNR          : Downloadnummer

* PI_DLDLFDNR       : Laufende Nummer für Status-Positionszeile

* PI_FILIA          : Empfängerfiliale (identisch der Partnernummer
*                     des Empfängers).
* PI_FILIA_CONST    : Filialkonstanten
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_subrc LIKE sy-subrc,
        dref    TYPE REF TO pos_short_edidd.

  DATA: BEGIN OF edi_head.
      INCLUDE STRUCTURE edidc.
  DATA: END OF edi_head.

  DATA: BEGIN OF t_docnum OCCURS 0.
      INCLUDE STRUCTURE edidc.
  DATA: END OF t_docnum.

  DATA: BEGIN OF t_wdlsp OCCURS 0.
      INCLUDE STRUCTURE wdlsp.
  DATA: END OF t_wdlsp.

  DATA: i_edidd TYPE edidd,
        t_edidd TYPE edidd OCCURS 0.

  FIELD-SYMBOLS: <f> TYPE pos_short_edidd.

* Provide metadata for mapper class for long material numbers
  STATICS st_fnames TYPE cl_matnr_chk_mapper=>tt_matnr_idoc_fname.


* Falls Simulationsmodus, dann kein DB-Update ==> Operation abbrechen.
  IF NOT g_simulation IS INITIAL.
*   Zurücksetzen der IDOC-Datentabelle.
    CLEAR:   pxt_idoc_data.
    REFRESH: pxt_idoc_data.

*   Zurücksetzen des Segmentzählers.
    CLEAR: px_segment_counter, g_status_pos.

*   Keine weitere Bearbeitung nötig.
    EXIT.
  ENDIF. " not g_simulation is initial.


* Füllen des Versendekopfes.
  CLEAR: edi_head.
  edi_head-idoctp = pi_doctype.        " Name der Original-Zwischenstr.
  edi_head-mestyp = pi_mestype.        " Logischer Nachrichtentyp
  edi_head-cimtyp = ' '.               " Erweiterter Nachrichtentyp

* Falls nicht über das Verteilungsmodell versendet werden soll, dann
* gebe den Empfänger mit.
  IF pi_filia_const-recdt = space
     AND NOT ( pi_filia_const-kunnr IS INITIAL ).
*  ## CSP 0120001706 0001170978 1997
*     take Customer number instead of plant number for idoc receiver
    edi_head-rcvprn = pi_filia_const-kunnr.  " Partnernr. des Empfängers

    edi_head-rcvprt = c_kunde.           " Partnerart des Empfängers
    edi_head-rcvpfc = ' '.               " Partnerrolle des Empfängers
  ENDIF. " pi_filia_const-recdt = space and ...

************************************************************************
* Damit über EDI anstatt über RFC versendet wird, muß in den
* Partnervereinbarungen (Transaktion SBPT) eine entsprechende
* Einstellung vorgenommen werden.
************************************************************************

* Übernehme die IDOC-Daten in eine interne Tabelle mit anderer Strukur.
  LOOP AT pxt_idoc_data REFERENCE INTO dref.
    i_edidd-segnam = dref->segnam.
    i_edidd-sdata  = dref->sdata.
    APPEND i_edidd TO t_edidd.
  ENDLOOP. " at pxt_idoc_data reference into dref

* Erzeuge IDOC.
ENHANCEMENT-POINT saplwpda_g2 SPOTS es_saplwpda.

  IF st_fnames IS INITIAL.
    st_fnames = VALUE #( ( segname = 'E1WPE01' seg_fields = VALUE #( int = 'ARTIKELNR' long = 'ARTIKELNR_LONG' ) )
                         ( segname = 'E1WPS01' seg_fields = VALUE #( int = 'SETNR' long = 'SETNR_LONG' ) )
                         ( segname = 'E1WPS02' seg_fields = VALUE #( int = 'ARTIKELNR' long = 'ARTIKELNR_LONG' ) )
                         ( segname = 'E1WPN02' seg_fields = VALUE #( int = 'ARTIKELNR' long = 'ARTIKELNR_LONG' ) )
                         ( segname = 'E1WPBB02' seg_fields = VALUE #( int = 'MAT_NR' long = 'MAT_NR_LONG' ) )
                         ( segname = 'E1WPBB04' seg_fields = VALUE #( int = 'MAT_NR' long = 'MAT_NR_LONG' ) )
                         ( segname = 'E1WPA01' seg_fields = VALUE #( int = 'ARTIKELNR' long = 'ARTIKELNR_LONG' ) )
                         ( segname = 'E1WPA10' seg_fields = VALUE #( int = 'DISC_MAT' long = 'DISC_MAT_LONG' ) )
                         ( segname = 'E1WPA08' seg_fields = VALUE #( int = 'ARTIKELNR' long = 'ARTIKELNR_LONG' ) )
    ).
  ENDIF.

* Mapper class for long material numbers
    cl_matnr_chk_mapper=>idoc_tables_conv_tab(
        EXPORTING
          iv_int_to_external = 'X'
          it_fnames          = st_fnames
        CHANGING
          ct_idoc_data       = t_edidd[] ).

  CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
    EXPORTING
      master_idoc_control        = edi_head
    TABLES
      communication_idoc_control = t_docnum
      master_idoc_data           = t_edidd
    EXCEPTIONS
      error_in_idoc_control      = 01
      error_writing_idoc_status  = 02
      error_in_idoc_data         = 03.
* Merken des Returncodes.
  h_subrc = sy-subrc.

  IF h_subrc = 0.
*   Entsperren der erzeugten IDOC's.
    LOOP AT t_docnum.
      CALL FUNCTION 'DEQUEUE_ES_EDIDOCE'
        EXPORTING
*         mode_edidc = 'E'
*         mandt     = sy-mandt
          docnum    = t_docnum-docnum
*         _scope    = '3'
          _synchron = 'X'.
    ENDLOOP. " at t_docnum.

  ENDIF. " h_subrc = 0.

* IDOC-Daten versenden und IDOC-Status aktualisieren.
  PERFORM idoc_data_send TABLES t_docnum.

* Lese die IDOC-Nummer des erzeugten IDOC's.
  CLEAR: t_docnum.
  READ TABLE t_docnum INDEX 1.

* Falls IDOC-Erzeugung geklappt hat.
  IF sy-subrc = 0 AND h_subrc = 0.
*   Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-lfdnr  = pi_dldlfdnr.
    gi_status_pos-docnum = t_docnum-docnum.
    gi_status_pos-stkey  = pi_firstkey.
    gi_status_pos-ltkey  = pi_lastkey.
    gi_status_pos-anseg  = px_segment_counter.
    gi_status_pos-anloz  = pi_err_counter.
    gi_status_pos-vsest  = t_docnum-status.

*   Falls über das Verteilungsmodell versendet werden soll,
*   dann zusätzliches Abspeichern des empfangenden Systems.
    IF pi_filia_const-recdt <> space.
      gi_status_pos-rcvsystem = t_docnum-rcvprn.
    ENDIF. " pi_filia_const-recdt <> space.

*   Falls keine Fehler aufgetreten sind, setze Positionszeilenstatus
*   auf OK.
    IF g_status_pos = 0.
      gi_status_pos-gesst = c_status_ok.
    ENDIF. " g_status_pos = 0.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                   g_returncode.
*   Aktualisiere IDOC-Zähler
    ADD 1 TO g_idoc_counter.

*   Falls über das Verteilungsmodell versendet werden soll,
*   dann zusätzliches Abspeichern von je einer Position pro
*   empfangenden Systems.
    IF pi_filia_const-recdt <> space.
*     Abspeichern der zusätzlichen Positionen in WDLSP.
      CALL FUNCTION 'DOWNLOAD_STATUS_POSITIONS_APPD'
        EXPORTING
          pi_i_wdlsp = gi_status_pos
        TABLES
          pi_t_edidc = t_docnum
          pe_t_wdlsp = t_wdlsp
        EXCEPTIONS
          OTHERS     = 1.

*     Aktualisiere Statistiktabelle
      LOOP AT t_wdlsp.
        APPEND t_wdlsp TO gt_wdlsp_buf.
      ENDLOOP. " at t_wdlsp.
    ENDIF. " pi_filia_const-recdt <> space.

*   Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
    CLEAR: gi_status_header.
    gi_status_header-dldnr = pi_dldnr.
    gi_status_header-anzid = g_idoc_counter.
    gi_status_header-eerzt = sy-uzeit.

*   Schreibe Status-Kopfzeile.
    PERFORM status_write_head USING  'X'  gi_status_header  pi_dldnr
                                          g_returncode.

*   Schreibe Fehlerprotokoll auf DB, falls nötig.
    IF g_init_log <> space.
*     Schreibe Fehlermeldungen auf Datenbank.
      PERFORM appl_log_write_to_db.
    ENDIF. " g_init_log <> space.

*   Falls eine Initialisierung vorliegt.
    IF gi_status_header-dlmod = c_init_mode.
*--- optimization for MARA: control refreshment of MARA buffer
      IF gv_mara_buffer_refresh = abap_true.
*     Lösche internen MARA-Buffer.
        CALL FUNCTION 'MARA_ARRAY_READ'
          EXPORTING
            kzrfb                = 'X'
          EXCEPTIONS
            enqueue_mode_changed = 1
            OTHERS               = 2.
      ENDIF.

    ENDIF. " gi_status_header-dlmod = c_init_mode.


*   Lösche internen MARC-Buffer.
*--- optimization for MARC: control refreshment of MARC buffer
    IF gv_marc_buffer_refresh = abap_true.
      CALL FUNCTION 'MARC_ARRAY_READ'
        EXPORTING
          kzrfb                = 'X'
        EXCEPTIONS
          enqueue_mode_changed = 1
          lock_on_marc         = 2
          lock_system_error    = 3
          OTHERS               = 4.
    ENDIF.

* Falls Fehler bei der IDOC-Erzeugung aufgetreten sind.
  ELSE.                " sy-subrc <> 0 or h_subrc <> 0.
*   Falls Fehlerprotokollierung erwünscht.
    IF pi_filia_const-ermod = space.
*     Falls noch keine Initialisierung des Fehlerprotokolls.
      IF g_init_log = space.
*       Aufbereitung der Parameter zum schreiben des Headers des
*       Fehlerprotokolls.
        CLEAR: gi_errormsg_header.
        gi_errormsg_header-object        = c_applikation.
        gi_errormsg_header-subobject     = c_subobject.
        gi_errormsg_header-extnumber     = pi_dldnr.
        gi_errormsg_header-extnumber+14  = pi_dldlfdnr.
        gi_errormsg_header-aluser        = sy-uname.

*       Initialisiere Fehlerprotokoll und erzeuge Header.
        PERFORM appl_log_init_with_header  USING gi_errormsg_header.

*       Merke, daß Fehlerprotokoll initialisiert wurde.
        g_init_log = 'X'.
      ENDIF.                           " G_INIT_LOG = SPACE.

*     Bereite Parameter zum schreiben der Fehlerzeile auf.
      CLEAR: gi_message.
      gi_message-msgty     = c_msgtp_error.
      gi_message-msgid     = c_message_id.
      gi_message-probclass = c_probclass_sehr_wichtig.
*     'Für Status-ID & und Positionsnr. & konnte kein IDOC
*      erzeugt werden'.
      gi_message-msgno     = '105'.
      gi_message-msgv1     = pi_dldnr.
      gi_message-msgv2     = pi_dldlfdnr.

*     Schreibe Fehlerzeile für Application-Log und WDLSO.
      g_object_key = c_whole_idoc.
      PERFORM appl_log_write_single_message USING  gi_message.

    ENDIF.   " pi_filia_const-ermod = space.

*   Ändern der Status-Kopfzeile, falls nötig.
    IF g_status < 4.                   " 'Fehlende IDOC's'
      CLEAR: gi_status_header.
      gi_status_header-dldnr = pi_dldnr.
      gi_status_header-gesst = c_status_fehlende_idocs.

*     Korrigiere Status-Kopfzeile auf "Fehlerhaft".
      PERFORM status_write_head USING  'X'  gi_status_header  pi_dldnr
                                       g_returncode.

*     Aktualisiere Aufbereitungsstatus.
      g_status = 4.                    " 'Fehlende IDOC's'

    ENDIF. " G_STATUS < 4.  " 'Fehlende IDOC's'

*   Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
    CLEAR: gi_status_pos.
    gi_status_pos-dldnr  = pi_dldnr.
    gi_status_pos-lfdnr  = pi_dldlfdnr.
    gi_status_pos-docnum = t_docnum-docnum.
    gi_status_pos-anloz  = pi_err_counter.
    gi_status_pos-anseg  = px_segment_counter.
    gi_status_pos-stkey  = pi_firstkey.
    gi_status_pos-ltkey  = pi_lastkey.
    gi_status_pos-gesst  = c_status_fehlende_idocs.
    gi_status_pos-vsest  = t_docnum-status.

*   Schreibe Status-Positionszeile.
    PERFORM status_write_pos USING 'X' gi_status_pos  pi_dldlfdnr
                                       g_returncode.

*   Schreibe Fehlermeldungen auf Datenbank.
    PERFORM appl_log_write_to_db.

*   Falls Abbruch bei Fehler erwünscht.
    IF pi_filia_const-ermod <> space.
*     Falls das IDOC normal aufbereitet werden sollte.
      IF g_idoc_copy = space.
*       Abbruch des Downloads.
        RAISE download_exit.
*     Falls das IDOC kopiert werden sollte.
      ELSE. " g_idoc_copy <> space.
        RAISE error_code_1.
      ENDIF. " g_idoc_copy = space.
    ENDIF.                             " pi_filia_const-ERMOD <> SPACE.
  ENDIF.                               " sy-subrc = 0 and h_subrc = 0.

* Aktualisiere Statistiktabelle
* append wdlsp to gt_wdlsp_buf.

* Zurücksetzen der IDOC-Datentabelle.
  CLEAR:   pxt_idoc_data.
  REFRESH: pxt_idoc_data.

* Zurücksetzen des Segmentzählers.
  CLEAR: px_segment_counter, g_status_pos.

* Schreibe DB-Änderungen fort.
  COMMIT WORK.


ENDFORM.                               " IDOC_CREATE


*eject
************************************************************************
FORM time_range_get
     USING  pi_datum_ab  LIKE wpstruc-datum
            pi_datum_bis LIKE wpstruc-datum
            pi_vzeit     LIKE twpfi-vzeit
            pi_fabkl     LIKE t001w-fabkl
            pe_datab     LIKE syst-datum
            pe_datbis    LIKE syst-datum
            pi_erstdat   LIKE syst-datum.
************************************************************************
* FUNKTION:                                                            *
* Berechnet den Anfang und das Ende des Betrachtungszeitraums          *
* unter Berücksichtung des Fabrikkalenders.                            *
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_DATUM_AB : Gewünschter Betrachtunszeitraumbeginn des Benutzers
*               ohne Berücksichtung des Fabrikkalenders.
* PI_DATUM_BIS: Gewünschtes Betrachtunszeitraumende des Benutzers
*               ohne Berücksichtung des Fabrikkalenders.
* PI_VZEIT    : Vorlaufzeit der Filiale.

* PI_FABKL    : Fabrikkalender der Filiale.

* PE_DATAB    : Berechneter Betrachtunszeitraumbeginn.

* PE_DATBIS   : Berechnetes Betrachtunszeitraumende.

* PI_ERSTDAT  : Datum, an dem der Download begann.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_datum LIKE sy-datum.


  IF pi_datum_ab IS INITIAL.
    pe_datab = pi_erstdat.
  ELSE.
    pe_datab = pi_datum_ab.
  ENDIF.                               " PI_DATUM_AB = '00000000'.

* Besorge das Datum des ersten Versendetages über Fabrikkalender.
  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      correct_option             = c_vorzeichen
      date                       = pe_datab
      factory_calendar_id        = pi_fabkl
    IMPORTING
      date                       = h_datum
      factorydate                = g_factorydate
    EXCEPTIONS
      date_after_range           = 01
      date_before_range          = 02
      date_invalid               = 03
      factory_calendar_not_found = 04.

  IF sy-subrc = 0.
    pe_datab = h_datum.

    IF pi_datum_bis IS INITIAL.
      g_factorydate = g_factorydate + pi_vzeit - 1.

*     Umrechnung des berechneten Arbeistages in Kalenderdatum.
      CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
        EXPORTING
          factorydate                  = g_factorydate
          factory_calendar_id          = pi_fabkl
        IMPORTING
          date                         = pe_datbis
        EXCEPTIONS
          calendar_buffer_not_loadable = 01
          factorydate_after_range      = 02
          factorydate_before_range     = 03
          factorydate_invalid          = 04
          factory_calendar_id_missing  = 05
          factory_calendar_not_found   = 06.

      IF sy-subrc <> 0.
        pe_datbis = pe_datab + pi_vzeit - 1.
      ENDIF.                           " SY-SUBRC <> 0.

    ELSE.                              " PI_DATUM_BIS IS (NOT) INITIAL.
*     Besorge das Datum des letzten Versendetages über Fabrikkalender.
      pe_datbis = pi_datum_bis.
      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          correct_option             = c_vorzeichen
          date                       = pe_datbis
          factory_calendar_id        = pi_fabkl
        IMPORTING
          date                       = h_datum
*         FACTORYDATE                = G_FACTORYDATE
*         WORKINGDAY_INDICATOR       = DOPTION
        EXCEPTIONS
          date_after_range           = 01
          date_before_range          = 02
          date_invalid               = 03
          factory_calendar_not_found = 04.

      IF sy-subrc = 0.
        pe_datbis = h_datum.
      ENDIF.                           " SY-SUBRC = 0.

    ENDIF.                             " PI_DATUM_BIS IS INITIAL
* Falls keine Datumsbestimmung über Fabrikkalender möglich ist.
  ELSE.                                " SY-SUBRC <> 0.
    IF pi_datum_bis IS INITIAL.
      pe_datbis = pe_datab + pi_vzeit - 1.
    ELSE.                              " PI_DATUM_BIS IS (NOT) INITIAL.
      pe_datbis = pi_datum_bis.
    ENDIF.                             " PI_DATUM_BIS IS INITIAL
  ENDIF.                               " SY-SUBRC = 0.

ENDFORM.                               " TIME_RANGE_GET


*eject.
************************************************************************
FORM org_tab_init TABLES pet_org_tab
                  USING  pi_datab LIKE wpstruc-datum
                         pi_datbi LIKE wpstruc-datum.
************************************************************************
* FUNKTION:
* Fülle Organisationstabelle mit Leerzeilen. Für jeden Tag des
* Zeitintervalls eine Leerzeile.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_ORG_TAB: Organisationstabelle.

* PI_DATAB   : Beginn des Zeitintervalls.

* PI_DATBI   : Ende des Zeitintervalls.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: diff_zeit TYPE i,
        datum     LIKE sy-datum.

  FIELD-SYMBOLS: <datum>.


* Ausgabetabelle initialisieren.
  CLEAR:   pet_org_tab.
  REFRESH: pet_org_tab.

  diff_zeit = pi_datbi - pi_datab.
  ADD 1 TO diff_zeit.
  ASSIGN pet_org_tab(8) TO <datum>.

  datum = pi_datab - 1.
  DO diff_zeit TIMES.
    datum = datum + 1.
    <datum> = datum.
    APPEND pet_org_tab.
  ENDDO.                               " DIFF_ZEIT TIMES.


ENDFORM.                               " ORG_TAB_INIT


*eject.
************************************************************************
FORM workdays_get
     TABLES pet_workdays STRUCTURE gt_workdays
     USING  pi_datab     LIKE syst-datum
            pi_datbi     LIKE syst-datum
            pi_fabkl     LIKE t001w-fabkl.
************************************************************************
* FUNKTION:
* Bestimme alle Arbeitstage innerhalb des Betrachtungszeitraums
* PI_DATAB bis PI_DATBI.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_WORKDAYS: Tabelle der ermittelten Arbeitstage.

* PI_DATAB    : Beginn des Zeitintervalls.

* PI_DATBI    : Ende des Zeitintervalls.

* PI_FABKL    : Zu verwendender Fabrikkalender.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: diff_zeit TYPE i,
        datum     LIKE sy-datum,
        h_datum   LIKE sy-datum.

* Prüfe, ob Arbeitstage neu bestimmt werden müssen.
  IF pi_datab <> gi_workdays-datab OR
     pi_datbi <> gi_workdays-datbi OR
     pi_fabkl <> gi_workdays-fabkl.

*   Merken der neuen Parameter für Arbeitstagberechnung.
    gi_workdays-datab = pi_datab.
    gi_workdays-datbi = pi_datbi.
    gi_workdays-fabkl = pi_fabkl.

*   Rücksetze Tabelle der Arbeitstage.
    REFRESH: pet_workdays.
    CLEAR:   pet_workdays.

*   Erzeuge Leerzeile mit Datum für jeden Tag des
*   Betrachtungszeitraums.
    diff_zeit = pi_datbi - pi_datab.
    ADD 1 TO diff_zeit.

    datum = pi_datab - 1.
    DO diff_zeit TIMES.
      datum = datum + 1.
      pet_workdays-datum = datum.

*     Falls kein Fabrikkalender mitgegeben wurde.
      IF pi_fabkl = space.
        pet_workdays-n_workday = pet_workdays-datum.
      ENDIF.                           " PI_FABKL = SPACE.
      APPEND pet_workdays.
    ENDDO.                             " DIFF_ZEIT TIMES.

*   Falls kein Fabrikkalender mitgegeben wurde, kann die Bearbeitung
*   hier verlassen werden.
    IF pi_fabkl = space.
      EXIT.
    ENDIF.                             " PI_FABKL = SPACE.

*   Bestimme die zugehörigen 'nächsten Arbeitstage' über Fabrikkalender.
    h_datum = pi_datab - 1.
    LOOP AT pet_workdays.
*     Falls ein neuer Arbeitstag bestimmt werden muß.
      IF h_datum < pet_workdays-datum.
*       Besorge das Datum des nächsten Arbeitstages über
*       Fabrikkalender.
        CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
          EXPORTING
            correct_option             = c_vorzeichen
            date                       = pet_workdays-datum
            factory_calendar_id        = pi_fabkl
          IMPORTING
            date                       = datum
          EXCEPTIONS
            date_after_range           = 01
            date_before_range          = 02
            date_invalid               = 03
            factory_calendar_not_found = 04.

        IF sy-subrc = 0.
          pet_workdays-n_workday = datum.
          MODIFY pet_workdays.
          h_datum = datum.
*       Falls ein falscher Fabrikkalender mitgegeben wurde.
        ELSE.                          " SY-SUBRC <> 0.
          pet_workdays-n_workday = pet_workdays-datum.
          MODIFY pet_workdays.

*         Sicherstellen, daß beim nächsten Aufruf dieser FORM-Routine
*         die Arbeitstage neu berechnet werden.
          MOVE space TO gi_workdays-datab.
        ENDIF.                         " SY-SUBRC = 0.

*     Falls kein neuer Arbeitstag bestimmt werden muß.
      ELSE.                            " H_DATUM >= PET_WORKDAYS-DATUM.
        pet_workdays-n_workday = h_datum.
        MODIFY pet_workdays.
      ENDIF.                           " H_DATUM < PET_WORKDAYS-DATUM.
    ENDLOOP.                           " AT PET_WORKDAYS.
  ENDIF. " PI_DATAB <> GI_WORKDAYS-DATAB OR ...


ENDFORM.                               " WORKDAYS_GET


*eject
************************************************************************
FORM next_workday_get
     TABLES pit_workdays STRUCTURE gt_workdays
     USING  pi_datum     LIKE syst-datum
            pe_arbtag    LIKE syst-datum.
************************************************************************
* FUNKTION:                                                            *
* Liest von PI_DATUM ausgehend den nächsten Arbeitstag
* aus Tabelle PIT_WORKDAYS.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WORKDAYS: Tabelle der Arbeitstage des Betrachtungszeitraums.

* PI_DATUM    : Datum, zu dem der Arbeitstag bestimmt werden soll.

* PE_ARBTAG   : Berechneter nächster Arbeitstag
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Besorge das Datum des ersten Versendetages über Fabrikkalender.
  READ TABLE pit_workdays WITH KEY pi_datum BINARY SEARCH.
  pe_arbtag = pit_workdays-n_workday.

ENDFORM.                               " NEXT_WORKDAY_GET


*eject
************************************************************************
FORM status_write_pos
     USING  pi_item_update TYPE c
            pi_status_pos  STRUCTURE gi_status_pos
            pe_dldlfdnr    LIKE wdlsp-lfdnr
            pe_fehlercode  LIKE g_returncode.
************************************************************************
* FUNKTION:                                                            *
* Schreibe Status-Positionszeile.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_ITEM_UPDATE: = ' ', wenn neue Positionszeile,
*                 sonst 'X' für Update.
* PI_STATUS_POS : Daten der Positionszeile.

* PE_DLDLFDNR   : Nr. der Positionszeile.

* PE_FEHLERCODE : = 0, wenn keine Fehler aufgetreten sind, sons > 0.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Falls Simulationsmodus, dann kein DB-Update ==> Operation abbrechen.
  IF NOT g_simulation IS INITIAL.
    EXIT.
  ENDIF. " not g_simulation is initial.

  CALL FUNCTION 'DOWNLOAD_STATUS_WRITE'
    EXPORTING
      pi_item_update = pi_item_update
*     PI_I_WDLS      = ''
      pi_i_wdlsp     = pi_status_pos
    IMPORTING
      pe_lfdnr       = pe_dldlfdnr
      pe_i_wdlsp     = wdlsp
    EXCEPTIONS
      no_insert      = 01
      no_item_insert = 02
      no_item_update = 03
      no_update      = 04.

* Falls Fehler auftraten.
  IF sy-subrc <> 0.
    pe_fehlercode = sy-subrc.
* Falls keine Fehler auftraten.
  ELSE. "  sy-subrc = 0.
*   Prüfe, ob der Eintrag der Status-Positionszeile bereits
*   gemerkt wurde.
    READ TABLE gt_wdlsp_buf WITH KEY
         dldnr  = wdlsp-dldnr
         lfdnr  = wdlsp-lfdnr.

*   Aktualisiere Eintrag der Status-Positionszeile.
    gt_wdlsp_buf = wdlsp.

    IF sy-subrc = 0.
      MODIFY gt_wdlsp_buf INDEX sy-tabix.
    ELSE.
      APPEND gt_wdlsp_buf.
    ENDIF. " sy-subrc = 0.
  ENDIF.                               " SY-SUBRC <> 0.


ENDFORM.                               " STATUS_WRITE_POS


*eject
************************************************************************
FORM status_write_head
     USING pi_item_update TYPE c
           px_status_head STRUCTURE gi_status_header
           pe_dldnr       LIKE wdls-dldnr
           pe_fehlercode  LIKE g_returncode.
************************************************************************
* FUNKTION:                                                            *
* Schreibe Status-Kopfzeile.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_ITEM_UPDATE: = ' ', wenn neue Kopfzeile, sonst 'X' für Update.

* PX_STATUS_HEAD: Daten der Kopf-Zeile.

* PE_DLDNR      : Downloadnummer der Kopfzeile.

* PE_FEHLERCODE : = 0, wenn keine Fehler aufgetreten sind, sons > 0.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Falls Simulationsmodus, dann kein DB-Update ==> Operation abbrechen.
  IF NOT g_simulation IS INITIAL.
    EXIT.
  ENDIF. " not g_simulation is initial.

  CALL FUNCTION 'DOWNLOAD_STATUS_WRITE'
    EXPORTING
      pi_item_update = pi_item_update
      pi_i_wdls      = px_status_head
*     PI_I_WDLSP     = ''
    IMPORTING
      pe_dldnr       = pe_dldnr
      pe_i_wdls      = px_status_head
    EXCEPTIONS
      no_insert      = 01
      no_item_insert = 02
      no_item_update = 03
      no_update      = 04.

  IF sy-subrc <> 0.
    pe_fehlercode = sy-subrc.
  ENDIF.                               " SY-SUBRC <> 0.


ENDFORM.                               " STATUS_WRITE_HEAD


*eject
************************************************************************
FORM appl_log_init_with_header
              USING  pi_header STRUCTURE gi_errormsg_header.
************************************************************************
* FUNKTION:                                                            *
* Initialisiere Fehlerprotokoll und schreibe Header.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_HEADER: Headerzeile des Fehlerprotokolls.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  CALL FUNCTION 'APPL_LOG_INIT'
    EXPORTING
      object              = c_applikation
      subobject           = c_subobject
    EXCEPTIONS
      object_not_found    = 01
      subobject_not_found = 02.

* Setze Zeitstempel für Nachricht.
  pi_header-aldate = sy-datum.
  pi_header-altime = sy-uzeit.

* Speichere aktuellen IDOC-Typ im Headerfeld Benutzer ab.
* Dies ist wichtig für Parallelverarbeitung, damit eine eindeutige
* Zuordnung erfolgen kann.
  pi_header-aluser = g_current_doctype(6).

* Erzeuge Nachrichten-Header.
  CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
    EXPORTING
      header              = pi_header
    EXCEPTIONS
      object_not_found    = 01
      subobject_not_found = 02.


ENDFORM.                               " APPL_LOG_INIT_WITH_HEADER


*eject
************************************************************************
FORM appl_log_write_single_message
                    USING pi_message STRUCTURE gi_message.
************************************************************************
* FUNKTION:                                                            *
* Schreibe einzelne Fehlernachricht ins lokale Gedächtnis des
* Application-Logs und erweitere das lokale Gedächtnis der
* Fehlerobjekttabelle WDLSO für späteren Restart.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_MESSAGE: Nachrichtenzeile des Fehlerprotokolls.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  CALL FUNCTION 'APPL_LOG_WRITE_SINGLE_MESSAGE'
    EXPORTING
      object              = c_applikation
      subobject           = c_subobject
      message             = pi_message
      update_or_insert    = c_insert
    EXCEPTIONS
      object_not_found    = 01
      subobject_not_found = 02.

* Aktualisiere Zähler für Fehlermeldungen.
  ADD 1 TO g_err_counter.

* Erweitere das lokale Gedächtnis der Fehlerobjekttabelle WDLSO.
  PERFORM error_object_write.


ENDFORM.                               " APPL_LOG_WRITE_SINGLE_MESSAGE


*eject
************************************************************************
FORM appl_log_write_to_db.
************************************************************************
* FUNKTION:                                                            *
* Schreibe Fehlerprotokoll und die Einträge der Fehlerobjekttabelle
* WDLSO auf die Datenbank.
* ---------------------------------------------------------------------*
* PARAMETER: keine.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: object_type LIKE g_current_doctype.

  DATA: BEGIN OF t_number OCCURS 1.
      INCLUDE STRUCTURE balnri.
  DATA: END OF t_number.

* Falls Simulationsmodus, dann kein DB-Update ==> Operation abbrechen.
  IF NOT g_simulation IS INITIAL.
    EXIT.
  ENDIF. " not g_simulation is initial.

  CALL FUNCTION 'APPL_LOG_WRITE_DB'
    EXPORTING
      object                = c_applikation
      subobject             = c_subobject
    TABLES
      object_with_lognumber = t_number
    EXCEPTIONS
      object_not_found      = 01
      subobject_not_found   = 02.

* Rücksetze Log-Variablen.
  CLEAR: g_err_counter, g_init_log.

  object_type = g_current_doctype(6).

* Schreibe das lokale Gedächtnis der Fehlerobjekttabelle
* auf DB.
  CALL FUNCTION 'POS_ERROR_OBJECTS_WRITE'
    EXPORTING
      pi_store_in_buffer       = ' '
      pi_object_type           = object_type
    TABLES
      pet_wdlso_parallel       = gt_wdlso_parallel
    EXCEPTIONS
      no_records_written_to_db = 1
      wrong_input              = 2
      wrong_table_input        = 3
      OTHERS                   = 4.

ENDFORM.                               " APPL_LOG_WRITE_TO_DB


*eject
************************************************************************
FORM filia_groups_get
     TABLES pet_filia_group    STRUCTURE gt_filia_group
            pit_filia          STRUCTURE wpfilia
            pet_kondart_gesamt STRUCTURE twpek
     USING  pi_erstdat         LIKE syst-datum
            pi_erstzeit        LIKE syst-uzeit
            pi_mode            LIKE wpstruc-modus
            pi_pointer_reorg   LIKE wpstruc-modus.
************************************************************************
* FUNKTION:
* Bestimme die einzelnen Filialgruppen mit ihren jeweiligen
* filialabhängigen Konstanten. Im Restart-Fall werden zusätzlich
* noch die Daten aus der Status-Kopf- und Positionszeile besorgt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_FILIA_GROUP: Tabelle der Filial-Gruppen.

* PIT_FILIA  : Falls die Tabelle gefüllt ist, dann sollen nur diese
*              Filialen berücksichtigt werden.
* PET_KONDART_GESAMT: Tabelle aler unterschiedlichen Konditionsarten
*                     aller Filialen. Wird nur bei Pointer-Reorg
*                     gefüllt.
* PI_DATBI   : Datum bis zu dem die Berechnung vorgenommen wird.

* PI_ERSTDAT : Beginndatum des Downloads.

* PI_ERSTZEIT: Beginnzeit des Downloads.

* PI_MODE    : Download-Modus: = 'U', wenn Änderungsfall.
*              Die übrigen Modusse werden hier nicht mehr benötigt.
* PI_POINTER_REORG: = 'X', wenn Pointer-Reorg erwünscht, sonst SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: counter     TYPE i,
        fehlercode  LIKE sy-index,
        h_readindex LIKE sy-tabix,
        tabix       LIKE sy-tabix,
        filia_only.

* Dummy für das Schreiben von Fehlermeldungen
  DATA: BEGIN OF t_number OCCURS 1.
      INCLUDE STRUCTURE balnri.
  DATA: END OF t_number.

  DATA: BEGIN OF i_twpfi.
      INCLUDE STRUCTURE twpfi.
  DATA: END OF i_twpfi.

  DATA: BEGIN OF i_key1,
          zeitdiff LIKE gt_filia_group-zeitdiff,
          kopro    LIKE gt_filia_group-meper,
          vkorg    LIKE gt_filia_group-vkorg,
          vtweg    LIKE gt_filia_group-vtweg.
  DATA: END OF i_key1.

  DATA: BEGIN OF i_key2.
      INCLUDE STRUCTURE i_key1.
  DATA: END OF i_key2.

  DATA: BEGIN OF t_wdls OCCURS 100.    " Status-Kopfzeilen
      INCLUDE STRUCTURE wdls.
  DATA: END OF t_wdls.

  DATA: BEGIN OF t_kunnr OCCURS 500.   " Selektionstabelle für KUNNR's.
      INCLUDE STRUCTURE wdl_kunnr.
  DATA: END OF t_kunnr.

  DATA: BEGIN OF t_filia_kopro OCCURS 500. " Tabelle für Kopro's
      INCLUDE STRUCTURE wpfilkopro.
  DATA: END OF t_filia_kopro.

  DATA: BEGIN OF t_t001w OCCURS 500.   " Tabelle für Filialstammdaten
      INCLUDE STRUCTURE t001w.
  DATA: END OF t_t001w.

  DATA: BEGIN OF t_filia_const OCCURS 100, " Tab. für Filialkonstanten
          filia LIKE wdls-empfn,
          vkorg LIKE t001w-vkorg,
          vtweg LIKE t001w-vtweg,
          spras LIKE t001w-spras,
          spart LIKE t001w-spart,
          bwkey LIKE t001w-bwkey,
          land1 LIKE t001w-land1,
          kunnr LIKE t001w-kunnr,
          fabkl LIKE t001w-fabkl,
          kopro LIKE twpfi-kopro.
  DATA: END OF t_filia_const.

* Tabelle für Kommunikationsprofile. Nur für Pointer-Reorg.
  DATA: BEGIN OF t_twpfi OCCURS 10.
      INCLUDE STRUCTURE twpfi.
  DATA: END OF t_twpfi.

* Initialisieren der internen Tabellen.
  REFRESH: pet_filia_group, t_kunnr, t_wdls, t_filia_const,
           t_filia_kopro.
  CLEAR:   pet_filia_group, t_kunnr, t_wdls, t_filia_const,
           t_filia_kopro.

* Besorge alle POS-relevanten Filialen.
  CALL FUNCTION 'POS_FILIA_GET'
    EXPORTING
      pi_with_t001w_data = 'X'
    TABLES
      pet_kunnr          = t_kunnr
      pet_filia_kopro    = t_filia_kopro
      pet_t001w          = t_t001w
    EXCEPTIONS
      no_data_found      = 01.

* Prüfe, ob nur bestimmte Filialen berücksichtigt werden sollen.
  READ TABLE pit_filia INDEX 1.

* Falls nur bestimmte Filialen berücksichtigt werden sollen, dann
* setze Merker.
  IF sy-subrc = 0.
    filia_only = 'X'.

*   Sortiere Daten.
    SORT pit_filia BY filia.

*   Beschränke t_kunnr auf übergebene Menge.
    REFRESH: t_kunnr.
    LOOP AT pit_filia.
      READ TABLE t_t001w WITH KEY
           werks = pit_filia-filia
           BINARY SEARCH.
      IF sy-subrc = 0 AND t_t001w-achvm IS INITIAL .
        t_kunnr-empfn = t_t001w-kunnr.
        APPEND t_kunnr.
      ELSE.
        DELETE pit_filia.
      ENDIF.

    ENDLOOP. " at pit_filia.
  ENDIF. " sy-subrc = 0.

  h_readindex = 1.
  LOOP AT t_t001w.
*   Merke SY-TABIX.
    tabix = sy-tabix.

*   Falls alle Filialen berücksichtigt werden sollen.
    IF filia_only = space.
*     Fülle Filialkonstanten in temporäre Tabelle.
      MOVE-CORRESPONDING t_t001w TO t_filia_const.
      MOVE t_t001w-werks TO t_filia_const-filia.

*     Übernehme Kommunikationsprofil.
      READ TABLE t_filia_kopro INDEX tabix.
      MOVE t_filia_kopro-kopro TO t_filia_const-kopro.
      APPEND t_filia_const.

*   Falls nur bestimmte Filialen berücksichtigt werden sollen.
    ELSE. " filia_only <> space.
      READ TABLE pit_filia INDEX h_readindex.
      IF sy-subrc <> 0.
        EXIT.
      ELSE. " sy-subrc = 0.
        IF t_t001w-werks = pit_filia-filia.
*         Aktualisiere Index-Variable.
          ADD 1 TO h_readindex.

*         Fülle Filialkonstanten in temporäre Tabelle.
          MOVE-CORRESPONDING t_t001w TO t_filia_const.
          MOVE t_t001w-werks TO t_filia_const-filia.

*         Übernehme Kommunikationsprofil.
          READ TABLE t_filia_kopro INDEX tabix.
          MOVE t_filia_kopro-kopro TO t_filia_const-kopro.
          APPEND t_filia_const.
        ENDIF. " t_t001w-werks = pit_filia-filia.
      ENDIF. " sy-subrc = 0.
    ENDIF. " filia_only = space.
  ENDLOOP.                           " AT T_T001W.

* Besorge die zuletzt erzeugten Kopfzeilen dieser Filialen
* mit Status OK.
  CALL FUNCTION 'DOWNLOAD_STATUS_READ'
    EXPORTING
      pi_last_only_flag     = 'X'
      pi_systp              = c_pos_systemtyp
      pi_read_edids         = 'X'
    TABLES
      pe_t_wdls             = t_wdls
      pi_t_kunnr            = t_kunnr
    EXCEPTIONS
      no_status_found       = 01
      status_item_not_found = 02
      status_not_found      = 03.

* Falls es noch keine fehlerfreie Statuszeile (Initialisierungs- oder
* Änderungsfall mit WDLS-GESST = 'X') gibt d. h., es gibt noch kein
* letztes korrektes Versenden.
  IF sy-subrc <> 0.
*   'Es hat noch kein letztes korrektes Versenden stattgefunden'.
    MESSAGE e011.
  ENDIF. " sy-subrc <> 0.
  SORT t_filia_const BY kunnr.
  LOOP AT t_wdls.

    CLEAR: pet_filia_group.

*   Übernehme filialabhängige Konstanten aus int. Tabelle.
    READ TABLE t_filia_const WITH KEY
         kunnr = t_wdls-empfn
         BINARY SEARCH.
    MOVE-CORRESPONDING t_filia_const TO pet_filia_group.

*   Bestimme das Kommunikationsprofil der Filiale.
    CLEAR: pet_filia_group-vzeit.
    CALL FUNCTION 'POS_CUST_COMM_PROFILE_READ'
      EXPORTING
        i_locnr               = t_filia_const-kunnr
        i_flag_wrf1_lesen     = ' '
        i_kopro               = t_filia_const-kopro
      IMPORTING
        o_twpfi               = i_twpfi
      EXCEPTIONS
        filiale_unbekannt     = 01
        komm_profil_unbekannt = 02.

*   Falls alles OK.
    IF sy-subrc = 0 AND i_twpfi-vzeit <> 0.
*     Eventuelle NULL-Werte einiger Flags in SPACE konvertieren.
      IF i_twpfi-promo_rebate <> 'X'.
        CLEAR: i_twpfi-promo_rebate.
      ENDIF.

      IF i_twpfi-pricing_direct <> 'X'.
        CLEAR: i_twpfi-pricing_direct.
      ENDIF.

      IF i_twpfi-pricing_direct_mult_access <> 'X'.
        CLEAR: i_twpfi-pricing_direct_mult_access.
      ENDIF.

      "clear multi access flag always in case of that the switch is turned off
      IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) = abap_false.
        CLEAR: i_twpfi-pricing_direct_mult_access.
      ENDIF.

      "clear multi access flag also in case of that the direct pricing is not activated (should not happen)
      IF i_twpfi-pricing_direct_mult_access <> 'X'.
        CLEAR: i_twpfi-pricing_direct_mult_access.
      ENDIF.

      IF i_twpfi-prices_siteindep <> 'X'.
        CLEAR: i_twpfi-prices_siteindep.
      ENDIF.

      IF i_twpfi-prices_in_a071 <> 'X'.
        CLEAR: i_twpfi-prices_in_a071.
      ELSE.
*       Setze Flag für Preiskopie.
        i_twpfi-prices_siteindep = 'X'.
      ENDIF.

*     Falls Empfängerermittlung aktiviert ist und die Trigger-Info nicht
*     via RFC verschickt werden soll, dann darf keine Trigger-Info
*     erzeugt werden.
      IF NOT i_twpfi-recdt          IS INITIAL   AND
             c_trigger_send_via_rfc IS INITIAL.
        i_twpfi-no_trigger = 'X'.
      ENDIF. " not i_twpfi-recdt is initial.

      MOVE-CORRESPONDING i_twpfi TO pet_filia_group.

*     Falls der Fabrikkalender ignoriert werden soll.
      IF NOT i_twpfi-no_fabkl IS INITIAL.
        CLEAR: pet_filia_group-fabkl.
      ENDIF. " not i_twpfi-no_fabkl is initial.

*     Bestimme die Zeitdifferenz zum letzten Versenden in Sekunden.
      PERFORM time_diff_get USING t_wdls-ersbi   t_wdls-erzbi
                                  pi_erstdat     pi_erstzeit
                                  pet_filia_group-zeitdiff.

*     Bestimme die Währung und das Kreditlimit zum Buchungskreis
*     der Filiale:
*     Bestimme mit Hilfe des Bewertungskreises den Buchungskreis
*     der Filiale. Suche zunächst in der Kopfzeile der Tabelle.
      IF t001k-bwkey = pet_filia_group-bwkey.
*       Bestimme die Buchungskreisdaten der Filiale.
*       Suche zunächst in der Kopfzeile der Tabelle.
        IF t001k-bukrs = t001-bukrs.
*         Übernehme den BUKRS-Kreditkontrollbereich.
          pet_filia_group-kkber = t001-kkber.

*         Übernehme die Buchungskreiswährung
          pet_filia_group-waers = t001-waers.

*       Wenn falsche Kopfzeile, dann besorge BUKRS-Daten von DB.
        ELSE. " t001k-bukrs <> t001-bukrs.
          SELECT SINGLE * FROM t001
                 WHERE bukrs = t001k-bukrs.
*         Übernehme den BUKRS-Kreditkontrollbereich.
          pet_filia_group-kkber = t001-kkber.

*         Übernehme die Buchungskreiswährung
          pet_filia_group-waers = t001-waers.
        ENDIF. " t001k-bukrs = t001-bukrs.

*     Wenn falsche Kopfzeile, dann besorge Buchungskreis von DB.
      ELSE. " t001k-bwkey <> pet_filia_group-bwkey.
        SELECT SINGLE * FROM t001k
               WHERE bwkey = pet_filia_group-bwkey.

*       Besorge die Buchungskreisdaten der Filiale.
*       Suche zunächst in der Kopfzeile der Tabelle.
        IF t001k-bukrs = t001-bukrs.
*         Übernehme den BUKRS-Kreditkontrollbereich.
          pet_filia_group-kkber = t001-kkber.

*         Übernehme die Buchungskreiswährung
          pet_filia_group-waers = t001-waers.

*       Wenn falsche Kopfzeile, dann besorge Buchungskreis von DB.
        ELSE. " t001k-bukrs <> t001-bukrs.
          SELECT SINGLE * FROM t001
                 WHERE bukrs = t001k-bukrs.
*         Übernehme den BUKRS-Kreditkontrollbereich.
          pet_filia_group-kkber = t001-kkber.

*         Übernehme die Buchungskreiswährung
          pet_filia_group-waers = t001-waers.

        ENDIF. " t001k-bukrs = t001-bukrs.
      ENDIF. " t001k-bwkey = pet_filia_group-bwkey.

*     Übernehme Daten aus Statustabelle.
      pet_filia_group-datab  = t_wdls-ersbi.
      pet_filia_group-timeab = t_wdls-erzbi.

*     Übernehme Preislistentyp aus Kundenstamm Vertriebsdaten (KNVV).
      CLEAR: knvv.
      SELECT SINGLE * FROM knvv
             WHERE kunnr = pet_filia_group-kunnr
             AND   vkorg = pet_filia_group-vkorg
             AND   vtweg = pet_filia_group-vtweg
             AND   spart = pet_filia_group-spart.

      IF sy-subrc = 0.
        pet_filia_group-pltyp = knvv-pltyp.
      ENDIF. " sy-subrc = 0.

*     Übernehme Währung der Kassensysteme aus WRF1
      CLEAR: wrf1.
      SELECT SINGLE * FROM wrf1
             WHERE locnr = pet_filia_group-kunnr.

      IF sy-subrc = 0.
        pet_filia_group-posws = wrf1-posws.
      ENDIF. " sy-subrc = 0.

      APPEND pet_filia_group.

*   Falls Fehler auftraten und der Simulationsmodus nicht aktiv ist.
    ELSEIF g_simulation    IS INITIAL     AND
           ( sy-subrc      <> 0 OR
             i_twpfi-vzeit =  0 ).

      CLEAR: pet_filia_group.

      IF sy-subrc <> 0.
*       Zwischenspeichern des Returncodes.
        fehlercode = sy-subrc.
      ELSE. " sy-subrc = 0.
*       Setze Fehlercode auf "fehlerhaft".
        fehlercode = 3.
      ENDIF." sy-subrc <> 0.

*     Aufbereiten der Parameter zum schreiben der Status-Kopfzeile.
      CLEAR: gi_status_header.
      gi_status_header-empfn = t_filia_const-kunnr.
      gi_status_header-systp = c_pos_systemtyp.
      gi_status_header-ersab = t_wdls-ersbi.
      gi_status_header-ersbi = pi_erstdat.
      gi_status_header-erzab = t_wdls-erzbi.
      gi_status_header-erzbi = pi_erstzeit.
      gi_status_header-gesst = c_status_fehlende_idocs.
      gi_status_header-dlmod = pi_mode.

*     Schreibe Status-Kopfzeile.
      PERFORM status_write_head USING  ' '  gi_status_header  g_dldnr
                                            g_returncode.

*     Falls noch keine Initialisierung des allgemeinen Fehlerprotokolls.
      IF g_init_log_dld = space.
*       Aufbereitung der Parameter zum schreiben des Headers des
*       Fehlerprotokolls.
        CLEAR: gi_errormsg_header.
        gi_errormsg_header-object    = c_applikation.
        gi_errormsg_header-subobject = c_download.
        gi_errormsg_header-aluser    = sy-uname.

*       Initialisiere Fehlerprotokoll und erzeuge Header.
        CALL FUNCTION 'APPL_LOG_INIT'
          EXPORTING
            object              = c_applikation
            subobject           = c_download
          EXCEPTIONS
            object_not_found    = 01
            subobject_not_found = 02.

*       Setze Zeitstempel für Nachricht.
        gi_errormsg_header-aldate = sy-datum.
        gi_errormsg_header-altime = sy-uzeit.

*       Erzeuge Nachrichten-Header.
        CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
          EXPORTING
            header              = gi_errormsg_header
          EXCEPTIONS
            object_not_found    = 01
            subobject_not_found = 02.

*       Merke, daß allgemeines Fehlerprotokoll initialisiert wurde.
        g_init_log_dld = 'X'.
      ENDIF. " g_init_log_dld = space.

*     Bereite Parameter zum schreiben der Fehlerzeile auf.
      CLEAR: gi_message.
      gi_message-msgty     = c_msgtp_error.
      gi_message-msgid     = c_message_id.
      gi_message-probclass = c_probclass_sehr_wichtig.

      IF fehlercode < 3.
*       'Kein Kommunikationsprofil für Filiale & gepflegt'.
        gi_message-msgno     = '110'.
        gi_message-msgv1     = t_filia_const-kunnr.
      ELSEIF fehlercode = 3.
*       'Die Vorlaufzeit für Filiale & wurde nicht gepflegt'.
        gi_message-msgno     = '148'.
        gi_message-msgv1     = t_filia_const-kunnr.
      ENDIF. " fehlercode < 3.

*     Schreibe Fehlerzeile.
      CALL FUNCTION 'APPL_LOG_WRITE_SINGLE_MESSAGE'
        EXPORTING
          object              = c_applikation
          subobject           = c_download
          message             = gi_message
          update_or_insert    = c_insert
        EXCEPTIONS
          object_not_found    = 01
          subobject_not_found = 02.

    ENDIF.                      " sy-subrc = 0 and i_twpfi-vzeit <> 0.
  ENDLOOP.                             " T_WDLS.

* Nummeriere die Filialgruppen.
  SORT pet_filia_group BY zeitdiff DESCENDING kopro vkorg vtweg.
  CLEAR: counter, i_key1, i_key2.
  LOOP AT pet_filia_group.
    MOVE-CORRESPONDING pet_filia_group TO i_key2.
    IF i_key1 <> i_key2.
      i_key1 = i_key2.
      ADD 1 TO counter.
    ENDIF.                             " I_KEY1 <> I_KEY2.

    pet_filia_group-group = counter.
    MODIFY pet_filia_group.
  ENDLOOP.                             " AT PET_FILIA_GROUP.

* Resortiere Daten.
  SORT pet_filia_group BY group filia.

* Falls Pointer-Reorg erwünscht.
  IF pi_pointer_reorg <> space.
*   Sortiere Tabelle mit Kommunikationsprofilschlüsseln.
    SORT t_filia_kopro BY kopro.

*   Bestimme alle unterschiedlichen Kommunikationsprofilschlüssel.
    DELETE ADJACENT DUPLICATES FROM t_filia_kopro
           COMPARING kopro.

*   Besorge die Kommunikationsprofile.
    SELECT * FROM twpfi INTO TABLE t_twpfi
           FOR ALL ENTRIES IN t_filia_kopro
           WHERE kopro = t_filia_kopro-kopro.

*   Sortieren der Daten.
    SORT t_twpfi BY ekoar.

*   Bestimme alle unterschiedlichen Typen erlaubter Konditionsarten.
    DELETE ADJACENT DUPLICATES FROM t_twpfi
           COMPARING ekoar.

*   Besorge die Gesamtmenge aller erlaubten Konditionsarten
*   aller Filialen.
    SELECT * FROM twpek INTO TABLE pet_kondart_gesamt
           FOR ALL ENTRIES IN t_twpfi
           WHERE ekoar = t_twpfi-ekoar.

*   Sortieren der Daten.
    SORT pet_kondart_gesamt BY kvewe kschl.

*   Bestmme die Gesamtmenge aller unterschiedlichen erlaubten
*   Konditionsarten aller Filialen.
    DELETE ADJACENT DUPLICATES FROM pet_kondart_gesamt
           COMPARING kvewe kschl.
  ENDIF. " pi_pointer_reorg <> space.


ENDFORM.                               " FILIA_GROUPS_GET


*eject
************************************************************************
FORM time_diff_get
     USING  pi_datab     LIKE wdls-ersbi
            pi_timeab    LIKE wdls-erzbi
            pi_datbi     LIKE syst-datum
            pi_timebi    LIKE syst-uzeit
            pe_timediff  TYPE i.
************************************************************************
* FUNKTION:
* Bestimme die zeitliche Differenz in Sekunden zwischen zwei
* Zeitpunkten.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_DATAB   : Datum von dem aus die Berechnung vorgenommen wird.

* PI_TIMEAB  : Zeit von der aus die Berechnung vorgenommen wird.

* PI_DATBI   : Datum bis zu dem die Berechnung vorgenommen wird.

* PI_TIMEBI  : Zeit bis zu der die Berechnung vorgenommen wird.

* PE_TIMEDIFF: Ergebnisdifferenz in Sekunden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: difftage  TYPE i,
        h_diffsec TYPE i.


  difftage = pi_datbi - pi_datab.

* Falls Bis-Zeit Größer oder gleich Ab-Zeit.
  IF pi_timebi >= pi_timeab.
    pe_timediff = ( pi_timebi - pi_timeab ) + ( difftage * 86400 ).
* Falls Bis-Zeit kleiner als Ab-Zeit.
  ELSE.                                " PI_TIMEBI < PI_TIMEAB.
    h_diffsec   = pi_timeab - pi_timebi.
    h_diffsec   = 86400 - h_diffsec.
    difftage    = difftage - 1.
    pe_timediff = h_diffsec + ( difftage * 86400 ).
  ENDIF.                               " PI_TIMEBI > PI_TIMEAB.


ENDFORM.                               " TIME_DIFF_GET


*eject
************************************************************************
FORM pointer_get
     TABLES pet_pointer   STRUCTURE gt_pointer
            pet_wind      STRUCTURE gt_wind
            pit_msg_types STRUCTURE wpmsgtype
     USING  pi_vkorg      LIKE wpstruc-vkorg
            pi_vtweg      LIKE wpstruc-vtweg
            pi_datp1      LIKE gt_filia_group-datab
            pi_timep1     LIKE gt_filia_group-timeab
            pi_datp2      LIKE syst-datum
            pi_timep2     LIKE syst-uzeit
            pi_datp3      LIKE syst-datum
            pi_datp4      LIKE syst-datum
            pi_wind       LIKE wpstruc-cond_index.
************************************************************************
* FUNKTION:
* Selektiere alle Änderungspointer, die zwischen den Zeitpunkten
* P1 und P2 erzeugt wurden und die bis zum Zeitpunkt P4 aktiv
* werden. Außerdem werden alle Änderungspointer selektiert, die
* bis zum Zeitpunkt P1 erzeugt wurden und die im Intervall
* P3 und P4 aktiv werden. (Siehe Dokument: 'Detailkonzept für den
* Download zum POS im SAP-Handelssystem', Abschnitt 4.8.1)
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_POINTER  : Ergebnistabelle der Selektierten Pointer.

* PET_WIND     : Ergebnistabelle der Selektierten Konditionspointer,
*                falls PI_WIND gesetzt ist.
* PIT_MSG_TYPES: Tabelle der POS-relevanten Nachrichtentypen.

* PI_VKORG     : Verkaufsorganisation für die versendet wird

* PI_VTWEG     : Vertriebsweg für den versendet wird.

* PI_DATP1     : Datum des AB-Zeitpunktes.

* PI_TIMEP1    : Zeit des AB-Zeitpunktes.

* PI_DATP2     : Datum des BIS-Zeitpunktes.

* PI_TIMEP2    : Zeit des BIS-Zeitpunktes.

* PI_DATP3     : Datum des AB-Zeitpunktes + Vorlaufzeit.

* PI_DATP4     : Datum des BIS-Zeitpunktes + Vorlaufzeit.

* PI_WIND      : = 'X', wenn zusätzlich die Konditionsbelegindextabelle
*                gelesen werden soll.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_date LIKE sy-datum,
        h_time LIKE sy-uzeit,
        key1   LIKE gt_pointer-cdobjid,
        key2   LIKE gt_pointer-cdobjid.

  DATA: BEGIN OF t_pointer_temp OCCURS 200.
      INCLUDE STRUCTURE gt_pointer.
  DATA: END OF t_pointer_temp.

  RANGES: ra_cretime   FOR wind-cretime,
          ra_wind_var1 FOR wind-wind_va1.


* Rücksetze Hilfsvariablen.
  CLEAR: h_date, h_time.

* Selektiere alle Änderungspointer, die zwischen den Zeitpunkten
* P1 und P2 erzeugt wurden
  CALL FUNCTION 'CHANGE_POINTERS_READ'
    EXPORTING
      creation_date_high = pi_datp2
      creation_date_low  = pi_datp1
      creation_time_high = pi_timep2
      creation_time_low  = pi_timep1
      message_type       = ' '
    TABLES
      change_pointers    = pet_pointer
      message_types      = pit_msg_types.

* Sortieren der Daten.
  SORT pet_pointer BY cdobjid cretime DESCENDING acttime.

* Lösche doppelte Konditionspointer.
  CLEAR: key1, key2.
  LOOP AT pet_pointer
       WHERE cdobjcl = c_objcl_cond_a
       OR    cdobjcl = c_objcl_cond_n.

    MOVE pet_pointer-cdobjid TO key2.

    IF key1 <> key2.
      key1 = key2.
    ELSE. " key1 = key2.
      DELETE pet_pointer.
    ENDIF. " key1 <> key2.

  ENDLOOP. " at pet_pointer

* Sortieren der Daten.
  SORT pet_pointer BY cdobjcl tabname cdobjid tabkey
                      fldname cdchgid cretime acttime.

* Daten komprimieren.
  DELETE ADJACENT DUPLICATES FROM pet_pointer
         COMPARING cdobjcl tabname cdobjid tabkey
                   fldname cdchgid tabname cretime acttime.

* Sortieren der Daten.
  SORT pet_pointer BY cdobjcl tabname cretime acttime.

* Falls zusätzlich die Konditionsbelegindextabelle WIND gelesen werden
* soll
  IF NOT pi_wind IS INITIAL.
*   Setze Intervallgrenzen für Zeitstempel.
    REFRESH: ra_cretime.
    CLEAR:   ra_cretime.
    ra_cretime-sign      = c_inclusive.
    ra_cretime-option    = c_between.
    ra_cretime-low(8)    = pi_datp1.
    ra_cretime-low+8(6)  = pi_timep1.
    ra_cretime-high(8)   = pi_datp2.
    ra_cretime-high+8(6) = pi_timep2.
    APPEND ra_cretime.

*   Setze Intervallgrenzen für WIND_VAR1.
    REFRESH: ra_wind_var1.
    CLEAR:   ra_wind_var1.
    ra_wind_var1-sign     = c_inclusive.
    ra_wind_var1-option   = c_equal.

*   Selektiere auch mandantenabhängige Konditionsänderungen,
*   falls vorhanden (kundeneigene Tabellen).
    APPEND ra_wind_var1.

*   Selektiere auch Konditionsänderungen, die nur von der
*   Verkaufsorganisation und nicht vom Vertriebsweg
*   abhängen (kundeneigene Tabellen).
    ra_wind_var1-low(4)   = pi_vkorg.
    APPEND ra_wind_var1.

*   Selektiere auch Konditionsänderungen, die nur von dieser
*   Vertriebslinie abhängen.
    ra_wind_var1-low+4(2) = pi_vtweg.
    APPEND ra_wind_var1.

*   Consider reference distribution chain
    IF pi_vtweg IS NOT INITIAL.
      DATA lv_vtweg like pi_vtweg.
      SELECT SINGLE vtwko FROM  tvkov
                   INTO lv_vtweg
                   WHERE  vtweg       = pi_vtweg
                   and    vkorg       = pi_vkorg
                   and    vtwko       <> pi_vtweg.
      IF SY-SUBRC = 0 and lv_vtweg IS NOT INITIAL.
        ra_wind_var1-low+4(2) = lv_vtweg.
        APPEND ra_wind_var1.
      ENDIF.
    ENDIF.

*   Besorge die WIND-Daten
    CALL FUNCTION 'MM_WIND_INDEX_READ'
      EXPORTING
        i_bltyp           = c_pos_bltyp
      TABLES
        pt_wind           = pet_wind
        pt_cretimerange   = ra_cretime
        pt_wind_var1range = ra_wind_var1
      EXCEPTIONS
        no_data_select    = 1
        OTHERS            = 2.

    IF sy-subrc = 0.
*     Daten sortieren.
      SORT pet_wind BY knumh kopos.

*     Daten komprimieren.
      DELETE ADJACENT DUPLICATES FROM pet_wind
             COMPARING knumh.

*     Daten resortieren.
      SORT pet_wind BY cretime acttime.
    ENDIF.
  ENDIF. " not pi_wind is initial.


ENDFORM.                               " POINTER_GET


*eject
************************************************************************
FORM pointer_analyse
     TABLES pit_pointer        STRUCTURE gt_pointer
            pit_wind           STRUCTURE gt_wind
            pit_filia_group    STRUCTURE gt_filia_group
            pit_kondart        STRUCTURE gt_kondart
            pit_kondart_gesamt STRUCTURE twpek
            pet_artdel         STRUCTURE gt_artdel
            pet_ot1_f_wrgp     STRUCTURE gt_ot1_f_wrgp
            pet_ot2_wrgp       STRUCTURE gt_ot2_wrgp
            pet_ot1_f_artstm   STRUCTURE gt_ot1_f_artstm
            pet_ot2_artstm     STRUCTURE gt_ot2_artstm
            pet_ot1_f_ean      STRUCTURE gt_ot1_f_ean
            pet_ot2_ean        STRUCTURE gt_ot2_ean
            pet_ot1_f_sets     STRUCTURE gt_ot1_f_sets
            pet_ot2_sets       STRUCTURE gt_ot2_sets
            pet_ot1_f_nart     STRUCTURE gt_ot1_f_nart
            pet_ot2_nart       STRUCTURE gt_ot2_nart
            pet_ot1_k_pers     STRUCTURE gt_ot1_k_pers
            pet_ot2_pers       STRUCTURE gt_ot2_pers
            pet_ot1_f_promreb  STRUCTURE gt_ot1_f_promreb
            pet_ot2_promreb    STRUCTURE gt_ot2_promreb
            pet_reorg_pointer  STRUCTURE bdicpident
            pet_rfcdest        STRUCTURE gt_rfcdest
     USING  pi_erstdat         LIKE syst-datum
            pi_datp3           LIKE syst-datum
            pi_datp4           LIKE syst-datum
            pi_pointer_reorg   LIKE wpstruc-modus
            pi_wind            LIKE wpstruc-cond_index
            pi_parallel        LIKE wpstruc-parallel
            pi_server_group    LIKE wpstruc-servergrp
            pi_taskname        LIKE wpstruc-counter6.
************************************************************************
* FUNKTION:
* Analysiere alle Änderungspointer in Tabelle PIT_POINTER und
* fülle die Objekttabellen PET_OT1_F (filialabhängig) und
* PET_OT2 (filialunabhängig).
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_POINTER       : Tabelle der zu analysierenden Änderungspointer.

* PIT_WIND          : Tabelle Konditionspointer, falls PI_WIND
*                     gesetzt ist.
* PIT_FILIA_GROUP   : Tabelle für Filialkonstanten der Gruppe

* PIT_KONDART       : Tabelle mit POS-relevanten Konditionsarten.

* PIT_KONDART_GESAMT: Tabelle aler unterschiedlichen Konditionsarten
*                     aller Filialen. Wird nur bei Pointer-Reorg
*                     gefüllt.
* PET_ARTDEL        : Tabelle für zu löschende Artikel

* PET_OT1_F_WRGP    : Warengruppen: Objekttabelle 1, filialabhängig.

* PET_OT2_WRGP      : Warengruppen: Objekttabelle 2, filialunabhängig.

* PET_OT1_F_ARTSTM  : Artikelstamm: Objekttabelle 1, filialabhängig.

* PET_OT2_ARTSTM    : Artikelstamm: Objekttabelle 2, filialunabhängig.

* PET_OT1_F_EAN     : EAN-Referenzen: Objekttabelle 1, filialabhängig.

* PET_OT2_EAN       : EAN-Referenzen: Objekttabelle 2, filialunabhängig.

* PET_OT1_F_SETS    : Set-Zuordnungen: Objekttabelle 1, filialabhängig.

* PET_OT2_SETS      : Set-Zuordnungen: Objekttabelle 2, filialunabhängig

* PET_OT1_F_NART    : Nachzugsartkikel Objekttabelle 1, filialabhängig.

* PET_OT2_NART      : Nachzugsartikel: Objekttabelle 2, filialunabhängig

* PET_OT1_K_PERS    : Personendaten: Objekttabelle 1,
*                     Kreditkontrollbereichsabhängig.
* PET_OT2_PERS      : Personendaten: Objekttabelle 2, filialunabhängig.

* PET_OT1_F_PROMREB : Aktionsrabatte: Objekttabelle 1, filialabhängig.

* PET_OT2_PROMREB   : Aktionsrabatte: Objekttabelle 2, filialunabhängig.

* PET_REORG_POINTER : Tabelle der reorganisierbaren Pointer-ID's.
*
* PET_RFCDEST       : Tabelle der abgebrochenen parallelen Tasks
*
* PI_ERSTDAT        : Datum: jetziges Versenden.

* PI_DATP3          : Datum: letztes   Versenden + Vorlaufzeit.

* PI_DATP4          : Datum: jetziges Versenden + Vorlaufzeit.

* PI_POINTER_REORG  : = 'X', wenn Pointer-Reorg erwünscht, sonst SPACE.

* PI_WIND           : Die Konditionsanalyse soll über
*                     Konditionsbelegindex erfolgen.
* PI_PARALLEL       : = 'X', wenn Parallelverarbeitung erwünscht,
*                            sonst SPCACE.
* PI_SERVER_GROUP   : Name der Server-Gruppe für
*                     Parallelverarbeitung.
* PI_TASKNAME       : Identifiziernder Name des aktuellen Tasks.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Falls Warengruppen aufbereitet werden sollen.
  IF pit_filia_group-npmec IS INITIAL.
*   Analysiere alle Pointer für Download Warengruppen.
    PERFORM wrgp_pointer_analyse TABLES  pit_pointer
                                         pit_filia_group
                                         pet_ot1_f_wrgp
                                         pet_ot2_wrgp.
  ENDIF. " pit_filia_group-npmec is initial.

* Falls Artikelstammdaten aufbereitet werden sollen.
  IF pit_filia_group-npmat IS INITIAL.
*   Analysiere alle Pointer für Download Artikelstamm und
*   EAN-Referenzen.
    PERFORM artstm_ean_pointer_analyse
                   TABLES  pit_pointer
                           pit_wind
                           pit_filia_group
                           pit_kondart
                           pit_kondart_gesamt
                           pet_artdel
                           pet_ot1_f_artstm
                           pet_ot2_artstm
                           pet_ot1_f_ean
                           pet_ot2_ean
                           pet_reorg_pointer
                           pet_rfcdest
                   USING   pi_erstdat
                           pi_datp3
                           pi_datp4
                           pi_pointer_reorg
                           pi_wind
                           pi_parallel
                           pi_server_group
                           pi_taskname.
  ENDIF. " pit_filia_group-npmat is initial.

* Falls Set-Zuordnungen aufbereitet werden sollen.
  IF pit_filia_group-npset IS INITIAL.
*   Analysiere alle Pointer für Download Set-Zuordnungen.
    PERFORM sets_pointer_analyse
                 TABLES  pit_pointer
                         pit_filia_group
                         pet_artdel
                         pet_ot1_f_sets
                         pet_ot2_sets
                 USING   pi_erstdat  pi_datp3  pi_datp4.
  ENDIF. " pit_filia_group-npset is initial.

* Falls Nachzugsartikel aufbereitet werden sollen.
  IF pit_filia_group-npfoa IS INITIAL.
*   Analysiere alle Pointer für Download Nachzugsartikel.
    PERFORM nart_pointer_analyse
                 TABLES  pit_pointer
                         pit_filia_group
                         pet_artdel
                         pet_ot1_f_nart
                         pet_ot2_nart
                 USING   pi_erstdat  pi_datp3  pi_datp4.
  ENDIF. " pit_filia_group-npfoa is initial.

* Falls Personendaten aufbereitet werden sollen.
  IF pit_filia_group-npcus IS INITIAL.
*   Analysiere alle Pointer für Download Personendaten.
    PERFORM pers_pointer_analyse TABLES  pit_pointer
                                         pit_filia_group
                                         pet_ot1_k_pers
                                         pet_ot2_pers.
  ENDIF. " pit_filia_group-npcus is initial.

* Falls Aktoinsrabatte aufbereitet werden sollen.
  IF pit_filia_group-promo_rebate = 'X'.
*   Analysiere alle Pointer für Download Aktionsrabatte.
    PERFORM promreb_pointer_analyse
            TABLES  pit_pointer
                    pit_filia_group
                    pet_ot1_f_promreb
                    pet_ot2_promreb
            USING   pi_erstdat
                    pi_datp3
                    pi_datp4.
  ENDIF. " pit_filia_group-promo_rebate = 'X'.


* Lösche doppelte Einträge aus PET_ARTDEL.
  SORT pet_artdel BY artnr vrkme ean datum.
  DELETE ADJACENT DUPLICATES FROM pet_artdel
                  COMPARING artnr vrkme ean.

ENDFORM.                               " POINTER_ANALYSE


*eject
************************************************************************
FORM ot3_generate
     TABLES pit_kondart            STRUCTURE gt_kondart
            pit_ot1_f_wrgp         STRUCTURE gt_ot1_f_wrgp
            pit_ot2_wrgp           STRUCTURE gt_ot2_wrgp
            pet_ot3_wrgp           STRUCTURE gt_ot3_wrgp
            pit_ot1_f_artstm       STRUCTURE gt_ot1_f_artstm
            pit_ot2_artstm         STRUCTURE gt_ot2_artstm
            pet_ot3_artstm         STRUCTURE gt_ot3_artstm
            pit_ot1_f_ean          STRUCTURE gt_ot1_f_ean
            pit_ot2_ean            STRUCTURE gt_ot2_ean
            pet_ot3_ean            STRUCTURE gt_ot3_ean
            pit_ot1_f_sets         STRUCTURE gt_ot1_f_sets
            pit_ot2_sets           STRUCTURE gt_ot2_sets
            pet_ot3_sets           STRUCTURE gt_ot3_sets
            pit_ot1_f_nart         STRUCTURE gt_ot1_f_nart
            pit_ot2_nart           STRUCTURE gt_ot2_nart
            pet_ot3_nart           STRUCTURE gt_ot3_nart
            pit_ot1_k_pers         STRUCTURE gt_ot1_k_pers
            pit_ot2_pers           STRUCTURE gt_ot2_pers
            pet_ot3_pers           STRUCTURE gt_ot3_pers
            pit_ot1_f_promreb      STRUCTURE gt_ot1_f_promreb
            pit_ot2_promreb        STRUCTURE gt_ot2_promreb
            pet_ot3_promreb        STRUCTURE gt_ot3_promreb
            pxt_independence_check STRUCTURE gt_independence_check
            pxt_artdel             STRUCTURE gt_artdel
            pet_wlk2               STRUCTURE gt_wlk2
            pit_filter_segs        STRUCTURE gt_filter_segs
     USING  pi_filia_group         STRUCTURE gt_filia_group
            pi_erstdat             LIKE syst-datum
            pi_datp3               LIKE syst-datum
            pi_datp4               LIKE syst-datum.
************************************************************************
* FUNKTION:
* Besorge alle sich ändernden Gültigkeitsstände einer Filiale, die
* noch nicht durch die Pointeranalyse übernommen wurden und
* erzeuge filialabhängige Objekttabelle PXT_OT3... Ferner
* werden die Objekttabellen OT1 und OT2 in OT3 zusammengemischt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_KONDART           : Tabelle mit POS-relevanten Konditionsarten.

* PIT_OT1_F_WRGP        : Warengruppen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_WRGP          : Warengruppen: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_WRGP          : Warengruppen: Objekttabelle 3.

* PIT_OT1_F_ARTSTM      : Artikelstamm: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_ARTSTM        : Artikelstamm: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3.

* PET_OT1_F_EAN         : EAN-Referenzen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_EAN           : EAN-Referenzen: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_EAN           : EAN-Referenzen: Objekttabelle 3.

* PIT_OT1_F_SETS        : Set-Zuordnungen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_SETS          : Set-Zuordnungen: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_SETS          : Set-Zuordnungen: Objekttabelle 3.

* PIT_OT1_F_NART        : Nachzugsartikel: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_NART          : Nachzugsartikel: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_NART          : Nachzugsartikel: Objekttabelle 3.

* PIT_OT1_K_PERS        : Personendaten: Objekttabelle 1,
*                         Kreditkontrollbereichsabhängig.
* PIT_OT2_PERS          : Personendaten: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_PERS          : Personendaten: Objekttabelle 3.

* PIT_OT1_F_PROMREB     : Aktionsrabatte: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_PROMREB       : Aktionsrabatte: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT3_PROMREB       : Aktionsrabatte: Objekttabelle 3,

* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_ARTDEL            : Tabelle für zu löschende Artikel

* PET_WLK2              : Gesammelte Bewirtschaftungszeiträume der
*                         Filiale.
* PIT_FILTER_SEGS       : Reduzierinformationen.

* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_datum LIKE sy-datum.


* Zwischenpuffer für Materialnummern aus WLK2.
  DATA: BEGIN OF t_matnr OCCURS 0.
      INCLUDE STRUCTURE wpmatnr.
  DATA: END OF t_matnr.

  DATA: BEGIN OF t_ot1_f_artstm OCCURS 0.
      INCLUDE STRUCTURE gt_ot1_f_artstm.
  DATA: END OF t_ot1_f_artstm.

  DATA: BEGIN OF t_ot2_artstm OCCURS 0.
      INCLUDE STRUCTURE gt_ot2_artstm.
  DATA: END OF t_ot2_artstm.

  DATA: BEGIN OF t_ot1_f_ean OCCURS 0.
      INCLUDE STRUCTURE gt_ot1_f_ean.
  DATA: END OF t_ot1_f_ean.

  DATA: BEGIN OF t_ot2_ean OCCURS 0.
      INCLUDE STRUCTURE gt_ot2_ean.
  DATA: END OF t_ot2_ean.

  DATA: BEGIN OF t_ot1_f_nart OCCURS 0.
      INCLUDE STRUCTURE gt_ot1_f_nart.
  DATA: END OF t_ot1_f_nart.

  DATA: BEGIN OF t_ot2_nart OCCURS 0.
      INCLUDE STRUCTURE gt_ot2_nart.
  DATA: END OF t_ot2_nart.

* Falls eine Kreuzverbindung mit EAN-Referenzen oder Nachzugsartikeln
* aktiv ist.
  IF NOT pi_filia_group-ean_art IS INITIAL OR
     NOT pi_filia_group-foa_art IS INITIAL.
*   Zwichenspeichern der Ergebnisse des Analyseteils.
    t_ot1_f_artstm[] = pit_ot1_f_artstm[].
    t_ot2_artstm[]   = pit_ot2_artstm[].
    t_ot1_f_ean[]    = pit_ot1_f_ean[].
    t_ot2_ean[]      = pit_ot2_ean[].
    t_ot1_f_nart[]   = pit_ot1_f_nart[].
    t_ot2_nart[]     = pit_ot2_nart[].
  ENDIF. " not pi_filia_group-ean_art is initial or ...

  IF pi_datp3 >= pi_erstdat.
    h_datum = pi_erstdat.
  ELSE. " pi_datp3 < pi_erstdat
    h_datum = pi_datp3.
  ENDIF. " pi_datp3 >= pi_erstdat

* Bestimme alle Artikel, deren Bewirtschaftungszeitraum jetzt erst
* in den Betrachtungszeitraum hineinrutscht und solche deren
* Bewirtschaftungszeitraum innerhalb des Betrachtungszeitraums endet.
* Das Ganze gilt für diese Filiale dieser Vertriebslinie.
  PERFORM wlk2_matnr_get
          TABLES t_matnr
          USING  pi_filia_group-vkorg
                 pi_filia_group-vtweg
                 pi_filia_group-filia
                 h_datum
                 pi_datp4.

* Aufruf WRSZ-Intervallscan: Bestimmung aller Artikel aus Sortimenten,
* deren Gültigkeitszeiträume für dies Lauf des POS Downloads relevant
* ist.
  PERFORM wrsz_article_get
          USING  pi_filia_group
                 pi_datp3
                 pi_datp4
          CHANGING pit_ot1_f_artstm[]
                   pit_ot1_f_ean[]
                   pit_ot1_f_sets[]
                   pit_ot1_f_nart[].
* Übernehme alle Artikel aus den Objekttabellen 1 und 2 in eine
* interne Tabelle.
* Übernehme Artikel von der Artikelstammanalyse.
  LOOP AT pit_ot1_f_artstm.
    APPEND pit_ot1_f_artstm-artnr TO t_matnr.
  ENDLOOP. " at pit_ot1_f_artstm.

  LOOP AT pit_ot2_artstm.
    APPEND pit_ot2_artstm-artnr TO t_matnr.
  ENDLOOP. " at pit_ot2_artstm.

* Übernehme Artikel von der EAN-Referenzen Analyse.
  LOOP AT pit_ot1_f_ean.
    APPEND pit_ot1_f_ean-artnr TO t_matnr.
  ENDLOOP. " at pit_ot1_f_ean.

  LOOP AT pit_ot2_ean.
    APPEND pit_ot2_ean-artnr TO t_matnr.
  ENDLOOP. " at pit_ot2_ean.

* Übernehme Artikel von der Setartikel Analyse.
  LOOP AT pit_ot1_f_sets.
    APPEND pit_ot1_f_sets-artnr TO t_matnr.
  ENDLOOP. " at pit_ot1_f_sets.

  LOOP AT pit_ot2_sets.
    APPEND pit_ot2_sets-artnr TO t_matnr.
  ENDLOOP. " at pit_ot2_sets.

* Übernehme Artikel von der Nachzugsartikel Analyse.
  LOOP AT pit_ot1_f_nart.
    APPEND pit_ot1_f_nart-artnr TO t_matnr.
  ENDLOOP. " at pit_ot1_f_nart.

  LOOP AT pit_ot2_nart.
    APPEND pit_ot2_nart-artnr TO t_matnr.
  ENDLOOP. " at pit_ot2_nart.

* Sortiere Daten.
  SORT t_matnr BY matnr.

* Daten komprimieren.
  DELETE ADJACENT DUPLICATES FROM t_matnr COMPARING matnr.

* B: New listing check logic => Note 1982796
  IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
     AND gs_twpa-marc_chk IS NOT INITIAL.
    MOVE-CORRESPONDING pi_filia_group TO gi_filia_const.
* New Lsiting logic: read WLK2 and check MARC if enries exists
    CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
      EXPORTING
        ip_access_type = '2'              " WLK2 access with Art/store
        ip_vkorg       = pi_filia_group-vkorg
        ip_vtweg       = pi_filia_group-vtweg
        ip_filia       = pi_filia_group-filia
        ip_date_from   = h_datum
        ip_date_to     = pi_datp4
        is_filia_const = gi_filia_const
      TABLES
        pit_matnr      = t_matnr
        pet_wlk2       = pet_wlk2.
  ENDIF.
* Falls Warengruppen aufbereitet werden sollen.
  IF pi_filia_group-npmec IS INITIAL.
*   Erzeuge Objekttabelle 3 für Download Warengruppen.
    PERFORM ot3_generate_wrgp TABLES  pit_ot1_f_wrgp
                                      pit_ot2_wrgp
                                      pet_ot3_wrgp
                                      pxt_independence_check
                              USING   pi_filia_group.
  ENDIF. " pi_filia_group-npmec is initial.

* Falls Artikelstammdaten aufbereitet werden sollen.
  IF pi_filia_group-npmat IS INITIAL.

*   Analysiere Gültigkeitsstände für Download Artikelstamm, falls
*   nötig und erzeuge Objekttabelle 3.
    PERFORM ot3_generate_artstm TABLES  pit_kondart
                                        pit_ot1_f_artstm
                                        pit_ot2_artstm
                                        pet_ot3_artstm
                                        pit_ot1_f_ean
                                        pit_ot2_ean
                                        pit_ot1_f_nart
                                        pit_ot2_nart
                                        pet_wlk2
                                        pxt_independence_check
                                        pxt_artdel
                                        t_matnr
                                        pit_filter_segs
                                USING   pi_filia_group
                                        pi_erstdat  pi_datp3
                                        pi_datp4.
  ENDIF. " pi_filia_group-npmat is initial.

* Falls EAN's aufbereitet werden sollen.
  IF pi_filia_group-npmat IS INITIAL.
*   Erzeuge Objekttabelle 3 für Download EAN-Referenzen.
    PERFORM ot3_generate_ean  TABLES  pit_ot1_f_ean
                                      pit_ot2_ean
                                      pet_ot3_ean
                                      pet_ot3_artstm
                                      pet_wlk2
                                      pxt_independence_check
                                      pxt_artdel
                                      t_matnr
                              USING   pi_filia_group
                                      pi_erstdat  pi_datp3
                                      pi_datp4.
  ENDIF. " pi_filia_group-npmat is initial.

* Falls Set-Zuordnungen aufbereitet werden sollen.
  IF pi_filia_group-npset IS INITIAL.
*   Analysiere Gültigkeitsstände für Download Artikelstamm, falls
*   nötig und erzeuge Objekttabelle 3.
    PERFORM ot3_generate_sets TABLES  pit_ot1_f_sets
                                      pit_ot2_sets
                                      pet_ot3_sets
                                      pet_wlk2
                                      pxt_independence_check
                                      pxt_artdel
                                      t_matnr
                              USING   pi_filia_group
                                      pi_erstdat  pi_datp3
                                      pi_datp4.
  ENDIF. " pi_filia_group-npset is initial.

* Falls Nachzugsartikel aufbereitet werden sollen.
  IF pi_filia_group-npfoa IS INITIAL.
*   Analysiere Gültigkeitsstände für Download Artikelstamm, falls
*   nötig und erzeuge Objekttabelle 3.
    PERFORM ot3_generate_nart TABLES  pit_ot1_f_nart
                                      pit_ot2_nart
                                      pet_ot3_nart
                                      pet_ot3_artstm
                                      pet_wlk2
                                      pxt_independence_check
                                      pxt_artdel
                                      t_matnr
                              USING   pi_filia_group
                                      pi_erstdat  pi_datp3
                                      pi_datp4.
  ENDIF. " pi_filia_group-npfoa is initial.

* Falls Personendaten aufbereitet werden sollen.
  IF pi_filia_group-npcus IS INITIAL.
*   Erzeuge Objekttabelle 3 für Download Personendaten.
    PERFORM ot3_generate_pers TABLES  pit_ot1_k_pers
                                      pit_ot2_pers
                                      pet_ot3_pers
                                      pxt_independence_check
                              USING   pi_filia_group.
  ENDIF. " pi_filia_group-npcus is initial.


* Falls Aktionsrabatte aufbereitet werden sollen.
  IF pi_filia_group-promo_rebate = 'X'.
*   Erzeuge Objekttabelle 3 für Download EAN-Referenzen.
    PERFORM ot3_generate_promreb TABLES pit_ot1_f_promreb
                                        pit_ot2_promreb
                                        pet_ot3_promreb
                                 USING  pi_filia_group.
  ENDIF. " PI_FILIA_GROUP-PROMO_REBATE = 'X'.

* Falls eine Kreuzverbindung mit EAN-Referenzen oder Nachzugsartikeln
* aktiv ist.
  IF NOT pi_filia_group-ean_art IS INITIAL OR
     NOT pi_filia_group-foa_art IS INITIAL.
*   Wiederherstellen der Ergebnisse des Analyseteils.
    pit_ot1_f_artstm[] = t_ot1_f_artstm[].
    pit_ot2_artstm[]   = t_ot2_artstm[].
    pit_ot1_f_ean[]    = t_ot1_f_ean[].
    pit_ot2_ean[]      = t_ot2_ean[].
    pit_ot1_f_nart[]   = t_ot1_f_nart[].
    pit_ot2_nart[]     = t_ot2_nart[].
  ENDIF. " not pi_filia_group-ean_art is initial or ...


ENDFORM.                               " OT3_GENERATE


*eject
************************************************************************
FORM download_change_mode
     TABLES pit_artdel             STRUCTURE gt_artdel
            pit_ot3_wrgp           STRUCTURE gt_ot3_wrgp
            pit_ot3_artstm         STRUCTURE gt_ot3_artstm
            pit_ot3_ean            STRUCTURE gt_ot3_ean
            pit_ot3_sets           STRUCTURE gt_ot3_sets
            pit_ot3_nart           STRUCTURE gt_ot3_nart
            pit_ot3_pers           STRUCTURE gt_ot3_pers
            pit_ot3_promreb        STRUCTURE gt_ot3_promreb
            pit_filter_segs        STRUCTURE gt_filter_segs
            pxt_independence_check STRUCTURE gt_independence_check
            pxt_master_idocs       STRUCTURE gt_master_idocs
            pet_rfcdest            STRUCTURE gt_rfcdest
            pit_wlk2               STRUCTURE gt_wlk2
     USING  pi_filia_group         STRUCTURE gt_filia_group
            pi_erstdat             LIKE syst-datum
            pi_erstzeit            LIKE syst-uzeit
            pi_datp3               LIKE syst-datum
            pi_datp4               LIKE syst-datum
            pi_mode                LIKE wpstruc-modus
            pi_mestype_wrgp        LIKE g_mestype_wrgp
            pi_mestype_artstm      LIKE g_mestype_artstm
            pi_mestype_ean         LIKE g_mestype_ean
            pi_mestype_set         LIKE g_mestype_set
            pi_mestype_nart        LIKE g_mestype_nart
            pi_mestype_steu        LIKE g_mestype_steu
            pi_mestype_cur         LIKE g_mestype_cur
            pi_mestype_pers        LIKE g_mestype_pers
            pi_parallel            LIKE wpstruc-parallel
            pi_server_group        LIKE wpstruc-servergrp
            pi_taskname            LIKE wpstruc-counter6
            pe_anzahl_tasks        LIKE g_snd_jobs_sub.
************************************************************************
* FUNKTION:
* Bereite den Download für die einzelnen IDOC-Typen vor dieser
* Filiale vor.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_OT3_WRGP          : Warengruppen: Objekttabelle 3.

* PIT_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3.

* PIT_OT3_EAN           : EAN-Referenzen: Objekttabelle 3.

* PIT_OT3_SETS          : Set-Zuordnungen: Objekttabelle 3.

* PIT_OT3_NART          : Nachzugsartikel: Objekttabelle 3.

* PIT_OT3_PERS          : Personendaten: Objekttabelle 3.

* PIT_OT3_PROMREB       : Aktionsrabatte: Objekttabelle 3.

* PIT_FILTER_SEGS       : Reduzierinformationen.

* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_MASTER_IDOCS      : Tabelle der kopierfähigen IDOC's

* PET_RFCDEST           : Tabelle der fehlerhaften Tasks

* PIT_WLK2              : Gesammelte Bewirtschaftungszeiträume der
*                         Filiale.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_ERSTZEIT           : Zeit : jetziges Versenden.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.

* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.

* PI_MESTYPE_WRGP       : Zu verwendender Nachrichtentyp für
*                         Objekt Warengruppen.
* PI_MESTYPE_ARTSTM     : Zu verwendender Nachrichtentyp für
*                         Objekt Artikelstamm.
* PI_MESTYPE_EAN        : Zu verwendender Nachrichtentyp für
*                         Objekt EAN-Referenzen.
* PI_MESTYPE_SETS       : Zu verwendender Nachrichtentyp für
*                         Objekt SET-Zuordnungen.
* PI_MESTYPE_NART       : Zu verwendender Nachrichtentyp für
*                         Objekt Nachzugsartikel.
* PI_MESTYPE_STEU       : Zu verwendender Nachrichtentyp für
*                         Objekt Steuern.
* PI_MESTYPE_CUR        : Zu verwendender Nachrichtentyp für
*                         Objekt Wechselcurse.
* PI_MESTYPE_PERS       : Zu verwendender Nachrichtentyp für
*                         Objekt Personendaten.
* PI_PARALLEL           : = 'X', wenn Parallelverarbeitung erwünscht,
*                                sonst SPCACE.
* PI_SERVER_GROUP       : Name der Server-Gruppe für
*                         Parallelverarbeitung
* PI_TASKNAME           : Identifiziernder Name des aktuellen Tasks
*                         Parallelverarbeitung
* PE_ANZAHL_TASKS       : Anzahl der parallelen Tasks
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_kkber LIKE t001-kkber,
        h_datum LIKE sy-datum,
        h_index LIKE sy-tabix,
        h_copy.

* Feldleiste für Filialkonstanten.
  DATA: BEGIN OF i_filia_const.
      INCLUDE STRUCTURE wpfilconst.
  DATA: END OF i_filia_const.


  CLEAR: g_segment_counter.

* Filialconstanten auf andere Feldleiste übernehmen.
  MOVE-CORRESPONDING pi_filia_group TO i_filia_const.

* Falls nötig, bestimme den nächsten Arbeitstag nach Ende
* des Betrachtungszeitraums.
* if pi_filia_group-fabkl <> space.
*   Besorge das Datum des letzten Versendetages über Fabrikkalender.
*   call function 'DATE_CONVERT_TO_FACTORYDATE'
*        exporting
*             correct_option             = c_vorzeichen
*             date                       = px_datp4
*             factory_calendar_id        = pi_filia_group-fabkl
*        importing
*             date                       = h_datum
*        exceptions
*             date_after_range           = 01
*             date_before_range          = 02
*             date_invalid               = 03
*             factory_calendar_not_found = 04.

*   if sy-subrc = 0.
*     px_datp4 = h_datum.
*   endif.                             " SY-SUBRC = 0.
* endif.                               " PI_FILIA_GROUP-FABKL <> SPACE.

* Erzeuge Tabelle mit Arbeitstagen, falls nötig.
  PERFORM workdays_get TABLES gt_workdays
                       USING  pi_erstdat
                              pi_datp4
                              pi_filia_group-fabkl.

* Aufbereiten der Parameter zum schreiben der Status-Kopfzeile.
  CLEAR: gi_status_header, g_err_counter.
  gi_status_header-empfn = pi_filia_group-kunnr.
  gi_status_header-systp = c_pos_systemtyp.
  gi_status_header-ersab = pi_filia_group-datab.
  gi_status_header-ersbi = pi_erstdat.
  gi_status_header-erzab = pi_filia_group-timeab.
  gi_status_header-erzbi = pi_erstzeit.
  gi_status_header-gesst = c_status_init.
  gi_status_header-dlmod = pi_mode.

* Schreibe Status-Kopfzeile.
  PERFORM status_write_head USING  ' '  gi_status_header  g_dldnr
                                        g_returncode.

* Besorge zugehörigen Satz in Filialcopy-Tabelle.
  READ TABLE pxt_independence_check WITH KEY
       filia = pi_filia_group-filia
       BINARY SEARCH.

* Zwischenspeichern des Tabelleneintrags.
  gi_independence_check = pxt_independence_check.

* Zwischenspeichern der Statistikinformationen.
  gi_stat_counter2 = gi_stat_counter.

* Zwischenspeichern der Tabellenzeilennummer.
  h_index = sy-tabix.


* Falls Parallelverarbeitung, dann Schreibe Statuskopfzeile auf DB,
* damit sie später im parallelen Task wieder von DB gelesen werden kann.
  IF NOT pi_parallel IS INITIAL.
    COMMIT WORK.
  ENDIF. " not pi_parallel is initial.

* Vorbesetzen des Aufbereitungsstatus.
  g_status = 0.

* Rücksetze Zählvariablen.
  CLEAR: g_idoc_counter, g_snd_jobs_sub, g_rcv_jobs_sub.

* Initialisiere Tabelle für abgebrochene parallele Tasks
* einer Filialuntergruppe.
  REFRESH: gt_rfcdest, pet_rfcdest.
  CLEAR:   gt_rfcdest, pet_rfcdest.

* Warengruppen:
* Falls Warengruppen aufbereitet werden sollen.
  IF pi_filia_group-npmec IS INITIAL.
*   Prüfe, ob Daten zum Versenden vorhanden sind.
    READ TABLE pit_ot3_wrgp INDEX 1.

*   Falls Daten zum Versenden vorhanden sind.
    IF sy-subrc = 0.
*     IDOC-Aufbereitung der Warengruppen
      PERFORM wrgp_change_mode_prepare
              TABLES pit_ot3_wrgp
                     pit_filter_segs
                     gt_workdays
                     pxt_master_idocs
                     pxt_independence_check
                     pet_rfcdest
                     gt_wdlsp_buf
                     gt_wdlso_parallel
              USING  pi_filia_group
                     gi_independence_check
                     gi_stat_counter2
                     c_idoctype_wrgp
                     pi_mestype_wrgp
                     g_dldnr
                     pi_erstdat
                     pi_parallel
                     pi_server_group
                     pi_taskname
                     g_snd_jobs_sub.
    ENDIF. " SY-SUBRC = 0.
  ENDIF. " pi_filia_group-npmec is initial.

* Artikelstamm.
* Falls Artikelstammdaten aufbereitet werden sollen.
  IF pi_filia_group-npmat IS INITIAL.
*   Prüfe, ob Daten zum Versenden vorhanden sind.
    READ TABLE pit_ot3_artstm INDEX 1.

*   Falls Daten zum Versenden vorhanden sind.
    IF sy-subrc = 0.
*     IDOC-Aufbereitung der Artikelstammdaten.
      PERFORM artstm_change_mode_prepare
              TABLES pit_ot3_artstm
                     pit_filter_segs
                     gt_workdays
                     pit_artdel
                     gt_mara_buf
                     gt_marm_buf
                     gt_mvke_buf
                     gt_a071_matnr
                     gt_old_ean
                     pxt_master_idocs
                     pxt_independence_check
                     pet_rfcdest
                     gt_wdlsp_buf
                     gt_wdlso_parallel
                     pit_wlk2
              USING  pi_filia_group
                     gi_independence_check
                     gi_stat_counter2
                     c_idoctype_artstm
                     pi_mestype_artstm
                     g_dldnr
                     pi_erstdat
                     pi_datp3
                     pi_datp4
                     pi_mode
                     pi_parallel
                     pi_server_group
                     pi_taskname
                     g_snd_jobs_sub.
    ENDIF. " SY-SUBRC = 0.
  ENDIF. " pi_filia_group-npmat is initial.

* EAN-Referenzen:
* Falls EAN's aufbereitet werden sollen.
  IF pi_filia_group-npmat IS INITIAL.
*   Prüfe, ob Daten zum Versenden vorhanden sind.
    READ TABLE pit_ot3_ean INDEX 1.

*   Falls Daten zum Versenden vorhanden sind.
    IF sy-subrc = 0.
*     IDOC-Aufbereitung der EAN-Referenzen.
      PERFORM ean_change_mode_prepare
              TABLES pit_ot3_ean
                     pit_filter_segs
                     gt_workdays
                     pit_artdel
                     gt_mara_buf
                     gt_marm_buf
                     gt_old_ean
                     gt_zus_ean_del
                     gt_ean_change
                     pxt_master_idocs
                     pxt_independence_check
                     pet_rfcdest
                     gt_wdlsp_buf
                     gt_wdlso_parallel
                     pit_wlk2
              USING  pi_filia_group
                     gi_independence_check
                     gi_stat_counter2
                     c_idoctype_ean
                     pi_mestype_ean
                     g_dldnr
                     pi_erstdat
                     pi_datp4
                     pi_mode
                     pi_parallel
                     pi_server_group
                     pi_taskname
                     g_snd_jobs_sub.
    ENDIF. " SY-SUBRC = 0.
  ENDIF. " pi_filia_group-npmat is initial.

* Set-Zuordnungen:
* Falls Set-Zuordnungen aufbereitet werden sollen.
  IF pi_filia_group-npset IS INITIAL.
*   Prüfe, ob Daten zum Versenden vorhanden sind.
    READ TABLE pit_ot3_sets INDEX 1.

*   Falls Daten zum Versenden vorhanden sind.
    IF sy-subrc = 0.
*     IDOC-Aufbereitung der Set-Zuordnungen.
      PERFORM sets_change_mode_prepare
              TABLES pit_ot3_sets
                     pit_filter_segs
                     gt_workdays
                     pit_artdel
                     gt_mara_buf
                     gt_marm_buf
                     gt_old_ean_set
                     pxt_master_idocs
                     pxt_independence_check
                     pet_rfcdest
                     gt_wdlsp_buf
                     gt_wdlso_parallel
                     pit_wlk2
              USING  pi_filia_group
                     gi_independence_check
                     gi_stat_counter2
                     c_idoctype_set
                     pi_mestype_set
                     g_dldnr
                     pi_erstdat
                     pi_datp4
                     pi_mode
                     pi_parallel
                     pi_server_group
                     pi_taskname
                     g_snd_jobs_sub.
    ENDIF. " SY-SUBRC = 0.
  ENDIF. " pi_filia_group-npset is initial.

* Nachzugsartikel:
* Falls Nachzugsartikel aufbereitet werden sollen.
  IF pi_filia_group-npfoa IS INITIAL.
*   Prüfe, ob Daten zum Versenden vorhanden sind.
    READ TABLE pit_ot3_nart INDEX 1.

*   Falls Daten zum Versenden vorhanden sind.
    IF sy-subrc = 0.
*     IDOC-Aufbereitung der Nachzugsartikel.
      PERFORM nart_change_mode_prepare
              TABLES pit_ot3_nart
                     pit_filter_segs
                     gt_workdays
                     pit_artdel
                     gt_mara_buf
                     gt_marm_buf
                     gt_old_ean_nart
                     pxt_master_idocs
                     pxt_independence_check
                     pet_rfcdest
                     gt_wdlsp_buf
                     gt_wdlso_parallel
                     pit_wlk2
              USING  pi_filia_group
                     gi_independence_check
                     gi_stat_counter2
                     c_idoctype_nart
                     pi_mestype_nart
                     g_dldnr
                     pi_erstdat
                     pi_datp4
                     pi_mode
                     pi_parallel
                     pi_server_group
                     pi_taskname
                     g_snd_jobs_sub.
    ENDIF. " SY-SUBRC = 0.
  ENDIF. " pi_filia_group-npfoa is initial.

* Personendaten:
* Falls Personendaten aufbereitet werden sollen.
  IF pi_filia_group-npcus IS INITIAL.
*   Prüfe, ob Daten zum Versenden vorhanden sind.
    READ TABLE pit_ot3_pers INDEX 1.

*   Falls Daten zum Versenden vorhanden sind.
    IF sy-subrc = 0.
*     IDOC-Aufbereitung der Personendaten.
      PERFORM pers_change_mode_prepare
              TABLES pit_ot3_pers
                     pit_filter_segs
                     gt_workdays
                     gt_kunnr_credit_buf
                     gt_kunnr_bank_buf
                     gt_credit_data_buf
                     gt_bank_data_buf
                     pxt_master_idocs
                     pxt_independence_check
                     pet_rfcdest
                     gt_wdlsp_buf
                     gt_wdlso_parallel
              USING  pi_filia_group
                     gi_independence_check
                     gi_stat_counter2
                     c_idoctype_pers
                     pi_mestype_pers
                     g_dldnr
                     pi_erstdat
                     pi_mode
                     pi_parallel
                     pi_server_group
                     pi_taskname
                     g_snd_jobs_sub.
    ENDIF. " SY-SUBRC = 0.
  ENDIF. " pi_filia_group-npcus is initial.

* Wechselkurse:
* Falls Wechselkurse aufbereitet werden sollen.
  IF pi_filia_group-npcur IS INITIAL.
*   Download Wechselkurse. Behandlung wie Initialisierungsfall.
    PERFORM wkurs_download
            TABLES pit_filter_segs
            USING  pi_filia_group-filia
                   ' '                 " Express
                   ' '                 " Löschen
                   pi_mode      pi_erstdat    pi_datp4
                   pi_filia_group-vkorg    pi_filia_group-vtweg
                   i_filia_const
                   g_dldnr                 pi_erstdat.

*   Schreibe DB-Änderungen fort.
    COMMIT WORK.
  ENDIF. " pi_filia_group-npcur is initial.

* Steuern:
* Falls Steuern aufbereitet werden sollen.
  IF pi_filia_group-nptax IS INITIAL.
*   Download Steuern. Behandlung wie Initialisierungsfall.
    PERFORM steuern_download
            TABLES pit_filter_segs
            USING  pi_filia_group-filia
                   ' '                 " Express
                   ' '                 " Löschen
                   pi_mode    pi_erstdat
                   i_filia_const
                   g_dldnr   pi_erstdat.

*   Schreibe DB-Änderungen fort.
    COMMIT WORK.
  ENDIF. " pi_filia_group-nptax is initial.

* Falls Aktionsrabatte aufbereitet werden sollen.
  IF pi_filia_group-promo_rebate = 'X'.
*   Download Aktionsrabatte.
    PERFORM promreb_download_change_mode
            TABLES pit_ot3_promreb
            USING  pi_filia_group
                   pi_mode
                   pi_erstdat
                   pi_datp4
                   g_dldnr.
  ENDIF. " pi_filia_group-promo_rebate = 'X'.

* Übernehme die Anzahl der parallelen Tasks.
  pe_anzahl_tasks = g_snd_jobs_sub.

************************************************************************
* Einsammeln der parallelen Tasks.
  WAIT UNTIL g_rcv_jobs_sub >= g_snd_jobs_sub.
************************************************************************

* Übernehme die Daten der fehlerhaften Tasks in Ausgabetabelle.
  LOOP AT gt_rfcdest.
    APPEND gt_rfcdest TO pet_rfcdest.
  ENDLOOP. " at gt_rfcdest.

************************************************************************
* Falls Fehler bei der parallelen Verarbeitung auftraten.
  LOOP AT gt_error_tasks.
*   Bestimme die richtigen Übergabeparameter aus globaler Tabelle
    READ TABLE gt_task_variables WITH KEY
         taskname = gt_error_tasks-taskname
         BINARY SEARCH.

*   Fehlerhafte Tasks noch einmal seqeuntiell abarbeiten.
    PERFORM idoc_prepare
                 TABLES pit_artdel
                        pit_ot3_wrgp
                        pit_ot3_artstm
                        pit_ot3_ean
                        pit_ot3_sets
                        pit_ot3_nart
                        pit_ot3_pers
                        pit_filter_segs
                        pxt_independence_check
                        pxt_master_idocs
                        gt_workdays
                 USING  pi_filia_group
                        gi_independence_check
                        gi_stat_counter2
                        g_dldnr
                        pi_erstdat
                        pi_erstzeit
                        pi_datp3
                        pi_datp4
                        pi_mode
                        gt_task_variables-mestype.
  ENDLOOP. " at gt_error_tasks.

* Aktualisiere Filialcopy-Tabelle.
  pxt_independence_check = gi_independence_check.
  MODIFY pxt_independence_check INDEX h_index.

* Aktualisiere Statistikinformation.
  gi_stat_counter-wrgp_ign   = gi_stat_counter2-wrgp_ign.
  gi_stat_counter-artstm_ign = gi_stat_counter2-artstm_ign.
  gi_stat_counter-ean_ign    = gi_stat_counter2-ean_ign.
  gi_stat_counter-sets_ign   = gi_stat_counter2-sets_ign.
  gi_stat_counter-nart_ign   = gi_stat_counter2-nart_ign.
  gi_stat_counter-pers_ign   = gi_stat_counter2-pers_ign.

* Falls Parallelverarbeitung aktiv.
  IF NOT pi_parallel IS INITIAL.
*   Übernehme erzeugte WDLSP-Einträge in Puffertabelle.
    LOOP AT gt_wdlsp_parallel.
      APPEND gt_wdlsp_parallel TO gt_wdlsp_buf.
    ENDLOOP. " at gt_wdlsp_parallel.

*   Übernehme erzeugte EDIDC-Einträge in Puffertabelle.
    LOOP AT gt_edidc_parallel.
      APPEND gt_edidc_parallel TO gt_edidc.
    ENDLOOP. " at gt_edidc_parallel.

*   Aktualisiere Status-Kopfzeile und Puffertabelle für WDLSP-Einträge.
    PERFORM status_correction
                   TABLES gt_wdlsp_buf
                          gt_wdlso_parallel
                   USING  gi_status_header
                          g_dldnr.
  ENDIF. " not pi_parallel is initial.

* Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
* auf OK.
  IF g_status = 0 AND gi_status_header-gesst = c_status_init.
*   Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
    CLEAR: gi_status_header.
    gi_status_header-dldnr = g_dldnr.
    gi_status_header-gesst = c_status_ok.

*   Schreibe Status-Kopfzeile.
    PERFORM status_write_head USING  'X'  gi_status_header  g_dldnr
                                          g_returncode.
  ENDIF.                             " G_STATUS = 0.

* Auswertung der erzeugten Statuseinträge auf aufgetretene Fehler
* bzgl. filialunabhängigkeit.
  PERFORM status_independence_check
                 TABLES pxt_independence_check
                        pxt_master_idocs
                 USING  pi_filia_group
                        g_dldnr.


ENDFORM.                               " DOWNLOAD_CHANGE_MODE


*eject
************************************************************************
FORM idoc_filter TABLES pet_filter_segs     STRUCTURE gt_filter_segs
                 USING  pi_filia_group      STRUCTURE gt_filia_group.
************************************************************************
* FUNKTION:
* Ermitteln der nicht benötigten Segmente für alle IDOC-Typen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_FILTER_SEGS: Tabelle der nicht benötigten Segmentnamen.

* PI_FILIA_GROUP:  Daten einer Filiale der Filialgruppe.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: BEGIN OF t_msg OCCURS 100.
      INCLUDE STRUCTURE wpmsgtype.
  DATA: END OF t_msg.

  DATA: BEGIN OF t_reduction OCCURS 20.
      INCLUDE STRUCTURE gt_filter_segs.
  DATA: END OF t_reduction.


* Füllen der Nachrichtentabelle für Reduzierung.
  PERFORM pos_message_types_get TABLES t_msg
                                USING  ' '  pi_filia_group.

  REFRESH: pet_filter_segs.
  LOOP AT t_msg.
*   Besorgen der nicht benötigten Segmente pro
*   Nachrichtentyp.
    CALL FUNCTION 'IDOC_REDUCTION'
      EXPORTING
        message_type = t_msg-mestyp
      TABLES
        reduction    = t_reduction.

*   Übernahme der Daten in Ausgabetabelle.
    LOOP AT t_reduction.
      APPEND t_reduction TO pet_filter_segs.
    ENDLOOP.                           " AT T_REDUCTION.
  ENDLOOP.                             " AT T_MSG.

* Löschen nicht benötigter Einträge, die sich nur im Feldnamen
* unterscheiden.
  SORT pet_filter_segs BY segtyp fldname.
  DELETE ADJACENT DUPLICATES FROM pet_filter_segs
                  COMPARING segtyp.

  DELETE pet_filter_segs WHERE fldname <> space.


ENDFORM.                               " IDOC_FILTER


*eject
************************************************************************
FORM pos_message_types_get
     TABLES pet_message_types         STRUCTURE wpmsgtype
     USING  pi_only_pointer_msgtypes  TYPE c
            pi_filia_group            STRUCTURE gt_filia_group.
************************************************************************
* FUNKTION:
* Fülle Tabelle mit POS-relevanten Nachrichtentyen und sezte die
* zu verwendenden Nachrichtentypen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_MESSAGE_TYPES       : Tabelle der POS-relevanten Nachrichtentypen.

* PI_ONLY_POINTER_MSGTYPES: 'X', nur Pointer-relevante Nachrichtentypen
*                            ' ', alle Nachrichtentypen.
* PI_FILIA_GROUP          : Daten einer Filiale der Filialgruppe.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Füllen der Nachrichtentabelle.
  REFRESH: pet_message_types.
  CLEAR:   pet_message_types.

* Falls Warengruppendaten aufbereitet werden sollen.
  IF pi_filia_group-npmec IS INITIAL.
*   Warengruppen.
    pet_message_types-mestyp  = c_mestype_wrgp.
    APPEND pet_message_types.

*   Setze zu verwendenden Nachrichtentyp für Warengruppen.
    g_mestype_wrgp = c_mestype_wrgp.
  ENDIF. " pi_filia_group-NPMEC is initial.

*   Artikelstamm.
* Falls Artikelstammdaten, EAN-Referenzen, Nachzugsartikel oder
* Setzuordnungen aufbereitet werden sollen.
  IF pi_filia_group-npmat IS INITIAL   OR
     pi_filia_group-npfoa IS INITIAL   OR
     pi_filia_group-npset IS INITIAL.

*   Falls die Artikelstammdaten nicht reduziert werden sollen.
    IF pi_filia_group-mestype_plu = space.
      pet_message_types-mestyp  = c_mestype_artstm.

*     Setze zu verwendenden Nachrichtentyp für Artikelstammdaten.
      g_mestype_artstm = c_mestype_artstm.

*   Falls die Artikelstammdaten reduziert werden sollen.
    ELSE. " pi_filia_group-mestype_plu <> space.
      pet_message_types-mestyp  = pi_filia_group-mestype_plu.

*     Setze zu verwendenden Nachrichtentyp für Artikelstammdaten.
      g_mestype_artstm = pi_filia_group-mestype_plu.
    ENDIF. " pi_filia_group-mestype_plu = space.

    APPEND pet_message_types.
  ENDIF. " pi_filia_group-NPMAT is initial.

* Falls EAN-Referenzen aufbereitet werden sollen.
  IF pi_filia_group-npmat IS INITIAL.
*   EAN-Referenzen.
    pet_message_types-mestyp  = c_mestype_ean.
    APPEND pet_message_types.

*   Setze zu verwendenden Nachrichtentyp für EAN-Referenzen.
    g_mestype_ean = c_mestype_ean.
  ENDIF. " pi_filia_group-NPMAT is initial.

* Falls Nachzugsartikel oder Setzuordnungen aufbereitet werden sollen.
  IF pi_filia_group-npfoa IS INITIAL   OR
     pi_filia_group-npset IS INITIAL.
*   Set-Zuordnungen.
    pet_message_types-mestyp  = c_mestype_set.
    APPEND pet_message_types.

*   Setze zu verwendenden Nachrichtentyp für Set-Zuordnungen.
    g_mestype_set = c_mestype_set.
  ENDIF. " pi_filia_group-NPFOA is initial   or  ...

* Falls Personendaten aufbereitet werden sollen.
  IF pi_filia_group-npcus IS INITIAL.
*   Personendaten.
*   Falls die Personendaten nicht reduziert werden sollen.
    IF pi_filia_group-meper = space.
      pet_message_types-mestyp  = c_mestype_pers.

*     Setze zu verwendenden Nachrichtentyp für Personendaten
      g_mestype_pers = c_mestype_pers.

*   Falls die Personendaten reduziert werden sollen.
    ELSE. " pi_filia_group-meper <> space.
      pet_message_types-mestyp  = pi_filia_group-meper.

*     Setze zu verwendenden Nachrichtentyp für Personendaten
      g_mestype_pers = pi_filia_group-meper.
    ENDIF. " pi_filia_group-meper = space.

    APPEND pet_message_types.
  ENDIF. " pi_filia_group-NPCUS is initial.

* Falls Aktionsrabatte aufbereitet werden sollen.
  IF NOT pi_filia_group-promo_rebate IS INITIAL.
*** Erweiterung für Aktionsrabatte (HPR-Projekt)
*   Aktionsrabatte.
    pet_message_types-mestyp  = c_mestype_prom.
    APPEND pet_message_types.

    g_mestype_prom = c_mestype_prom.
  ENDIF. " not pi_filia_group-PROMO_REBATE is initial.

  IF pi_only_pointer_msgtypes = space.
*** Erweiterung Bonuskäufe Rel.4.6A (GL)
*   Bonuskäufe.
    pet_message_types-mestyp  = c_mestype_bby.
    APPEND pet_message_types.

    g_mestype_bby = c_mestype_bby.

*   Nachzugsartikel.
    pet_message_types-mestyp  = c_mestype_nart.
    APPEND pet_message_types.

*   Setze zu verwendenden Nachrichtentyp für Nachzugsartikel.
    g_mestype_nart = c_mestype_nart.


*   Steuern.
    pet_message_types-mestyp  = c_mestype_steu.
    APPEND pet_message_types.

*   Setze zu verwendenden Nachrichtentyp für Steuern
    g_mestype_steu = c_mestype_steu.


*   Wechselkurse.
    pet_message_types-mestyp  = c_mestype_cur.
    APPEND pet_message_types.

*   Setze zu verwendenden Nachrichtentyp für Wechselkurse.
    g_mestype_cur = c_mestype_cur.
  ENDIF. " PI_ONLY_POINTER_MSGTYPES = SPACE.


ENDFORM. " POS_MESSAGE_TYPES_GET


*eject
************************************************************************
FORM idoc_data_assume
     TABLES   pit_idoc_data_temp STRUCTURE gt_idoc_data_temp
     USING    pxt_idoc_data      TYPE short_edidd
              px_segment_counter LIKE g_segment_counter
              pi_seg_local_cnt   TYPE i.
************************************************************************
* Übernehme die IDOC-Daten aus Temporärtabelle.
* ----------------------------------------------------------------------
* PARAMETER:
* PIT_IDOC_DATA_TEMP: Tabelle mit einem umzusetzenden IDOC-Satz.

* PXT_IDOC_DATA     : Tabelle mit allen Sätzen eines IDOC's.

* PX_SEGMENT_COUNTER: Anzahl der Einträge in PXT_IDOC_DATA.

* PI_SEG_LOCAL_CNT  : Anzahl der Einträge in PIT_IDOC_DATA_TEMP.
*                     wird nicht mehr benötigt.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA:  i_short_idoc_data TYPE pos_short_edidd.

  FIELD-SYMBOLS: <f> TYPE edidd.


* Übernehme die IDOC_Daten aus Temporärtabelle.
  LOOP AT pit_idoc_data_temp ASSIGNING <f>.
    i_short_idoc_data-segnam = <f>-segnam.
    i_short_idoc_data-sdata  = <f>-sdata.
    APPEND i_short_idoc_data TO pxt_idoc_data.

*   Aktualisiere Segmentzähler
    ADD 1 TO px_segment_counter.
  ENDLOOP.                             " AT PIT_IDOC_DATA_TEMP.

* Aktualisiere Segmentzähler
* px_segment_counter = px_segment_counter + pi_seg_local_cnt.

ENDFORM.                               " IDOC_DATA_ASSUME


*eject
************************************************************************
FORM mara_select
     USING  pe_mara         STRUCTURE mara
            VALUE(pi_matnr) LIKE mara-matnr.
************************************************************************
* Liefert einen einzelnen MARA-Satz zurück.
* Mit interner Pufferung.
* ----------------------------------------------------------------------
* PARAMETER:
* PE_MARA  : MARA-Satz.

* PI_MATNR : Materialnummer des zu bestimmenden MARA-Satzes.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: tabix LIKE sy-tabix.

* Rücksetze Ausgabestruktur.
  CLEAR: pe_mara.


* Falls die Pufferzeile bereits die nötigen Daten enthält.
  IF gt_mara_buf-matnr = pi_matnr.
    MOVE-CORRESPONDING gt_mara_buf TO pe_mara.

* Falls die Kopfzeile des Puffers nicht die nötigen Daten enthält,
* dann Suche im Puffer nach den Daten.
  ELSE.
*   Falls Parallelverarbeitung aktiv ist, dann internen Puffer
*   aufbauen.
    IF NOT g_parallel IS INITIAL.
*     Lese Daten aus internen Puffer.
      READ TABLE gt_mara_buf WITH KEY
                 matnr = pi_matnr
                 BINARY SEARCH.

*     Falls die Daten im Puffer gefunden wurden.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING gt_mara_buf TO pe_mara.

*     Falls keine Werte gefunden wurden, dann lese von DB.
      ELSE. " sy-subrc <> 0.
        tabix = sy-tabix.

*       Rücksetze 3000-Zeilen-Puffer, falls nötig.
        IF g_mara_count > c_max_mara_buf.
          REFRESH: gt_mara_buf.
          CLEAR:   g_mara_count.
        ENDIF. " g_mara_count > c_max_mara_buf.

*       Lese Daten von DB.
        CALL FUNCTION 'MARA_SINGLE_READ'
          EXPORTING
            maxtz             = 10
            matnr             = pi_matnr
          IMPORTING
            wmara             = mara
          EXCEPTIONS
            lock_on_material  = 1
            lock_system_error = 2
            wrong_call        = 3
            not_found         = 4
            OTHERS            = 5.

*       Falls Daten gelesen wurden.
        IF sy-subrc = 0.
*         Übernehme Daten in den Pufferzeile.
          MOVE-CORRESPONDING mara TO gt_mara_buf.
          INSERT gt_mara_buf INDEX tabix.

*         Aktualisiere Pufferzähler.
          ADD 1 TO g_mara_count.

*         Fülle Ausgabestruktur.
          pe_mara = mara.
        ENDIF. " sy-subrc = 0 auf gt_mara_buf
      ENDIF. " sy-subrc = 0.

*   Falls Parallelverarbeitung inaktiv ist, dann nur Standardpuffer
*   verwenden.
    ELSE. " g_parallel is initial.
*     Lese Daten von DB.
      CALL FUNCTION 'MARA_SINGLE_READ'
        EXPORTING
          maxtz             = c_max_mara_buf
          matnr             = pi_matnr
        IMPORTING
          wmara             = mara
        EXCEPTIONS
          lock_on_material  = 1
          lock_system_error = 2
          wrong_call        = 3
          not_found         = 4
          OTHERS            = 5.

*     Falls Daten gelesen wurden.
      IF sy-subrc = 0.
*       Übernehme Daten in den Pufferzeile.
        MOVE-CORRESPONDING mara TO gt_mara_buf.

*       Fülle Ausgabestruktur.
        pe_mara = mara.
      ENDIF. " sy-subrc = 0 auf MARA
    ENDIF. " not g_parallel is initial.
  ENDIF. " gt_mara_buf-matnr = pi_matnr.


ENDFORM.                               " Mara_select


*eject
************************************************************************
FORM mvke_select
     USING  pe_mvke         STRUCTURE mvke
            VALUE(pi_matnr) LIKE mvke-matnr
            VALUE(pi_vkorg) LIKE mvke-vkorg
            VALUE(pi_vtweg) LIKE mvke-vtweg.
************************************************************************
* Liefert einen einzelnen MVKE-Satz zurück.
* Mit interner Pufferung.
* ----------------------------------------------------------------------
* PARAMETER:
* PE_MVKE  : MVKE-Satz.

* PI_MATNR : Materialnummer des zu bestimmenden MVKE-Satzes.

* PI_VKORG : Verkaufsorganisation des zu bestimmenden MVKE-Satzes.

* PI_VTWEG : Vertriebsweg des zu bestimmenden MVKE-Satzes.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: tabix LIKE sy-tabix.


* Rücksetze Ausgabestruktur.
  CLEAR: pe_mvke.

* Falls die Kopfzeile des Puffers bereits die nötigen Daten enthält.
  IF gt_mvke_buf-matnr = pi_matnr    AND
     gt_mvke_buf-vkorg = pi_vkorg    AND
     gt_mvke_buf-vtweg = pi_vtweg.
    MOVE-CORRESPONDING gt_mvke_buf TO pe_mvke.

* Falls die Kopfzeile des Puffers nicht die nötigen Daten enthält,
* dann Suche im Puffer nach den Daten.
  ELSE.
*   Falls Parallelverarbeitung aktiv ist, dann internen Puffer
*   aufbauen.
    IF NOT g_parallel IS INITIAL.
*     Lese Daten aus internen Puffer.
      READ TABLE gt_mvke_buf WITH KEY
           matnr = pi_matnr
           vkorg = pi_vkorg
           vtweg = pi_vtweg
           BINARY SEARCH.

*     Falls die Daten im Puffer gefunden wurden.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING gt_mvke_buf TO pe_mvke.

*     Falls keine Werte gefunden wurden, dann lese von DB.
      ELSE. " sy-subrc <> 0.
        tabix = sy-tabix.

*       Rücksetze Zeilen-Puffer, falls nötig.
        IF g_mvke_count > c_max_mvke_buf.
          REFRESH: gt_mvke_buf.
          CLEAR:   g_mvke_count.
        ENDIF. " g_MVKE_count > c_max_MVKE_buf.

*       Lese Daten von DB.
        CALL FUNCTION 'MVKE_SINGLE_READ'
          EXPORTING
            maxtz             = 10
            matnr             = pi_matnr
            vkorg             = pi_vkorg
            vtweg             = pi_vtweg
          IMPORTING
            wmvke             = mvke
          EXCEPTIONS
            lock_on_mvke      = 1
            lock_system_error = 2
            wrong_call        = 3
            not_found         = 4
            OTHERS            = 5.

*       Falls Daten gelesen wurden.
        IF sy-subrc = 0.
*         Übernehme Daten in den Puffer.
          MOVE-CORRESPONDING mvke TO gt_mvke_buf.
          INSERT gt_mvke_buf INDEX tabix.

*         Aktualisiere Pufferzähler.
          ADD 1 TO g_mvke_count.

*         Fülle Ausgabestruktur.
          pe_mvke = mvke.
        ENDIF. " sy-subrc = 0 auf MVKE
      ENDIF. " sy-subrc = 0  auf gt_MVKE_buf

*   Falls Parallelverarbeitung inaktiv ist, dann nur Standardpuffer
*   verwenden.
    ELSE. " g_parallel is initial.
*     Lese Daten von DB.
      CALL FUNCTION 'MVKE_SINGLE_READ'
        EXPORTING
          maxtz             = c_max_mvke_buf
          matnr             = pi_matnr
          vkorg             = pi_vkorg
          vtweg             = pi_vtweg
        IMPORTING
          wmvke             = mvke
        EXCEPTIONS
          lock_on_mvke      = 1
          lock_system_error = 2
          wrong_call        = 3
          not_found         = 4
          OTHERS            = 5.

*     Falls Daten gelesen wurden.
      IF sy-subrc = 0.
*       Übernehme Daten in den Puffer.
        MOVE-CORRESPONDING mvke TO gt_mvke_buf.

*       Fülle Ausgabestruktur.
        pe_mvke = mvke.
      ENDIF. " sy-subrc = 0 auf MVKE

    ENDIF. " not g_parallel is initial.
  ENDIF. " gt_MVKE_buf-matnr = pi_matnr.


ENDFORM.                               " MVKE_select


*eject
************************************************************************
FORM mara_prefetch
     TABLES pit_wlk2        STRUCTURE gt_wlk2.
************************************************************************
* Prefetch auf den MARA-Puffer. Erfolgt einmal pro Filialgruppe.
* ----------------------------------------------------------------------
* PARAMETER:
* PIT_WLK2: Alle Artikel, die innerhalb dieser Filiale bewirtschaftet
*           werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: BEGIN OF t_pre03 OCCURS 0.
      INCLUDE STRUCTURE pre03.
  DATA: END OF t_pre03.


* Falls der MARA-Puffer vorgefüllt werden soll.
  IF g_mara_buf_filled IS INITIAL.
*   Prüfe, ob bereits alle in dieser Filiale bewirtschafteten
*   Artikel eingelesen wurden.
    READ TABLE pit_wlk2 INDEX 1.

*   Falls bereits alle in dieser Filiale bewirtschafteten
*   Artikel eingelesen wurden, dann kann ein Prefetch auf den
*   Puffer stattfinden.
    IF sy-subrc = 0.
      LOOP AT pit_wlk2.
        APPEND pit_wlk2-matnr TO t_pre03.
      ENDLOOP. " at pit_wlk2.

*     Prefetch auf Tabelle MARA.
      CALL FUNCTION 'MARA_ARRAY_READ'
        TABLES
          ipre03               = t_pre03
        EXCEPTIONS
          enqueue_mode_changed = 1
          OTHERS               = 2.

*     Prüfe, ob bereits Daten im Puffer vorhanden sind.
*     read table gt_mara_buf index 1.

*     Falls schon Daten im Puffer vorhanden sind.
*     if sy-subrc = 0.
*       Ergänze Puffer mit den MARA-Daten aller in dieser Filiale
*       bewirtschafteten Artikel.
*       select * from  mara
*              appending corresponding fields of table gt_mara_buf
*              for all entries in pit_wlk2
*              where matnr  = pit_wlk2-matnr.

*       Daten sortieren
*       sort gt_mara_buf by matnr.
*
*       Lösche mehrfach-Einträge
*       delete adjacent duplicates from gt_mara_buf
*              comparing matnr.
*
*     Falls noch keine Daten im Puffer vorhanden sind.
*     else. " sy-subrc <> 0.
*       Fülle Puffer mit den MARA-Daten aller in dieser Filiale
*       bewirtschafteten Artikel.
*       select * from  mara
*              into corresponding fields of table gt_mara_buf
*              for all entries in pit_wlk2
*              where matnr  = pit_wlk2-matnr.
*
*       Daten sortieren
*       sort gt_mara_buf by matnr.
*     endif. " sy-subrc = 0.

*     Sorge dafür, daß vorerst kein weiterer Prefetch für den
*     MARA-Puffer erfolgt.
      g_mara_buf_filled = 'X'.
    ENDIF. " sy-subrc = 0.
  ENDIF. " g_mara_buf_filled is initial.


ENDFORM.                               " mara_prefetch


*eject
************************************************************************
FORM nart_select
     TABLES pet_nart  STRUCTURE gt_nart_buf.
************************************************************************
* Bestimmt alle Nachzugsartikel aus Tabelle MARA.
* Mit interner Pufferung.
* ----------------------------------------------------------------------
* PARAMETER:
* PET_NART : Artikelnummern der Nachzugsartikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
   "MEINS und MLGUT wird für gt_nart_buf und IF Anweisung benötigt, Hilfsstruktur
   TYPES: BEGIN OF gs_nart_buf_extended,
      matnr TYPE MATNR,
      matkl TYPE MATKL,
      meins TYPE MEINS,
      mlgut TYPE W_MITLEERG,
    END OF gs_nart_buf_extended.



  DATA:
        lv_is_multi_lvl_struc_art TYPE abap_bool,
        lt_nart_buf TYPE TABLE OF GS_NART_BUF_EXTENDED,
        ls_nart_buf TYPE GS_NART_BUF_EXTENDED,
        ls_nart_buf_tmp LIKE LINE OF GT_NART_BUF.




* Rücksetze Ausgabestruktur.
  REFRESH: pet_nart.

* Prüfe, ob der Puffer bereits die nötigen Daten enthält.
  READ TABLE gt_nart_buf INDEX 1.


* Falls der Puffer noch keine Daten enthält.
  IF sy-subrc <> 0.
*   Fülle Puffertabelle.
    " Aus MARA alle Vollgüter, Displays, Prepacks und Sales Sets auslesen
     SELECT matnr matkl meins mlgut FROM mara
           INTO CORRESPONDING FIELDS OF TABLE lt_nart_buf
           WHERE  ATTYP = if_struc_art_multi_lvl_const=>co_attyp-display_art
                  OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-prepack_art
                  OR ATTYP = if_struc_art_multi_lvl_const=>co_attyp-sales_set_art
                  OR mlgut <> space .


    "Loop über alle selektierten Artikel. Lediglich Vollgüter und Multi-Level-Structured-Articles werden in gt_nart_buf geschrieben
    LOOP AT lt_nart_buf INTO ls_nart_buf.
      IF ls_nart_buf-mlgut = space.
       LV_IS_MULTI_LVL_STRUC_ART = cl_struc_art_multi_lvl_generic=>get_single_instance( )->is_multi_lvl_struc_art(
          iv_matnr = ls_nart_buf-matnr
          iv_erfme = ls_nart_buf-meins
          ).
      ENDIF.

       IF LV_IS_MULTI_LVL_STRUC_ART = abap_true OR ls_nart_buf-mlgut  <> space.
          MOVE-CORRESPONDING ls_nart_buf TO ls_nart_buf_tmp.
          APPEND ls_nart_buf_tmp TO gt_nart_buf.
       ENDIF.
       CLEAR lv_is_multi_lvl_struc_art.
    ENDLOOP.
  ENDIF. " sy-subrc = 0

* Fülle Ausgabestruktur.
  pet_nart[] = gt_nart_buf[].



ENDFORM.                               " nart_select


*eject
************************************************************************
FORM sets_select
     TABLES pet_sets  STRUCTURE gt_sets_buf.
************************************************************************
* Bestimmt alle Setartikel aus Tabelle MARA.
* Mit interner Pufferung.
* ----------------------------------------------------------------------
* PARAMETER:
* PET_SETS: Artikelnummern der Nachzugsartikel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Rücksetze Ausgabetabelle.
  REFRESH: pet_sets.

* Prüfe, ob der Puffer bereits die nötigen Daten enthält.
  READ TABLE gt_sets_buf INDEX 1.

* Falls der Puffer noch keine Daten enthält.
  IF sy-subrc <> 0.
*-- fill buffer table
    SELECT matnr matkl FROM mara
           INTO CORRESPONDING FIELDS OF TABLE gt_sets_buf
           WHERE attyp = c_setartikel.                  "#EC CI_NOFIELD
  ENDIF. " sy-subrc = 0

* Fülle Ausgabestruktur.
  pet_sets[] = gt_sets_buf[].

ENDFORM.                               " sets_select


*eject
************************************************************************
FORM mara_by_matkl_select
     TABLES pet_matnr       STRUCTURE gt_matnr
     USING  VALUE(pi_matkl) LIKE mara-matkl.
************************************************************************
* Liefert zu einer Warengruppe alle dieser Warengruppe zugeordneten
* Artikelnummern.
* Mit interner Pufferung der Daten der letzten Warengruppe.
* ----------------------------------------------------------------------
* PARAMETER:
* PET_MATNR: Alle Materialnummern, die der Warengruppe PI_MATKL
*            zugeordnet sind.
* PI_MATKL : Warengruppe der zu bestimmenden MARA-Sätze.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Rücksetze Ausgabetabelle.
  REFRESH: pet_matnr.
  CLEAR:   pet_matnr.

* Falls die Warengruppe mit der des Puffers übereinstimmt.
  IF g_matkl_buf = pi_matkl.
    pet_matnr[] = gt_matnr_buf[].

* Falls die MARA-Daten neu gelesen werden müssen.
  ELSE. " g_matkl_buf <> pi_matkl.
*   Rücksetze MATNR-Puffer.
    REFRESH: gt_matnr_buf.
    CLEAR:   gt_matnr_buf, g_matkl_buf.

*   Lese Daten von DB. Benutze View M_MAT1L.
*   select matnr   from  m_mat1l
*          into (gt_matnr_buf-matnr)
*          where matkl = pi_matkl.
*     append gt_matnr_buf.
*   endselect.

    SELECT * FROM  m_mat1l
           INTO CORRESPONDING FIELDS OF TABLE gt_matnr_buf
           WHERE matkl = pi_matkl.

*   Falls Daten gelesen wurden.
    IF sy-subrc = 0.
*     Daten sortieren
      SORT gt_matnr_buf BY matnr.

*     Daten komprimieren.
      DELETE ADJACENT DUPLICATES FROM gt_matnr_buf
             COMPARING ALL FIELDS.

*     Übernehme Daten in die Ausgabetabelle.
      pet_matnr[] = gt_matnr_buf[].

*     Zwischenspeichern der übergebenen Warengruppe in globaler
*     Variable.
      g_matkl_buf = pi_matkl.
    ENDIF. " sy-subrc = 0
  ENDIF. " g_matkl_buf = pi_matkl.


ENDFORM.                               " mara_by_matkl_select


*eject
************************************************************************
FORM ean_by_date_get
     USING  pi_artnr      LIKE wpmarm-matnr
            pi_vrkme      LIKE wpmarm-meinh
            pi_datum      LIKE syst-datum
            pe_loesch_ean LIKE wpdel-ean
            pe_fehlercode LIKE syst-subrc.
************************************************************************
* Besorge die EAN eines Artikels zu einem bestimmten Datum.
* ----------------------------------------------------------------------
* PARAMETER:
* PI_ARTNR     : Artikelnummer.

* PI_VRKME     : Verkaufsmengeneinheit.

* PI_DATUM     : Datum, zu dem die EAN besorgt werden soll.

* PE_LOESCH_EAN: Lösch-EAN.

* PE_FEHLERCODE: > 0, wenn EAN nicht bestimmt werden konnte.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: no_record_found_marm.

  DATA: BEGIN OF t_imarm OCCURS 1.
      INCLUDE STRUCTURE gt_imarm.
  DATA: END OF t_imarm.

* Nur als Dummy für FB-Aufruf.
  DATA: BEGIN OF t_mara OCCURS 1.
      INCLUDE STRUCTURE gt_imara.
  DATA: END OF t_mara.


* Initialisieren der Datentabellen
  REFRESH: t_imarm, t_mara.
  CLEAR:   t_imarm, t_mara.
  CLEAR:   pe_fehlercode, pe_loesch_ean.

* Füllen der einzelnen Tabellenschlüssel.
  t_imarm-mandt = sy-mandt.
  t_imarm-matnr = pi_artnr.
  t_imarm-meinh = pi_vrkme.
  APPEND t_imarm.

* Besorge Material-Stammdaten. ### zukünftige Änderung
* call function 'MATERIAL_CHANGE_DOCUMENTATION'
*      exporting
*           date_from            = pi_datum
*           date_to              = pi_datum
*           explosion            = 'X'
*           indicator            = 'X'
*      importing
*           no_record_found_marm = no_record_found_marm
*      tables
*           jmara                = t_mara
*           jmarm                = t_imarm
*      exceptions
*           no_record_found_mara = 01
*           wrong_date_relation  = 02.

  CALL FUNCTION 'POS_MATERIAL_GET'
    EXPORTING
      marm_ean_check       = 'X'
      pi_exception_mode    = 'X'
    IMPORTING
      no_record_found_marm = no_record_found_marm
    TABLES
      p_t_cmara            = t_mara
      p_t_cmarm            = t_imarm
    EXCEPTIONS
      no_record_found_mara = 01
      OTHERS               = 02.

* Falls Fehler auftraten.
  IF sy-subrc <> 0 OR no_record_found_marm <> space.
*   Zwischenspeichern des Returncodes.
    pe_fehlercode = sy-subrc.

* Falls keine Fehler auftraten
  ELSE.
*   Übernehme Lösche-EAN in Ausgabevariable.
    READ TABLE t_imarm INDEX 1.
    pe_loesch_ean = t_imarm-ean11.
  ENDIF. " SY-SUBRC <> 0 OR ...


ENDFORM.                               " EAN_BY_DATE_GET


*eject
************************************************************************
FORM old_value_get
     USING  pi_pointer   STRUCTURE gt_pointer
            pe_value_old
            pe_not_found LIKE wpmara-chgflag.
************************************************************************
* Besorge VALUE_OLD aus Änderungsbeleg.
* ----------------------------------------------------------------------
* PARAMETER:
* PI_POINTER   : Key-Daten der Selektion.

* PE_VALUE_OLD : Ergebniswert.

* PE_NOT_FOUND : = 'X', wenn kein Wert gefunde oder SPACE.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Initialisiere Returncode.
  CLEAR pe_not_found.

* Lese Änderungsbelegpositionen.
  SELECT SINGLE * FROM  cdpos
         WHERE  objectclas  = pi_pointer-cdobjcl
         AND    objectid    = pi_pointer-cdobjid
         AND    changenr    = pi_pointer-cdchgno
         AND    tabname     = pi_pointer-tabname
         AND    tabkey      = pi_pointer-tabkey
         AND    fname       = pi_pointer-fldname
         AND    chngind     = pi_pointer-cdchgid.

  IF sy-subrc = 0.
*   Falls ein alter Wert <> SPACE gefunden wurde.
    IF cdpos-value_old <> space.
*     Übernahme Ergebniswert.
      pe_value_old = cdpos-value_old.
    ELSE. " cdpos-value_old = space.
*     Merken, daß kein alter Wert gefunden wurde.
      pe_not_found = 'X'.
    ENDIF. " cdpos-value_old <> space.
  ENDIF. " sy-subrc = 0.

  IF sy-subrc <> 0.
    pe_not_found = 'X'.
  ENDIF. " sy-subrc <> 0.


ENDFORM. " old_value_get


* eject.
************************************************************************
FORM mat_by_date_get
     TABLES pet_marm     STRUCTURE marm
     USING  pe_mara      STRUCTURE mara
            pi_artnr     LIKE mara-matnr
            pi_vrkme     TYPE c
            pi_datum     LIKE syst-datum
            pi_get_mara  TYPE c
            pi_get_marm  TYPE c
            pe_no_found  LIKE wpmara-chgflag.
************************************************************************
* FUNKTION:
* Besorge Material-Stammdaten für den Download Artikelstamm aus
* internen Puffer oder von DB.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_VRKME    : Tabelle der Verkaufsmengeneinheiten für Datum
*                PI_DATUM
* PI_ARTNR     : Artikelnummer der Selektion.

* PE_MARA      : Mara-Daten zum Selektionsdatum.

* PI_DATUM     : Datum der Selektion.

* PI_GET_MARA  : = 'X', wenn MARA-Daten sollen gelesen werden sollen,
*                sonst SPACE.
* PI_GET_MARM  : = 'X', wenn MARM-Daten sollen gelesen werden sollen,
*                sonst SPACE.
* PE_NO_FOUND  : = 'X', wenn keine MARM- oder MARA-Daten
*                gefunden wurden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: key1 LIKE marm-meinh,
        key2 LIKE marm-meinh.

  DATA: BEGIN OF t_imara OCCURS 1.
      INCLUDE STRUCTURE wpmara.
  DATA: END OF t_imara.

  DATA: BEGIN OF t_imarm OCCURS 10.
      INCLUDE STRUCTURE wpmarm.
  DATA: END OF t_imarm.


* Initialisieren der Tabellen
  REFRESH: t_imara, t_imarm, pet_marm.
  CLEAR:   t_imara, t_imarm, pet_marm, pe_no_found.

  IF pi_get_mara <> space.
    t_imara-mandt = sy-mandt.
    t_imara-matnr = pi_artnr.
    APPEND t_imara.
  ENDIF. " pi_get_mara <> space.

  IF pi_get_marm <> space.
    t_imarm-mandt = sy-mandt.
    t_imarm-matnr = pi_artnr.
    t_imarm-meinh = pi_vrkme.
    APPEND t_imarm.
  ENDIF. " pi_get_marm <> space.

* ### zukünftige Änderung
* Besorge Material-Stammdaten.
* call function 'MATERIAL_CHANGE_DOCUMENTATION'
*      exporting
*           date_from            = pi_datum
*           date_to              = pi_datum
*           explosion            = 'X'
*           indicator            = 'X'
*      importing
*           no_record_found_marm = pe_no_found
*      tables
*           jmara                = t_imara
*           jmarm                = t_imarm
*      exceptions
*           no_record_found_mara = 01
*           wrong_date_relation  = 02.

  CALL FUNCTION 'POS_MATERIAL_GET'
    EXPORTING
      marm_ean_check       = 'X'
      pi_exception_mode    = 'X'
    IMPORTING
      no_record_found_marm = pe_no_found
    TABLES
      p_t_cmara            = t_imara
      p_t_cmarm            = t_imarm
    EXCEPTIONS
      no_record_found_mara = 01
      OTHERS               = 02.

* Falls kein MARA-Satz gefunden wurde.
  IF sy-subrc <> 0.
    pe_no_found = 'X'.
    EXIT.
  ENDIF. " sy-subrc <> 0.

* Übernahme der MARA-Daten in die Ausgabestruktur.
  IF pi_get_mara <> space.
    CLEAR: pe_mara.
    READ TABLE t_imara INDEX 1.
    MOVE-CORRESPONDING t_imara TO pe_mara.
  ENDIF. " pi_get_mara <> space.

* Übernahme der MARM-Daten in die Ausgabetabelle.
  IF pi_get_marm <> space.
    SORT t_imarm BY meinh.
    CLEAR: key1, key2.
    LOOP AT t_imarm.
      key2 = t_imarm-meinh.
      IF key1 <> key2.
        key1 = key2.
        MOVE-CORRESPONDING t_imarm TO pet_marm.
        APPEND pet_marm.
      ENDIF. " key1 <> key2.
    ENDLOOP. " at t_imarm.
  ENDIF. " pi_get_marm <> space.


ENDFORM. " mat_by_date_get

* eject.
************************************************************************
FORM listed_articles_get
     TABLES pxt_wlk2 STRUCTURE gt_wlk2
     USING  pi_vkorg LIKE wpstruc-vkorg
            pi_vtweg LIKE wpstruc-vtweg
            pi_filia LIKE t001w-werks
            pi_datab LIKE syst-datum
            pi_datbi LIKE syst-datum.
************************************************************************
* FUNKTION:
* Besorge alle Artikel, die innerhalb des Betrachtungszeitraum
* in Filiale PI_FILIA bewirtschaftet werden.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_WLK2: Liste der selektierten Artikel.

* PI_VKORG: Verkaufsorganisation.

* PI_VTWEG: Vertriebsweg.

* PI_FILIA: Filiale.

* PI_DATAB: Beginn des Betrachtungszeitraums.

* PI_DATBI: Ende   des Betrachtungszeitraums.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Prüfe, ob Artikel innerhalb des Betrachtungszeitraums
* von dieser Filiale bewirtschaftet werden.
  READ TABLE pxt_wlk2 INDEX 1.

* Falls interne Listungstabelle nicht gefüllt ist, dann
* besorge die entsprechenden Bewirtschaftungszeiträume von DB.
  IF sy-subrc <> 0 OR pxt_wlk2-werks <> pi_filia.
*  B: New listing check logic => Note 1982796
    IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
      AND gs_twpa-marc_chk IS NOT INITIAL.
*   New Lsiting logic: read WLK2 and check MARC if enries exists
      CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
        EXPORTING
          ip_access_type = '1'   " WLK2 access with store
          ip_vkorg       = pi_vkorg
          ip_vtweg       = pi_vtweg
          ip_filia       = pi_filia
          ip_date_from   = pi_datab
          ip_date_to     = pi_datbi
          is_filia_const = gi_filia_const
        TABLES
          pet_wlk2       = pxt_wlk2.
    ELSE.
      CALL FUNCTION 'WLK2_MATERIAL_FOR_FILIA'
        EXPORTING
          pi_datab        = pi_datab
          pi_datbi        = pi_datbi
          pi_vkorg        = pi_vkorg
          pi_vtweg        = pi_vtweg
          pi_filia        = pi_filia
        TABLES
          wlk2_input      = pxt_wlk2
        EXCEPTIONS
          werks_not_found = 01
          no_wlk2         = 02
          no_wlk2_listing = 03.
*   Löschen nicht mehr benötigter globaler interner Tabellen
      CALL FUNCTION 'WLK2_REFRESH_INTERNAL_BUFFERS'.
    ENDIF.                                               " Note 1982796
    READ TABLE pxt_wlk2 INDEX 1.

*   Wenn Daten gefunden wurden.
    IF sy-subrc = 0.
*--- optimization for MARA: control refreshment of MARA buffer
*--- if this sub-routine is called for very first time for a
*--- store, the buffer contains all articles which are listed
*--- in the store. This can be more articles than the package
*--- size. Therefore the buffer is refreshed. Just before the
*--- articles of the first package are determined, the flag
*--- gv_mara_buffer_refresh is set to abap_false.
      IF gv_mara_buffer_refresh = abap_true.
*     Lösche internen MARA-Buffer.
        CALL FUNCTION 'MARA_ARRAY_READ'
          EXPORTING
            kzrfb                = 'X'
          EXCEPTIONS
            enqueue_mode_changed = 1
            OTHERS               = 2.
      ENDIF.
    ENDIF. " sy-subrc = 0.
  ENDIF.   " sy-subrc <> 0 or pxt_wlk2-filia <> pi_filia.


ENDFORM. " listed_articles_get

* eject.
************************************************************************
FORM pos_listing_check
     TABLES pit_wlk2       STRUCTURE gt_wlk2
            pet_listung    STRUCTURE gt_listung
     USING  pi_filia_group STRUCTURE gt_filia_group
            pi_article     LIKE      mara-matnr
            pi_vrkme       LIKE      wpwlk1-vrkme
            pi_datab       LIKE      wlk1-datab
            pi_datbi       LIKE      wlk1-datbi.
************************************************************************
* FUNKTION:
* Prüfe, ob der Artikel, für diesen Zeitraum innerhalb der Filiale
* bewirtschaftet wird.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WLK2:    Bewirtschaftungszeiträume der Filiale

* PET_LISTUNG: Listungtabelle für den Artikel

* PI_FILIA_GROUP: Filialkonstanten.

* PI_ARTICLE:  Artikelnummer.

* PI_VRKME:    Verkaufsmengeneinheit.

* PI_DATAB:    Beginn des Betrachtungszeitraums.

* PI_DATBI:    Ende des Betrachtungszeitraums.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: t_matnr LIKE gt_matnr    OCCURS 0 WITH HEADER LINE,
        t_marm  LIKE gt_marm_buf OCCURS 0 WITH HEADER LINE.

  REFRESH: pet_listung.

* Prüfe, ob eine EAN vorhanden ist.
  PERFORM marm_select
          TABLES t_matnr
                 t_marm
          USING  'X'          " pi_with_ean
                 pi_article   " pi_matnr
                 pi_vrkme.    " pi_meinh

  READ TABLE t_marm INDEX 1.

* Falls keine EAN vorhanden ist, dann keine Aufbereitung nötig.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF. " sy-subrc <> 0.

* Besorge den Bewirtschaftungszeitraum des Artikels.
  READ TABLE pit_wlk2 WITH KEY
       matnr = pi_article
       vkorg = pi_filia_group-vkorg
       vtweg = pi_filia_group-vtweg
       werks = pi_filia_group-filia
       BINARY SEARCH.
* Falls das Intervall stimmt.
  IF sy-subrc = 0               AND
     pit_wlk2-vkdab <= pi_datbi AND
     pit_wlk2-vkbis >= pi_datab.

*    Fülle Listungstabelle.
    CLEAR: gt_listung.
    gt_listung-artnr = pi_article.
    gt_listung-vrkme = pi_vrkme.
    gt_listung-datbi = pit_wlk2-vkbis.
    gt_listung-datab = pit_wlk2-vkdab.
    APPEND gt_listung.
  ENDIF. " sy-subrc = 0 and


ENDFORM. " POS_listing_check


*eject
************************************************************************
FORM statistic_data_generate_chg
     TABLES pit_wdlsp_buf          STRUCTURE gt_wdlsp_buf
            pit_ot1_f_wrgp         STRUCTURE gt_ot1_f_wrgp
            pit_ot2_wrgp           STRUCTURE gt_ot2_wrgp
            pit_ot3_wrgp           STRUCTURE gt_ot3_wrgp
            pit_ot1_f_artstm       STRUCTURE gt_ot1_f_artstm
            pit_ot2_artstm         STRUCTURE gt_ot2_artstm
            pit_ot3_artstm         STRUCTURE gt_ot3_artstm
            pit_ot1_f_ean          STRUCTURE gt_ot1_f_ean
            pit_ot2_ean            STRUCTURE gt_ot2_ean
            pit_ot3_ean            STRUCTURE gt_ot3_ean
            pit_ot1_f_sets         STRUCTURE gt_ot1_f_sets
            pit_ot2_sets           STRUCTURE gt_ot2_sets
            pit_ot3_sets           STRUCTURE gt_ot3_sets
            pit_ot1_f_nart         STRUCTURE gt_ot1_f_nart
            pit_ot2_nart           STRUCTURE gt_ot2_nart
            pit_ot3_nart           STRUCTURE gt_ot3_nart
            pit_ot1_k_pers         STRUCTURE gt_ot1_k_pers
            pit_ot2_pers           STRUCTURE gt_ot2_pers
            pit_ot3_pers           STRUCTURE gt_ot3_pers
            pit_ot1_f_promreb      STRUCTURE gt_ot1_f_promreb
            pit_ot2_promreb        STRUCTURE gt_ot2_promreb
            pit_ot3_promreb        STRUCTURE gt_ot3_promreb
            pxt_statistik_wdlsp    STRUCTURE gt_statistik_wdlsp
     USING  pi_filia_group         STRUCTURE gt_filia_group
            px_statistik           STRUCTURE gt_statistik
            pi_stat_counter        STRUCTURE gi_stat_counter
            pi_pointer_no          TYPE i.
************************************************************************
* FUNKTION:
* Sammeln von Daten wie Statistikinformationen für spätere
* Listaufbereitung.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WDLSP_BUF         : Tabelle bereits erzeugter
*                         Statuspositionszeilen.
* PIT_OT1_F_WRGP        : Warengruppen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_WRGP          : Warengruppen: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT3_WRGP          : Warengruppen: Objekttabelle 3.

* PIT_OT1_F_ARTSTM      : Artikelstamm: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_ARTSTM        : Artikelstamm: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3.

* PIT_OT1_F_EAN         : EAN-Referenzen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_EAN           : EAN-Referenzen: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT3_EAN           : EAN-Referenzen: Objekttabelle 3.

* PIT_OT1_F_SETS        : Set-Zuordnungen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_SETS          : Set-Zuordnungen: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT3_SETS          : Set-Zuordnungen: Objekttabelle 3.

* PIT_OT1_F_NART        : Nachzugsartikel: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_NART          : Nachzugsartikel: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT3_NART          : Nachzugsartikel: Objekttabelle 3.

* PIT_OT1_K_PERS        : Personendaten: Objekttabelle 1,
*                         Kreditkontrollbereichsabhängig.
* PIT_OT2_PERS          : Personendaten: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT3_PERS          : Personendaten: Objekttabelle 3.

* PIT_OT1_F_PROMREB     : Aktionsrabatte: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_PROMREB       : Aktionsrabatte: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT3_PROMREB       : Aktionsrabatte: Objekttabelle 3,

* PXT_STATISTIK_WDLSP   : Daten für spätere Listaufbereitung.

* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PX_STATISTIK          : Daten für spätere Listaufbereitung.

* PI_STAT_COUNTER       : Zählvariablen für die Anzahl der ignorierten
*                         Objekte.
* PI_POINTER_NO         : Anzahl der selektierten Änderungszeiger.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_statistik1  TYPE i,
        h_statistik2  TYPE i,
        h_statistik3  TYPE i,
        h_statistik_p TYPE i,
        h_result      TYPE i.


  CLEAR: h_statistik1, h_statistik2, h_statistik3, h_statistik_p.

* Bestimme die Anzahl der überprüften Pointer.
  h_statistik_p = pi_pointer_no.

************************************************************************
* Aufbereitung der Statistikinformationen für Warengruppen.
************************************************************************
  DESCRIBE TABLE  pit_ot2_wrgp   LINES h_statistik2.
  DESCRIBE TABLE  pit_ot3_wrgp   LINES h_statistik3.

* Zähle alle filialabhängigen Einträge in PIT_OT1_F_WRGP, die
* diese Filiale betreffen.
  LOOP AT pit_ot1_f_wrgp
       WHERE filia = pi_filia_group-filia.
    ADD 1 TO h_statistik1.
  ENDLOOP. " at pit_ot1_f_wrgp

* Merke Statistikinfo für spätere Listaufbereitung.
  MOVE-CORRESPONDING pi_stat_counter TO px_statistik.
  px_statistik-pointer_anz = h_statistik_p.
  px_statistik-wrgp_anz_1  = h_statistik1.
  px_statistik-wrgp_anz_2  = h_statistik2.
  px_statistik-wrgp_anz_3  = h_statistik3.

************************************************************************
* Aufbereitung der Statistikinformationen für Artikelstamm.
************************************************************************
  CLEAR: h_statistik1, h_statistik2, h_statistik3.

  DESCRIBE TABLE  pit_ot2_artstm   LINES h_statistik2.
  DESCRIBE TABLE  pit_ot3_artstm   LINES h_statistik3.

* Zähle alle filialabhängigen Einträge in PIT_OT1_F_ARTSTM, die
* diese Filiale betreffen.
  LOOP AT pit_ot1_f_artstm
       WHERE filia = pi_filia_group-filia.
    ADD 1 TO h_statistik1.
  ENDLOOP. " at PIT_OT1_F_ARTSTM
  ADD pi_stat_counter-artstm_zus TO h_statistik1.

* Merke Statistikinfo für spätere Listaufbereitung.
  px_statistik-artstm_anz_1  = h_statistik1.
  px_statistik-artstm_anz_2  = h_statistik2.
  px_statistik-artstm_anz_3  = h_statistik3.

************************************************************************
* Aufbereitung der Statistikinformationen für EAN-Referenzen.
************************************************************************
  CLEAR: h_statistik1, h_statistik2, h_statistik3.

  DESCRIBE TABLE  pit_ot2_ean  LINES h_statistik2.
  DESCRIBE TABLE  pit_ot3_ean  LINES h_statistik3.

* Zähle alle filialabhängigen Einträge in PIT_OT1_F_EAN, die
* diese Filiale betreffen.
  LOOP AT pit_ot1_f_ean
       WHERE filia = pi_filia_group-filia.
    ADD 1 TO h_statistik1.
  ENDLOOP. " at PIT_OT1_F_ean
  ADD pi_stat_counter-ean_zus TO h_statistik1.

* Merke Statistikinfo für spätere Listaufbereitung.
  px_statistik-ean_anz_1  = h_statistik1.
  px_statistik-ean_anz_2  = h_statistik2.
  px_statistik-ean_anz_3  = h_statistik3.

**********************************************************************
* Aufbereitung der Statistikinformationen für Setartikel.
************************************************************************
  CLEAR: h_statistik1, h_statistik2, h_statistik3.

  DESCRIBE TABLE  pit_ot2_sets  LINES h_statistik2.
  DESCRIBE TABLE  pit_ot3_sets  LINES h_statistik3.

* Zähle alle filialabhängigen Einträge in PIT_OT1_F_SETS, die
* diese Filiale betreffen.
  LOOP AT pit_ot1_f_sets
       WHERE filia = pi_filia_group-filia.
    ADD 1 TO h_statistik1.
  ENDLOOP. " at PIT_OT1_F_sets
  ADD pi_stat_counter-sets_zus TO h_statistik1.

* Merke Statistikinfo für spätere Listaufbereitung.
  px_statistik-sets_anz_1  = h_statistik1.
  px_statistik-sets_anz_2  = h_statistik2.
  px_statistik-sets_anz_3  = h_statistik3.

************************************************************************
* Aufbereitung der Statistikinformationen für Nachzugsartikel.
************************************************************************
  CLEAR: h_statistik1, h_statistik2, h_statistik3.

  DESCRIBE TABLE  pit_ot2_nart  LINES h_statistik2.
  DESCRIBE TABLE  pit_ot3_nart  LINES h_statistik3.

* Zähle alle filialabhängigen Einträge in PIT_OT1_F_NART, die
* diese Filiale betreffen.
  LOOP AT pit_ot1_f_nart
       WHERE filia = pi_filia_group-filia.
    ADD 1 TO h_statistik1.
  ENDLOOP. " at PIT_OT1_F_nart
  ADD pi_stat_counter-nart_zus TO h_statistik1.
  .
* Merke Statistikinfo für spätere Listaufbereitung.
  px_statistik-nart_anz_1  = h_statistik1.
  px_statistik-nart_anz_2  = h_statistik2.
  px_statistik-nart_anz_3  = h_statistik3.

************************************************************************
* Aufbereitung der Statistikinformationen für Personendaten.
************************************************************************
  CLEAR: h_statistik1, h_statistik2, h_statistik3.

  DESCRIBE TABLE  pit_ot2_pers  LINES h_statistik2.
  DESCRIBE TABLE  pit_ot3_pers  LINES h_statistik3.

* Zähle alle KKBER-abhängigen Einträge in PIT_OT1_K_PERS, die
* diese Filiale betreffen.
  LOOP AT pit_ot1_k_pers
       WHERE kkber = pi_filia_group-kkber.
    ADD 1 TO h_statistik1.
  ENDLOOP. " at PIT_OT1_K_pers

* Merke Statistikinfo für spätere Listaufbereitung.
  px_statistik-pers_anz_1  = h_statistik1.
  px_statistik-pers_anz_2  = h_statistik2.
  px_statistik-pers_anz_3  = h_statistik3.

************************************************************************
* Aufbereitung der Statistikinformationen für Aktionsrabatte.
************************************************************************
  CLEAR: h_statistik1, h_statistik2, h_statistik3.

  DESCRIBE TABLE  pit_ot2_promreb  LINES h_statistik2.
  DESCRIBE TABLE  pit_ot3_promreb  LINES h_statistik3.

* Zähle alle filialabhängigen Einträge in PIT_OT1_F_PROMREB die
* diese Filiale betreffen.
  LOOP AT pit_ot1_f_promreb
       WHERE kunnr = pi_filia_group-kunnr.
    ADD 1 TO h_statistik1.
  ENDLOOP. " at PIT_OT1_F_PROMREB

* Merke Statistikinfo für spätere Listaufbereitung.
  px_statistik-promreb_anz_1  = h_statistik1.
  px_statistik-promreb_anz_2  = h_statistik2.
  px_statistik-promreb_anz_3  = h_statistik3.



* Merke Statistikinfo für spätere Listaufbereitung.
  CLEAR: pxt_statistik_wdlsp.
  pxt_statistik_wdlsp-group = px_statistik-group.
  pxt_statistik_wdlsp-kunnr = px_statistik-kunnr.

  LOOP AT pit_wdlsp_buf.
    MOVE-CORRESPONDING pit_wdlsp_buf TO pxt_statistik_wdlsp.
    APPEND pxt_statistik_wdlsp.
  ENDLOOP. " at pit_wdlsp_buf.


ENDFORM. " statistic_data_generate_chg


*eject
************************************************************************
FORM list_generate_chg
     TABLES pit_statistik          STRUCTURE gt_statistik
            pit_statistik_wdlsp    STRUCTURE gt_statistik_wdlsp
            pxt_rfcdest            STRUCTURE gt_rfcdest
            pit_filia_group        STRUCTURE gt_filia_group
     USING  pi_jobs_gesamt         LIKE      wpstruc-counter6
            pi_parallel            LIKE      wpstruc-parallel.
************************************************************************
* FUNKTION:
* Ausgabe von Statistikinformationen bzgl. der
* Änderungspointeranalyse, der erzeugten IDOC's und der
* Parallelverarbeitung.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_STATISTIK         : Daten für Listaufbereitung.

* PIT_STATISTIK_WDLSP   : Daten für Listaufbereitung.

* PXT_RFCDEST           : RFC-Destinations bei denen Fehler auftraten.

* PIT_FILIA_GROUP       : Tabelle mit Filialkonstanten

* PI_JOBS_GESAMT        : Gesamtzahl aller parallelen Task.

* PI_PARALLEL           : = 'X', wenn Parallelverarbeitung erfolgte.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_result           LIKE wplistdata-wrgp_anz_1,
        h_lines            LIKE sy-tabix,
        h_counter          LIKE sy-tabix,
        h_laufzeit         TYPE i,
        h_dummy            TYPE p DECIMALS 3,
        h_durchschnitt(11).

  DATA: BEGIN OF t_wdlsp OCCURS 1.
      INCLUDE STRUCTURE wdlsp.
  DATA: END OF t_wdlsp.


* Daten sortieren.
  SORT pit_statistik_wdlsp BY kunnr lfdnr.
  SORT pit_statistik       BY kunnr.
  SORT pxt_rfcdest         BY rfcdest datum uzeit.

* Komprimieren der Daten. Nötig, wenn parallele Prozesse abgegrochen
* waren und seriell wiederholt wurden.
  DELETE ADJACENT DUPLICATES FROM pit_statistik_wdlsp
         COMPARING kunnr lfdnr.
  DELETE ADJACENT DUPLICATES FROM pit_statistik
         COMPARING kunnr.
  DELETE ADJACENT DUPLICATES FROM pxt_rfcdest
         COMPARING ALL FIELDS.

* Bestimme die Anzahl der aufbereiteten Filialen.
  DESCRIBE TABLE pit_statistik LINES h_lines.

* Setzen der Spaltenzahl für Textausgabe.
  NEW-PAGE NO-TITLE LINE-SIZE 100.


  WRITE: / 'Detail-Statistik der Aufbereitung'(059).
  ULINE.

  LOOP AT pit_statistik.
*   Übernehme WDLSP-Daten in Sekundärtabelle.
    REFRESH: t_wdlsp.
    CLEAR:   t_wdlsp.
    LOOP AT pit_statistik_wdlsp
         WHERE group = pit_statistik-group
         AND   kunnr = pit_statistik-kunnr
         AND   ( NOT docnum IS INITIAL ).
      MOVE-CORRESPONDING pit_statistik_wdlsp TO t_wdlsp.
      APPEND t_wdlsp.
    ENDLOOP. " at pit_statistik_wdlsp

*   Beginn der Listausgabe.
    FORMAT COLOR COL_GROUP.
    WRITE: /  'Empfänger:'(007),
              pit_statistik-kunnr.
    FORMAT COLOR OFF.

*   Falls laut Kommunikationsprofil überhaupt keine Objekte
*   aufbereitet werden sollen.
    IF pit_statistik-obj_proc = c_no_object_process.
      WRITE: /6 'Laut Kommunikationsprofil wurden alle Objekte'(039)
                 COLOR COL_NEGATIVE.
      WRITE: /6  'von der Aufbereitung ausgeschlossen'(040)
                 COLOR COL_NEGATIVE.
      SKIP.
      FORMAT COLOR OFF.
    ENDIF. " pit_statistik-obj_proc = c_no_object_process.

    WRITE: 23 'Es wurden insgesamt'(008),
              pit_statistik-pointer_anz COLOR COL_TOTAL,
              'Änderungsbelege überprüft'(009).

    WRITE: /3 'Analyse und Aufbereitung'(026) COLOR COL_HEADING.
    FORMAT COLOR OFF.

************************************************************************
* Ausgabe von Statistikinformationen für Warengruppen.
************************************************************************
*   Falls Warengruppeninformationen gesammelt wurden.
    IF pit_statistik-wrgp_anz_1 <> 0 OR
       pit_statistik-wrgp_anz_2 <> 0 OR
       pit_statistik-wrgp_anz_3 <> 0.

      WRITE: /6 'Warengruppen'(010) COLOR COL_KEY.
      FORMAT COLOR OFF.

*     Falls Filialabhängige Einträge gefunden wurden.
      IF pit_statistik-wrgp_anz_1 <> 0.
        WRITE: /9 'Analysierte filialabhängige Änderungen:'(011),
               57 pit_statistik-wrgp_anz_1 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-wrgp_anz_1 <> 0.

*     Falls Filialunabhängige Einträge gefunden wurden.
      IF pit_statistik-wrgp_anz_2 <> 0.
        WRITE: /9 'Analysierte filialunabhängige Änderungen:'(012),
               57 pit_statistik-wrgp_anz_2 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-wrgp_anz_2 <> 0.

*     Falls Objekte ignoriert wurden.
      IF pit_statistik-wrgp_ign <> 0.
        WRITE: /9 'Ignorierte Objekte:'(021),
               57 pit_statistik-wrgp_ign COLOR COL_NORMAL.
      ENDIF. " pit_statistik-wrgp_ign <> 0.

*     Ausgabe der Gesamtänderungen.
      h_result = pit_statistik-wrgp_anz_3 - pit_statistik-wrgp_ign.
      WRITE: /9 'Aufzubereitende Objekte:'(013),
             57 h_result COLOR COL_NORMAL INTENSIFIED OFF.

      SKIP.
    ENDIF. " pit_statistik-wrgp_anz_1 <> 0 or ...


************************************************************************
* Ausgabe von Statistikinformationen für Artikelstamm.
************************************************************************
*   Falls Artikelstamminformationen gesammelt wurden.
    IF pit_statistik-artstm_anz_1 <> 0 OR
       pit_statistik-artstm_anz_2 <> 0 OR
       pit_statistik-artstm_anz_3 <> 0.

      WRITE: /6 'Artikelstamm'(014) COLOR COL_KEY.
      FORMAT COLOR OFF.

*     Falls Filialabhängige Einträge gefunden wurden.
      IF pit_statistik-artstm_anz_1 <> 0.
        WRITE: /9 'Analysierte filialabhängige Änderungen:'(011),
               57 pit_statistik-artstm_anz_1 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-artsm_anz_1 <> 0.

*     Falls Filialunabhängige Einträge gefunden wurden.
      IF pit_statistik-artstm_anz_2 <> 0.
        WRITE: /9 'Analysierte filialunabhängige Änderungen:'(012),
               57 pit_statistik-artstm_anz_2 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-artsm_anz_2 <> 0.

*     Falls Objekte ignoriert wurden.
      IF pit_statistik-artstm_ign <> 0 OR
         pit_statistik-artstm_bew <> 0.
        h_result = pit_statistik-artstm_ign +
                   pit_statistik-artstm_bew.
        WRITE: /9 'Ignorierte Objekte:'(021),
               57 h_result COLOR COL_NORMAL.
      ENDIF. " pit_statistik-artstm_ign <> 0 or ...

*     Ausgabe der Gesamtänderungen.
      h_result = pit_statistik-artstm_anz_3 - pit_statistik-artstm_ign.
      WRITE: /9 'Aufzubereitende Objekte:'(013),
             57 h_result COLOR COL_NORMAL INTENSIFIED OFF.

      SKIP.
    ENDIF. " pit_statistik-artsm_anz_1 <> 0 or ...


************************************************************************
* Ausgabe von Statistikinformationen für EAN-Referenzen.
************************************************************************
*   Falls Informationen Zu EAN-Referenzen gesammelt wurden.
    IF pit_statistik-ean_anz_1 <> 0 OR
       pit_statistik-ean_anz_2 <> 0 OR
       pit_statistik-ean_anz_3 <> 0.

      WRITE: /6 'EAN-Referenzen'(015) COLOR COL_KEY.
      FORMAT COLOR OFF.

*     Falls Filialabhängige Einträge gefunden wurden.
      IF pit_statistik-ean_anz_1 <> 0.
        WRITE: /9 'Analysierte filialabhängige Änderungen:'(011),
               57 pit_statistik-ean_anz_1 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-ean_anz_1 <> 0.

*     Falls Filialunabhängige Einträge gefunden wurden.
      IF pit_statistik-ean_anz_2 <> 0.
        WRITE: /9 'Analysierte filialunabhängige Änderungen:'(012),
               57 pit_statistik-ean_anz_2 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-ean_anz_2 <> 0.

*     Falls Objekte ignoriert wurden.
      IF pit_statistik-ean_ign <> 0 OR pit_statistik-ean_bew <> 0.
        h_result = pit_statistik-ean_ign + pit_statistik-ean_bew.
        WRITE: /9 'Ignorierte Objekte:'(021),
               57 h_result COLOR COL_NORMAL.
      ENDIF. " pit_statistik-ean_ign <> 0 or ...

*     Ausgabe der Gesamtänderungen.
      h_result = pit_statistik-ean_anz_3 - pit_statistik-ean_ign.
      WRITE: /9 'Aufzubereitende Objekte:'(013),
             57 h_result COLOR COL_NORMAL INTENSIFIED OFF.

      SKIP.
    ENDIF. " pit_statistik-ean_anz_1 <> 0 or ...


************************************************************************
* Ausgabe von Statistikinformationen für Setartikel.
************************************************************************
*   Falls Setartikelstamminformationen gesammelt wurden.
    IF pit_statistik-sets_anz_1 <> 0 OR
       pit_statistik-sets_anz_2 <> 0 OR
       pit_statistik-sets_anz_3 <> 0.

      WRITE: /6 'Set-Zuordnungen'(016) COLOR COL_KEY.
      FORMAT COLOR OFF.

*     Falls Filialabhängige Einträge gefunden wurden.
      IF pit_statistik-sets_anz_1 <> 0.
        WRITE: /9 'Analysierte filialabhängige Änderungen:'(011),
               57 pit_statistik-sets_anz_1 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-sets_anz_1 <> 0.

*     Falls Filialunabhängige Einträge gefunden wurden.
      IF pit_statistik-sets_anz_2 <> 0.
        WRITE: /9 'Analysierte filialunabhängige Änderungen:'(012),
               57 pit_statistik-sets_anz_2 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-sets_anz_2 <> 0.

*     Falls Objekte ignoriert wurden.
      IF pit_statistik-sets_ign <> 0 OR pit_statistik-sets_bew <> 0.
        h_result = pit_statistik-sets_ign + pit_statistik-sets_bew.
        WRITE: /9 'Ignorierte Objekte:'(021),
               57 h_result COLOR COL_NORMAL.
      ENDIF. " pi_stat_counter-sets_ign <> 0 or ...

*     Ausgabe der Gesamtänderungen.
      h_result = pit_statistik-sets_anz_3 - pit_statistik-sets_ign.
      WRITE: /9 'Aufzubereitende Objekte:'(013),
             57 h_result COLOR COL_NORMAL INTENSIFIED OFF.

      SKIP.
    ENDIF. " pit_statistik-sets_anz_1 <> 0 or ...


************************************************************************
* Ausgabe von Statistikinformationen für Nachzugsartikel.
************************************************************************
*   Falls Nachzugsartikelstamminformationen gesammelt wurden.
    IF pit_statistik-nart_anz_1 <> 0 OR
       pit_statistik-nart_anz_2 <> 0 OR
       pit_statistik-nart_anz_3 <> 0.

      WRITE: /6 'Nachzugsartikel'(017) COLOR COL_KEY.
      FORMAT COLOR OFF.

*     Falls Filialabhängige Einträge gefunden wurden.
      IF pit_statistik-nart_anz_1 <> 0.
        WRITE: /9 'Analysierte filialabhängige Änderungen:'(011),
               57 pit_statistik-nart_anz_1 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-nart_anz_1 <> 0.

*     Falls Filialunabhängige Einträge gefunden wurden.
      IF pit_statistik-nart_anz_2 <> 0.
        WRITE: /9 'Analysierte filialunabhängige Änderungen:'(012),
               57 pit_statistik-nart_anz_2 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-nart_anz_2 <> 0.

*     Falls Objekte ignoriert wurden.
      IF pit_statistik-nart_ign <> 0 OR pit_statistik-nart_bew <> 0.
        h_result = pit_statistik-nart_ign + pit_statistik-nart_bew.
        WRITE: /9 'Ignorierte Objekte:'(021),
               57 h_result COLOR COL_NORMAL.
      ENDIF. " pit_statistik-nart_ign <> 0 or ...

*     Ausgabe der Gesamtänderungen.
      h_result = pit_statistik-nart_anz_3 - pit_statistik-nart_ign.
      WRITE: /9 'Aufzubereitende Objekte:'(013),
             57 h_result COLOR COL_NORMAL INTENSIFIED OFF.

      SKIP.
    ENDIF. " pit_statistik-nart_anz_1 <> 0 or ...


************************************************************************
* Ausgabe von Statistikinformationen für Personendaten.
************************************************************************
*   Falls Personendateninformationen gesammelt wurden.
    IF pit_statistik-pers_anz_1 <> 0 OR
       pit_statistik-pers_anz_2 <> 0 OR
       pit_statistik-pers_anz_3 <> 0.

      WRITE: /6 'Personendaten'(018) COLOR COL_KEY.
      FORMAT COLOR OFF.

*     Falls Filialabhängige Einträge gefunden wurden.
      IF pit_statistik-pers_anz_1 <> 0.
        WRITE: /9 'Analys. Kreditkontrollbereichsabhängige Änd.:'(019),
               57 pit_statistik-pers_anz_1 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-pers_anz_1 <> 0.

*     Falls Filialunabhängige Einträge gefunden wurden.
      IF pit_statistik-pers_anz_2 <> 0.
        WRITE: /9 'Analys. Kreditkontrollbereichsunabhängige Änd.:'(020),
                57 pit_statistik-pers_anz_2 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-pers_anz_2 <> 0.

*     Falls Objekte ignoriert wurden.
      IF pit_statistik-pers_ign   <> 0 OR
         pit_statistik-pers_gklim <> 0.
        h_result = pit_statistik-pers_ign +
                   pit_statistik-pers_gklim.
        WRITE: /9 'Ignorierte Objekte:'(021),
               57 h_result COLOR COL_NORMAL.
      ENDIF. " pit_statistik-pers_ign <> 0 or ...

*     Ausgabe der Gesamtänderungen.
      h_result = pit_statistik-pers_anz_3 - pit_statistik-pers_ign.
      WRITE: /9 'Aufzubereitende Objekte:'(013),
             57 h_result COLOR COL_NORMAL INTENSIFIED OFF.

      SKIP.
    ENDIF. " pit_statistik-pers_anz_1 <> 0 or


************************************************************************
* Ausgabe von Statistikinformationen für Aktionsrabatte.
************************************************************************
*   Falls Aktionsrabattinformationen gesammelt wurden.
    IF pit_statistik-promreb_anz_1 <> 0 OR
       pit_statistik-promreb_anz_2 <> 0 OR
       pit_statistik-promreb_anz_3 <> 0.

      WRITE: /6 'Aktionsrabatte'(071) COLOR COL_KEY.
      FORMAT COLOR OFF.

*     Falls Filialabhängige Einträge gefunden wurden.
      IF pit_statistik-promreb_anz_1 <> 0.
        WRITE: /9 'Analysierte filialabhängige Änderungen:'(011),
               57 pit_statistik-promreb_anz_1 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-promreb_anz_1 <> 0.

*     Falls Filialunabhängige Einträge gefunden wurden.
      IF pit_statistik-promreb_anz_2 <> 0.
        WRITE: /9 'Analysierte filialunabhängige Änderungen:'(012),
               57 pit_statistik-promreb_anz_2 COLOR COL_NORMAL.
      ENDIF. " pit_statistik-promreb_anz_2 <> 0.

*     Ausgabe der Gesamtänderungen.
      h_result = pit_statistik-promreb_anz_3.
      WRITE: /9 'Aufzubereitende Objekte:'(013),
             57 h_result COLOR COL_NORMAL INTENSIFIED OFF.

      SKIP.
    ENDIF. " pit_statistik-promreb_anz_1 <> 0 or ...


************************************************************************
* Ausgabe von Statistikinformationen der bereits Erzeugten IDOC's.
************************************************************************
    PERFORM statistic_text_generate_idoc
            TABLES t_wdlsp.

*     Statistik für Triggerfile.
    SKIP.
    WRITE: /6 'Triggerfile für Status-ID:'(001),
              pit_statistik-dldnr COLOR COL_NORMAL.

    CASE pit_statistik-trig_err.
*       Falls keine Fehler aufgetreten sind.
      WHEN 0.
        WRITE:  'erzeugt.'(003).
*       Falls Fehler aufgetreten sind, zu denen es keine
*       Statusprotokolle gibt und die daher separat protokolliert
*       wurden.
      WHEN 1.
        WRITE: /6 'brauchte nicht erzeugt zu werden.'(004)
                   COLOR COL_NEGATIVE,
                  'Keine Nachrichten erforderlich.'(045)
                   COLOR COL_NEGATIVE.
        FORMAT COLOR OFF.
*       Falls Fehler aufgetreten sind, zu denen es
*       Statusprotokolle gibt.
      WHEN 2.
        WRITE: /6 'konnte nicht erzeugt werden'(005)
                   COLOR COL_NEGATIVE,
                  '(--> POS-Ausgangs-Protokoll).'(006)
                   COLOR COL_NEGATIVE.
        FORMAT COLOR OFF.

      WHEN 3.
*         Besorge die zugehörigen Filialkonstanten.
        READ TABLE pit_filia_group WITH KEY
             kunnr = pit_statistik-kunnr.

*         Falls kein Triggerfile erzeugt werden soll.
        IF NOT pit_filia_group-no_trigger IS INITIAL.
*           Falls über das Verteilungsmodell verteilt werden soll.
          IF NOT pit_filia_group-recdt IS INITIAL.
            WRITE:     'wurde nicht erzeugt, da Verteilung'(066),
                   /48 'über Verteilungsmodell erfolgt.'(067).
*          Falls nicht über das Verteilungsmodell verteilt werden soll.
          ELSE.
            WRITE:     'wurde entsprechend POS-Ausgangsprofil'(080),
                   /48 'nicht erzeugt'(081).
          ENDIF. " not pit_filia_group-recdt is initial.
        ENDIF. " not gi_filia_const-no_trigger is initial.
    ENDCASE. " pit_statistik-trig_err.

    ULINE.

  ENDLOOP. " at pit_statistik.


************************************************************************
* Ausgabe von Statistikinformationen bzgl. paralleler Taskaufrufe.
************************************************************************
  PERFORM task_error_text_generate
          TABLES pxt_rfcdest
          USING  pi_jobs_gesamt
                 pi_parallel.

* Berechne die Gesamtzahl aller Segmente
  LOOP AT pit_statistik_wdlsp
       WHERE group  = pit_statistik-group
*       and   doctyp = c_idoctype_artstm
       AND ( NOT docnum IS INITIAL ).

    h_counter = h_counter + pit_statistik_wdlsp-anseg.

  ENDLOOP. " at pit_statistik_wdlsp

* Beende Laufzeitmessung.
  g_time2 = cl_abap_runtime=>create_lr_timer( )->get_runtime( ).

  COMMIT WORK.
  g_runtime_dat2  = sy-datum.
  g_runtime_time2 = sy-uzeit.

* Bestimme die Zeitdifferenz in Sekunden.
  PERFORM time_diff_get USING g_runtime_dat1   g_runtime_time1
                              g_runtime_dat2   g_runtime_time2
                              h_laufzeit.

* Der GET RUN TIME-Befehlt arbeitet nur bis 999 Sekunden, danach
* fängt er wieder von vorne an zu zählen. Daher wird vorsichtshalber ab
* 950 Sekunden die Laufzeit über die Systemzeit bestimmt.
  IF h_laufzeit < 950.
    h_laufzeit = g_time2 - g_time1.
    h_laufzeit = h_laufzeit / 1000000.
  ENDIF. " h_laufzeit < 950.

  IF NOT h_counter IS INITIAL.
    h_dummy = h_laufzeit / h_counter.
    WRITE h_dummy TO h_durchschnitt RIGHT-JUSTIFIED.
  ENDIF.

  SKIP 2.
  WRITE: / 'Gesamt-Statistik der Aufbereitung'(073).
  ULINE.

  FORMAT: COLOR COL_NORMAL INTENSIFIED OFF.

  WRITE: / 'Gesamtzahl aller aufbereiteten Filialen:'(074),
        54  h_lines COLOR COL_TOTAL,
         /  'Gesamtlaufzeit der Aufbereitung:'(070),
        54  h_laufzeit COLOR COL_TOTAL,
            'Sekunden'(078),
         /  'Gesamtzahl aller aufbereiteten Segmente:'(075),
        54  h_counter COLOR COL_TOTAL.

  IF NOT h_counter IS INITIAL.
    WRITE: /  'Durchschnittlicher Segmentdurchsatz:'(076),
          54   h_durchschnitt COLOR COL_TOTAL,
              'Sek. pro Segment'(077).
  ENDIF.


ENDFORM. " list_generate_chg


*eject
************************************************************************
FORM statistic_text_generate_idoc
     TABLES pit_wdlsp_buf  STRUCTURE gt_wdlsp_buf.
************************************************************************
* FUNKTION:
* Ausgabe von Statistikinformationen bzgl. der erzeugten IDOC's.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WDLSP_BUF         : Tabelle bereits erzeugter
*                         Statuspositionszeilen.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_text(16).


  WRITE: /3 'Erzeugte Zwischenbelege'(027) COLOR COL_HEADING.
  FORMAT COLOR OFF.

  LOOP AT pit_wdlsp_buf
       WHERE NOT ( docnum IS INITIAL ).
    CASE pit_wdlsp_buf-doctyp.
      WHEN c_idoctype_wrgp.
        MOVE: 'Warengruppen:'(028) TO h_text.
      WHEN c_idoctype_artstm.
        MOVE: 'Artikelstamm:'(029) TO h_text.
      WHEN c_idoctype_ean.
        MOVE: 'EAN-Referenzen:'(030) TO h_text.
      WHEN c_idoctype_set.
        MOVE: 'Set-Zuordnungen:'(031) TO h_text.
      WHEN c_idoctype_nart.
        MOVE: 'Nachzugsartikel:'(032) TO h_text.
      WHEN c_idoctype_cur.
        MOVE: 'Wechselkurse:'(033) TO h_text.
      WHEN c_idoctype_steu.
        MOVE: 'Steuern:'(034) TO h_text.
      WHEN c_idoctype_pers.
        MOVE: 'Personendaten:'(035) TO h_text.
***   Erweiterung Bonuskäufe Rel. 99a (GL)
      WHEN c_idoctype_bby.
        MOVE: 'Bonuskäufe:'(065) TO h_text.
*     Erweiterung für Aktionsrabatte.
      WHEN c_idoctype_prom.
        MOVE: 'Aktionsrabatte:'(072) TO h_text.

    ENDCASE. " pit_wdlsp_buf-doctyp.


    WRITE: /6  h_text COLOR COL_KEY,
           23  'Zwbeleg.'(022),
               pit_wdlsp_buf-docnum COLOR COL_NORMAL,
           48  ', Struktur'(023),
               pit_wdlsp_buf-doctyp COLOR COL_NORMAL,
           67  ', mit'(024),
               pit_wdlsp_buf-anseg  COLOR COL_NORMAL,
           80  'Segmenten erzeugt'(025).
  ENDLOOP. " at pit_wdlsp_buf.

* Falls keine IDOC's erzeugt wurden.
  IF sy-subrc <> 0.
    WRITE: /6  'keine'(036) COLOR COL_NEGATIVE.
  ENDIF. " sy-subrc <> 0.



ENDFORM. " statistic_text_generate_idoc


*eject
************************************************************************
FORM task_error_text_generate
     TABLES pxt_rfcdest            STRUCTURE gt_rfcdest
     USING  pi_jobs_gesamt         LIKE      wpstruc-counter6
            pi_parallel            LIKE      wpstruc-parallel.
************************************************************************
* FUNKTION:
* Ausgabe von Statistikinformationen bzgl. paralleler Taskaufrufe.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_RFCDEST           : RFC-Destinations bei denen Fehler auftraten.

* PI_JOBS_GESAMT        : Gesamtzahl aller parallelen Task.

* PI_PARALLEL           : = 'X', wenn Parallelverarbeitung erfolgte.

* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: system_failure,
        comm_failure,
        unknown_failure,
        key1            LIKE gt_rfcdest-rfcdest,
        key2            LIKE gt_rfcdest-rfcdest,
        errors          LIKE wpstruc-counter6.


* Falls Parallelverarbeitung erfolgte.
  IF NOT pi_parallel IS INITIAL.
    SKIP 2.

*   Bestimme die Anzahl der Fehlerhaften Tasks.
    LOOP AT pxt_rfcdest
         WHERE no_start IS INITIAL.
      ADD 1 TO errors.
    ENDLOOP. " at pxt_rfcdest

*   Falls parallele Tasks erfolgreich beendet wurden.
    IF NOT pi_jobs_gesamt IS INITIAL.
      WRITE: /  'Status Parallelverarbeitung'(046). " color col_group.
      ULINE.
      WRITE: / 'Es wurden insgesamt'(047).

*     Falls Tasks während des Laufs abstürzten.
      IF NOT errors IS INITIAL.
        WRITE:  24 pi_jobs_gesamt COLOR COL_TOTAL.
*     Falls alle Tasks durchliefen.
      ELSE. " errors is initial.
        WRITE:  pi_jobs_gesamt COLOR COL_TOTAL.
      ENDIF. " not errors is initial.

      WRITE: 'parallele Tasks erfolgreich beendet'(048).

*     Falls Tasks während des Laufs abstürzten.
      IF NOT errors IS INITIAL.
        WRITE: / 'Es wurden insgesamt'(047),
               24 errors COLOR COL_TOTAL,
                 'parallele Tasks systemseitig unterbrochen'(061).
      ENDIF. " not errors is initial.
      SKIP.
    ENDIF. " not pi_jobs_gesamt is initial.

*   Daten sortieren.
    SORT pxt_rfcdest BY subrc rfcdest DESCENDING datum uzeit.

*   Lösche alle doppelten Einträge für Kommunikationsfehler.
    CLEAR: key1, key2.
    LOOP AT pxt_rfcdest
         WHERE subrc = 1.
      MOVE pxt_rfcdest-rfcdest TO key2.

      IF key1 <> key2.
        key1 = key2.
      ELSE. " key1 = key2.
        DELETE pxt_rfcdest.
      ENDIF. " key1 <> key2.

    ENDLOOP. " at pxt_rfcdest.

*   Lösche alle identischen Einträge.
    DELETE ADJACENT DUPLICATES FROM pxt_rfcdest COMPARING ALL FIELDS.

*   Falls Fehler bei der Parallelverarbeitung auftraten.
    LOOP AT pxt_rfcdest.
      CASE pxt_rfcdest-subrc.
*       Falls ein Kommunikationsfehler auftrat.
        WHEN 1.
          IF comm_failure IS INITIAL.
            comm_failure = 'X'.
            WRITE: / 'Bei folgenden Destinationen gab es'(049),
                     'Verbindungsprobleme:'(050).
            WRITE: / pxt_rfcdest-rfcdest COLOR COL_NORMAL.

            IF NOT pxt_rfcdest-filia IS INITIAL.
              WRITE: ', betroffen:'(064),
                     pxt_rfcdest-filia COLOR COL_NORMAL.
            ENDIF. " not pxt_rfcdest-filia is initial.
          ELSE. " not comm_failure is initial.
            WRITE: / pxt_rfcdest-rfcdest COLOR COL_NORMAL.

            IF NOT pxt_rfcdest-filia IS INITIAL.
              WRITE: ', betroffen:'(064),
                     pxt_rfcdest-filia COLOR COL_NORMAL.
            ENDIF. " not pxt_rfcdest-filia is initial.
          ENDIF. " comm_failure is initial.

*       Falls ein Systemfehler auftrat.
        WHEN 2.
          IF system_failure IS INITIAL.
            IF NOT comm_failure IS INITIAL.
              SKIP.
            ENDIF. " not comm_failure is initial.

            system_failure = 'X'.
            WRITE: / 'Bei folgenden Destinationen wurden'(051),
                     'eventuell auf der Empfängerseite'(052),
                   / 'Kurzdumps erzeugt:'(053).
            WRITE: / pxt_rfcdest-rfcdest COLOR COL_NORMAL,
                     'am'(054),
                     pxt_rfcdest-datum DD/MM/YYYY COLOR COL_NORMAL,
                     'um etwa'(055),
                     pxt_rfcdest-uzeit COLOR COL_NORMAL,
                     'Uhr'(056).

            IF NOT pxt_rfcdest-filia IS INITIAL.
              WRITE: ', betroffen:'(064),
                     pxt_rfcdest-filia COLOR COL_NORMAL.
            ENDIF. " not pxt_rfcdest-filia is initial.

          ELSE. " not system_failure is initial.
            WRITE: / pxt_rfcdest-rfcdest COLOR COL_NORMAL,
                     'am'(054),
                     pxt_rfcdest-datum DD/MM/YYYY COLOR COL_NORMAL,
                     'um etwa'(055),
                     pxt_rfcdest-uzeit COLOR COL_NORMAL,
                     'Uhr'(056).

            IF NOT pxt_rfcdest-filia IS INITIAL.
              WRITE: ', betroffen:'(064),
                     pxt_rfcdest-filia COLOR COL_NORMAL.
            ENDIF. " not pxt_rfcdest-filia is initial.
          ENDIF. " system_failure is initial.

*       Falls ein unbekannter Fehler auftrat.
        WHEN OTHERS.
          IF unknown_failure IS INITIAL.
            IF NOT unknown_failure IS INITIAL.
              SKIP.
            ENDIF. " not unknown_failure is initial.

            unknown_failure = 'X'.
            WRITE: / 'Bei folgenden Destinationen trat'(062),
                     'ein nicht identifizierbarer Fehler auf'(063).
            WRITE: / pxt_rfcdest-rfcdest COLOR COL_NORMAL,
                     'am'(054),
                     pxt_rfcdest-datum DD/MM/YYYY COLOR COL_NORMAL,
                     'um etwa'(055),
                     pxt_rfcdest-uzeit COLOR COL_NORMAL,
                     'Uhr'(056).

            IF NOT pxt_rfcdest-filia IS INITIAL.
              WRITE: ', betroffen:'(064),
                     pxt_rfcdest-filia COLOR COL_NORMAL.
            ENDIF. " not pxt_rfcdest-filia is initial.

          ELSE. " not unknown_failure is initial.
            WRITE: / pxt_rfcdest-rfcdest COLOR COL_NORMAL,
                     'am'(054),
                     pxt_rfcdest-datum DD/MM/YYYY COLOR COL_NORMAL,
                     'um etwa'(055),
                     pxt_rfcdest-uzeit COLOR COL_NORMAL,
                     'Uhr'(056).

            IF NOT pxt_rfcdest-filia IS INITIAL.
              WRITE: ', betroffen:'(064),
                     pxt_rfcdest-filia COLOR COL_NORMAL.
            ENDIF. " not pxt_rfcdest-filia is initial.
          ENDIF. " system_failure is initial.

      ENDCASE. " pxt_rfcdest-subrc.
    ENDLOOP. " at pxt_rfcdest.

    IF sy-subrc = 0.
      SKIP.
      FORMAT COLOR COL_KEY.
      WRITE: / 'Die nachträgliche Verarbeitung fehlerhafter'(057),
               'Tasks erfolgte jeweils seriell'(058).
      FORMAT COLOR OFF.
      SKIP.
    ENDIF. " sy-subrc = 0.
  ENDIF. " not pi_parallel is initial.


ENDFORM. " task_error_text_generate


*eject
************************************************************************
FORM wlk2_intervals_check
     TABLES pet_marm               STRUCTURE gt_marm_buf
            pet_wlk2_temp          STRUCTURE gt_wlk2
            pit_wlk2               STRUCTURE gt_wlk2
            pxt_independence_check STRUCTURE gt_independence_check
            pxt_ot3                STRUCTURE wpaot3
            pxt_artdel             STRUCTURE gt_artdel
     USING  pi_filia_group         STRUCTURE gt_filia_group
            pi_mestype             LIKE edimsg-mestyp
            pi_datp3               LIKE syst-datum
            pi_datp4               LIKE syst-datum
            pe_index               LIKE sy-tabix.
************************************************************************
* Bestimme alle Objekte, deren Bewirtschaftungszeitraum jetzt erst
* in den Betrachtungszeitraum hineinrutscht und solche deren
* Bewirtschaftungszeitraum innerhalb des Betrachtungszeitraums endet.
* Mit interner Pufferung.
* ----------------------------------------------------------------------
* PARAMETER:
* PET_MARM:             : MARM-Daten der gefundene Objekte.

* PET_WLK2_TEMP         : WLK2-Sätze der gefundenen Objekte.

* PIT_WLK2              : Gesammelte Bewirtschaftungszeiträume der
*                         Filiale.
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_OT3               : Tabelle der aufzubereitenden Objekte

* PXT_ARTDEL            : Tabelle für zu löschende Artikel

* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PI_MESTYPE            : Nachrichtentyp

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: jetziges Versenden + Vorlaufzeit.

* PE_INDEX              : Index der Tabellenzeile für diese Filiale
*                         aus PXT_INDEPENDENCE_CHECK.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_datum LIKE sy-datum,
        h_tabix LIKE sy-tabix.

* Tabelle für Materialnummern aus WLK2.
  DATA: BEGIN OF t_wlk2_matnr OCCURS 1000.
      INCLUDE STRUCTURE gt_filia_wlk2_buf.
  DATA: END OF t_wlk2_matnr.

* Zweiter Zwischenpuffer für Materialnummern aus WLK2.
  DATA: BEGIN OF t_matnr OCCURS 0.
      INCLUDE STRUCTURE gt_matnr.
  DATA: END OF t_matnr.

* Zwischenpuffer für WLK2-Daten.
  DATA: BEGIN OF t_wlk2 OCCURS 10.
      INCLUDE STRUCTURE gt_wlk2.
  DATA: END OF t_wlk2.

* Zwischenpuffer für MARM-Schlüssel.
  DATA: BEGIN OF t_short_marm OCCURS 0.
      INCLUDE STRUCTURE gt_marm_buf.
  DATA: END OF t_short_marm.


* Rücksetze Ausgabetabelle.
  REFRESH: pet_marm, pet_wlk2_temp.
  CLEAR:   pet_marm, pet_wlk2_temp.

* Besorge zugehörigen Satz in Filialcopy-Tabelle.
  READ TABLE pxt_independence_check WITH KEY
       filia = pi_filia_group-filia
       BINARY SEARCH.

  pe_index = sy-tabix.
* Bestimme alle Objekte, deren Bewirtschaftungszeitraum jetzt erst
* in den Betrachtungszeitraum hineinrutscht.
  REFRESH: t_matnr.
  LOOP AT pit_wlk2
       WHERE vkdab >  pi_datp3
       AND   vkdab <= pi_datp4.

    CASE pi_mestype.
      WHEN c_mestype_artstm.
*       Falls eine mögliche Kopiermutter vorliegt.
        IF pxt_independence_check-artstm <> space.
*         Falls dieses Objekt einen filialabhängigen
*         WLK2-Satz besitzt.
          IF pit_wlk2-orghier = c_orghier_filia.
*           Sorge dafür, daß diese Filiale keine weitere
*           Kopiermutter wird.
            CLEAR: pxt_independence_check-artstm.
            MODIFY pxt_independence_check INDEX pe_index.
          ENDIF. " pit_wlk2-orghier = C_orghier_filia.
        ENDIF. " pxt_independence_check-artstm <> space.

      WHEN c_mestype_ean.
*       Falls eine mögliche Kopiermutter vorliegt.
        IF pxt_independence_check-ean <> space.
*         Falls dieses Objekt einen filialabhängigen
*         WLK2-Satz besitzt.
          IF pit_wlk2-orghier = c_orghier_filia.
*           Sorge dafür, daß diese Filiale keine weitere
*           Kopiermutter wird.
            CLEAR: pxt_independence_check-ean.
            MODIFY pxt_independence_check INDEX pe_index.
          ENDIF. " pit_wlk2-orghier = C_orghier_filia.
        ENDIF. " pxt_independence_check-ean <> space.

      WHEN c_mestype_set.
*       Falls eine mögliche Kopiermutter vorliegt.
        IF pxt_independence_check-sets <> space.
*         Falls dieses Objekt einen filialabhängigen
*         WLK2-Satz besitzt.
          IF pit_wlk2-orghier = c_orghier_filia.
*           Besorge die MARA-Daten des Artikels.
            PERFORM mara_select USING mara
                                      pit_wlk2-matnr.

*           Falls der Artikel ein Setartikel ist dann kann dieser
*           Objekttyp keine Kopiermutter mehr sein.
            IF mara-attyp = c_setartikel.
*             Sorge dafür, daß diese Filiale keine weitere
*             Kopiermutter wird.
              CLEAR: pxt_independence_check-sets.
              MODIFY pxt_independence_check INDEX pe_index.
            ENDIF. " mara-attyp = c_setartikel.
          ENDIF. " pit_wlk2-orghier = C_orghier_filia.
        ENDIF. " pxt_independence_check-sets <> space.


      WHEN c_mestype_nart.
*       Falls eine mögliche Kopiermutter vorliegt.
        IF pxt_independence_check-nart <> space.
*         Falls dieses Objekt einen filialabhängigen
*         WLK2-Satz besitzt.
          IF pit_wlk2-orghier = c_orghier_filia.
*           Besorge die MARA-Daten des Artikels.
            PERFORM mara_select USING mara
                                      pit_wlk2-matnr.

*           Falls der Artikel ein Nachzugsartikel ist dann kann dieser
*           Objekttyp keine Kopiermutter mehr sein.
            IF mara-mlgut <> space.
*             Sorge dafür, daß diese Filiale keine weitere
*             Kopiermutter wird.
              CLEAR: pxt_independence_check-nart.
              MODIFY pxt_independence_check INDEX pe_index.
            ENDIF. " mara-mlgut <> space.
          ENDIF. " pit_wlk2-orghier = C_orghier_filia.
        ENDIF. " pxt_independence_check-nart <> space.
    ENDCASE. " pi_mestype

*   Übernahme der Materialnummer in separaten Puffer.
    APPEND pit_wlk2-matnr TO t_matnr.

*   Übernahme des WLK2-Satzes in Zwischenspeicher.
    APPEND pit_wlk2 TO pet_wlk2_temp.
  ENDLOOP. " at pit_wlk2

* Prüfe, ob zusätzliche Objekte gefunden wurden.
  READ TABLE t_matnr INDEX 1.

* Falls zusätzliche Objekte gefunden wurden, dann besorge die
* zugehörigen Verkaufsmengeneinheiten.
  IF sy-subrc = 0.
*   Besorge die zugehörigen Verkaufsmengeneinheiten.
    PERFORM marm_select TABLES t_matnr
                               pet_marm
                        USING  'X'   ' '   ' '.
  ENDIF. " sy-subrc = 0.

* Bestimme alle Objekte, deren Bewirtschaftungszeitraum innerhalb
* des Betrachtungszeitraums (Zeitraum P3 bis P4) endet.
  REFRESH: t_wlk2.
  LOOP AT pit_wlk2
       WHERE vkbis >=  pi_datp3
       AND   vkbis <   pi_datp4.

    CLEAR: t_wlk2.

    CASE pi_mestype.
      WHEN c_mestype_set.
*       Besorge die MARA-Daten des Artikels.
        PERFORM mara_select USING mara
                                  pit_wlk2-matnr.

*       Falls der Artikel kein Setartikel ist, dann ignoriere ihn.
        IF mara-attyp <> c_setartikel.
          CONTINUE.
        ENDIF. " mara-attyp <> c_setartikel.

      WHEN c_mestype_nart.
*       Besorge die MARA-Daten des Artikels.
        PERFORM mara_select USING mara
                                  pit_wlk2-matnr.

*       Falls der Artikel kein Nachzugsartikel ist, dann ignoriere ihn.
        IF mara-mlgut = space.
          CONTINUE.
        ENDIF. " mara-mlgut = space.
    ENDCASE. " pi_mestype

*   Zwischenspeichern des WLK2-Satzes.
    APPEND pit_wlk2 TO t_wlk2.
  ENDLOOP. " at pit_wlk2

* Prüfe, ob Objekte gefunden wurden.
  READ TABLE t_wlk2 INDEX 1.

* Falls keine Objekte gefunden wurden, dann keine weitere
* Aufbereitung nötig.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF. " sy-subrc <> 0.

* Übernehme Materialnummer in separate interne Tabelle
  REFRESH: t_matnr.
  LOOP AT t_wlk2.
    APPEND t_wlk2-matnr TO t_matnr.
  ENDLOOP. " at t_wlk2.

* Besorge die zugehörigen Verkaufsmengeneinheiten.
  PERFORM marm_select TABLES t_matnr
                             t_short_marm
                      USING  'X'   ' '   ' '.

* Daten sortieren.
  SORT t_short_marm BY matnr meinh.
  SORT t_wlk2       BY matnr.

* Schleife über alle Verkaufsmengeneinheiten der gefundenen
* Artikel.
  LOOP AT t_short_marm.
*   Lese zugehörigen WLK2-Satz.
    IF t_wlk2-matnr <> t_short_marm-matnr.
      READ TABLE t_wlk2 WITH KEY
           matnr = t_short_marm-matnr
           BINARY SEARCH.
    ENDIF. " t_wlk2-matnr <> t_short_marm-matnr.

*   Prüfe, ob EAN bereits gemerkt wurde.
    h_datum = t_wlk2-vkbis + 1.
    READ TABLE pxt_artdel WITH KEY
         artnr = t_short_marm-matnr
         vrkme = t_short_marm-meinh
         datum = h_datum
         BINARY SEARCH.

    h_tabix = sy-tabix.

*   Falls die zugehörige EAN noch nicht gemerkt wurde, dann
*   besorge EAN.
    IF sy-subrc <> 0.
*     Besorge die Haupt-EAN vom Vortag des Löschens.
      PERFORM ean_by_date_get
                  USING t_short_marm-matnr  t_short_marm-meinh
                        t_wlk2-vkbis        g_loesch_ean
                        g_returncode.

*     Falls eine EAN gefunden wurde, dann erzeuge Lösch-Eintrag
*     in OT3.
      IF g_returncode = 0 AND g_loesch_ean <> space.
        pxt_artdel-artnr = t_short_marm-matnr.
        pxt_artdel-vrkme = t_short_marm-meinh.
        pxt_artdel-ean   = g_loesch_ean.
        pxt_artdel-datum = h_datum.
        INSERT pxt_artdel INDEX h_tabix.

*     Falls keine EAN gefunden wurde, dann weiter zum nächsten Satz.
      ELSE. " g_returncode <> 0 or g_loesch_ean = space.
        CONTINUE.
      ENDIF. " G_RETURNCODE = 0 AND G_LOESCH_EAN <> SPACE.
    ENDIF. " sy-subrc <> 0.

*   Prüfe, ob Lösch-Einrag schon existiert.
    READ TABLE pxt_ot3 WITH KEY
         artnr    = t_short_marm-matnr
         vrkme    = t_short_marm-meinh
         init     = space
         upd_flag = c_del
         datum    = h_datum.

*   Falls der Lösch-Eintrag noch nicht gemerkt wurde, dann
*   merke Lösch-Eintrag.
    IF sy-subrc <> 0.
*     Erzeuge Lösch-Eintrag in Objekttabelle 3
      pxt_ot3-artnr    = t_short_marm-matnr.
      pxt_ot3-vrkme    = t_short_marm-meinh.
      pxt_ot3-datum    = h_datum.
      pxt_ot3-upd_flag = c_del.
      CLEAR: pxt_ot3-init.
      APPEND pxt_ot3.
    ENDIF.                   " SY-SUBRC <> 0.

  ENDLOOP. " at t_short_marm.

ENDFORM.                               " wlk2_intervals_check


*eject
************************************************************************
FORM error_object_write.
************************************************************************
* FUNKTION:                                                            *
* Erweitere, falls nötig das lokale Gedächtnis der Fehlerobjekttabelle
* WDLSO für späteren Restart.
* ---------------------------------------------------------------------*
* PARAMETER: keine.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Falls Simulationsmodus, dann kein DB-Update ==> Operation abbrechen.
  IF NOT g_simulation IS INITIAL.
    EXIT.
  ENDIF. " not g_simulation is initial.

* Falls Fehlerobjekttabelle WDLSO gefüllt werden soll.
  IF g_object_key <> space.
*   Merken des nicht aufzubereitenden Objekts im lokalen Gedächtnis
*   der Fehlerobjekttabelle WDLSO für späteren Restart.
    CALL FUNCTION 'POS_ERROR_OBJECTS_WRITE'
      EXPORTING
        pi_dldnr                 = g_dldnr
        pi_lfdnr                 = g_dldlfdnr
        pi_single_object         = g_object_key
        pi_loekz                 = g_object_delete
      EXCEPTIONS
        no_records_written_to_db = 1
        wrong_input              = 2
        wrong_table_input        = 3
        OTHERS                   = 4.
  ENDIF. " g_object_key <> space.


ENDFORM.                               " error_object_write.


*eject.
************************************************************************
FORM pathnames_get
     TABLES pit_edidc        STRUCTURE edidc
            pit_partnr       STRUCTURE edidc
            pet_pathname     STRUCTURE edi_path
            pet_msgtype      STRUCTURE wpmsgtype
     USING  pi_wdls          STRUCTURE wdls
            pe_fehlercode    LIKE wpstruc-counter.
************************************************************************
* FUNKTION:
* Besorge zu den übergebenen EDIDC-Sätzen die jeweiligen Pfadnamen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_EDIDC             : Zu untersuchende EDIDC-Sätze.

* PIT_PARTNR            : Alle betroffenen Partnernummern und -arten.

* PET_PATHNAME          : Gesuchte Pfadnamen.

* PET_MSGTYPE           : Betroffene Nachrichtentypen.

* PI_WDLS               : Statuskopfzeile.

* PE_FEHLERCODE         : > 0, wenn Fehler auftraten, sonst 0.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: key1 LIKE edidc-mestyp,
        key2 LIKE edidc-mestyp.

  DATA: BEGIN OF t_edp13 OCCURS 10.
      INCLUDE STRUCTURE edp13.
  DATA: END OF t_edp13.

  DATA: BEGIN OF t_edipod OCCURS 10.
      INCLUDE STRUCTURE edipod.
  DATA: END OF t_edipod.

* Zum zwischenspeichern fehlerhafter Nachrichtentypen.
  DATA: BEGIN OF t_msgtype_error OCCURS 10,
          mestyp LIKE wpmsgtype-mestyp.
  DATA: END OF t_msgtype_error.

* Dummy für das Schreiben von Fehlermeldungen
  DATA: BEGIN OF t_number OCCURS 1.
      INCLUDE STRUCTURE balnri.
  DATA: END OF t_number.


* Rücksetze Ausgabetabelle.
  REFRESH: pet_pathname.
  CLEAR:   pet_pathname.

* Rücksetze Fehlertabelle für IDOC-Typen.
  REFRESH: t_msgtype_error.
  CLEAR:   t_msgtype_error.

* Sortieren der Daten.
  SORT pit_edidc BY mestyp.

* Füllen der Ausgabetabelle der Nachrichtentypen mit allen gefundenen
* unterschiedlichen Nachrichtentypen.
  REFRESH: pet_msgtype.
  CLEAR: key1, key2, pet_msgtype.
  LOOP AT pit_edidc.
    key2 = pit_edidc-mestyp.
    IF key1 <> key2.
      key1 = key2.
      APPEND pit_edidc-mestyp TO pet_msgtype.
    ENDIF. " key1 <> key2.
  ENDLOOP. " at pit_edidc.

* Sortieren der Daten.
  SORT pit_edidc BY docnum.

* Bestimme die einzelnen Ports
  LOOP AT pit_partnr.
    SELECT * FROM edp13 APPENDING TABLE t_edp13
           FOR ALL ENTRIES IN pet_msgtype
           WHERE mestyp = pet_msgtype-mestyp
           AND   rcvprn = pit_partnr-rcvprn
           AND   rcvprt = pit_partnr-rcvprt
           AND   test   = space.
  ENDLOOP. " at pit_partnr.

* Lösche alle doppelten Einträge aus Tabelle T_EDP13.
  SORT t_edp13 BY mestyp rcvpor.
  DELETE ADJACENT DUPLICATES FROM t_edp13 COMPARING mestyp rcvpor.

* Bestimme die zugehörigen Portbeschreibungen
  SELECT * FROM  edipod INTO TABLE t_edipod
         FOR ALL ENTRIES IN t_edp13
         WHERE port = t_edp13-rcvpor.

* Sortieren der Daten.
  SORT t_edp13 BY mestyp.
  SORT t_edipod BY port.

* Bestimme die Dateinamen der IDOC's über die zugehörigen FB's.
  LOOP AT pit_edidc.
*   Lese zugehörige Partnervereinbarung.
    CLEAR: t_edp13.
    READ TABLE t_edp13 WITH KEY
         mestyp = pit_edidc-mestyp  BINARY SEARCH.

*   Lese zugehörige Portbeschreibung.
    CLEAR: t_edipod.
    READ TABLE t_edipod WITH KEY
         port = t_edp13-rcvpor  BINARY SEARCH.

*   Falls kein FB-Name existiert, so kann kein Dateiname ermittelt
*   werden und der Download läuft für diesen IDOC-Typ falsch.
*   Daher Fehlermeldung
    IF t_edipod-outputfunc = space.
*     Prüfe, ob schon eine Fehlermeldung bzgl. dieses Nachrichtentyps
*     aufbereitet wurde.
      READ TABLE t_msgtype_error WITH KEY
           mestyp = pit_edidc-mestyp BINARY SEARCH.

*     Falls noch keine Fehlermeldung abgesetzt wurde, dann erzeuge
*     Fehlermeldung.
      IF sy-subrc <> 0.
*       Merken, daß für diesen Nachrichtentyp bereits eine
*       Fehlermeldung aufbereitet wurde.
        t_msgtype_error-mestyp = pit_edidc-mestyp.
        INSERT t_msgtype_error INDEX sy-tabix.

*       Setze Fehlercode.
        pe_fehlercode = 2.

*       Falls noch keine Initialisierung des Fehlerprotokolls.
        IF g_init_log = space.
*         Aufbereitung der Parameter zum schreiben des Headers des
*         Fehlerprotokolls.
          CLEAR: gi_errormsg_header.
          gi_errormsg_header-object    = c_applikation.
          gi_errormsg_header-subobject = c_download.

*         Initialisiere Fehlerprotokoll und erzeuge Header.
          CALL FUNCTION 'APPL_LOG_INIT'
            EXPORTING
              object              = c_applikation
              subobject           = c_download
            EXCEPTIONS
              object_not_found    = 01
              subobject_not_found = 02.

*         Setze Zeitstempel für Nachricht.
          gi_errormsg_header-aldate = sy-datum.
          gi_errormsg_header-altime = sy-uzeit.

*         Erzeuge Nachrichten-Header.
          CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
            EXPORTING
              header              = gi_errormsg_header
            EXCEPTIONS
              object_not_found    = 01
              subobject_not_found = 02.


*         Merke, daß Fehlerprotokoll initialisiert wurde.
          g_init_log = 'X'.
        ENDIF.                           " G_INIT_LOG = SPACE.

*       Bereite Parameter zum schreiben der Fehlerzeile auf.
        CLEAR: gi_message.
        gi_message-msgty     = c_msgtp_error.
        gi_message-msgid     = c_message_id.
        gi_message-probclass = c_probclass_sehr_wichtig.
*       'Partnernr. &, Nachrichtentyp &: Kein FB-Name in den
*       Portbeschr. gepflegt'.
        gi_message-msgno     = '027'.
        gi_message-msgv1     = pi_wdls-empfn.
        gi_message-msgv2     = pit_edidc-mestyp.
        gi_message-msgv3     = t_edipod-port.

*       Schreibe Fehlerzeile.
        CALL FUNCTION 'APPL_LOG_WRITE_SINGLE_MESSAGE'
          EXPORTING
            object              = c_applikation
            subobject           = c_download
            message             = gi_message
            update_or_insert    = c_insert
          EXCEPTIONS
            object_not_found    = 01
            subobject_not_found = 02.
      ENDIF. " sy-subrc <> 0.

*   Falls ein FB-Name existiert, so kann ein Dateiname ermittelt
*   werden. Daher Ermittlung des Dateinamens.
    ELSE. " t_edipod-outputfunc <> space.
*     Bestimme den zugehörigen Dateinamen über FB-Aufruf.
      CALL FUNCTION t_edipod-outputfunc
        EXPORTING
          datatype  = t_edipod-actrig
          directory = t_edipod-outputdir
          filename  = t_edipod-outputfile
          control   = pit_edidc
        IMPORTING
          pathname  = pet_pathname.

      APPEND pet_pathname.

    ENDIF. " t_edipod-outputfunc = space.

*   Setze neuen Status für EDIDC-Sätze "Ans SCS übergeben".
*   IDOC öffnen.
    CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_PROCESS'
      EXPORTING
        db_read_option           = 'N'
        document_number          = pit_edidc-docnum
        enqueue_option           = 'S'
      EXCEPTIONS
        document_foreign_lock    = 01
        document_not_exist       = 02
        document_number_invalid  = 03
        document_is_already_open = 04.

    IF sy-subrc = 0.
*     Fülle Status-Zwischenstruktur.
      CLEAR: edi_ds.
      edi_ds-tabnam  = c_edi_ds.
      edi_ds-mandt   = sy-mandt.
      edi_ds-docnum  = pit_edidc-docnum.
      edi_ds-logdat  = sy-datum.
      edi_ds-logtim  = sy-uzeit.
      edi_ds-uname   = sy-uname.
      edi_ds-repid   = c_saplwpda.
      edi_ds-routid  = c_pathnames_get.

*     Falls ein Dateiname ermittelt werden konnte.
      IF t_edipod-outputfunc <> space.
        edi_ds-status  =  c_an_scs_uebergeben.
*     Falls Kein Dateiname ermittelt werden konnte.
      ELSE. " t_edipo-outputfunc = space.
        edi_ds-status  =  c_fehler_bei_uebergabe_an_scs.
      ENDIF. " t_edipo-outputfunc <> space.

*     Neuen Status erzeugen in EDIDS und EDIDC.
      CALL FUNCTION 'EDI_DOCUMENT_STATUS_SET'
        EXPORTING
          document_number         = pit_edidc-docnum
          idoc_status             = edi_ds
        EXCEPTIONS
          document_number_invalid = 01
          other_fields_invalid    = 02
          status_invalid          = 03.

      IF sy-subrc = 0.
*       IDOC entsperren.
        CALL FUNCTION 'EDI_DOCUMENT_CLOSE_PROCESS'
          EXPORTING
            document_number     = pit_edidc-docnum
          EXCEPTIONS
            document_not_open   = 01
            failure_in_db_write = 02
            parameter_error     = 03
            status_set_missing  = 04.
      ENDIF. " sy-subrc = 0.
    ENDIF. " sy-subrc = 0.

  ENDLOOP. " at pit_edidc.

* Schreibe Fehlermeldungen auf Datenbank, falls nötig.
  IF g_init_log <> space.
    CALL FUNCTION 'APPL_LOG_WRITE_DB'
      EXPORTING
        object                = c_applikation
        subobject             = c_download
      TABLES
        object_with_lognumber = t_number
      EXCEPTIONS
        object_not_found      = 01
        subobject_not_found   = 02.

*   Rücksezte Fehlermeldungsflag.
    CLEAR: g_init_log.
  ENDIF.                           " G_INIT_LOG <> SPACE.


ENDFORM. " pathnames_get


*eject.
************************************************************************
FORM table_independence_check
     TABLES pit_kotabnr       STRUCTURE wpperiod
            pet_indep_kotabnr STRUCTURE wpperiod
            pet_dep_kotabnr   STRUCTURE wpperiod
     USING  pi_verwendung     LIKE      t685-kvewe.
************************************************************************
* FUNKTION:
* Bestimme die Filialabhängigkeit bzw. die Filialunabhängigkeit
* von Konditionstabellen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_KOTABNR           : Tabelle mit den zu untersuchenden
*                         Konditionstabellennummern.
* PET_INDEP_KOTABNR     : Tabelle mit den Tabellennummern der
*                         filialunabhängigen Tabellen.
* PET_DEP_KOTABNR       : Tabelle mit den Tabellennummern der
*                         filialabhängigen Tabellen.
* PI_VERWENDUNG         : Verwendung.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: tabname TYPE ddobjname.

  DATA: BEGIN OF t_dntab OCCURS 1.
      INCLUDE STRUCTURE dfies.
  DATA: END OF t_dntab.

  DATA: BEGIN OF t_kotabnr OCCURS 1.
      INCLUDE STRUCTURE wpperiod.
  DATA: END OF t_kotabnr.

* Initialisiere Ausgabetabellen.
  REFRESH: pet_indep_kotabnr, pet_dep_kotabnr.

* Übernehme die Nummern der Konditionstabellen in seperate Tabelle.
  t_kotabnr[] = pit_kotabnr[].

* Daten sortieren.
  SORT t_kotabnr BY kotabnr.

* Lösche doppelte Einträge heraus.
  DELETE ADJACENT DUPLICATES FROM t_kotabnr COMPARING kotabnr.

  LOOP AT t_kotabnr.
    CLEAR:   pet_indep_kotabnr, pet_dep_kotabnr.

*   Falls ein Naturalrabatt vorliegt.
    IF pi_verwendung = c_vewe_natrab.
      tabname   = 'KOTN'.
      tabname+4 = t_kotabnr-kotabnr.
    ELSE. " pi_verwendung <> c_vewe_natrab.
      tabname   = pi_verwendung.
      tabname+1 = t_kotabnr-kotabnr.
    ENDIF. " pi_verwendung = c_vewe_natrab.

    CALL FUNCTION 'NAMETAB_GET_WITH_BUFFER'
      EXPORTING
        pi_tabname  = tabname
      TABLES
        pet_nametab = t_dntab
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.

    IF sy-subrc = 0.
      LOOP AT t_dntab
           WHERE ( fieldname = 'WERKS'
           OR      fieldname = 'KUNNR'
           OR      fieldname = 'PLTYP'
           OR      fieldname = 'AKTNR' )
           AND   keyflag   <> space.
        EXIT.
      ENDLOOP. " at t_dntab

*     Falls der Schlüssel Filialabhängig ist.
      IF sy-subrc = 0.
        pet_dep_kotabnr-kotabnr = t_kotabnr-kotabnr.
        APPEND pet_dep_kotabnr.

*     Falls der Schlüssel Filialunabhängig ist.
      ELSE. " sy-subrc <> 0.
        pet_indep_kotabnr-kotabnr = t_kotabnr-kotabnr.
        APPEND pet_indep_kotabnr.
      ENDIF. " sy-subrc = 0.
    ENDIF. " sy-subrc = 0.

  ENDLOOP. " at t_kotabnr.


ENDFORM. " table_independence_check


*eject.
************************************************************************
FORM referenz_vtweg_check
     TABLES pit_filia  STRUCTURE wdl_fil
            pet_vtweg  STRUCTURE wpposfilia
     USING  pi_komg    STRUCTURE komg.
***********************************************************************
* FUNKTION:
* Besorge alle Vertriebswege aus PIT_FILIA, die als
* Referenzvertriebsweg PI_KOMG-VTWEG haben.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILIA             : Tabelle der POS-relevante Filialen.

* PET_VTWEG             : Tabelle mit den gefundenen
*                         Vertriebswegen.
* PI_KOMG               : Objektschlüssel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Ausgabetabelle initialisieren.
  CLEAR: pet_vtweg.

  LOOP AT pit_filia
       WHERE vkorg =  pi_komg-vkorg
       AND   vtweg <> pi_komg-vtweg.
*   Besorge Referenzvertriebsweg, falls möglich.
    CALL FUNCTION 'TVKOV_SINGLE_READ'
      EXPORTING
        tvkov_vkorg = pi_komg-vkorg
        tvkov_vtweg = pit_filia-vtweg
      IMPORTING
        wtvkov      = tvkov
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.

*   Falls ein Referenzvertriebsweg gefunden wurde.
    IF sy-subrc = 0.
*     Falls der Referenzvertriebsweg mit dem Quell-VTWEG übereinstimmt
      IF tvkov-vtwko = pi_komg-vtweg.
*       Übernehme den Vertriebsweg aus PIT_FILIA in Ausgabetabelle.
        pet_vtweg-vtweg = pit_filia-vtweg.
        APPEND pet_vtweg.
      ENDIF. " tvkov-vtwko = pi_komg-vtweg.
    ENDIF. " sy-subrc = 0.
  ENDLOOP. " at pit_filia

* Doppelte Einträge löschen.
  SORT pet_vtweg BY vtweg.
  DELETE ADJACENT DUPLICATES FROM pet_vtweg
         COMPARING vtweg.


ENDFORM. " referenz_vtweg_check


*eject
************************************************************************
FORM idoc_data_send
     TABLES pxt_edidc  STRUCTURE edidc.
************************************************************************
* FUNKTION:
* IDOC-Daten versenden und IDOC-Status aktualisieren.
* ----------------------------------------------------------------------
* PARAMETER:
* PXT_EDIDC         : EDIDC-Daten der zur Versendung anstehenden
*                     IDOC's
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: BEGIN OF t_edidc OCCURS 0.
      INCLUDE STRUCTURE edidc.
  DATA: END OF t_edidc.


* Schleife über alle zur Versendung anstehenden IDOC's.
  LOOP AT pxt_edidc.
*   IDOC versenden.
    CALL FUNCTION 'POS_IDOC_SEND'
      EXPORTING
        pi_docnum = pxt_edidc-docnum.

*** Start of Changes by Suri : 04.03.2020
*** For IDoc Succefully Created or Not in Background job
 data(docnum) = pxt_edidc-docnum.
 export docnum to MEMORY id 'IDOC'.
*** End of Changes by Suri : 04.03.2020
*   submit rwdposis
*          with docnum in t_docnum
*          and return.
  ENDLOOP. " at pxt_edidc.

* Falls Einträge in PXT_EDIDC vorhanden sind.
  IF sy-subrc = 0.
*   Lese alle zugehörigen EDIDC-Sätze nach.
    SELECT * FROM edidc INTO TABLE t_edidc
           FOR ALL ENTRIES IN pxt_edidc
           WHERE docnum = pxt_edidc-docnum.

*   Daten sortieren.
    SORT t_edidc BY docnum.

*   Übernehme die gefundenen EDIDC-Sätze in Ausgabetabelle
    pxt_edidc[] = t_edidc[].
  ENDIF. " sy-subrc = 0.


ENDFORM. " idoc_data_send


*eject.
************************************************************************
FORM filia_group_check
     TABLES pit_filia_group  STRUCTURE wdl_fil
            pit_kondart      STRUCTURE wpkondart
            pet_filia        STRUCTURE gt_filia
     USING  pi_periods       STRUCTURE val_period
            px_komg          STRUCTURE komg
            pi_konh          STRUCTURE konh.
***********************************************************************
* FUNKTION:
* Besorge die Liste aller Filialen der Filialgruppe PIT_FILIA_GROUP
* die vom aktuell zu analysierenden Konditionsänderungspointer
* betroffen sind.
* Weicht der Vertriebsweg der Filiale vom Vertriebsweg der Kondition
* ab, dann ist das Feld PET_FILIA-VTWEG gefüllt.
* In diesem Fall wird der Vertriebsweg der Filiale durch
* PX_KOMG-VTWEG referenziert.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILIA_GROUP       : Tabelle der Filialen dieser Gruppe.
*
* PIT_KONDART           : Tabelle der POS-relevanten Konditionsarten.
*
* PET_FILIA             : Ergebnistabelle der Filialen mit gleichem
*                         Vertriebsweg wie PI_KOMG-VTWEG.
* PI_PERIODS            : Gültigkeitsintervall der betrachteten
*                         Kondition.
* PX_KOMG               : Objektschlüssel.
*
* PI_KONH               : Konditionskopfsatz.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_vkorg LIKE komg-vkorg.


* Tabelle zum zwischenspeichern von Vertriebswegen.
  DATA: BEGIN OF t_vtweg  OCCURS 10.
      INCLUDE STRUCTURE wpposfilia.
  DATA: END OF t_vtweg.

* Tabelle zum zwischenspeichern von Filialen einer Aktion
  DATA: BEGIN OF t_bapi1068t6  OCCURS 10.
      INCLUDE STRUCTURE bapi1068t6.
  DATA: END OF t_bapi1068t6.

* Tabelle zum zwischenspeichern von WRF6-Einträgen.
  DATA: BEGIN OF t_wrf6  OCCURS 10.
      INCLUDE STRUCTURE wrf6.
  DATA: END OF t_wrf6.


* Rücksetze Vertriebswegtabelle.
  REFRESH: t_vtweg.
  CLEAR:   t_vtweg.

* Rücksetze Ausgabetabelle mit Filialzusatzdaten.
  REFRESH: pet_filia.
  CLEAR:   pet_filia.

* Falls die Kondition Vertriebswegabhängig ist.
  IF NOT px_komg-vtweg IS INITIAL.
*   Prüfe ob dieser Vertriebsweg in der gerade bearbeiteten
*   Filialgruppe vorkommt.
    LOOP AT pit_filia_group
         WHERE vkorg = px_komg-vkorg
         AND   vtweg = px_komg-vtweg.
      EXIT.
    ENDLOOP. " at pit_filia_group

*   Falls dieser Vertriebsweg in der gerade bearbeiteten
*   Filialgruppe vorkommt, dann Übernahme in Sekundärtabelle.
    IF sy-subrc = 0.
*     Erzeuge Eintrag in T_VTWEG.
      t_vtweg-vtweg = px_komg-vtweg.
      APPEND t_vtweg.
    ENDIF. " sy-subrc = 0.

*   Ergänze T_VTWEG um alle Vertriebswege aus PIT_FILIA,
*   die als Referenzvertriebsweg den gleichen Vertriebsweg
*   wie das Objekt (PI_KOMG-VTWEG) haben.
*   Hintergrund: Das Objekt, welches durch den aktuellen
*                Konditionspointer behandelt wird muß nicht
*                nur für die Filiale(n) mit dem aktuellen
*                Vertriebsweg aufbereitet werden, sondern
*                für alle Filialen dieser Gruppe, denen
*                dieser Vertriebsweg als
*                Referenzvertriebsweg zugeordnet ist.
    PERFORM referenz_vtweg_check
            TABLES pit_filia_group
                   t_vtweg
            USING  px_komg.

*   Falls die Kondition nicht zum Werk (Filiale) gepflegt wurde.
    IF px_komg-werks IS INITIAL.
      px_komg-werks = '*'.
    ENDIF. " px_komg-werks is initial.

*   Falls die Kondition nicht zur Kundennummer gepflegt wurde.
    IF px_komg-kunnr IS INITIAL.
      px_komg-kunnr = '*'.
    ENDIF. " px_komg-kunnr is initial.

*   Falls die Kondition zum Preislistentyp gepflegt wurde.
    IF NOT px_komg-pltyp IS INITIAL.
*     Besorge alle Filialen, die von diesem Preislistentyp betroffen
*     sind.
      CALL FUNCTION 'MATGRP_ALL_PLANTS_VIA_IND1_GET'
        EXPORTING
          pi_matnr           = px_komg-matnr
          pi_pltyp           = px_komg-pltyp
        TABLES
          pe_t_wrf6          = t_wrf6
        EXCEPTIONS
          invalid_parameters = 1
          no_entries_found   = 2
          OTHERS             = 3.

*     Daten sortieren.
      SORT t_wrf6 BY locnr.
    ENDIF. " not px_komg-pltyp is initial.

*   Falls die Kondition zur Filialgruppe einer Aktion geplegt wurde.
    IF NOT px_komg-vkorg IS INITIAL   AND
       NOT px_komg-aktnr IS INITIAL   AND
           px_komg-werks = '*'.
*     Besorge die der Aktion zugeortneten Filialen
      REFRESH: t_bapi1068t6.
      CALL FUNCTION 'PROMOTION_STORES_FIND'
        EXPORTING
          pi_aktnr                = px_komg-aktnr
          pi_artnr                = px_komg-matnr
          pi_vkme                 = px_komg-vrkme
          pi_datum                = pi_periods-datab
          pi_vkorg                = px_komg-vkorg
          pi_vtweg                = px_komg-vtweg
          pi_buffer_stores        = ' '
        TABLES
          pet_filialen            = t_bapi1068t6
        EXCEPTIONS
          promotion_not_found     = 1
          no_store_group_assigned = 2
          no_store_found          = 3.

*     Falls die Filialgruppe aus allen Filialen der Vertriebslinie
*     besteht.
      IF sy-subrc = 2.
        REFRESH: t_bapi1068t6.
        CLEAR:   t_bapi1068t6.
        LOOP AT pit_filia_group.
          MOVE pit_filia_group-locnr TO t_bapi1068t6-plant_customer.
          APPEND t_bapi1068t6.
        ENDLOOP. " at pit_filia_group.
*     Falls die Filial gefunden wurden.
      ELSEIF sy-subrc = 1 OR sy-subrc = 3.
*       Keine weitere Analyse nötig.
        EXIT.
      ENDIF. " sy-subrc = 2.

*     Daten sortieren.
      SORT t_bapi1068t6 BY plant_customer.
    ENDIF. " not px_komg-vkorg is initial and ...

*   Schleife über alle gefundenen Vertriebswege.
    LOOP AT t_vtweg.
*     Besorge alle Filialen, dieser Vertriebslinie,
*     die dieser Filialgruppe angehören, bzw. prüfe,
*     ob die Filiale zu dieser Gruppe gehört.
      LOOP AT pit_filia_group
           WHERE werks  CP px_komg-werks
           AND   locnr  CP px_komg-kunnr
           AND   vkorg  =  px_komg-vkorg
           AND   vtweg  =  t_vtweg-vtweg.

*     Check if corresponding SAP condition type in pit_wind is
*     relevant for this store group concerning POS
        CLEAR pit_kondart.
        READ TABLE pit_kondart WITH KEY kschl = pi_konh-kschl
                                        locnr = pit_filia_group-locnr
                               TRANSPORTING NO FIELDS BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT pit_kondart FROM sy-tabix.
            IF ( pit_kondart-kvewe = pi_konh-kvewe   OR
                 pit_kondart-kvewe = space ).
              EXIT.
            ELSEIF pit_kondart-kschl NE pi_konh-kschl          OR
                   pit_kondart-locnr NE pit_filia_group-locnr.
              CLEAR pit_kondart.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF pit_kondart IS INITIAL.
            CONTINUE.
          ENDIF.
        ELSE.
          CONTINUE.
        ENDIF.

*       Falls die Kondition zum Preislistentyp gepflegt wurde.
        IF NOT px_komg-pltyp IS INITIAL.
*         Prüfe, ob diese Filiale den Preislistentyp der Kondition
*         beinhaltet.
          READ TABLE t_wrf6 WITH KEY
               locnr = pit_filia_group-locnr
               BINARY SEARCH.

*         Falls diese Filiale den Preislistentyp der Kondition
*         nicht beinhaltet, dann ignoriere diesen Satz.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.                 " SY-SUBRC <> 0.
        ENDIF. " not px_komg-pltyp is initial.

*       Falls die Kondition zur Filialgruppe einer Aktion geplegt wurde.
        IF NOT px_komg-vkorg IS INITIAL   AND
           NOT px_komg-aktnr IS INITIAL   AND
           px_komg-werks = '*'.
*         Prüfe, ob diese Filiale dieser Aktion zugeordnet ist.
          READ TABLE t_bapi1068t6 WITH KEY
               plant_customer = pit_filia_group-locnr
               BINARY SEARCH.

*         Falls diese Filiale dieser Aktion nicht zugeordnet ist,
*         dann ignoriere diesen Satz.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.                 " SY-SUBRC <> 0.
        ENDIF. " not px_komg-vkorg is initial and ...

        CLEAR: pet_filia.
        pet_filia-vkorg = pit_filia_group-vkorg.
        pet_filia-filia = pit_filia_group-werks.
        pet_filia-locnr = pit_filia_group-locnr.
        pet_filia-pltyp = pit_filia_group-pltyp.
        pet_filia-waerk = pit_filia_group-waers.

*       Falls der Vertriebsweg <> Referenzvertriebsweg.
        IF pit_filia_group-vtweg <> px_komg-vtweg.
          pet_filia-vtweg = pit_filia_group-vtweg.
        ENDIF. " pit_filia_group-vtweg <> px_komg-vtweg.

        APPEND pet_filia.
      ENDLOOP.                 " AT PIT_FILIA_GROUP
    ENDLOOP. " at t_vtweg.

* Falls die Kondition Vertriebswegunabhängig ist.
  ELSE. " px_komg-vtweg is initial.
*   Falls die Kondition zum Preislistentyp gepflegt wurde.
    IF NOT px_komg-pltyp IS INITIAL.
*     Besorge alle Filialen, die von diesem Preislistentyp betroffen
*     sind.
      CALL FUNCTION 'MATGRP_ALL_PLANTS_VIA_IND1_GET'
        EXPORTING
          pi_matnr           = px_komg-matnr
          pi_pltyp           = px_komg-pltyp
        TABLES
          pe_t_wrf6          = t_wrf6
        EXCEPTIONS
          invalid_parameters = 1
          no_entries_found   = 2
          OTHERS             = 3.

*     Daten sortieren.
      SORT t_wrf6 BY locnr.
    ENDIF. " not px_komg-pltyp is initial.

*   Falls die Kondition nicht zur Verkaufsorganisation gepflegt wurde.
    h_vkorg = px_komg-vkorg.
    IF px_komg-vkorg IS INITIAL.
      h_vkorg = '*'.
    ENDIF.

*   Übernehme alle Filialen dieser Verkaufsorganisation (dieses
*   Mandanten), die für diese Konditonsart POS-Relevant sind.
    LOOP AT pit_filia_group
         WHERE vkorg CP h_vkorg.

*     Check if corresponding SAP condition type in pit_wind is
*     relevant for this store group concerning POS
      CLEAR pit_kondart.
      READ TABLE pit_kondart WITH KEY kschl = pi_konh-kschl
                                      locnr = pit_filia_group-locnr
                             TRANSPORTING NO FIELDS BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT pit_kondart FROM sy-tabix.
          IF ( pit_kondart-kvewe = pi_konh-kvewe   OR
               pit_kondart-kvewe = space ).
            EXIT.
          ELSEIF pit_kondart-kschl NE pi_konh-kschl          OR
                 pit_kondart-locnr NE pit_filia_group-locnr.
            CLEAR pit_kondart.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF pit_kondart IS INITIAL.
          CONTINUE.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.

*     Falls die Kondition zum Preislistentyp gepflegt wurde.
      IF NOT px_komg-pltyp IS INITIAL.
*       Prüfe, ob diese Filiale den Preislistentyp der Kondition
*       beinhaltet.
        READ TABLE t_wrf6 WITH KEY
             locnr = pit_filia_group-locnr
             BINARY SEARCH.

*       Falls diese Filiale den Preislistentyp der Kondition
*       nicht beinhaltet, dann ignoriere diesen Satz.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.                 " SY-SUBRC <> 0.
      ENDIF. " not px_komg-pltyp is initial.

      CLEAR: pet_filia.
      pet_filia-vkorg = pit_filia_group-vkorg.
      pet_filia-vtweg = pit_filia_group-vtweg.
      pet_filia-filia = pit_filia_group-werks.
      pet_filia-locnr = pit_filia_group-locnr.
      pet_filia-pltyp = pit_filia_group-pltyp.
      pet_filia-waerk = pit_filia_group-waers.
      APPEND pet_filia.
    ENDLOOP.                 " AT PIT_FILIA_GROUP
  ENDIF. " not px_komg-vtweg is initial.


ENDFORM. " filia_group_check


*eject.
************************************************************************
FORM varkey_precheck
     TABLES pit_filia_group  STRUCTURE wdl_fil
     USING  pi_komg          STRUCTURE komg
            pe_ignore        LIKE      wpstruc-modus.
***********************************************************************
* FUNKTION:
* Prüfe, ob diese Kondition filialabhängig ist und wenn ja,
* ob sie zu der Gruppe gerade bearbeiteter Filialen gehört.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILIA_GROUP       : Tabelle der Filialen dieser Gruppe.

* PI_KOMG               : Objektschlüssel.

* PE_IGNORE             : = 'X', wenn die betrachtete Konditionsänd.
*                                ignoriert werden kann.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Rücksetze Ergebnisvariable.
  CLEAR:   pe_ignore.

* Falls die Kondition Filialunabhängig ist.
  IF pi_komg-werks IS INITIAL AND
     pi_komg-kunnr IS INITIAL.
*   Falls die Kondition von der Verlkaufsorganisation abhängt.
*   Hinweis: Die Prüfung auf Vertriebsweg an diese Stelle wäre falsch,
*            da es sich um einen Referenzvertriebsweg handeln könnte
*            der sowieso nicht mit dem aktuell zu versorgenden
*            Vertriebsweg übereinstimmt.
    IF NOT pi_komg-vkorg IS INITIAL.
*     Besorge die aktuell zu versorgende Vertriebslinie.
      READ TABLE pit_filia_group INDEX 1.

*     Falls die Verkaufsorganisation übereinstimmt.
      IF pi_komg-vkorg = pit_filia_group-vkorg.
*       Die Konditionsänderung muß weiter analysiert werden.
        EXIT.
*     Falls die Verkaufsorganisation nicht übereinstimmt.
      ELSE. " PI_KOMG-VKORG <> PIT_FILIA_GROUP-VKORG.
*       Setze Ergebnisvariable auf "ignorieren".
        pe_ignore = 'X'.
        EXIT.
      ENDIF. " PI_KOMG-VKORG = PIT_FILIA_GROUP-VKORG.
    ENDIF. " NOT PI_KOMG-VKORG IS INITIAL.
  ENDIF. " pi_komg-werks is initial and  ...

* Falls die Kondition von der Filialnummer abhängt.
  IF NOT pi_komg-werks IS INITIAL.
*   Prüfe ob dieses Werk in der aktuellen Filialgruppen vorkommt.
    LOOP AT pit_filia_group
         WHERE werks = pi_komg-werks.
      EXIT.
    ENDLOOP. " at pit_filia_group

*   Falls dieses Werk nicht in der gerade bearbeiteten
*   Filialgruppe vorkommt, dann kann die Konditionsänderung ignoriert
*   werden.
    IF sy-subrc <> 0.
*     Setze Ergebnisvariable auf "ignorieren".
      pe_ignore = 'X'.
      EXIT.
    ENDIF. " sy-subrc <> 0.
  ENDIF. " not pi_komg-werks is initial.

* Falls die Kondition von der Kundennummer der Filiale abhängt.
  IF NOT pi_komg-kunnr IS INITIAL.
    LOOP AT pit_filia_group
         WHERE locnr = pi_komg-kunnr.
      EXIT.
    ENDLOOP. " at pit_filia_group

*   Falls diese Kundennummer nicht in der gerade bearbeiteten
*   Filialgruppe vorkommt, dann kann die Konditionsänderung ignoriert
*   werden.
    IF sy-subrc <> 0.
*     Setze Ergebnisvariable auf "ignorieren".
      pe_ignore = 'X'.
      EXIT.
    ENDIF. " sy-subrc <> 0.
  ENDIF. " not pi_komg-kunnr is initial.

ENDFORM. " varkey_precheck


*eject.
************************************************************************
FORM periods_get_and_analyse
     TABLES pet_periods_2    STRUCTURE wpperiod
     USING  px_komg          STRUCTURE komg
            pi_konh          STRUCTURE konh
            pi_filia         STRUCTURE gt_filia
            pi_periods       STRUCTURE val_period
            pi_datbi         LIKE      wpstruc-datum
            pi_delete        LIKE      wpstruc-modus
            pe_independence  LIKE      wpstruc-modus.
***********************************************************************
* FUNKTION:
* Besorge die Intervalle aller Konditionstabellen, dieser
* Konditionsart zu diesem Objekt und analysiere, ob sie
* filialunabhängige Einträge enthalten sind.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_KONDART           : Tabelle der POS-relevanten Konditionsarten.

* PET_PERIODS_2         : Tabelle mit den zu untersuchenden
*                         Konditionstabellennummern.
* PX_KOMG               : Objektschlüssel.

* PI_KONH               : Konditionskopfsatz.

* PI_FILIA              : Zusatzwerte der Filiale zum füllen der
*                         KOMG-Struktur.
* PI_PERIODS            : Aktuelle zu analysierendes
*                         Konditionsintervall.
* PI_DATBI              : Endedatum des Betrachtungsintervalls
*
* PI_DELETE             : Es liegt eine Konditionslöschung vor
*
* PE_INDEPENDENCE       : = 'X, wenn nur filialunhabhängige
*                               Konditionsänderungen, sonst SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum zwischenspeichern von Konditionsarten.
  DATA: BEGIN OF t_kondart OCCURS 10.
      INCLUDE STRUCTURE wpkschl.
  DATA: END OF t_kondart.

* Table for storing Conditionsintervals.
  DATA: BEGIN OF t_wcondint OCCURS 20.
      INCLUDE STRUCTURE wcondint.
  DATA: END OF t_wcondint.

* Tabelle mit filialabhängigen Tabellennummern.
  DATA: BEGIN OF t_dep_kotabnr OCCURS 1.
      INCLUDE STRUCTURE wpperiod.
  DATA: END OF t_dep_kotabnr.

* Tabelle mit filialunabhängigen Tabellennummern.
  DATA: BEGIN OF t_indep_kotabnr OCCURS 1.
      INCLUDE STRUCTURE wpperiod.
  DATA: END OF t_indep_kotabnr.

* Struktur für WRF6-Daten.
  DATA: BEGIN OF i_wrf6.
      INCLUDE STRUCTURE wrf6.
  DATA: END OF i_wrf6.

* Tabelle zum Zwischenspeichern von Filialen einer Aktion
  DATA: BEGIN OF t_bapi1068t6  OCCURS 10.
      INCLUDE STRUCTURE bapi1068t6.
  DATA: END OF t_bapi1068t6.


  CLEAR: pispr.

* Rücksetze Ergebnistabelle.
  REFRESH: pet_periods_2.
  CLEAR:   pet_periods_2.

* Merker für Filialunabhängigkeitsprüfung vorbesetzen.
  pe_independence = 'X'.

* Falls die Kondition zur Filialgruppe einer Aktion geplegt wurde.
  IF px_komg-vkorg <> space AND
     px_komg-vtweg <> space AND
     px_komg-aktnr <> space.

    CLEAR: pe_independence.
  ENDIF.

* Versorge restliche KOMG-Felder.
* Verkaufsorganisation.
  IF px_komg-vkorg IS INITIAL.
    px_komg-vkorg = pi_filia-vkorg.
  ENDIF. " px_komg-vkorg is initial.

* Vertriebsweg.
  IF px_komg-vtweg IS INITIAL.
    px_komg-vtweg = pi_filia-vtweg.
  ENDIF. " px_komg-vtweg is initial.

* Filialnummer.
  px_komg-werks = pi_filia-filia.

* Kundennummer.
  px_komg-kunnr = pi_filia-locnr.

* Preislistentyp.
  IF px_komg-pltyp IS INITIAL.
    px_komg-pltyp = pi_filia-pltyp.
  ENDIF. " px_komg-pltyp is initial.

* Währungsschlüssel.
  IF px_komg-waerk IS INITIAL.
    px_komg-waerk = pi_filia-waerk.
  ENDIF. " px_komg-waerk is initial.

* Falls Löschungen untersucht werden sollen und auch gerade
* eine Löschung vorliegt.
  IF NOT c_check_deletions IS INITIAL AND
     NOT pi_delete         IS INITIAL.

*   Übernehme KONH-Eintrag in Ausgabetabelle.
    MOVE-CORRESPONDING pi_konh TO pet_periods_2.
    APPEND pet_periods_2.

* Falls keine Löschungen untersucht werden sollen oder gerade
* keine Löschung vorliegt.
  ELSE.
    REFRESH: t_kondart.
    APPEND pi_konh-kschl TO t_kondart.

*   Besorge die Intervalle aller Konditionstabellen, dieser
*   Konditionsart zu diesem Objekt.
*   Es werden nur diejenigen Konditionstabellen durchsucht
*   bei denen sämtliche Schlüsselfelder (VAKEY) mit den
*   gefüllten Feldinhalten von I_KOMG versorgt werden
*   können und die im Intervall PI_DATAB bis PI_DATBI
*   gültig sind.
    CALL FUNCTION 'WWS_CONDITION_INTERVALS_GET'
      EXPORTING
        komg_i       = px_komg
        datvo_i      = pi_periods-datab
        datbi_i      = pi_datbi
        kvewe_i      = pi_konh-kvewe
        kappl_i      = pi_konh-kappl
        pi_mode      = c_pos_mode
      TABLES
        pi_t_kschl   = t_kondart
        pe_t_condint = t_wcondint.

*   Übernehme Intervalle in Tabelle PET_PERIODS_2.
    LOOP AT t_wcondint.
*     Falls dieses Konditionsintervall nicht mit dem aktuellen
*     übereinstimmt.
      IF t_wcondint-knumh <> pi_konh-knumh.
*       Falls eine indirekte Filialabhängigkeit durch den
*       Preislistentyp in der WRF6 vorliegt.
        IF NOT t_wcondint-pltyp IS INITIAL AND
               pi_filia-pltyp IS INITIAL.

*         Besorge die MARA-Daten des Artikels.
          PERFORM mara_select
                  USING  mara t_wcondint-matnr.

*         Besorge den zugehörigen WRF6-Satz für PLTYP-Vergleich
          CLEAR: i_wrf6.
          CALL FUNCTION 'WRF6_SINGLE_READ'
            EXPORTING
              iv_locnr        = pi_filia-locnr
              iv_matkl        = mara-matkl
              iv_buffer_size  = 2000
            IMPORTING
              es_wrf6         = i_wrf6
            EXCEPTIONS
              not_found       = 1
              parameter_error = 2
              OTHERS          = 3.

          IF sy-subrc = 0.
*           Falls ein Preislistentyp in der Zuordnung Filiale <--> Wrgp
*           (WRF6) gepflegt ist und dieser nicht mit dem Preislistentyp
*           aus dem Konditionsintervall übereinstimmt, dann ist das
*           Konditionsintervall für die aktuelle Filiale nicht relevant
*           und muß ignoriert werden.
            IF i_wrf6-pltyp_p <> t_wcondint-pltyp.
              CONTINUE.
            ENDIF. " i_wrf6-pltyp_p <> t_wcondint-pltyp.
          ENDIF. " sy-subrc = 0
        ENDIF. " not t_wcondint-pltyp is initial and ...

**       Falls eine indirekte Filialabhängigkeit durch eine
**       Filialgruppe einer Aktion vorliegt.
*        if not t_wcondint-vkorg is initial   and
*           not t_wcondint-vtweg is initial   and
*           not t_wcondint-aktnr is initial   and
*               t_wcondint-werks is initial.
**         Besorge die der Aktion zugeortneten Filialen
*          refresh: t_bapi1068t6.
*          call function 'PROMOTION_STORES_FIND'
*               exporting
*                    pi_aktnr                = t_wcondint-aktnr
*                    pi_artnr                = t_wcondint-matnr
*                    pi_vkme                 = t_wcondint-vrkme
*                    pi_datum                = t_wcondint-datab
*                    pi_vkorg                = t_wcondint-vkorg
*                    pi_vtweg                = t_wcondint-vtweg
*               tables
*                    pet_filialen            = t_bapi1068t6
*               exceptions
*                    promotion_not_found     = 1
*                    no_store_group_assigned = 2
*                    no_store_found          = 3
*                    others                  = 4.
*
*          if sy-subrc = 0.
**           Ergebnistabelle sortieren.
*            sort t_bapi1068t6 by plant_customer.
*
**           Prüfe, ob diese Filiale dieser Aktion zugeordnet ist.
*            read table t_bapi1068t6 with key
*                 plant_customer = pi_filia-locnr
*                 binary search.
*
**           Falls diese Filiale nicht für diese Aktion relevant ist,
**           dann muß dieses Konditionsintervall ignoriert werden.
*            if sy-subrc <> 0.
*              continue.
*            endif. " sy-subrc <> 0.
*          else. " sy-subrc <> 0.
**           Falls diese Filiale nicht für diese Aktion relevant ist,
**           dann muß dieses Konditionsintervall ignoriert werden.
*            if sy-subrc <> 2.
*              continue.
*            endif. " sy-subrc <> 2.
*          endif.                           " sy-subrc = 0.
*        endif. " not t_wcondint-vkorg is initial   and ...
      ENDIF. " t_wcondint-knumh <> pi_konh-knumh.

      MOVE-CORRESPONDING t_wcondint TO pet_periods_2.
      APPEND pet_periods_2.
    ENDLOOP.                   " AT t_wcondint.

  ENDIF. " not c_check_deletions is initial and

* Falls bereits Filialabhängigkeit festgestellt wurde, dann
* ist weiter nichts zu tun.
  IF pe_independence IS INITIAL.
    EXIT.
  ENDIF. " pe_independence is initial.

* Bestimme, welche Tabellen in PET_PERIODS_2
* filialabhängig und welche filialunabhängig sind.
  PERFORM table_independence_check
          TABLES pet_periods_2
                 t_indep_kotabnr
                 t_dep_kotabnr
          USING  pi_konh-kvewe.

* Prüfe Intervalle auf Filialabhängigkeit.
  LOOP AT t_dep_kotabnr.
    LOOP AT pet_periods_2
         WHERE kotabnr = t_dep_kotabnr-kotabnr.
*     Merken, daß filialabhängige Intervalle dabei sind.
      CLEAR: pe_independence.
      EXIT.
    ENDLOOP. " at pet_periods_2

*   Schleife verlassen, falls bereits eine
*   Filialabhängigkeit festgestellt wurde.
    IF pe_independence IS INITIAL.
      EXIT.
    ENDIF. " pe_independence is initial.
  ENDLOOP. " at t_dep_kotabnr.


ENDFORM. " periods_get_and_analyse


*eject.
************************************************************************
FORM vrkme_get
     TABLES pet_vrkme   STRUCTURE gt_marm_buf
     USING  pi_komg     STRUCTURE komg.
***********************************************************************
* FUNKTION:
* Besorge alle Verkaufsmengeneinheiten, auf die sich diese
* Konditionsänderung bezieht.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_VRKME  : Tabelle der Verkaufsmengeneinheiten, auf die
*              sich diese Konditionsänderung bezieht.
* PI_KOMG    : Objektschlüssel.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum zwischenspeichern von Materialnummern.
  DATA: BEGIN OF t_matnr  OCCURS 0.
      INCLUDE STRUCTURE gt_matnr.
  DATA: END OF t_matnr.


* Zusätzliche Konditionstabellen möglich aber mit
* folgenden Bedingungen:
* Mußfelder: (VKORG, VTWEG), MATNR.
* Optional:  WERKS, VRKME, EAN11.
* Daher:
* Initialisiere Tabelle für Verkaufsmengeneinheiten.
  REFRESH: pet_vrkme.
  CLEAR:   pet_vrkme.

* Falls die Kondition zur VRKME gepflegt wurde.
  IF pi_komg-vrkme <> space.
*   Erzeuge Eintrag in PET_VRKME.
    pet_vrkme-meinh = pi_komg-vrkme.
    APPEND pet_vrkme.

* Falls die Kondition zur EAN-Nummer gepflegt wurde.
  ELSEIF pi_komg-ean11 <> space.
*   Besorge die zur Artikelnummer und EAN gehörige VRKME.
    SELECT * FROM mean
           WHERE matnr = pi_komg-matnr
           AND   ean11 = pi_komg-ean11.
*     Erzeuge Eintrag in T_SHORT_MARM.
      pet_vrkme-meinh = mean-meinh.
      APPEND pet_vrkme.
      EXIT.
    ENDSELECT.         " * FROM MEAN

* Falls die Kondition weder von der VRKME noch
* von der EAN abhängt.
  ELSEIF pi_komg-vrkme = space AND
         pi_komg-ean11 = space.
*   Übernehme die Materialnummer in interne Tabelle.
    REFRESH: t_matnr.
    APPEND pi_komg-matnr TO t_matnr.

*   Besorge alle dieser Materialnummer zugeordneten
*   Verkaufsmengeneinheiten.
    PERFORM marm_select TABLES t_matnr
                               pet_vrkme
*            using  'X'   ' '   ' '. OSS 785226
                        USING  ' '   ' '   ' '.
*   perform marm_select_3 tables t_matnr
*                              pet_vrkme.
  ENDIF.               " I_KOMG-MATNR <> SPACE...


ENDFORM. " vrkme_get


*eject
************************************************************************
FORM marm_select
     TABLES pit_matnr       STRUCTURE gt_matnr
            pet_marm        STRUCTURE gt_marm_buf
     USING  pi_with_ean     LIKE wpstruc-modus
            pi_matnr        LIKE marm-matnr
            pi_meinh        LIKE marm-meinh.
************************************************************************
* Liefert MARM-Daten nach verschiedenen Selektionskriterien.
* Mit interner Pufferung.
* ----------------------------------------------------------------------
* PARAMETER:
* PIT_MATNR  : Tabelle mit Artikelnummern.

* PET_MARM   : Gelesene reduzierte MARM-Daten.

* PI_WITH_EAN: = 'X', wenn nur diejenigen MARM-Daten gelesen werden
*                     sollen, die eine EAN besitzen, sonst SPACE.
* PI_MATNR   : Materialnummer. Wird nur für den Einzelsatzzugriff
*              benötigt.
* PI_MEINH   : Mengeneinheit. Wird nur für den Einzelsatzzugriff
*              benötigt.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_lines LIKE sy-dbcnt,
        h_tabix LIKE sy-tabix.

  DATA: BEGIN OF t_matnr OCCURS 0.
      INCLUDE  STRUCTURE gt_matnr.
  DATA: END OF t_matnr.

  DATA: BEGIN OF t_marm  OCCURS 0.
      INCLUDE  STRUCTURE marm.
  DATA: END OF t_marm.

  DATA: t_marm_buf LIKE gt_marm_buf OCCURS 0 WITH HEADER LINE.


* Rücksetze Ausgabetabelle.
  REFRESH: pet_marm, t_marm.
  CLEAR:   pet_marm, t_marm.


* Falls Parallelverarbeitung aktiv ist, dann internen Puffer
* aufbauen.
  IF NOT g_parallel IS INITIAL.
*   Prüfe, ob der Puffer zurückgesetzt werden muß.
    DESCRIBE TABLE gt_marm_buf LINES h_lines.

*   Falls der Puffer zurückgesetzt werden muß.
    IF h_lines > c_max_marm_buf.
*     Rücksetze Puffer.
      REFRESH: gt_marm_buf.
      CLEAR:   gt_marm_buf, h_lines.
    ENDIF. " h_lines > c_max_marm_buf.

*   Falls kein Einzelsatz-Zugriff erforderlich ist.
    IF pi_matnr IS INITIAL.
*     Kopiere die Übergebenen Materialnummern.
      t_matnr[] = pit_matnr[].

*     Falls der Puffer gefüllt ist.
      IF h_lines <> 0.
*       Prüfe, welche der gesuchten Daten bereits im Puffer
*       vorhanden sind.
        LOOP AT t_matnr.

          READ TABLE gt_marm_buf WITH KEY
               matnr = t_matnr-matnr
               BINARY SEARCH
               TRANSPORTING NO FIELDS.

          CHECK sy-subrc = 0.

          h_tabix = sy-tabix.

*         Übernehme die im Puffer befindlichen Werte in Ausgabetabelle.
          LOOP AT gt_marm_buf FROM h_tabix.
*           Setze Abbruchbedingung.
            IF gt_marm_buf-matnr <> t_matnr-matnr.
              EXIT.
            ENDIF.

*           Falls eine EAN vorhanden sein soll.
            IF NOT pi_with_ean IS INITIAL.
              IF NOT gt_marm_buf-ean11 IS INITIAL.
                pet_marm = gt_marm_buf.
                APPEND pet_marm.
              ENDIF. " not gt_marm_buf-ean11 is initial.
*           Falls keine EAN vorhanden sein muß.
            ELSE. " pi_with_ean is initial
              pet_marm = gt_marm_buf.
              APPEND pet_marm.
            ENDIF. " not pi_with_ean is initial.
          ENDLOOP. " at gt_marm_buf from h_tabix.

          IF sy-subrc = 0.
            DELETE t_matnr.
          ENDIF. " sy-subrc = 0.
        ENDLOOP. " at t_matnr.
      ENDIF. " h_lines <> 0.

*     Prüfe, ob noch Daten von DB nachgelesen werden müssen.
      READ TABLE t_matnr INDEX 1.

*     Falls noch Daten von DB nachgelesen werden müssen.
      IF sy-subrc = 0.
*       Lese die übrigen MARM-Daten von DB.
        SELECT * FROM marm
               INTO CORRESPONDING FIELDS OF TABLE t_marm_buf
               FOR ALL ENTRIES IN t_matnr
               WHERE matnr = t_matnr-matnr.

        IF sy-subrc = 0.
*         Einsortieren der Daten in den internen Puffer und
*         Ergänzen der Ausgabetabelle.
          LOOP AT t_matnr.
            READ TABLE gt_marm_buf WITH KEY
                 matnr = t_matnr-matnr
                 BINARY SEARCH
                 TRANSPORTING NO FIELDS.

            h_tabix = sy-tabix.

            LOOP AT t_marm_buf
                 WHERE matnr = t_matnr-matnr.
              gt_marm_buf = t_marm_buf.
              INSERT gt_marm_buf INDEX h_tabix.
              ADD 1 TO h_tabix.

*             Falls eine EAN vorhanden sein soll.
              IF NOT pi_with_ean IS INITIAL.
                IF NOT gt_marm_buf-ean11 IS INITIAL.
                  pet_marm = gt_marm_buf.
                  APPEND pet_marm.
                ENDIF. " not gt_marm_buf-ean11 is initial.
*             Falls keine EAN vorhanden sein muß.
              ELSE. " pi_with_ean is initial
                pet_marm = gt_marm_buf.
                APPEND pet_marm.
              ENDIF. " not pi_with_ean is initial.

            ENDLOOP. " at t_marm_buf.
          ENDLOOP. " at t_matnr.
        ENDIF. " sy-subrc = 0.
      ENDIF. " sy-subrc = 0.

*   Falls ein Einzelsatz-Zugriff erforderlich ist.
    ELSE. " not pi_matnr is initial.
*     Prüfe, ob der Puffer die notwendigen Daten enthält.
      SORT gt_marm_buf.
      READ TABLE gt_marm_buf WITH KEY
           matnr = pi_matnr
           BINARY SEARCH.

*     Falls die Daten bereits im Puffer sind.
      IF sy-subrc = 0.
        h_tabix = sy-tabix.

*       Übernehme die im Puffer befindlichen Werte in Ausgabetabelle.
        LOOP AT gt_marm_buf FROM h_tabix.
*         Setze Abbruchbedingung.
          IF gt_marm_buf-matnr <> pi_matnr.
            EXIT.
          ENDIF.

          IF gt_marm_buf-meinh = pi_meinh.
*           Falls eine EAN vorhanden sein soll.
            IF NOT pi_with_ean IS INITIAL.
              IF NOT gt_marm_buf-ean11 IS INITIAL.
                pet_marm = gt_marm_buf.
                APPEND pet_marm.
              ENDIF. " not gt_marm_buf-ean11 is initial.
*           Falls keine EAN vorhanden sein muß.
            ELSE. " pi_with_ean is initial
              pet_marm = gt_marm_buf.
              APPEND pet_marm.
            ENDIF. " not pi_with_ean is initial.
          ENDIF. " gt_marm_buf-meinh = pi_meinh.
        ENDLOOP. " at gt_marm_buf from h_tabix.

*     Falls noch Daten von DB nachgelesen werden müssen.
      ELSE. " sy-subrc <> 0
*       Lese die übrigen MARM-Daten von DB.
        SELECT * FROM marm
               INTO CORRESPONDING FIELDS OF TABLE t_marm_buf
               WHERE matnr = pi_matnr ORDER BY matnr meinh.

        IF sy-subrc = 0.
*         Einsortieren der Daten in den internen Puffer und
*         Ergänzen der Ausgabetabelle.
          READ TABLE gt_marm_buf WITH KEY
               matnr = pi_matnr
               BINARY SEARCH.

          h_tabix = sy-tabix.

          LOOP AT t_marm_buf.

            gt_marm_buf = t_marm_buf.
            INSERT gt_marm_buf INDEX h_tabix.
            ADD 1 TO h_tabix.

*           Übernehme die im Puffer befindlichen Werte in
*           Ausgabetabelle.
            IF gt_marm_buf-meinh = pi_meinh.
*             Falls eine EAN vorhanden sein soll.
              IF NOT pi_with_ean IS INITIAL.
                IF NOT gt_marm_buf-ean11 IS INITIAL.
                  pet_marm = gt_marm_buf.
                  APPEND pet_marm.
                ENDIF. " not gt_marm_buf-ean11 is initial.
*             Falls keine EAN vorhanden sein muß.
              ELSE. " pi_with_ean is initial
                pet_marm = gt_marm_buf.
                APPEND pet_marm.
              ENDIF. " not pi_with_ean is initial.
            ENDIF. " gt_marm_buf-meinh = pi_meinh.

          ENDLOOP. " at t_marm_buf.
        ENDIF. " sy-subrc = 0.
      ENDIF. " sy-subrc = 0.
    ENDIF. " pi_matnr is initial.

*   Ausgabetabelle sortieren.
    SORT pet_marm BY matnr meinh.

* Falls Parallelverarbeitung inaktiv ist, dann nur Standardpuffer
* verwenden.
  ELSE. " g_parallel is initial.
*   Falls kein Einzelsatz-Zugriff erforderlich ist.
    IF pi_matnr IS INITIAL.
*     Kopiere die Übergebenen Materialnummern.
      t_matnr[] = pit_matnr[].

*     Prüfe, welche der gesuchten Daten bereits im Puffer
*     vorhanden sind.
      LOOP AT t_matnr.
*       Besorge die zugehörigen MARM-Daten.
        CALL FUNCTION 'MARM_GENERIC_READ_WITH_MATNR'
          EXPORTING
            matnr      = t_matnr-matnr
          TABLES
            marm_tab   = t_marm
          EXCEPTIONS
            wrong_call = 1
            not_found  = 2
            OTHERS     = 3.
*       Übernehme die Werte in Ausgabetabelle.
        LOOP AT t_marm.
*         Falls eine EAN vorhanden sein soll.
          IF NOT pi_with_ean IS INITIAL.
            IF NOT t_marm-ean11 IS INITIAL.
              MOVE-CORRESPONDING t_marm TO pet_marm.
              APPEND pet_marm.
            ENDIF. " not gt_marm_buff-ean11 is initial.
*         Falls keine EAN vorhanden sein muß.
          ELSE. " pi_with_ean is initial
            MOVE-CORRESPONDING t_marm TO pet_marm.
            APPEND pet_marm.
          ENDIF. " not pi_with_ean is initial.
        ENDLOOP. " at t_marm
      ENDLOOP. " at t_matnr.

*   Falls ein Einzelsatz-Zugriff erforderlich ist.
    ELSE. " not pi_matnr is initial.
*     Besorge den zugehörigen MARM-Satz.
      CALL FUNCTION 'MARM_SINGLE_READ'
        EXPORTING
          maxtz      = c_max_marm_buf
          matnr      = pi_matnr
          meinh      = pi_meinh
        IMPORTING
          wmarm      = t_marm
        EXCEPTIONS
          wrong_call = 1
          not_found  = 2
          OTHERS     = 3.

*     Übernehme die Werte in Ausgabetabelle.
*     Falls eine EAN vorhanden sein soll.
      IF NOT pi_with_ean IS INITIAL.
        IF NOT t_marm-ean11 IS INITIAL.
          MOVE-CORRESPONDING t_marm TO pet_marm.
          APPEND pet_marm.
        ENDIF. " not t_marm-ean11 is initial.
*     Falls keine EAN vorhanden sein muß.
      ELSE. " pi_with_ean is initial
        MOVE-CORRESPONDING t_marm TO pet_marm.
        APPEND pet_marm.
      ENDIF. " not pi_with_ean is initial.
    ENDIF. " pi_matnr is initial.

*   Ausgabetabelle sortieren.
    SORT pet_marm BY matnr meinh.
  ENDIF. " not g_parallel is initial.


ENDFORM.                               " marm_select


*eject
************************************************************************
*form marm_select_2
*     tables pit_matnr       structure gt_matnr
*            pet_marm        structure gt_marm_buf
*     using  pi_with_ean     like wpstruc-modus
*            pi_matnr        like marm-matnr
*            pi_meinh        like marm-meinh.
************************************************************************
* Liefert MARM-Daten nach verschiedenen Selektionskriterien.
* Mit interner Pufferung.
* ----------------------------------------------------------------------
* PARAMETER:
* PIT_MATNR  : Tabelle mit Artikelnummern.

* PET_MARM   : Gelesene reduzierte MARM-Daten.

* PI_WITH_EAN: = 'X', wenn nur diejenigen MARM-Daten gelesen werden
*                     sollen, die eine EAN besitzen, sonst SPACE.
* PI_MATNR   : Materialnummer. Wird nur für den Einzelsatzzugriff
*              benötigt.
* PI_MEINH   : Mengeneinheit. Wird nur für den Einzelsatzzugriff
*              benötigt.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
**data: h_lines like sy-dbcnt.
*
* data: begin of t_matnr occurs 0.
*         include  structure gt_matnr.
* data: end of t_matnr.
*
* Prüfe, ob der Puffer zurückgesetzt werden muß.
**describe table gt_marm_buff lines h_lines.
*
* Falls der Puffer zurückgesetzt werden muß.
* if h_lines > c_max_marm_buf.
*   Rücksetze Puffer.
**  refresh: gt_marm_buff.
* endif. " h_lines > c_max_marm_buf.
*
* Rücksetze Ausgabetabelle.
* refresh: pet_marm.
* clear:   pet_marm.
*
**Falls kein Einzelsatz-Zugriff erforderlich ist.
* if pi_matnr is initial.
*   Kopiere die Übergebenen Materialnummern.
*   t_matnr[] = pit_matnr[].
**
*   Falls der Puffer gefüllt ist.
*   if h_lines <> 0.
*     Prüfe, welche der gesuchten Daten bereits im Puffer
*     vorhanden sind.
*     loop at t_matnr.
*       Übernehme die im Puffer befindlichen Werte in Ausgabetabelle.
**      loop at gt_marm_buff
*            where matnr =  t_matnr-matnr.
*         Falls eine EAN vorhanden sein soll.
*         if not pi_with_ean is initial.
*           if not gt_marm_buff-ean11 is initial.
**            pet_marm = gt_marm_buff.
*             append pet_marm.
*           endif. " not gt_marm_buff-ean11 is initial.
*         Falls keine EAN vorhanden sein muß.
*         else. " pi_with_ean is initial
*           pet_marm = gt_marm_buff.
*           append pet_marm.
**        endif. " not pi_with_ean is initial.
*       endloop. " at gt_marm_buff
*
*       if sy-subrc = 0.
*         delete t_matnr.
**      endif. " sy-subrc = 0.
*     endloop. " at t_matnr.
*   endif. " h_lines <> 0.
*
*   Prüfe, ob noch Daten von DB nachgelesen werden müssen.
*   read table t_matnr index 1.
*
**  Falls noch Daten von DB nachgelesen werden müssen.
*   if sy-subrc = 0.
*     Lese die übrigen MARM-Daten von DB.
*     select * from marm
*            appending corresponding fields of table gt_marm_buff
**           for all entries in t_matnr
*            where matnr = t_matnr-matnr.
*   endif. " sy-subrc = 0.
*
*   Lese restliche Daten aus Puffer
*   loop at t_matnr.
*     Übernehme die im Puffer befindlichen Werte in Ausgabetabelle.
**    loop at gt_marm_buff
*          where matnr =  t_matnr-matnr.
*       Falls eine EAN vorhanden sein soll.
*       if not pi_with_ean is initial.
*         if not gt_marm_buff-ean11 is initial.
**          pet_marm = gt_marm_buff.
*           append pet_marm.
*         endif. " not gt_marm_buff-ean11 is initial.
*       Falls keine EAN vorhanden sein muß.
*       else. " pi_with_ean is initial
*         pet_marm = gt_marm_buff.
*         append pet_marm.
**      endif. " not pi_with_ean is initial.
*     endloop. " at gt_marm_buff
*   endloop. " at t_matnr.
*
* Falls ein Einzelsatz-Zugriff erforderlich ist.
* else. " not pi_matnr is initial.
**  Übernehme die im Puffer befindlichen Werte in Ausgabetabelle,
*   falls möglich.
*   loop at gt_marm_buff
*        where matnr =  pi_matnr
*        and   meinh =  pi_meinh.
*     Falls eine EAN vorhanden sein soll.
*     if not pi_with_ean is initial.
**      if not gt_marm_buff-ean11 is initial.
*         pet_marm = gt_marm_buff.
*         append pet_marm.
*       endif. " not gt_marm_buff-ean11 is initial.
*     Falls keine EAN vorhanden sein muß.
*     else. " pi_with_ean is initial
**      pet_marm = gt_marm_buff.
*       append pet_marm.
*     endif. " not pi_with_ean is initial.
*
*     Schleife verlassen, da nur ein Satz gelesen werden soll.
*     exit.
*   endloop. " at gt_marm_buff
**
*   Falls noch Daten von DB nachgelesen werden müssen.
*   if sy-subrc <> 0.
*     Lese die übrigen MARM-Daten von DB.
*     select * from marm
**           appending corresponding fields of table gt_marm_buff
*            where matnr = pi_matnr
*            and   meinh = pi_meinh.
*
*     Übernehme Daten in Ausgabetabelle,
*     loop at gt_marm_buff
*          where matnr =  pi_matnr
**         and   meinh =  pi_meinh.
*       Falls eine EAN vorhanden sein soll.
*       if not pi_with_ean is initial.
*         if not gt_marm_buff-ean11 is initial.
*           pet_marm = gt_marm_buff.
**          append pet_marm.
*         endif. " not gt_marm_buff-ean11 is initial.
*       Falls keine EAN vorhanden sein muß.
*       else. " pi_with_ean is initial
*         pet_marm = gt_marm_buff.
*         append pet_marm.
*       endif. " not pi_with_ean is initial.
**
*       Schleife verlassen, da nur ein Satz gelesen werden soll.
**      exit.
*     endloop. " at gt_marm_buff
*   endif. " sy-subrc <> 0.
* endif. " pi_matnr is initial.
*
* Ausgabetabelle sortieren.
* sort pet_marm by matnr meinh.
**

*endform.                               " marm_select


*eject
************************************************************************
FORM filia_group_preprare
     TABLES pit_filia_group     STRUCTURE gt_filia_group
            pit_kondart_gesamt  STRUCTURE twpek
            pxt_statistik       STRUCTURE gt_statistik
            pxt_statistik_wdlsp STRUCTURE gt_statistik_wdlsp
            pxt_reorg_pointer   STRUCTURE bdicpident
     USING  pi_erstdat          LIKE syst-datum
            pi_erstzeit         LIKE syst-uzeit
            pi_mode             LIKE wpstruc-modus
            pi_pointer_reorg    LIKE wpstruc-modus
            pi_filia_group_no   LIKE wpfiliagrp-group
            pi_parallel         LIKE wpstruc-parallel
            pi_server_group     LIKE wpstruc-servergrp
            pi_fil_grp_size     LIKE wpstruc-filsgrpsize
            pi_taskname         LIKE wpstruc-counter6
            px_snd_jobs         LIKE wpstruc-counter6
            pi_wind             LIKE wpstruc-cond_index.
************************************************************************
* FUNKTION:
* Verarbeitung einer einzelnen Filialgruppe.
* Wenn das Flag PI_PARALLEL gesetzt ist, dann wird die Verarbeitung in
* einem parallelen Task durchgeführt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILIA_GROUP    : Daten einer Filialgruppe

* PIT_KONDART_GESAMT : Tabelle aler unterschiedlichen Konditionsarten
*                      aller Filialen. Ist nur bei Pointer-Reorg
*                      gefüllt.
* PXT_STATISTIK      : Statistikdaten für Listaufbereitung.

* PXT_STATISTIK_WDLSP: WDLSP-Daten für Listaufbereitung.

* PXT_REORG_POINTER  : Pointer, die reorganisiert werden sollen.

* PI_ERSTDAT         : Startdatum der Aufbereitung

* PI_ERSTZEIT        : Startzeit der Aufbereitung

* PI_MODE            : Download-Modus: = 'U', wenn Änderungsfall.

* PI_POINTER_REORG   : = 'X', wenn Pointer-Reorg erwünscht, sonst SPACE.

* PI_FILIA_GROUP_NO  : Nummer der gerade bearbeiteten Filialgruppe

* PI_PARALLEL        : = 'X', wenn Parallelverarbeitung erwünscht,
*                           sonst SPCACE.
* PI_SERVER_GROUP    : Name der Server-Gruppe für Parallelverarbeitung

* PI_FIL_GRP_SIZE    : Anzahl der Filialen pro parallelen Task
*
* PI_TASKNAME        : Identifiziernder Name des neuen Tasks

* PX_SND_JOBS        : Anzahl der gestarteten parallelen Tasks.

* PI_WIND            : Die Konditionsanalyse solle über
*                      Konditionsbelegindex erfolgen.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle der reorganisierbaren Pointer-ID's.
  DATA: BEGIN OF t_reorg_pointer_temp OCCURS 10.
      INCLUDE STRUCTURE bdicpident.
  DATA: END OF t_reorg_pointer_temp.

* Tabelle zum speichern von Daten für spätere Listaufbereitung.
  DATA: BEGIN OF t_statistik OCCURS 1.
      INCLUDE STRUCTURE wplistdata.
  DATA: END OF t_statistik.

* Tabelle zum speichern von Daten für spätere Listaufbereitung.
  DATA: BEGIN OF t_statistik_wdlsp OCCURS 1.
      INCLUDE STRUCTURE wpstatwdlsp.
  DATA: END OF t_statistik_wdlsp.


* Falls nicht parallelisiert werden soll.
  IF pi_parallel IS INITIAL.
*   Aufbereitung dieser Filialgruppe.
    CALL FUNCTION 'POS_FILIA_GROUP_PREPARE'
      EXPORTING
        pi_erstdat          = pi_erstdat
        pi_erstzeit         = pi_erstzeit
        pi_mode             = pi_mode
        pi_filia_group_no   = pi_filia_group_no
        pi_pointer_reorg    = pi_pointer_reorg
        pi_parallel         = pi_parallel
        pi_server_group     = pi_server_group
        pi_taskname         = pi_taskname
        pi_wind             = pi_wind
      TABLES
        pit_filia_group     = pit_filia_group
        pit_kondart_gesamt  = pit_kondart_gesamt
        pet_statistik       = t_statistik
        pet_statistik_wdlsp = t_statistik_wdlsp
        pet_reorg_pointer   = t_reorg_pointer_temp.

*   Falls Pointer reorganisiert werden sollen.
    IF pi_pointer_reorg <> space.
*     Übernehme die reorganisierbaren Pointer-ID's in Ausgabetabelle.
      LOOP AT t_reorg_pointer_temp.
        APPEND t_reorg_pointer_temp TO pxt_reorg_pointer.
      ENDLOOP. " at t_reorg_pointer_temp
    ENDIF. " pi_pointer_reorg <> space.

*   Übernehme Statistikdaten in die Ausgabetabellen.
    LOOP AT t_statistik.
      APPEND t_statistik TO pxt_statistik.
    ENDLOOP. " at t_statistik

    LOOP AT t_statistik_wdlsp.
      APPEND t_statistik_wdlsp TO pxt_statistik_wdlsp.
    ENDLOOP. " at t_statistik_wdlsp

* Falls  parallelisiert werden soll.
  ELSE. " not pi_parallel is initial.
*   Übernehme Varialblen für Wiederaufsetzen im Fehlerfalle in
*   interne Tabelle.
    CLEAR: gt_task_variables_grp.
    gt_task_variables_grp-taskname = pi_taskname.
    gt_task_variables_grp-number   = pi_filia_group_no.
    APPEND gt_task_variables_grp.

*   Merke, ob Pointer-Reorg oder nicht.
    g_pt_reorg = pi_pointer_reorg.

*   Aufbereitung dieser Filialgruppe in parallelem Task.
    CALL FUNCTION 'POS_FILIA_GROUP_PREPARE'
      STARTING NEW TASK pi_taskname
      DESTINATION IN GROUP pi_server_group
      PERFORMING return_filia_group_prepare ON END OF TASK
      EXPORTING
        pi_erstdat            = pi_erstdat
        pi_erstzeit           = pi_erstzeit
        pi_mode               = pi_mode
        pi_filia_group_no     = pi_filia_group_no
        pi_pointer_reorg      = pi_pointer_reorg
        pi_parallel           = pi_parallel
        pi_server_group       = pi_server_group
        pi_fil_grp_size       = pi_fil_grp_size
        pi_taskname           = pi_taskname
        pi_wind               = pi_wind
      TABLES
        pit_filia_group       = pit_filia_group
        pit_kondart_gesamt    = pit_kondart_gesamt
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        resource_failure      = 3.

*   Falls eine Parallelverarbeitung gerade nicht möglich ist, dann
*   dann arbeite sequentiell.
    IF sy-subrc <> 0.
*     Falls Probleme mit dem Zielsystem auftraten.
      IF sy-subrc <> 3.
        CLEAR: gt_rfcdest_grp.

*       Aktualisiere Fehlertabelle für Zielsysteme.
        gt_rfcdest_grp-subrc = sy-subrc.
        CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
          IMPORTING
            rfcdest = gt_rfcdest_grp-rfcdest.

*       Aktualisiere System-Zeitstempel
        COMMIT WORK.

        gt_rfcdest_grp-datum    = sy-datum.
        gt_rfcdest_grp-uzeit    = sy-uzeit.
        gt_rfcdest_grp-no_start = 'X'.
        APPEND gt_rfcdest_grp.
      ENDIF. " sy-subrc <> 3.

*     Aufbereitung dieser Filialgruppe.
      CALL FUNCTION 'POS_FILIA_GROUP_PREPARE'
        EXPORTING
          pi_erstdat          = pi_erstdat
          pi_erstzeit         = pi_erstzeit
          pi_mode             = pi_mode
          pi_filia_group_no   = pi_filia_group_no
          pi_pointer_reorg    = pi_pointer_reorg
          pi_parallel         = pi_parallel
          pi_server_group     = pi_server_group
          pi_taskname         = pi_taskname
        TABLES
          pit_filia_group     = pit_filia_group
          pit_kondart_gesamt  = pit_kondart_gesamt
          pet_statistik       = t_statistik
          pet_statistik_wdlsp = t_statistik_wdlsp
          pet_reorg_pointer   = t_reorg_pointer_temp.

*     Falls Pointer reorganisiert werden sollen.
      IF pi_pointer_reorg <> space.
*       Übernehme die reorganisierbaren Pointer-ID's in Ausgabetabelle.
        LOOP AT t_reorg_pointer_temp.
          APPEND t_reorg_pointer_temp TO pxt_reorg_pointer.
        ENDLOOP. " at t_reorg_pointer_temp
      ENDIF. " pi_pointer_reorg <> space.

*     Übernehme Statistikdaten in die Ausgabetabellen.
      LOOP AT t_statistik.
        APPEND t_statistik TO pxt_statistik.
      ENDLOOP. " at t_statistik

      LOOP AT t_statistik_wdlsp.
        APPEND t_statistik_wdlsp TO pxt_statistik_wdlsp.
      ENDLOOP. " at t_statistik_wdlsp

*   Falls eine Parallelverarbeitung möglich ist.
    ELSE. " sy-subrc = 0.
*     Bestimme die verwendetet Destination.
      CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
        IMPORTING
          rfcdest = gt_rfc_indicator_grp-rfcdest.

*     Merken der gestarteten Destination.
      gt_rfc_indicator_grp-taskname = pi_taskname.
      APPEND gt_rfc_indicator_grp.

*     Aktualisiere die Anzahl der parallelen Tasks
      ADD 1 TO px_snd_jobs.
    ENDIF. " sy-subrc <> 0.


  ENDIF. " pi_pointer_reorg <> space.


ENDFORM. " filia_group_preprare


*eject
************************************************************************
FORM filia_sub_group_prepare
     TABLES pit_filia_sub_group    STRUCTURE gt_filia_sub_group
            pit_kondart            STRUCTURE gt_kondart
            pxt_statistik          STRUCTURE gt_statistik
            pxt_statistik_wdlsp    STRUCTURE gt_statistik_wdlsp
            pit_ot1_f_wrgp         STRUCTURE gt_ot1_f_wrgp
            pit_ot2_wrgp           STRUCTURE gt_ot2_wrgp
            pit_ot1_f_artstm       STRUCTURE gt_ot1_f_artstm
            pit_ot2_artstm         STRUCTURE gt_ot2_artstm
            pit_ot1_f_ean          STRUCTURE gt_ot1_f_ean
            pit_ot2_ean            STRUCTURE gt_ot2_ean
            pit_ot1_f_sets         STRUCTURE gt_ot1_f_sets
            pit_ot2_sets           STRUCTURE gt_ot2_sets
            pit_ot1_f_nart         STRUCTURE gt_ot1_f_nart
            pit_ot2_nart           STRUCTURE gt_ot2_nart
            pit_ot1_k_pers         STRUCTURE gt_ot1_k_pers
            pit_ot2_pers           STRUCTURE gt_ot2_pers
            pit_ot1_f_promreb      STRUCTURE gt_ot1_f_promreb
            pit_ot2_promreb        STRUCTURE gt_ot2_promreb
            pxt_independence_check STRUCTURE gt_independence_check
            pxt_artdel             STRUCTURE gt_artdel
            pit_filter_segs        STRUCTURE gt_filter_segs
            pet_rfcdest            STRUCTURE gt_rfcdest
            pit_artdel             STRUCTURE gt_artdel
            pit_mara_buf           STRUCTURE gt_mara_buf
            pit_marm_buf           STRUCTURE gt_marm_buf
            pit_mvke_buf           STRUCTURE gt_mvke_buf
            pit_a071_matnr         STRUCTURE gt_a071_matnr
            pit_old_ean            STRUCTURE gt_old_ean
            pit_old_ean_nart       STRUCTURE gt_old_ean_nart
            pit_old_ean_set        STRUCTURE gt_old_ean_set
            pit_zus_ean_del        STRUCTURE gt_zus_ean_del
            pit_ean_change         STRUCTURE gt_ean_change
     USING  pi_erstdat             LIKE syst-datum
            pi_erstzeit            LIKE syst-uzeit
            pi_datp3               LIKE syst-datum
            pi_datp4               LIKE syst-datum
            pi_mode                LIKE wpstruc-modus
            pi_parallel            LIKE wpstruc-parallel
            pi_server_group        LIKE wpstruc-servergrp
            px_taskname            LIKE wpstruc-counter6
            px_snd_jobs            LIKE wpstruc-counter6
            pi_mestype_wrgp        LIKE g_mestype_wrgp
            pi_mestype_artstm      LIKE g_mestype_artstm
            pi_mestype_ean         LIKE g_mestype_ean
            pi_mestype_set         LIKE g_mestype_set
            pi_mestype_nart        LIKE g_mestype_nart
            pi_mestype_steu        LIKE g_mestype_steu
            pi_mestype_cur         LIKE g_mestype_cur
            pi_mestype_pers        LIKE g_mestype_pers
            pi_mestype_prom        LIKE g_mestype_prom
            pi_sub_group           LIKE gt_filia_group_temp-group
            pi_pointer_no          TYPE i.
************************************************************************
* FUNKTION:
* Verarbeitung einer einzelnen Filialuntergruppe.
* Wenn das Flag PI_PARALLEL gesetzt ist, dann wird die Verarbeitung in
* einem parallelen Task durchgeführt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILIA_SUB_GROUP   : Tabelle mit allen Filialen die zur aktuellen
*                         Filialuntergruppe gehören.
* PIT_KONDART           : Tabelle mit POS-relevanten Konditionsarten.
*
* PXT_STATISTIK         : Statistikdaten für Listaufbereitung.
*
* PXT_STATISTIK_WDLSP   : WDLSP-Daten für Listaufbereitung.
*
* PIT_OT1_F_WRGP        : Warengruppen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_WRGP          : Warengruppen: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT1_F_ARTSTM      : Artikelstamm: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_ARTSTM        : Artikelstamm: Objekttabelle 2,
*                         filialunabhängig.
* PET_OT1_F_EAN         : EAN-Referenzen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_EAN           : EAN-Referenzen: Objekttabelle 2,
*
* PIT_OT1_F_SETS        : Set-Zuordnungen: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_SETS          : Set-Zuordnungen: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT1_F_NART        : Nachzugsartikel: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_NART          : Nachzugsartikel: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT1_K_PERS        : Personendaten: Objekttabelle 1,
*                         Kreditkontrollbereichsabhängig.
* PIT_OT2_PERS          : Personendaten: Objekttabelle 2,
*                         filialunabhängig.
* PIT_OT1_F_PROMREB     : Aktionsrabatte: Objekttabelle 1,
*                         filialabhängig.
* PIT_OT2_PROMREB       : Aktionsrabatte: Objekttabelle 2,
*                         filialunabhängig.
* PXT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_ARTDEL            : Tabelle für zu löschende Artikel
*
* PET_WLK2              : Gesammelte Bewirtschaftungszeiträume der
*                         Filiale.
* PIT_FILTER_SEGS       : Reduzierinformationen.
*
* PET_RFCDEST           : Tabelle der abgebrochenen parallelen Tasks
*
* PIT_ARTDEL            : Tabelle der zu löschenden Artikel
*
* PIT_MARA_BUF          : MARA-Puffer.
*
* PIT_MARM_BUF          : MARM-Puffer.
*
* PIT_MVKE_BUF          : MVKE-Puffer.
*
* PIT_A071_MATNR        : Alle Artikel aus Tabelle A071
*
* PIT_OLD_EAN           : Puffer für Haupt-EAN's.
*
* PIT_OLD_EAN_NART      : Lösch-EAN's für Nachzugsartikel
*
* PIT_OLD_EAN_SET       : Lösch-EAN's für Setartikel
*
* PIT_ZUS_EAN_DEL       : Puffer für zusätzliche EAN-Löschsätze
*                         (Falls im POS-Ausgangsprofil so eingestellt)
* PIT_EAN_CHANGE        :  Puffer für EAN-Änderungen
*
* PI_ERSTDAT            : Datum: jetziges Versenden.
*
* PI_ERSTZEIT           : Zeit : jetziges Versenden.
*
* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.
*
* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.
*
* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus
*
* PI_PARALLEL           : = 'X', wenn Parallelverarbeitung erwünscht,
*                              sonst SPCACE.
* PI_SERVER_GROUP       : Name der Server-Gruppe für
*                         Parallelverarbeitung
* PX_TASKNAME           : Identifiziernder Name des neuen Tasks
*
* PX_SND_JOBS           : Anzahl der gestarteten parallelen Tasks.
*
* PI_MESTYPE_WRGP       : Zu verwendender Nachrichtentyp für
*                         Objekt Warengruppen.
* PI_MESTYPE_ARTSTM     : Zu verwendender Nachrichtentyp für
*                         Objekt Artikelstamm.
* PI_MESTYPE_EAN        : Zu verwendender Nachrichtentyp für
*                         Objekt EAN-Referenzen.
* PI_MESTYPE_SETS       : Zu verwendender Nachrichtentyp für
*                         Objekt SET-Zuordnungen.
* PI_MESTYPE_NART       : Zu verwendender Nachrichtentyp für
*                         Objekt Nachzugsartikel.
* PI_MESTYPE_STEU       : Zu verwendender Nachrichtentyp für
*                         Objekt Steuern.
* PI_MESTYPE_CUR        : Zu verwendender Nachrichtentyp für
*                         Objekt Wechselcurse.
* PI_MESTYPE_PERS       : Zu verwendender Nachrichtentyp für
*                         Objekt Personendaten.
* PI_MESTYPE_PROM       : Zu verwendender Nachrichtentyp für
*                         Objekt Aktionsrabatte.
* PI_SUB_GROUP          : Nummer der Filialuntergruppe
*
* PI_POINTER_NO         : Anzahl der selektierten Änderungszeiger
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum speichern von Daten für spätere Listaufbereitung.
  DATA: BEGIN OF t_statistik OCCURS 1.
      INCLUDE STRUCTURE wplistdata.
  DATA: END OF t_statistik.

* Tabelle zum speichern von Daten für spätere Listaufbereitung.
  DATA: BEGIN OF t_statistik_wdlsp OCCURS 1.
      INCLUDE STRUCTURE wpstatwdlsp.
  DATA: END OF t_statistik_wdlsp.


* Falls nicht parallelisiert werden soll.
  IF pi_parallel IS INITIAL.
*   Aufbereitung dieser Filialuntergruppe.
    CALL FUNCTION 'POS_FILIA_SUB_GROUP_PREPARE'
      EXPORTING
        pi_erstdat             = pi_erstdat
        pi_erstzeit            = pi_erstzeit
        pi_datp3               = pi_datp3
        pi_datp4               = pi_datp4
        pi_mode                = pi_mode
        pi_parallel            = pi_parallel
        pi_mestype_wrgp        = pi_mestype_wrgp
        pi_mestype_artstm      = pi_mestype_artstm
        pi_mestype_ean         = pi_mestype_ean
        pi_mestype_set         = pi_mestype_set
        pi_mestype_nart        = pi_mestype_nart
        pi_mestype_steu        = pi_mestype_steu
        pi_mestype_cur         = pi_mestype_cur
        pi_mestype_pers        = pi_mestype_pers
        pi_mestype_prom        = pi_mestype_prom
        pi_pointer_no          = pi_pointer_no
      TABLES
        pit_filia_sub_group    = pit_filia_sub_group
        pit_kondart            = pit_kondart
        pxt_statistik          = t_statistik
        pxt_statistik_wdlsp    = t_statistik_wdlsp
        pit_ot1_f_wrgp         = pit_ot1_f_wrgp
        pit_ot2_wrgp           = pit_ot2_wrgp
        pit_ot1_f_artstm       = pit_ot1_f_artstm
        pit_ot2_artstm         = pit_ot2_artstm
        pit_ot1_f_ean          = pit_ot1_f_ean
        pit_ot2_ean            = pit_ot2_ean
        pit_ot1_f_sets         = pit_ot1_f_sets
        pit_ot2_sets           = pit_ot2_sets
        pit_ot1_f_nart         = pit_ot1_f_nart
        pit_ot2_nart           = pit_ot2_nart
        pit_ot1_k_pers         = pit_ot1_k_pers
        pit_ot2_pers           = pit_ot2_pers
        pit_ot1_f_promreb      = pit_ot1_f_promreb
        pit_ot2_promreb        = pit_ot2_promreb
        pxt_independence_check = pxt_independence_check
        pxt_artdel             = pxt_artdel
        pit_filter_segs        = pit_filter_segs.

*   Übernehme Statistikdaten in die Ausgabetabellen.
    LOOP AT t_statistik.
      APPEND t_statistik TO pxt_statistik.
    ENDLOOP. " at t_statistik

    LOOP AT t_statistik_wdlsp.
      APPEND t_statistik_wdlsp TO pxt_statistik_wdlsp.
    ENDLOOP. " at t_statistik_wdlsp

* Falls  parallelisiert werden soll.
  ELSE. " not pi_parallel is initial.

    ADD 10 TO px_taskname.

*   Übernehme Variablen für Wiederaufsetzen im Fehlerfalle in
*   interne Tabelle.
    CLEAR: gt_task_variables_sub.
    gt_task_variables_sub-taskname = px_taskname.
    gt_task_variables_sub-number   = pi_sub_group .
    APPEND gt_task_variables_sub.

*   Aufbereitung dieser Filialgruppe in parallelem Task.
    CALL FUNCTION 'POS_FILIA_SUB_GROUP_PREPARE'
      STARTING NEW TASK px_taskname
      DESTINATION IN GROUP pi_server_group
      PERFORMING return_filia_sub_group_prepare ON END OF TASK
      EXPORTING
        pi_erstdat             = pi_erstdat
        pi_erstzeit            = pi_erstzeit
        pi_datp3               = pi_datp3
        pi_datp4               = pi_datp4
        pi_mode                = pi_mode
        pi_parallel            = pi_parallel
        pi_server_group        = pi_server_group
        px_taskname            = px_taskname
        pi_mestype_wrgp        = pi_mestype_wrgp
        pi_mestype_artstm      = pi_mestype_artstm
        pi_mestype_ean         = pi_mestype_ean
        pi_mestype_set         = pi_mestype_set
        pi_mestype_nart        = pi_mestype_nart
        pi_mestype_steu        = pi_mestype_steu
        pi_mestype_cur         = pi_mestype_cur
        pi_mestype_pers        = pi_mestype_pers
        pi_mestype_prom        = pi_mestype_prom
        pi_pointer_no          = pi_pointer_no
        pi_condint_scanned     = g_condint_scanned
      TABLES
        pit_filia_sub_group    = pit_filia_sub_group
        pit_kondart            = pit_kondart
        pxt_statistik          = t_statistik
        pxt_statistik_wdlsp    = t_statistik_wdlsp
        pit_ot1_f_wrgp         = pit_ot1_f_wrgp
        pit_ot2_wrgp           = pit_ot2_wrgp
        pit_ot1_f_artstm       = pit_ot1_f_artstm
        pit_ot2_artstm         = pit_ot2_artstm
        pit_ot1_f_ean          = pit_ot1_f_ean
        pit_ot2_ean            = pit_ot2_ean
        pit_ot1_f_sets         = pit_ot1_f_sets
        pit_ot2_sets           = pit_ot2_sets
        pit_ot1_f_nart         = pit_ot1_f_nart
        pit_ot2_nart           = pit_ot2_nart
        pit_ot1_k_pers         = pit_ot1_k_pers
        pit_ot2_pers           = pit_ot2_pers
        pit_ot1_f_promreb      = pit_ot1_f_promreb
        pit_ot2_promreb        = pit_ot2_promreb
        pxt_independence_check = pxt_independence_check
        pxt_artdel             = pxt_artdel
        pit_filter_segs        = pit_filter_segs
        pit_mara_buf           = pit_mara_buf
        pit_marm_buf           = pit_marm_buf
        pit_mvke_buf           = pit_mvke_buf
        pit_a071_matnr         = pit_a071_matnr
        pit_old_ean            = pit_old_ean
        pit_old_ean_nart       = pit_old_ean_nart
        pit_old_ean_set        = pit_old_ean_set
        pit_zus_ean_del        = pit_zus_ean_del
        pit_ean_change         = pit_ean_change
        pit_ot3_artstm_buf     = gt_ot3_artstm_buf
        pit_kond_art_buf       = gt_kond_art_buf
        pit_staff_art_buf      = gt_staff_art_buf
        pit_artsteu_buf        = gt_artsteu_buf
      EXCEPTIONS
        communication_failure  = 1
        system_failure         = 2
        resource_failure       = 3.

*   Falls eine Parallelverarbeitung gerade nicht möglich ist, dann
*   dann arbeite sequentiell.
    IF sy-subrc <> 0.
*     Falls Probleme mit dem Zielsystem auftraten.
      IF sy-subrc <> 3.
        CLEAR: pet_rfcdest.

*       Aktualisiere Fehlertabelle für Zielsysteme.
        pet_rfcdest-subrc = sy-subrc.
        CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
          IMPORTING
            rfcdest = pet_rfcdest-rfcdest.

*       Aktualisiere System-Zeitstempel
        COMMIT WORK.

        pet_rfcdest-datum    = sy-datum.
        pet_rfcdest-uzeit    = sy-uzeit.
        pet_rfcdest-no_start = 'X'.
        APPEND pet_rfcdest.
      ENDIF. " sy-subrc <> 3.

*     Serielle Aufbereitung dieser Filialuntergruppe.
      CALL FUNCTION 'POS_FILIA_SUB_GROUP_PREPARE'
        EXPORTING
          pi_erstdat             = pi_erstdat
          pi_erstzeit            = pi_erstzeit
          pi_datp3               = pi_datp3
          pi_datp4               = pi_datp4
          pi_mode                = pi_mode
          pi_parallel            = ' '
          pi_mestype_wrgp        = pi_mestype_wrgp
          pi_mestype_artstm      = pi_mestype_artstm
          pi_mestype_ean         = pi_mestype_ean
          pi_mestype_set         = pi_mestype_set
          pi_mestype_nart        = pi_mestype_nart
          pi_mestype_steu        = pi_mestype_steu
          pi_mestype_cur         = pi_mestype_cur
          pi_mestype_pers        = pi_mestype_pers
          pi_mestype_prom        = pi_mestype_prom
          pi_pointer_no          = pi_pointer_no
        TABLES
          pit_filia_sub_group    = pit_filia_sub_group
          pit_kondart            = pit_kondart
          pxt_statistik          = t_statistik
          pxt_statistik_wdlsp    = t_statistik_wdlsp
          pit_ot1_f_wrgp         = pit_ot1_f_wrgp
          pit_ot2_wrgp           = pit_ot2_wrgp
          pit_ot1_f_artstm       = pit_ot1_f_artstm
          pit_ot2_artstm         = pit_ot2_artstm
          pit_ot1_f_ean          = pit_ot1_f_ean
          pit_ot2_ean            = pit_ot2_ean
          pit_ot1_f_sets         = pit_ot1_f_sets
          pit_ot2_sets           = pit_ot2_sets
          pit_ot1_f_nart         = pit_ot1_f_nart
          pit_ot2_nart           = pit_ot2_nart
          pit_ot1_k_pers         = pit_ot1_k_pers
          pit_ot2_pers           = pit_ot2_pers
          pit_ot1_f_promreb      = pit_ot1_f_promreb
          pit_ot2_promreb        = pit_ot2_promreb
          pxt_independence_check = pxt_independence_check
          pxt_artdel             = pxt_artdel
          pit_filter_segs        = pit_filter_segs.

*     Übernehme Statistikdaten in die Ausgabetabellen.
      LOOP AT t_statistik.
        APPEND t_statistik TO pxt_statistik.
      ENDLOOP. " at t_statistik

      LOOP AT t_statistik_wdlsp.
        APPEND t_statistik_wdlsp TO pxt_statistik_wdlsp.
      ENDLOOP. " at t_statistik_wdlsp

*   Falls eine Parallelverarbeitung möglich ist.
    ELSE. " sy-subrc = 0.

*     Bestimme die verwendetet Destination.
      CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
        IMPORTING
          rfcdest = gt_rfc_indicator_sub-rfcdest.

*     Merken der gestarteten Destination.
      gt_rfc_indicator_sub-taskname = px_taskname.
      APPEND gt_rfc_indicator_sub.

*     Aktualisiere die Anzahl der parallelen Tasks
      ADD 1 TO px_snd_jobs.
    ENDIF. " sy-subrc <> 0.


  ENDIF. " pi_parallel is initial.


ENDFORM. " filia_sub_group_prepare


*eject
************************************************************************
FORM idoc_prepare
     TABLES pit_artdel             STRUCTURE gt_artdel
            pit_ot3_wrgp           STRUCTURE gt_ot3_wrgp
            pit_ot3_artstm         STRUCTURE gt_ot3_artstm
            pit_ot3_ean            STRUCTURE gt_ot3_ean
            pit_ot3_sets           STRUCTURE gt_ot3_sets
            pit_ot3_nart           STRUCTURE gt_ot3_nart
            pit_ot3_pers           STRUCTURE gt_ot3_pers
            pit_filter_segs        STRUCTURE gt_filter_segs
            pit_independence_check STRUCTURE gt_independence_check
            pxt_master_idocs       STRUCTURE gt_master_idocs
            pit_workdays           STRUCTURE gt_workdays
     USING  pi_filia_group         STRUCTURE gt_filia_group
            px_independence_check  STRUCTURE gt_independence_check
            px_stat_counter        STRUCTURE gi_stat_counter
            pi_dldnr               LIKE g_dldnr
            pi_erstdat             LIKE syst-datum
            pi_erstzeit            LIKE syst-uzeit
            pi_datp3               LIKE syst-datum
            pi_datp4               LIKE syst-datum
            pi_mode                LIKE wpstruc-modus
            pi_mestype             LIKE edimsg-mestyp.
************************************************************************
* FUNKTION:
* Fehlerhafte Tasks noch einmal seqeuntiell abarbeiten.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_ARTDEL            : Tabelle für zu löschende Artikel

* PIT_OT3_WRGP          : Warengruppen: Objekttabelle 3.

* PIT_OT3_ARTSTM        : Artikelstamm: Objekttabelle 3.

* PIT_OT3_EAN           : EAN-Referenzen: Objekttabelle 3.

* PIT_OT3_SETS          : Set-Zuordnungen: Objekttabelle 3.

* PIT_OT3_NART          : Nachzugsartikel: Objekttabelle 3.

* PIT_OT3_PERS          : Personendaten: Objekttabelle 3.

* PIT_FILTER_SEGS       : Reduzierinformationen.

* PIT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_MASTER_IDOCS      : Tabelle der kopierfähigen IDOC's

* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.

* PX_INDEPENDENCE_CHECK : Aktueller Satz aus Filialunabhängigkeitstab.

* PX_STAT_COUNTER       : Feldleiste für Statistikinformationen.

* PI_DLDNR              : Downloadnummer

* PI_ERSTDAT            : Datum: jetziges Versenden.

* PI_ERSTZEIT           : Zeit : jetziges Versenden.

* PI_DATP3              : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4              : Datum: letztes Versenden + Vorlaufzeit.

* PI_MODE               : = 'U', wenn Update-Modus, 'R' = Restart-Modus.

* PI_MESTYPE            : Nachzubereitender Nachrichtentyp.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Feldleiste für Statistikinformation.
  DATA: BEGIN OF i_stat_counter.
      INCLUDE STRUCTURE gi_stat_counter.
  DATA: END OF i_stat_counter.


  CASE pi_mestype.
*   Warengruppen.
    WHEN c_mestype_wrgp.
*     IDOC-Aufbereitung der Warengruppen.
      CALL FUNCTION 'POS_WRGP_CHG_MODE_PREPARE'
        EXPORTING
          pi_filia_group         = pi_filia_group
          pi_idoctype            = c_idoctype_wrgp
          pi_mestype             = pi_mestype
          pi_dldnr               = pi_dldnr
          pi_erstdat             = pi_erstdat
          pi_independence_check  = px_independence_check
        IMPORTING
          pe_independence_check  = px_independence_check
          pe_stat_counter        = i_stat_counter
        TABLES
          pit_ot3_wrgp           = pit_ot3_wrgp
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pxt_master_idocs
          pit_independence_check = pit_independence_check.

*     Aktualisiere Statisktikinformation.
      px_stat_counter-wrgp_ign = i_stat_counter-wrgp_ign.

*   Artikelstamm.
    WHEN c_mestype_artstm.
*     Download Artikelstammdaten für Änderungsfall.
      CALL FUNCTION 'POS_ARTSTM_CHG_MODE_PREPARE'
        EXPORTING
          pi_filia_group         = pi_filia_group
          pi_idoctype            = c_idoctype_artstm
          pi_mestype             = pi_mestype
          pi_dldnr               = pi_dldnr
          pi_erstdat             = pi_erstdat
          pi_datp3               = pi_datp3
          pi_datp4               = pi_datp4
          pi_mode                = pi_mode
          pi_independence_check  = px_independence_check
        IMPORTING
          pe_independence_check  = px_independence_check
          pe_stat_counter        = i_stat_counter
        TABLES
          pit_ot3_artstm         = pit_ot3_artstm
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pxt_master_idocs
          pit_independence_check = pit_independence_check.

*     Aktualisiere Statisktikinformation.
      px_stat_counter-artstm_ign = i_stat_counter-artstm_ign.

*   EAN-Referenzen.
    WHEN c_mestype_ean.
*     Download EAN-Referenzen für Änderungsfall.
      CALL FUNCTION 'POS_EAN_CHG_MODE_PREPARE'
        EXPORTING
          pi_filia_group         = pi_filia_group
          pi_idoctype            = c_idoctype_ean
          pi_mestype             = pi_mestype
          pi_dldnr               = pi_dldnr
          pi_erstdat             = pi_erstdat
          pi_datp4               = pi_datp4
          pi_mode                = pi_mode
          pi_independence_check  = px_independence_check
        IMPORTING
          pe_independence_check  = px_independence_check
          pe_stat_counter        = i_stat_counter
        TABLES
          pit_ot3_ean            = pit_ot3_ean
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pxt_master_idocs
          pit_independence_check = pit_independence_check.

*   Aktualisiere Statisktikinformation.
      px_stat_counter-ean_ign = i_stat_counter-ean_ign.

*   Set-Zuordnungen.
    WHEN c_mestype_set.
*     IDOC-Aufbereitung der Set-Zuordnungen.
      CALL FUNCTION 'POS_SETS_CHG_MODE_PREPARE'
        EXPORTING
          pi_filia_group         = pi_filia_group
          pi_idoctype            = c_idoctype_set
          pi_mestype             = pi_mestype
          pi_dldnr               = pi_dldnr
          pi_erstdat             = pi_erstdat
          pi_datp4               = pi_datp4
          pi_mode                = pi_mode
          pi_independence_check  = px_independence_check
        IMPORTING
          pe_independence_check  = px_independence_check
          pe_stat_counter        = i_stat_counter
        TABLES
          pit_ot3_sets           = pit_ot3_sets
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pxt_master_idocs
          pit_independence_check = pit_independence_check.

*     Aktualisiere Statisktikinformation.
      px_stat_counter-sets_ign = i_stat_counter-sets_ign.

*   Nachzugsartikel.
    WHEN c_mestype_nart.
*     IDOC-Aufbereitung der Nachzugsartikel.
      CALL FUNCTION 'POS_NART_CHG_MODE_PREPARE'
        EXPORTING
          pi_filia_group         = pi_filia_group
          pi_idoctype            = c_idoctype_nart
          pi_mestype             = pi_mestype
          pi_dldnr               = pi_dldnr
          pi_erstdat             = pi_erstdat
          pi_datp4               = pi_datp4
          pi_mode                = pi_mode
          pi_independence_check  = px_independence_check
        IMPORTING
          pe_independence_check  = px_independence_check
          pe_stat_counter        = i_stat_counter
        TABLES
          pit_ot3_nart           = pit_ot3_nart
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pxt_master_idocs
          pit_independence_check = pit_independence_check.

*     Aktualisiere Statisktikinformation.
      px_stat_counter-nart_ign = i_stat_counter-nart_ign.

*   Personendaten.
    WHEN c_mestype_pers.
*     IDOC-Aufbereitung der Personendaten.
      CALL FUNCTION 'POS_PERS_CHG_MODE_PREPARE'
        EXPORTING
          pi_filia_group         = pi_filia_group
          pi_idoctype            = c_idoctype_pers
          pi_mestype             = pi_mestype
          pi_dldnr               = pi_dldnr
          pi_erstdat             = pi_erstdat
          pi_mode                = pi_mode
          pi_independence_check  = px_independence_check
        IMPORTING
          pe_independence_check  = px_independence_check
          pe_stat_counter        = i_stat_counter
        TABLES
          pit_ot3_pers           = pit_ot3_pers
          pit_filter_segs        = pit_filter_segs
          pit_workdays           = pit_workdays
          pit_master_idocs       = pxt_master_idocs
          pit_independence_check = pit_independence_check.

*     Aktualisiere Statisktikinformation.
      px_stat_counter-pers_ign = i_stat_counter-pers_ign.

  ENDCASE. " pi_mestype.


ENDFORM. " idoc_prepare


*eject
************************************************************************
FORM status_correction
     TABLES pxt_wdlsp_buf       STRUCTURE gt_wdlsp_buf
            pit_wdlso_parallel  STRUCTURE gt_wdlso_parallel
     USING  px_status_header    STRUCTURE gi_status_header
            pi_dldnr            LIKE g_dldnr.
************************************************************************
* FUNKTION:
* Aktualisiere Status-Kopfzeile und Puffertabelle für WDLSP-Einträge.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_WDLSP_BUF         : Tabelle für erzeugte WDLSP-Einträge.

* PIT_WDLSO_PARALLEL    : Tabelle für fehlerhafte, nachzubereitende
*                         Objekte.
* PX_STATUS_HEADER      : Status-Kopfzeile.

* PI_DLDNR              : Downloadnummer
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: uzeit        LIKE sy-uzeit,
        status       LIKE g_status,
        object       LIKE balhdr-aluser,
        lfdnr        LIKE wdlsp-lfdnr,
        new_protocol.

* Tabelle zur Aufnahme von Statuspositionszeilen.
  DATA: BEGIN OF t_wdlsp OCCURS 0.
      INCLUDE STRUCTURE wdlsp.
  DATA: END OF t_wdlsp.

* Tabelle zur Aufnahme von fehlerhaften Objektschlüsseln.
  DATA: BEGIN OF t_wdlso OCCURS 0.
      INCLUDE STRUCTURE wdlso.
  DATA: END OF t_wdlso.


* Mache alle Datenbankänderungen wirksam.
  COMMIT WORK.

* Merke Zeitstempel.
  uzeit = sy-uzeit.

* Resortiere Status-Positionseinträge.
  SORT pxt_wdlsp_buf BY doctyp lfdnr.
* sort pxt_wdlsp_buf by doctyp docnum.

* Zwischenspeichern der gemerkten Statuspositionszeilen.
  t_wdlsp[] = pxt_wdlsp_buf[].

* Renumeriere und analysiere Status-Positionseinträge.
  CLEAR: lfdnr, g_idoc_counter, g_status, status.
  LOOP AT pxt_wdlsp_buf.
*   Bestimme neue Positionsnummer.
    ADD 1 TO lfdnr.

*   Falls zu dieser Positionszeile ein Protokoll erzeugt wurde
    IF NOT pxt_wdlsp_buf-anloz IS INITIAL.
*     Falls das erzeugte Protokoll auf einen anderen Schlüssel
*     umgespeichert werden muß.
      IF pxt_wdlsp_buf-lfdnr <> lfdnr.
*       Protokoll auf anderen Schlüssel umspeichern.
        PERFORM protocol_restore
                USING  pxt_wdlsp_buf
                       lfdnr.

*       Merke, daß eine Umspeicherung der Protokolldateien
*       stattgefunden hat.
        new_protocol = 'X'.
      ENDIF. " pxt_wdlsp_buf-lfdnr <> lfdnr.
    ENDIF. " not pxt_wdlsp_buf-anloz is initial.

*   Renumerieren.
    pxt_wdlsp_buf-lfdnr = lfdnr.
    MODIFY pxt_wdlsp_buf.

*   Analysieren.

*   Falls zu dieser Status-Positionszeile ein IDOC erzeugt wurde.
    IF NOT pxt_wdlsp_buf-docnum IS INITIAL.
*     Aktualisiere IDOC-Zähler.
      ADD 1 TO g_idoc_counter.
    ENDIF. " not pxt_wdlsp_buf-docnum is initial.

*   Bestimme Gesamt-Aufbereitungsstatus aus Positionseinträgen.
    CASE pxt_wdlsp_buf-gesst.
      WHEN c_status_ok.
        status = 1.
      WHEN c_status_benutzerhinweis.
        status = 2.
      WHEN c_status_fehlende_daten.
        status = 3.
      WHEN c_status_fehlende_idocs.
        status = 4.
    ENDCASE. " pxt_wdlsp_buf-gesst.

    IF g_status < status.
      g_status = status.
    ENDIF. " g_status < status.
  ENDLOOP. " at pxt_wdlsp_buf

* Umspeichern der fehlerhaften, nachzubereitenden Objekte.
* Komprimiere Tabelle für fehlerhafte Objekte.
  SORT pit_wdlso_parallel.
  DELETE ADJACENT DUPLICATES FROM pit_wdlso_parallel
         COMPARING ALL FIELDS.

* Lösche alte Einträge von DB.
  DELETE FROM wdlso
         WHERE dldnr = pi_dldnr.

* Erzeuge neue Einträge für Fehlerobjekt-Tabelle.
  CLEAR: lfdnr.
  LOOP AT t_wdlsp.
*   Bestimme neue Positionsnummer.
    ADD 1 TO lfdnr.

*   Falls zu dieser Positionszeile ein Protokoll erzeugt wurde
    IF NOT t_wdlsp-anloz IS INITIAL.
*     Bestimme, um welchen IDOC-Typen es sich handelt.
      object = t_wdlsp-doctyp(6).

*     Umspeichern der fehlerhaften, nachzubereitenden Objekte.
      REFRESH: t_wdlso.
      LOOP AT pit_wdlso_parallel
           WHERE dldnr       = t_wdlsp-dldnr
           AND   lfdnr       = t_wdlsp-lfdnr
           AND   object_type = object.

        MOVE-CORRESPONDING pit_wdlso_parallel TO t_wdlso.
        t_wdlso-lfdnr = lfdnr.
        APPEND t_wdlso.
      ENDLOOP. " at pit_wdlso_parallel

      IF sy-subrc = 0.
*       Einfügen der neuen Einträge auf DB.
        INSERT wdlso FROM TABLE t_wdlso.
      ENDIF. " sy-subrc = 0.

    ENDIF. " not t_wdlsp-anloz is initial.
  ENDLOOP. " at t_wdlsp.

* Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
  CLEAR: px_status_header.
  px_status_header-dldnr = pi_dldnr.
  px_status_header-anzid = g_idoc_counter.
  px_status_header-eerzt = uzeit.

  CASE g_status.
    WHEN 0.
      px_status_header-gesst = c_status_init.
    WHEN 1.
      px_status_header-gesst = c_status_ok.
    WHEN 2.
      px_status_header-gesst = c_status_benutzerhinweis.
    WHEN 3.
      px_status_header-gesst = c_status_fehlende_daten.
    WHEN 4.
      px_status_header-gesst = c_status_fehlende_idocs.
  ENDCASE. " g_status.

* Schreibe Status-Kopfzeile.
  PERFORM status_write_head USING  'X'  px_status_header  pi_dldnr
                                        g_returncode.

* Lösche alte Status-Positionseinträge von Datenbank.
  DELETE FROM wdlsp WHERE dldnr = pi_dldnr.

* Erzeuge die neuen Status-Positionseinträge.
  MODIFY wdlsp FROM TABLE pxt_wdlsp_buf.

* Mache Datenbankänderung wirksam.
  COMMIT WORK.


ENDFORM. " status_correction


*eject
************************************************************************
FORM protocol_restore
     USING  pi_wdlsp           STRUCTURE gt_wdlsp_buf
            pi_lfdnr           LIKE wdlsp-lfdnr.
************************************************************************
* FUNKTION:
* Umspeichern der erzeugten Protokolls auf einen neuen Schlüssel.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_WDLSO_PARALLEL    : Tabelle für fehlerhafte, nachzubereitende
*                         Objekte.
* PI_WDLSP              : Eintrag in Status-Positionstabelle zu dem
*                         ein Protokoll erzeugt wurde.
* PI_LFDNR              : Neue lfd. Nummer der Status-Positionszeile.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: object          LIKE balhdr-aluser,
        external_number LIKE balhdr-extnumber.

* Tabelle zur Aufnahme von Protokollkopfinformationen.
  DATA: BEGIN OF t_header_data OCCURS 0.
      INCLUDE STRUCTURE balhdr.
  DATA: END OF t_header_data.

* Kopfparameter. Wird hier nicht benötigt, daher nur als Dummy.
  DATA: BEGIN OF t_header_parameters OCCURS 0.
      INCLUDE STRUCTURE balhdrp.
  DATA: END OF t_header_parameters.

* Tabelle zur Aufnahme von Fehlernachrichten.
  DATA: BEGIN OF t_messages OCCURS 0.
      INCLUDE STRUCTURE balm.
  DATA: END OF t_messages.

* Messageparameter. Wird hier nicht benötigt, daher nur als Dummy.
  DATA: BEGIN OF t_message_parameters OCCURS 0.
      INCLUDE STRUCTURE balmp.
  DATA: END OF t_message_parameters.

* Tabelle zur Aufnahme von Protokollkopfinformationen.
  DATA: BEGIN OF t_lognumber OCCURS 0.
      INCLUDE STRUCTURE balno.
  DATA: END OF t_lognumber.

* Wird hier nicht benötigt, daher nur als Dummy.
  DATA: BEGIN OF t_number OCCURS 0.
      INCLUDE STRUCTURE balnri.
  DATA: END OF t_number.


* Bestimme, um welchen IDOC-Typen es sich handelt.
  object = pi_wdlsp-doctyp(6).

* Bestimme Zugriffsschlüssel für Protokoll.
  external_number    = pi_wdlsp-dldnr.
  external_number+14 = pi_wdlsp-lfdnr.

* Lese umzuspeicherndes Protokoll von DB.
  CALL FUNCTION 'APPL_LOG_READ_DB'
    EXPORTING
      object             = c_applikation
      subobject          = c_subobject
      external_number    = external_number
      user_id            = object
    TABLES
      header_data        = t_header_data
      header_parameters  = t_header_parameters
      messages           = t_messages
      message_parameters = t_message_parameters.

* Erzeuge neuen Protokollkopf.
  CLEAR: g_current_doctype, gi_errormsg_header.
  READ TABLE t_header_data INDEX 1.
  MOVE-CORRESPONDING t_header_data TO gi_errormsg_header.
  gi_errormsg_header-extnumber+14 = pi_lfdnr.

* Merken der verwendeten Protokollnummer.
  APPEND t_header_data-lognumber TO t_lognumber.

* Initialisiere Fehlerprotokoll und erzeuge Header.
  PERFORM appl_log_init_with_header  USING gi_errormsg_header.

* Übernehme Fehlernachrichten in das neue Protokoll.
  LOOP AT t_messages.
    CLEAR: gi_message.
    MOVE-CORRESPONDING t_messages TO gi_message.

*   Füge diese Fehlermeldung dem neuen Protokoll hinzu.
    CALL FUNCTION 'APPL_LOG_WRITE_SINGLE_MESSAGE'
      EXPORTING
        object              = c_applikation
        subobject           = c_subobject
        message             = gi_message
        update_or_insert    = c_insert
      EXCEPTIONS
        object_not_found    = 01
        subobject_not_found = 02.

  ENDLOOP. " at t_messages.

* Speichere neues Protokoll ab.
  CALL FUNCTION 'APPL_LOG_WRITE_DB'
    EXPORTING
      object                = c_applikation
      subobject             = c_subobject
    TABLES
      object_with_lognumber = t_number
    EXCEPTIONS
      object_not_found      = 01
      subobject_not_found   = 02.

* Lösche altes Protokoll.
  CALL FUNCTION 'APPL_LOG_DELETE_WITH_LOGNUMBER'
    TABLES
      lognumber = t_lognumber.


ENDFORM. " protocol_restore


*eject
************************************************************************
FORM help_request_modify_for_vtweg
          TABLES   record_tab  STRUCTURE seahlpres
          CHANGING shlp        TYPE shlp_descr_t
                   callcontrol LIKE ddshf4ctrl.
************************************************************************
* FUNKTION:
* Modifizierung der F4-Hilfe für die Auswahl des Vertriebsweges.
* ---------------------------------------------------------------------*
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_index  LIKE sy-tabix,
        h_offset LIKE dfies-offset.

  DATA: i_fieldprop  LIKE ddshfprop,
        i_fielddescr LIKE dfies.

  DATA: BEGIN OF t_interface OCCURS 0.
      INCLUDE STRUCTURE ddshiface.
  DATA: END OF t_interface.


  CLEAR: t_interface.
  READ TABLE shlp-interface INTO t_interface WITH KEY
       shlpfield = 'VKORG'.

* Merken der Tabellenzeile.
  h_index = sy-tabix.

  t_interface-shlpfield = 'VKORG'.
  t_interface-valfield  = 'PA_VKORG'.

  IF sy-subrc <> 0.
    APPEND t_interface TO shlp-interface.
  ELSE. " sy-subrc = 0.
    MODIFY shlp-interface FROM t_interface INDEX h_index.
  ENDIF. " sy-subrc <> 0.

  READ TABLE shlp-interface INTO t_interface WITH KEY
       shlpfield = 'VTWEG'.

* Merken der Tabellenzeile.
  h_index = sy-tabix.

  t_interface-shlpfield = 'VTWEG'.
  t_interface-valfield  = 'PA_VTWEG'.

  IF sy-subrc <> 0.
    APPEND t_interface TO shlp-interface.
  ELSE. " sy-subrc = 0.
    MODIFY shlp-interface FROM t_interface INDEX h_index.
  ENDIF. " sy-subrc <> 0.

* Korrigiere Offset Angaben.
  CLEAR: h_offset.
  LOOP AT shlp-fielddescr INTO i_fielddescr.
    i_fielddescr-offset = h_offset.
    MODIFY shlp-fielddescr FROM i_fielddescr.
    ADD i_fielddescr-intlen TO h_offset.
  ENDLOOP. " at shlp-fielddescr into i_fielddescr.

  i_fieldprop-shlpoutput = 'X'.
  MODIFY shlp-fieldprop FROM i_fieldprop TRANSPORTING shlpoutput
         WHERE fieldname = 'VKORG'.


ENDFORM. " help_request_modify_for_vtweg

*eject
************************************************************************
FORM help_request_modify_for_filia
          TABLES   record_tab  STRUCTURE seahlpres
          CHANGING shlp        TYPE shlp_descr_t
                   callcontrol LIKE ddshf4ctrl.
************************************************************************
* FUNKTION:
* Modifizierung der F4-Hilfe für die Auswahl der Filiale.
* ---------------------------------------------------------------------*
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_index  LIKE sy-tabix,
        h_offset LIKE dfies-offset.

  DATA: i_fieldprop  LIKE ddshfprop,
        i_fielddescr LIKE dfies.

  DATA: BEGIN OF t_interface OCCURS 0.
      INCLUDE STRUCTURE ddshiface.
  DATA: END OF t_interface.


  CLEAR: t_interface.
  READ TABLE shlp-interface INTO t_interface WITH KEY
       shlpfield = 'VKORG'.

* Merken der Tabellenzeile.
  h_index = sy-tabix.

  t_interface-shlpfield = 'VKORG'.
  t_interface-valfield  = 'PA_VKORG'.

  IF sy-subrc <> 0.
    APPEND t_interface TO shlp-interface.
  ELSE. " sy-subrc = 0.
    MODIFY shlp-interface FROM t_interface INDEX h_index.
  ENDIF. " sy-subrc <> 0.

  READ TABLE shlp-interface INTO t_interface WITH KEY
       shlpfield = 'VTWEG'.

* Merken der Tabellenzeile.
  h_index = sy-tabix.

  t_interface-shlpfield = 'VTWEG'.
  t_interface-valfield  = 'PA_VTWEG'.

  IF sy-subrc <> 0.
    APPEND t_interface TO shlp-interface.
  ELSE. " sy-subrc = 0.
    MODIFY shlp-interface FROM t_interface INDEX h_index.
  ENDIF. " sy-subrc <> 0.

  READ TABLE shlp-interface INTO t_interface WITH KEY
       shlpfield = 'FILIA'.

* Merken der Tabellenzeile.
  h_index = sy-tabix.

  t_interface-shlpfield  = 'FILIA'.
  t_interface-valfield   = g_filia_pname.

  IF sy-subrc <> 0.
    APPEND t_interface TO shlp-interface.
  ELSE. " sy-subrc = 0.
    MODIFY shlp-interface FROM t_interface INDEX h_index.
  ENDIF. " sy-subrc <> 0.

* Korrigiere Offset Angaben.
  CLEAR: h_offset.
  LOOP AT shlp-fielddescr INTO i_fielddescr.
    i_fielddescr-offset = h_offset.
    MODIFY shlp-fielddescr FROM i_fielddescr.
    ADD i_fielddescr-intlen TO h_offset.
  ENDLOOP. " at shlp-fielddescr into i_fielddescr.

  i_fieldprop-shlpoutput = 'X'.
  MODIFY shlp-fieldprop FROM i_fieldprop TRANSPORTING shlpoutput
         WHERE fieldname = 'VKORG'.

  MODIFY shlp-fieldprop FROM i_fieldprop TRANSPORTING shlpoutput
         WHERE fieldname = 'VTWEG'.

ENDFORM. " help_request_modify_for_filia


*eject
************************************************************************
FORM help_request_modify_for_field
          TABLES   record_tab  STRUCTURE seahlpres
          CHANGING shlp        TYPE shlp_descr_t
                   callcontrol LIKE ddshf4ctrl.
************************************************************************
* FUNKTION:
* Modifizierung der F4-Hilfe für die Auswahl des Tabellenfeldnamens.
* ---------------------------------------------------------------------*
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: h_index  LIKE sy-tabix,
        h_offset LIKE dfies-offset.

  DATA: i_fieldprop  LIKE ddshfprop,
        i_fielddescr LIKE dfies.

  DATA: BEGIN OF t_interface OCCURS 0.
      INCLUDE STRUCTURE ddshiface.
  DATA: END OF t_interface.


  CLEAR: t_interface.
  READ TABLE shlp-interface INTO t_interface WITH KEY
       shlpfield = 'TABNAME'.

* Merken der Tabellenzeile.
  h_index = sy-tabix.

  t_interface-shlpfield = 'TABNAME'.
  t_interface-valfield  = 'PA_SEGNA'.
  IF sy-subrc <> 0.
    APPEND t_interface TO shlp-interface.
  ELSE. " sy-subrc = 0.
    MODIFY shlp-interface FROM t_interface INDEX h_index.
  ENDIF. " sy-subrc <> 0.

  READ TABLE shlp-interface INTO t_interface WITH KEY
       shlpfield = 'FIELDNAME'.

* Merken der Tabellenzeile.
  h_index = sy-tabix.

  t_interface-shlpfield = 'FIELDNAME'.
  t_interface-valfield  = 'PA_FELD'.

  IF sy-subrc <> 0.
    APPEND t_interface TO shlp-interface.
  ELSE. " sy-subrc = 0.
    MODIFY shlp-interface FROM t_interface INDEX h_index.
  ENDIF. " sy-subrc <> 0.

* Korrigiere Offset Angaben.
  CLEAR: h_offset.
  LOOP AT shlp-fielddescr INTO i_fielddescr.
    i_fielddescr-offset = h_offset.
    MODIFY shlp-fielddescr FROM i_fielddescr.
    ADD i_fielddescr-intlen TO h_offset.
  ENDLOOP. " at shlp-fielddescr into i_fielddescr.

  i_fieldprop-shlpoutput = 'X'.
  MODIFY shlp-fieldprop FROM i_fieldprop TRANSPORTING shlpoutput
         WHERE fieldname = 'TABNAME'.


ENDFORM. " help_request_modify_for_field


*eject
************************************************************************
FORM gt_listung_fill
     TABLES pit_marm        STRUCTURE gt_marm_buf
            pet_listung     STRUCTURE gt_listung
     USING  pi_wlk2         STRUCTURE gt_wlk2.
************************************************************************
* Erzeugt eine gefüllte Listungstabelle für diesen Artikel.
* ----------------------------------------------------------------------
* PARAMETER:
* PIT_MARM   : Tabelle mit MARM-Daten des Artikels.

* PET_LISTUNG: Ergebnistabelle.

* PI_wlk2    : WLK2-Daten des Artikels.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

  REFRESH: gt_listung.
  LOOP AT pit_marm.
    CLEAR: gt_listung.
    gt_listung-artnr = pit_marm-matnr.
    gt_listung-vrkme = pit_marm-meinh.
    gt_listung-datbi = pi_wlk2-vkbis.
    gt_listung-datab = pi_wlk2-vkdab.
    APPEND gt_listung.
  ENDLOOP. " at pit_marm.


ENDFORM. " gt_listung_fill


*eject.
************************************************************************
FORM promotion_store_check
     TABLES pxt_periods  STRUCTURE wcondint
     USING  pi_filia     LIKE      t001w-werks.
************************************************************************
* FUNKTION:
* Falls eines der ermittelten Konditionsintervalle eine
* Aktionskondition auf Filialgruppenebene enthält, dann prüfe,
* ob die gerade bearbeitete Filiale davon überhaupt betroffen ist.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_PERIODS           : Ermittelte Konditionsintervalle.
*
* PI_FILIA              : Aktuelle Filiale
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Struktur zum zwischenspeichern von Filialdaten
  DATA: BEGIN OF i_t001w.
      INCLUDE STRUCTURE t001w.
  DATA: END OF i_t001w.

* Tabelle zum zwischenspeichern von Filialen einer Aktion
  DATA: BEGIN OF t_bapi1068t6  OCCURS 0.
      INCLUDE STRUCTURE bapi1068t6.
  DATA: END OF t_bapi1068t6.


  LOOP AT pxt_periods
       WHERE vkorg <> space
       AND   aktnr <> space
       AND   werks IS INITIAL.

*   Besorge die Kundennummer der Filiale.
    CALL FUNCTION 'T001W_SINGLE_READ'
      EXPORTING
        t001w_werks = pi_filia
      IMPORTING
        wt001w      = i_t001w
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.

    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*   Besorge die der Aktion zugeortneten Filialen
    REFRESH: t_bapi1068t6.
    CALL FUNCTION 'PROMOTION_STORES_FIND'
      EXPORTING
        pi_aktnr                = pxt_periods-aktnr
        pi_artnr                = pxt_periods-matnr
        pi_vkme                 = pxt_periods-vrkme
        pi_datum                = pxt_periods-datab
        pi_vkorg                = pxt_periods-vkorg
        pi_vtweg                = pxt_periods-vtweg
        pi_buffer_stores        = ' '
      TABLES
        pet_filialen            = t_bapi1068t6
      EXCEPTIONS
        promotion_not_found     = 1
        no_store_group_assigned = 2
        no_store_found          = 3.

*   Daten sortieren.
    SORT t_bapi1068t6 BY plant_customer.

*   Falls nur bestimmte Filialen dieser Vertriebslinie der Aktion
*   zugeordnet sind.
    IF sy-subrc = 0.
*     Prüfe, ob die aktuelle Filiale betroffen ist.
      READ TABLE t_bapi1068t6 WITH KEY
           plant_customer = i_t001w-kunnr
           BINARY SEARCH.

*     Falls die aktuelle Filiale betroffen ist.
      IF sy-subrc = 0.
*       Filiale ist relevant. ==> weiter zum nächsten Satz.
        CONTINUE.
*     Die aktuelle Filiale ist nicht für diese Aktion relevant.
      ELSE. " sy-subrc <> 0.
        DELETE pxt_periods.
        CONTINUE.
      ENDIF. " sy-subrc = 0.

*   Falls die Filialgruppe aus allen Filialen der Vertriebslinie
*   besteht.
    ELSEIF sy-subrc = 2.
*     Filiale ist relevant. ==> weiter zum nächsten Satz.
      CONTINUE.

*   Falls die Aktion oder die Filiale nicht gefunden wurde.
    ELSEIF sy-subrc = 1 OR sy-subrc = 3.
*     Die aktuelle Filiale ist nicht für diese Aktion relevant.
      DELETE pxt_periods.
      CONTINUE.
    ENDIF. " sy-subrc = 2.

  ENDLOOP. " at pxt_periods


ENDFORM. " promotion_store_check


*eject.
************************************************************************
FORM promotion_store_check_2
     USING  pi_periods  STRUCTURE gt_condint
            pi_kunnr    LIKE      t001w-kunnr
            pe_relevant LIKE      wpstruc-modus.
************************************************************************
* FUNKTION:
* Falls das ermittelte Konditionsintervall eine
* Aktionskondition auf Filialgruppenebene enthält, dann prüfe,
* ob die gerade bearbeitete Filiale davon überhaupt betroffen ist.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_PERIODS            : Ermitteltes Konditionsintervall.
*
* PI_KUNNR              : Kundennummer der aktuelle Filiale
*
* PE_RELEVANT           : = 'X', wenn das ermittelte Konditionsintervall
*                                für diese Filiale relevant ist, sonst
*                                SPACE.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum zwischenspeichern von Filialen einer Aktion
  DATA: BEGIN OF t_bapi1068t6  OCCURS 0.
      INCLUDE STRUCTURE bapi1068t6.
  DATA: END OF t_bapi1068t6.

* Initialisiere Rückgabeflag.
  pe_relevant = 'X'.

  IF pi_periods-vkorg <> space      AND
     pi_periods-aktnr <> space      AND
     pi_periods-werks IS INITIAL.

*   Besorge die der Aktion zugeortneten Filialen
    REFRESH: t_bapi1068t6.
    CALL FUNCTION 'PROMOTION_STORES_FIND'
      EXPORTING
        pi_aktnr                = pi_periods-aktnr
        pi_artnr                = pi_periods-matnr
        pi_vkme                 = pi_periods-vrkme
        pi_datum                = pi_periods-datab
        pi_vkorg                = pi_periods-vkorg
        pi_vtweg                = pi_periods-vtweg
        pi_buffer_stores        = ' '
      TABLES
        pet_filialen            = t_bapi1068t6
      EXCEPTIONS
        promotion_not_found     = 1
        no_store_group_assigned = 2
        no_store_found          = 3.

*   Daten sortieren.
    SORT t_bapi1068t6 BY plant_customer.

*   Falls nur bestimmte Filialen dieser Vertriebslinie der Aktion
*   zugeordnet sind.
    IF sy-subrc = 0.
*     Prüfe, ob die aktuelle Filiale betroffen ist.
      READ TABLE t_bapi1068t6 WITH KEY
           plant_customer = pi_kunnr
           BINARY SEARCH.


*     Die aktuelle Filiale ist nicht für diese Aktion relevant.
      IF sy-subrc <> 0.
        CLEAR: pe_relevant.
      ENDIF. " sy-subrc <> 0.

*   Falls die Aktion oder die Filiale nicht gefunden wurde.
    ELSEIF sy-subrc = 1 OR sy-subrc = 3.
*     Die aktuelle Filiale ist nicht für diese Aktion relevant.
      CLEAR: pe_relevant.
    ENDIF. " sy-subrc = 0.

  ENDIF. " pi_periods-vkorg <> space      and ...



ENDFORM. " promotion_store_check_2



*eject
************************************************************************
FORM kunnr_by_pltyp_get
     TABLES pet_short_wrf6  STRUCTURE wpos_short_wrf6
     USING  pi_pltyp        LIKE      wrf6-pltyp_p.
************************************************************************
* Liefert alle Kundennummern der an einem Preislistentyp beteiligten
* Filialen. Mit interner Pufferung.
*-----------------------------------------------------------------------
* PARAMETER:
*
* PET_SHORT_WRF6 : Gelesene Kundennummer der betroffenen Filialen.

* PI_PLTYP       : Zu untersuchender Preislistentyp.
*
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: c_max_short_wrf6_buf LIKE sy-tabix VALUE 3000.

  DATA: h_lines LIKE sy-dbcnt,
        h_tabix LIKE sy-tabix.

* Tabellen für Pufferung von verkürzten WRF6-Daten und
* für Ausgabepufferung von verkürzten WRF6-Daten.
  STATICS: lt_short_wrf6_buf LIKE wpos_short_wrf6 OCCURS 0
                                                WITH HEADER LINE,
           lt_short_wrf6_out LIKE wpos_short_wrf6 OCCURS 0
                                                WITH HEADER LINE.


* Rücksetze Ausgabetabelle.
  REFRESH: pet_short_wrf6.
  CLEAR:   pet_short_wrf6.

* Prüfe, ob der Puffer zurückgesetzt werden muß.
  DESCRIBE TABLE lt_short_wrf6_buf LINES h_lines.

* Falls der Puffer zurückgesetzt werden muß.
  IF h_lines > c_max_short_wrf6_buf.
*   Rücksetze Puffer.
    REFRESH: lt_short_wrf6_buf.
    CLEAR:   lt_short_wrf6_buf, h_lines.
  ENDIF. " h_lines > c_max_short_wrf6_buf.


* Prüfe, ob die gesuchten Daten bereits im Ausgabepuffer sind.
  CLEAR: lt_short_wrf6_out.
  READ TABLE lt_short_wrf6_out INDEX 1.

* Falls die gesuchten Daten bereits im Ausgabepuffer sind.
  IF lt_short_wrf6_out-pltyp = pi_pltyp.
*   Übernehme Ausgabepuffer in Ausgabetabelle.
    pet_short_wrf6[] = lt_short_wrf6_out[].

    EXIT.

* Falls die gesuchten Daten nicht im Ausgabepuffer sind.
  ELSE. " lt_short_wrf6_out-pltyp <> pi_pltyp.
*   Prüfe, ob die gesuchten Daten bereits im Puffer sind.
    READ TABLE lt_short_wrf6_buf WITH KEY
         pltyp = pi_pltyp
         BINARY SEARCH
         TRANSPORTING NO FIELDS.

    h_tabix = sy-tabix.

*   Falls die gesuchten Daten bereits im Puffer sind.
    IF sy-subrc = 0.
*     Übernehme die im Puffer befindlichen Werte in Ausgabepuffer.
      REFRESH: lt_short_wrf6_out.
      CLEAR:   lt_short_wrf6_out.

      LOOP AT lt_short_wrf6_buf FROM h_tabix.
*       Setze Abbruchbedingung.
        IF lt_short_wrf6_buf-pltyp <> pi_pltyp.
          EXIT.
        ENDIF.

        APPEND lt_short_wrf6_buf TO lt_short_wrf6_out.

      ENDLOOP. " at lt_short_wrf6_buf from h_tabix.

*     Übernehme Ausgabepuffer in Ausgabetabelle.
      pet_short_wrf6[] = lt_short_wrf6_out[].

*   Falls die Daten noch nicht im Puffer sind.
    ELSE. " sy-subrc <> 0.
*     Lese die WRF6-Daten von DB.
      SELECT * FROM wrf6
             INTO CORRESPONDING FIELDS OF TABLE lt_short_wrf6_out
             WHERE pltyp_p = pi_pltyp.

*     Daten sortieren
      SORT lt_short_wrf6_out BY locnr.

*     Daten komprimieren
      DELETE ADJACENT DUPLICATES FROM lt_short_wrf6_out
             COMPARING locnr.

*     Übernehme Ausgabepuffer in Ausgabetabelle.
      pet_short_wrf6[] = lt_short_wrf6_out[].

*     Einsortieren der Daten in den Puffertabelle.
      LOOP AT lt_short_wrf6_out.

        lt_short_wrf6_buf = lt_short_wrf6_out.
        INSERT lt_short_wrf6_buf INDEX h_tabix.
        ADD 1 TO h_tabix.

      ENDLOOP. " at lt_short_wrf6_out.


    ENDIF. " sy-subrc = 0.
  ENDIF. " lt_short_wrf6_out-pltyp = pi_pltyp.


ENDFORM.                               " kunnr_by_pltyp_get

*{   INSERT         XB4K001679                                        1
*WRF_POSOUT
*&---------------------------------------------------------------------*
*&      Form  call_badi_matgrp_analyse_pointer
*&---------------------------------------------------------------------*
* FUNKTION:
* Analysiere alle Änderungspointer in Tabelle PIT_POINTER und
* fülle die Objekttabellen PET_OT1_F_ARTSTM (filialabhängig)
* und PET_OT2_ARTSTM.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_POINTER       : Tabelle der zu analysierenden Änderungspointer.

* PIT_FILIA_GROUP   : Tabelle für Filialkonstanten der Gruppe.

* PET_OT1_F_ARTSTM  : Artikelstamm: Objekttabelle 1, filialabhängig.

* PET_OT2_ARTSTM    : Artikelstamm: Objekttabelle 2, filialunabhängig.

* PI_ERSTDAT        : Datum: jetziges Versenden.

* PI_DATP3          : Datum: letztes  Versenden + Vorlaufzeit.

* PI_DATP4          : Datum: jetziges Versenden + Vorlaufzeit.
*----------------------------------------------------------------------*
FORM call_badi_mtgp_analyse_pointer
     TABLES pit_pointer        STRUCTURE bdcp
            pit_filia_group    STRUCTURE wpfiliagrp
            pxt_ot1_f_artstm   STRUCTURE gt_ot1_f_artstm
            pxt_ot2_artstm     STRUCTURE gt_ot2_artstm
     USING  pi_erstdat         LIKE syst-datum
            pi_datp3           LIKE syst-datum
            pi_datp4           LIKE syst-datum.

* Besorge Badi-Instanz.
  PERFORM get_badi_instance.

* Aufruf des BADIs zur Übernahme der Artikelhierarchiedaten
  IF NOT g_badi_active_imp IS INITIAL.

    CALL METHOD g_badi_instance->matgrp_analyse_pointer
      EXPORTING
        i_datp3        = pi_datp3
        i_datp4        = pi_datp4
        i_erstdat      = pi_erstdat
        it_filia_group = pit_filia_group[]
        it_pointer     = pit_pointer[]
      CHANGING
        xt_ot2_artstm  = pxt_ot2_artstm[].

  ENDIF.

ENDFORM.                    " call_badi_matgrp_analyse_pointer
*WRF_POSOUT
*}   INSERT

*{   INSERT         XB4K001679                                        2
*WRF_POSOUT
*&---------------------------------------------------------------------*
*&      Form  call_badi_idoc_artstm_append
*&---------------------------------------------------------------------*
*       neue Idoc-Segmente füllen
*----------------------------------------------------------------------*
*      -->PIT_IDOC_DATA_TEMP aktueller Datensatz des IDOC's
*      -->PI_E1WPA01         ID-Segment von WP_PLU
*      -->PE_SUBRC           Returncode
*      -->PE_MESSAGE         Nachrichtenzeile des Fehlerprotokolls.
*----------------------------------------------------------------------*
FORM call_badi_idoc_artstm_append
          TABLES pxt_idoc_data_temp STRUCTURE gt_idoc_data_temp
          USING  pi_e1wpa01         STRUCTURE e1wpa01
                 pe_subrc           LIKE      sy-subrc
                 pe_message         STRUCTURE balmi
                 pi_mestype_plu     TYPE      mestype_plu.

* Besorge Badi-Instanz.
  PERFORM get_badi_instance.

  IF NOT g_badi_active_imp IS INITIAL.

    CALL METHOD g_badi_instance->idoc_dataset_artstm_append
      EXPORTING
        is_e1wpa01             = pi_e1wpa01
        i_mestype_plu          = pi_mestype_plu
      IMPORTING
        es_message             = pe_message
      CHANGING
        xt_idoc_data_temp      = pxt_idoc_data_temp[]
      EXCEPTIONS
        matgrp_struc_not_found = 1
        OTHERS                 = 2.
    IF sy-subrc <> 0.
      pe_subrc = sy-subrc.
    ENDIF.

  ENDIF.

ENDFORM.                    " call_badi_idoc_artstm_append

*&---------------------------------------------------------------------*
*&      Form  call_badi_orgtab_modify
*&---------------------------------------------------------------------*
*       Berücksichtige Versendezeitpunkte für die Versendung von
*       Artikelhierarchie-Zuordnungen.
*----------------------------------------------------------------------*
*      -->PXT_ORGTAB         ORGTAB: Zeitlicher Verlauf der Änd. eines
*                                    Materials
*      -->PI_MATNR           Materialnummer
*      -->PI_VKORG           Verkaufsorganisation
*      -->PI_VTWEG           Vertriebsweg
*----------------------------------------------------------------------*
FORM call_badi_orgtab_modify
          TABLES pxt_orgtab         STRUCTURE gt_orgtab_artstm
          USING  pi_matnr           TYPE      matnr
                 pi_vkorg           TYPE      vkorg
                 pi_vtweg           TYPE      vtweg
                 pi_mestype_plu     TYPE      mestype_plu.

* Besorge Badi-Instanz.
  PERFORM get_badi_instance.

  IF NOT g_badi_active_imp IS INITIAL.
    CALL METHOD g_badi_instance->modify_orgtab_for_downld
      EXPORTING
        i_matnr       = pi_matnr
        i_vkorg       = pi_vkorg
        i_vtweg       = pi_vtweg
        i_mestype_plu = pi_mestype_plu
      CHANGING
        xt_orgtab     = pxt_orgtab[].

  ENDIF.

ENDFORM.                    " call_badi_orgtab_modify


*WRF_POSOUT
*&---------------------------------------------------------------------*
*&      Form  get_badi_instance
*&---------------------------------------------------------------------*
*       Badi Instanz besorgen, falls noch nicht geschehen
*----------------------------------------------------------------------*
FORM get_badi_instance.

* Initialisierung der Instanz
  IF g_badi_instance IS INITIAL.
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name        = 'WPOS_X_POSOUT001_I'
      IMPORTING
        act_imp_existing = g_badi_active_imp
      CHANGING
        instance         = g_badi_instance.
  ENDIF.
* WRF_POSOUT


ENDFORM. " get_badi_instance
*WRF_POSOUT
*}   INSERT

*{   INSERT         XB4K001679                                        3
*&---------------------------------------------------------------------*
*&      Form  call_badi_idoc_promreb_append
*&---------------------------------------------------------------------*
*       Übergabe neuer Aktionsrabatt-Felder in IDOC-Segment
*----------------------------------------------------------------------*
*      -->P_PIT_WAKR   Aktionsrabattposition
*      <--P_E1WPREB02  Positionssegment
*----------------------------------------------------------------------*
FORM call_badi_idoc_promreb_append  USING    is_wakr
                                    CHANGING xs_e1wpreb02.

  PERFORM get_badi_instance.

  IF NOT g_badi_active_imp IS INITIAL.

    CALL METHOD g_badi_instance->idoc_promreb_append
      EXPORTING
        is_wakr      = is_wakr
      CHANGING
        xs_e1wpreb02 = xs_e1wpreb02.
  ENDIF.

ENDFORM.                    " call_badi_idoc_promreb_append

*}   INSERT
*&---------------------------------------------------------------------*
*&      Form  wrsz_article_get
*&---------------------------------------------------------------------*
*       Aufruf des BAdIs zum WRSZ-Intervallscan und Abmischen mit
*       bereits vorhandenen Artikeln
*----------------------------------------------------------------------*
*      -->P_PI_FILIA_GROUP   Filial-/Sortimentsdaten
*      -->P_PI_DATP3         Zeitstempel Start
*      -->P_PI_DATP4         Zeitstempel Stop
*      <--P_PIT_OT1_F_ARTSTM Artikeltab. 1
*      <--P_PIT_OT1_F_EAN    Artikeltab. 2
*      <--P_PIT_OT1_F_SETS   Artikeltab. 3
*      <--P_PIT_OT1_F_NART   Artikeltab. 4
*----------------------------------------------------------------------*
FORM wrsz_article_get
  USING  pi_filia_group     STRUCTURE gt_filia_group
         pi_datp3           LIKE      sy-datum
         pi_datp4           LIKE      sy-datum
  CHANGING pit_ot1_f_artstm TYPE      tt_wpartstm
           pit_ot1_f_ean    TYPE      tt_wpartstm
           pit_ot1_f_sets   TYPE      tt_wpartstm
           pit_ot1_f_nart   TYPE      tt_wpartstm.

  DATA: lt_articles TYPE tt_wpartstm.

* Allgemeine Retail-Einstallungen aus der Tabelle TWPA lesen
  SELECT SINGLE * FROM twpa INTO gs_twpa.

* Weitermachen macht nur Sinn, wenn ein Datensatz vorhanden ist und das
* Flag 'Zeitabhängigkeit verwenden' gesetzt ist
  IF ( sy-subrc EQ 0 ) AND ( gs_twpa-timedep EQ 'X' ).

*   Falls keine BAdI-Instanz existiert -> erzeugen
    IF gv_wpos_timedep_wrsz IS INITIAL.
      CALL METHOD cl_exithandler=>get_instance
        EXPORTING
          exit_name                     = 'WPOS_TIMEDEP_WRSZ_I'
          null_instance_accepted        = 'X'
        CHANGING
          instance                      = gv_wpos_timedep_wrsz
        EXCEPTIONS
          no_reference                  = 1
          no_interface_reference        = 2
          no_exit_interface             = 3
          class_not_implement_interface = 4
          single_exit_multiply_active   = 5
          cast_error                    = 6
          exit_not_existing             = 7
          data_incons_in_exit_managem   = 8
          OTHERS                        = 9.
      IF sy-subrc <> 0.
        CLEAR gv_wpos_timedep_wrsz.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

*   BAdI-Instanz vorhanden? -> Badi aufrufen
    IF NOT gv_wpos_timedep_wrsz IS INITIAL.
      CALL METHOD gv_wpos_timedep_wrsz->scan_timedep_wrsz
        EXPORTING
          is_filia_group  = pi_filia_group
          iv_datp3        = pi_datp3
          iv_datp4        = pi_datp4
        CHANGING
          xt_ot1_f_artstm = pit_ot1_f_artstm[]
          xt_ot1_f_ean    = pit_ot1_f_ean[]
          xt_ot1_f_sets   = pit_ot1_f_sets[]
          xt_ot1_f_nart   = pit_ot1_f_nart[].
    ENDIF.

  ENDIF.

ENDFORM.                    " wrsz_article_get

************************************************************************
FORM listed_articles_get_2
     TABLES pxt_wlk2 STRUCTURE gt_wlk2
     USING  pi_vkorg LIKE wpstruc-vkorg
            pi_vtweg LIKE wpstruc-vtweg
            pi_filia LIKE t001w-werks
            pi_datab LIKE syst-datum
            pi_datbi LIKE syst-datum.
************************************************************************
* This forms reads all listed articles of the store
* PI_FILIA.
* ---------------------------------------------------------------------*
* PARAMETERS:
* PXT_WLK2: List of selected articles.

* PI_VKORG: Sales organisationn.

* PI_VTWEG: Distribution channel.

* PI_FILIA: Store.

* PI_DATAB: Begin date.

* PI_DATBI: End date.
* ----------------------------------------------------------------------
* AUTORS(EN):
* Stefan Edelmann (SAP AG), Sven Wolfanger (SAP AG)
************************************************************************

  DATA: lv_package_size TYPE i.
  DATA: lv_deact_mara_buffer_refresh TYPE abap_bool VALUE abap_false.

* Prüfe, ob Artikel innerhalb des Betrachtungszeitraums
* von dieser Filiale bewirtschaftet werden.
  READ TABLE pxt_wlk2 INDEX 1.
* Falls interne Listungstabelle nicht gefüllt ist, dann
* besorge die entsprechenden Bewirtschaftungszeiträume von DB.
  IF sy-subrc <> 0 OR pxt_wlk2-werks <> pi_filia.
*  B: New listing check logic => Note 1982796
    IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
      AND gs_twpa-marc_chk IS NOT INITIAL.
*   New Lsiting logic: read WLK2 and check MARC if enries exists
      CALL FUNCTION 'POS_READ_WLK2_CHECK_MARC'
        EXPORTING
          ip_access_type = '1'   " WLK2 access with store
          ip_vkorg       = pi_vkorg
          ip_vtweg       = pi_vtweg
          ip_filia       = pi_filia
          ip_date_from   = pi_datab
          ip_date_to     = pi_datbi
          is_filia_const = gi_filia_const
        TABLES
          pet_wlk2       = pxt_wlk2.
    ELSE.
      CALL FUNCTION 'WLK2_MATERIAL_FOR_FILIA'
        EXPORTING
          pi_datab        = pi_datab
          pi_datbi        = pi_datbi
          pi_vkorg        = pi_vkorg
          pi_vtweg        = pi_vtweg
          pi_filia        = pi_filia
        TABLES
          wlk2_input      = pxt_wlk2
        EXCEPTIONS
          werks_not_found = 01
          no_wlk2         = 02
          no_wlk2_listing = 03.

*   Löschen nicht mehr benötigter globaler interner Tabellen
      CALL FUNCTION 'WLK2_REFRESH_INTERNAL_BUFFERS'.
    ENDIF. " Note 1982796
    READ TABLE pxt_wlk2 INDEX 1.

*   Wenn Daten gefunden wurden.
    IF sy-subrc = 0.
*--- optimization for MARA: control refreshment of MARA buffer
      PERFORM get_package_size CHANGING lv_package_size.

      IF lv_package_size > lines( pxt_wlk2 ).
        lv_deact_mara_buffer_refresh = abap_true.
      ELSE.
        lv_deact_mara_buffer_refresh = abap_false.
      ENDIF.

*--- only delete MARA buffer if the number of listed articles is
*--- greater than or is equal to (>=) the package size
      IF lv_deact_mara_buffer_refresh = abap_false.
*     Lösche internen MARA-Buffer.
        CALL FUNCTION 'MARA_ARRAY_READ'
          EXPORTING
            kzrfb                = 'X'
          EXCEPTIONS
            enqueue_mode_changed = 1
            OTHERS               = 2.
      ENDIF.
    ENDIF. " sy-subrc = 0.
  ENDIF.   " sy-subrc <> 0 or pxt_wlk2-filia <> pi_filia.

ENDFORM. " listed_articles_get_2

*&---------------------------------------------------------------------*
*&      Form  reset_article_buffers
*&---------------------------------------------------------------------*
* This form resets the internal buffer for article
* related database tables:
* MARA, MARM, MVKE, MEAN, MAMT, MAKT, MARC, MLAN
*----------------------------------------------------------------------*
*      --> pi_disable_reset
*      <--none
*  if the parameter pi_disable_reset is set to true then the store
*  independent buffers are not reset. It is assumed that this flag
*  is set to true very carefully (for instance if you know that the
*  articles in the stores are very similar).
*----------------------------------------------------------------------*
FORM reset_article_buffers USING pi_disable_reset TYPE abap_bool.

  IF pi_disable_reset = abap_false.
*     Lösche internen MARA-Buffer.
    CALL FUNCTION 'MARA_ARRAY_READ'
      EXPORTING
        kzrfb                = abap_true
      EXCEPTIONS
        enqueue_mode_changed = 1
        OTHERS               = 2.

*--- deletion of internal MARM-buffer:
    CALL FUNCTION 'MARM_ARRAY_READ_MATNR_ALL'
      EXPORTING
        kzrfb = abap_true.

*--- deletion of internal MVKE-buffer:
    CALL FUNCTION 'MVKE_ARRAY_READ'
      EXPORTING
        kzrfb                = abap_true
      EXCEPTIONS
        enqueue_mode_changed = 1
        OTHERS               = 2.

*--- deletion of internal MEAN-buffer:
    CALL FUNCTION 'MEAN_ARRAY_READ_MATNR_ALL'
      EXPORTING
        kzrfb = abap_true.

*--- deletion of internal MAMT-buffer:
    CALL FUNCTION 'MAMT_ARRAY_READ_MATNR_ALL'
      EXPORTING
        kzrfb                = abap_true
      EXCEPTIONS
        enqueue_mode_changed = 1
        OTHERS               = 2.

*--- deletion of internal MAKT-buffer:
    CALL FUNCTION 'MAKT_ARRAY_READ'
      EXPORTING
        kzrfb                = abap_true
      EXCEPTIONS
        enqueue_mode_changed = 1
        OTHERS               = 2.

    "under certain circumstances (store change with country change),
    "a reset of the MLAN buffer is needed altough disable_reset = true.
    "this is handled below in prefetch_article_data.
*--- deletion of internal MLAN-buffer:
    CALL FUNCTION 'MATERIAL_PRE_READ_MLAN'
      EXPORTING
        kzrfb = abap_true.
  ENDIF.

*--- deletion of internal MARC-buffer:
  CALL FUNCTION 'MARC_ARRAY_READ'
    EXPORTING
      kzrfb                = abap_true
    EXCEPTIONS
      enqueue_mode_changed = 1
      lock_on_marc         = 2
      lock_system_error    = 3
      OTHERS               = 4.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  prefetch_article_data
*&---------------------------------------------------------------------*
* This form prefetches article related data from the database tables:
* MARA, MARM, MVKE, MEAN, MAMT, MAKT, MARC, MLAN
* Consider that the prefetch on MARA is triggered via parameter. There
* are situations in which it is not necessary to do this prefetch
* because the buffer is already filled.
* This behavior is not true for the other tables.
*----------------------------------------------------------------------*
*      -->pi_filia Store
*      -->pi_do_pref_mara
*      -->pi_do_pref_marc_only
*      -->pit_wlk2 article data (table)
*      -->pit_articles_marc (table)
*----------------------------------------------------------------------*
FORM prefetch_article_data
  TABLES pit_wlk2 STRUCTURE gt_wlk2
         pit_articles_marc STRUCTURE gt_wlk2
  USING pi_filia LIKE t001w-werks
        pi_do_pref_mara TYPE abap_bool
        pi_do_pref_marc_only TYPE abap_bool.

*--- information for which country the MLAN buffer is filled and for which store
*--- the appropriate information was determined:
  STATICS: s_t001w TYPE t001w.
  STATICS: sv_aland TYPE aland.

  DATA ls_pre03 TYPE pre03.
  DATA ls_pre09 TYPE pre09.
  DATA ls_pre01 TYPE pre01.
  DATA ls_pre19 TYPE pre19.
  DATA lt_pre03_mara TYPE pre03_tab.
  DATA lt_pre03_marm TYPE pre03_tab.
  DATA lt_pre03_mvke TYPE pre03_tab.
  DATA lt_pre03_mean TYPE pre03_tab.
  DATA lt_pre03_mamt TYPE pre03_tab.
  DATA lt_pre09_makt TYPE STANDARD TABLE OF pre09.
  DATA lt_pre01_marc TYPE pre01_tab.
  DATA lt_pre19_mlan TYPE STANDARD TABLE OF pre19.
  DATA lv_country_changed TYPE abap_bool VALUE abap_false.
  DATA ls_t001w TYPE t001w.


  FIELD-SYMBOLS <ls_wkwlk2> TYPE wkwlk2.

  IF pit_wlk2[] IS INITIAL AND pit_articles_marc[] IS INITIAL.
    RETURN.
  ENDIF.

*--- preparation of prefetch for table MLAN shall be done.
*---Check at first, if the data in the buffer can fit:
  IF pi_filia IS NOT INITIAL.
    IF pi_filia NE s_t001w-werks.
*--- the store has changed; the plant related data for the new store must be determined:
      CALL FUNCTION 'T001W_SINGLE_READ'
        EXPORTING
          kzrfb       = abap_false
          t001w_werks = pi_filia
        IMPORTING
          wt001w      = ls_t001w
        EXCEPTIONS
          not_found   = 1
          OTHERS      = 2.

      IF sy-subrc = 0.
        s_t001w = ls_t001w.
      ELSE.
        CLEAR s_t001w.
      ENDIF.
    ENDIF.

    IF sv_aland NE s_t001w-land1.
*--- if some data are already prefetched, then they don't fit to the new given
*--- country therefore: reset any way:
*--- deletion of internal MLAN buffer:
      IF sv_aland IS NOT INITIAL.
*--- there is a country change
        lv_country_changed = abap_true.

        CALL FUNCTION 'MATERIAL_PRE_READ_MLAN'
          EXPORTING
            kzrfb = abap_true.
      ENDIF.

*--- assign the new value to the static variable:
      sv_aland = s_t001w-land1.
    ENDIF.
  ENDIF.

*--- pit_wlk2 contains articles which are relevant for all
*--- tables
  LOOP AT pit_wlk2 ASSIGNING <ls_wkwlk2>.
    IF pi_do_pref_marc_only = abap_false.
      MOVE <ls_wkwlk2>-matnr TO ls_pre03-matnr.
      MOVE <ls_wkwlk2>-matnr TO ls_pre09-matnr.
      MOVE sy-langu          TO ls_pre09-spras.

      APPEND ls_pre03 TO lt_pre03_mara.
      APPEND ls_pre03 TO lt_pre03_marm.
      APPEND ls_pre03 TO lt_pre03_mvke.
      APPEND ls_pre03 TO lt_pre03_mean.
      APPEND ls_pre03 TO lt_pre03_mamt.
      APPEND ls_pre09 TO lt_pre09_makt.
    ENDIF.

    IF pi_do_pref_marc_only = abap_false OR lv_country_changed = abap_true.
      ls_pre19-matnr = <ls_wkwlk2>-matnr.
      ls_pre19-aland = sv_aland.

      APPEND ls_pre19 TO lt_pre19_mlan.
    ENDIF.

    MOVE <ls_wkwlk2>-matnr TO ls_pre01-matnr.
    MOVE pi_filia          TO ls_pre01-werks.

    APPEND ls_pre01 TO lt_pre01_marc.
  ENDLOOP.

*--- pit_articles_marc contains only articles which have to be prefetched
*--- for table MARC and table MLAN in case of a store and country change
  LOOP AT pit_articles_marc ASSIGNING <ls_wkwlk2>..
    MOVE <ls_wkwlk2>-matnr TO ls_pre01-matnr.
    MOVE pi_filia          TO ls_pre01-werks.

    APPEND ls_pre01 TO lt_pre01_marc.

    IF lv_country_changed = abap_true.
      ls_pre19-matnr = <ls_wkwlk2>-matnr.
      ls_pre19-aland = sv_aland.

      APPEND ls_pre19 TO lt_pre19_mlan.
    ENDIF.
  ENDLOOP.

  IF pi_do_pref_marc_only = abap_false.
*--- prefetch for MARA:
    IF pi_do_pref_mara = abap_true.
      CALL FUNCTION 'MARA_ARRAY_READ'
        TABLES
          ipre03               = lt_pre03_mara[]
        EXCEPTIONS
          enqueue_mode_changed = 1
          OTHERS               = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.

*--- prefetch for MARM:
    CALL FUNCTION 'MARM_ARRAY_READ_MATNR_ALL'
      TABLES
        ipre03 = lt_pre03_marm[].

*--- prefetch for MVKE:
    CALL FUNCTION 'MVKE_ARRAY_READ_MATNR_ALL'
      TABLES
        ipre03               = lt_pre03_mvke[]
*       MVKE_TAB             =
      EXCEPTIONS
        enqueue_mode_changed = 1
        lock_system_error    = 2
        lock_on_mvke         = 3
        OTHERS               = 4.

*--- prefetch for MEAN:
    CALL FUNCTION 'MEAN_ARRAY_READ_MATNR_ALL'
      TABLES
        ipre03 = lt_pre03_mean.

*--- prefetch for MAMT:
    CALL FUNCTION 'MAMT_ARRAY_READ_MATNR_ALL'
      TABLES
        ipre03               = lt_pre03_mamt
      EXCEPTIONS
        enqueue_mode_changed = 1
        OTHERS               = 2.

*--- prefetch for MAKT:
    CALL FUNCTION 'MAKT_ARRAY_READ'
      TABLES
        ipre09               = lt_pre09_makt
      EXCEPTIONS
        enqueue_mode_changed = 1
        OTHERS               = 2.
  ENDIF.

  IF pi_do_pref_marc_only = abap_false OR lv_country_changed = abap_true.
*--- prefetch for MLAN
*--- delete duplicate at first, because it is not done in
*--- the called function module (for all other tables, this
*--- is done within the called function module):
    SORT lt_pre19_mlan.
    DELETE ADJACENT DUPLICATES FROM lt_pre19_mlan.
    CALL FUNCTION 'MATERIAL_PRE_READ_MLAN'
      TABLES
        mlan_keytab = lt_pre19_mlan.
  ENDIF.

* B: New listing check logic => Note 1982796
  IF cl_retail_switch_check=>isr_appl_store_con_sfws( ) EQ abap_true
     AND gs_twpa-marc_chk IS NOT INITIAL.
  ELSE.
*--- prefetch for MARC:
    CALL FUNCTION 'MARC_ARRAY_READ'
      TABLES
        ipre01               = lt_pre01_marc
      EXCEPTIONS
        enqueue_mode_changed = 1
        lock_on_marc         = 2
        lock_system_error    = 3
        OTHERS               = 4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form check_call_listed_articles_get
*&---------------------------------------------------------------------*
* This form checks if the form listed_articles_get needs to be called
*----------------------------------------------------------------------*
*      -->pit_article article table
*      -->pi_mode Mode (initial or delta download)
*      -->pi_art direct request or restart mode for articles?
*      -->pi_ean direct request or restart mode for eans?
*      <--po_must_be_called flag to check if listed_articles_get must
*                           be called
*----------------------------------------------------------------------*
FORM check_call_listed_articles_get TABLES pit_article STRUCTURE wpart
                                    USING pi_mode LIKE wpstruc-modus
                                          pi_art LIKE wpstruc-modus
                                          pi_ean LIKE wpstruc-modus
                                    CHANGING po_must_be_called TYPE abap_bool.

  DATA: lv_art_lines TYPE i,
        lv_ean_lines TYPE i.

  po_must_be_called = abap_false.

*  If direct request or restart mode for articles, check if
* article table contains article data
  IF pi_art <> space.
    CLEAR: lv_art_lines.
    READ TABLE pit_article WITH KEY
         arttyp = c_artikeltyp
         BINARY SEARCH.

    IF sy-subrc = 0.
      lv_art_lines = 1.
    ENDIF.                           " SY-SUBRC = 0.
  ENDIF.                             " PI_ART <> SPACE.

  IF pi_mode = c_init_mode OR ( pi_art <> space AND lv_art_lines = 0 ).
    po_must_be_called = abap_true.
    RETURN.
  ENDIF.

*  If direct request or restart mode for ean, check if
* article table contains ean data
  IF pi_ean <> space.
    CLEAR: lv_ean_lines.
    READ TABLE pit_article WITH KEY
         arttyp = c_eantyp
         BINARY SEARCH.

    IF sy-subrc = 0.
      lv_ean_lines = 1.
    ENDIF.                           " SY-SUBRC = 0.
  ENDIF.                             " PI_ART <> SPACE.

  IF pi_mode = c_init_mode OR ( pi_ean <> space AND lv_ean_lines = 0 ).
    po_must_be_called = abap_true.
    RETURN.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_next_article_package
*&---------------------------------------------------------------------*
* This form determines the next article package to be prefetched
*----------------------------------------------------------------------*
*      -->pit_wlk2_save table
*      <--pot_wlk2 (table will be built up)
*      -->piv_package_size (determines how many items will be tranferred
*                           into pot_wlk2)
*      <->px_last_processed_index (index of last processed entry in
*                                  pit_wlk2_save
*----------------------------------------------------------------------*
FORM get_next_article_package TABLES pit_wlk2_save STRUCTURE gt_wlk2
                                     pot_wlk2      STRUCTURE gt_wlk2
                              USING  piv_package_size TYPE pos_max_idoc_size
                                     px_last_processed_index TYPE sy-tabix.

  DATA lv_start_index TYPE sy-tabix.
  DATA lv_stop_index TYPE sy-tabix.

  FIELD-SYMBOLS <ls_wlk2> TYPE wkwlk2.

  REFRESH: pot_wlk2.

  lv_start_index = px_last_processed_index + 1.
  lv_stop_index  = px_last_processed_index + piv_package_size.

  LOOP AT pit_wlk2_save FROM lv_start_index ASSIGNING <ls_wlk2>.
    IF sy-tabix > lv_stop_index.
      EXIT.
    ELSE.
      MOVE sy-tabix TO px_last_processed_index.
      APPEND <ls_wlk2> TO pot_wlk2.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form prefetch_plant_related_data
*&---------------------------------------------------------------------*
* This form does a prefetch for plant related data
*----------------------------------------------------------------------*
*      -->pit_filia (table)
*----------------------------------------------------------------------*
FORM prefetch_plant_related_data TABLES pit_filia STRUCTURE wpfilia.

  DATA ls_t001w        TYPE t001w.
  DATA lt_t001w        TYPE STANDARD TABLE OF t001w.
  DATA lt_t001w_return TYPE STANDARD TABLE OF t001w.
  DATA ls_range_kunnr  TYPE bapi_rangeskunnr.
  DATA lt_range_kunnr  TYPE STANDARD TABLE OF bapi_rangeskunnr.

  FIELD-SYMBOLS <ls_filia> TYPE wpfilia.
  FIELD-SYMBOLS <ls_t001w> TYPE t001w.

  IF pit_filia[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT pit_filia ASSIGNING <ls_filia>.
    MOVE <ls_filia>-filia TO ls_t001w-werks.
    APPEND ls_t001w TO lt_t001w.
  ENDLOOP.

*--- prefetch for T001W:
  CALL FUNCTION 'LOCATION_SELECT_PLANT_BY_RANGE'
    TABLES
      i_t001w       = lt_t001w[]
      o_t001w_found = lt_t001w_return[].

  IF lt_t001w_return[] IS INITIAL.
    RETURN.
  ENDIF.

  MOVE 'I' TO ls_range_kunnr-sign.
  MOVE 'EQ' TO ls_range_kunnr-option.
  LOOP AT lt_t001w_return ASSIGNING <ls_t001w>.
    MOVE <ls_t001w>-kunnr TO ls_range_kunnr-low.
    APPEND ls_range_kunnr TO lt_range_kunnr.
  ENDLOOP.

*--- prefetch for WRF1:
  CALL FUNCTION 'LOCATION_PREFETCH_WRF1'
    TABLES
      i_kunnr = lt_range_kunnr[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_package_size
*&---------------------------------------------------------------------*
* This form computes the maximum package size for the DB table buffering
*----------------------------------------------------------------------*
*      <--ov_package_size
*----------------------------------------------------------------------*
FORM get_package_size CHANGING ov_package_size.
*--- the package size shall be the maximum of the Idoc-sizing for
*--- PLU and EAN:
*--- additionally, a BAdI-method can be processed to overwrite the
*--- calculated value:
  DATA lv_mode             TYPE wjdposmode.
  DATA lr_mode_get         TYPE REF TO data.
  DATA lo_badi             TYPE REF TO badi_wpos_outbound_pckg_size.
  DATA lv_new_package_size TYPE pos_max_idoc_size.

  FIELD-SYMBOLS <lv_mode_get> TYPE wjdposmode.

  MOVE c_max_idoc_plu TO ov_package_size.
  IF ov_package_size <  c_max_idoc_ean.
    MOVE c_max_idoc_ean TO ov_package_size.
  ENDIF.

*--- the minimum package size is always 5000
  IF ov_package_size < 5000.
    ov_package_size = 5000.
  ENDIF.

*--- determine the mode which is filter criterion of the BAdi-method; because it
*--- is not possible to transfer the mode via importing parameter, this is done
*--- via the class CL_WRT_FORM_PARAMETER. Consider that between the setting and
*--- the getting of the parameter 'PIV_MODE' there can be more than one call levels:
  TRY.
      cl_wrt_form_parameter=>get_instance( )->get( EXPORTING iv_name = 'PIV_MODE'
                                                   IMPORTING e_data  = lr_mode_get ).

      ASSIGN lr_mode_get->* TO <lv_mode_get>.
      lv_mode = <lv_mode_get>.

    CATCH cx_wrt_form_parameter_error .
      CLEAR lv_mode.
  ENDTRY.

*--- get the BAdI-Instance and call the BAdI:
  TRY.
      GET BADI lo_badi
        FILTERS
          pos_mode = lv_mode.

      lv_new_package_size = ov_package_size.

      CALL BADI lo_badi->set_package_size
        CHANGING
          cv_package_size = lv_new_package_size.

      IF lv_new_package_size > 0.
        ov_package_size = lv_new_package_size.
      ENDIF.
    CATCH cx_badi_not_implemented   ##no_handler.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_article_pckg_for_download
*&---------------------------------------------------------------------*
* This form computes the list of articles which have to be prefetched
* next and does this prefetch. If a buffer refresh is needed, then this
* will also be done.
*----------------------------------------------------------------------*
*      -->pit_wlk2_save (table)
*      <--pot_wlk2 (table)
*      -->piv_count_filia
*      -->piv_curr_number_filia
*      -->piv_size_gt_wlk2
*      -->piv_filia
*      <->pxv_last_processed_index
*      <->pxt_contained_articles (table)
*----------------------------------------------------------------------*
FORM get_article_pckg_for_download TABLES pit_wlk2_save STRUCTURE gt_wlk2
                                          pot_wlk2 STRUCTURE gt_wlk2
                                   USING piv_count_filia TYPE i
                                         piv_curr_number_filia TYPE i
                                         piv_size_gt_wlk2 TYPE i
                                         piv_filia LIKE wpfilia-filia
                                   CHANGING pxv_last_processed_index TYPE i
                                            pxt_contained_articles TYPE tth_articles.

  DATA lv_do_pref_mara TYPE abap_bool.  "flag to decide if a prefetch for MARA is needed
  DATA lv_disable_reset TYPE abap_bool. "flag to disable the reset on store-independant tables (all but MARC)
  DATA lv_package_size TYPE pos_max_idoc_size.
  DATA lt_new_articles TYPE TABLE OF wkwlk2.  "table to store all new artices of a package which have to be prefetched

  DATA lv_use_new_articles TYPE abap_bool.
  DATA lv_do_marc_prefetch_only TYPE abap_bool.
  DATA lv_percentage TYPE p DECIMALS 5.       "number of changed articles in percent
  DATA lt_marc_articles TYPE TABLE OF wkwlk2. "articles only needed for table MARC
  DATA lv_do_general_reset TYPE abap_bool.    "flag to decide if the article buffer reset should be executed
  FIELD-SYMBOLS <ls_wlk2> TYPE wkwlk2.

  IF piv_size_gt_wlk2 = 0.      "there are no articles listed for this store ->do nothing
    RETURN.
  ENDIF.

  IF piv_count_filia = 0.       "there are no stores at all -> do nothing
    RETURN.
  ENDIF.

  IF piv_curr_number_filia = 1 AND pxv_last_processed_index = 0.  "first store and first package run
    lv_do_general_reset = abap_false.
  ELSE.
    lv_do_general_reset = abap_true.
  ENDIF.

  PERFORM get_package_size CHANGING lv_package_size.

  IF pxv_last_processed_index = 0.    "first package of a store
    IF piv_size_gt_wlk2 <= lv_package_size. "less articles than package size -> no prefetch for MARA needed, reset not disabled
      lv_do_pref_mara = abap_false.
      lv_disable_reset = abap_false.
    ELSE.                                   "more articles than package size -> prefetch for MARA necessary
      "because buffer shall only contain data of current package, reset not disabled
      lv_do_pref_mara = abap_true.
      lv_disable_reset = abap_false.
    ENDIF.
  ELSE.                               "not first package of a store -> prefetch for MARA is always necessary, reset not disabled
    lv_do_pref_mara = abap_true.
    lv_disable_reset = abap_false.
  ENDIF.

  "compute next package
  IF piv_size_gt_wlk2 <= lv_package_size. "not necessary to compute next package because there is only one
    pot_wlk2 = pit_wlk2_save.
    pxv_last_processed_index = piv_size_gt_wlk2.
  ELSE.
    PERFORM get_next_article_package TABLES pit_wlk2_save
                                            pot_wlk2
                                     USING  lv_package_size
                                            pxv_last_processed_index.
  ENDIF.

  IF piv_count_filia = 1.     "there is only one store -> not necessary to build up pxt_contained_articles.
    IF lv_do_general_reset = abap_true.
      PERFORM reset_article_buffers USING lv_disable_reset.
    ENDIF.

    PERFORM prefetch_article_data TABLES pot_wlk2
                                         lt_marc_articles
                                  USING  piv_filia
                                         lv_do_pref_mara
                                         abap_false.       "not only MARC
  ELSE.                     "there is more than one store
    IF pxt_contained_articles[] IS INITIAL.   "all articles need to be prefetched
      lv_use_new_articles = abap_false.
      lv_disable_reset = abap_false.
      REFRESH lt_marc_articles.
    ELSE.                                  "some articles are already buffered
      LOOP AT pot_wlk2 ASSIGNING <ls_wlk2>.
        READ TABLE pxt_contained_articles WITH TABLE KEY table_line = <ls_wlk2>-matnr
                                          TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.     "not already buffered
          APPEND <ls_wlk2> TO lt_new_articles.
        ELSE.                "already buffered -> only prefetch for MARC needed
          APPEND <ls_wlk2> TO lt_marc_articles.
        ENDIF.
      ENDLOOP.

      "compute the ration between new articles (articles which need to be prefetched) and all articles of this package
      lv_percentage = lines( lt_new_articles ) / lines( pot_wlk2 ) * 100.

      IF lv_percentage <= 0.    " all articles already buffered, only a prefetch for MARC is needed
        lv_do_marc_prefetch_only = abap_true.
        lv_use_new_articles = abap_true.
        lv_disable_reset = abap_true.
      ELSEIF lv_percentage <= 50.    "not more than 50% of the articles must be prefetched, reset only for MARC
        lv_do_marc_prefetch_only = abap_false.
        lv_use_new_articles = abap_true.
        lv_disable_reset = abap_true.
      ELSE.                       "more than 50% of the articles must be prefetched -> reset and prefetch for all articles
        lv_do_marc_prefetch_only = abap_false.
        lv_use_new_articles = abap_false.
        lv_disable_reset = abap_false.

        REFRESH lt_marc_articles.
      ENDIF.
    ENDIF.

    IF lv_do_general_reset = abap_true.
      PERFORM reset_article_buffers USING lv_disable_reset.
    ENDIF.

    IF lv_use_new_articles = abap_true.   "store-independent data will be prefetched only for new articles,
      "store-dependent data (MARC) will be prefetched for all articles
      PERFORM prefetch_article_data TABLES lt_new_articles
                                           lt_marc_articles
                                    USING  piv_filia
                                           lv_do_pref_mara
                                           lv_do_marc_prefetch_only.
    ELSE.                                 "all articles of the package must be prefetched, there are no special MARC articles
      PERFORM prefetch_article_data TABLES pot_wlk2
                                           lt_marc_articles
                                    USING  piv_filia
                                           lv_do_pref_mara
                                           lv_do_marc_prefetch_only.
    ENDIF.

    IF pxv_last_processed_index >= piv_size_gt_wlk2.    "last package of a store -> prefetched articles must be transferred to pxt_contained_articles
      IF piv_curr_number_filia < piv_count_filia.       "this must only be done if this is not the last store
        IF lv_use_new_articles = abap_true.             "insert all new articles of prefetch
          LOOP AT lt_new_articles ASSIGNING <ls_wlk2>.
            INSERT <ls_wlk2>-matnr INTO TABLE pxt_contained_articles.
          ENDLOOP.
        ELSE.                                         "all articles of the package are inserted
          REFRESH pxt_contained_articles.

          LOOP AT pot_wlk2 ASSIGNING <ls_wlk2>.
            INSERT <ls_wlk2>-matnr INTO TABLE pxt_contained_articles.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ELSE.                                           "not last package of a store -> pxt_contained_articles must be refreshed because next package has only new articles
      REFRESH pxt_contained_articles.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_article_from wind
*&---------------------------------------------------------------------*
* This form determines an article out of a wind entry.
*----------------------------------------------------------------------*
*      -->pit_kondart (table)
*      -->pit_filia (table)
*      -->pis_wind
*      -->piv_datab
*      -->piv_datbi
*      <--pos_article
*----------------------------------------------------------------------*
FORM get_article_from_wind TABLES    pit_kondart STRUCTURE wpkondart
                                     pit_filia STRUCTURE wdl_fil
                            USING    pis_wind TYPE windvb
                                     piv_datab TYPE wpstruc-datum
                                     piv_datbi TYPE wpstruc-datum
                            CHANGING pos_article TYPE pre03.

  DATA ls_konh TYPE konh.
  DATA ls_komg TYPE komg.
  DATA lv_ignore TYPE abap_bool.

  CLEAR: pos_article.

*     Copy the WIND data to our konh structure
  MOVE-CORRESPONDING pis_wind TO ls_konh.

*   Is usage relevant?
  IF ls_konh-kvewe = c_cond_vewe.
*     Check if corresponding SAP condition type in pit_wind is
*     relevant for this store group concerning POS
    CLEAR pit_kondart.
    READ TABLE pit_kondart WITH KEY kschl = ls_konh-kschl
                           TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc = 0.
      LOOP AT pit_kondart FROM sy-tabix.
        IF ( pit_kondart-kvewe = ls_konh-kvewe   OR
             pit_kondart-kvewe = space ).
          EXIT.
        ELSEIF pit_kondart-kschl NE ls_konh-kschl.
          CLEAR pit_kondart.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
*     This condition type is relevant concerning POS
    IF pit_kondart IS NOT INITIAL.
*       If the max interval of this condition record does not
*       lie in the given periond, it can be ignored
      IF NOT ls_konh-datab IS INITIAL AND
         NOT ls_konh-datbi IS INITIAL.
        IF ls_konh-datab > piv_datbi OR
           ls_konh-datbi < piv_datab.
          CLEAR: pos_article.
          RETURN.
        ENDIF. " konh-datab >= pi_datbi or ...
      ENDIF. " not ls_konh-datab is initial and

*"-----KONH has no longer VAKEY, it is determined on the fly to fill KOMG
*       Compute corresponding object key
*      CALL FUNCTION 'SD_CONDITION_KOMG_FILL'
*        EXPORTING
*          p_kotabnr = ls_konh-kotabnr
*          p_kvewe   = ls_konh-kvewe
*          p_vakey   = ls_konh-vakey
*        IMPORTING
*          p_komg    = ls_komg.
      CALL METHOD CL_PREPARE_KOMG=>FILL_KOMG_FROM_VAKEY
        EXPORTING
          I_KONH          = ls_konh
        IMPORTING
          E_KOMG          = ls_komg
        EXCEPTIONS
          VAKEY_NOT_FOUND = 1
          others          = 2.

      check sy-subrc EQ 0.
*       Check if this condition is store-dependent and if so,
*       if it belongs to the group of stores which is currently processed
      PERFORM varkey_precheck
              TABLES pit_filia
              USING  ls_komg
                     lv_ignore.

*       If this condition change is not relevant, just go to
*       the next condition change
      IF NOT lv_ignore IS INITIAL.
        CLEAR: pos_article.
        RETURN.
      ELSE.
        MOVE ls_komg-matnr TO pos_article-matnr.
        RETURN.
      ENDIF. " not lv_ignore is initial.
    ELSE.
      CLEAR: pos_article.
      RETURN.
    ENDIF.
  ELSE.
    CLEAR: pos_article.
    RETURN.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_next_wind_package
*&---------------------------------------------------------------------*
* This form determines the next article package to be prefetched
* concerning wind data.
*----------------------------------------------------------------------*
*      -->pit_wind (table)
*      -->pit_kondart (table)
*      -->pit_filia (table)
*      <--pot_wind_package (table will be built up)
*      -->piv_package_size (determines how many items will be tranferred
*                           into pot_wind_package)
*      -->piv_datab
*      -->piv_datbi
*      <->px_last_processed_index (index of last processed entry in
*                                  pit_wind_table)
*      <--pot_articles (table will be built up)
*----------------------------------------------------------------------*
FORM get_next_wind_package TABLES   pit_wind STRUCTURE windvb
                                    pit_kondart STRUCTURE wpkondart
                                    pit_filia STRUCTURE wdl_fil
                                    pot_wind_package  STRUCTURE windvb
                           USING    piv_package_size TYPE pos_max_idoc_size
                                    piv_datab TYPE wpstruc-datum
                                    piv_datbi TYPE wpstruc-datum
                           CHANGING px_last_processed_index TYPE sy-tabix
                                    pot_articles TYPE pre03_tab.

  DATA lv_start_index TYPE sy-tabix.
  DATA ls_article TYPE pre03.
  DATA lv_nr_of_articles TYPE i VALUE 0.
  DATA ls_last_art_in_pckg TYPE pre03.
  DATA lv_wind_tabix       TYPE sy-tabix.

  FIELD-SYMBOLS <ls_windvb> TYPE windvb.

  REFRESH: pot_wind_package.

  lv_start_index = px_last_processed_index + 1.

  LOOP AT pit_wind FROM lv_start_index ASSIGNING <ls_windvb>.
    IF lv_nr_of_articles >= piv_package_size.
      IF ls_article IS NOT INITIAL AND ls_article <> ls_last_art_in_pckg.
        EXIT.
      ENDIF.
    ENDIF.

    lv_wind_tabix = sy-tabix.

    PERFORM get_article_from_wind TABLES   pit_kondart
                                           pit_filia
                                  USING    <ls_windvb>
                                           piv_datab
                                           piv_datbi
                                  CHANGING ls_article.

    IF ls_article IS NOT INITIAL.
      IF ls_last_art_in_pckg IS NOT INITIAL AND
         ls_last_art_in_pckg NE ls_article.
*--- the found article is not equal to the last article entered in
*--- the package before the package size was reached ==> skip this
*--- article; it has to be handled in the next package:
        CONTINUE.
      ENDIF.
      px_last_processed_index = lv_wind_tabix.
*    We only have to add the entry here to the wind package
*    as an article exists for it and is relevant for the
*    current store.
      APPEND <ls_windvb> TO pot_wind_package.

*    Add the article number of this condition change to our articles table
*    We do not want to have duplicates in our articles table
      READ TABLE pot_articles BINARY SEARCH WITH KEY matnr = ls_article-matnr TRANSPORTING NO FIELDS.

      IF sy-subrc <> 0.
        INSERT ls_article INTO pot_articles INDEX sy-tabix.
        lv_nr_of_articles = lv_nr_of_articles + 1.
        IF lv_nr_of_articles >= piv_package_size.
*--- store the article which is added as last to the package; as long as
*--- no other article is found, the wind package can be built up further;
*--- other articles have to be handled in the next package:
          ls_last_art_in_pckg = ls_article.
        ENDIF.
      ENDIF.
    ELSE.
*--- the wind-entry does not have an article:
      px_last_processed_index = lv_wind_tabix.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_wind_pckg_for_download
*&---------------------------------------------------------------------*
* This form computes the list of articles which have to be prefetched
* next and does this prefetch (including a buffer reset before the prefetch).
* It gives back the entries in table PIT_WIND which
* have to be processed in the next package.
*----------------------------------------------------------------------*
*      -->pit_wind (table)
*      -->pit_kondart (table)
*      -->pit_filia (table)
*      <--pot_wind_package (table)
*      -->piv_size_wind
*      -->piv_datab
*      -->piv_datbi
*      -->piv_package_size
*      <->pxv_last_processed_index
*----------------------------------------------------------------------*
FORM get_wind_pckg_for_download TABLES   pit_wind STRUCTURE windvb
                                         pit_kondart STRUCTURE wpkondart
                                         pit_filia STRUCTURE wdl_fil
                                         pot_wind_package STRUCTURE windvb
                                USING    piv_size_wind TYPE i
                                         piv_datab TYPE wpstruc-datum
                                         piv_datbi TYPE wpstruc-datum
                                         piv_package_size TYPE pos_max_idoc_size
                                CHANGING pxv_last_processed_index TYPE i.

  DATA lt_wind_articles TYPE pre03_tab.

*--- initialization of the result table:
  REFRESH pot_wind_package.

  IF piv_size_wind = 0.
*--- there are not WIND-entries listed --> do nothing:
    RETURN.
  ENDIF.

*--- compute next package and articles to be prefetched:
  PERFORM get_next_wind_package TABLES    pit_wind
                                          pit_kondart
                                          pit_filia
                                          pot_wind_package
                                 USING    piv_package_size
                                          piv_datab
                                          piv_datbi
                                 CHANGING pxv_last_processed_index
                                          lt_wind_articles.

*--- do the prefetches for the found articles:
  CALL FUNCTION 'POS_PREP_PREFETCH_ARTICLE_DATA'
    EXPORTING
      it_articles     = lt_wind_articles
      i_package_size  = piv_package_size
      i_mara_pref     = abap_true
      i_marc_pref     = abap_false
      i_mlan_pref     = abap_false
      i_variants_pref = abap_true
      i_generics_pref = abap_true.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_next_pointer_package
*&---------------------------------------------------------------------*
* This form determines the next article package to be prefetched
* concerning pointer data.
*----------------------------------------------------------------------*
*      -->pit_pointer (table)
*      <--pot_pointer_package (table will be built up)
*      <--pot_articles (table will be built up)
*      -->piv_package_size (determines how many items will be tranferred
*                           into pot_wind_package)
*      -->piv_pointer_tabix (start index within pointer table)
*      <->px_last_processed_index (index of last processed entry in
*                                  pit_wind_table)
*----------------------------------------------------------------------*
FORM get_next_pointer_package TABLES   pit_pointer STRUCTURE bdcp
                                       pot_pointer_package  STRUCTURE windvb
                              USING    piv_package_size TYPE pos_max_idoc_size
                                       piv_pointer_tabix TYPE sy-tabix
                              CHANGING px_last_processed_index TYPE sy-tabix
                                       pot_articles TYPE pre03_tab.

  DATA lv_start_index TYPE sy-tabix.
  DATA ls_article TYPE pre03.
  DATA lv_nr_of_articles TYPE i VALUE 0.
  DATA ls_last_art_in_pckg TYPE pre03.
  DATA lv_pointer_tabix    TYPE sy-tabix.

  FIELD-SYMBOLS <ls_pointer> TYPE bdcp.

  REFRESH: pot_pointer_package.
  REFRESH: pot_articles.

  IF px_last_processed_index = 0.
    lv_start_index = piv_pointer_tabix.
  ELSE.
    lv_start_index = px_last_processed_index + 1.
  ENDIF.

  LOOP AT pit_pointer FROM lv_start_index ASSIGNING <ls_pointer>.
    IF lv_nr_of_articles >= piv_package_size.
      IF ls_article IS NOT INITIAL AND ls_article <> ls_last_art_in_pckg.
        EXIT.
      ENDIF.
    ENDIF.

*     Leave the loop when last relevant entry was processed
    IF <ls_pointer>-cdobjcl <> c_objcl_mat_full.
      px_last_processed_index = lines( pit_pointer ) + 1.
      EXIT.
    ENDIF. " ls_pointer-cdobjcl <> c_objcl_mat_full.

    lv_pointer_tabix = sy-tabix.

*   Only consider pointers which "belong" to us
    IF <ls_pointer>-tabname = 'MARA' OR <ls_pointer>-tabname = 'DMARM' OR <ls_pointer>-tabname = 'DMEAN' OR <ls_pointer>-tabname = 'DMAKT' OR <ls_pointer>-tabname = 'DMAMT'.
      ls_article-matnr = <ls_pointer>-cdobjid.

      IF ls_last_art_in_pckg IS NOT INITIAL AND
         ls_last_art_in_pckg NE ls_article.
*--- the found article is not equal to the last article entered in
*--- the package before the package size was reached ==> skip this
*--- article; it has to be handled in the next package:
        CONTINUE.
      ENDIF.
      px_last_processed_index = lv_pointer_tabix.

*    We do not want to have duplicates in our articles table
      READ TABLE pot_articles BINARY SEARCH WITH KEY matnr = ls_article-matnr TRANSPORTING NO FIELDS.

*    Add the article number of this pointer change to our articles table
      IF sy-subrc <> 0.
        INSERT ls_article INTO pot_articles INDEX sy-tabix.
        lv_nr_of_articles = lv_nr_of_articles + 1.
        IF lv_nr_of_articles >= piv_package_size.
*--- store the article which is added as last to the package; as long as
*--- no other article is found, the wind package can be built up further;
*--- other articles have to be handled in the next package:
          ls_last_art_in_pckg = ls_article.
        ENDIF.
      ENDIF.
    ELSE.
*--- the pointer does not "belong" to us; continue with the next entry:
      CLEAR ls_article.
      px_last_processed_index = lv_pointer_tabix.
    ENDIF.

    APPEND <ls_pointer> TO pot_pointer_package ##ENH_OK.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_pointer_pckg_for_download
*&---------------------------------------------------------------------*
* This form computes the list of articles which have to be prefetched
* next and does this prefetch (including a buffer refresh before the prefetch).
* It gives back the entries in table PIT_POINTER which
* have to be processed in the next package.
*----------------------------------------------------------------------*
*      -->pit_pointer (table)
*      <--pot_pointer_package (table)
*      -->piv_size_pointer
*      -->piv_pointer_tabix
*      -->piv_package_size
*      <->pxv_last_processed_index
*----------------------------------------------------------------------*
FORM get_pointer_pckg_for_download TABLES   pit_pointer STRUCTURE bdcp
                                            pot_pointer_package STRUCTURE bdcp
                                   USING    piv_size_pointer TYPE i
                                            piv_pointer_tabix TYPE sy-tabix
                                            piv_package_size TYPE pos_max_idoc_size
                                   CHANGING pxv_last_processed_index TYPE i.

  DATA lt_pointer_articles TYPE pre03_tab.

*--- initialization of the result table:
  REFRESH pot_pointer_package.

  IF piv_size_pointer = 0.
*--- there are no pointer entries listed --> do nothing:
    RETURN.
  ENDIF.

*--- compute next package:
  PERFORM get_next_pointer_package TABLES   pit_pointer ##ENH_OK
                                            pot_pointer_package
                                   USING    piv_package_size
                                            piv_pointer_tabix
                                   CHANGING pxv_last_processed_index
                                            lt_pointer_articles.

*--- do the prefetches for the found articles
  CALL FUNCTION 'POS_PREP_PREFETCH_ARTICLE_DATA'
    EXPORTING
      it_articles     = lt_pointer_articles
      i_package_size  = piv_package_size
      i_mara_pref     = abap_true
      i_marc_pref     = abap_false
      i_mlan_pref     = abap_false
      i_variants_pref = abap_true
      i_generics_pref = abap_true.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_next_ot3_artstm_package
*&---------------------------------------------------------------------*
* This form determines the next WPAOT3 data package to be prefetched
*----------------------------------------------------------------------*
*      -->pit_wpaot3_data (table)
*      <--pot_wpaot3_package (table will be built up)
*      <--pot_articles (table will be built up)
*      -->piv_package_size (determines how many items will be tranferred
*                           into pot_wpaot3_package)
*      <->px_last_processed_index (index of last processed entry in
*                                  pit_wpaot3_data table)
*----------------------------------------------------------------------*
FORM get_next_wpaot3_package TABLES   pit_wpaot3_data STRUCTURE wpaot3
                                      pot_wpaot3_package STRUCTURE wpaot3
                             USING    piv_package_size TYPE pos_max_idoc_size
                             CHANGING px_last_processed_index TYPE sy-tabix
                                      pot_articles TYPE pre03_tab.

  DATA lv_start_index TYPE sy-tabix.
  DATA ls_article TYPE pre03.
  DATA lv_nr_of_articles TYPE i VALUE 0.
  DATA ls_last_art_in_pckg TYPE pre03.
  DATA lv_wpaot3_tabix     TYPE sy-tabix.

  FIELD-SYMBOLS <ls_wpaot3> TYPE wpaot3.

  REFRESH: pot_wpaot3_package.
  REFRESH: pot_articles.

  lv_start_index = px_last_processed_index + 1.

  LOOP AT pit_wpaot3_data FROM lv_start_index ASSIGNING <ls_wpaot3>.
    IF lv_nr_of_articles >= piv_package_size.
      IF ls_article IS NOT INITIAL AND ls_article <> ls_last_art_in_pckg.
        EXIT.
      ENDIF.
    ENDIF.

    lv_wpaot3_tabix = sy-tabix.
    ls_article-matnr = <ls_wpaot3>-artnr.
    IF ls_article IS NOT INITIAL.
      IF ls_last_art_in_pckg IS NOT INITIAL AND
         ls_last_art_in_pckg NE ls_article AND
         <ls_wpaot3>-pmata = space.
*--- the found article is not equal to the last article entered in
*--- the package before the package size was reached ==> skip this
*--- article; it has to be handled in the next package:
        CONTINUE.
      ENDIF.

      APPEND <ls_wpaot3> TO pot_wpaot3_package.
      px_last_processed_index = lv_wpaot3_tabix.

*    We do not want to have duplicates in our articles table
      READ TABLE pot_articles BINARY SEARCH WITH KEY matnr = ls_article-matnr TRANSPORTING NO FIELDS.

*    Add the article number of this pointer change to our articles table
      IF sy-subrc <> 0.
        INSERT ls_article INTO pot_articles INDEX sy-tabix.
        lv_nr_of_articles = lv_nr_of_articles + 1.
        IF lv_nr_of_articles >= piv_package_size.
*--- store the article which is added as last to the package; as long as
*--- no other article is found, the wind package can be built up further;
*--- other articles have to be handled in the next package:
          ls_last_art_in_pckg = ls_article.
        ENDIF.
      ENDIF.
    ELSE.
*--- the WPAOT3-entry does not have an article number:
      APPEND <ls_wpaot3> TO pot_wpaot3_package.
      px_last_processed_index = lv_wpaot3_tabix.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_wpaot3_pckg_for_downl
*&---------------------------------------------------------------------*
* This form computes the list of articles which have to be prefetched
* next and does this prefetch (including a buffer refresh before the prefetch).
* It gives back the entries in table PIT_WPAOT3_DATA which
* have to be processed in the next package.
*----------------------------------------------------------------------*
*      -->pit_wpaot3_data (table)
*      <--pot_wpaot3_package (table)
*      -->piv_size_wpaot3_data
*      -->pis_filia_group
*      -->piv_package_size
*      -->piv_mara_pref
*      -->piv_marc_pref
*      -->piv_variants_pref
*      -->piv_generics_pref
*      <->pxv_last_processed_index
*----------------------------------------------------------------------*
FORM get_wpaot3_pckg_for_downl TABLES   pit_wpaot3_data STRUCTURE wpaot3
                                        pot_wpaot3_package STRUCTURE wpaot3
                               USING    piv_size_wpaot3_data TYPE i
                                        pis_filia_group TYPE wpfiliagrp
                                        piv_package_size TYPE pos_max_idoc_size
                                        piv_mara_pref TYPE abap_bool
                                        piv_marc_pref TYPE abap_bool
                                        piv_variants_pref TYPE abap_bool
                                        piv_generics_pref TYPE abap_bool
                               CHANGING pxv_last_processed_index TYPE i.

  DATA lt_wpaot3_articles TYPE pre03_tab.
  DATA lv_mlan_pref       TYPE abap_bool.
  DATA lr_mlan_pref_get   TYPE REF TO data.

  FIELD-SYMBOLS <lv_mlan_pref_get> TYPE abap_bool.

*--- initialization of the result table:
  REFRESH pot_wpaot3_package.

  IF piv_size_wpaot3_data = 0.
*--- there are no WPAOT3 entries listed --> do nothing:
    RETURN.
  ENDIF.

*--- compute next package:
  PERFORM get_next_wpaot3_package TABLES   pit_wpaot3_data
                                           pot_wpaot3_package
                                  USING    piv_package_size
                                  CHANGING pxv_last_processed_index
                                           lt_wpaot3_articles.

*--- determine the flag to switch on/off the prefetches on MLAN; because it
*--- is not possible to transfer the mode via importing parameter, this is done
*--- via the class CL_WRT_FORM_PARAMETER:
  TRY.
      cl_wrt_form_parameter=>get_instance( )->get( EXPORTING iv_name = 'PIV_MLAN_PREF'
                                                   IMPORTING e_data  = lr_mlan_pref_get ).

      ASSIGN lr_mlan_pref_get->* TO <lv_mlan_pref_get>.
      lv_mlan_pref = <lv_mlan_pref_get>.

    CATCH cx_wrt_form_parameter_error .
      CLEAR lv_mlan_pref.
  ENDTRY.

*--- do the prefetches for the found articles
  CALL FUNCTION 'POS_PREP_PREFETCH_ARTICLE_DATA'
    EXPORTING
      it_articles     = lt_wpaot3_articles
      i_package_size  = piv_package_size
      i_mara_pref     = piv_mara_pref
      i_marc_pref     = piv_marc_pref
      i_mlan_pref     = lv_mlan_pref
      i_variants_pref = piv_variants_pref
      i_generics_pref = piv_generics_pref
      i_vkorg         = pis_filia_group-vkorg
      i_vtweg         = pis_filia_group-vtweg
      i_werks         = pis_filia_group-filia.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form do_wind_analysis
*&---------------------------------------------------------------------*
* This form does the WIND-analysis. The coding was copied from function
* module POS_CONDITION_POINTER_ANALYSE2 in this sub routine, so that
* it can be called at several places
*----------------------------------------------------------------------*
*      -->pit_wind (table)
*      -->pit_kondart (table)
*      -->pit_filia (table)
*      <->pxt_artstm_objects (table)
*      <->pxt_artstm_objects_2 (table)
*      <->pxt_bb_obj (table)
*      <->pxt_bb_obj_2 (table)
*      -->piv_vkorg
*      -->piv_vtweg
*      -->piv_datab
*      -->piv_datbi
*      -->piv_datp3
*      -->piv_mode
*      -->piv_uexac
*----------------------------------------------------------------------*
FORM do_wind_analysis TABLES pit_wind             STRUCTURE windvb
                             pit_kondart          STRUCTURE wpkondart
                             pit_filia            STRUCTURE wdl_fil
                             pxt_artstm_objects   STRUCTURE wpartstm
                             pxt_artstm_objects_2 STRUCTURE wpaot2
                             pxt_bb_obj           STRUCTURE wpartstm2
                             pxt_bb_obj_2         STRUCTURE wpartstm2
                      USING  piv_vkorg            TYPE vkorg
                             piv_vtweg            TYPE vtweg
                             piv_datab            TYPE wpstruc-datum
                             piv_datbi            TYPE wpstruc-datum
                             piv_datp3            TYPE wpstruc-datum
                             piv_mode             TYPE wpstruc-modus
                             piv_uexac            TYPE sy-marky.

  DATA ls_konh                  TYPE konh.
  DATA ls_komg                  TYPE komg.
  DATA lv_delete                TYPE wjdposmode.
  DATA lv_ignore                TYPE wjdposmode.
  DATA lv_independence          TYPE wjdposmode.
  DATA lv_datum                 TYPE wpperiod-datbi.
  DATA lv_tabix                 TYPE sy-tabix.
  DATA ls_validity              TYPE win1_dats.
  DATA ls_mara                  TYPE mara.
  DATA ls_artstm_objects        TYPE wpartstm.
  DATA ls_artstm_objects_2      TYPE wpaot2.
  DATA ls_bb_obj                TYPE wpartstm2.
  DATA ls_bb_obj_2              TYPE wpartstm2.
*--- structure for sales condition type resp. promotion specific condition type:
  DATA ls_pespr                 TYPE pespr.
*--- for condition intervals:
  DATA lt_periods               TYPE STANDARD TABLE OF val_period.
  DATA ls_period                TYPE val_period.
*--- for condition intervals:
  DATA lt_periods_2             TYPE STANDARD TABLE OF wpperiod.
  DATA ls_period_2              TYPE wpperiod.
*--- table to store condition types with an additional flag:
  DATA lt_kondart_flag          TYPE STANDARD TABLE OF wpkartflag.
  DATA ls_kondart_flag          TYPE wpkartflag.
*--- table for start dates of a condition number:
  DATA lt_datab                 TYPE STANDARD TABLE OF wpdate.
*--- table for sales units of measure:
  DATA lt_short_marm            TYPE STANDARD TABLE OF wpos_short_marm.
  DATA ls_short_marm            TYPE wpos_short_marm.
*--- temporary table for stores:
  DATA lt_filia_tmp              TYPE STANDARD TABLE OF wpfilia_cond.

  FIELD-SYMBOLS: <fwindvb>       TYPE windvb.
  FIELD-SYMBOLS: <ls_filia_tmp>  TYPE wpfilia_cond.
  FIELD-SYMBOLS: <ls_datab>      TYPE wpdate.
  FIELD-SYMBOLS: <ls_short_marm> TYPE wpos_short_marm.

* Betrachte POS-relevante Konditionsänderungen.
  LOOP AT pit_wind ASSIGNING <fwindvb>.

    CLEAR: ls_artstm_objects, lv_delete.

*   Falls ein normaler, d. h. angereicherter WIND-Eintrag
*   vorliegt.
    IF NOT <fwindvb>-kschl IS INITIAL.
*     Umspeichern der WIND-Daten in andere Struktur.
      MOVE-CORRESPONDING <fwindvb> TO ls_konh.

*   Falls noch, ob ein alter WIND-Eintrag, d. h. ohne
*   angereicherte Daten vorliegt.
    ELSE. " <fwindvb>-kschl is initial.
*     Lese die Kopfdaten der Kondition.
      SELECT SINGLE * FROM konh INTO ls_konh
             WHERE knumh = <fwindvb>-knumh.
    ENDIF. " not <fwindvb>-kschl is initial.

*   Falls Verwendung relevant.
    IF ls_konh-kvewe = c_cond_vewe.
*     Prüfe, ob zugehörige SAP-Konditionsart in pit_wind für diese
*     Filialgruppe POS-relevant ist.
      CLEAR pit_kondart.
      READ TABLE pit_kondart WITH KEY kschl = ls_konh-kschl
                             TRANSPORTING NO FIELDS BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT pit_kondart FROM sy-tabix.
          IF ( pit_kondart-kvewe = ls_konh-kvewe   OR
               pit_kondart-kvewe = space ).
            EXIT.
          ELSEIF pit_kondart-kschl NE ls_konh-kschl.
            CLEAR pit_kondart.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
*     Falls Konditionsart POS-relevant ist.
      IF pit_kondart IS NOT INITIAL.
*       Falls das Maximintervall dieses Konditionssatzes
*       den Betrachtungszeitraum nicht schneidet
*       dann kann der Konditionssatz ignoriert werden.
        IF NOT ls_konh-datab IS INITIAL AND
           NOT ls_konh-datbi IS INITIAL.
          IF ls_konh-datab > piv_datbi OR
             ls_konh-datbi < piv_datab.
            CONTINUE.
          ENDIF. " konh-datab >= pi_datbi or ...
        ENDIF. " not konh-datab is initial and

*"-------KONH has no longer VAKEY, it is determined on the fly to fill KOMG
*       Bestimme zugehörigen Objektschlüssel.
*        CALL FUNCTION 'SD_CONDITION_KOMG_FILL'
*          EXPORTING
*            p_kotabnr = ls_konh-kotabnr
*            p_kvewe   = ls_konh-kvewe
*            p_vakey   = ls_konh-vakey
*          IMPORTING
*            p_komg    = ls_komg.

        CALL METHOD CL_PREPARE_KOMG=>FILL_KOMG_FROM_VAKEY
          EXPORTING
            I_KONH          = ls_konh
          IMPORTING
            E_KOMG          = ls_komg
          EXCEPTIONS
            VAKEY_NOT_FOUND = 1
            others          = 2.

        check sy-subrc = 0.
*       Prüfe, ob diese Kondition filialabhängig ist und wenn ja,
*       ob sie zu der Gruppe gerade bearbeiteter Filialen gehört.
        PERFORM varkey_precheck
                TABLES pit_filia
                USING  ls_komg
                       lv_ignore.

*       Falls diese Konditionsänderung nicht relevant ist, dann
*       weiter zur nächsten Konditionsänderung.
        IF NOT lv_ignore IS INITIAL.
          CONTINUE.
        ENDIF. " not lv_ignore is initial.

*       Bestimme die Intervalle, die zu dieser Konditionsnummer
*       gehören.
        REFRESH: lt_periods.
        ls_validity-datab = piv_datab.
        ls_validity-datbi = piv_datbi.
        CALL FUNCTION 'SD_CONDITION_VALIDITY_PERIODS'
          EXPORTING
            p_konh             = ls_konh
            pi_validity        = ls_validity
            pi_use_import_komg = 'X'
            pi_komg            = ls_komg
          TABLES
            p_tb_val_period    = lt_periods
          EXCEPTIONS
            no_periods_found   = 1
            OTHERS             = 2.

*       Falls Löschungen untersucht werden sollen.
        IF NOT c_check_deletions IS INITIAL.
          READ TABLE lt_periods INDEX 1
                                TRANSPORTING NO FIELDS.

*         Falls eine Löschung gefunden wurde.
          IF sy-subrc <> 0.
*           Falls das Intervall in KONH den Betrachtungszeitraum
*           schneidet.
            ls_period-datab = ls_konh-datab.
            ls_period-datbi = ls_konh-datbi.
            APPEND ls_period TO lt_periods.
            lv_delete = 'X'.
          ENDIF. " sy-subrc <> 0.
        ENDIF. " not c_check_deletions is initial.

*       Schleife über alle Intervalle.
        LOOP AT lt_periods INTO ls_period.
*         Falls das Intervall innerhalb des
*         Betrachtungszeitraums liegt.
          IF ls_period-datab <= piv_datbi AND
             ls_period-datbi >= piv_datab.

*           Falls Aktivierungszeitpunkt in der Vergangenheit liegt,
*           dann setzte ihn auf Beginn 'jetziges Versenden'.
            IF ls_period-datab < piv_datab.
              ls_period-datab = piv_datab.
            ENDIF.                   " LS_PERIOD-DATAB < PIV_DATAB.

*           Besorge die Liste aller Filialen der Filialgruppe
*           PIT_FILIA_GROUP die vom aktuell zu analysierenden
*           Konditionsänderungspointer betroffen sind.
*           Weicht der Vertriebsweg der Filiale vom Vertriebsweg
*           der Kondition ab, dann ist das Feld PET_FILIA-VTWEG
*           gefüllt. In diesem Fall wird der Vertriebsweg
*           der Filiale durch I_KOMG-VTWEG referenziert.
            PERFORM filia_group_check
                    TABLES pit_filia
                           pit_kondart
                           lt_filia_tmp
                    USING  ls_period
                           ls_komg
                           ls_konh.

************************************************************************
*           Funktionsexit für kundeneigene Filtermöglichkeit in der
*           Konditionszeigeranalyse.
            CALL CUSTOMER-FUNCTION '015'
              EXPORTING
                pi_periods       = ls_period
                pi_komg          = ls_komg
                pi_konh          = ls_konh
                pi_wind          = <fwindvb>
                pi_mode          = 'W'
              TABLES
                pit_filia        = pit_filia
                pit_kondart      = pit_kondart
                pxt_filia_filter = lt_filia_tmp[].
************************************************************************

            LOOP AT lt_filia_tmp ASSIGNING <ls_filia_tmp>.
*             Falls Aufbereitung für Additionals.
              IF piv_mode = c_additional_mode AND
                 NOT piv_uexac IS INITIAL.
*               Bestimme die Aktionskonditionsart
                CLEAR: ls_pespr.
                CALL FUNCTION 'SALES_PRICE_COND_TYPE_GET'
                  EXPORTING
                    pi_vkorg                    = piv_vkorg
                    pi_vtweg                    = piv_vtweg
                    pi_werks                    = <ls_filia_tmp>-filia
                  IMPORTING
                    pe_i_spr                    = ls_pespr
                  EXCEPTIONS
                    plant_not_found             = 1
                    org_structure_not_completed = 2
                    vkorg_not_found             = 3
                    no_calculation_type_found   = 4
                    no_condition_types_found    = 5
                    invalid_import              = 6
                    customer_is_no_plant        = 7
                    OTHERS                      = 8.
              ENDIF. " pi_mode = c_additional_mode and ...

*             Besorge die Intervalle aller Konditionstabellen, dieser
*             Konditionsart zu diesem Objekt und analysiere, ob sie
*             filialunabhängige Einträge enthalten sind.
*             Bestimme ferner, ob Referenzvertriebswege
*             berücksichtigt werden müssen.
              PERFORM periods_get_and_analyse
                      TABLES lt_periods_2
                      USING  ls_komg
                             ls_konh
                             <ls_filia_tmp>
                             ls_period
                             piv_datbi
                             lv_delete
                             lv_independence.

*             Parametrisieren des Bis-Datums, je nachdem, ob
*             Aufruf über POS-Schnittstelle oder nicht.
              IF piv_mode = c_pos_mode.
                lv_datum = piv_datbi.
              ELSE. " PIV_MODE <> c_pos_mode
                lv_datum = ls_period-datbi.
              ENDIF. " PIV_MODE = c_pos_mode

*             Besorge das Zusatzflag zur Konditionsart für diese
*             Filiale.
              CLEAR pit_kondart.
              READ TABLE pit_kondart WITH KEY kschl = ls_konh-kschl
                                              locnr = <ls_filia_tmp>-locnr
                                     TRANSPORTING NO FIELDS BINARY SEARCH.
              IF sy-subrc = 0.
                LOOP AT pit_kondart FROM sy-tabix.
                  IF ( pit_kondart-kvewe = ls_konh-kvewe   OR
                       pit_kondart-kvewe = space ).
                    EXIT.
                  ELSEIF pit_kondart-kschl NE ls_konh-kschl  OR
                         pit_kondart-locnr NE <ls_filia_tmp>-locnr.
                    CLEAR pit_kondart.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ENDIF.

              REFRESH: lt_kondart_flag.
              CLEAR:   ls_kondart_flag.
              MOVE-CORRESPONDING pit_kondart TO ls_kondart_flag.
              APPEND ls_kondart_flag TO lt_kondart_flag.

*             Bestimme die zugehörigen Aktivierungszeitpunkte.
              CALL FUNCTION 'POS_CONDITION_INTERVALS_MERGE'
                EXPORTING
                  pi_inc_first_record = 'X'
                  pi_kotabnr          = ls_konh-kotabnr
                  pi_datab            = ls_period-datab
                  pi_datbi            = lv_datum
* ### später vielleicht pi_applikation      = ls_konh-kappl
* aktivieren
*###  ???               pi_verwendung       = ls_konh-kvewe
                TABLES
                  pit_periods         = lt_periods_2[]
                  pit_kondart         = lt_kondart_flag[]
                  pet_datab           = lt_datab[].

              LOOP AT lt_datab ASSIGNING <ls_datab>.
*               Falls Aufbereitung für Additionals.
                IF piv_mode = c_additional_mode.
*                 Falls eine Aktionskonditionsänderung vorliegt.
                  IF ls_konh-kschl = ls_pespr-aksch.
                    ls_artstm_objects-aktion ='X'.
                  ENDIF. " ls_konh-kschl = ls_pespr-aksch.
                ENDIF. " piv_mode = c_additional_mode.

                ls_artstm_objects-filia = <ls_filia_tmp>-filia.
                ls_artstm_objects-artnr = ls_komg-matnr.

*               Merken, das der Pointer aufgrund einer
*               Konditionsänderung erzeugt wurde.
                ls_artstm_objects-aetyp_sort = c_cond_sort_index.

*               Besorge die MARA-Daten des Artikels.
                PERFORM mara_select
                        USING  ls_mara  ls_komg-matnr.

* ### Variante kann Preismaterial sein.
*               Falls es sich um einen Sammelartikel handelt.
*               oder um eine Variante handelt.
                IF ls_mara-attyp = c_sammelartikel   OR
                   ls_mara-attyp = c_variante.
                  ls_artstm_objects-attyp = ls_mara-attyp.
                ENDIF. " ls_mara-attyp = c_sammelartikel or ...

*               Besorge alle Verkaufsmengeneinheiten, auf
*               die sich diese Konditionsänderung bezieht.
                PERFORM vrkme_get
                        TABLES lt_short_marm
                        USING  ls_komg.

*               Schleife über alle aufzubereitenden VRKME's
                LOOP AT lt_short_marm ASSIGNING <ls_short_marm>.
*                 Fülle Objekttabelle 1 (filialabhängig).
                  ls_artstm_objects-vrkme = <ls_short_marm>-meinh.

                  ls_artstm_objects-datum = <ls_datab>-datab.
************************************************************************
* Eventuell USER-Exit zum Füllen von PXT_ARTSTM_OBJECTS
* Input:  Feldleiste LS_ARTSTM_OBJECTS
*         Feldleiste LS_KOMG
*         Feldleiste LS_KONH (eventuell)
*         PIV_MODE (eventuell)
* Output: Feldleiste LS_ARTSTM_OBJECTS
* Funktion: Vervollständig die Feldleiste LS_ARTSTM_OBJECTS
************************************************************************

*                 Falls sich der Aktivierungszeitpunkt mit dem
*                 letzten Versenden schneidet.
                  IF <ls_datab>-datab < piv_datp3.
                    ls_artstm_objects-init = 'X'.
                  ELSE. " <ls_datab>-datab >= piv_datp3.
                    CLEAR: ls_artstm_objects-init.
                  ENDIF.               " <LS_DATAB>-DATAB < PIV_DATP3.

*                 Fülle Zusatztabelle für Bestellbuch.
                  CLEAR: ls_bb_obj, ls_bb_obj_2.
                  MOVE-CORRESPONDING ls_artstm_objects
                                     TO ls_bb_obj.
                  ls_bb_obj-vkorg   = ls_komg-vkorg.
                  ls_bb_obj-pltyp   = ls_komg-pltyp.
                  ls_bb_obj-waerk   = ls_komg-waerk.
                  ls_bb_obj-kunnr   = ls_komg-kunnr.
*                  pet_bb_obj-cretime = pit_wind-cretime.
                  ls_bb_obj-cretime = <fwindvb>-cretime. "HFE,14.04.04
                  ls_bb_obj-attyp   = ls_mara-attyp.
                  ls_bb_obj-bbtyp   = ls_mara-bbtyp.

*                 Falls der Vertriebsweg dieser Filiale durch
*                 LS_KOMG-VTWEG referenziert wird, dann übernehme
*                 ihn in Ausgabetabelle.
                  IF NOT <ls_filia_tmp>-vtweg IS INITIAL.
                    ls_bb_obj-vtweg = <ls_filia_tmp>-vtweg.

*                 Falls der Vertriebsweg dieser Filiale nicht durch
*                 LS_KOMG-VTWEG referenziert wird, dann übernehme
*                 LS_KOMG-VTWEG in Ausgabetabelle.
                  ELSE. " if <ls_filia_tmp>-vtweg is initial.
                    ls_bb_obj-vtweg = ls_komg-vtweg.
                  ENDIF. " not <ls_filia_tmp>-vtweg is initial.

*                 Falls Filialabhängigkeit vorliegt.
                  IF lv_independence = space.
*                     Prüfe, ob die Änderung bereits gespeichert
*                     wurde.
                    READ TABLE pxt_artstm_objects WITH KEY
                         filia  = ls_artstm_objects-filia
                         artnr  = ls_artstm_objects-artnr
                         vrkme  = ls_artstm_objects-vrkme
                         datum  = ls_artstm_objects-datum
                         init   = ls_artstm_objects-init
                         attyp  = ls_artstm_objects-attyp
                         aktion = ls_artstm_objects-aktion
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.

*                     Falls die Änderung bereits gespeichert wurde.
                    IF sy-subrc <> 0.
                      lv_tabix = sy-tabix.

*                       Übernehme die Daten in filialabhängige
*                       Ausgabetabellen.
                      INSERT ls_artstm_objects INTO pxt_artstm_objects INDEX lv_tabix.
                      APPEND ls_bb_obj TO pxt_bb_obj.
                    ENDIF.           " sy-subrc <> 0.

*                 Falls Filialunabhängigkeit vorliegt.
                  ELSE. " lv_independence <> space.
*                   Prüfe, ob die Änderung bereits gespeichert
*                   wurde.
                    READ TABLE pxt_artstm_objects_2 WITH KEY
                         artnr  = ls_artstm_objects-artnr
                         vrkme  = ls_artstm_objects-vrkme
                         datum  = ls_artstm_objects-datum
                         init   = ls_artstm_objects-init
                         attyp  = ls_artstm_objects-attyp
                         aktion = ls_artstm_objects-aktion
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.

*                   Falls die Änderung bereits gespeichert wurde.
                    IF sy-subrc <> 0.
                      lv_tabix = sy-tabix.

*                     Übernehme die Daten in filialunabhängige
*                     Ausgabetabellen.
                      CLEAR: ls_artstm_objects_2.
                      MOVE-CORRESPONDING ls_artstm_objects TO
                                         ls_artstm_objects_2.

                      INSERT ls_artstm_objects_2 INTO pxt_artstm_objects_2 INDEX lv_tabix.
                    ENDIF. " sy-subrc <> 0.

                    MOVE-CORRESPONDING ls_bb_obj TO ls_bb_obj_2.
                    APPEND ls_bb_obj_2 TO pxt_bb_obj_2.
                  ENDIF. " lv_independence = space.
                ENDLOOP. " at lt_short_marm.
              ENDLOOP.               " AT LT_DATAB.
            ENDLOOP.                 " AT LT_FILIA_TMP
          ENDIF. " LS_PERIOD-DATAB <= PIV_DATBI AND ...
        ENDLOOP.                     " AT LT_PERIODS.
      ENDIF.                         " PIT_KONDART not initial   POS-Kon.art
    ENDIF.   " SY-SUBRC = 0 and ls_konh-kvewe = c_cond_vewe, KONH-Select
  ENDLOOP.                           " at pit_wind.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_package_size_2
*&---------------------------------------------------------------------*
* This form computes the maximum package size for the DB table buffering.
* It is a new version of sub routine GET_PACKAGE_SIZE in which the mode
* is transferred via an using parameter.
*----------------------------------------------------------------------*
*      -->iv_mode
*      <--ov_package_size
*----------------------------------------------------------------------*
FORM get_package_size_2 USING    iv_mode TYPE wjdposmode
                        CHANGING ov_package_size.
*--- the package size shall be the maximum of the Idoc-sizing for
*--- PLU and EAN:
*--- additionally, a BAdI-method can be processed to overwrite the
*--- calculated value:
  DATA lo_badi TYPE REF TO badi_wpos_outbound_pckg_size.
  DATA lv_new_package_size TYPE pos_max_idoc_size.

  MOVE c_max_idoc_plu TO ov_package_size.
  IF ov_package_size <  c_max_idoc_ean.
    MOVE c_max_idoc_ean TO ov_package_size.
  ENDIF.

*--- the minimum package size is always 5000
  IF ov_package_size < 5000.
    ov_package_size = 5000.
  ENDIF.

*--- get the BAdI-Instance and call the BAdI:
  TRY.
      GET BADI lo_badi
        FILTERS
          pos_mode = iv_mode.

      lv_new_package_size = ov_package_size.

      CALL BADI lo_badi->set_package_size
        CHANGING
          cv_package_size = lv_new_package_size.

      IF lv_new_package_size > 0.
        ov_package_size = lv_new_package_size.
      ENDIF.
    CATCH cx_badi_not_implemented   ##no_handler.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form get_cond_data_from_buffer
*&---------------------------------------------------------------------*
* This form reads the condition data of a material out of a buffer at
* first. If the buffer does not contain the relevant data, the condition
* data are determined by calling sub routine MATCOND_GET. Afterwards the
* buffer is filled with the found data.
* Consider:
*  - this sub routine may only be called if the customizing flag
*    "WPFILCONST-TAXES_COPY" is switched on.
*  - if an article has not a price article, then article and price article
*    are equal.
*  - below, only the new parameters (compared with the sub routine
*    MATCOND_GET) are listed:
*----------------------------------------------------------------------*
*      -->pi_package_size
*      -->pi_pmatn
*      <->ptx_mat_vrkme_cond
*----------------------------------------------------------------------*
FORM get_cond_data_from_buffer
             TABLES   pet_kond               STRUCTURE gt_kond_art
                      pet_staffeln           STRUCTURE gt_staff_art
                      pet_artsteu            STRUCTURE gt_artsteu
             USING    pi_filia_const         TYPE wpfilconst
                      pi_filia               TYPE werks_d
                      pi_artnr               TYPE matnr
                      pi_vrkme               TYPE vrkme
                      pi_datab               TYPE syst-datum
                      pi_datbi               TYPE syst-datum
                      pi_vkorg               TYPE vkorg
                      pi_vtweg               TYPE vtweg
                      pi_mode                TYPE wjdposmode
                      pi_package_size        TYPE pos_max_idoc_size
                      pi_pmatn               TYPE pmatn
             CHANGING ptx_mat_vrkme_cond   TYPE cl_pos_types=>stty_mat_vrkme_cond.

  STATICS s_last_mat_vrkme_cond TYPE cl_pos_types=>sty_mat_vrkme_cond.
  STATICS sv_filia              TYPE werks_d.

  DATA lv_do_refresh TYPE abap_bool.

*--- initialize result parameter:
  REFRESH: pet_kond, pet_artsteu, pet_staffeln.
  CLEAR:   pet_kond, pet_artsteu, pet_staffeln.

  IF pi_filia_const-prices_siteindep = abap_false.
*--- prices can exist on store level; therefore the buffer is reset if the
*--- store is changed:
    IF pi_filia <> sv_filia AND pi_filia IS NOT INITIAL.
      IF ptx_mat_vrkme_cond IS NOT INITIAL.
        CLEAR ptx_mat_vrkme_cond.
      ENDIF.
      CLEAR s_last_mat_vrkme_cond.
      MOVE pi_filia TO sv_filia.
    ENDIF.
  ENDIF.

  IF s_last_mat_vrkme_cond IS NOT INITIAL.
*--- check if the last found entry still fits:
    IF s_last_mat_vrkme_cond-matnr = pi_pmatn AND
       s_last_mat_vrkme_cond-vrkme = pi_vrkme.
      pet_kond[]     = s_last_mat_vrkme_cond-t_kond.
      pet_staffeln[] = s_last_mat_vrkme_cond-t_scales.
      pet_artsteu[]  = s_last_mat_vrkme_cond-t_taxcd.
*--- leave the sub routine:
      RETURN.
    ENDIF.
  ENDIF.

*--- try to find the condition data in the buffer; the search
*--- is done with the price material (because we would like to
*--- find the condition data which belong to the price material):
  READ TABLE ptx_mat_vrkme_cond INTO s_last_mat_vrkme_cond
             WITH TABLE KEY matnr = pi_pmatn
                            vrkme = pi_vrkme.
  IF sy-subrc = 0.
*--- data found:
    pet_kond[]     = s_last_mat_vrkme_cond-t_kond.
    pet_staffeln[] = s_last_mat_vrkme_cond-t_scales.
    pet_artsteu[]  = s_last_mat_vrkme_cond-t_taxcd.
  ELSE.
*--- no entry found; determine the condition data...
    PERFORM matcond_get
            TABLES pet_kond
                   pet_staffeln
                   pet_artsteu
            USING  pi_filia_const
                   pi_filia
                   pi_pmatn
                   pi_vrkme
                   pi_datab
                   pi_datbi
                   pi_vkorg
                   pi_vtweg
                   pi_mode.

*--- ... and store them in the buffer (the data are stored with the
*--- price material):
    IF lines( ptx_mat_vrkme_cond ) >= pi_package_size.
*--- refresh the buffer if its size will be bigger than the package size:
      CLEAR ptx_mat_vrkme_cond.
    ENDIF.
    s_last_mat_vrkme_cond-matnr = pi_pmatn.
    s_last_mat_vrkme_cond-vrkme = pi_vrkme.
    s_last_mat_vrkme_cond-t_kond = pet_kond[].
    s_last_mat_vrkme_cond-t_scales = pet_staffeln[].
    s_last_mat_vrkme_cond-t_taxcd = pet_artsteu[].
    INSERT s_last_mat_vrkme_cond INTO TABLE ptx_mat_vrkme_cond.
  ENDIF.

ENDFORM.
