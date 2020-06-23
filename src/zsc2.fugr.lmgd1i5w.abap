*&---------------------------------------------------------------------*
*&      Module  SMEINH-EAN11  INPUT
*&---------------------------------------------------------------------*
*   Die eingegebene Kombination EAN und EAN-Typ wird überprüft
*
*   Läuft im BTCI-Fall nur on chain-request ab, da in diesem Fall
*   die Daten nur von außen kommen können (Die bisherigen Daten können
*   nicht ins Dynpro eingestellt werden).  Wird ein Initialwert
*   vorgegeben (Rücksetzen eines Feldes) laufen die Prüfungen ab.
*----------------------------------------------------------------------*
MODULE SMEINH-EAN11 INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK SMEINH-MEINH NE SPACE.

* AHE: 25.01.96 - A
* externe Vergabe der EAN und die Prüfziffer soll automatisch
* ermittelt werden.
  IF NOT RMMZU-AUTO_PRFZ IS INITIAL AND  " Dynprofeld !
     NOT SMEINH-EAN11 IS INITIAL.        " AND  " Dynprofeld !
*    NOT SMEINH-NUMTP IS INITIAL.        " Dynprofeld !

    CALL FUNCTION 'EAN_AUTO_CHECKSUM'
      EXPORTING
        P_EAN11        = SMEINH-EAN11
        P_NUMTP        = SMEINH-NUMTP
        P_MESSAGE      = ' '
      IMPORTING
        P_EAN11        = SMEINH-EAN11
      EXCEPTIONS
        EAN_PRFZ_ERROR = 1
        OTHERS         = 2.

    CLEAR RMMZU-AUTO_PRFZ.   " Bei Error oder Erfolg immer zurücksetzen

    IF SY-SUBRC NE 0.
      MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    CLEAR RMMZU-AUTO_PRFZ.
  ENDIF.                               " Ende Prüfziffernermittlung
* AHE: 25.01.96 - E

*---- Meinh wieder richtig positionieren, da in MARA-EAN11 ev umsortiert
*---- wird.
  READ TABLE MEINH INDEX ME_AKT_ZEILE.


  IF MEINH-GTIN_VARIANT NE SMEINH-GTIN_VARIANT.
*   note 1034796: check, that GTIN_VARIANT is on the current screen
*                 otherwise the SMEINH value is always initial
    READ TABLE FAUSWTAB WITH KEY FNAME = 'SMEINH-GTIN_VARIANT'.
    IF SY-SUBRC = 0.
      MEINH-GTIN_VARIANT = SMEINH-GTIN_VARIANT.     "RS 4.7
    ENDIF.
  ENDIF.

*--- Festhalten der Eingaben --------------------------------------
* cfo/4.0C-A   Damit b. Referenz des EAN-Typs das Modul durchlaufen wird
* (HW 71129)
* IF MEINH-EAN11 NE SMEINH-EAN11 OR MEINH-NUMTP NE SMEINH-NUMTP.
  IF MEINH-EAN11 NE SMEINH-EAN11 OR MEINH-NUMTP NE SMEINH-NUMTP
     OR ( NOT MEINH-NUMTP IS INITIAL AND MEINH-EAN11 IS INITIAL ).
* cfo/4.0C-E

* AHE: 18.06.96 - A
* Retail-Fall: EAN-Lieferantenbezug-Handling
* Fall: EAN oder Typ gändert
    IF NOT RMMG2-FLG_RETAIL IS INITIAL OR GV_FLAG_GTIN_VP = 'X'.

*     EAN.UCC Functionality
      IF GV_FLAG_GTIN_VP = 'X'.
        RMMW1_MATN = MARA-MATNR.
      ENDIF.
      IF SMEINH-EAN11    IS INITIAL AND
         SMEINH-NUMTP    IS INITIAL AND
         NOT MEINH-EAN11 IS INITIAL.
*       EAN von Hand gelöscht.
*{   INSERT         note 539901                                       1

*       note 1034796: check, that GTIN_VARIANT is initial
        IF NOT MEINH-GTIN_VARIANT IS INITIAL.
          MESSAGE W553(MM).
          EXIT.
        ENDIF.

* Für den Fall, dass die EAN von Hand geändert wurde, muss der LMEINH
* Stand gelöscht werden, da die vorherige EAN nicht mehr der L-Stand ist
        DATA: GELOESCHT LIKE T130F-KZREF.
        DATA: EAN_GELOESCHT LIKE MEINH-EAN11.
        DATA: MEINH_GELOESCHT LIKE MEINH-MEINH.

* Die EAN, die von Hand geloescht wurde, wird gesichert, damit nur
* der entsprechende Rettungs-Puffer geloescht wird.
        GELOESCHT = X.
        EAN_GELOESCHT = MEINH-EAN11.
        MEINH_GELOESCHT = MEINH-MEINH.
*}   INSERT

*       -> Löschen per Button wird in Modul OK_CODE_MEINH_I behandelt
        PERFORM DEL_EAN_LIEF_MEINH USING FLAG_EXIT.
        CASE FLAG_EXIT.
          WHEN 'N'.
*           "NEIN" -> nur diese Zeile nicht Ändern
            EXIT.
        ENDCASE.
      ENDIF.

      IF  ( SMEINH-EAN11 IS INITIAL AND
          NOT SMEINH-NUMTP IS INITIAL )
*         EAN evtl. intern neu vergeben (geändert)
        OR
          ( SMEINH-EAN11 NE MEINH-EAN11 AND
          NOT SMEINH-EAN11 IS INITIAL ) .
*         EAN wurde von Hand geändert

        PERFORM UPD_EAN_LIEF_MEINH USING FLAG_EXIT.
        CASE FLAG_EXIT.
          WHEN 'N'.
*           "NEIN" -> nur diese Zeile nicht Ändern
            EXIT.
          WHEN 'A'.
*           "ABBRUCH" -> Ändern abbrechen
            EXIT FROM STEP-LOOP.
        ENDCASE.
      ENDIF.

    ENDIF.
* AHE: 18.06.96 - E

    MEINH-EAN11 = SMEINH-EAN11.
    MEINH-NUMTP = SMEINH-NUMTP.
    CLEAR MEINH-EANGEPRFT.
  ENDIF.

  CHECK ME_DOPPEINTRAG IS INITIAL.
  CHECK RMMZU-OKCODE NE FCODE_MEDE.

*--- Zuletzt eingegebenen EAN und Nummerntyp ermitteln
  READ TABLE LMEINH WITH KEY MEINH-MEINH.
  IF SY-SUBRC NE 0.
    CLEAR: LMEINH-EAN11, LMEINH-NUMTP.
  ELSE.
* note 646042 : Wenn ME mit selber EAN nach ME-Löschung sofort wieder
*               angelegt wird, steht in LMEINH noch der alte Stand mit
*               nun wieder neuer EAN. Dann muß EAN in LMEINH gecleart
*               werden, da sonst die neue EAN nicht in MEAN_ME_TAB kommt
    IF LMEINH-EAN11 EQ SMEINH-EAN11
       AND LMEINH-NUMTP EQ SMEINH-NUMTP
       AND NOT SMEINH-EAN11 IS INITIAL
       AND NOT SMEINH-NUMTP IS INITIAL.
      DATA LS_MEINH_HELP LIKE SMEINH.
*     aus MEINH nochmal nachlesen, ob EAN neu vom Dynpro ist
      READ TABLE MEINH INDEX ME_AKT_ZEILE INTO LS_MEINH_HELP.
      IF SY-SUBRC EQ 0
         AND LS_MEINH_HELP-EAN11 IS INITIAL
         AND LS_MEINH_HELP-NUMTP IS INITIAL.
        CLEAR: LMEINH-EAN11, LMEINH-NUMTP.
      ENDIF.
    ENDIF.
  ENDIF.

* AHE: 12.12.95 - A
  IF NOT ME_EANERRFLG IS INITIAL." gesetzt, wenn vorher Error ausgegeben
    CLEAR MEINH-EANGEPRFT.             " nochmal reingehen ! !
  ENDIF.
* AHE: 12.12.95 _ E
* Die Warnung, daß EAN bereits bei ME existiert wurde mittels Löschen
* der eingetragenen EAN und Typ einfach mit Return bestätigt.
* daher sicherheitshalber die Prüfung erneut machen
  "note 2072661
  IF MEINH-EAN11 IS INITIAL AND MEINH-NUMTP IS INITIAL AND
    ( SY-MSGNO = 347 OR SY-MSGNO = 348 ).                  "BKE /"434702
    CLEAR MEINH-EANGEPRFT.
  ENDIF.

*{   INSERT         note 539901                                 2
* Es wurde von Hand gelöscht, d.h. der L-Stand für diese EAN muss
* initial sein.
  IF GELOESCHT = X
      AND MEINH-EAN11 = EAN_GELOESCHT
      AND MEINH-MEINH = MEINH_GELOESCHT.

    READ TABLE LMEINH WITH KEY EAN11 = MEINH-EAN11
                               MEINH = MEINH-MEINH.
    IF SY-SUBRC = 0.
      LMEINH-EAN11 = SPACE.
      LMEINH-NUMTP = SPACE.
*     MODIFY table LMEINH.
      GELOESCHT = SPACE.
    ENDIF.

  ENDIF.
*}   INSERT

*--- Prüfung nur durchführen, wenn EAN noch nicht geprüft wurde.
*--- Ansonsten kann es bei interner Nummernvergabe und nichtaktu-
*--- alisierter LMEINH zu einem Fehler führen.

  IF MEINH-EANGEPRFT = SPACE.
    CALL FUNCTION 'MARA_EAN11'
         EXPORTING
              P_MATNR      = MARA-MATNR
              P_NUMTP      = SMEINH-NUMTP
              P_EAN11      = SMEINH-EAN11
              P_MEINH      = SMEINH-MEINH
              RET_EAN11    = LMEINH-EAN11
              RET_NUMTP    = LMEINH-NUMTP
              BINPT_IN     = SY-BINPT
              P_MESSAGE    = ' '
              ERROR_FLAG   = ME_EANERRFLG
              P_HERKUNFT   = 'M'       " für Mengeneinheiten / EAN
              GDS_RELEVANT = MARA-GDS_RELEVANT
         IMPORTING
              P_EAN11      = SMEINH-EAN11
              P_NUMTP      = SMEINH-NUMTP
              VB_FLAG_MEAN = RMMG2-VB_MEAN
* AHE: 08.10.96 - A
              MSGID        = MSGID     " s. weiter unten
              MSGTY        = MSGTY
              MSGNO        = MSGNO
              MSGV1        = MSGV1
              MSGV2        = MSGV2
              MSGV3        = MSGV3
              MSGV4        = MSGV4
* AHE: 08.10.96 - E
         TABLES
              MARM_EAN     = MARM_EAN
              MEAN_ME_TAB  = MEAN_ME_TAB  " NEU: AHE 24.10.95
              ME_TAB       = ME_TAB
              YDMEAN       = YDMEAN
         EXCEPTIONS
              EAN_ERROR    = 1
              OTHERS       = 2.

*--- Eingabe aktualisieren --------------------------------------
    MEINH-EAN11 = SMEINH-EAN11.
    MEINH-NUMTP = SMEINH-NUMTP.

    IF SY-SUBRC NE 0.            "cfo/29.10.95/besser positionieren
*     CLEAR RMMZU-OKCODE.       " AHE: 20.01.97
*     IF BILDFLAG IS INITIAL.   AHE 12.12.95
*     BILDFLAG = X.      "cfo/24.9.96 Setzen Bildflag bei Error unnötig
      ME_EANERRFLG = X.                " wenn Error -> Flag setzen ! !

*     AHE: 09.06.97 - A
*     Wenn die Meldung 348 (EAN bereits bei anderem Material benutzt)
*     ausgegeben wird, muß die MEAN_ME_TAB wieder bereinigt werden.
      IF SY-MSGNO = 348 OR SY-MSGNO = 347.                  "434702
        READ TABLE MEAN_ME_TAB WITH KEY MEINH = SMEINH-MEINH
                                        EAN11 = SMEINH-EAN11.
        IF SY-SUBRC = 0.
          DELETE MEAN_ME_TAB INDEX SY-TABIX.
        ENDIF.
      ENDIF.
*     AHE: 09.06.97 - E

      CLEAR MEINH-EANGEPRFT.
*     MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO  " AHE 12.12.95
      MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     ENDIF.
    ELSE.
*   AHE: 08.10.96 - A
*   Ausgabe der Warnungen 068 und 069 (EAN wird geändert / intern
*   vergeben) nachdem die neue EAN aufs Bild geschossen wurde.
      IF MSGNO = 069 OR MSGNO = 068.
*     neue EAN aufs Dynprofeld schieben

* AHE: 18.06.98 - A (4.0c)
* UPC-E muß konvertiert werden, da der Exit noch nicht gelaufen ist an
* dieser Stelle
*       PERFORM SET_SCREEN_FIELD_VALUE USING 'SMEINH-EAN11'
*                                             SMEINH-EAN11.
        EAN_BUFF = SMEINH-EAN11.
        CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
          EXPORTING
            INPUT   = SMEINH-EAN11
            EAN_TYP = SMEINH-NUMTP
          IMPORTING
            OUTPUT  = SMEINH-EAN11.
        PERFORM SET_SCREEN_FIELD_VALUE USING 'SMEINH-EAN11'
                                              SMEINH-EAN11.
* AHE: 18.06.98 - E

*     jetzt erst Warnung ausgeben
        MESSAGE ID MSGID TYPE MSGTY NUMBER MSGNO
                WITH MSGV1 MSGV2 MSGV3 MSGV4.

* AHE: 18.06.98 - A (4.0c)
        SMEINH-EAN11 = EAN_BUFF.
* AHE: 18.06.98 - E

      ENDIF.
*   AHE: 08.10.96 - E

      CLEAR ME_EANERRFLG.              " kein Error ! !
      MEINH-EANGEPRFT = X.
    ENDIF.

*--- Eingabe aktualisieren --------------------------------------
*   MEINH-EAN11 = SMEINH-EAN11.
*   MEINH-NUMTP = SMEINH-NUMTP.
  ENDIF.

ENDMODULE.                             " SMEINH-EAN11  INPUT
