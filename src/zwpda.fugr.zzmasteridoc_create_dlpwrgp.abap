FUNCTION ZZMASTERIDOC_CREATE_DLPWRGP.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_AKTIVDAT) LIKE  WPSTRUC-DATUM
*"     VALUE(PI_BASE_MATKL) LIKE  WWG02 STRUCTURE  WWG02
*"     VALUE(PI_DEBUG) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PX_DLDLFDNR) LIKE  WDLSP-LFDNR
*"     VALUE(PI_DLDNR) LIKE  WDLS-DLDNR
*"     VALUE(PI_EXPRESS) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_VTWEG) LIKE  WPSTRUC-VTWEG
*"     VALUE(PI_VKORG) LIKE  WPSTRUC-VKORG
*"     VALUE(PI_FILIA) LIKE  T001W-WERKS
*"     VALUE(PI_LOESCHEN) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_E1WPW02) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_E1WPW05) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PI_E1WPW03) LIKE  WPSTRUC-MODUS DEFAULT ' '
*"     VALUE(PX_SEGMENT_COUNTER) LIKE  WDLSP-ANSEG
*"     VALUE(PI_FILIA_CONST) LIKE  WPFILCONST STRUCTURE  WPFILCONST
*"     VALUE(PI_MESTYPE) LIKE  EDIMSG-MESTYP DEFAULT 'WPDWGR'
*"  EXPORTING
*"     VALUE(PX_SEGMENT_COUNTER) LIKE  WDLSP-ANSEG
*"  CHANGING
*"     REFERENCE(PXT_IDOC_DATA) TYPE  SHORT_EDIDD
*"  EXCEPTIONS
*"      DOWNLOAD_EXIT
*"--------------------------------------------------------------------
  DATA: FEHLERCODE    LIKE SY-SUBRC,
        E1WPW05_CNT   TYPE I,
        E1WPW03_CNT   TYPE I,
        SEG_LOCAL_CNT TYPE I.

  CLEAR: FEHLERCODE.

* Falls Steuerkennzeichen übertragen werdn sollen.
  IF PI_E1WPW05 <> SPACE.
*   Falls kein Warengruppenwertartikel definiert wurde und kein
*   Löschmodus aktiv ist, dann schreibe diesbezüglich einen Hinweis.
    IF PI_BASE_MATKL-WWGPA = SPACE AND PI_LOESCHEN = SPACE.
*     Falls Fehlerprotokollierung erwünscht.
      IF PI_FILIA_CONST-ERMOD = SPACE.
*       Falls noch keine Initialisierung des Fehlerprotokolls.
        IF G_INIT_LOG = SPACE.
*         Aufbereitung der Parameter zum schreiben des Headers des
*         Fehlerprotokolls.
          CLEAR: GI_ERRORMSG_HEADER.
          GI_ERRORMSG_HEADER-OBJECT        = C_APPLIKATION.
          GI_ERRORMSG_HEADER-SUBOBJECT     = C_SUBOBJECT.
          GI_ERRORMSG_HEADER-EXTNUMBER     = PI_DLDNR.
          GI_ERRORMSG_HEADER-EXTNUMBER+14  = PX_DLDLFDNR.
          GI_ERRORMSG_HEADER-ALUSER        = SY-UNAME.

*         Initialisiere Fehlerprotokoll und erzeuge Header.
          PERFORM APPL_LOG_INIT_WITH_HEADER  USING GI_ERRORMSG_HEADER.

*         Merke, daß Fehlerprotokoll initialisiert wurde.
          G_INIT_LOG = 'X'.
        ENDIF.                           " G_INIT_LOG = SPACE.

*       Bereite Parameter zum schreiben der Fehlerzeile auf.
        CLEAR: GI_MESSAGE.
        GI_MESSAGE-MSGTY     = C_MSGTP_WARNING.
        GI_MESSAGE-MSGID     = C_MESSAGE_ID.
        GI_MESSAGE-PROBCLASS = C_PROBCLASS_WENIGER_WICHTIG.
*       'Zur Warengruppe & wurde kein Warengruppenwertartikel
*       definiert'.
        GI_MESSAGE-MSGNO     = '152'.
        GI_MESSAGE-MSGV1     = PI_BASE_MATKL-MATKL.

*       Schreibe Fehlerzeile für Application-Log und WDLSO.
        CLEAR: G_OBJECT_KEY.
        PERFORM APPL_LOG_WRITE_SINGLE_MESSAGE USING  GI_MESSAGE.

      ENDIF.                             " pi_filia_const-ermod = space.

*     Ändern der Status-Kopfzeile, falls nötig.
      IF G_STATUS < 2.                   " 'Benutzerhinweis'.
        CLEAR: GI_STATUS_HEADER.
        GI_STATUS_HEADER-DLDNR = PI_DLDNR.
        GI_STATUS_HEADER-GESST = C_STATUS_BENUTZERHINWEIS.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        PERFORM STATUS_WRITE_HEAD USING  'X'  GI_STATUS_HEADER
                                         PI_DLDNR   G_RETURNCODE.
*       Aktualisiere Aufbereitungsstatus.
        G_STATUS = 2.                    " 'Benutzerhinweis'.
      ENDIF. " g_status < 2.                   " 'Benutzerhinweis'.

*     Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
      CLEAR: GI_STATUS_POS.
      GI_STATUS_POS-DLDNR  = PI_DLDNR.
      GI_STATUS_POS-LFDNR  = PX_DLDLFDNR.
      GI_STATUS_POS-ANLOZ  = G_ERR_COUNTER.
      GI_STATUS_POS-ANSEG  = PX_SEGMENT_COUNTER.
      GI_STATUS_POS-STKEY  = G_FIRSTKEY.
      GI_STATUS_POS-LTKEY  = PI_BASE_MATKL-MATKL.

*     Aktualisiere Aufbereitungsstatus für Positionszeile,
*     falls nötig.
      IF G_STATUS_POS <  2.                   " 'Benutzerhinweis'
        GI_STATUS_POS-GESST = C_STATUS_BENUTZERHINWEIS.

        G_STATUS_POS = 2.                    " 'Benutzerhinweis'.
      ENDIF. " g_status_pos <  2.                   " 'Benutzerhinweis'

*     Schreibe Status-Positionszeile.
      PERFORM STATUS_WRITE_POS USING 'X' GI_STATUS_POS  PX_DLDLFDNR
                                         G_RETURNCODE.

    ENDIF. " PI_BASE_MATKL-WWGPA = SPACE...
  ENDIF. " pi_e1wpw05 <> space.

* Falls eine neue Status-Positionszeile geschrieben werden muß.
  IF G_NEW_POSITION <> SPACE.
    CLEAR: G_NEW_POSITION.

*   Aufbereiten der Parameter zum schreiben der
*   Status-Positionszeile.
    CLEAR: GI_STATUS_POS.
    GI_STATUS_POS-DLDNR  = PI_DLDNR.
    GI_STATUS_POS-DOCTYP = C_IDOCTYPE_WRGP.

*   Schreibe Status-Positionszeile.
    PERFORM STATUS_WRITE_POS USING ' ' GI_STATUS_POS  PX_DLDLFDNR
                                       G_RETURNCODE.

    G_DLDLFDNR = PX_DLDLFDNR.

*   Merke neuen 'Firstkey'.
    G_FIRSTKEY = PI_BASE_MATKL-MATKL.
  ENDIF. " g_new_position <> space.

* Falls Löschmodus aktiv, dann müssen keine Hierarchiestufen gelesen
* werden.
  IF PI_LOESCHEN <> SPACE.
    REFRESH: GT_WRGP_DATA.
    CLEAR:   GT_WRGP_DATA.
    GT_WRGP_DATA-MATKL = PI_BASE_MATKL-MATKL.
    APPEND GT_WRGP_DATA.

* Falls Löschmodus nicht aktiv ist.
  ELSE. " pi_loeschen = space.
*   Einlesen aller übergeordneten Warengruppen und Steuern.
    PERFORM ARTICLE_GROUP_READ TABLES   GT_WRGP_DATA
                                        GT_WRGP_MWSKZ
                               USING    PI_FILIA_CONST-SPRAS
                                        PI_VKORG
                                        PI_VTWEG  PI_FILIA  PI_AKTIVDAT
                               CHANGING G_RETURNCODE
                                        PI_DLDNR    PX_DLDLFDNR
                                        PI_BASE_MATKL-MATKL
                                        PI_BASE_MATKL-WWGPA
                                        PI_FILIA_CONST-ERMOD
                                        PI_BASE_MATKL-WGBEZ
                                        PX_SEGMENT_COUNTER
                                        PI_E1WPW05.

*   Verlassen der Aufbereitung dieser Basiswrgp., falls Einlesefehler.
    IF G_RETURNCODE <> 0.
      EXIT.
    ENDIF.                               " G_RETURNCODE <> 0.
  ENDIF. " pi_loeschen <> space.

* Schleife über alle Warengruppenhierarchien.
  LOOP AT GT_WRGP_DATA.
*   Rücksetze Temporärtabelle für IDOC-Daten.
    REFRESH: GT_IDOC_DATA_TEMP.

*   Rücksetze temporären Segmentzähler.
    CLEAR: SEG_LOCAL_CNT.

*   Aufbau ID-Segment.
    CLEAR: E1WPW01.
    E1WPW01-FILIALE    = PI_FILIA_CONST-KUNNR.
    E1WPW01-AKTIVDATUM = PI_AKTIVDAT.
    E1WPW01-AENDDATUM  = '00000000'.
    E1WPW01-AENDERER   = ' '.
    E1WPW01-WARENGR    = GT_WRGP_DATA-MATKL.

    IF PI_LOESCHEN <> SPACE.
      E1WPW01-AENDKENNZ  = C_DELETE.
    ELSE.
      E1WPW01-AENDKENNZ  = C_MODI.
    ENDIF.                             " PI_LOESCHEN <> SPACE.

*   Erzeuge temporären IDOC-Segmentsatz.
    GT_IDOC_DATA_TEMP-SEGNAM = C_E1WPW01_NAME.
    GT_IDOC_DATA_TEMP-SDATA  = E1WPW01.
    APPEND GT_IDOC_DATA_TEMP.

*   aktualisiere Segmentzähler.
    ADD 1 TO SEG_LOCAL_CNT.

*   Es müssen Stammdaten übertragen werden.
    IF PI_LOESCHEN = SPACE.
*     Aufbau Stammdaten-Segment.
      IF PI_E1WPW02 <> SPACE.
        CLEAR: E1WPW02.
        E1WPW02-BEZEICH     = GT_WRGP_DATA-WGBEZ.
        E1WPW02-VERKNUEPFG  = GT_WRGP_DATA-VERKNUEPFG.
        E1WPW02-HIERARCHIE  = GT_WRGP_DATA-HIERARCHIE.

*       Erzeuge temporären IDOC-Segmentsatz.
        GT_IDOC_DATA_TEMP-SEGNAM = C_E1WPW02_NAME.
        GT_IDOC_DATA_TEMP-SDATA  = E1WPW02.
        APPEND GT_IDOC_DATA_TEMP.

*       aktualisiere Segmentzähler.
        ADD 1 TO SEG_LOCAL_CNT.
      ENDIF.                           " PI_E1WPW02 <> SPACE.

*     Es müssen Konditionen übertragen werden.
      IF PI_E1WPW03 <> SPACE.
************************************************************************
*     Aufbau Konditions-Segmente. (Noch nicht für Rel. 3.0)
************************************************************************
      ENDIF.                           " PI_E1WPW03 <> SPACE.

*     Falls Segment E1WPW05 (Warengruppen-Steuern)
*     gefüllt werden muß und ein Warengruppenwertartikel zur
*     Steuerfindung vorhanden ist.
      IF PI_E1WPW05 <> SPACE AND PI_BASE_MATKL-WWGPA <> SPACE.
*       Nur für die Basiswarengruppe dürfen Steuern übertragen werden.
        IF GT_WRGP_DATA-HIERARCHIE = 0.
*         Fülle Segment E1WPW05.
          CLEAR: E1WPW05, E1WPW05_CNT.

*         Aufbau Steuer-Segment.
          LOOP AT GT_WRGP_MWSKZ.
*           Aktualisiere Zähler für Warengruppen-Steuern.
            ADD 1 TO E1WPW05_CNT.

            E1WPW05-MWSKZ = GT_WRGP_MWSKZ-MWSK1.

*           Erzeuge temporären IDOC-Segmentsatz.
            GT_IDOC_DATA_TEMP-SEGNAM = C_E1WPW05_NAME.
            GT_IDOC_DATA_TEMP-SDATA  = E1WPW05.
            APPEND GT_IDOC_DATA_TEMP.

*           aktualisiere Segmentzähler.
            ADD 1 TO SEG_LOCAL_CNT.

          ENDLOOP.                       " AT GT_WRGP_MWSKZ
        ENDIF. " GT_WRGP_DATA-HIERARCHIE = 0.

      ENDIF.    " pi_e1wpw05 <> space and pi_base_matkl-wwgpa <> space.
    ENDIF.                             " PI_LOESCHEN = SPACE.

*********************************************************************
***********************   U S E R - E X I T  ************************
    CALL CUSTOMER-FUNCTION '001'
         EXPORTING
              PI_E1WPW05_CNT     = E1WPW05_CNT
              PI_E1WPW03_CNT     = E1WPW03_CNT
              PX_SEGMENT_COUNTER = PX_SEGMENT_COUNTER
              PI_SEG_LOCAL_CNT   = SEG_LOCAL_CNT
              PI_DLDNR           = PI_DLDNR
              PI_DLDLFDNR        = PX_DLDLFDNR
              PI_ERMOD           = PI_FILIA_CONST-ERMOD
              PI_FIRSTKEY        = G_FIRSTKEY
              PX_INIT_LOG        = G_INIT_LOG
              PX_STATUS          = G_STATUS
              PX_STATUS_POS      = G_STATUS_POS
              PX_ERR_COUNTER     = G_ERR_COUNTER
              PI_FILIA_CONST     = PI_FILIA_CONST
         IMPORTING
              PX_INIT_LOG        = G_INIT_LOG
              PX_STATUS          = G_STATUS
              PX_STATUS_POS      = G_STATUS_POS
              PE_FEHLERCODE      = FEHLERCODE
              PX_ERR_COUNTER     = G_ERR_COUNTER
              PI_SEG_LOCAL_CNT   = SEG_LOCAL_CNT
         TABLES
              PXT_IDOC_DATA_TEMP = GT_IDOC_DATA_TEMP
              PIT_IDOC_DATA      = gt_idoc_data_dummy
         changing
              PIT_IDOC_DATA_new  = PXT_IDOC_DATA.

*   Falls Umsetzfehler auftraten.
    IF FEHLERCODE <> 0.
*     Falls Fehlerprotokollierung erwünscht.
      IF PI_FILIA_CONST-ERMOD = SPACE.
*       Fülle allgemeinen Objektschlüssel.
        G_OBJECT_KEY = GT_WRGP_DATA-MATKL.

*       Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
        PERFORM ERROR_OBJECT_WRITE.

*       Verlassen der Aufbereitung dieser Basiswarengruppe.
        EXIT.
*     Falls Abbruch bei Fehler erwünscht.
      ELSE.                        " pi_filia_const-ermod <> space.
*       Abbruch des Downloads.
        RAISE DOWNLOAD_EXIT.
      ENDIF.                       " pi_filia_const-ermod = space.

*   Falls Umschlüsselung fehlerfrei.
    ELSE. " FEHLERCODE = 0.
*     Übernehme die IDOC-Daten aus Temporärtabelle.
      PERFORM IDOC_DATA_ASSUME TABLES  GT_IDOC_DATA_TEMP
                               USING   PXT_IDOC_DATA
                                       PX_SEGMENT_COUNTER
                                       SEG_LOCAL_CNT.

    ENDIF.                             " FEHLERCODE <> 0.

*********************************************************************

*   Aktualisiere Status-Positionszeile, falls Debug-Modus ein.
    IF PI_DEBUG <> SPACE.
*     Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
      CLEAR: GI_STATUS_POS.
      GI_STATUS_POS-DLDNR  = PI_DLDNR.
      GI_STATUS_POS-LFDNR  = PX_DLDLFDNR.
      GI_STATUS_POS-STKEY  = G_FIRSTKEY.
      GI_STATUS_POS-LTKEY  = GT_WRGP_DATA-MATKL.
      GI_STATUS_POS-ANSEG  = PX_SEGMENT_COUNTER.

*     Schreibe Status-Positionszeile.
      PERFORM STATUS_WRITE_POS USING 'X' GI_STATUS_POS  PX_DLDLFDNR
                                         G_RETURNCODE.

*     Schreibe DB-Änderungen fort.
      COMMIT WORK.
    ENDIF.                             " PI_DEBUG <> SPACE.

  ENDLOOP.                             " AT GT_WRGP_DATA

* check if IDoc must be created based on user
* specific setting
  IF PX_SEGMENT_COUNTER >= C_MAX_IDOC_WGR .
*   Erzeuge IDOC.
    PERFORM IDOC_CREATE using  PXT_IDOC_DATA
                               PI_MESTYPE
                               C_IDOCTYPE_WRGP
                               PX_SEGMENT_COUNTER
                               G_ERR_COUNTER
                               G_FIRSTKEY
                               PI_BASE_MATKL-MATKL
                               PI_DLDNR     PX_DLDLFDNR
                               PI_FILIA
                               PI_FILIA_CONST.

*   Merken, daß neue Positionszeile geschrieben werden muß.
    G_NEW_POSITION = 'X'.
  ENDIF.


ENDFUNCTION.
