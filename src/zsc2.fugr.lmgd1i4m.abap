*------------------------------------------------------------------
*  Module MPOP-PERIO.
* Die Anzahl Perioden pro Saison wird vorgeschlagen bei Saison.
*------------------------------------------------------------------
MODULE MPOP-PERIO.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_PERIO = X ) AND
     ( ( UMPOP-PRMOD NE MPOP-PRMOD ) OR
       ( UMPOP-MODAW NE MPOP-MODAW ) OR
* Note 316843
       ( UMPOP-PERIO NE MPOP-PERIO ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMPOP-MATNR NE MPOP-MATNR ) OR
       ( UMPOP-WERKS NE MPOP-WERKS ) ).
    CLEAR RMMZU-PS_PERIO.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_PERIO IS INITIAL.
    CALL FUNCTION 'MPOP_PERIO'
         EXPORTING
              P_PRMOD      = MPOP-PRMOD
              P_MODAW      = MPOP-MODAW
              P_PERIO      = MPOP-PERIO
              P_PS_PERIO   = RMMZU-PS_PERIO
              P_KZ_NO_WARN = ' '
         IMPORTING
              P_PERIO      = MPOP-PERIO
              P_PS_PERIO   = RMMZU-PS_PERIO.
*    EXCEPTIONS
*         P_ERR_MPOP_PERIO = 01.     " wird z. Z. nicht benutzt
* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_PERIO NE SPACE.
      BILDFLAG = X.
      MESSAGE S455.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMPOP = MPOP.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig hier entfallen.
  ENDIF.

ENDMODULE.
