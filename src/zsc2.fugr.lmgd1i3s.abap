
*------------------------------------------------------------------
*Module MBEW-BKLAS.
*
*Pruefung der Bewertungsklasse
*
* - einheitliche Bewertung
*   Bewertungsklasse muß gefüllt sein
*   weitere Prüfung siehe Routine Bewertungsklasse
* - getrennte Bewertung
*  - Bewertungsklasse muß in folgenden Fällen gefüllt sein:
*    - Bewertungsart ist gefüllt
*    - Bewertungsart ungefüllt, aber die automatische Anlage von
*      Bewertungssätzen ist erlaubt für den Bewertungstyp
*      (in diesem Fall wird bei der automatischen Anlage in der
*      Bestandsführung die Bewertungsklasse des Kopfsatzes in den
*      Detailsatz übernommen)
*    Weitere Prüfungen siehe Routine Bewertungsklasse (Im Falle
*    getrennter Bewertung ohne automatische Anlage wäre bei ungefüllter
*    Bewertungsart keine weitere Prüfung notwendig, der Einfachheit
*    halber wird in diesem Fall auch gegen die Materialart abgeglichen)
*    Ab 3.0 erfolgen diese weiteren Prüfungen nur noch, wenn eine
*    bereits zugeordnete Bewertungsklasse geändert wird. (K11K093523)
*------------------------------------------------------------------
MODULE MBEW-BKLAS.

  CHECK BILDFLAG = SPACE OR UMBEW-BKLAS NE MBEW-BKLAS.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

*mk/3.0C Prüfung nur sinnvoll, wenn MBEW überhaupt aktiv ist, speziell
*Fehlermeldung, wenn initial (analog zum material_update_all)
* CHECK AKTVSTATUS CA STATUS_B.                "ch zu 3.1I ->H: 81698

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_BKLAS = X ) AND
     ( ( UMBEW-BKLAS NE MBEW-BKLAS ) OR
* Note 316843
       ( UMBEW-BWTTY NE MBEW-BWTTY ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMBEW-MATNR NE MBEW-MATNR ) OR
       ( UMBEW-BWKEY NE MBEW-BWKEY ) OR
       ( UMBEW-BWTAR NE MBEW-BWTAR ) ).
    CLEAR RMMZU-PS_BKLAS.
  ENDIF.
* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_BKLAS IS INITIAL.

    CALL FUNCTION 'MBEW_BKLAS'
         EXPORTING
              WMBEW_BKLAS     = MBEW-BKLAS
              WMBEW_BWKEY     = MBEW-BWKEY
              WMBEW_BWTTY     = MBEW-BWTTY
              WMBEW_SALK3     = MBEW-SALK3
              WMBEW_BWTAR     = MBEW-BWTAR
              LMBEW_BKLAS     = LMBEW-BKLAS
              OMBEW_BKLAS     = *MBEW-BKLAS
              WMBEW_MATNR     = RMMG1-MATNR         "ch/40C ->H: 102653
              WMARA_ATTYP     = MARA-ATTYP          "ch/40C ->H: 102653
              WRMMG1_MTART    = RMMG1-MTART
              P_AKTYP         = T130M-AKTYP
              P_PS_BKLAS      = RMMZU-PS_BKLAS
              OMBEW_MLAST     = *MBEW-MLAST      "1388546
         IMPORTING
              WMBEW_BKLAS     = MBEW-BKLAS
              P_PS_BKLAS      = RMMZU-PS_BKLAS
         EXCEPTIONS
              NO_BKLAS        = 01
              ERROR_BKLAS     = 02
              ERROR_NACHRICHT = 03.

* Errormeldung als S-Meldung ausgeben
    IF SY-SUBRC NE 0.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MBEW-BKLAS'.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_BKLAS NE SPACE.
      BILDFLAG = X.
      RMMZU-FLG_FLISTE = 'X'.                               "note 865189
      RMMZU-CURS_FELD = 'MBEW-BKLAS'.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMBEW = MBEW.
      MESSAGE W368.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig hier entfallen.
  ENDIF.

ENDMODULE.

*------------------------------------------------------------------
*Module MBEW-EKLAS.                             ch/4.6B
*
* Prüfung Bewertungksklasse für einzeln bewerteten Kundenauftr. Bestand
*------------------------------------------------------------------
MODULE MBEW-EKLAS.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CALL FUNCTION 'MBEW_XKLAS'
       EXPORTING
            WMBEW_XKLAS  = mbew-eklas
            WMBEW_BWKEY  = mbew-bwkey
            WMBEW_BWTTY  = mbew-bwtty
            WMBEW_BWTAR  = mbew-bwtar
            LMBEW_XKLAS  = lmbew-eklas
            WMBEW_MATNR  = rmmg1-matnr
            WRMMG1_MTART = rmmg1-mtart .

endmodule.


*------------------------------------------------------------------
*Module MBEW-QKLAS.                             ch/4.6B
*
* Prüfung Bewertungksklasse für einzeln bewerteten Kundenauftr. Bestand
*------------------------------------------------------------------
MODULE MBEW-QKLAS.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CALL FUNCTION 'MBEW_XKLAS'
       EXPORTING
            WMBEW_XKLAS  = mbew-qklas
            WMBEW_BWKEY  = mbew-bwkey
            WMBEW_BWTTY  = mbew-bwtty
            WMBEW_BWTAR  = mbew-bwtar
            LMBEW_XKLAS  = lmbew-qklas
            WMBEW_MATNR  = rmmg1-matnr
            WRMMG1_MTART = rmmg1-mtart .

endmodule.
*------------------------------------------------------------------
*Module MBEW-OKLAS.                             ch/4.6C
*
* Pruefung Bewertungksklasse fuer einzeln bewerteten Kundenauftr. Bestan
*------------------------------------------------------------------
module mbew-oklas input.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CALL FUNCTION 'MBEW_XKLAS'
       EXPORTING
            WMBEW_XKLAS  = mbew-oklas
            WMBEW_BWKEY  = mbew-bwkey
            WMBEW_BWTTY  = mbew-bwtty
            WMBEW_BWTAR  = mbew-bwtar
            LMBEW_XKLAS  = lmbew-oklas
            WMBEW_MATNR  = rmmg1-matnr
            WRMMG1_MTART = rmmg1-mtart .

endmodule.                 " MBEW-OKLAS  INPUT
