*------------------------------------------------------------------
*  Module MBEW-VMPEI.
*
* Pruefen Preiseinheit auf Eingabe groesser Null. Beim Aendern werden
* die Preise entsprechend der neuen Preiseinheit errechnet. Dabei wird
* geprueft, ob es durch die neue Preiseinheit zu Preisueberlaeufen
* kommt. Wenn ja, wird das Aendern der Preiseinheit nicht zugelassen.
* Der bewertungsrelevante Preis (Standardpreis bei Preissteuerung 'S',
* Verrechnungspreis bei Preissteuerung 'V') wird ueber VMSAL und VMKUM
* emittelt, falls ein bewerteter Bestand vorhanden ist. Kommt es dabei
* zu Rundungsdifferenzen wird eine entsprechende Nachricht ausgegeben.
* Bei Aenderung der Preissteuerung wird der Bewertungspreis neu
* gesetzt.
*------------------------------------------------------------------
MODULE mbew-vmpei.

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
* Prozessieren wegen Daten-Veränderung durch FIELD-Anweisung "BE/220197
* CHECK BILDFLAG = SPACE.                                    "BE/220197

* Generelle Überarbeitung ohne Einzelstatementkennzeichnung: "BE/220197
* Umstellung der Vergleichslogik von LMBEW auf UMBEW         "BE/220197

* note 489818 ML-Puffer aktualisieren
  CALL FUNCTION 'MBEW_GET_ML_BUFFER'
    IMPORTING
      mlmbew = umbew.

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( rmmzu-ps_peinh = x ) AND
     ( ( umbew-vmvpr NE mbew-vmvpr ) OR
       ( umbew-vmver NE mbew-vmver ) OR
       ( umbew-vmstp NE mbew-vmstp ) OR
       ( umbew-vmpei NE mbew-vmpei ) OR
* Note 316843
       ( umbew-vmbkl NE mbew-vmbkl ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( umbew-matnr NE mbew-matnr ) OR
       ( umbew-bwkey NE mbew-bwkey ) OR
       ( umbew-bwtar NE mbew-bwtar ) ).
    CLEAR rmmzu-ps_peinh.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF rmmzu-ps_peinh IS INITIAL.

* Initialisierung UMBEW -> wird jetzt anstelle LMBEW übergeben
    IF umbew-matnr NE lmbew-matnr OR
       umbew-bwkey NE lmbew-bwkey OR
       umbew-bwtar NE lmbew-bwtar.
      umbew = lmbew.
    ENDIF.

    CALL FUNCTION 'MBEW_VMPEI'
         EXPORTING
              wmbew       = mbew
*             LMBEW       = LMBEW                            "BE/220197
              lmbew       = umbew                           "BE/220197
              p_aktyp     = t130m-aktyp
         IMPORTING
              wmbew       = mbew
              flg_dialog  = flag1
         TABLES
              p_ptab      = ptab.

* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF flag1 IS INITIAL.
      rmmzu-ps_peinh = x.
      bildflag = x.
      MESSAGE s155.            "Meldung mit Anzeige Preisänderung
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      umbew = mbew.
* note 489818 ML-Puffer aktualisieren
      CALL FUNCTION 'MBEW_SET_ML_BUFFER'
        EXPORTING
          mlmbew = mbew.
    ELSE.                              "4.0A  BE/040897
      umbew = mbew.            "Generell aktualisieren "4.0A  BE/040897
* note 489818 ML-Puffer aktualisieren
      CALL FUNCTION 'MBEW_SET_ML_BUFFER'
        EXPORTING
          mlmbew = mbew.

    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig hier entfallen.
  ENDIF.

ENDMODULE.                    "MBEW-VMPEI
