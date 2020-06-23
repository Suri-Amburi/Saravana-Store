*-------------------------------------------------------------------
***INCLUDE LWPDAF08 .
*-------------------------------------------------------------------
* FORM-Routinen für Download Steuern.
************************************************************************


************************************************************************
FORM STEUERN_DOWNLOAD
     TABLES PIT_FILTER_SEGS STRUCTURE GT_FILTER_SEGS
     USING  PI_FILIA        LIKE WPFILIA-FILIA
            PI_EXPRESS      LIKE WPSTRUC-MODUS
            PI_LOESCHEN     LIKE WPSTRUC-MODUS
            PI_MODE         LIKE WPSTRUC-MODUS
            PI_DATUM_AB     LIKE WPSTRUC-DATUM
            PI_FILIA_CONST  LIKE GI_FILIA_CONST
*           pi_fabkl        like t001w-fabkl
*           pi_ermod        like twpfi-ermod
*           pi_kunnr        like t001w-kunnr
*           pi_land1        like t001w-land1
*           pi_spras        like t001w-spras
            PI_DLDNR        LIKE WDLS-DLDNR
            PI_ERSTDAT      LIKE SYST-DATUM.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads des Steuern.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS: Liste aller für den POS-Download nicht benötigten
*                  Segmente.
* PI_FILIA       : Filiale, an die verschickt werden soll.
*
* PI_EXPRESS     := 'X', wenn sofort versendet werden soll, sonst SPACE.
*
* PI_LOESCHEN    : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                     sollen, sonst SPACE.
* PI_MODE        : 'I': Init, 'A' = direkte Anf., 'U': Änderungsfall,
*                  'R': Restartfall.
* PI_DATUM_AB    : Beginn des Betrachtungszeitraums.
*
* PI_FILIA_CONST : Filialkonstanten.
*
**PI_FABKL       : Fabrikkalender der Filiale.
*
**PI_ERMOD       : = 'X', wenn Downloadabbruch bei Fehler erwünscht.
*
**PI_KUNNR       : Kundennummer.
*
**PI_LAND1       : Länderkennzeichen.
*
**PI_SPRAS       : Sprachenschlüssel.
*
* PI_DLDNR       : Downloadnummer der Status-Kopfzeile.
*
* PI_ERSTDAT     : Beginndatum des Downloads.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: E1WPT01 VALUE 'X', " Flag, ob Segm. E1WPT01 vers. werden muß
        E1WPT02 VALUE 'X',
        H_DATUM LIKE SY-DATUM.


* Übernehme den aktuellen Nachrichtentyp in globale Variable.
  G_CURRENT_DOCTYPE = C_IDOCTYPE_STEU.

* Prüfe, welche Artikelstammsegmente versendet werden müssen
  LOOP AT PIT_FILTER_SEGS.

    CASE PIT_FILTER_SEGS-SEGTYP.
      WHEN C_E1WPT01_NAME.
        CLEAR: E1WPT01.
      WHEN C_E1WPT02_NAME.
        CLEAR: E1WPT02.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " PIT_FILTER_SEGS

* Es müssen Steuern versendet werden.
  IF E1WPT01 <> SPACE.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: G_SEGMENT_COUNTER, G_NEW_POSITION, G_STATUS_POS.

    IF PI_DATUM_AB IS INITIAL.
      G_AKTIVDAT = PI_ERSTDAT.
    ELSE.
      G_AKTIVDAT = PI_DATUM_AB.
    ENDIF.                             " PI_DATUM_AB = '00000000'.

*   Falls ein Fabrikkalender existiert.
    IF PI_FILIA_CONST-FABKL <> SPACE.
*     Besorge das Datum des Versendetages über Fabrikkalender.
      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
           EXPORTING
                CORRECT_OPTION             = C_VORZEICHEN
                DATE                       = G_AKTIVDAT
                FACTORY_CALENDAR_ID        = PI_FILIA_CONST-FABKL
           IMPORTING
                DATE                       = H_DATUM
           EXCEPTIONS
                DATE_AFTER_RANGE           = 01
                DATE_BEFORE_RANGE          = 02
                DATE_INVALID               = 03
                FACTORY_CALENDAR_NOT_FOUND = 04.

      IF SY-SUBRC = 0.
        G_AKTIVDAT = H_DATUM.
      ENDIF.                           " SY-SUBRC = 0.
    ENDIF.                             " PI_FABKL <> SPACE.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: GI_STATUS_POS.
    GI_STATUS_POS-DLDNR  = PI_DLDNR.
    GI_STATUS_POS-DOCTYP = C_IDOCTYPE_STEU.

*   Fall Restart-Modus.
    IF PI_MODE = C_RESTART_MODE.
      GI_STATUS_POS-RSPOS  = 'X'.
    ENDIF. " pi_mode = c_restart_mode.

*   Schreibe Status-Positionszeile.
    PERFORM STATUS_WRITE_POS USING ' ' GI_STATUS_POS  G_DLDLFDNR
                                       G_RETURNCODE.

*   Rücksetzen Fehler-Zähler.
    CLEAR: G_ERR_COUNTER.

*   Besorge Steuern und bereite IDOC auf.
    CALL FUNCTION 'MASTERIDOC_CREATE_DLPSTEUERN'
         EXPORTING
*###          pi_ermod           = pi_filia_const-ermod
              PI_DLDNR           = PI_DLDNR
              PI_DLDLFDNR        = G_DLDLFDNR
              PI_FILIA           = PI_FILIA
*             pi_kunnr           = pi_filia_const-kunnr
*             pi_land1           = pi_filia_const-land1
              PI_AKTIVDAT        = G_AKTIVDAT
              PI_EXPRESS         = PI_EXPRESS
              PI_LOESCHEN        = PI_LOESCHEN
              PI_E1WPT02         = E1WPT02
*             pi_spras           = pi_filia_const-spras
              PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
              PI_FILIA_CONST     = PI_FILIA_CONST
         IMPORTING
              PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
         changing
              PXT_IDOC_DATA      = GT_IDOC_DATA
         EXCEPTIONS
              DOWNLOAD_EXIT      = 1.

*   Es sind Fehler beim Download aufgetreten'
    IF SY-SUBRC = 1.
*     Falls Initialisierungsfall, direkte Anforderung oder Restart.
      IF PI_MODE <> C_CHANGE_MODE.
        RAISE DOWNLOAD_EXIT.
*     Falls Änderungsfall.
      ELSE.
        RAISE ERROR_CODE_1.
      ENDIF. " pi_mode <> c_change_mode.
    ENDIF.                             " SY-SUBRC = 1.

*   Erzeuge letztes IDOC, falls nötig.
    IF G_SEGMENT_COUNTER > 0.
      PERFORM IDOC_CREATE USING  GT_IDOC_DATA
                                 G_MESTYPE_STEU
                                 C_IDOCTYPE_STEU
                                 G_SEGMENT_COUNTER
                                 G_ERR_COUNTER
                                 G_FIRSTKEY            " 'Firstkey'
                                 GT_STEUERN_DATA-MWSKZ " 'Lastkey'
                                 PI_DLDNR    G_DLDLFDNR
                                 PI_FILIA
                                 PI_FILIA_CONST.

    ENDIF.                             " G_SEGMENT_COUNTER > 0.

*   Schreibe Fehlermeldungen auf Datenbank, falls nötig.
    IF G_INIT_LOG <> SPACE.
      PERFORM APPL_LOG_WRITE_TO_DB.
    ENDIF.                             " G_INIT_LOG <> SPACE.

*   Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
*   auf OK.
    IF G_STATUS = 0.
*     Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
      CLEAR: GI_STATUS_HEADER.
      GI_STATUS_HEADER-DLDNR = PI_DLDNR.
      GI_STATUS_HEADER-GESST = C_STATUS_OK.

*     Schreibe Status-Kopfzeile.
      PERFORM STATUS_WRITE_HEAD USING  'X'  GI_STATUS_HEADER  PI_DLDNR
                                            G_RETURNCODE.
    ENDIF.                             " G_STATUS = 0.
  ENDIF.                               " E1WPC01 <> SPACE.


ENDFORM.                               " STEUERN_DOWNLOAD


*eject
************************************************************************
FORM STEUERNDATA_GET_AND_ANALYSE
     TABLES PET_STEUERN STRUCTURE GT_STEUERN_DATA
     USING  PI_LAND1    LIKE T001W-LAND1
            PI_SPRAS    LIKE WPSTRUC-SPRAS
            PI_FILIA    LIKE T001W-WERKS
   CHANGING VALUE(PE_FEHLERCODE) LIKE SYST-SUBRC
            PI_DLDNR    LIKE WDLS-DLDNR
            PI_DLDLFDNR LIKE WDLSP-LFDNR
            PI_ERMOD    LIKE TWPFI-ERMOD
            PI_LOESCHEN LIKE WPSTRUC-MODUS
            PI_SEGMENT_COUNTER LIKE G_SEGMENT_COUNTER.
************************************************************************
* FUNKTION:
* Lese die Daten für Download Steuern.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_STEUERN  : Tabelle der Steuern.
*
* PI_LAND1     : Länderschlüssel der Selektion.
*
* PI_SPRAS     : Sprachenschlüssel der Selektion.
*
* PI_FILIA     : Filiale.
*
* PE_FEHLERCODE: > 0, wenn Datenbeschaffung mißlungen, sonst '0'.
*
* PI_DLDNR     : Downloadnummer für Statusverfolgung.
*
* PI_DLDLFDNR  : Laufende Nr. der Positionszeile für Statusverfolgung.
*
* PI_ERMOD     : = 'X', wenn Downloadabbruch bei Fehler erwünscht.
*
* PI_LOESCHEN   : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                        sollen, sonst SPACE.
* PI_SEGMENT_COUNTER: Segmentzähler.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Besorge Steuern.
  CALL FUNCTION 'POS_TAX_GET'
       EXPORTING
            PI_LAND                  = PI_LAND1
            PI_SPRAS                 = PI_SPRAS
            PI_LOESCHEN              = PI_LOESCHEN
       TABLES
            PET_SALES_TAXES          = PET_STEUERN
       EXCEPTIONS
            KEINE_UMSKZ_GEFUNDEN     = 01
            KEIN_KALKSCHEMA_GEFUNDEN = 02.

  IF SY-SUBRC <> 0.
*   Zwischenspeichern des Returncodes.
    PE_FEHLERCODE = SY-SUBRC.

*   Falls Fehlerprotokollierung erwünscht.
    IF PI_ERMOD = SPACE.
*     Falls noch keine Initialisierung des Fehlerprotokolls.
      IF G_INIT_LOG = SPACE.
*       Aufbereitung der Parameter zum schreiben des Headers des
*       Fehlerprotokolls.
        CLEAR: GI_ERRORMSG_HEADER.
        GI_ERRORMSG_HEADER-OBJECT        = C_APPLIKATION.
        GI_ERRORMSG_HEADER-SUBOBJECT     = C_SUBOBJECT.
        GI_ERRORMSG_HEADER-EXTNUMBER     = PI_DLDNR.
        GI_ERRORMSG_HEADER-EXTNUMBER+14  = PI_DLDLFDNR.
        GI_ERRORMSG_HEADER-ALUSER        = SY-UNAME.

*       Initialisiere Fehlerprotokoll und erzeuge Header.
        PERFORM APPL_LOG_INIT_WITH_HEADER  USING GI_ERRORMSG_HEADER.

*       Merke, daß Fehlerprotokoll initialisiert wurde.
        G_INIT_LOG = 'X'.
      ENDIF.                           " G_INIT_LOG = SPACE.

*     Bereite Parameter zum schreiben der Fehlerzeile auf.
      CLEAR: GI_MESSAGE.
      GI_MESSAGE-MSGTY     = C_MSGTP_WARNING.
      GI_MESSAGE-MSGID     = C_MESSAGE_ID.
      GI_MESSAGE-PROBCLASS = C_PROBCLASS_WENIGER_WICHTIG.
      CASE PE_FEHLERCODE.
        WHEN '1'.
*         'Keine Steuerkennzeichen für Länderkennzeichen &
*          gepflegt'.
          GI_MESSAGE-MSGNO     = '140'.
          GI_MESSAGE-MSGV1     = PI_LAND1.
        WHEN '2'.
*         'Kein Kalkulationsschema für Länderkennzeichen &
*          gepflegt'.
          GI_MESSAGE-MSGNO     = '141'.
          GI_MESSAGE-MSGV1     = PI_LAND1.
      ENDCASE.                         " PE_FEHLERCODE

*     Schreibe Fehlerzeile.
      CLEAR: G_OBJECT_KEY.
      PERFORM APPL_LOG_WRITE_SINGLE_MESSAGE USING  GI_MESSAGE.

    ENDIF.                             " PI_ERMOD = SPACE.

*   Ändern der Status-Kopfzeile, falls nötig.
    IF G_STATUS < 2.                   " 'Benutzerhinweis'
      CLEAR: GI_STATUS_HEADER.
      GI_STATUS_HEADER-DLDNR = PI_DLDNR.
      GI_STATUS_HEADER-GESST = C_STATUS_BENUTZERHINWEIS.

*     Korrigiere Status-Kopfzeile auf "Fehlerhaft".
      PERFORM STATUS_WRITE_HEAD USING  'X'  GI_STATUS_HEADER  PI_DLDNR
                                       G_RETURNCODE.
*     Aktualisiere Aufbereitungsstatus.
      G_STATUS = 2.                  " 'Benutzerhinweis'

    ENDIF. " G_STATUS < 2.  " 'Benutzerhinweis'

*   Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
    CLEAR: GI_STATUS_POS.
    GI_STATUS_POS-DLDNR  = PI_DLDNR.
    GI_STATUS_POS-LFDNR  = PI_DLDLFDNR.
    GI_STATUS_POS-ANLOZ  = G_ERR_COUNTER.
    GI_STATUS_POS-ANSEG  = PI_SEGMENT_COUNTER.

*   Aktualisiere Aufbereitungsstatus für Positionszeile,
*   falls nötig.
    IF G_STATUS_POS < 2.                   " 'Benutzerhinweis'
      GI_STATUS_POS-GESST = C_STATUS_BENUTZERHINWEIS.

      G_STATUS_POS = 2.                    " 'Benutzerhinweis'
    ENDIF. " g_status_pos < 2.             " 'Benutzerhinweis'

*   Schreibe Status-Positionszeile.
    PERFORM STATUS_WRITE_POS USING 'X' GI_STATUS_POS  PI_DLDLFDNR
                                       G_RETURNCODE.

*   Falls Fehlerprotokollierung erwünscht.
    IF PI_ERMOD = SPACE.
*     Verlassen der Aufbereitung, falls Einlesefehler.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE DOWNLOAD_EXIT.
    ENDIF.                             " PI_ERMOD = SPACE.
  ENDIF.                               " SY-SUBRC <> 0.


ENDFORM.                               " STEUERNDATA_GET_AND_ANALYSE


*eject.
************************************************************************
FORM IDOC_DATASET_STEUERN_APPEND
     using  PXT_IDOC_DATA  type short_edidd
            PI_STEUER      STRUCTURE GT_STEUERN_DATA
            PI_DATUM       LIKE WPSTRUC-DATUM
            PX_SEGCNT      LIKE G_SEGMENT_COUNTER
            PI_LOESCHEN    LIKE WPSTRUC-MODUS
            PI_E1WPT02     LIKE WPSTRUC-MODUS
            PI_FILIA       LIKE T001W-WERKS
            PE_FEHLERCODE  LIKE SYST-SUBRC
            PI_DLDNR       LIKE WDLS-DLDNR
            PI_DLDLFDNR    LIKE WDLSP-LFDNR
            PI_FILIA_CONST LIKE WPFILCONST.
************************************************************************
* FUNKTION:
* Erzeuge den IDOC-Satz für das Datum PI_DATUM und füge ihn an die
* Tabelle PXT_IDOC_DATA an.
* ---------------------------------------------------------------------*
* PARAMETER:
* PXT_IDOC_DATA: IDOC-Daten der Struktur EDIDD (Tabelle an die die
*                IDOC-Sätze angefügt werden).
* PI_STEUER    : Daten eines Steuerkennezeichens.
*
* PI_DATUM     : Datum für das die Daten aufbereitet werden sollen.
*
* PX_SEGCNT    : Segment-Zähler.
*
* PI_LOESCHEN  : = 'X', wenn Löschmodus aktiv.
*
* PI_E1WPT02   : = 'X', wenn Segment E1WPT02 aufbereitet werden soll.
*
* PI_FILIA     : Filiale, an die versendet werden soll.
*
* PE_FEHLERCODE: > 0, wenn Fehler beim Umsetzen der Daten.

* PI_DLDNR     : Downloadnummer für Statusverfolgung.
*
* PI_DLDLFDNR  : Laufende Nr. der Positionszeile für Statusverfolgung.
*
* PI_FILIA_CONST : Filialkonstanten.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: SEG_LOCAL_CNT TYPE I.


* Rücksetze Returncode.
  CLEAR: PE_FEHLERCODE.

* Rücksetze Temporärtabelle für IDOC-Daten.
  REFRESH: GT_IDOC_DATA_TEMP.

* Rücksetze lokalen Segmentzähler.
  CLEAR: SEG_LOCAL_CNT.

* Aufbereitung ID-Segment.
  CLEAR: E1WPT01.
  E1WPT01-FILIALE    = PI_FILIA_CONST-KUNNR.
  E1WPT01-AKTIVDATUM = PI_DATUM.
  E1WPT01-AENDDATUM  = '00000000'.
  E1WPT01-AENDERER   = ' '.
  E1WPT01-MWSKZ      = PI_STEUER-MWSKZ.

* Falls Löschmodus aktiv.
  IF PI_LOESCHEN <> SPACE.
    E1WPT01-AENDKENNZ  = C_DELETE.
* Falls Löschmodus nicht aktiv.
  ELSE.
    E1WPT01-AENDKENNZ  = C_MODI.
  ENDIF.                               " PI_LOESCHEN <> SPACE.

* Erzeuge temporären IDOC-Segmentsatz.
  GT_IDOC_DATA_TEMP-SEGNAM = C_E1WPT01_NAME.
  GT_IDOC_DATA_TEMP-SDATA  = E1WPT01.
  APPEND GT_IDOC_DATA_TEMP.

* aktualisiere Segmentzähler.
  ADD 1 TO SEG_LOCAL_CNT.

* Es müssen Stammdaten übertragen werden, da kein Löschmodus aktiv ist.
  IF PI_LOESCHEN = SPACE.
*   Falls Segment E1WPT02 Steuern Stammdaten gefüllt werden muß.
    IF PI_E1WPT02 <> SPACE.
*     Aufbereitung Segment Steuern Stammdaten.
      CLEAR: E1WPT02.
      E1WPT02-STEUERART  = PI_STEUER-STEUERART.
      E1WPT02-BEZEICH    = PI_STEUER-BEZEICH.
      E1WPT02-SATZ       = PI_STEUER-STEUERSATZ.
      CONDENSE E1WPT02-SATZ.

*     Erzeuge temporären IDOC-Segmentsatz.
      GT_IDOC_DATA_TEMP-SEGNAM = C_E1WPT02_NAME.
      GT_IDOC_DATA_TEMP-SDATA  = E1WPT02.
      APPEND GT_IDOC_DATA_TEMP.

*     aktualisiere Segmentzähler.
      ADD 1 TO SEG_LOCAL_CNT.
    ENDIF.                             " PI_E1WPT02 <> SPACE.
  ENDIF.                               " PI_LOESCHEN = SPACE.

*********************************************************************
***********************   U S E R - E X I T  ************************
  CALL CUSTOMER-FUNCTION '007'
       EXPORTING
            PX_SEGMENT_COUNTER = PX_SEGCNT
            PI_SEG_LOCAL_CNT   = SEG_LOCAL_CNT
            PI_DLDNR           = PI_DLDNR
            PI_DLDLFDNR        = PI_DLDLFDNR
            PI_ERMOD           = PI_FILIA_CONST-ERMOD
            PI_FIRSTKEY        = G_FIRSTKEY
            PX_INIT_LOG        = G_INIT_LOG
            PX_STATUS          = G_STATUS
            PX_STATUS_POS      = G_STATUS_POS
            PX_ERR_COUNTER     = G_ERR_COUNTER
       IMPORTING
            PX_INIT_LOG        = G_INIT_LOG
            PX_STATUS          = G_STATUS
            PX_STATUS_POS      = G_STATUS_POS
            PE_FEHLERCODE      = PE_FEHLERCODE
            PX_ERR_COUNTER     = G_ERR_COUNTER
            PI_SEG_LOCAL_CNT   = SEG_LOCAL_CNT
       TABLES
            PXT_IDOC_DATA_TEMP = GT_IDOC_DATA_TEMP
            PIT_IDOC_DATA      = gt_idoc_data_dummy
       changing
            PIT_IDOC_DATA_new  = PXT_IDOC_DATA.

* Falls Umsetzfehler auftraten.
  IF PE_FEHLERCODE <> 0.
*   Falls Fehlerprotokollierung erwünscht.
    IF PI_FILIA_CONST-ERMOD = SPACE.
*     Fülle allgemeinen Objektschlüssel.
      G_OBJECT_KEY = C_WHOLE_IDOC.

*     Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
      PERFORM ERROR_OBJECT_WRITE.

*     Verlassen der Aufbereitung dieser Basiswarengruppe.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_FILIA_CONST-ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE DOWNLOAD_EXIT.
    ENDIF.                             " PI_FILIA_CONST-ERMOD = SPACE.

* Falls Umschlüsselung fehlerfrei.
  ELSE.                                " PE_FEHLERCODE = 0.
*   Übernehme die IDOC-Daten aus Temporärtabelle.
    PERFORM IDOC_DATA_ASSUME TABLES  GT_IDOC_DATA_TEMP
                             using   PXT_IDOC_DATA
                                     PX_SEGCNT
                                     SEG_LOCAL_CNT.

  ENDIF.                               " PE_FEHLERCODE <> 0.

*********************************************************************

ENDFORM.                               " IDOC_DATASET_STEUERN_APPEND
