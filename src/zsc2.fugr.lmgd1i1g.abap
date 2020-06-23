*&---------------------------------------------------------------------*
*&      Module  MARC-STRGR  INPUT
*&---------------------------------------------------------------------*
*       Planungsstrategiegruppe
*----------------------------------------------------------------------*
* AHE: 21.01.98 - A (4.0c)
* komplett neues Prüfmodul
*----------------------------------------------------------------------*
MODULE MARC-STRGR INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Prüfstatus zurücksetzen, falls Felder geändert wurden.
  IF ( RMMZU-PS_STRGR = X ) AND
     ( ( UMARC-STRGR NE MARC-STRGR ) OR
       ( UMARC-BSTRF NE MARC-BSTRF ) OR
* Note 316843
       ( UMARC-DISLS NE MARC-DISLS ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMARC-MATNR NE MARC-MATNR ) OR
       ( UMARC-WERKS NE MARC-WERKS ) ).
    CLEAR RMMZU-PS_STRGR.
  ENDIF.
* Wenn Prüfstatus = Space, Prüfbaustein aufrufen.
  IF RMMZU-PS_STRGR = SPACE.

    CALL FUNCTION 'MARC_STRGR'
         EXPORTING
              STRATEGY_GROUP             = MARC-STRGR
              ROUNDING_VALUE             = MARC-BSTRF
              LOT_SIZE                   = MARC-DISLS
*        TABLES
*             RETURN                     = TMESSAGE
         EXCEPTIONS
              STRATEGY_NOT_ALLOWED       = 1
              ROUNDING_VALUE_NOT_ALLOWED = 2
              OTHERS                     = 3.

    IF SY-SUBRC NE 0.
      IF SY-MSGTY NE 'E'.
*       Falls z.B. eine Warnung ausgegeben wird, wir diese auch als
*       S-Meldung ausgegeben. Das Prüfflag muß dann hier gesetzt
*       werden.
*       Bemerkung: P_KZ_NO_WARN muß hier nicht ausgewertet werden !
        RMMZU-PS_STRGR = X.
*       Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am
*       Ende des Bildes keine Aktualisierung von UMXXX erfolgt.
        UMARC = MARC.
      ENDIF.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MARC-STRGR'.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig entfallen.
  ENDIF.

ENDMODULE.                             " MARC-STRGR  INPUT
