*&---------------------------------------------------------------------*
*&      Module  SMEINH-GEWEI  INPUT
*&---------------------------------------------------------------------*
*  Prüfen ob eine ( richtige ) Gewichtseinheit angegeben wurde.
*  (Analog zu MARA-GEWEI auf Konstruktionsbild).
*
*  Läuft im BTCI-Fall nur on chain-request ab, da in diesem Fall
*  die Daten nur von außen kommen können. Wird ein Initialwert
*  vorgegeben (d.h. löschen des alten Wertes) laufen die Prüfungen ab.
*----------------------------------------------------------------------*
MODULE SMEINH-GEWEI INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK SMEINH-MEINH NE SPACE.

*--- Festhalten der Eingaben -------------------------------------
  MEINH-GEWEI = SMEINH-GEWEI.
  MEINH-BRGEW = SMEINH-BRGEW.
  MEINH-NTGEW = SMEINH-NTGEW.          "cfo/20.9.96

  CHECK RMMZU-OKCODE NE FCODE_MEDE.

*  IF NOT SMEINH-KZBME IS INITIAL.    "note 335937
  if  smeinh-meinh = mara-meins.      "note 335937
    CALL FUNCTION 'MARA_GEWEI'
         EXPORTING
              NTGEW = SMEINH-NTGEW     "cfo/20.9.96
              BRGEW = SMEINH-BRGEW
              GEWEI = SMEINH-GEWEI.
  ELSE.
*   cfo/4.5B-A Im Retail Gewichtseinheit für alternativMEen vor-
*   schlagen.
    IF NOT RMMG2-FLG_RETAIL IS INITIAL
       AND SMEINH-GEWEI IS INITIAL
       AND NOT MARA-GEWEI IS INITIAL.
      SMEINH-GEWEI = MARA-GEWEI.
      MEINH-GEWEI = MARA-GEWEI.
    ENDIF.
*   cfo/4.5B-E
    CALL FUNCTION 'MARA_GEWEI'
         EXPORTING                     " NTGEW = MARA-NTGEW
              BRGEW = SMEINH-BRGEW
              GEWEI = SMEINH-GEWEI.
  ENDIF.
*      EXCEPTIONS      "cfo/29.10.95/besser positionieren
*           MISSING_DIMENSION = 01
*           WRONG_DIMENSION   = 02.
* IF SY-SUBRC NE 0.
*   CLEAR RMMZU-OKCODE.
*   IF BILDFLAG IS INITIAL.
*     BILDFLAG = X.
*     MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   ENDIF.
* ENDIF.

  CHECK BILDFLAG IS INITIAL.

  IF NOT MEINH-KZBME IS INITIAL.
*---- Für die Basis-ME Überprüfung Bruttogewicht / Nettogewicht
* cfo/28.8.96 Prüfstatus ergänzt, damit Prüfung nicht mehrfach kommt
* Prüfstatus zurücksetzen, falls Felder geändert wurden.
    IF ( RMMZU-PS_BRGEW = X ) AND
* Note 316843
* Da im Retail von einem SA auf eine VAR gewechselt werden kann, muß
* auch die MATNR in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für die VAR nicht mehr läuft, wenn die Prüfung schon für
* den SA gelaufen ist und die Daten bei beiden den gleichen Stand haben.
* Zusätzlich wurde hier der Vergleich noch über die MARA gemacht, die
* aber zu diesem Zeitpunkt noch einen veralteten Stand enthält -> SMEINH
* nehmen (MATNR muß aus MARA genommen werden, da nicht in SMEINH drin).
       ( ( UMARA-BRGEW NE SMEINH-BRGEW ) OR
         ( UMARA-NTGEW NE SMEINH-NTGEW ) OR
         ( UMARA-MATNR NE MARA-MATNR   ) ).
      CLEAR RMMZU-PS_BRGEW.
    ENDIF.
* Wenn Prüfstatus = Space, Prüfbaustein aufrufen.
    IF RMMZU-PS_BRGEW = SPACE.
*note 1799356
*      CALL FUNCTION 'GEWICHT_PRUEFUNG'
*           EXPORTING
*                NTGEW      = SMEINH-NTGEW
*                BRGEW      = SMEINH-BRGEW
*                P_MESSAGE  = ' '
*           CHANGING
*                P_PS_BRGEW = RMMZU-PS_BRGEW.
      IF SMEINH-NTGEW GT SMEINH-BRGEW AND NOT SMEINH-BRGEW IS INITIAL.
        RMMZU-PS_BRGEW = 'X'.
*      IF RMMZU-PS_BRGEW NE SPACE.
* Warnung außerhalb als S-Meldung ausgeben, da mehrere Felder betroffen
* sind.

* note 1799356
        CALL FUNCTION 'ME_CHECK_T160M'
          EXPORTING
            I_ARBGB = 'M3'
            I_MSGNR = '176'
            I_MSGVS = '00'           " Messagevariante default '00'
            I_MSGTP_DEFAULT = 'S'
          EXCEPTIONS
            NOTHING     = 00
            SUCCESS     = 01
            WARNING     = 02
            ERROR       = 03.
        CASE SY-SUBRC.
          WHEN '0'.
          WHEN '2'.
* Hinweis 519311
            IF NOT RMMG2-FLG_RETAIL IS INITIAL.
*             ME_FEHLERFLG = OTMEINH.
*             BILDFLAG = X.
              MESSAGE W176.
            ELSE.
              ME_FEHLERFLG = OTMEINH.
              BILDFLAG = X.
              MESSAGE W176(M3).
            ENDIF.
          WHEN '3'.
           IF NOT RMMG2-FLG_RETAIL IS INITIAL.
*             ME_FEHLERFLG = OTMEINH.
*             BILDFLAG = X.
              MESSAGE E176.
            ELSE.
              ME_FEHLERFLG = OTMEINH.
              BILDFLAG = X.
              MESSAGE E176(M3).
            ENDIF.
          WHEN OTHERS.
            IF NOT RMMG2-FLG_RETAIL IS INITIAL.
*           ME_FEHLERFLG = OTMEINH.
*           BILDFLAG = X.
            MESSAGE W176.
            ELSE.
              ME_FEHLERFLG = OTMEINH.
              BILDFLAG = X.
              MESSAGE S176(M3).
            ENDIF.
        ENDCASE.

        RMMZU-CURS_FELD = 'SMEINH-NTGEW'.
      ENDIF.                                           "710099
    ENDIF.
        MARA-NTGEW = SMEINH-NTGEW.                    "cfo/4.0C
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
        UMARA = MARA.
* Note 316843
*       UMARA mit dem aktuellen Wert versorgen (MARA-BRGEW wird erst
*       später auf den aktuellen Wert aus SMEINH-BRGEW gesetzt).
        UMARA-BRGEW = SMEINH-BRGEW.
    ENDIF.

ENDMODULE.                             " SMEINH-GEWEI  INPUT
