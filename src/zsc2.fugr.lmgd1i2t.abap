*------------------------------------------------------------------
*  Module MARC_DISMM_MINBE.
*  Bei Bestellpunktverfahren ist Meldebestand obligatorisch, ansonsten
*  wird das Feld zurückgesetzt.
*------------------------------------------------------------------
MODULE MARC_DISMM_MINBE.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  check not rmmg1-werks is initial.                     "cfo/4.6B

* Prüfstatus zurücksetzen, falls Felder geändert wurden.
  IF ( RMMZU-PS_MINBE = X ) AND
     ( ( UMARC-DISMM NE MARC-DISMM ) OR
* Note 316843
       ( UMARC-MINBE NE MARC-MINBE ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMARC-MATNR NE MARC-MATNR ) OR
       ( UMARC-WERKS NE MARC-WERKS ) ).
    CLEAR RMMZU-PS_MINBE.
  ENDIF.
* Wenn Prüfstatus = Space, Prüfbaustein aufrufen.
  IF RMMZU-PS_MINBE = SPACE.
    CALL FUNCTION 'MARC_DISMM_MINBE'
         EXPORTING
              P_DISMM                = MARC-DISMM
              P_MINBE                = MARC-MINBE
              P_DISPR                = MARC-DISPR
              P_PS_MINBE             = RMMZU-PS_MINBE
              P_KZ_NO_WARN           = ' '
         IMPORTING
              P_MINBE                = MARC-MINBE
              P_PS_MINBE             = RMMZU-PS_MINBE
         EXCEPTIONS
              P_ERR_MARC_DISMM_MINBE = 01.
    IF SY-SUBRC NE 0.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MARC-MINBE'.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Warnung außerhalb als S-Meldung ausgeben, da mehrere Felder betroffen
* sind.
    IF RMMZU-PS_MINBE NE SPACE.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MARC-MINBE'.
      MESSAGE S440.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMARC = MARC.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig entfallen.
  ENDIF.

ENDMODULE.
