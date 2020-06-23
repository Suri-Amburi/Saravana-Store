*&---------------------------------------------------------------------*
*&      Module  ME_INITIALISIERUNG  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Initflag, ermitteln Anzahl Zeilen, Basismengen-         *
*       einheit an erster Stelle anzeigen.                             *
*----------------------------------------------------------------------*
MODULE ME_INITIALISIERUNG OUTPUT.

* jw 21.12.98: LHM-Menge bzgl. Basis-ME berechnen und speichern.
  PERFORM ME_LHMG_BZGL_BME_BERECHNEN.

* AHE: 01.10.96 - A
* Flag darf nicht im Step-Loop (PAI) initialisiert werden !
  CLEAR ME_EANERRFLG.
* AHE: 01.10.96 - E

* AHE: 19.06.96 - A
* Retail-Fall: EAN-Lieferantenbezug-Handling
* soll bei jedem PBO ablaufen
  CLEAR: EAN_UPD.

  IF NOT RMMG2-FLG_RETAIL IS INITIAL.
* Lieferant lesen aus RMMW2, MATNR lesen aus RMMW1
    CALL FUNCTION 'GET_ZUS_RETAIL'
         IMPORTING
              RMMW2_LIFNR = RMMW2_LIEF
              RMMW1_MATNR = RMMW1_MATN
              RMMW2_VARNR = RMMW2_VARN
              RMMW2_SATNR = RMMW2_SATN.
  ELSE.
    CLEAR: RMMW2_LIEF, RMMW1_MATN, RMMW2_VARN, RMMW2_SATN.
  ENDIF.
* AHE: 19.06.96 - E

* AHE: 16.07.96 - A
* Umstellung auf Table-Control

* CHECK RMMZU-MINIT = SPACE.
* RMMZU-MINIT = X.
*
* CLEAR: ME_ERSTE_ZEILE.
*
*--Ermitteln der Anzahl der Mengeneinheiten ----------------------
* DESCRIBE TABLE MEINH LINES ME_LINES.
*
*--Mengeneinh. neu sort. - Basismengeneinh. an erste Stelle ------
* SORT MEINH BY KZBME DESCENDING MEINH ASCENDING.
*
**cfo/22.06.95/ 'Sort' sortiert manchmal alle Einträge um statt nur
** die Basismengeneinheit
** READ TABLE MEINH WITH KEY MEINH = MARA-MEINS.
** IF SY-SUBRC = 0.
**   CHECK NOT SY-TABIX = 1.
**   DELETE MEINH INDEX SY-TABIX.
**   INSERT MEINH INDEX 1.
** ENDIF.

  IF RMMZU-MINIT IS INITIAL.
    RMMZU-MINIT = X.
    CLEAR: ME_ERSTE_ZEILE.
  ELSE.                                         "ch zu 4.0
    IF ME_LINES = 0.                            "
      ME_ERSTE_ZEILE = 0.                       "
    ELSEIF ME_ERSTE_ZEILE GE ME_LINES.          "
      ME_ERSTE_ZEILE = ME_LINES - 1.            "
    ENDIF.                                      "
  ENDIF.

* AHE: 24.07.96 - A
* AHE: 12.08.96 - wieder deaktiviert ! ! !
* wegen Table Control; Cursor steht in der ersten Zeile mit der
* Basismengeneinheit sonst immer auf dem ersten Feld, das
* eingabebereit ist (hier EAN); dieses ist jedoch sehr weit rechts
* angesiedelt -> optisch sehr schlecht auf Grunddatenbild.
* IF ME_ERSTE_ZEILE IS INITIAL OR
*    ME_ERSTE_ZEILE = 1.
*   SET CURSOR FIELD 'SMEINH-UMREN' LINE 1.
* ENDIF.
* AHE: 24.07.96 - E

*--Ermitteln der Anzahl der Mengeneinheiten ----------------------
  DESCRIBE TABLE MEINH LINES ME_LINES.

*--Mengeneinh. neu sort. - Basismengeneinh. an erste Stelle ------
* SORT MEINH BY KZBME DESCENDING MEINH ASCENDING.
* WS Abwicklung: zusätzliche Sortierung nach Sort-Regel/Verwendungs-KZ

* SORT MEINH BY KZBME DESCENDING MESRT ASCENDING
*                                KZWSO ASCENDING
*                                MEINH ASCENDING.

* JW/4.6A: neue Sortierung gemaess der Verpackungshierarchie
  perform sort_meinh.

* note 700229
  IF NOT_SET_OLD_MEINH IS INITIAL.
    old_meinh[] = meinh[].
  ENDIF.

  IF NOT FLG_TC IS INITIAL.
    CASE SY-DYNNR.
      WHEN DP_8020.
        REFRESH CONTROL 'TC_ME_8020' FROM SCREEN SY-DYNNR.
        TC_ME_8020-LINES    = ME_LINES.
        TC_ME_8020-TOP_LINE = ME_ERSTE_ZEILE + 1.
        TC_ME_TOPL_BUF      = TC_ME_8020-TOP_LINE. " Puffer für TCtrl
        ASSIGN TC_ME_8020 TO <F_TC>.   "wk/4.0
ENHANCEMENT-POINT EHP606_LSPL_LMGD1O0P_01 SPOTS ES_LMGD1O0P INCLUDE BOUND .

      WHEN DP_8021.
        REFRESH CONTROL 'TC_ME_8021' FROM SCREEN SY-DYNNR.
        TC_ME_8021-LINES    = ME_LINES.
        TC_ME_8021-TOP_LINE = ME_ERSTE_ZEILE + 1.
        TC_ME_TOPL_BUF      = TC_ME_8021-TOP_LINE. " Puffer für TCtrl
        ASSIGN TC_ME_8021 TO <F_TC>.   "wk/4.0
      WHEN DP_8022.         "jw / 20.11.98
        REFRESH CONTROL 'TC_ME_8022' FROM SCREEN SY-DYNNR.
        TC_ME_8022-LINES    = ME_LINES.
        TC_ME_8022-TOP_LINE = ME_ERSTE_ZEILE + 1.
        TC_ME_TOPL_BUF      = TC_ME_8022-TOP_LINE. " Puffer für TCtrl
        ASSIGN TC_ME_8022 TO <F_TC>.
*==============TF 4.7===================================================
      WHEN DP_8024.
        REFRESH CONTROL 'TC_ME_8024' FROM SCREEN SY-DYNNR.
        TC_ME_8024-LINES    = ME_LINES.
        TC_ME_8024-TOP_LINE = ME_ERSTE_ZEILE + 1.
        TC_ME_TOPL_BUF      = TC_ME_8024-TOP_LINE. " Puffer für TCtrl
        ASSIGN TC_ME_8024 TO <F_TC>.   "wk/4.0
*==============TF 4.7===================================================
    ENDCASE.
  ENDIF.
* AHE: 16.07.96 - E

*--BestellME, AusgabeME und VerkaufsME in MEINH markieren.
  IF ME_LINES NE 0.
*   BasisME setzen, damit bei Fehlen des Moduls SMEINH-KZME nicht
*   initial; sonst Fehler in PRUEFEN_KZME.
    IF NOT MARA-MEINS IS INITIAL.
      ME_BME = MARA-MEINS.
    ENDIF.

    CHECK ME_FEHLERFLG NE FDMEINH      "cfo/5.9.96 sonst Radiobutton
          AND ME_FEHLERFLG NE KZMEINH  "doppelt belegt
          AND ME_FEHLERFLG NE OTMEINH.
*   BestellME
    IF MARA-BSTME IS INITIAL AND NOT MARA-MEINS IS INITIAL.
      ME_BSTME = MARA-MEINS.
    ELSEIF NOT MARA-BSTME IS INITIAL.
      ME_BSTME = MARA-BSTME.
    ENDIF.
    IF NOT ME_BSTME IS INITIAL.
* cfo/24.9.96 damit keine Doppelten Markierungen auftreten.
      LOOP AT MEINH WHERE NOT KZBSTME IS INITIAL.           "
        EXIT.                                               "
      ENDLOOP.                                              "
      IF SY-SUBRC NE 0.                                     "
        READ TABLE MEINH WITH KEY ME_BSTME.
        IF SY-SUBRC = 0.
          MEINH-KZBSTME = X.
          MODIFY MEINH INDEX SY-TABIX.
        ENDIF.
      ENDIF.                                                "
    ENDIF.
*   AusgabeME
    IF MAW1-WAUSM IS INITIAL AND NOT MARA-MEINS IS INITIAL.
      ME_AUSME = MARA-MEINS.
    ELSEIF NOT MAW1-WAUSM IS INITIAL.
      ME_AUSME = MAW1-WAUSM.
    ENDIF.
    IF NOT ME_AUSME IS INITIAL.
* cfo/24.9.96 damit keine Doppelten Markierungen auftreten.
      LOOP AT MEINH WHERE NOT KZAUSME IS INITIAL.           "
        EXIT.                                               "
      ENDLOOP.                                              "
      IF SY-SUBRC NE 0.                                     "
        READ TABLE MEINH WITH KEY ME_AUSME.
        IF SY-SUBRC = 0.
          MEINH-KZAUSME = X.
          MODIFY MEINH INDEX SY-TABIX.
        ENDIF.
      ENDIF.                                                "
    ENDIF.
*   VerkaufsME
    IF MAW1-WVRKM IS INITIAL AND NOT MARA-MEINS IS INITIAL.
      ME_VRKME = MARA-MEINS.
    ELSEIF NOT MAW1-WVRKM IS INITIAL.
*     ME_AUSME = MAW1-WVRKM.        cfo/7.8.96 war falsch
      ME_VRKME = MAW1-WVRKM.
    ENDIF.
    IF NOT ME_VRKME IS INITIAL.
* cfo/24.9.96 damit keine Doppelten Markierungen auftreten.
      LOOP AT MEINH WHERE NOT KZVRKME IS INITIAL.           "
        EXIT.                                               "
      ENDLOOP.                                              "
      IF SY-SUBRC NE 0.                                     "
        READ TABLE MEINH WITH KEY ME_VRKME.
        IF SY-SUBRC = 0.
          MEINH-KZVRKME = X.
          MODIFY MEINH INDEX SY-TABIX.
        ENDIF.
      ENDIF.                                                "
    ENDIF.
  ENDIF.

ENDMODULE.                             " ME_INITIALISIERUNG  OUTPUT
