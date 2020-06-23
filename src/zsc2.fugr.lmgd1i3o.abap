*eject
*------------------------------------------------------------------
*  Module MBEW-PEINH.
*
* Pruefen Preiseinheit auf Eingabe groesser Null. Beim Aendern werden
* die Preise entsprechend der neuen Preiseinheit errechnet. Dabei wird
* geprueft, ob es durch die neue Preiseinheit zu Preisueberlaeufen
* kommt. Wenn ja, wird das Aendern der Preiseinheit nicht zugelassen.
* Achtung: die Niederwerstpreise beziehen sich nicht auf die Preis-
*          einheit im Materialstamm und werden deswegen nicht angepaßt.
*          Angepaßt werden aber die Kalkulationsplanpreise
* Der bewertungsrelevante Preis (Standardpreis bei Preissteuerung 'S',
* Verrechnungspreis bei Preissteuerung 'V') wird ueber SALK3 und LBKUM
* emittelt, falls ein bewerteter Bestand vorhanden ist. Kommt es dabei
* zu Rundungsdifferenzen wird eine entsprechende Nachricht ausgegeben.
*
* Ist die Kalkulationssicht bereits vorhanden, so wird die Kalkulations-
* losgröße gleich der Preiseinheit gesetzt, wenn sie infolge der
* Änderung kleiner würde.
*
* Bei Aenderung der Preissteuerung wird der Bewertungspreis neu
* gesetzt.
*------------------------------------------------------------------
MODULE MBEW-PEINH.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MBEW_PEINH_INIT'      "ch zu 4.0
       EXCEPTIONS
            OTHERS  = 1.
* note 489818 ML-Puffer aktualisieren
  CALL FUNCTION 'MBEW_GET_ML_BUFFER'
       IMPORTING
            MLMBEW = UMBEW.


* Prozessieren wegen Daten-Veränderung durch FIELD-Anweisung "BE/220197
* CHECK BILDFLAG = SPACE.                                    "BE/220197

*mk/3.0C Prüfung nur sinnvoll, wenn MBEW überhaupt aktiv ist, speziell
*Fehlermeldung, wenn initial (analog zum material_update_all)
* CHECK AKTVSTATUS CA STATUS_B.                "ch zu 3.1I ->H: 81698

* Generelle Überarbeitung ohne Einzelstatementkennzeichnung: "BE/220197
* Umstellung der Vergleichslogik von LMBEW auf UMBEW         "BE/220197

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_PEINH = X ) AND
     ( ( UMBEW-VPRSV NE MBEW-VPRSV ) OR
       ( UMBEW-VERPR NE MBEW-VERPR ) OR
       ( UMBEW-STPRS NE MBEW-STPRS ) OR
       ( UMBEW-PEINH NE MBEW-PEINH ) OR
* Note 316843
       ( UMBEW-BKLAS NE MBEW-BKLAS ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMBEW-MATNR NE MBEW-MATNR ) OR
       ( UMBEW-BWKEY NE MBEW-BWKEY ) OR
       ( UMBEW-BWTAR NE MBEW-BWTAR ) ).
    CLEAR RMMZU-PS_PEINH.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_PEINH IS INITIAL.

* Initialisierung UMBEW -> wird jetzt anstelle LMBEW übergeben
    IF UMBEW-MATNR NE LMBEW-MATNR OR
       UMBEW-BWKEY NE LMBEW-BWKEY OR
       UMBEW-BWTAR NE LMBEW-BWTAR.
      UMBEW = LMBEW.
    ENDIF.

    CALL FUNCTION 'MBEW_PEINH'
         EXPORTING
              WMBEW       = MBEW
*             LMBEW       = LMBEW                            "BE/220197
              LMBEW       = UMBEW      "BE/220197
              KALK_LOSGR  = RMMG2-KALK_LOSGR                 "ch/4.0c
              WMARC_LOSGR = MARC-LOSGR
              P_AKTYP     = T130M-AKTYP
         IMPORTING
              WMBEW       = MBEW
              WMARC_LOSGR = MARC-LOSGR
              KALK_LOSGR  = RMMG2-KALK_LOSGR                 "ch/4.0c
              FLG_DIALOG  = FLAG1
         TABLES
              P_PTAB      = PTAB.

* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF FLAG1 IS INITIAL.
      RMMZU-PS_PEINH = X.
* note 329079, Meldung nicht im Neuanlagefall
      READ TABLE PTAB WITH KEY 'MBEW' BINARY SEARCH.
      IF PTAB-RCODE = 0 OR             "MBEW existiert auf der DB
         ( not PTAB-PFSTATUS is initial and processflag eq 'X' ).
        BILDFLAG = X.
ENHANCEMENT-SECTION     LMGD1I30_01 SPOTS ES_LMGD1TOP.
        MESSAGE S155.            "Meldung mit Anzeige Preisänderung
END-ENHANCEMENT-SECTION.
      endif.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
     UMBEW = MBEW.
* note 489818 ML-Puffer aktualisieren
      CALL FUNCTION 'MBEW_SET_ML_BUFFER'
           EXPORTING
                MLMBEW = MBEW.
    ELSE.                              "4.0A  BE/040897
     UMBEW = MBEW.            "Generell aktualisieren "4.0A  BE/040897
* note 489818 ML-Puffer aktualisieren
      CALL FUNCTION 'MBEW_SET_ML_BUFFER'
           EXPORTING
                MLMBEW = MBEW.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig hier entfallen.
  ENDIF.

  processflag = 'X'.

ENDMODULE.
