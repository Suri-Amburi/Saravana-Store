*&---------------------------------------------------------------------*
*&      Module  CHECK_EAN_ZUS INPUT
*&---------------------------------------------------------------------*
* Prüfen der Eingabe und ggf. interne Vergabe von EANs.
*
* Bemerkung zu MEAN_ME_TAB-EAN_GEPRF:
* ===================================
* In diesem Feld wird festgehalten, ob ein Eintrag bezüglich EAN und
* EAN-Typ bereits korrekt geprüft wurde. Wenn ja, darf eine solche
* Prüfung im Falle einer internen EAN-Vergabe nicht noch einmal
* ablaufen, da dann das Prüfergebnis zu einer Error-Message führt
* (EAN paßt nicht zum Typ). Die Prüfung soll nur ablaufen, wenn sich
* die Eingabe auf dem Dynpro geändert hat. Um dies festzustellen, kann
* nicht die Tabelle LMEAN_ME_TAB herangezogen werden, da sie in diesem
* speziellen Falle NICHT auf dem geforderten Stand ist (Lesen in
* GET-Bausteinen wird dann nicht durchgeführt). Deswegen muß intern
* festgehalten werden, ob sich die EAN seit dem letzen Bilddurchlauf
* auf dem Bild geändert hat.
*----------------------------------------------------------------------*
MODULE CHECK_EAN_ZUS INPUT.

* Start: EAN.UCC functionality - GTIN
  IF GV_FLAG_GTIN_VP = 'X'.
    RMMW1_MATN = MARA-MATNR.
  ENDIF.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK RMMZU-OKCODE NE FCODE_EADE.
* CHECK BILDFLAG IS INITIAL.           " AHE: 12.12.95 raus ! !

* AHE: 12.06.96 - A
* Retail-Fall: EAN-Lieferantenbezug-Handling
  CLEAR: FLAG_EXIT, EAN_UPD.
* AHE: 12.06.96 - E

* AHE: 24.01.96 - A
* externe Vergabe der EAN und die Prüfziffer soll automatisch
* ermittelt werden.
  IF NOT RMMZU-AUTO_PRFZ IS INITIAL AND" Dynprofeld !
     NOT MEAN-EAN11 IS INITIAL.        " AND  " Dynprofeld !
*    NOT MEAN-EANTP IS INITIAL.          " Dynprofeld !

    CALL FUNCTION 'EAN_AUTO_CHECKSUM'
      EXPORTING
        P_EAN11        = MEAN-EAN11
        P_NUMTP        = MEAN-EANTP
        P_MESSAGE      = ' '
      IMPORTING
        P_EAN11        = MEAN-EAN11
      EXCEPTIONS
        EAN_PRFZ_ERROR = 1
        OTHERS         = 2.

    CLEAR RMMZU-AUTO_PRFZ.   " Bei Error oder Erfolg immer zurücksetzen

    IF SY-SUBRC NE 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    CLEAR RMMZU-AUTO_PRFZ.
  ENDIF.                               " Ende Prüfziffernermittlung
* AHE: 24.01.96 - E


  CLEAR MEAN_ME_TAB.  " wegen evtl. neuer noch nicht übernommener Zeile
  READ TABLE MEAN_ME_TAB INDEX EAN_AKT_ZEILE.
* hier kein CHECK SY-SUBRC wg. evtl. neuem Satz möglich (dann könnte
* man zuerst die Konsistenzchecks machen, bevor z. Bsp. eine EAN intern
* vergeben wird). (AHE: 21.11.95);

* Es wird nur für die EANs geprüft, bei deren Eintrag sich etwas
* verändert hat.
  IF MEAN-EAN11 = MEAN_ME_TAB-EAN11 AND
     MEAN-EANTP = MEAN_ME_TAB-NUMTP AND
     MEAN_ME_TAB-EAN_GEPRF = X.
*    Zeile unverändert
    IF MEAN-EAN11       IS INITIAL AND " neu 07.11.95 - A
       NOT MEAN-EANTP   IS INITIAL AND
       EAN_FEHLERFLG_ME IS INITIAL.
*    EAN muss noch intern ermittelt werden --> FB-Aufruf aber nur, wenn
*    die Mengeneinheit korrekt eingegeben wurde (EAN_FEHLERFLAG_ME ist
*    initial).
*    MESSAGE W069(WE).                " EAN wird intern ermittelt
*    --> Meldung nun aus EAN_SYSTEMATIC in MARA_EAN11
      CLEAR MEAN_ME_TAB-EAN_GEPRF.
    ENDIF.                             " neu 07.11.95 - E

  ELSE.
*    Zeile geändert oder neu --> ggf. Meldungen ausgeben + Prüfen
    CLEAR MEAN_ME_TAB-EAN_GEPRF.
*   AHE: 04.01.96 - A
*   Zeile geändert: -> nicht mehr in den Zweig für den Fehlerfall
*   "M3 348" springen (in MARA_EAN11).
*   Dies gilt nur ! für dieses Modul nicht für die anderen Module,
*   die MARA_EAN11 aufrufen ! ! !
    CLEAR EAN_FEHLERFLG.
*   AHE: 04.01.96 - E

    IF MEAN-EAN11 IS INITIAL.
      IF MEAN-EANTP IS INITIAL.
        IF NOT MEAN_ME_TAB-EAN11 IS INITIAL.  " neu: 07.11.95
* AHE: 11.06.96 - A
          IF NOT rmmg2-flg_retail IS INITIAL OR GV_FLAG_GTIN_VP = 'X'.
*         Retail-Fall: EAN-Lieferantenbezug-Handling
*         ->  Abfragen (POP-UP) und Löschen von ggf. vorhandenen
*             EAN-Lieferantenbezügen
            PERFORM DEL_EAN_LIEF USING FLAG_EXIT.
            CASE FLAG_EXIT.
              WHEN 'N'.
*               "NEIN" -> nur diese Zeile nicht löschen
                EXIT.
              WHEN 'A'.
*               "ABBRUCH" -> Löschen abbrechen
                EXIT FROM STEP-LOOP.
            ENDCASE.
*           Beim Löschen der Zeile muß in jedem Falle RMMZU-LIEFZU und
*           MLEA-LFEAN gelöscht werden. RMMZU-LIEFZU auch deswegen,
*           damit in TMLEA keine MEAN-Sätze mit leerer (zum Löschen
*           vorgem.) EAN aufgenommen werden (in BELEGEN_MEAN_ME_TAB).
            CLEAR: RMMZU-LIEFZU, MLEA-LFEAN.   " Dynprofelder
* AHE: 27.01.99 - A ( 4.6a)
            CLEAR: MLEA-LARTN.         " Dynprofeld
* AHE: 27.01.99 - E
          ENDIF.
* AHE: 11.06.96 - E

*         note 1034796: check for gtin variant of a main EAN
          IF NOT mean_me_tab-hpean IS INITIAL AND
             NOT MEINH-GTIN_VARIANT IS INITIAL.
            MESSAGE W553(MM).
            FLAG_EXIT = 'N'.
            EXIT.
          ENDIF.

          MESSAGE W067(WE).            " bisherige EAN gelöscht
* Muß außerhalb des FBs EAN_SYSTEMATIC (MARA_EAN11) ausgegeben werden.
* Der FB darf dann nicht mehr aufgerufen werden, da ansonsten
* das POP-UP "Bitte neue Haupt-EAN auswählen" aufgerufen wird.
* Bem.: Diese Funktionalität wird an anderer Stelle (z. Bsp. Mengenein-
* heitenbild ) benötigt.

          MEAN_ME_TAB-EAN_GEPRF = X.
*         Prüfung für EAN und Typ nicht mehr ausführen
        ENDIF.
      ELSE.
* AHE: 12.06.96 - A
        IF NOT rmmg2-flg_retail IS INITIAL OR GV_FLAG_GTIN_VP = 'X'.
*         Retail-Fall: EAN-Lieferantenbezug-Handling
*         ->  Abfragen (POP-UP) und Ändern von ggf. vorhandenen
*             EAN-Lieferantenbezügen
          PERFORM UPD_EAN_LIEF USING FLAG_EXIT.
          CASE FLAG_EXIT.
            WHEN 'N'.
*             "NEIN" -> nur diese Zeile nicht Ändern
              EXIT.
            WHEN 'A'.
*             "ABBRUCH" -> Ändern abbrechen
              EXIT FROM STEP-LOOP.
          ENDCASE.
        ENDIF.
* AHE: 12.06.96 - E
*       MESSAGE W069(WE).              " EAN wird intern ermittelt
*       Meldung nun aus EAN_SYSTEMATIC in MARA_EAN11
      ENDIF.
    ENDIF.

*   IF NOT MEAN-EAN11 IS INITIAL AND
*      NOT MEAN-EANTP IS INITIAL AND
*      NOT MEAN_ME_TAB-EAN11 IS INITIAL.  " neu 07.11.95
*     MESSAGE W068(WE).                " bisherige EAN überschrieben
*     Meldung nun aus EAN_SYSTEMATIC in MARA_EAN11
*   ENDIF.

  ENDIF.

* AHE: 12.06.96 - A
* Retail-Fall: EAN-Lieferantenbezug-Handling
* für: EAN geändert
  IF ( NOT rmmg2-flg_retail IS INITIAL OR GV_FLAG_GTIN_VP = 'X' ) AND
     MEAN-EAN11 NE MEAN_ME_TAB-EAN11 AND
     NOT MEAN-EAN11 IS INITIAL.
* -> Abfragen (POP-UP) und Ändern von ggf. vorhandenen
*    EAN-Lieferantenbezügen
    PERFORM UPD_EAN_LIEF USING FLAG_EXIT.
    CASE FLAG_EXIT.
      WHEN 'N'.
*       "NEIN" -> nur diese Zeile nicht Ändern
        EXIT.
      WHEN 'A'.
*       "ABBRUCH" -> Ändern abbrechen
        EXIT FROM STEP-LOOP.
    ENDCASE.
  ENDIF.
* AHE: 12.06.96 - E

* AHE: 12.12.95 - A
  IF NOT EAN_FEHLERFLG IS INITIAL. " gesetzt, wenn vorher Error ausgeg.
    CLEAR MEAN_ME_TAB-EAN_GEPRF.       " nochmal reingehen ! !
  ENDIF.
* AHE: 12.12.95 - E

* AHE: 13.06.96 - A
* Retail-Fall: EAN-Lieferantenbezug-Handling
  IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
     MEAN-EAN11 IS INITIAL           AND
     MEAN-EANTP IS INITIAL.

    IF NOT MLEA-LFEAN   IS INITIAL OR
* AHE: 27.01.99 - A ( 4.6a)
*      NOT RMMZU-LIEFZU IS INITIAL.
       NOT RMMZU-LIEFZU IS INITIAL OR
       NOT MLEA-LARTN IS INITIAL.
      CLEAR: MLEA-LARTN.
* AHE: 27.01.99 - E
      MEAN_ME_TAB-EAN_GEPRF = X.
      CLEAR: MLEA-LFEAN, RMMZU-LIEFZU.
*   Falls nach der Meldung M3 898 "Bitte Haupt-EAN zum Lief. angeben"
*   diese Haupt-EAN-Lief auf einer Zeile ohne Eintrag markiert wird,
*   würde als Seiteneffekt in die MEAN_ME_TAB eine leere Zeile einge-
*   tragen, da der PBO dann nochmal prozessiert wird mit dieser
*   ansonsten leeren Zeile.
*   Dasselbe gilt für RMMZU-LIEFZU.
*   Dies wird realisiert, indem das FLAG_EXIT hier dazu mißbraucht
*   wird, den Tabellenupdate zu verhindern.
      FLAG_EXIT = 'N'.
    ENDIF.
  ENDIF.
* AHE: 13.06.96 - E

  CHECK MEAN_ME_TAB-EAN_GEPRF IS INITIAL.
* Zeile noch zu prüfen  ?

*--- Letzter geprüfter Stand von EAN und Nummerntyp ermitteln
  READ TABLE LMEAN_ME_TAB WITH KEY MEINH = MEAN_ME_TAB-MEINH
                                   EAN11 = MEAN_ME_TAB-EAN11.
  IF SY-SUBRC NE 0.
    CLEAR: LMEAN_ME_TAB-EAN11, LMEAN_ME_TAB-NUMTP.
  ENDIF.

* note 1455075: sort table to check correctly for duplicate EANs
  GT_MEAN_ME_TAB[] = MEAN_ME_TAB[].
  SORT GT_MEAN_ME_TAB.


  CALL FUNCTION 'MARA_EAN11'
       EXPORTING
            P_MATNR         = MARA-MATNR           " Dynprofeld
            P_NUMTP         = MEAN-EANTP                    "
            P_EAN11         = MEAN-EAN11                    "
            P_MEINH         = SMEINH-MEINH                  "
            RET_EAN11       = LMEAN_ME_TAB-EAN11   " letzt. geprf. Stand
            RET_NUMTP       = LMEAN_ME_TAB-NUMTP            "
            BINPT_IN        = SY-BINPT
            P_MESSAGE       = ' '
*           SPERRMODUS      = 'E'
            KZ_MEAN_TAB_UPD = X   " MEAN_ME_TAB nicht "by ref." ändern !
            ERROR_FLAG      = EAN_FEHLERFLG
            P_HERKUNFT      = 'Z'      " für zusätzl. EAN
       IMPORTING
            VB_FLAG_MEAN    = RMMG2-VB_MEAN
            P_NUMTP         = MEAN-EANTP
            P_EAN11         = MEAN-EAN11
* AHE: 08.10.96 - A
            MSGID           = MSGID    " s. weiter unten
            MSGTY           = MSGTY
            MSGNO           = MSGNO
            MSGV1           = MSGV1
            MSGV2           = MSGV2
            MSGV3           = MSGV3
            MSGV4           = MSGV4
* AHE: 08.10.96 - E
       TABLES
            MARM_EAN        = MARM_EAN " Benötigt zum Puffern !
            MEAN_ME_TAB     = GT_MEAN_ME_TAB               "note 1455075
            ME_TAB          = ME_TAB
*           YDMEAN          =
*           MEINH           =
       EXCEPTIONS
            EAN_ERROR       = 1
            OTHERS          = 2.

  IF SY-SUBRC NE 0.
    CLEAR MEAN_ME_TAB-EAN_GEPRF.
*     CLEAR auf MEAN_ME_TAB-GEPRF, weil dieses KZ durch die zwar
*     nicht veränderte aber in MARA_EAN11 durchgeloopte ( = veränderte
*     Kopfzeile) MEAN_ME_TAB nicht mehr richtig sitzt.
*   CLEAR RMMZU-OKCODE.  " AHE: 20.01.97
*       IF BILDFLAG IS INITIAL.
    BILDFLAG = X.
    EAN_FEHLERFLG = X.
*       MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO " hier FALSCH
*                                                    " wg. M3 348
    MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*       ENDIF.
  ELSE.
*   AHE: 08.10.96 - A
*   Ausgabe der Warnungen 068 und 069 (EAN wird geändert / intern
*   vergeben) nachdem die neue EAN aufs Bild geschossen wurde.
    IF MSGNO = 069 OR MSGNO = 068.
*   neue EAN aufs Dynprofeld schieben

* AHE: 18.06.98 - A (4.0c)
* UPC-E muß konvertiert werden, da der Exit noch nicht gelaufen ist an
* dieser Stelle
*     PERFORM SET_SCREEN_FIELD_VALUE USING 'MEAN-EAN11' MEAN-EAN11.
      EAN_BUFF = MEAN-EAN11.
      CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
        EXPORTING
          INPUT   = MEAN-EAN11
          EAN_TYP = MEAN-EANTP
        IMPORTING
          OUTPUT  = MEAN-EAN11.
      PERFORM SET_SCREEN_FIELD_VALUE USING 'MEAN-EAN11' MEAN-EAN11.
* AHE: 18.06.98 - E

*   jetzt erst Warnung ausgeben
      MESSAGE ID MSGID TYPE MSGTY NUMBER MSGNO
              WITH MSGV1 MSGV2 MSGV3 MSGV4.

*     note 1061743
      PERFORM RESET_WARN_EAN11 IN PROGRAM ('SAPLMG07').

* AHE: 18.06.98 - A (4.0c)
      MEAN-EAN11 = EAN_BUFF.
* AHE: 18.06.98 - E

    ENDIF.
*   AHE: 08.10.96 - E

    CLEAR EAN_FEHLERFLG.
    MEAN_ME_TAB-EAN_GEPRF = X.         " Zeile geprüft und O.K.
  ENDIF.

ENDMODULE.                             " CHECK_EAN_ZUS  INPUT
