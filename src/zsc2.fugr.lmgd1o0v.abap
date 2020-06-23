*&---------------------------------------------------------------------*
*&      Module  FELDAUSWAHL_EAN_ZUS  OUTPUT
*&---------------------------------------------------------------------*
*       Alle schon angezeigten Mengeneinheiten werden nur auf Ausgabe
*       geschaltet, nur die leeren Zeilen im Step-Loop sind noch
*       komplett eingabebereit. Jeder erste Eintrag einer Mengeneinheit
*       wird optisch hervorgehoben. In jedem weiteren Eintrag zu einer
*       Mengeneinheit wird die Bezeichnung zur Mengeneinheit
*       ausgeblendet.
*       Im Fehlerfall wird die Mengeneinheit zur Korrektur frei-
*       geschaltet.
*       Im Anzeigemodus ist logischerweise nichts eingabebereit.
*----------------------------------------------------------------------*
MODULE FELDAUSWAHL_EAN_ZUS OUTPUT.

  EAN_AKT_ZEILE = EAN_ERSTE_ZEILE + SY-STEPL.

*mk/4.0A EAN sind für MPN-Materialien nicht pflegbar
  IF NOT RMMG2-KZMPN IS INITIAL.
    LOOP AT SCREEN.
      SCREEN-INVISIBLE = 1.
      SCREEN-ACTIVE    = 0.
      SCREEN-OUTPUT    = 0.
      SCREEN-INPUT     = 0.
      SCREEN-REQUIRED  = 0.
      MODIFY SCREEN.
    ENDLOOP.
    EXIT.
  ENDIF.

  READ TABLE MEAN_ME_TAB INDEX EAN_AKT_ZEILE.
  IF SY-SUBRC = 0.
* Belegte Zeilen: Es wird jeder erste Eintrag einer Mengeneinheit
* intensified geschaltet. Beim Anzeigen wird die gesamte Zeile auf "nur
* Ausgabe" geschaltet.

    IF MEAN_ME_TAB-MEINH = HILFS_MEEIN.
*   MEINH hat sich nicht geändert
      CLEAR FLAG_INTENSIFY.
    ELSE.
*   neue MEINH
      FLAG_INTENSIFY = X.
      HILFS_MEEIN = MEAN_ME_TAB-MEINH.
    ENDIF.

    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ   " Anzeigen
    OR RMMG2-MANBR NE SPACE.  "Prf. zentr. Berechtigung ab 3.0F/Rt1.2 ch
      LOOP AT SCREEN.
*       note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
        IF SCREEN-NAME = 'MEAN-EAN11' OR SCREEN-NAME = 'MEAN-HPEAN'.
          SCREEN-NAME = 'SMEINH-EAN11'.
        ENDIF.
        IF SCREEN-NAME = 'MEAN-EANTP'.
          SCREEN-NAME = 'SMEINH-NUMTP'.
        ENDIF.
        READ TABLE FAUSWTAB WITH KEY FNAME = SCREEN-NAME BINARY SEARCH.
        IF SY-SUBRC = 0.
          SCREEN-ACTIVE      = FAUSWTAB-KZACT.
          SCREEN-INPUT       = FAUSWTAB-KZINP.
          SCREEN-INTENSIFIED = FAUSWTAB-KZINT.
          SCREEN-INVISIBLE   = FAUSWTAB-KZINV.
          SCREEN-OUTPUT      = FAUSWTAB-KZOUT.
*         don't set MEAN-HPEAN or RMMZU-AUTO_PRFZ as required field
          IF SCREEN-GROUP1(1) NE 'T' AND SCREEN-GROUP1 NE 'F02'.
            SCREEN-REQUIRED    = FAUSWTAB-KZREQ.
          ENDIF.
        ENDIF.

        SCREEN-INPUT       = 0.
        SCREEN-REQUIRED    = 0.
*     Jede erste neue MEINH intensified schalten und alle Bezeichnungen
*     für die nächsten Einträge dieser Mengeneinheit ausblenden.
        IF NOT FLAG_INTENSIFY IS INITIAL AND
*           screen-group1 = '001'.      mk/4.0A
           ( SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001' ).
          SCREEN-INTENSIFIED = 1.
*        elseif screen-group1 = '002' and  mk/4.0A
        ELSEIF ( SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002' ) AND
              FLAG_INTENSIFY IS INITIAL.
          SCREEN-ACTIVE = 0.
        ENDIF.
*       Prf. Berechtigung für zentrale Daten ab 3.0F/Rt1.2         ch
        IF RMMG2-MANBR = MANBR1.       "nur   Anzeigeberechtigung.
        ENDIF.
        IF RMMG2-MANBR = MANBR2.       "keine Anzeigeberechtigung.
          SCREEN-INVISIBLE = 1.
          SCREEN-ACTIVE    = 0.
          SCREEN-OUTPUT    = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    ELSE.                              " Anlegen / Ändern

      LOOP AT SCREEN.
*       if screen-group1 = '001'.     mk/4.0A
        IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001'.
          IF NOT MEAN_ME_TAB-MEINH IS INITIAL.
            SCREEN-INPUT       = 0.
            SCREEN-REQUIRED    = 0.
* neu 27.10.95 - A
*           Cursor positionieren und hervorheben der Zeile,
*           falls im vorherigen PAI ein Fehler (S-Meldung)
*           ausgegeben wurde. Außerdem freischalten
*           der Mengeneinheit zur Korrektur.
            IF NOT EAN_FEHLERFLG_ME IS INITIAL        AND
               MEAN_TAB_KEY-MEINH = MEAN_ME_TAB-MEINH. " AND
*              MEAN_TAB_KEY-EAN11 = MEAN_ME_TAB-EAN11.
              SCREEN-INPUT       = 1.
*             SCREEN-REQUIRED    = 1.
              SCREEN-INTENSIFIED = 1.
*             Zur Cursorpositionierung
              MOVE SY-STEPL TO EAN_ZEILEN_NR.
*             PERFORM EAN_SET_ZEILE.
            ENDIF.
* neu 27.10.95 - E

*           Jede erste neue MEINH intensified schalten
            IF NOT FLAG_INTENSIFY IS INITIAL.
              SCREEN-INTENSIFIED = 1.
            ENDIF.
          ENDIF.
*       elseif screen-group1 = '002' and   mk/4.0A
        ELSEIF ( SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002' ) AND
               FLAG_INTENSIFY IS INITIAL.
*       Bei jedem weiteren Eintrag zu einer Mengeneinheit wird die
*       Bezeichnung ausgeblendet.
          SCREEN-ACTIVE = 0.
        ENDIF.

* AHE: 04.06.96 - A
* Retail-Fall: EAN-Lieferantenbezug-Handling
        IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
               RMMW2_LIEF IS INITIAL.
*         Wenn kein Lieferant angegeben ist, wird  RMMZU-LIEFZU und
*         MLEA-LFEAN generell auf Anzeige gestellt.
*         if screen-group1 = '003'.    " RMMZU-LIEFZU, MLEA-LFEAN mk4.0A
* AHE: 27.01.99 - A (4.6a)
*         IF SCREEN-GROUP1 = '003' OR SCREEN-GROUP2 = '003'.
          IF SCREEN-GROUP1 = '003' OR SCREEN-GROUP2 = '003' OR
             SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004'.
* AHE: 27.01.99 - E
            SCREEN-INPUT       = 0.
            SCREEN-REQUIRED    = 0.
          ENDIF.
        ENDIF.

* AHE: 27.01.99 - A (4.6a)
* <== Feldauswahl vorher gilt auch für neues Feld MLEA-LARTN !!

* Hier werden nur die Felder für MLEA-LARTN freigeschaltet, für die
* die Lieferanten-EAN als Haupt-EAN gekennzeichnet ist.
        IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
           NOT RMMW2_LIEF IS INITIAL.
          IF NOT MLEA-LFEAN IS INITIAL.
            IF SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004'.
              IF RMMW2_VARN IS INITIAL.
                SCREEN-INPUT       = 0.
                SCREEN-REQUIRED    = 0.
              ELSE.
                SCREEN-INPUT       = 1.
                SCREEN-ACTIVE      = 1.
              ENDIF.
            ENDIF.
          ELSE.
            IF SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004'.
              SCREEN-INPUT       = 0.
              SCREEN-REQUIRED    = 0.
            ENDIF.
          ENDIF.
        ENDIF.
* AHE: 27.01.99 - E

* AHE: 04.06.96 - E

*       note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
*       note 1402388: do this only for MEAN fields to don't overwrite
*       for instance special MLEA settings
        IF SCREEN-NAME = 'MEAN-EAN11' OR SCREEN-NAME = 'MEAN-HPEAN' OR
           SCREEN-NAME = 'MEAN-EANTP'.
          IF SCREEN-NAME = 'MEAN-EAN11' OR SCREEN-NAME = 'MEAN-HPEAN'.
            SCREEN-NAME = 'SMEINH-EAN11'.
          ENDIF.
          IF SCREEN-NAME = 'MEAN-EANTP'.
            SCREEN-NAME = 'SMEINH-NUMTP'.
          ENDIF.
          READ TABLE FAUSWTAB WITH KEY FNAME = SCREEN-NAME BINARY SEARCH.
          IF SY-SUBRC = 0.
            SCREEN-ACTIVE      = FAUSWTAB-KZACT.
            SCREEN-INPUT       = FAUSWTAB-KZINP.
            SCREEN-INTENSIFIED = FAUSWTAB-KZINT.
            SCREEN-INVISIBLE   = FAUSWTAB-KZINV.
            SCREEN-OUTPUT      = FAUSWTAB-KZOUT.
*           don't set MEAN-HPEAN or RMMZU-AUTO_PRFZ as required field
            IF SCREEN-GROUP1(1) NE 'T' AND SCREEN-GROUP1 NE 'F02'.
              SCREEN-REQUIRED    = FAUSWTAB-KZREQ.
            ENDIF.
          ENDIF.
        ENDIF.                                             "note 1402388

        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

  ELSE.

*   Leere Zeilen: Beim "Anzeigen" werden diese Zeilen komplett auf "nur
*   Ausgabe" geschaltet.

    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ  " Anzeigen
  OR RMMG2-MANBR NE SPACE.  "Prf. zentr. Berechtigung ab 3.0F/Rt1.2 ch
      LOOP AT SCREEN.
*       note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
        IF SCREEN-NAME = 'MEAN-EAN11' OR SCREEN-NAME = 'MEAN-HPEAN'.
          SCREEN-NAME = 'SMEINH-EAN11'.
        ENDIF.
        IF SCREEN-NAME = 'MEAN-EANTP'.
          SCREEN-NAME = 'SMEINH-NUMTP'.
        ENDIF.
        READ TABLE FAUSWTAB WITH KEY FNAME = SCREEN-NAME BINARY SEARCH.
        IF SY-SUBRC = 0.
          SCREEN-ACTIVE      = FAUSWTAB-KZACT.
          SCREEN-INPUT       = FAUSWTAB-KZINP.
          SCREEN-INTENSIFIED = FAUSWTAB-KZINT.
          SCREEN-INVISIBLE   = FAUSWTAB-KZINV.
          SCREEN-OUTPUT      = FAUSWTAB-KZOUT.
          SCREEN-REQUIRED    = 0. "no required fields on an empty line
        ENDIF.

        SCREEN-INPUT       = 0.
        SCREEN-REQUIRED    = 0.
*       Prf. Berechtigung für zentrale Daten ab 3.0F/Rt1.2         ch
        IF RMMG2-MANBR = MANBR1.       "nur   Anzeigeberechtigung.
        ENDIF.
        IF RMMG2-MANBR = MANBR2.       "keine Anzeigeberechtigung.
          SCREEN-INVISIBLE = 1.
          SCREEN-ACTIVE    = 0.
          SCREEN-OUTPUT    = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.
*       note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
        IF SCREEN-NAME = 'MEAN-EAN11' OR SCREEN-NAME = 'MEAN-HPEAN'.
          SCREEN-NAME = 'SMEINH-EAN11'.
        ENDIF.
        IF SCREEN-NAME = 'MEAN-EANTP'.
          SCREEN-NAME = 'SMEINH-NUMTP'.
        ENDIF.
        READ TABLE FAUSWTAB WITH KEY FNAME = SCREEN-NAME BINARY SEARCH.
        IF SY-SUBRC = 0.
          SCREEN-ACTIVE      = FAUSWTAB-KZACT.
          SCREEN-INPUT       = FAUSWTAB-KZINP.
          SCREEN-INTENSIFIED = FAUSWTAB-KZINT.
          SCREEN-INVISIBLE   = FAUSWTAB-KZINV.
          SCREEN-OUTPUT      = FAUSWTAB-KZOUT.
          SCREEN-REQUIRED    = 0. "no required fields on an empty line
        ENDIF.

*       note 1085078: close LARTN for empty lines
        IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
           ( RMMW2_LIEF IS INITIAL OR RMMW2_VARN IS INITIAL ) AND
           ( SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004' ).
          SCREEN-INPUT       = 0.
          SCREEN-REQUIRED    = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

  ENDIF.
ENDMODULE.                             " FELDAUSWAHL_EAN_ZUS  OUTPUT
