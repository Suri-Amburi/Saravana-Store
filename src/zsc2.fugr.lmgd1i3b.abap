*------------------------------------------------------------------
*  Module MBEW-VJVPR.
*
*  Das Preissteuerungskz wird geprueft.
*------------------------------------------------------------------
MODULE MBEW-VJVPR.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ. "mk/21.04.95

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_VPRSV = X ) AND
     ( ( UMBEW-VJVPR NE MBEW-VJVPR ) OR
       ( UMBEW-VJVER NE MBEW-VJVER ) OR
* Note 316843
       ( UMBEW-VJSTP NE MBEW-VJSTP ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMBEW-MATNR NE MBEW-MATNR ) OR
       ( UMBEW-BWKEY NE MBEW-BWKEY ) OR
       ( UMBEW-BWTAR NE MBEW-BWTAR ) ).
    CLEAR RMMZU-PS_VPRSV.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_VPRSV IS INITIAL.

    CALL FUNCTION 'MBEW_VJVPR'
         EXPORTING
              WMBEW_VJVPR     = MBEW-VJVPR
              WMBEW_VJSAL     = MBEW-VJSAL
              WMBEW_VJSAV     = MBEW-VJSAV
              OMBEW_VJVPR     = *MBEW-VJVPR
              P_PS_VPRSV      = RMMZU-PS_VPRSV
              WMBEW_MATNR     = MBEW-MATNR "fbo/111298 Sharedsperre
              WRMMG1_BWKEY    = MBEW-BWKEY "fbo/111298 Sharedsperre
              WRMMG1_BWTAR    = MBEW-BWTAR "fbo/111298 Sharedsperre
         IMPORTING
              WMBEW_VJVPR     = MBEW-VJVPR
              P_PS_VPRSV      = RMMZU-PS_VPRSV.

* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_VPRSV NE SPACE.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MBEW-VJVPR'.
      MESSAGE S551.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMBEW = MBEW.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig hier entfallen.
  ENDIF.

ENDMODULE.
