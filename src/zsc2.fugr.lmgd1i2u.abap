*------------------------------------------------------------------
*  Module MARC-DISMM-FXHOR.
*  Falls Dispoverfahren mit Fixierung eingestellt ist, muß der
*  Fixierungshorizont eingegeben werden, es sei denn, er kann aus
*  der Dispogruppe ermittelt werden (dann keine Eingabe erforderlich,
*  aber Warnmeldung erfolgt).
*------------------------------------------------------------------
MODULE MARC-DISMM-FXHOR.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Prüfstatus zurücksetzen, falls Felder geändert wurden.
  IF ( RMMZU-PS_FXHOR = X ) AND
     ( ( UMARC-DISMM NE MARC-DISMM ) OR
* Note 316843
       ( UMARC-FXHOR NE MARC-FXHOR ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMARC-MATNR NE MARC-MATNR ) OR
       ( UMARC-WERKS NE MARC-WERKS ) ).
    CLEAR RMMZU-PS_FXHOR.
  ENDIF.
* Wenn Prüfstatus = Space, Prüfbaustein aufrufen.
  IF RMMZU-PS_FXHOR = SPACE.
    CALL FUNCTION 'MARC_DISMM_FXHOR'
         EXPORTING
              P_DISMM      = MARC-DISMM
              P_FXHOR      = MARC-FXHOR
              P_DISGR      = MARC-DISGR
              P_PS_FXHOR   = RMMZU-PS_FXHOR
              P_KZ_NO_WARN = ' '
         IMPORTING
              P_PS_FXHOR   = RMMZU-PS_FXHOR.
*        EXCEPTIONS
*             ERR_MARC_FXHOR = 01.
* Warnung außerhalb als S-Meldung ausgeben, da mehrere Felder betroffen
* sind.
    IF RMMZU-PS_FXHOR NE SPACE.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MARC-FXHOR'.
      MESSAGE S550.
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
