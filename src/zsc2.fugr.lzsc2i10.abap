*-------------------------------------------------------------------
*  INCLUDE LMGD2I10 .
*    PAI-Module für Steuerhandling Retail
*-------------------------------------------------------------------

*----------------------------------------------------------------------*
*       Module ST_BILDFLAG_BLAETTERN                                   *
*----------------------------------------------------------------------*
* Wenn das Bildflag   u n d   Blätter-OK-CODE für die Steuern          *
* gesetzt ist, muß das Bildflag temporär zurückgenommen werden.        *
*----------------------------------------------------------------------*
MODULE ST_BILDFLAG_BLAETTERN.

  IF NOT BILDFLAG IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_STFP OR
       RMMZU-OKCODE = FCODE_STPP OR
       RMMZU-OKCODE = FCODE_STNP OR
       RMMZU-OKCODE = FCODE_STLP OR
       RMMZU-OKCODE = FCODE_STDE ).
    CLEAR BILDFLAG.
  ENDIF.

ENDMODULE.                             " ST_BILDFLAG_BLAETTERN

*----------------------------------------------------------------------*
*       Module  AUFNEHMEN_STEUERTAB                                    *
* Aufnahme der Eingaben in die interne Tabelle STEUERTAB.              *
* Vorher wird noch geprüft, ob die Kombination Steuertyp/              *
* Materialklassifikation nach Tabelle TSKM erlaubt ist.                *
* Ist der Steuereintrag noch nicht vorhanden, wird dieser              *
* neu aufgenommen. Zuvor wird gegen die TSTL auf Gültigkeit            *
* geprüft und darüber die zugehörige lfd. Nummer ermittelt.            *
*----------------------------------------------------------------------*
MODULE AUFNEHMEN_STEUERTAB.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  IF SY-STEPL = 1.
    ST_BILDFLAG_OLD = BILDFLAG.
  ENDIF.

  ST_AKT_ZEILE = ST_ERSTE_ZEILE + SY-STEPL.

*----Prüfen Eingabe-------------------------------------------------
  IF NOT MG03STEUER-TAXKM IS INITIAL.

    CALL FUNCTION 'TSKM_SINGLE_READ'
         EXPORTING
              TSKM_TATYP = MG03STEUER-TATYP
              TSKM_TAXKM = MG03STEUER-TAXKM
         IMPORTING
              WTSKM      = TSKM
         EXCEPTIONS
              NOT_FOUND  = 01.

    IF SY-SUBRC NE 0.
      MESSAGE E014 WITH MG03STEUER-TATYP MG03STEUER-TAXKM.
    ENDIF.
  ENDIF.

*----Lesen aktuellen Eintrag----------------------------------------
  READ TABLE STEUERTAB INDEX ST_AKT_ZEILE.

*----Aktualisieren interne Tabelle----------------------------------
  IF SY-SUBRC = 0.
    MOVE MG03STEUER-TAXKM TO STEUERTAB-TAXKM.
    MODIFY STEUERTAB INDEX ST_AKT_ZEILE.
  ELSE.

*----Prüfen, ob Eingabedaten zurückgenommen wurden-----------"BE/181096
*----(Ok-Code Delete funktioniert innerhalb Loop nicht) -----"BE/181096
    IF MG03STEUER-ALAND IS INITIAL AND MG03STEUER-TATYP IS INITIAL.
      EXIT.
    ENDIF.

*----Aufnehmen neuen Eintrag----------------------------------------
    READ TABLE ITSTL WITH KEY MANDT = SY-MANDT
                              TALND = MG03STEUER-ALAND
                              TATYP = MG03STEUER-TATYP.
*                    BINARY SEARCH.                          "BE/181096
    IF SY-SUBRC EQ 0.
      CLEAR STEUERTAB.
      MOVE ITSTL-TALND      TO STEUERTAB-ALAND.
      MOVE ITSTL-LFDNR      TO STEUERTAB-LFDNR.
      MOVE ITSTL-TATYP      TO STEUERTAB-TATYP.
      READ TABLE STEUERTAB.            "implizit über Kopf-Key-Felder
      IF SY-SUBRC EQ 0.
*----Wenn gleicher Eintrag bereits da, nur Hinweis bringen   "BE/181096
*       MESSAGE E044(MH) WITH MG03STEUER-ALAND MG03STEUER-TATYP.
        MESSAGE W044(MH).
      ELSE.
        MOVE MG03STEUER-TAXKM TO STEUERTAB-TAXKM.
        APPEND STEUERTAB.
      ENDIF.
    ELSE.
      MESSAGE E043(MH) WITH MG03STEUER-ALAND MG03STEUER-TATYP.
    ENDIF.
  ENDIF.

ENDMODULE.                             " AUFNEHMEN_STEUERTAB

*----------------------------------------------------------------------*
*       Module  OKCODE_STEUERN_DELETE                                  *
*----------------------------------------------------------------------*
MODULE OKCODE_STEUERN_DELETE.

  CHECK T130M-AKTYP EQ AKTYPH OR T130M-AKTYP EQ AKTYPV.

  IF RMMZU-OKCODE = FCODE_STDE.
*----Loeschen Eintrag - aber keine Vorschlagsdaten-------------
    GET CURSOR LINE ST_ZEILEN_NR.
    ST_AKT_ZEILE = ST_ERSTE_ZEILE + ST_ZEILEN_NR.
    READ TABLE STEUERTAB INDEX ST_AKT_ZEILE.
    IF SY-SUBRC = 0.
      IF STEUERTAB-KZVOR = X.
        MESSAGE E045(MH) WITH STEUERTAB-ALAND STEUERTAB-TATYP.
      ELSE.
        DELETE STEUERTAB INDEX ST_AKT_ZEILE.
      ENDIF.
    ENDIF.
    BILDFLAG = X.
    CLEAR RMMZU-OKCODE.
  ENDIF.

ENDMODULE.                             " OKCODE_STEUERN_DELETE

*----------------------------------------------------------------------*
*       Module  OKCODE_STEUERN                                         *
*----------------------------------------------------------------------*
MODULE OKCODE_STEUERN.

  IF NOT ST_BILDFLAG_OLD IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_STFP OR
       RMMZU-OKCODE = FCODE_STPP OR
       RMMZU-OKCODE = FCODE_STNP OR
       RMMZU-OKCODE = FCODE_STLP  ).
    CLEAR RMMZU-OKCODE.
  ENDIF.
  IF NOT FLG_TC IS INITIAL.
    ST_ERSTE_ZEILE = TC_STEUERN-TOP_LINE - 1.
    TC_STEUERN-LINES = ST_LINES.
    IF TC_STEUERN-TOP_LINE NE TC_STEUERN_TOP_LINE_BUF.
      PERFORM PARAM_SET.
    ENDIF.
  ENDIF.
  PERFORM OK_CODE_STEUERN.

ENDMODULE.                             " OKCODE_STEUERN

*----------------------------------------------------------------------*
*       Module ERZWINGEN_STEUERN                                       *
* Beim Hinzufuegen wird das Steuerbild als Zwangsbild prozessiert,     *
* wenn es noch Einträge in der Steuertabelle gibt, zu denen die        *
* Steuerklassifikation initial ist und die Steuern Mußeingabe sind.    *
* Das Vorschlagsfeld Steuerklassifikation wird Retour mit dem Wert     *
* des Default-Eintrages aus der Steuertabelle versorgt.                *
*----------------------------------------------------------------------*
MODULE ERZWINGEN_STEUERN.

  CHECK T130M-AKTYP = AKTYPH OR T130M-AKTYP = AKTYPV.

  SORT STEUERTAB.                  "Mögliche neue Einträge in Tabelle

  CHECK NOT RMMG2-STEUERMUSS IS INITIAL.   "Mußeingabe über Feldauswahl
  CHECK BILDFLAG IS INITIAL.           "Keine Bild-Wiederholung

* DESCRIBE TABLE STEUERTAB LINES ZAEHLER.
* CHECK ZAEHLER GT 1.

  DATA: P_ACTIVE TYPE BOOLEAN.                          "v note 2533608

*check if MARA-TAKLV is ready for input
  PERFORM MARA_TAKLV_ACTIVE
              CHANGING
                 P_ACTIVE.                              "^ note 2533608

  CLEAR FLAG1.
  LOOP AT STEUERTAB.
    IF NOT STEUERTAB-TAXKM IS INITIAL AND  "Vorschlags-Klassfikation /96
       STEUERTAB-KZVOR = X.            "aus der Vorschlags-Steuer/96
      IF P_ACTIVE = X.                                    "note 2533608
        MARA-TAKLV = STEUERTAB-TAXKM.  "BE/020296
      ENDIF.                                              "note 2533608
      EXIT.                            "BE/020296
    ENDIF.                             "BE/020296
    IF STEUERTAB-TAXKM IS INITIAL AND  "keine Steuerklassifikation
       STEUERTAB-KZVOR = X.            "für die Vorschlags-Steuer
      FLAG1 = X.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF NOT FLAG1 IS INITIAL.
*mk/4.0  fcode ist konfigurierbar
*   if not rmmzu-okcode is initial and rmmzu-okcode ne fcode_steu.
*     message s015.
*   endif.
*   rmmzu-okcode = fcode_steu.     "Aufrufen Zusatzsteuerbild
    CALL FUNCTION 'T133D_ARRAY_READ'
         EXPORTING
              BILDSEQUENZ = BILDSEQUENZ
         TABLES
              TT133D      = TT133D
         EXCEPTIONS
              WRONG_CALL  = 01.
    CLEAR: FLAG1, FLAG2.
    LOOP AT TT133D WHERE ROUTN = FORM_STEU.
      FLAG1 = X.
      IF RMMZU-OKCODE EQ TT133D-FCODE.
        FLAG2 = X.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF NOT RMMZU-OKCODE IS INITIAL AND FLAG2 IS INITIAL.
      MESSAGE S015.
    ENDIF.
    IF NOT FLAG1 IS INITIAL.
      RMMZU-OKCODE = TT133D-FCODE.
    ENDIF.
  ENDIF.

ENDMODULE.                             " ERZWINGEN_STEUERN

*----------------------------------------------------------------------*
*       Module  AUFNEHMEN_TAXIM                                        *
* Aufnehmen des Steuerindikators Einkauf in die interne Tabelle        *
* STEUMMTAB, vorher Prüfung auf Gültigkeit gegen Tabelle TMKM1.        *
*----------------------------------------------------------------------*
MODULE AUFNEHMEN_TAXIM.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* CHECK NOT MG03STEUMM-TAXIM IS INITIAL.                   "BE/140396

*----Prüfen Eingabe-------------------------------------------------
  IF NOT MG03STEUMM-TAXIM IS INITIAL.  "BE/120496
    CALL FUNCTION 'TMKM1_SINGLE_READ'
         EXPORTING
              TMKM1_LAND1 = MG03STEUMM-ALAND
              TMKM1_TAXIM = MG03STEUMM-TAXIM
         IMPORTING
              WTMKM1      = TMKM1
         EXCEPTIONS
              NOT_FOUND   = 01.

    IF SY-SUBRC NE 0.
*----Steuerindikator zum Land nicht vorhanden-----------------------
      MESSAGE E019 WITH MG03STEUMM-ALAND MG03STEUMM-TAXIM.
    ENDIF.
  ENDIF.                               "BE/120496

*----Lesen aktuellen Eintrag----------------------------------------
*  READ TABLE steummtab INDEX 1.                      "TF 4.5B
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

   READ TABLE STEUMMTAB WITH KEY ALAND = COUNTRY. "TF 4.5B

*----Aktualisieren interne Tabelle----------------------------------
  IF SY-SUBRC = 0.
    MOVE MG03STEUMM-TAXIM TO STEUMMTAB-TAXIM.
*   MODIFY steummtab INDEX 1.                         "TF 4.5B
    MODIFY STEUMMTAB INDEX SY-TABIX.                  "TF 4.5B
  ENDIF.

ENDMODULE.                             " AUFNEHMEN_TAXIM
