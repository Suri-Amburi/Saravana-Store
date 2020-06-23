*-------------------------------------------------------------------
* INCLUDE LMGD2O02 .
*   PBO-Module für Steuerhandling Retail
*-------------------------------------------------------------------

*----------------------------------------------------------------------*
*        Module ST_INITIALISIERUNG OUTPUT                              *
* Initialisieren Daten für die Steuerabwicklung                        *
*----------------------------------------------------------------------*
MODULE ST_INITIALISIERUNG OUTPUT.
*wk/4.0 always do tc stuff
*-------Ermitteln Anzahl Steuereinträge--------------------------
  DESCRIBE TABLE STEUERTAB LINES ST_LINES.
  IF NOT FLG_TC IS INITIAL.
    REFRESH CONTROL 'TC_STEUERN' FROM SCREEN SY-DYNNR.
    TC_STEUERN-LINES = ST_LINES.
    TC_STEUERN-TOP_LINE = ST_ERSTE_ZEILE + 1.
    TC_STEUERN_TOP_LINE_BUF = TC_STEUERN-TOP_LINE.
    ASSIGN TC_STEUERN TO <F_TC>.
  ENDIF.
*-------Prüfen Erstaufruf Baustein Steuern-----------------------
  CHECK RMMG2-FLGSTEUER IS INITIAL.
  RMMG2-FLGSTEUER = X.

*mk/4.0  fcode ist konfigurierbar
* if rmmzu-okcode = fcode_steu.
*   clear rmmzu-okcode.
* endif.
  CALL FUNCTION 'T133D_ARRAY_READ'
       EXPORTING
            BILDSEQUENZ = BILDSEQUENZ
       TABLES
            TT133D      = TT133D
       EXCEPTIONS
            WRONG_CALL  = 01.
  CLEAR FLAG1.
  LOOP AT TT133D WHERE ROUTN = FORM_STEU.
    IF RMMZU-OKCODE = TT133D-FCODE.
      CLEAR RMMZU-OKCODE.
      EXIT.
    ENDIF.
  ENDLOOP.
*wk/4.0 set for tc above
*  clear: st_erste_zeile.


*-------Ermitteln aller gültigen Länder-Steuertypen--------------
  READ TABLE ITSTL INDEX 1.
  IF SY-SUBRC NE 0.
    CALL FUNCTION 'TSTL_FULL_READ'
         TABLES
              TTSTL = ITSTL.
  ENDIF.

ENDMODULE.                             " ST_INITIALISIERUNG  OUTPUT

*----------------------------------------------------------------------*
*        Module AUFBEREITEN_STEUERTAB OUTPUT                           *
*                                                                      *
* Die interne Tabelle STEUERTAB wird für die aktuelle Zeile gelesen    *
* und mit den zugehörigen Texten ausgegeben.                           *
* Dabei werden nicht gefüllte Loop-Zeilen zur Erfassung zusätzlicher   *
* Steuertabellen-Einträge angeboten.                                   *
* Bildschirmmodifikation: Vorhandene Steuertabellen-Einträge sind      *
* außer der Steuerklassifikation nicht mehr eingabebereit.             *
*                                                                      *
*----------------------------------------------------------------------*
MODULE AUFBEREITEN_STEUERTAB OUTPUT.

  IF SY-STEPL = 1.
    ST_ZLEPROSEITE = SY-LOOPC.
  ENDIF.

  ST_AKT_ZEILE = ST_ERSTE_ZEILE + SY-STEPL.

*-------Lesen aktuelle Zeile interne Tabelle---------------------
  READ TABLE STEUERTAB INDEX ST_AKT_ZEILE.

  IF SY-SUBRC EQ 0.

*-------Aufbereiten Daten für Loop-Zeile-------------------------
    MOVE STEUERTAB TO MG03STEUER.

    CALL FUNCTION 'T005T_SINGLE_READ'
         EXPORTING
              T005T_SPRAS = SY-LANGU
              T005T_LAND1 = MG03STEUER-ALAND
         IMPORTING
              WT005T      = T005T
         EXCEPTIONS
              NOT_FOUND   = 01.

    CALL FUNCTION 'T685T_SINGLE_READ'
         EXPORTING
              T685T_SPRAS = SY-LANGU
              T685T_KVEWE = KVEWEA
              T685T_KAPPL = KAPPLV
              T685T_KSCHL = MG03STEUER-TATYP
         IMPORTING
              WT685T      = T685T
         EXCEPTIONS
              NOT_FOUND   = 01.

    CALL FUNCTION 'TSKMT_SINGLE_READ'
         EXPORTING
              TSKMT_SPRAS = SY-LANGU
              TSKMT_TATYP = MG03STEUER-TATYP
              TSKMT_TAXKM = MG03STEUER-TAXKM
         IMPORTING
              WTSKMT      = TSKMT
         EXCEPTIONS
              NOT_FOUND   = 01.

*-------Bildschirm-Modifikation für vorhandene Einträge ---------
*   IF MG03STEUER-KZVOR = X.
    PERFORM ST_MODIF_ZEILE.
*   ENDIF.

  ELSE.

*-------Loop-Zeilen für neue Einträge ---------------------------
    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ.
      EXIT FROM STEP-LOOP.
    ENDIF.
  ENDIF.

ENDMODULE.                             " AUFBEREITEN_STEUERTAB OUTPUT

*----------------------------------------------------------------------*
*        Module ST_MAX_SEITE_ERMITTELN OUTPUT                          *
* Aufbereitung für Eintragsanzeige : ' Einträge ___ / ___ '            *
*----------------------------------------------------------------------*
MODULE ST_MAX_SEITE_ERMITTELN OUTPUT.

  ST_EINTRAEGE_C   = ST_LINES.
  IF ST_LINES = 0.
    ST_ERSTE_ZEILE_C = 0.
  ELSE.
    ST_ERSTE_ZEILE_C = ST_ERSTE_ZEILE + 1.
  ENDIF.

ENDMODULE.                             " ST_MAX_SEITE_ERMITTELN  OUTPUT

*------------------------------------------------------------------
* Module MARA-TAKLV OUTPUT
*
* Sichern Vorschlags-Klassifikation.
* Bei Übernahme aus Referenz-Material muss der Vorschlagswert
* im PBO aus MARA selbst gesichert werden, da zu diesem Zeitpunkt
* die LMARA-Struktur noch nicht versorgt ist (weil 1.Datenbild).
*
*------------------------------------------------------------------
MODULE MARA-TAKLV OUTPUT.

  CHECK BILDFLAG IS INITIAL.                            "3.0F BE/140198
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ."3.0F BE/140198

  MOVE MARA-TAKLV TO RETT_TAKLV.

ENDMODULE.

*----------------------------------------------------------------------*
*        Module ANZEIGEN_TAXIM OUTPUT                                  *
* Anzeigen des Steuerindikators für den Einkauf.                       *
*----------------------------------------------------------------------*
MODULE ANZEIGEN_TAXIM OUTPUT.

* READ TABLE steummtab INDEX 1.                        "TF 4.5B

  IF T001W IS INITIAL.                             "Note 637186
   IF T133A-RPSTA = '6'.
      SELECT SINGLE LAND1 into COUNTRY FROM T001W
             where WERKS = RMMW1-FIWRK.
   ELSE.
      SELECT SINGLE LAND1 into COUNTRY FROM T001W
             where WERKS = RMMW1-VZWRK.
   ENDIF.
  ELSE.
   country = T001W-LAND1.
  ENDIF.

  READ TABLE STEUMMTAB WITH KEY ALAND = COUNTRY.   "TF 4.5B
  CHECK SY-SUBRC = 0.

*-------Aufbereiten Daten für Dynpro-----------------------------------
  MOVE STEUMMTAB TO MG03STEUMM.

ENDMODULE.                             " ANZEIGEN_TAXIM  OUTPUT
