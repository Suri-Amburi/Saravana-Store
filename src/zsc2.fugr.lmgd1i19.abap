*------------------------------------------------------------------
*  Module MARA-EAN11
* Die eingegebene Kombination EAN und EAN-Typ wird überprüft
*------------------------------------------------------------------
MODULE MARA-EAN11.

* CHECK BILDFLAG IS INITIAL.      " AHE: 12.12.95 raus ! !
  CHECK BILDFLAG IS INITIAL.           " AHE: 01.10.96
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 25.01.96 - A
* externe Vergabe der EAN und die Prüfziffer soll automatisch
* ermittelt werden.
  IF NOT RMMZU-AUTO_PRFZ IS INITIAL AND" Dynprofeld !
     NOT MARA-EAN11 IS INITIAL.        " AND  " Dynprofeld !
*    NOT MARA-NUMTP IS INITIAL.               " Dynprofeld !

    CALL FUNCTION 'EAN_AUTO_CHECKSUM'
      EXPORTING
        P_EAN11        = MARA-EAN11
        P_NUMTP        = MARA-NUMTP
        P_MESSAGE      = ' '
      IMPORTING
        P_EAN11        = MARA-EAN11
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

* note 1034796: check, that GTIN_VARIANT is initial in deletion case
  IF MARA-EAN11    IS INITIAL AND
     MARA-NUMTP    IS INITIAL AND
     NOT LMARA-EAN11 IS INITIAL AND
     NOT MARA-GTIN_VARIANT IS INITIAL.
    MESSAGE W553(MM).
    BILDFLAG = X.
    MARA-EAN11 = LMARA-EAN11.
    MARA-NUMTP = LMARA-NUMTP.
    EXIT.
  ENDIF.

  CHECK MARA-EAN11 <> LMARA-EAN11    "Note 713425
    OR  MARA-NUMTP <> LMARA-NUMTP
    OR  EAN_FEHLERFLG <> SPACE.

* AHE: 19.06.98 - A (4.0c) HW 71129
* wegen Referenzhandling EAN intern, damit die Meldung "EAN darf
* nicht extern vergeben werden" nicht kommt
  READ TABLE MEAN_ME_TAB WITH KEY MEINH = MARA-MEINS
                                  EAN11 = MARA-EAN11
                                  NUMTP = MARA-NUMTP.

  IF SY-SUBRC = 0 AND NOT MEAN_ME_TAB-EAN_GEPRF IS INITIAL.
    LMARA-EAN11 = MARA-EAN11.
    LMARA-NUMTP = MARA-NUMTP.
  ENDIF.
* AHE: 19.06.98 - E

* Start: EAN.UCC Functionality - GTIN

  IF GV_FLAG_GTIN_VP = 'X'.

*********************************
*Retail functionality

*&&&&
   RMMW1_MATN = MARA-MATNR.
*  get old version in MEINH as in LMARA to include retail functionality
*  in basic data screen
   READ TABLE MEINH WITH KEY MEINH = MARA-MEINS.
*&&&&

    IF MARA-EAN11    IS INITIAL AND
       MARA-NUMTP    IS INITIAL AND
       NOT MEINH-EAN11 IS INITIAL.
*      EAN von Hand gelöscht.

*{   INSERT         note 539901                                       1
*     -> Löschen per Button wird in Modul OK_CODE_MEINH_I behandelt
      PERFORM DEL_EAN_LIEF_MEINH USING FLAG_EXIT.
*}   INSERT
      CASE FLAG_EXIT.
        WHEN 'N'.
*           "NEIN" -> nur diese Zeile nicht Ändern
          MARA-EAN11 = MEINH-EAN11.
          MARA-NUMTP = MEINH-NUMTP.
          EXIT.
      ENDCASE.
    ENDIF.

    IF  ( MARA-EAN11 IS INITIAL AND
        NOT MARA-NUMTP IS INITIAL )
*         EAN evtl. intern neu vergeben (geändert)
      OR
        ( MARA-EAN11 NE MEINH-EAN11 AND
        NOT MARA-EAN11 IS INITIAL ) .
*         EAN wurde von Hand geändert

      PERFORM UPD_EAN_LIEF_MEINH USING FLAG_EXIT.
      CASE FLAG_EXIT.
        WHEN 'N'.
*           "NEIN" -> nur diese Zeile nicht Ändern
          MARA-EAN11 = MEINH-EAN11.
          EXIT.
        WHEN 'A'.
*           "ABBRUCH" -> Ändern abbrechen
*           EXIT FROM STEP-LOOP.
          MARA-EAN11 = MEINH-EAN11.
          EXIT.
      ENDCASE.
    ENDIF.

  ENDIF.
*{   INSERT         note 539901                                 2
*}   INSERT
* End:

  CALL FUNCTION 'MARA_EAN11'
       EXPORTING
            P_MATNR      = MARA-MATNR
            P_NUMTP      = MARA-NUMTP
            P_EAN11      = MARA-EAN11
            P_MEINH      = MARA-MEINS
            RET_EAN11    = LMARA-EAN11
            RET_NUMTP    = LMARA-NUMTP
            BINPT_IN     = SY-BINPT
            P_MESSAGE    = ' '
            ERROR_FLAG   = EAN_FEHLERFLG
            P_HERKUNFT   = 'A'         " Für Abmessungen / EAN
            GDS_RELEVANT = MARA-GDS_RELEVANT
       IMPORTING
            P_NUMTP      = MARA-NUMTP
            P_EAN11      = MARA-EAN11
            VB_FLAG_MEAN = RMMG2-VB_MEAN
* AHE: 08.10.96 - A
            MSGID        = MSGID       " s. weiter unten
            MSGTY        = MSGTY
            MSGNO        = MSGNO
            MSGV1        = MSGV1
            MSGV2        = MSGV2
            MSGV3        = MSGV3
            MSGV4        = MSGV4
* AHE: 08.10.96 - E
       TABLES
            MARM_EAN     = MARM_EAN
            MEAN_ME_TAB  = MEAN_ME_TAB " NEU: AHE 24.10.95
            ME_TAB       = ME_TAB
            YDMEAN       = YDMEAN
       EXCEPTIONS
            EAN_ERROR    = 1
            OTHERS       = 2.

  IF SY-SUBRC NE 0.
*   CLEAR RMMZU-OKCODE.     " AHE: 20.01.97
*   IF BILDFLAG IS INITIAL.
*   BILDFLAG = X.           AHE: 01.10.96
    EAN_FEHLERFLG = X.
*     MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
    MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   ENDIF.
  ELSE.
*mk/4.0 Kopie LMGD2I05 wieder mit Original LMGD1I01 vereint
*    Achtung: dieser Teil fehlte in der Retail-Kopie
* AHE: 08.10.96 - A
* Ausgabe der Warnungen 068 und 069 (EAN wird geändert / intern
* vergeben) nachdem die neue EAN aufs Bild geschossen wurde.
    IF MSGNO = 069 OR MSGNO = 068.
*   neue EAN aufs Dynprofeld schieben

* AHE: 18.06.98 - A (4.0c)
* UPC-E muß konvertiert werden, da der Exit noch nicht gelaufen ist an
* dieser Stelle
*     PERFORM SET_SCREEN_FIELD_VALUE USING 'MARA-EAN11' MARA-EAN11.
      EAN_BUFF = MARA-EAN11.
      CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
        EXPORTING
          INPUT   = MARA-EAN11
          EAN_TYP = MARA-NUMTP
        IMPORTING
          OUTPUT  = MARA-EAN11.
      PERFORM SET_SCREEN_FIELD_VALUE USING 'MARA-EAN11' MARA-EAN11.
* AHE: 18.06.98 - E

*   jetzt erst Warnung ausgeben
      MESSAGE ID MSGID TYPE MSGTY NUMBER MSGNO
              WITH MSGV1 MSGV2 MSGV3 MSGV4.

* AHE: 18.06.98 - A (4.0c)
      MARA-EAN11 = EAN_BUFF.
* AHE: 18.06.98 - E

    ENDIF.
* AHE: 08.10.96 - E

    CLEAR EAN_FEHLERFLG.
  ENDIF.

ENDMODULE.                                                  "MARA-EAN11
