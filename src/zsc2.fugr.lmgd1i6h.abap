*&---------------------------------------------------------------------*
*&      Module  OKCODE_EADE  INPUT
*&---------------------------------------------------------------------*
*       Bereitet Löschen EAN vor; Hier wird nur LÖSCHEN per Button
*       behandelt. Das eigentliche Löschen in der MEAN_ME_TAB
*       geschieht später.
*----------------------------------------------------------------------*
MODULE OKCODE_EADE INPUT.

  CLEAR FLAG_DEL_EAN.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  IF NOT EAN_BILDFLAG_OLD IS INITIAL AND
      RMMZU-OKCODE = FCODE_EADE.
    CLEAR RMMZU-OKCODE.
  ENDIF.

  IF RMMZU-OKCODE EQ FCODE_EADE.       " Einträge löschen
    FLAG_DEL_EAN = X.                  " merken für UPDATE MEINH, MARM
    BILDFLAG = X.
    CLEAR RMMZU-OKCODE.

    GET CURSOR LINE EAN_ZEILEN_NR.     " Zeile bestimmen
    EAN_AKT_ZEILE = EAN_ERSTE_ZEILE + EAN_ZEILEN_NR.

    READ TABLE MEAN_ME_TAB INDEX EAN_AKT_ZEILE.
    IF SY-SUBRC = 0.
*     DELETE MEAN_ME_TAB INDEX EAN_AKT_ZEILE.
*     hier kein DELETE auf Tabellensatz, da erst noch geprüft werden
*     muß, ob es der letzte Satz zu einer Mengeneinheit ist. Dieser
*     darf dann nicht gelöscht werden.

      IF NOT MEAN_ME_TAB-EAN11 IS INITIAL.

*       note 1034796: check, that GTIN_VARIANT is initial
        READ TABLE MEINH WITH KEY MEINH = MEAN_ME_TAB-MEINH.
        IF SY-SUBRC = 0 AND NOT MEINH-GTIN_VARIANT IS INITIAL.
          MESSAGE W553(MM).
          EXIT.
        ENDIF.

* AHE: 10.06.96 - A
        IF NOT RMMG2-FLG_RETAIL IS INITIAL OR GV_FLAG_GTIN_VP = 'X'.
*         Retail-Fall: EAN-Lieferantenbezug-Handling
*         ->  Abfragen (POP-UP) und Löschen von ggf. vorhandenen
*             EAN-Lieferantenbezügen
          PERFORM DEL_EAN_LIEF USING FLAG_EXIT.
          CHECK FLAG_EXIT IS INITIAL.
*         FLAG_EXIT initial, wenn POP-UP mit "JA" verlassen
        ENDIF.
* AHE: 10.06.96 - E

        MESSAGE S067(WE).
*       Bisherige EAN wird gelöscht

      ENDIF.

      CLEAR: MEAN_ME_TAB-EAN11,
             MEAN_ME_TAB-NUMTP,
             MEAN_ME_TAB-HPEAN.
      MODIFY MEAN_ME_TAB INDEX EAN_AKT_ZEILE.  " zum Löschen vorgemerkt
*     dieses CLEAR entspricht dem Löschen von Hand ohne Löschbutton
      MEAN_ME_TAB_CHECK = X.   " Prüfung "Tabelle bereinigen" anstoßen

    ENDIF.
  ENDIF.

ENDMODULE.                             " OKCODE_EADE  INPUT
