*-------------------------------------------------------------------
***INCLUDE LWPDAF02 .
*-------------------------------------------------------------------
* FORM-Routinen für Download Warengruppen
************************************************************************

************************************************************************
FORM WRGP_DOWNLOAD
     TABLES PIT_FILTER_SEGS STRUCTURE  GT_FILTER_SEGS
            PIT_WRGP        STRUCTURE  WPMGOT3
     USING  PI_FILIA        LIKE       WPFILIA-FILIA
            PI_FILIA_CONST  STRUCTURE  GI_FILIA_CONST
            PI_LOESCHEN     LIKE       WPSTRUC-MODUS
            PI_DATUM_AB     LIKE       WPSTRUC-DATUM
            PI_VKORG        LIKE       WPSTRUC-VKORG
            PI_VTWEG        LIKE       WPSTRUC-VTWEG
            PI_EXPRESS      LIKE       WPSTRUC-MODUS
            PI_DEBUG        LIKE       WPSTRUC-MODUS
            PI_MODE         LIKE       WPSTRUC-MODUS.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der Warengruppen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS: Liste aller für den POS-Download nicht benötigten
*                  Segmente.
* PIT_WRGP       : Tabelle mit den aufzubereitenden Warengruppen.
*
* PI_FILIA       : Filiale, an die verschickt werden soll.
*
* PI_FILIA_CONST : Feldleiste mit Filialkonstanten.
*
* PI_LOESCHEN    : = 'X', wenn die Daten im Zielsystem gelöscht werden
*                  sollen, sonst SPACE.
* PI_DATUM_AB    : = Beginn des Betrachtungszeitraums.
*
* PI_VKORG       : Verkaufsorganisation.
*
* PI_VTWEG       : Vertriebsweg.
*
* PI_EXPRESS     : = 'X', wenn sofort versendet werden soll,
*                         sonst SPACE.
* PI_DEBUG       : = 'X', wenn Status-Positionszeile ständig
*                         aktualisiert werden soll, sonst SPACE.
* PI_MODE        : = 'I', wenn Initialisierungsmodus, 'A' = direkte
*                     Anforderung, 'R' = Restart
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: E1WPW01     VALUE 'X', " Flag, ob Segm. E1WPW01 vers. werden muß
        E1WPW02     VALUE 'X',
        E1WPW05     VALUE 'X',
        E1WPW03     VALUE 'X',
        H_DATUM     LIKE SY-DATUM,
        H_READINDEX LIKE SY-TABIX,
        FEHLERCODE  TYPE I.

  DATA: BEGIN OF T_WRGP_BASE_DATA OCCURS 200.
          INCLUDE STRUCTURE WWG02.
        DATA: END OF T_WRGP_BASE_DATA.

  DATA: BEGIN OF T_WRF6 OCCURS 200.
          INCLUDE STRUCTURE WRF6.
        DATA: END OF T_WRF6.

* Prüfe, welche Warengruppensegmente versendet werden müssen
  LOOP AT PIT_FILTER_SEGS.

    CASE PIT_FILTER_SEGS-SEGTYP.
      WHEN C_E1WPW01_NAME.
        CLEAR: E1WPW01.
      WHEN C_E1WPW02_NAME.
        CLEAR: E1WPW02.
      WHEN C_E1WPW05_NAME.
        CLEAR: E1WPW05.
      WHEN C_E1WPW03_NAME.
        CLEAR: E1WPW03.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " AT PIT_FILTER_SEGS

* Es müssen Warengruppen versendet werden.
  IF E1WPW01 <> SPACE.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: G_SEGMENT_COUNTER, G_NEW_POSITION, G_STATUS_POS.

*   Merke daß 'Firstkey' gemerkt werden muß.
    G_NEW_FIRSTKEY = 'X'.

    IF PI_DATUM_AB IS INITIAL.
      G_AKTIVDAT = G_ERSTDAT.
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
    ENDIF.                             " PI_FILIA_CONST-FABKL  <> SPACE.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: GI_STATUS_POS.
    GI_STATUS_POS-DLDNR  = G_DLDNR.
    GI_STATUS_POS-DOCTYP = C_IDOCTYPE_WRGP.

*   Fall Restart-Modus.
    IF PI_MODE = C_RESTART_MODE.
      GI_STATUS_POS-RSPOS  = 'X'.
    ENDIF. " pi_mode = c_restart_mode.

*   Schreibe Status-Positionszeile.
    PERFORM STATUS_WRITE_POS USING ' ' GI_STATUS_POS  G_DLDLFDNR
                                       G_RETURNCODE.
*   Rücksetzen Fehler-Zähler.
    CLEAR: G_ERR_COUNTER, G_FIRSTKEY.

*   Prüfe, ob nur bestimmte Warengruppen noch einmal aufbereitet
*   werden sollen (nur für Restart-Fall relevant).
    READ TABLE PIT_WRGP INDEX 1.

*   Falls nur bestimmte Warengruppen noch einmal aufbereitet werden
*   sollen.
    IF SY-SUBRC = 0.
*     Schleife über alle nochmal zu versendenden Warengruppen.
      LOOP AT PIT_WRGP.
*       Falls nötig, erzeuge Löschsatz.
        IF PIT_WRGP-UPD_FLAG <> SPACE OR PI_LOESCHEN <> SPACE.
*         Übernehme Warengruppe in andere Feldleiste.
          CLEAR: T_WRGP_BASE_DATA.
          T_WRGP_BASE_DATA-MATKL = PIT_WRGP-MATKL.

*         Merke 'Firstkey'.
          IF G_NEW_FIRSTKEY <> SPACE.
            G_FIRSTKEY = T_WRGP_BASE_DATA-MATKL.
            CLEAR: G_NEW_FIRSTKEY.
          ENDIF.                         " G_NEW_FIRSTKEY <> SPACE.

***     Start Of Changes By Suri : 25.12.2019
***     For Chaning Material Group IDoc Segments to 1000
*          CALL FUNCTION 'MASTERIDOC_CREATE_DLPWRGP'
*               EXPORTING
*                    PI_BASE_MATKL      = T_WRGP_BASE_DATA
*                    PI_AKTIVDAT        = G_AKTIVDAT
*                    PI_DLDNR           = G_DLDNR
*                    PX_DLDLFDNR        = G_DLDLFDNR
*                    PI_VKORG           = PI_VKORG
*                    PI_VTWEG           = PI_VTWEG
*                    PI_FILIA           = PI_FILIA
*                    PI_EXPRESS         = ' '
*                    PI_LOESCHEN        = 'X'
*                    PI_E1WPW02         = E1WPW02
*                    PI_E1WPW05         = E1WPW05
*                    PI_E1WPW03         = E1WPW03
*                    PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*                    PI_FILIA_CONST     = PI_FILIA_CONST
*               IMPORTING
*                    PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*               changing
*                    PXT_IDOC_DATA      = GT_IDOC_DATA
*               EXCEPTIONS
*                    DOWNLOAD_EXIT      = 1.

          CALL FUNCTION 'ZZMASTERIDOC_CREATE_DLPWRGP'
            EXPORTING
              PI_BASE_MATKL      = T_WRGP_BASE_DATA
              PI_AKTIVDAT        = G_AKTIVDAT
              PI_DLDNR           = G_DLDNR
              PX_DLDLFDNR        = G_DLDLFDNR
              PI_VKORG           = PI_VKORG
              PI_VTWEG           = PI_VTWEG
              PI_FILIA           = PI_FILIA
              PI_EXPRESS         = ' '
              PI_LOESCHEN        = 'X'
              PI_E1WPW02         = E1WPW02
              PI_E1WPW05         = E1WPW05
              PI_E1WPW03         = E1WPW03
              PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
              PI_FILIA_CONST     = PI_FILIA_CONST
            IMPORTING
              PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
            CHANGING
              PXT_IDOC_DATA      = GT_IDOC_DATA
            EXCEPTIONS
              DOWNLOAD_EXIT      = 1.

***     End Of Changes By Suri : 25.12.2019

*         Es sind Fehler beim Download aufgetreten'
          IF SY-SUBRC = 1.
            RAISE ERROR_CODE_1.
          ENDIF.                         " SY-SUBRC = 1.

*         Weiter zur nächsten Warengruppe.
          CONTINUE.
        ENDIF. " pit_wrgp-upd_flag <> space or pi_loeschen <> space.

*       Einlesen der Daten dieser Basiswarengruppe.
        CALL FUNCTION 'MERCHANDISE_GROUP_SELECT'
          EXPORTING
            MATKL       = PIT_WRGP-MATKL
            SPRAS       = PI_FILIA_CONST-SPRAS
            WG_BEZ      = 'X'
          TABLES
            O_WWG01     = T_WRGP_BASE_DATA
          EXCEPTIONS
            NO_BASIS_MG = 01.

*       Falls die Basiswarengruppe existiert.
        IF SY-SUBRC = 0.
*         Falls nur bestimmte Warengruppen an diese Filiale geschickt
*         werden sollen, dann filialabhängige Prüfung nötig.
          IF PI_FILIA_CONST-SALLMG = SPACE.
*           Prüfe, ob die Warengruppe dieser Filiale zugeordnet ist.
            CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
              EXPORTING
                PI_FILIALE     = PI_FILIA_CONST-KUNNR
                PI_WARENGRUPPE = PIT_WRGP-MATKL
              TABLES
                PE_T_WRF6      = T_WRF6
              EXCEPTIONS
                NO_WRF6_RECORD = 01
                NO_WRGP_FOUND  = 02.

            READ TABLE T_WRF6 INDEX 1.
          ENDIF. " pi_filia_const-sallmg = space.

*         Falls die Warengruppe dieser Filiale zugeordnet ist oder
*         alle Warengruppen an diese Filiale versendet werden sollen.
          IF ( SY-SUBRC = 0 AND T_WRF6-WDAUS = SPACE ) OR
               PI_FILIA_CONST-SALLMG <> SPACE.
            READ TABLE T_WRGP_BASE_DATA INDEX 1.

*           Merke 'Firstkey'.
            IF G_NEW_FIRSTKEY <> SPACE.
              G_FIRSTKEY = T_WRGP_BASE_DATA-MATKL.
              CLEAR: G_NEW_FIRSTKEY.
            ENDIF.                         " G_NEW_FIRSTKEY <> SPACE.
***     Start Of Changes By Suri : 25.12.2019
***     For Chaning Material Group IDoc Segments to 1000
*            CALL FUNCTION 'MASTERIDOC_CREATE_DLPWRGP'
*              EXPORTING
*                PI_BASE_MATKL      = T_WRGP_BASE_DATA
*                PI_AKTIVDAT        = G_AKTIVDAT
*                PI_DLDNR           = G_DLDNR
*                PX_DLDLFDNR        = G_DLDLFDNR
*                PI_VKORG           = PI_VKORG
*                PI_VTWEG           = PI_VTWEG
*                PI_FILIA           = PI_FILIA
*                PI_EXPRESS         = ' '
*                PI_LOESCHEN        = ' '
*                PI_E1WPW02         = E1WPW02
*                PI_E1WPW05         = E1WPW05
*                PI_E1WPW03         = E1WPW03
*                PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*                PI_FILIA_CONST     = PI_FILIA_CONST
*              IMPORTING
*                PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*              CHANGING
*                PXT_IDOC_DATA      = GT_IDOC_DATA
*              EXCEPTIONS
*                DOWNLOAD_EXIT      = 1.

            CALL FUNCTION 'ZZMASTERIDOC_CREATE_DLPWRGP'
              EXPORTING
                PI_BASE_MATKL      = T_WRGP_BASE_DATA
                PI_AKTIVDAT        = G_AKTIVDAT
                PI_DLDNR           = G_DLDNR
                PX_DLDLFDNR        = G_DLDLFDNR
                PI_VKORG           = PI_VKORG
                PI_VTWEG           = PI_VTWEG
                PI_FILIA           = PI_FILIA
                PI_EXPRESS         = ' '
                PI_LOESCHEN        = ' '
                PI_E1WPW02         = E1WPW02
                PI_E1WPW05         = E1WPW05
                PI_E1WPW03         = E1WPW03
                PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
                PI_FILIA_CONST     = PI_FILIA_CONST
              IMPORTING
                PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
              CHANGING
                PXT_IDOC_DATA      = GT_IDOC_DATA
              EXCEPTIONS
                DOWNLOAD_EXIT      = 1.

***     End Of Changes By Suri : 25.12.2019
*           Es sind Fehler beim Download aufgetreten'
            IF SY-SUBRC = 1.
              RAISE ERROR_CODE_1.
            ENDIF.                         " SY-SUBRC = 1.

*         Falls die Warengruppe nicht an diese Filiale versendet
*         werden soll.
          ELSE.
*           Aktualisiere Zählvariable für ignorierte Objekte für
*           spätere Statistikausgabe.
            ADD 1 TO GI_STAT_COUNTER-WRGP_IGN.
          ENDIF. " sy-subrc = 0 or pi_filia_group-sallmg <> space.

*       Falls Fehler beim Einlesen der Basiswarengruppe auftraten.
        ELSE.                            " SY-SUBRC <> 0.
*         Falls Fehlerprotokollierung erwünscht.
          IF PI_FILIA_CONST-ERMOD = SPACE.
*           Falls noch keine Initialisierung des Fehlerprotokolls.
            IF G_INIT_LOG = SPACE.
*             Zwischenspeichern des Returncodes.
              FEHLERCODE = SY-SUBRC.

*             Aufbereitung der Parameter zum schreiben des Headers
*             des Fehlerprotokolls.
              CLEAR: GI_ERRORMSG_HEADER.
              GI_ERRORMSG_HEADER-OBJECT        = C_APPLIKATION.
              GI_ERRORMSG_HEADER-SUBOBJECT     = C_SUBOBJECT.
              GI_ERRORMSG_HEADER-EXTNUMBER     = G_DLDNR.
              GI_ERRORMSG_HEADER-EXTNUMBER+14  = G_DLDLFDNR.
              GI_ERRORMSG_HEADER-ALUSER        = SY-UNAME.

*             Initialisiere Fehlerprotokoll und erzeuge Header.
              PERFORM APPL_LOG_INIT_WITH_HEADER
                      USING GI_ERRORMSG_HEADER.

*             Merke, daß Fehlerprotokoll initialisiert wurde.
              G_INIT_LOG = 'X'.
            ENDIF.                       " G_INIT_LOG = SPACE.

*           Bereite Parameter zum schreiben der Fehlerzeile auf.
            CLEAR: GI_MESSAGE.
            GI_MESSAGE-MSGTY     = C_MSGTP_ERROR.
            GI_MESSAGE-MSGID     = C_MESSAGE_ID.
            GI_MESSAGE-PROBCLASS = C_PROBCLASS_SEHR_WICHTIG.
*           'Fehler beim Einlesen der Basiswarengruppe &'
            GI_MESSAGE-MSGNO     = '101'.
            GI_MESSAGE-MSGV1     = PIT_WRGP-MATKL.

*           Schreibe Fehlerzeile für Application-Log und WDLSO.
            G_OBJECT_KEY = PIT_WRGP-MATKL.
            PERFORM APPL_LOG_WRITE_SINGLE_MESSAGE
                    USING  GI_MESSAGE.
          ENDIF.                     " pi_filia_const-ERMOD = SPACE.

*         Ändern der Status-Kopfzeile, falls nötig.
          IF G_STATUS < 3.                   " 'Fehlende Daten'
*           Aufbereiten der Parameter zum Ändern der
*           Status-Kopfzeile.
            CLEAR: GI_STATUS_HEADER.
            GI_STATUS_HEADER-DLDNR = G_DLDNR.
            GI_STATUS_HEADER-GESST = C_STATUS_FEHLENDE_DATEN.

*           Korrigiere Status-Kopfzeile auf "Fehlerhaft".
            PERFORM STATUS_WRITE_HEAD
                    USING  'X'  GI_STATUS_HEADER  G_DLDNR
                           G_RETURNCODE.

*           Aktualisiere Aufbereitungsstatus.
            G_STATUS = 3.                  " 'Fehlende Daten'
          ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*         Aufbereiten der Parameter zum Ändern der
*         Status-Positionszeile.
          CLEAR: GI_STATUS_POS.
          GI_STATUS_POS-DLDNR  = G_DLDNR.
          GI_STATUS_POS-LFDNR  = G_DLDLFDNR.
          GI_STATUS_POS-ANLOZ  = G_ERR_COUNTER.

*         Aktualisiere Aufbereitungsstatus für Positionszeile,
*         falls nötig.
          IF G_STATUS_POS < 3.                   " 'Fehlende Daten'
            GI_STATUS_POS-GESST = C_STATUS_FEHLENDE_DATEN.

            G_STATUS_POS = 3.                    " 'Fehlende Daten'
          ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*         Schreibe Status-Positionszeile.
          PERFORM STATUS_WRITE_POS USING 'X' GI_STATUS_POS
                                         G_DLDLFDNR G_RETURNCODE.

*         Falls Abbruch bei Fehler erwünscht.
          IF GT_FILIA_GROUP-ERMOD <> SPACE.
*           Abbruch des Downloads.
            RAISE ERROR_CODE_1.
          ENDIF.                         " GT_FILIA_GROUP-ERMOD.
        ENDIF. " sy-subrc = 0. (keine Basiswarengruppe)
      ENDLOOP.                           " AT pit_wrgp.

*     Erzeuge letztes IDOC, falls nötig .
      IF G_SEGMENT_COUNTER > 0.
        PERFORM IDOC_CREATE USING  GT_IDOC_DATA
                                   G_MESTYPE_WRGP
                                   C_IDOCTYPE_WRGP
                                   G_SEGMENT_COUNTER
                                   G_ERR_COUNTER
                                   G_FIRSTKEY
                                   PIT_WRGP-MATKL
                                   G_DLDNR G_DLDLFDNR
                                   PI_FILIA
                                   PI_FILIA_CONST.

      ENDIF.                             " G_SEGMENT_COUNTER > 0

*   Falls das ganze IDOC noch einmal aufbereitet werden soll.
    ELSE. " sy-subrc <> 0.
*     Einlesen aller Basiswarengruppen.
      CALL FUNCTION 'MERCHANDISE_GROUP_SELECT'
        EXPORTING
          SPRAS       = PI_FILIA_CONST-SPRAS
          WG_BEZ      = 'X'
        TABLES
          O_WWG01     = T_WRGP_BASE_DATA
        EXCEPTIONS
          NO_BASIS_MG = 01.

      IF SY-SUBRC = 0.
*       Falls nur bestimmte Warengruppen an diese Filialen geschickt
*       werden sollen, dann löschen der überflüssigen Einträge
*       aus t_wrgp_base_data.
        IF PI_FILIA_CONST-SALLMG = SPACE.
*         Besorge alle Warengruppen, die zu dieser Filiale gehören.
          CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
            EXPORTING
              PI_FILIALE     = PI_FILIA_CONST-KUNNR
            TABLES
              PE_T_WRF6      = T_WRF6
            EXCEPTIONS
              NO_WRF6_RECORD = 01
              NO_WRGP_FOUND  = 02.

*         Falls keine Warengruppen zu dieser Filiale gehören.
          IF SY-SUBRC <> 0.
            REFRESH: T_WRGP_BASE_DATA.

*         Übernehme nur die Warengruppen, die zu dieser
*         Filiale gehören.
          ELSE. " sy-subrc = 0.
*           Lösche alle Warengruppen aus T_WRF6 die grundsätzlich nicht
*           für diese Filiale versendet werden sollen.
            LOOP AT T_WRF6
                 WHERE WDAUS <> SPACE.
              DELETE T_WRF6.
            ENDLOOP. " at T_WRF6

            SORT T_WRF6 BY MATKL.
            H_READINDEX = 1.
            LOOP AT T_WRGP_BASE_DATA.
*              READ TABLE T_WRF6 INDEX H_READINDEX.
**             Falls die Warengruppe nicht zu dieser Filiale gehört,
**             dann wird sie gelöscht.
*              IF SY-SUBRC <> 0.
*                DELETE T_WRGP_BASE_DATA.
*              ELSE. " sy-subrc = 0.
*                IF T_WRGP_BASE_DATA-MATKL = T_WRF6-MATKL.
*                  ADD 1 TO H_READINDEX.
**               Falls die Warengruppe nicht zu dieser Filiale gehört,
**               dann wird sie gelöscht.
*                ELSE. " t_wrgp_base_data-matkl <> T_WRF6-matkl.
*                  DELETE T_WRGP_BASE_DATA.
*                ENDIF. " T_WRF6_base_data-matkl = t_wrgp-matkl.
*              ENDIF. " sy-subrc = 0.
              READ TABLE T_WRF6 WITH KEY MATKL = T_WRGP_BASE_DATA-MATKL
              BINARY SEARCH TRANSPORTING NO FIELDS.

              IF SY-SUBRC <> 0.
                DELETE T_WRGP_BASE_DATA.
              ENDIF.
            ENDLOOP.                         " AT T_WRF6_BASE_DATA.
          ENDIF. " sy-subrc = 0.
        ENDIF. " pi_filia_const-sallmg = space.

*       Schleife über alle zu versendenden Basiswarengruppen.
        LOOP AT T_WRGP_BASE_DATA.
*         Merke 'Firstkey'.
          IF G_NEW_FIRSTKEY <> SPACE.
            G_FIRSTKEY = T_WRGP_BASE_DATA-MATKL.
            CLEAR: G_NEW_FIRSTKEY.
          ENDIF.                         " G_NEW_FIRSTKEY <> SPACE.

***     Start Of Changes By Suri : 25.12.2019
***     For Chaning Material Group IDoc Segments to 1000
*          CALL FUNCTION 'MASTERIDOC_CREATE_DLPWRGP'
*               EXPORTING
*                    PI_DEBUG           = PI_DEBUG
*                    PI_BASE_MATKL      = T_WRGP_BASE_DATA
*                    PI_AKTIVDAT        = G_AKTIVDAT
*                    PI_DLDNR           = G_DLDNR
*                    PX_DLDLFDNR        = G_DLDLFDNR
*                    PI_VKORG           = PI_VKORG
*                    PI_VTWEG           = PI_VTWEG
*                    PI_FILIA           = PI_FILIA
*                    PI_EXPRESS         = PI_EXPRESS
*                    PI_LOESCHEN        = PI_LOESCHEN
*                    PI_E1WPW02         = E1WPW02
*                    PI_E1WPW05         = E1WPW05
*                    PI_E1WPW03         = E1WPW03
*                    PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*                    PI_FILIA_CONST     = PI_FILIA_CONST
*               IMPORTING
*                    PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*               changing
*                    PXT_IDOC_DATA      = GT_IDOC_DATA
*               EXCEPTIONS
*                    DOWNLOAD_EXIT      = 1.

          CALL FUNCTION 'ZZMASTERIDOC_CREATE_DLPWRGP'
            EXPORTING
              PI_DEBUG           = PI_DEBUG
              PI_BASE_MATKL      = T_WRGP_BASE_DATA
              PI_AKTIVDAT        = G_AKTIVDAT
              PI_DLDNR           = G_DLDNR
              PX_DLDLFDNR        = G_DLDLFDNR
              PI_VKORG           = PI_VKORG
              PI_VTWEG           = PI_VTWEG
              PI_FILIA           = PI_FILIA
              PI_EXPRESS         = PI_EXPRESS
              PI_LOESCHEN        = PI_LOESCHEN
              PI_E1WPW02         = E1WPW02
              PI_E1WPW05         = E1WPW05
              PI_E1WPW03         = E1WPW03
              PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
              PI_FILIA_CONST     = PI_FILIA_CONST
            IMPORTING
              PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
            CHANGING
              PXT_IDOC_DATA      = GT_IDOC_DATA
            EXCEPTIONS
              DOWNLOAD_EXIT      = 1.
***     End Of Changes By Suri : 25.12.2019
*         Es sind Fehler beim Download aufgetreten'
          IF SY-SUBRC = 1.
            RAISE DOWNLOAD_EXIT.
          ENDIF.                         " SY-SUBRC = 1.

        ENDLOOP.                         " AT T_WRGP_BASE_DATA.

*       Fehler, falls keine Warengruppen dieser Filiale zugeordnet
*       sind.
        IF SY-SUBRC <> 0.
*         Falls Fehlerprotokollierung erwünscht.
          IF PI_FILIA_CONST-ERMOD = SPACE.
*           Falls noch keine Initialisierung des Fehlerprotokolls.
            IF G_INIT_LOG = SPACE.
*             Aufbereitung der Parameter zum schreiben des Headers des
*             Fehlerprotokolls.
              CLEAR: GI_ERRORMSG_HEADER.
              GI_ERRORMSG_HEADER-OBJECT        = C_APPLIKATION.
              GI_ERRORMSG_HEADER-SUBOBJECT     = C_SUBOBJECT.
              GI_ERRORMSG_HEADER-EXTNUMBER     = G_DLDNR.
              GI_ERRORMSG_HEADER-EXTNUMBER+14  = G_DLDLFDNR.
              GI_ERRORMSG_HEADER-ALUSER        = SY-UNAME.

*             Initialisiere Fehlerprotokoll und erzeuge Header.
              PERFORM APPL_LOG_INIT_WITH_HEADER
                      USING GI_ERRORMSG_HEADER.

*             Merke, daß Fehlerprotokoll initialisiert wurde.
              G_INIT_LOG = 'X'.
            ENDIF.                       " G_INIT_LOG = SPACE.

*           Bereite Parameter zum schreiben der Fehlerzeile auf.
            CLEAR: GI_MESSAGE.
            GI_MESSAGE-MSGTY     = C_MSGTP_ERROR.
            GI_MESSAGE-MSGID     = C_MESSAGE_ID.
            GI_MESSAGE-PROBCLASS = C_PROBCLASS_SEHR_WICHTIG.
*           'Der Filiale & wurden keine Warengruppen zugeordnet'.
            GI_MESSAGE-MSGNO     = '146'.
            GI_MESSAGE-MSGV1     = PI_FILIA.

*           Schreibe Fehlerzeile für Application-Log und WDLSO.
            G_OBJECT_KEY = C_WHOLE_IDOC.
            PERFORM APPL_LOG_WRITE_SINGLE_MESSAGE USING  GI_MESSAGE.
          ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.

*         Ändern der Status-Kopfzeile, falls nötig.
          IF G_STATUS < 4.             " 'Fehlende IDOC's'
            CLEAR: GI_STATUS_HEADER.
            GI_STATUS_HEADER-DLDNR = G_DLDNR.
            GI_STATUS_HEADER-GESST = C_STATUS_FEHLENDE_IDOCS.

*           Korrigiere Status-Kopfzeile auf "Fehlerhaft".
            PERFORM STATUS_WRITE_HEAD USING  'X'  GI_STATUS_HEADER
                                             G_DLDNR   G_RETURNCODE.
*           Aktualisiere Aufbereitungsstatus.
            G_STATUS = 4.              " 'Fehlende IDOC's'
          ENDIF. " G_STATUS < 4.  " 'Fehlende IDOC's

*         Aufbereiten der Parameter zum Ändern der
*         Status-Positionszeile.
          CLEAR: GI_STATUS_POS.
          GI_STATUS_POS-DLDNR  = G_DLDNR.
          GI_STATUS_POS-LFDNR  = G_DLDLFDNR.
          GI_STATUS_POS-ANLOZ  = G_ERR_COUNTER.
          GI_STATUS_POS-ANSEG  = G_SEGMENT_COUNTER.
          GI_STATUS_POS-GESST  = C_STATUS_FEHLENDE_IDOCS.

*         Aktualisiere Aufbereitungsstatus für Positionen.
          G_STATUS_POS = 4.              " 'Fehlende IDOC's'

*         Schreibe Status-Positionszeile.
          PERFORM STATUS_WRITE_POS USING 'X' GI_STATUS_POS  G_DLDLFDNR
                                             G_RETURNCODE.

*         Schreibe Fehlermeldungen auf Datenbank.
          PERFORM APPL_LOG_WRITE_TO_DB.

*         Falls Fehlerprotokollierung erwünscht.
          IF PI_FILIA_CONST-ERMOD = SPACE.
*           Aufbereitung verlassen.
            EXIT.
*         Falls Abbruch bei Fehler erwünscht.
          ELSE.                          " PI_ERMOD <> SPACE.
*           Abbruch des Downloads.
            RAISE DOWNLOAD_EXIT.
          ENDIF.                         " PI_FILIA_CONST-ERMOD = SPACE.
        ENDIF.                           " SY-SUBRC <> 0.

*       Erzeuge letztes IDOC, falls nötig .
        IF G_SEGMENT_COUNTER > 0.
          PERFORM IDOC_CREATE USING  GT_IDOC_DATA
                                     G_MESTYPE_WRGP
                                     C_IDOCTYPE_WRGP
                                     G_SEGMENT_COUNTER
                                     G_ERR_COUNTER
                                     G_FIRSTKEY
                                     T_WRGP_BASE_DATA-MATKL
                                     G_DLDNR        G_DLDLFDNR
                                     PI_FILIA
                                     PI_FILIA_CONST.

        ENDIF.                           " G_SEGMENT_COUNTER > 0

*     Falls Fehler beim Einlesen der Basiswarangruppen auftraten.
      ELSE.                              " SY-SUBRC <> 0.
*       Falls Fehlerprotokollierung erwünscht.
        IF PI_FILIA_CONST-ERMOD = SPACE.
*         Falls noch keine Initialisierung des Fehlerprotokolls.
          IF G_INIT_LOG = SPACE.
*           Zwischenspeichern des Returncodes.
            FEHLERCODE = SY-SUBRC.

*           Aufbereitung der Parameter zum schreiben des Headers des
*           Fehlerprotokolls.
            CLEAR: GI_ERRORMSG_HEADER.
            GI_ERRORMSG_HEADER-OBJECT        = C_APPLIKATION.
            GI_ERRORMSG_HEADER-SUBOBJECT     = C_SUBOBJECT.
            GI_ERRORMSG_HEADER-EXTNUMBER     = G_DLDNR.
            GI_ERRORMSG_HEADER-EXTNUMBER+14  = G_DLDLFDNR.
            GI_ERRORMSG_HEADER-ALUSER        = SY-UNAME.

*           Initialisiere Fehlerprotokoll und erzeuge Header.
            PERFORM APPL_LOG_INIT_WITH_HEADER
                    USING GI_ERRORMSG_HEADER.

*           Merke, daß Fehlerprotokoll initialisiert wurde.
            G_INIT_LOG = 'X'.
          ENDIF.                         " G_INIT_LOG = SPACE.

*         Bereite Parameter zum schreiben der Fehlerzeile auf.
          CLEAR: GI_MESSAGE.
          GI_MESSAGE-MSGTY     = C_MSGTP_ERROR.
          GI_MESSAGE-MSGID     = C_MESSAGE_ID.
          GI_MESSAGE-PROBCLASS = C_PROBCLASS_SEHR_WICHTIG.
*         'Es sind keine Basiswarengruppen gepflegt'.
          GI_MESSAGE-MSGNO     = '100'.

*         Schreibe Fehlerzeile für Application-Log und WDLSO.
          G_OBJECT_KEY = C_WHOLE_IDOC.
          PERFORM APPL_LOG_WRITE_SINGLE_MESSAGE  USING GI_MESSAGE.

        ENDIF.                           " PI_FILIA_CONST-ERMOD = SPACE.

*       Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
        CLEAR: GI_STATUS_HEADER.
        GI_STATUS_HEADER-DLDNR = G_DLDNR.
        GI_STATUS_HEADER-GESST = C_STATUS_FEHLENDE_IDOCS.

*       Korrigiere Status-Kopfzeile auf "Fehlerhaft".
        PERFORM STATUS_WRITE_HEAD USING  'X'  GI_STATUS_HEADER G_DLDNR
                                              G_RETURNCODE.

*       Aktualisiere Aufbereitungsstatus.
        G_STATUS = 4.                    " 'Fehlende IDOC's'

*       Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
        CLEAR: GI_STATUS_POS.
        GI_STATUS_POS-DLDNR  = G_DLDNR.
        GI_STATUS_POS-LFDNR  = G_DLDLFDNR.
        GI_STATUS_POS-ANLOZ  = G_ERR_COUNTER.
        GI_STATUS_POS-GESST  = C_STATUS_FEHLENDE_IDOCS.

*       Aktualisiere Aufbereitungsstatus für Positionen.
        G_STATUS_POS = 4.              " 'Fehlende IDOC's'

*       Schreibe Status-Positionszeile.
        PERFORM STATUS_WRITE_POS USING 'X' GI_STATUS_POS  G_DLDLFDNR
                                           G_RETURNCODE.

*       Schreibe Fehlermeldungen auf Datenbank.
        PERFORM APPL_LOG_WRITE_TO_DB.

*       Falls Fehlerprotokollierung erwünscht.
        IF PI_FILIA_CONST-ERMOD = SPACE.
*         Verlassen der Aufbereitung für Warengruppen-IDOC's.
          EXIT.
*       Falls Abbruch bei Fehler erwünscht.
        ELSE.                            " PI_FILIA_CONST-ERMOD <> SPACE.
*         Abbruch des Downloads.
          RAISE DOWNLOAD_EXIT.
        ENDIF.                           " PI_FILIA_CONST-ERMOD = SPACE.
      ENDIF.                             " SY-SUBRC = 0.
    ENDIF. " sy-subrc = 0.

*   Schreibe Fehlermeldungen auf Datenbank, falls nötig.
    IF G_INIT_LOG <> SPACE.
      PERFORM APPL_LOG_WRITE_TO_DB.
    ENDIF.                             " G_INIT_LOG <> SPACE.

*   Falls keine Fehler aufgetreten sind, setze Kopfzeilenstatus
*   auf OK.
    IF G_STATUS = 0.
*     Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
      CLEAR: GI_STATUS_HEADER.
      GI_STATUS_HEADER-DLDNR = G_DLDNR.
      GI_STATUS_HEADER-GESST = C_STATUS_OK.

*     Schreibe Status-Kopfzeile.
      PERFORM STATUS_WRITE_HEAD USING  'X'  GI_STATUS_HEADER  G_DLDNR
                                            G_RETURNCODE.
    ENDIF.                             " G_STATUS = 0.

  ENDIF.                               " E1WPW01 <> SPACE.


ENDFORM.                               " wrgp_download


*eject
************************************************************************
FORM WRGP_DOWNLOAD_CHANGE_MODE
     TABLES PIT_FILTER_SEGS STRUCTURE GT_FILTER_SEGS
            PIT_OT3_WRGP    STRUCTURE GT_OT3_WRGP
            PIT_WORKDAYS    STRUCTURE GT_WORKDAYS
     USING  PI_FILIA_GROUP  STRUCTURE GT_FILIA_GROUP
            PI_ERSTDAT      LIKE SYST-DATUM
            PI_DLDNR        LIKE WDLS-DLDNR
            PI_MESTYPE      LIKE EDIMSG-MESTYP.
************************************************************************
* FUNKTION:                                                            *
* Beginn des Downloads der Warengruppen.                               *
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_FILTER_SEGS : Liste aller für den POS-Download nicht benötigten
*                   Segmente.
* PIT_OT3_WRGP    : Arkelstamm: Objekttabelle 3, filialabhängig.
*
* PIT_WORKDAYS    : Tabelle der Arbeitstage des Betrachtungszeitraums.
*
* PI_FILIA_GROUP  : Daten einer Filiale der Filialgruppe.
*
* PI_ERSTDAT      : Beginndatum des Downloads.
*
* PI_DATP3        : Datum: letztes  Versenden + Vorlaufzeit.
*
* PI_DATP4        : Datum: letztes Versenden + Vorlaufzeit.
*
* PI_MODE         : = 'U', wenn Update-Modus, 'R' = Restart-Modus.
*
* PI_DLDNR        : Downloadnummer für Statusverfolgung.
*
* PI_MESTYPE      : Zu verwendender Nachrichtentyp für
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: E1WPW01    VALUE 'X', " Flag, ob Segm. E1WPW01 vers. werden muß
        E1WPW02    VALUE 'X',
        E1WPW05    VALUE 'X',
        E1WPW03    VALUE 'X',
        H_DATUM    LIKE SY-DATUM,
        FEHLERCODE TYPE I.

  DATA: BEGIN OF T_WRGP_BASE_DATA OCCURS 50.
          INCLUDE STRUCTURE WWG02.
        DATA: END OF T_WRGP_BASE_DATA.

  DATA: BEGIN OF T_WRF6 OCCURS 2.
          INCLUDE STRUCTURE WRF6.
        DATA: END OF T_WRF6.

* Feldleiste für Filialkonstanten.
  DATA: BEGIN OF I_FILIA_CONST.
          INCLUDE STRUCTURE WPFILCONST.
        DATA: END OF I_FILIA_CONST.

* Übernehme den aktuellen Nachrichtentyp in globale Variable.
  G_CURRENT_DOCTYPE = C_IDOCTYPE_WRGP.

* Übernehme Filialkonstanten in andere Feldleiste
  MOVE-CORRESPONDING PI_FILIA_GROUP TO I_FILIA_CONST.

* Prüfe, welche Warengruppensegmente versendet werden müssen
  LOOP AT PIT_FILTER_SEGS.

    CASE PIT_FILTER_SEGS-SEGTYP.
      WHEN C_E1WPW01_NAME.
        CLEAR: E1WPW01.
      WHEN C_E1WPW02_NAME.
        CLEAR: E1WPW02.
      WHEN C_E1WPW05_NAME.
        CLEAR: E1WPW05.
      WHEN C_E1WPW03_NAME.
        CLEAR: E1WPW03.
    ENDCASE.                           " PIT_FILTER_SEGS-SEGTYP

  ENDLOOP.                             " AT PIT_FILTER_SEGS

* Es müssen Warengruppen versendet werden.
  IF E1WPW01 <> SPACE.
*   Rücksetze Segmentzähler und Positionszeilenmerker.
    CLEAR: G_SEGMENT_COUNTER, G_NEW_POSITION, G_STATUS_POS.

*   Rücksetzen Fehler-Zähler.
    CLEAR: G_ERR_COUNTER, G_FIRSTKEY.

*   Merke daß 'Firstkey' gemerkt werden muß.
    G_NEW_FIRSTKEY = 'X'.

*   Vorbesetzen Aktivierungsdatum.
    G_AKTIVDAT = PI_ERSTDAT.

*   Besorge das Datum des Versendetages.
    PERFORM NEXT_WORKDAY_GET TABLES PIT_WORKDAYS
                             USING  G_AKTIVDAT
                                    H_DATUM.

    G_AKTIVDAT = H_DATUM.

*   Aufbereiten der Parameter zum schreiben der Status-Positionszeile.
    CLEAR: GI_STATUS_POS.
    GI_STATUS_POS-DLDNR  = PI_DLDNR.
    GI_STATUS_POS-DOCTYP = C_IDOCTYPE_WRGP.

*   Schreibe Status-Positionszeile.
    PERFORM STATUS_WRITE_POS USING ' ' GI_STATUS_POS  G_DLDLFDNR
                                       G_RETURNCODE.

*   Schleife über alle neu hinzugekommenen Warengruppen.
    LOOP AT PIT_OT3_WRGP.
*     Falls nötig, erzeuge Löschsatz.
      IF PIT_OT3_WRGP-UPD_FLAG = C_DEL.
*       Erzeuge Löschsatz für Warengruppe.
        PERFORM WRGP_DELETE USING PIT_OT3_WRGP
                                  PI_FILIA_GROUP
                                  GT_IDOC_DATA
                                  G_RETURNCODE
                                  PI_DLDNR    G_DLDLFDNR
                                  G_AKTIVDAT  G_SEGMENT_COUNTER.
*       Weiter zur nächsten Warengruppe.
        CONTINUE.
      ENDIF. " pit_ot3_wrgp-upd_flag = c_del.

*     Falls nur bestimmte Warengruppen an diese Filiale geschickt
*     werden sollen, dann filialabhängige Prüfung nötig.
      IF PI_FILIA_GROUP-SALLMG = SPACE.
*       Prüfe, ob die Warengruppe dieser Filiale zugeordnet ist.
        CALL FUNCTION 'PLANT_ALL_MATERIAL_GROUP_GET'
          EXPORTING
            PI_FILIALE     = PI_FILIA_GROUP-KUNNR
            PI_WARENGRUPPE = PIT_OT3_WRGP-MATKL
          TABLES
            PE_T_WRF6      = T_WRF6
          EXCEPTIONS
            NO_WRF6_RECORD = 01
            NO_WRGP_FOUND  = 02.

        READ TABLE T_WRF6 INDEX 1.
      ENDIF. " pi_filia_group-sallmg = space.

*     Falls die Warengruppe dieser Filiale zugeordnet ist oder
*     alle Warengruppen an diese Filiale versendet werden sollen.
      IF ( SY-SUBRC = 0 AND T_WRF6-WDAUS = SPACE ) OR
           PI_FILIA_GROUP-SALLMG <> SPACE.
*       Einlesen der Daten dieser Basiswarengruppe.
        CALL FUNCTION 'MERCHANDISE_GROUP_SELECT'
          EXPORTING
            MATKL       = PIT_OT3_WRGP-MATKL
            SPRAS       = PI_FILIA_GROUP-SPRAS
            WG_BEZ      = 'X'
          TABLES
            O_WWG01     = T_WRGP_BASE_DATA
          EXCEPTIONS
            NO_BASIS_MG = 01.

*       Falls Warengruppe vorhanden.
        IF SY-SUBRC = 0.
          READ TABLE T_WRGP_BASE_DATA INDEX 1.

*         Merke 'Firstkey'.
          IF G_NEW_FIRSTKEY <> SPACE.
            G_FIRSTKEY = T_WRGP_BASE_DATA-MATKL.
            CLEAR: G_NEW_FIRSTKEY.
          ENDIF.                         " G_NEW_FIRSTKEY <> SPACE.

***     Start Of Changes By Suri : 25.12.2019
***     For Chaning Material Group IDoc Segments to 1000
*          CALL FUNCTION 'MASTERIDOC_CREATE_DLPWRGP'
*               EXPORTING
*                    PI_DEBUG           = ' '
*                    PI_BASE_MATKL      = T_WRGP_BASE_DATA
*                    PI_AKTIVDAT        = G_AKTIVDAT
*                    PI_DLDNR           = PI_DLDNR
*                    PX_DLDLFDNR        = G_DLDLFDNR
*                    PI_VKORG           = PI_FILIA_GROUP-VKORG
*                    PI_VTWEG           = PI_FILIA_GROUP-VTWEG
*                    PI_FILIA           = PI_FILIA_GROUP-FILIA
*                    PI_EXPRESS         = ' '
*                    PI_LOESCHEN        = ' '
*                    PI_E1WPW02         = E1WPW02
*                    PI_E1WPW05         = E1WPW05
*                    PI_E1WPW03         = E1WPW03
*                    PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*                    PI_FILIA_CONST     = I_FILIA_CONST
*                    PI_MESTYPE         = PI_MESTYPE
*               IMPORTING
*                    PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
*               changing
*                    PXT_IDOC_DATA      = GT_IDOC_DATA
*               EXCEPTIONS
*                    DOWNLOAD_EXIT      = 1.

          CALL FUNCTION 'ZZMASTERIDOC_CREATE_DLPWRGP'
            EXPORTING
              PI_DEBUG           = ' '
              PI_BASE_MATKL      = T_WRGP_BASE_DATA
              PI_AKTIVDAT        = G_AKTIVDAT
              PI_DLDNR           = PI_DLDNR
              PX_DLDLFDNR        = G_DLDLFDNR
              PI_VKORG           = PI_FILIA_GROUP-VKORG
              PI_VTWEG           = PI_FILIA_GROUP-VTWEG
              PI_FILIA           = PI_FILIA_GROUP-FILIA
              PI_EXPRESS         = ' '
              PI_LOESCHEN        = ' '
              PI_E1WPW02         = E1WPW02
              PI_E1WPW05         = E1WPW05
              PI_E1WPW03         = E1WPW03
              PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
              PI_FILIA_CONST     = I_FILIA_CONST
              PI_MESTYPE         = PI_MESTYPE
            IMPORTING
              PX_SEGMENT_COUNTER = G_SEGMENT_COUNTER
            CHANGING
              PXT_IDOC_DATA      = GT_IDOC_DATA
            EXCEPTIONS
              DOWNLOAD_EXIT      = 1.
***     End Of Changes By Suri : 25.12.2019
*         Es sind Fehler beim Download aufgetreten'
          IF SY-SUBRC = 1.
            RAISE ERROR_CODE_1.
          ENDIF.                         " SY-SUBRC = 1.

*       Falls Fehler beim Einlesen der Basiswarengruppe auftraten.
        ELSE.                            " SY-SUBRC <> 0.
*         Falls Fehlerprotokollierung erwünscht.
          IF PI_FILIA_GROUP-ERMOD = SPACE.
*           Falls noch keine Initialisierung des Fehlerprotokolls.
            IF G_INIT_LOG = SPACE.
*             Zwischenspeichern des Returncodes.
              FEHLERCODE = SY-SUBRC.

*             Aufbereitung der Parameter zum schreiben des Headers des
*             Fehlerprotokolls.
              CLEAR: GI_ERRORMSG_HEADER.
              GI_ERRORMSG_HEADER-OBJECT        = C_APPLIKATION.
              GI_ERRORMSG_HEADER-SUBOBJECT     = C_SUBOBJECT.
              GI_ERRORMSG_HEADER-EXTNUMBER     = PI_DLDNR.
              GI_ERRORMSG_HEADER-EXTNUMBER+14  = G_DLDLFDNR.
              GI_ERRORMSG_HEADER-ALUSER        = SY-UNAME.

*             Initialisiere Fehlerprotokoll und erzeuge Header.
              PERFORM APPL_LOG_INIT_WITH_HEADER
                      USING GI_ERRORMSG_HEADER.

*             Merke, daß Fehlerprotokoll initialisiert wurde.
              G_INIT_LOG = 'X'.
            ENDIF.                       " G_INIT_LOG = SPACE.

*           Bereite Parameter zum schreiben der Fehlerzeile auf.
            CLEAR: GI_MESSAGE.
            GI_MESSAGE-MSGTY     = C_MSGTP_ERROR.
            GI_MESSAGE-MSGID     = C_MESSAGE_ID.
            GI_MESSAGE-PROBCLASS = C_PROBCLASS_SEHR_WICHTIG.
*           'Fehler beim Einlesen der Basiswarengruppe &'
            GI_MESSAGE-MSGNO     = '101'.
            GI_MESSAGE-MSGV1     = PIT_OT3_WRGP-MATKL.

*           Schreibe Fehlerzeile für Application-Log und WDLSO.
            G_OBJECT_KEY = PIT_OT3_WRGP-MATKL.
            PERFORM APPL_LOG_WRITE_SINGLE_MESSAGE  USING GI_MESSAGE.

          ENDIF.                         " PI_FILIA_GROUP-ERMOD = SPACE.

*         Ändern der Status-Kopfzeile, falls nötig.
          IF G_STATUS < 3.                   " 'Fehlende Daten'
*           Aufbereiten der Parameter zum Ändern der Status-Kopfzeile.
            CLEAR: GI_STATUS_HEADER.
            GI_STATUS_HEADER-DLDNR = PI_DLDNR.
            GI_STATUS_HEADER-GESST = C_STATUS_FEHLENDE_DATEN.

*           Korrigiere Status-Kopfzeile auf "Fehlerhaft".
            PERFORM STATUS_WRITE_HEAD
                    USING  'X'  GI_STATUS_HEADER  PI_DLDNR
                           G_RETURNCODE.

*           Aktualisiere Aufbereitungsstatus.
            G_STATUS = 3.                  " 'Fehlende Daten'
          ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*         Aufbereiten der Parameter zum Ändern der
*         Status-Positionszeile.
          CLEAR: GI_STATUS_POS.
          GI_STATUS_POS-DLDNR  = PI_DLDNR.
          GI_STATUS_POS-LFDNR  = G_DLDLFDNR.
          GI_STATUS_POS-ANLOZ  = G_ERR_COUNTER.

*         Aktualisiere Aufbereitungsstatus für Positionszeile,
*         falls nötig.
          IF G_STATUS_POS < 3.                   " 'Fehlende Daten'
            GI_STATUS_POS-GESST = C_STATUS_FEHLENDE_DATEN.

            G_STATUS_POS = 3.                    " 'Fehlende Daten'
          ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*         Schreibe Status-Positionszeile.
          PERFORM STATUS_WRITE_POS USING 'X' GI_STATUS_POS  G_DLDLFDNR
                                             G_RETURNCODE.

*         Falls Abbruch bei Fehler erwünscht.
          IF PI_FILIA_GROUP-ERMOD <> SPACE.
*           Abbruch des Downloads.
            RAISE ERROR_CODE_1.
          ENDIF.                         " PI_FILIA_GROUP-ERMOD.
        ENDIF.                           " SY-SUBRC <> 0.

      ELSE.
*       Aktualisiere Zählvariable für ignorierte Objekte für
*       spätere Statistikausgabe.
        ADD 1 TO GI_STAT_COUNTER-WRGP_IGN.
      ENDIF. " sy-subrc = 0 or pi_filia_group-sallmg <> space.
    ENDLOOP.                           " AT PIT_OT3_WRGP.

*   Erzeuge letztes IDOC, falls nötig .
    IF G_SEGMENT_COUNTER > 0.
      PERFORM IDOC_CREATE USING  GT_IDOC_DATA
                                 PI_MESTYPE
                                 C_IDOCTYPE_WRGP
                                 G_SEGMENT_COUNTER
                                 G_ERR_COUNTER
                                 G_FIRSTKEY
                                 PIT_OT3_WRGP-MATKL
                                 PI_DLDNR  G_DLDLFDNR
                                 PI_FILIA_GROUP-FILIA
                                 I_FILIA_CONST.

    ENDIF.                             " G_SEGMENT_COUNTER > 0

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
  ENDIF.                               " E1WPW01 <> SPACE.


ENDFORM.                               " WRGP_DOWNLOAD_CHANGE_MODE


*eject
************************************************************************
FORM ARTICLE_GROUP_READ
     TABLES   PET_WRGP_DATA  STRUCTURE GT_WRGP_DATA
              PET_WRGP_MWSKZ STRUCTURE GT_WRGP_MWSKZ
     USING    PI_SPRAS       LIKE T001W-SPRAS
              PI_VKORG       LIKE WPSTRUC-VKORG
              PI_VTWEG       LIKE WPSTRUC-VTWEG
              PI_FILIA       LIKE T001W-WERKS
              PI_AKTIVDAT    LIKE WPSTRUC-DATUM
     CHANGING VALUE(PE_FEHLERCODE) LIKE SYST-SUBRC
              PI_DLDNR       LIKE WDLS-DLDNR
              PI_DLDLFDNR    LIKE WDLSP-LFDNR
              PI_MATKL       LIKE WWG02-MATKL
              PI_WERTART     LIKE WWG02-WWGPA
              PI_ERMOD       LIKE TWPFI-ERMOD
              PI_WGBEZ       LIKE WWG02-WGBEZ
              PI_SEGMENT_COUNTER LIKE G_SEGMENT_COUNTER
              PI_E1WPW05     LIKE WPSTRUC-MODUS.
************************************************************************
* FUNKTION:
* Einlesen der Hierarchien zu einer Basiswarengruppe.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_WRGP_DATA : Tabelle der eingelesenen Warengruppen.
*
* PET_WRGP_MWSKZ: Tabelle der zugehörigen Steuerkennzeichen.
*
* PI_SPRAS      : Sprachenschlüssel.
*
* PI_VKORG       : Verkaufsorganisation.
*
* PI_VTWEG       : Vertriebsweg.
*
* PI_FILIA       : Filiale.
*
* PI_AKTIVDAT   : Datum zu dem versendet werden soll.
*
* PE_FEHLERCODE : <> 0: Schwerer Fehler, sonst 0.
*
* PI_DLDNR      : Downloadnummer für Statusverfolgung.
*
* PI_DLDLFDNR   : Laufende Nr. der Positionszeile für Statusverfolgung.
*
* PI_MATKL      : Basiswarengruppe.
*
* PI_WERTART    : Warengruppenwertartikel der Basiswarengruppe.
*
* PI_ERMOD      : = 'X', wenn Downloadabbruch bei Fehler erwünscht.
*
* PI_WGBEZ      : Bezeichnung der Basiswarengruppe.
*
* PI_SEGMENT_COUNTER: Segmentzähler.
*
* PI_E1WPW05    : = 'X', wenn Segment E1WPW05 (Steuern) aufbereitet
*                        werden soll.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: BEGIN OF T_WRGP_CLASS_DATA OCCURS 200.
          INCLUDE STRUCTURE WGHIER.
        DATA: END OF T_WRGP_CLASS_DATA.

* Nur als Dummy für Aufruf des FB's.
  DATA: BEGIN OF T_SACO OCCURS 5.
          INCLUDE STRUCTURE GT_KOND_ART.
        DATA: END OF T_SACO.


  REFRESH: PET_WRGP_DATA, T_WRGP_CLASS_DATA, PET_WRGP_MWSKZ.
  CLEAR:   PE_FEHLERCODE.

* Einlesen aller übergeordneten Klassen.
  CALL FUNCTION 'MERCHANDISE_GROUP_HIER_SELECT'
    EXPORTING
      MATKL       = PI_MATKL
      SPRAS       = PI_SPRAS
      WG_BEZ      = 'X'
      WG_STUFEN   = C_WGSTUFEN
    TABLES
      O_WGHIER    = T_WRGP_CLASS_DATA
    EXCEPTIONS
      NO_BASIS_MG = 01
      NO_MG_HIER  = 02.

* Falls keine übergeordnete Hierarchie gefunden wurde.
  IF SY-SUBRC = 2.
*   Übernehme Basiswarengruppe in interne Tabelle.
    REFRESH: T_WRGP_CLASS_DATA.
    CLEAR: T_WRGP_CLASS_DATA.
    T_WRGP_CLASS_DATA-CLAS1 = PI_MATKL.
    T_WRGP_CLASS_DATA-CLTX1 = PI_WGBEZ.
    APPEND T_WRGP_CLASS_DATA.
  ENDIF.                               " SY-SUBRC = 2.


* Falls Segment E1WPW05 (Warengruppen-Steuern)
* gefüllt werden muß und ein Warengruppenwertartikel zur Steuerfindung
* vorhanden ist.
  IF PI_E1WPW05 <> SPACE AND PI_WERTART <> SPACE.
*   Besorge Steuern zum Warengruppenwertartikel.
    CALL FUNCTION 'SALES_CONDITIONS_READ'
      EXPORTING
        PI_DATAB                    = PI_AKTIVDAT
        PI_DATBI                    = PI_AKTIVDAT
        PI_EAN11                    = ' '
        PI_INCFI                    = 'X'
        PI_MATNR                    = PI_WERTART
        PI_VKORG                    = PI_VKORG
        PI_VTWEG                    = PI_VTWEG
        PI_WERKS                    = PI_FILIA
      TABLES
        PE_T_SACO                   = T_SACO
        PE_T_TAXK                   = PET_WRGP_MWSKZ
      EXCEPTIONS
        NO_BUKRS_FOUND              = 01
        PLANT_NOT_FOUND             = 02
        ORG_STRUCTURE_NOT_COMPLETED = 03
        VKORG_NOT_FOUND             = 04
        MATERIAL_NOT_FOUND          = 05
        ERROR_MESSAGE               = 06
        OTHERS                      = 07.

*   Prüfe, ob Steuerkennzeichen ermittelt wurden.
    READ TABLE PET_WRGP_MWSKZ INDEX 1.

* Falls keine Steuern übertragen werden müssen, dann setze
* SY-SUBRC = 0.
  ELSE. " pi_e1wpw05 = SPACE or pi_wertart = SPACE.
    READ TABLE T_WRGP_CLASS_DATA INDEX 1.
  ENDIF. " pi_e1wpw05 <> space and pi_wertart <> space.

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
      GI_MESSAGE-MSGTY     = C_MSGTP_ERROR.
      GI_MESSAGE-MSGID     = C_MESSAGE_ID.
      GI_MESSAGE-PROBCLASS = C_PROBCLASS_SEHR_WICHTIG.
*     'Warengruppenwertartikel & der Warengruppe & nicht
*      vollständig gepflegt'.
      GI_MESSAGE-MSGNO     = '103'.
      GI_MESSAGE-MSGV1     = PI_WERTART.
      GI_MESSAGE-MSGV2     = PI_MATKL.

*     Schreibe Fehlerzeile für Application-Log und WDLSO.
      G_OBJECT_KEY = PI_MATKL.
      PERFORM APPL_LOG_WRITE_SINGLE_MESSAGE USING  GI_MESSAGE.

    ENDIF.                             " PI_ERMOD = SPACE.

*   Ändern der Status-Kopfzeile, falls nötig.
    IF G_STATUS < 3.                 " 'Fehlende Daten'
      CLEAR: GI_STATUS_HEADER.
      GI_STATUS_HEADER-DLDNR = PI_DLDNR.
      GI_STATUS_HEADER-GESST = C_STATUS_FEHLENDE_DATEN.

*     Korrigiere Status-Kopfzeile auf "Fehlerhaft".
      PERFORM STATUS_WRITE_HEAD USING  'X'  GI_STATUS_HEADER
                                       PI_DLDNR   G_RETURNCODE.
*     Aktualisiere Aufbereitungsstatus.
      G_STATUS = 3.                  " 'Fehlende Daten'
    ENDIF. " G_STATUS < 3.  " 'Fehlende Daten'

*   Aufbereiten der Parameter zum Ändern der Status-Positionszeile.
    CLEAR: GI_STATUS_POS.
    GI_STATUS_POS-DLDNR  = PI_DLDNR.
    GI_STATUS_POS-LFDNR  = PI_DLDLFDNR.
    GI_STATUS_POS-ANLOZ  = G_ERR_COUNTER.
    GI_STATUS_POS-ANSEG  = PI_SEGMENT_COUNTER.
    GI_STATUS_POS-STKEY  = G_FIRSTKEY.
    GI_STATUS_POS-LTKEY  = PI_MATKL.

*   Aktualisiere Aufbereitungsstatus für Positionszeile,
*   falls nötig.
    IF G_STATUS_POS < 3.                   " 'Fehlende Daten'
      GI_STATUS_POS-GESST = C_STATUS_FEHLENDE_DATEN.

      G_STATUS_POS = 3.                    " 'Fehlende Daten'
    ENDIF. " g_status_pos < 3.             " 'Fehlende Daten'

*   Schreibe Status-Positionszeile.
    PERFORM STATUS_WRITE_POS USING 'X' GI_STATUS_POS  PI_DLDLFDNR
                                       G_RETURNCODE.
*   Falls Fehlerprotokollierung erwünscht.
    IF PI_ERMOD = SPACE.
*     Verlassen der Aufbereitung dieser Basiswrgp., falls Einlesefehler.
      EXIT.
*   Falls Abbruch bei Fehler erwünscht.
    ELSE.                              " PI_ERMOD <> SPACE.
*     Abbruch des Downloads.
      RAISE DOWNLOAD_EXIT.
    ENDIF.                             " PI_ERMOD = SPACE.

* Es konnten Steuerkennzeichen eingelesen werden.
  ELSE.                                " SY-SUBRC = 0.   Steuern
*   Übertragen der Daten in Ausgabetabellen.
*   Hierarchien.
    SORT T_WRGP_CLASS_DATA BY STUFE.
    LOOP AT T_WRGP_CLASS_DATA.
      CLEAR: PET_WRGP_DATA.
      PET_WRGP_DATA-MATKL      = T_WRGP_CLASS_DATA-CLAS1.
      PET_WRGP_DATA-WGBEZ      = T_WRGP_CLASS_DATA-CLTX1.
      PET_WRGP_DATA-HIERARCHIE = T_WRGP_CLASS_DATA-STUFE.
      PET_WRGP_DATA-VERKNUEPFG = T_WRGP_CLASS_DATA-CLAS2.
      APPEND PET_WRGP_DATA.

*     Falls der letzte Satz vorliegt.
      IF T_WRGP_CLASS_DATA-HENDE <> SPACE.
        CLEAR: PET_WRGP_DATA.
        PET_WRGP_DATA-MATKL      = T_WRGP_CLASS_DATA-CLAS2.
        PET_WRGP_DATA-WGBEZ      = T_WRGP_CLASS_DATA-CLTX2.
        PET_WRGP_DATA-HIERARCHIE = T_WRGP_CLASS_DATA-HSTUFE.
        APPEND PET_WRGP_DATA.
      ENDIF. " T_WRGP_CLASS_DATA-HENDE <> SPACE.

    ENDLOOP.                           " AT T_WRGP_CLASS_DATA.
  ENDIF.                               " SY-SUBRC <> 0, Einlesen Steuern


ENDFORM.                               " ARTICLE_GROUP_READ


* eject.
************************************************************************
FORM WRGP_DELETE
     USING  PI_OT3_WRGP    STRUCTURE GT_OT3_WRGP
            PI_FILIA_GROUP STRUCTURE GT_FILIA_GROUP
   CHANGING PXT_IDOC_DATA  TYPE      SHORT_EDIDD
            VALUE(PE_FEHLERCODE) LIKE SYST-SUBRC
            PI_DLDNR       LIKE WDLS-DLDNR
            PI_DLDLFDNR    LIKE WDLSP-LFDNR
            PI_AKTIVDAT    LIKE WPSTRUC-DATUM
            PX_SEGCNT      LIKE G_SEGMENT_COUNTER.
************************************************************************
* FUNKTION:
* Erzeuge Löschsatz für Warengruppe.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_OT3_WRGP   : Struktur mit Warengruppe, die gelöscht werden soll.
*
* PI_FILIA_GROUP: Filialeabhängige Konstanten.
*
* PXT_IDOC_DATA : Tabelle der IDOC-Daten.
*
* PE_FEHLERCODE : = '1', wenn Datenumsetzung mißlungen, sonst '0'.
*
* PI_DLDNR      : Downloadnummer für Statusverfolgung.
*
* PI_DLDLFDNR   : Laufende Nr. der Positionszeile für Statusverfolgung.
*
* PI_AKTIVDAT   : Löschdatum der Aufbereitung.
*
* PX_SEGCNT     : Segmentzähler.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: SEG_LOCAL_CNT TYPE I,
        E1WPW05_CNT   TYPE I,
        E1WPW03_CNT   TYPE I.

  DATA: BEGIN OF I_FILIA_CONST.
          INCLUDE STRUCTURE WPFILCONST.
        DATA: END OF I_FILIA_CONST.



* Rücksetze Temporärtabelle für IDOC-Daten.
  REFRESH: GT_IDOC_DATA_TEMP.

* Rücksetze Fehlercode.
  CLEAR: PE_FEHLERCODE.

* Übernehme Filialkonstanten in eine andere Struktur.
  MOVE-CORRESPONDING PI_FILIA_GROUP TO I_FILIA_CONST.

* Aufbau ID-Segment.
  CLEAR: E1WPW01.
  E1WPW01-FILIALE    = PI_FILIA_GROUP-KUNNR.
  E1WPW01-AKTIVDATUM = PI_AKTIVDAT.
  E1WPW01-AENDDATUM  = '00000000'.
  E1WPW01-AENDERER   = ' '.
  E1WPW01-WARENGR    = PI_OT3_WRGP-MATKL.
  E1WPW01-AENDKENNZ  = C_DELETE.

* Erzeuge temporären IDOC-Segmentsatz.
  GT_IDOC_DATA_TEMP-SEGNAM = C_E1WPW01_NAME.
  GT_IDOC_DATA_TEMP-SDATA  = E1WPW01.
  APPEND GT_IDOC_DATA_TEMP.

* aktualisiere Segmentzähler.
  ADD 1 TO SEG_LOCAL_CNT.

* Merke 'Firstkey'.
  IF G_NEW_FIRSTKEY <> SPACE.
    G_FIRSTKEY = PI_OT3_WRGP-MATKL.
    CLEAR: G_NEW_FIRSTKEY.
  ENDIF.                         " G_NEW_FIRSTKEY <> SPACE.

*********************************************************************
***********************   U S E R - E X I T  ************************
  CALL CUSTOMER-FUNCTION '001'
    EXPORTING
      PI_E1WPW05_CNT     = E1WPW05_CNT
      PI_E1WPW03_CNT     = E1WPW03_CNT
      PX_SEGMENT_COUNTER = PX_SEGCNT
      PI_SEG_LOCAL_CNT   = SEG_LOCAL_CNT
      PI_DLDNR           = PI_DLDNR
      PI_DLDLFDNR        = PI_DLDLFDNR
      PI_ERMOD           = PI_FILIA_GROUP-ERMOD
      PI_FIRSTKEY        = G_FIRSTKEY
      PX_INIT_LOG        = G_INIT_LOG
      PX_STATUS          = G_STATUS
      PX_STATUS_POS      = G_STATUS_POS
      PX_ERR_COUNTER     = G_ERR_COUNTER
      PI_FILIA_CONST     = I_FILIA_CONST
    IMPORTING
      PX_INIT_LOG        = G_INIT_LOG
      PX_STATUS          = G_STATUS
      PX_STATUS_POS      = G_STATUS_POS
      PE_FEHLERCODE      = PE_FEHLERCODE
      PX_ERR_COUNTER     = G_ERR_COUNTER
      PI_SEG_LOCAL_CNT   = SEG_LOCAL_CNT
    TABLES
      PXT_IDOC_DATA_TEMP = GT_IDOC_DATA_TEMP
      PIT_IDOC_DATA      = GT_IDOC_DATA_DUMMY
    CHANGING
      PIT_IDOC_DATA_NEW  = PXT_IDOC_DATA.

*   Falls Umsetzfehler auftraten.
  IF PE_FEHLERCODE <> 0.
*     Falls Fehlerprotokollierung erwünscht.
    IF PI_FILIA_GROUP-ERMOD = SPACE.
*       Falls der Satz zum heutigen Datum gelöscht werden soll.
      IF PI_AKTIVDAT <= SY-DATUM.
*         Fülle allgemeinen Objektschlüssel.
        G_OBJECT_KEY    = PI_OT3_WRGP-MATKL.
        G_OBJECT_DELETE = 'X'.

*         Ergänze Fehlerobjekttabelle um einen zusätzlichen Eintrag.
        PERFORM ERROR_OBJECT_WRITE.

*         Rücksetze Löschkennzeichen für Fehlerobjekttabelle WDLSO.
        CLEAR: G_OBJECT_DELETE.
      ENDIF. " pi_aktivdat <= sy-datum.

*       Verlassen der Aufbereitung dieser Basiswarengruppe.
      EXIT.
*     Falls Abbruch bei Fehler erwünscht.
    ELSE.                        " PI_ERMOD <> SPACE.
*       Abbruch des Downloads.
      RAISE ERROR_CODE_1.
    ENDIF.                       " pi_filia_group-ermod = SPACE.

*   Falls Umschlüsselung fehlerfrei.
  ELSE. " pe_fehlercode = 0.
*     Übernehme die IDOC-Daten aus Temporärtabelle.
    PERFORM IDOC_DATA_ASSUME TABLES  GT_IDOC_DATA_TEMP
                             USING   PXT_IDOC_DATA
                                     PX_SEGCNT
                                     SEG_LOCAL_CNT.

  ENDIF.                             " pe_fehlercode <> 0.
*********************************************************************


ENDFORM.                               " WRGP_DELETE


*eject
************************************************************************
FORM WRGP_CHANGE_MODE_PREPARE
     TABLES PIT_OT3_WRGP           STRUCTURE GT_OT3_WRGP
            PIT_FILTER_SEGS        STRUCTURE GT_FILTER_SEGS
            PIT_WORKDAYS           STRUCTURE GT_WORKDAYS
            PXT_MASTER_IDOCS       STRUCTURE GT_MASTER_IDOCS
            PIT_INDEPENDENCE_CHECK STRUCTURE GT_INDEPENDENCE_CHECK
            PXT_RFCDEST            STRUCTURE GT_RFCDEST
            PXT_WDLSP_BUF          STRUCTURE GT_WDLSP_BUF
            PXT_WDLSO_PARALLEL     STRUCTURE GT_WDLSO_PARALLEL
     USING  PI_FILIA_GROUP         STRUCTURE GT_FILIA_GROUP
            PX_INDEPENDENCE_CHECK  STRUCTURE GT_INDEPENDENCE_CHECK
            PX_STAT_COUNTER        STRUCTURE GI_STAT_COUNTER
            PI_IDOCTYPE            LIKE EDIMSG-IDOCTYP
            PI_MESTYPE             LIKE EDIMSG-MESTYP
            PI_DLDNR               LIKE G_DLDNR
            PI_ERSTDAT             LIKE SYST-DATUM
            PI_PARALLEL            LIKE WPSTRUC-PARALLEL
            PI_SERVER_GROUP        LIKE WPSTRUC-SERVERGRP
            PX_TASKNAME            LIKE WPSTRUC-COUNTER6
            PX_SND_JOBS            LIKE WPSTRUC-COUNTER6.
************************************************************************
* FUNKTION:
* IDOC-Aufbereitung der Warengruppen.
* Wenn das Flag PI_PARALLEL gesetzt ist, dann wird die Aufbereitung in
* einem parallelen Task durchgeführt.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_OT3_WRGP          : Warengruppen: Objekttabelle 3.
*
* PIT_FILTER_SEGS       : Reduzierinformationen.
*
* PIT_WORKDAYS          : Tabelle der Arbeitstage des
*                         Betrachtungszeitraums.
* PXT_MASTER_IDOCS      : Tabelle der kopierfähigen IDOC's
*
* PIT_INDEPENDENCE_CHECK: Tabelle der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PXT_RFCDEST           : Tabelle der fehlerhaften Tasks
*
* PXT_WDLSP_BUF         : Tabelle der erzeugten Status-Positionszeilen.
*
* PXT_WDLSO_PARALLEL    : Tabelle der nachzubereitenden fehlerhaften
*                         Objekte.
* PI_FILIA_GROUP        : Daten einer Filiale der Filialgruppe.
*
* PX_INDEPENDENCE_CHECK : Tabellenkopfzeile der filialunabhängigen
*                         Objekte pro Filiale der Filialgruppe.
* PX_STAT_COUNTER       : Feldleiste für Statistikinformationen.
*
* PI_IDOCTYPE           : Name der Original Zwischenstruktur.
*
* PI_MESTYPE            : Zu verwendender Nachrichtentyp für
*                         Objekt Warengruppen.
* PI_DLDNR              : Downloadnummer
*
* PI_ERSTDAT            : Datum: jetziges Versenden.
*
* PI_PARALLEL           : = 'X', wenn Parallelverarbeitung erwünscht,
*                                sonst SPCACE.
* PI_SERVER_GROUP       : Name der Server-Gruppe für
*                         Parallelverarbeitung.
* PX_TASKNAME           : Identifiziernder Name des aktuellen Tasks.
*
* PX_SND_JOBS           : Anzahl der gestarteten parallelen Tasks.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Feldleiste für Statistikinformation.
  DATA: BEGIN OF I_STAT_COUNTER.
          INCLUDE STRUCTURE GI_STAT_COUNTER.
        DATA: END OF I_STAT_COUNTER.


* Falls nicht parallelisiert werden soll.
  IF PI_PARALLEL IS INITIAL.
*   IDOC-Aufbereitung der Warengruppen.
    CALL FUNCTION 'POS_WRGP_CHG_MODE_PREPARE'
      EXPORTING
        PI_FILIA_GROUP         = PI_FILIA_GROUP
        PI_IDOCTYPE            = PI_IDOCTYPE
        PI_MESTYPE             = PI_MESTYPE
        PI_DLDNR               = PI_DLDNR
        PI_ERSTDAT             = PI_ERSTDAT
        PI_PARALLEL            = PI_PARALLEL
        PI_INDEPENDENCE_CHECK  = PX_INDEPENDENCE_CHECK
      IMPORTING
        PE_INDEPENDENCE_CHECK  = PX_INDEPENDENCE_CHECK
        PE_STAT_COUNTER        = I_STAT_COUNTER
      TABLES
        PIT_OT3_WRGP           = PIT_OT3_WRGP
        PIT_FILTER_SEGS        = PIT_FILTER_SEGS
        PIT_WORKDAYS           = PIT_WORKDAYS
        PIT_MASTER_IDOCS       = PXT_MASTER_IDOCS
        PIT_INDEPENDENCE_CHECK = PIT_INDEPENDENCE_CHECK.

*   Aktualisiere Statisktikinformation.
    PX_STAT_COUNTER-WRGP_IGN = I_STAT_COUNTER-WRGP_IGN.

* Falls  parallelisiert werden soll.
  ELSE. " not pi_parallel is initial.
*   Setze neuen Tasknamen.
    ADD 1 TO PX_TASKNAME.

*   Übernehme Variablen für Wiederaufsetzen im Fehlerfalle in
*   interne Tabelle.
    CLEAR: GT_TASK_VARIABLES.
    GT_TASK_VARIABLES-TASKNAME = PX_TASKNAME.
    GT_TASK_VARIABLES-MESTYPE  = PI_MESTYPE.
    APPEND GT_TASK_VARIABLES.

*   IDOC-Aufbereitung der Warengruppen in parallelem Task.
    CALL FUNCTION 'POS_WRGP_CHG_MODE_PREPARE'
      STARTING NEW TASK PX_TASKNAME
      DESTINATION IN GROUP PI_SERVER_GROUP
      PERFORMING RETURN_WRGP_CHG_MODE_PREPARE ON END OF TASK
      EXPORTING
        PI_FILIA_GROUP         = PI_FILIA_GROUP
        PI_IDOCTYPE            = PI_IDOCTYPE
        PI_MESTYPE             = PI_MESTYPE
        PI_DLDNR               = PI_DLDNR
        PI_ERSTDAT             = PI_ERSTDAT
        PI_PARALLEL            = PI_PARALLEL
        PI_INDEPENDENCE_CHECK  = PX_INDEPENDENCE_CHECK
      TABLES
        PIT_OT3_WRGP           = PIT_OT3_WRGP
        PIT_FILTER_SEGS        = PIT_FILTER_SEGS
        PIT_WORKDAYS           = PIT_WORKDAYS
        PIT_MASTER_IDOCS       = PXT_MASTER_IDOCS
        PIT_INDEPENDENCE_CHECK = PIT_INDEPENDENCE_CHECK
      EXCEPTIONS
        COMMUNICATION_FAILURE  = 1
        SYSTEM_FAILURE         = 2
        RESOURCE_FAILURE       = 3.

*   Falls eine Parallelverarbeitung gerade nicht möglich ist, dann
*   dann arbeite sequentiell.
    IF SY-SUBRC <> 0.
*     Falls Probleme mit dem Zielsystem auftraten.
      IF SY-SUBRC <> 3.
        CLEAR: PXT_RFCDEST.

*       Aktualisiere Fehlertabelle für Zielsysteme.
        PXT_RFCDEST-SUBRC = SY-SUBRC.
        CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
          IMPORTING
            RFCDEST = PXT_RFCDEST-RFCDEST.

*       Aktualisiere System-Zeitstempel
        COMMIT WORK.

        PXT_RFCDEST-DATUM    = SY-DATUM.
        PXT_RFCDEST-UZEIT    = SY-UZEIT.
        PXT_RFCDEST-NO_START = 'X'.
        PXT_RFCDEST-FILIA    = PI_FILIA_GROUP-FILIA.
        APPEND PXT_RFCDEST.
      ENDIF. " sy-subrc <> 3.

*     IDOC-Aufbereitung der Warengruppen sequentiell.
      CALL FUNCTION 'POS_WRGP_CHG_MODE_PREPARE'
        EXPORTING
          PI_FILIA_GROUP         = PI_FILIA_GROUP
          PI_IDOCTYPE            = PI_IDOCTYPE
          PI_MESTYPE             = PI_MESTYPE
          PI_DLDNR               = PI_DLDNR
          PI_ERSTDAT             = PI_ERSTDAT
          PI_PARALLEL            = ' '
          PI_INDEPENDENCE_CHECK  = PX_INDEPENDENCE_CHECK
        IMPORTING
          PE_INDEPENDENCE_CHECK  = PX_INDEPENDENCE_CHECK
          PE_STAT_COUNTER        = I_STAT_COUNTER
        TABLES
          PIT_OT3_WRGP           = PIT_OT3_WRGP
          PIT_FILTER_SEGS        = PIT_FILTER_SEGS
          PIT_WORKDAYS           = PIT_WORKDAYS
          PIT_MASTER_IDOCS       = PXT_MASTER_IDOCS
          PIT_INDEPENDENCE_CHECK = PIT_INDEPENDENCE_CHECK.

*     Aktualisiere Statisktikinformation.
      PX_STAT_COUNTER-WRGP_IGN = I_STAT_COUNTER-WRGP_IGN.

*   Falls eine Parallelverarbeitung möglich ist.
    ELSE. " sy-subrc = 0.
*     Bestimme die verwendetet Destination.
      CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
        IMPORTING
          RFCDEST = GT_RFC_INDICATOR-RFCDEST.

*     Merken der gestarteten Destination.
      GT_RFC_INDICATOR-TASKNAME = PX_TASKNAME.
      APPEND GT_RFC_INDICATOR.

*     Aktualisiere die Anzahl der parallelen Tasks
      ADD 1 TO PX_SND_JOBS.
    ENDIF. " sy-subrc <> 0.

  ENDIF. " pi_parallel is initial.


ENDFORM. " wrgp_change_mode_prepare
