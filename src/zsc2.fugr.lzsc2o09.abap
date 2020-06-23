*----------------------------------------------------------------------*
***INCLUDE LMGD2O09 .
*----------------------------------------------------------------------*

*****************************
* AHE: 09.04.99  - A (4.6a) *
* komplett neues Include    *
* AHE: 09.04.99  - E        *
*****************************

*&---------------------------------------------------------------------*
*&      Module  EAN_INITIALISIERUNG_SA_VA  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Initflag, Ermitteln Anzahl Zeilen, Mengeneinheiten
*       aus Mengeneinh.-Bild auch ohne EANs vorblenden.
*       Dies ist der Normalfall. Für den Fall SA-VA-EANs pflegen
*       läuft die Form EAN_INIT_SA.
*----------------------------------------------------------------------*
MODULE EAN_INITIALISIERUNG_SA_VA OUTPUT.

  IF RMMZU-EINIT IS INITIAL.
    RMMZU-EINIT = X.
    CLEAR: EAN_ERSTE_ZEILE.
  ENDIF.

  CLEAR: EAN_ZEILEN_NR.

* Bestimmen: Normalfall oder Fall: Pflege der VA-EANs aus dem SA.
* Wenn RMMW2_SATN gefüllt, haben wir den Fall SA / VA. Wenn dann die
* Variante RMMW2_VARN nicht gefüllt ist, befinden wir uns in der
* Pflege des Sammelartikels.
  CALL FUNCTION 'GET_ZUS_RETAIL'
       IMPORTING
            RMMW1_MATNR = RMMW1_MATN
            RMMW2_VARNR = RMMW2_VARN
            RMMW2_SATNR = RMMW2_SATN.

  IF NOT RMMG2-FLG_RETAIL IS INITIAL  AND   "nur sicherheitshalber
         RMMW1-ATTYP = ATTYP_SAMM     AND
     NOT RMMW2_SATN IS INITIAL        AND
         RMMW2_VARN IS INITIAL.
* Fall: Pflege im Sammelartikel --> nur dort gibts dann die Pflege
* für die Varianten-EANs.
    SA_VA_EAN = X.
  ELSE.
    CLEAR SA_VA_EAN.
  ENDIF.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_INIT_SA_VA.

  ELSE.
* Normalfall
    IF T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
      LOOP AT MEINH.
        READ TABLE MEAN_ME_TAB WITH KEY MEINH-MEINH.
        IF SY-SUBRC NE 0.
*       noch kein Eintrag zur Mengeneinheit im Bild Zus. EAN vorhanden
*       Mengeneinheit aus MEINH mit leeren Einträgen übernehmen
*       als Voreinstellung
*       Solche Einträge werden am Ende des Bildes wieder gelöscht
*       (Modul CLEAN_MEINH);
          CLEAR MEAN_ME_TAB.
          MEAN_ME_TAB-MEINH = MEINH-MEINH.
          APPEND MEAN_ME_TAB.
        ENDIF.
      ENDLOOP.
    ENDIF.


* Retail-Fall: EAN-Lieferantenbezug-Handling
    IF NOT RMMG2-FLG_RETAIL IS INITIAL.
* Lieferant (aus RMMW2) lesen für Zuordnung EAN - Lieferant
* RMMW2-LIFNR wird aus RMMW1-LIFNR im Keyumsetzer versorgt. RMMW1-LIFNR
* ist der aktuelle Lieferant, der auch im Kopf-Subscreen angezeigt wird.
* Außerdem wird die MATNR aus dem Kopf-Subscreen besorgt.
      CALL FUNCTION 'GET_ZUS_RETAIL'
           IMPORTING
                RMMW2_LIFNR = RMMW2_LIEF
                RMMW1_MATNR = RMMW1_MATN

* bei der Pflege einer Variante muß RMMW2_VARN genommen werden, da in
* RMMW1_MATN der Sammelartikel steht.
                RMMW2_VARNR = RMMW2_VARN.

      IF NOT RMMW2_VARN IS INITIAL.
        RMMW1_MATN = RMMW2_VARN.       " wegen Verwendung RMMW1_MATN
      ENDIF.

    ENDIF.


* Sortierung notwendig für Feldauswahl
    SORT MEAN_ME_TAB BY MEINH EAN11.

* Initialisieren der Kennzeichen zur Aktualisierung von int. Tabellen
    CLEAR: MEAN_ME_TAB_CHECK,
           HILFS_MEEIN.                " für Feldauswahl

*--Ermitteln der aktuellen Anzahl Einträge ME - EANs
    DESCRIBE TABLE MEAN_ME_TAB LINES EAN_LINES.

  ENDIF.                               " Normalfall


* Umstellung auf Table-Control
  IF NOT FLG_TC IS INITIAL.
    REFRESH CONTROL 'TC_EAN' FROM SCREEN SY-DYNNR.
    TC_EAN-LINES    = EAN_LINES.
    TC_EAN-TOP_LINE = EAN_ERSTE_ZEILE + 1.
    TC_EAN_TOPL_BUF = TC_EAN-TOP_LINE. " Puffer für TCtrl
    ASSIGN TC_EAN TO <F_TC>.           "wk/4.0
  ENDIF.

ENDMODULE.                 " EAN_INITIALISIERUNG_SA_VA  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  ANZEIGEN_EAN_ZUS_SA_VA  OUTPUT
*&---------------------------------------------------------------------*
*    Ermitteln Anzahl Einträge.
*    Fuellen der Loop-Zeile mit den Daten aus der internen Tabelle
*----------------------------------------------------------------------*
MODULE ANZEIGEN_EAN_ZUS_SA_VA OUTPUT.

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_ANZ_SA_VA.
  ELSE.
* Normalfall
    IF SY-STEPL = 1.
      EAN_ZLEPROSEITE = SY-LOOPC.

* Auf die fehlerhafte Zeile positionieren, wenn eine nicht erlaubte
* Mengeneinheit eingegeben wurde. Diese kann wegen SORT v. MEAN_ME_TAB
* auf einer anderen Seite stehen.

      IF NOT EAN_FEHLERFLG_ME IS INITIAL.
        READ TABLE MEAN_ME_TAB WITH KEY MEINH = MEAN_TAB_KEY-MEINH.
        IF SY-SUBRC = 0.
          EAN_ERSTE_ZEILE = SY-TABIX - 1.
        ENDIF.
      ENDIF.

    ENDIF.

    EAN_AKT_ZEILE = EAN_ERSTE_ZEILE + SY-STEPL.

*-------Anzeigen interne Tabelle---------------------------------

    READ TABLE MEAN_ME_TAB  INDEX EAN_AKT_ZEILE.

    IF SY-SUBRC = 0.
* note 331039 auch MATNR verfüllen,
* da sonst Suchhilfe für Mengeneinheit ohne Funktion
      MEAN-MATNR   = RMMW1_MATN.
      MEAN-EAN11   = MEAN_ME_TAB-EAN11.
      MEAN-EANTP   = MEAN_ME_TAB-NUMTP.
      MEAN-HPEAN   = MEAN_ME_TAB-HPEAN.
      SMEINH-MEINH = MEAN_ME_TAB-MEINH.
      MEAN-SGT_CATV   = MEAN_ME_TAB-SGT_CATV.
*     Lesen der Bezeichnungen für die Mengeneinheiten nach T006A-MSEHT
*     Hier wird nicht mit der Ausblendtechnik (FELDBEZTAB) gearbeitet,
*     da nicht notwendig.
      CALL FUNCTION 'ZUS_EAN_READ_DESCRIPTION'
           EXPORTING
                P_MEAN_MEINH = MEAN_ME_TAB-MEINH
           IMPORTING
                WT006A       = T006A   " T006A-MSEHT belegt
           EXCEPTIONS
                OTHERS       = 1.

      IF NOT RMMG2-FLG_RETAIL IS INITIAL.
* Retail-Fall: EAN-Lieferantenbezug-Handling

* Lieferantenzuordnung für aktuellen Lieferanten anzeigen
        READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                                  MEINH = MEAN_ME_TAB-MEINH
                                  LIFNR = RMMW2_LIEF
                                  EAN11 = MEAN_ME_TAB-EAN11
                                  BINARY SEARCH.
        IF SY-SUBRC = 0.
*     Es existiert eine Lieferantenzuordnung für diese EAN und
*     den aktuellen Lieferanten (falls Lief noch nicht spezifiziert:
*     Abfrage auch O.K.);
          RMMZU-LIEFZU  = X.
        MLEA-LFEAN = TMLEA-LFEAN.  " falls in MLEA Haupt-Lief gesetzt...
* neues Feld MLEA-LARTN
          IF NOT MLEA-LFEAN IS INITIAL.
*         Lieferantenartikelnummer nur bei Haupt-EANs
            MLEA-LARTN = TMLEA-LARTN.
          ENDIF.
        ELSE.
          CLEAR MLEA-LFEAN.            " KZ-Haupt-Lief löschen
          CLEAR MLEA-LARTN.
        ENDIF.


* Lieferantenzuordnung für andere als den aktuellen Lieferanten anzeigen
        READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                                MEINH = MEAN_ME_TAB-MEINH BINARY SEARCH.
        IF SY-SUBRC = 0.
          HTABIX = SY-TABIX.
          LOOP AT TMLEA FROM HTABIX.
            IF TMLEA-MATNR NE RMMW1_MATN        OR
               TMLEA-MEINH NE MEAN_ME_TAB-MEINH.
              EXIT.
            ENDIF.
            IF TMLEA-LIFNR NE RMMW2_LIEF       AND
               TMLEA-EAN11 = MEAN_ME_TAB-EAN11.
*              Es existiert eine Lieferantenzuordnung für diese EAN und
*              einen anderen Lieferanten.
              RMMZU-LIEFBEZ = X.       " nur Anzeigefeld !
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.

* Fehler bei Haupt-EAN-Lief KZ (nicht eindeutig oder keins angegeben).
        IF NOT EAN_FEHLERFLG_LFEAN IS INITIAL       AND
           MLEA_LFEAN_KEY-MEINH = MEAN_ME_TAB-MEINH.        "AND
*          MLEA_LFEAN_KEY-EAN11 = MEAN_ME_TAB-EAN11.
          PERFORM EAN_SET_ZEILE_LFEAN.
        ENDIF.

      ENDIF.

* Cursor positionieren und hervorheben der Zeile, falls im vorherigen
* PAI ein Fehler (S-Meldung) ausgegeben wurde.
* Der Fehler bezieht sich dann auf das KZ HPEAN !
      IF NOT EAN_FEHLERFLG IS INITIAL           AND
         MEAN_TAB_KEY-MEINH = MEAN_ME_TAB-MEINH. " AND
*        MEAN_TAB_KEY-EAN11 = MEAN_ME_TAB-EAN11.
        PERFORM EAN_SET_ZEILE.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.                             " ANZEIGEN_EAN_ZUS_SA_VA  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  FELDAUSWAHL_EAN_ZUS_SA_VA  OUTPUT
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
MODULE FELDAUSWAHL_EAN_ZUS_SA_VA OUTPUT.

  EAN_AKT_ZEILE = EAN_ERSTE_ZEILE + SY-STEPL.

* EAN sind für MPN-Materialien nicht pflegbar
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

  IF NOT SA_VA_EAN IS INITIAL.
* VA-EANs pflegen im Sammelartikel
    PERFORM EAN_FAUSW_SA_VA.

  ELSE.
* Normalfall

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
*         note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
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

          SCREEN-INPUT       = 0.
          SCREEN-REQUIRED    = 0.
*     Jede erste neue MEINH intensified schalten und alle Bezeichnungen
*     für die nächsten Einträge dieser Mengeneinheit ausblenden.
          IF NOT FLAG_INTENSIFY IS INITIAL AND
             ( SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001' ).
            SCREEN-INTENSIFIED = 1.
          ELSEIF ( SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002' ) AND
                FLAG_INTENSIFY IS INITIAL.
            SCREEN-ACTIVE = 0.
          ENDIF.
*       Prf. Berechtigung für zentrale Daten
          IF RMMG2-MANBR = MANBR1.     "nur   Anzeigeberechtigung.
          ENDIF.
          IF RMMG2-MANBR = MANBR2.     "keine Anzeigeberechtigung.
            SCREEN-INVISIBLE = 1.
            SCREEN-ACTIVE    = 0.
            SCREEN-OUTPUT    = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

      ELSE.                            " Anlegen / Ändern

        LOOP AT SCREEN.
          IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001'.
            IF NOT MEAN_ME_TAB-MEINH IS INITIAL.
              SCREEN-INPUT       = 0.
              SCREEN-REQUIRED    = 0.
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

* Retail-Fall: EAN-Lieferantenbezug-Handling
          IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
                 RMMW2_LIEF IS INITIAL.
*         Wenn kein Lieferant angegeben ist, wird  RMMZU-LIEFZU und
*         MLEA-LFEAN generell auf Anzeige gestellt.
*         if screen-group1 = '003'.    " RMMZU-LIEFZU, MLEA-LFEAN mk4.0A
*         IF SCREEN-GROUP1 = '003' OR SCREEN-GROUP2 = '003'.
            IF SCREEN-GROUP1 = '003' OR SCREEN-GROUP2 = '003' OR
               SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004'.
              SCREEN-INPUT       = 0.
              SCREEN-REQUIRED    = 0.
            ENDIF.
          ENDIF.

* <== Feldauswahl vorher gilt auch für Feld MLEA-LARTN !!

* Hier werden nur die Felder für MLEA-LARTN freigeschaltet, für die
* die Lieferanten-EAN als Haupt-EAN gekennzeichnet ist.
          IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
             NOT RMMW2_LIEF IS INITIAL.
            IF NOT MLEA-LFEAN IS INITIAL.
              IF SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004'.
*               IF RMMW1-ATTYP <> ATTYP_VAR.  " geht nicht ???
                IF RMMW2_VARN IS INITIAL.
*               d.h.: nicht im Fall der Variantenpflege und hier sowieso
*                     nicht im Fall Sammelartikelpflege -->
*               Lieferantenartikelnummer nur bei Varianten pflegbar
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

          IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
             SCREEN-GROUP1 = '005' OR SCREEN-GROUP2 = '005'.
*         MATNR (SA / VA) immer auf Ausgabe
            SCREEN-INPUT       = 0.
            SCREEN-REQUIRED    = 0.
          ENDIF.

*         note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
*         note 1402388: do this only for MEAN fields to don't overwrite
*         for instance special MLEA settings
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
*             don't set MEAN-HPEAN or RMMZU-AUTO_PRFZ as required field
              IF SCREEN-GROUP1(1) NE 'T' AND SCREEN-GROUP1 NE 'F02'.
                SCREEN-REQUIRED    = FAUSWTAB-KZREQ.
              ENDIF.
            ENDIF.
          ENDIF.                                           "note 1402388

          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.

    ELSE.

*   Leere Zeilen: Beim "Anzeigen" werden diese Zeilen komplett auf "nur
*   Ausgabe" geschaltet.

      IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ  " Anzeigen
         OR RMMG2-MANBR NE SPACE.      "Prf. zentr. Berechtigung
        LOOP AT SCREEN.
*         note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
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
*         Prf. Berechtigung für zentrale Daten
          IF RMMG2-MANBR = MANBR1.     "nur   Anzeigeberechtigung.
          ENDIF.
          IF RMMG2-MANBR = MANBR2.     "keine Anzeigeberechtigung.
            SCREEN-INVISIBLE = 1.
            SCREEN-ACTIVE    = 0.
            SCREEN-OUTPUT    = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

      ELSE.

        LOOP AT SCREEN.
*         note 1296499: use SMEINH-EAN11/NUMTP for MEAN fields
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

*         note 1085078: close LARTN for empty lines
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

  ENDIF.                               "Normalfall

ENDMODULE.                 " FELDAUSWAHL_EAN_ZUS_SA_VA  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  TC_SET_FIRST_COL  OUTPUT
*&---------------------------------------------------------------------*
*       Ausblenden der ersten Spalte, wenn kein Sammelartikelfall
*----------------------------------------------------------------------*
MODULE TC_SET_FIRST_COL OUTPUT.

  IF SA_VA_EAN IS INITIAL.
* Normalfall --> Spezial-FELDAUSWAHL
* 1. Spalte mit SA / VA Nummern ausblenden, wenn nicht im Sammelartikel!
    LOOP AT TC_EAN-COLS INTO TC_COL.
      IF TC_COL-INDEX = 1.
        TC_COL-INVISIBLE = 'X'.
      ENDIF.

      IF TC_COL-screen-name = 'MAKT_TMP-MAKTX'.
        TC_COL-INVISIBLE = 'X'.
      ENDIF.

ENHANCEMENT-POINT EHP_TC_SET_FIRST_COL_01 SPOTS ES_LMGD2O09 INCLUDE BOUND .

      MODIFY TC_EAN-COLS FROM TC_COL.
    ENDLOOP.
  ENDIF.

ENDMODULE.                             " TC_SET_FIRST_COL  OUTPUT
