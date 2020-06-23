*----------------------------------------------------------------------*
*   INCLUDE LMGD2F05                                                   *
* Spezielle Routinen, die für die Varianten-EAN-Pflege aus dem
* Sammelartikel heraus benötigt werden.
*----------------------------------------------------------------------*

********************************
* AHE: 08.04.99 - A (4.6a)     *
* Komplett neues Include   !!  *
* AHE: 08.04.99 - E            *
********************************

*&---------------------------------------------------------------------*
*&      Form  EAN_INIT_SA_VA
*&---------------------------------------------------------------------*
*       Spezielle Initialisierung für den SA / VA-Fall
*----------------------------------------------------------------------*
FORM EAN_INIT_SA_VA.

* { ERP2005 EHP2
  data: lt_pre09 type table of pre09,
        ls_pre09 type          pre09.
  field-symbols: <ls_mean_me> type MEANI_F.
* } ERP2005 EHP2

  IF T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

    READ TABLE MEINH_SA WITH KEY MATNR = RMMW2_SATN BINARY SEARCH.
    HTABIX = SY-TABIX.
    IF SY-SUBRC = 0.
      LOOP AT MEINH_SA FROM HTABIX.
        IF MEINH_SA-MATNR <> RMMW2_SATN.
          EXIT.
        ENDIF.
        READ TABLE MEAN_ME_TAB_SA WITH KEY MATNR = RMMW2_SATN
                                           MEINH = MEINH_SA-MEINH
                                           BINARY SEARCH.
        HTABIX = SY-TABIX.
        IF SY-SUBRC NE 0.
*       noch kein Eintrag zur Mengeneinheit im Bild Zus. EAN vorhanden
*       Mengeneinheit aus MEINH_SA mit leeren Einträgen übernehmen
*       als Voreinstellung, allerdings nur für den Sammelartikel
*       Solche Einträge werden am Ende des Bildes wieder gelöscht
*       (Modul CLEAN_MEINH);
          CLEAR MEAN_ME_TAB_SA.
          MEAN_ME_TAB_SA-MATNR = RMMW2_SATN.
          MEAN_ME_TAB_SA-MEINH = MEINH_SA-MEINH.
          INSERT MEAN_ME_TAB_SA INDEX HTABIX.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.


* Lieferant (aus RMMW2) lesen für Zuordnung EAN - Lieferant
* RMMW2-LIFNR wird aus RMMW1-LIFNR im Keyumsetzer versorgt. RMMW1-LIFNR
* ist der aktuelle Lieferant, der auch im Kopf-Subscreen angezeigt wird.
* Außerdem wird die MATNR aus dem Kopf-Subscreen besorgt.
  CALL FUNCTION 'GET_ZUS_RETAIL'
       IMPORTING
            RMMW2_LIFNR = RMMW2_LIEF
            RMMW1_MATNR = RMMW1_MATN.

* hier immer im Sammelartikelfall und hier nur Lieferant des SA erlaubt
* zur Pflege der MLEA

* Sortierung notwendig für Feldauswahl
  SORT MEAN_ME_TAB_SA BY MATNR MEINH EAN11.

* Initialisieren der Kennzeichen zur Aktualisierung von int. Tabellen
  CLEAR: MEAN_ME_TAB_CHECK,
         HILFS_MEEIN,                  " für Feldauswahl
         HILFS_MATNR.

*--Ermitteln der aktuellen Anzahl Einträge ME - EANs
  DESCRIBE TABLE MEAN_ME_TAB_SA LINES EAN_LINES.

    ls_pre09-spras = sy-langu.
  loop at MEAN_ME_TAB_SA assigning <ls_mean_me>.
    ls_pre09-matnr = <ls_mean_me>-matnr.
    append ls_pre09 to lt_pre09.
  endloop.

  CALL FUNCTION 'MAKT_ARRAY_READ'
*   EXPORTING
*     KZRFB                      = ' '
*     NEUFLAG                    = ' '
    TABLES
      IPRE09                     = lt_pre09
      MAKT_TAB                   = gt_sa_va_makt
    EXCEPTIONS
      ENQUEUE_MODE_CHANGED       = 1
      OTHERS                     = 2.

    if sy-subrc = 0.
      sort gt_sa_va_makt by matnr.
    else.
      refresh gt_sa_va_makt.
    endif.

ENHANCEMENT-POINT EHP_EAN_INIT_SA_VA_01 SPOTS ES_LMGD2F05 INCLUDE BOUND .

ENDFORM.                               " EAN_INIT_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_ANZ_SA_VA
*&---------------------------------------------------------------------*
*       Anzeigen der EANs für den SA- / VA-Fall
*----------------------------------------------------------------------*
FORM EAN_ANZ_SA_VA.

* { ERP2005 EHP2
  field-symbols: <ls_sa_va_makt> type makt.
* } ERP2005 EHP2

  IF SY-STEPL = 1.
    EAN_ZLEPROSEITE = SY-LOOPC.

* Auf die fehlerhafte Zeile positionieren, wenn eine nicht erlaubte
* Mengeneinheit eingegeben wurde. Diese kann wegen SORT v. MEAN_ME_TAB
* auf einer anderen Seite stehen.

    IF NOT EAN_FEHLERFLG_ME IS INITIAL.
      READ TABLE MEAN_ME_TAB_SA WITH KEY MATNR = MEAN_TAB_KEY_SA-MATNR
                                         MEINH = MEAN_TAB_KEY_SA-MEINH.
      IF SY-SUBRC = 0.
        EAN_ERSTE_ZEILE = SY-TABIX - 1.
      ENDIF.
    ENDIF.

  ENDIF.

  EAN_AKT_ZEILE = EAN_ERSTE_ZEILE + SY-STEPL.

*-------Anzeigen interne Tabelle---------------------------------

  READ TABLE MEAN_ME_TAB_SA  INDEX EAN_AKT_ZEILE.

  IF SY-SUBRC = 0.
    MEAN-MATNR   = MEAN_ME_TAB_SA-MATNR.
    MEAN-EAN11   = MEAN_ME_TAB_SA-EAN11.
    MEAN-EANTP   = MEAN_ME_TAB_SA-NUMTP.
    MEAN-HPEAN   = MEAN_ME_TAB_SA-HPEAN.
    SMEINH-MEINH = MEAN_ME_TAB_SA-MEINH.
    MEAN-SGT_CATV   = MEAN_ME_TAB_SA-SGT_CATV.
*   Lesen der Bezeichnungen für die Mengeneinheiten nach T006A-MSEHT
*   Hier wird nicht mit der Ausblendtechnik (FELDBEZTAB) gearbeitet,
*   da nicht notwendig.
    CALL FUNCTION 'ZUS_EAN_READ_DESCRIPTION'
         EXPORTING
              P_MEAN_MEINH = MEAN_ME_TAB_SA-MEINH
         IMPORTING
              WT006A       = T006A     " T006A-MSEHT belegt
         EXCEPTIONS
              OTHERS       = 1.


* EAN-Lieferantenbezug-Handling
* Lieferantenzuordnung für aktuellen Lieferanten anzeigen
* Als Lieferant ist nur der aktuell im Sammelartikel angegebene
* Lieferant erlaubt.
    READ TABLE TMLEA_SA WITH KEY
                             MATNR = MEAN_ME_TAB_SA-MATNR
                             MEINH = MEAN_ME_TAB_SA-MEINH
                             LIFNR = RMMW2_LIEF
                             EAN11 = MEAN_ME_TAB_SA-EAN11 BINARY SEARCH.
    IF SY-SUBRC = 0.
*     Es existiert eine Lieferantenzuordnung für diese EAN und
*     den aktuellen Lieferanten (falls Lief noch nicht spezifiziert:
*     Abfrage auch O.K.);
      RMMZU-LIEFZU  = X.
      MLEA-LFEAN = TMLEA_SA-LFEAN.     " falls in MLEA Haupt-Lief
      IF NOT MLEA-LFEAN IS INITIAL.
*       Lieferantenartikelnummer nur bei Haupt-EANs
        MLEA-LARTN = TMLEA_SA-LARTN.
      ENDIF.
    ELSE.
      CLEAR MLEA-LFEAN.                " KZ-Haupt-Lief löschen
      CLEAR MLEA-LARTN.
    ENDIF.


* Lieferantenzuordnung für andere als den aktuellen Lieferanten anzeigen
    READ TABLE TMLEA_SA WITH KEY
                             MATNR = MEAN_ME_TAB_SA-MATNR
                             MEINH = MEAN_ME_TAB_SA-MEINH BINARY SEARCH.
    IF SY-SUBRC = 0.
      HTABIX = SY-TABIX.
      LOOP AT TMLEA_SA FROM HTABIX.
        IF TMLEA_SA-MATNR NE MEAN_ME_TAB_SA-MATNR OR
           TMLEA_SA-MEINH NE MEAN_ME_TAB_SA-MEINH.
          EXIT.
        ENDIF.
        IF TMLEA_SA-LIFNR NE RMMW2_LIEF       AND
           TMLEA_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
*           Es existiert eine Lieferantenzuordnung für diese EAN und
*           einen anderen Lieferanten.
          RMMZU-LIEFBEZ = X.           " nur Anzeigefeld !
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

* Fehler bei Haupt-EAN-Lief KZ (nicht eindeutig oder keins angegeben).
    IF NOT EAN_FEHLERFLG_LFEAN IS INITIAL               AND
       MLEA_LFEAN_KEY_SA-MATNR = MEAN_ME_TAB_SA-MATNR   AND
       MLEA_LFEAN_KEY_SA-MEINH = MEAN_ME_TAB_SA-MEINH.      "AND
*      MLEA_LFEAN_KEY_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
      PERFORM EAN_SET_ZEILE_LFEAN_SA.
    ENDIF.

    read table gt_sa_va_makt assigning <ls_sa_va_makt>
         with key matnr = MEAN_ME_TAB_SA-matnr binary search.
    if sy-subrc = 0.
      makt_tmp-maktx = <ls_sa_va_makt>-maktx.
    endif.

ENHANCEMENT-POINT EHP_EAN_ANZ_SA_VA_01 SPOTS ES_LMGD2F05 INCLUDE BOUND .

  ENDIF.

* Cursor positionieren und hervorheben der Zeile, falls im vorherigen
* PAI ein Fehler (S-Meldung) ausgegeben wurde.
* Der Fehler bezieht sich dann auf das KZ HPEAN !
  IF NOT EAN_FEHLERFLG IS INITIAL           AND
     MEAN_TAB_KEY_SA-MATNR = MEAN_ME_TAB_SA-MATNR AND
     MEAN_TAB_KEY_SA-MEINH = MEAN_ME_TAB_SA-MEINH. " AND
*    MEAN_TAB_KEY-EAN11 = MEAN_ME_TAB-EAN11.
    PERFORM EAN_SET_ZEILE_SA.
  ENDIF.


ENDFORM.                               " EAN_ANZ_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_SET_ZEILE_LFEAN_SA
*&---------------------------------------------------------------------*
*       Prinzip: Alle Zeilen zur beteiligten Mengeneinheit intensified
*       schalten. Cursorposition aber von der Zeile merken, die in
*       MLEA_LFEAN_KEY_SA voll spezifiziert ist (incl. EAN).
*----------------------------------------------------------------------*
FORM EAN_SET_ZEILE_LFEAN_SA.

  LOOP AT SCREEN.
    SCREEN-INTENSIFIED = 1.
    MODIFY SCREEN.
  ENDLOOP.

* Cursor auf die gemerkte Zeile (MATNR, MEINH und EAN) positionieren
  CHECK EAN_ZEILEN_NR IS INITIAL.
* Zur Cursorpositionierung
  IF MLEA_LFEAN_KEY_SA-MATNR = MEAN_ME_TAB_SA-MATNR AND
     MLEA_LFEAN_KEY_SA-MEINH = MEAN_ME_TAB_SA-MEINH AND
     MLEA_LFEAN_KEY_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
    MOVE SY-STEPL TO EAN_ZEILEN_NR.
  ENDIF.

ENDFORM.                               " EAN_SET_ZEILE_LFEAN_SA


*&---------------------------------------------------------------------*
*&      Form  EAN_SET_ZEILE_SA
*&---------------------------------------------------------------------*
*       Zeile wird intensified geschaltet und Cursorposition gemerkt
*----------------------------------------------------------------------*
FORM EAN_SET_ZEILE_SA.

  LOOP AT SCREEN.
    SCREEN-INTENSIFIED = 1.
    MODIFY SCREEN.
  ENDLOOP.

* damit der Cursor auf die erste Zeile der falschen Meinh. auf dem
* Bild positioniert wird.
  CHECK EAN_ZEILEN_NR IS INITIAL.
* Zur Cursorpositionierung
  MOVE SY-STEPL TO EAN_ZEILEN_NR.

ENDFORM.                               " EAN_SET_ZEILE_SA


*&---------------------------------------------------------------------*
*&      Form  EAN_FAUSW_SA_VA
*&---------------------------------------------------------------------*
*       Feldauswahl für SA- / VA-Fall
*----------------------------------------------------------------------*
FORM EAN_FAUSW_SA_VA.

  READ TABLE MEAN_ME_TAB_SA INDEX EAN_AKT_ZEILE.
  IF SY-SUBRC = 0.
* Belegte Zeilen: Es wird jeder erste Eintrag einer Mengeneinheit
* intensified geschaltet. Für den ersten Eintrag einer MATNR gilt dies
* immer. Beim Anzeigen wird die gesamte Zeile auf "nur usgabe"
* geschaltet.

    IF MEAN_ME_TAB_SA-MATNR = HILFS_MATNR.
      IF MEAN_ME_TAB_SA-MEINH = HILFS_MEEIN.
*     MEINH hat sich nicht geändert
        CLEAR FLAG_INTENSIFY.
      ELSE.
*     neue MEINH
        FLAG_INTENSIFY = X.
        HILFS_MEEIN = MEAN_ME_TAB_SA-MEINH.
      ENDIF.
    ELSE.
*   neue MATNR
      HILFS_MATNR = MEAN_ME_TAB_SA-MATNR.
      HILFS_MEEIN = MEAN_ME_TAB_SA-MEINH.
*     CLEAR HILFS_MEEIN.
      FLAG_INTENSIFY = X.
    ENDIF.

    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ   " Anzeigen
       OR RMMG2-MANBR NE SPACE.        "Prf. zentr. Berechtigung
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
           ( SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001' ).
          SCREEN-INTENSIFIED = 1.
        ELSEIF ( SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002' ) AND
              FLAG_INTENSIFY IS INITIAL.
          SCREEN-ACTIVE = 0.
        ENDIF.
*       Prf. Berechtigung für zentrale Daten
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
        IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001'.
          IF NOT MEAN_ME_TAB_SA-MEINH IS INITIAL.
            SCREEN-INPUT       = 0.
            SCREEN-REQUIRED    = 0.
*           Cursor positionieren und hervorheben der Zeile,
*           falls im vorherigen PAI ein Fehler (S-Meldung)
*           ausgegeben wurde. Außerdem freischalten
*           der Mengeneinheit zur Korrektur.
            IF NOT EAN_FEHLERFLG_ME IS INITIAL        AND
               MEAN_TAB_KEY_SA-MATNR = MEAN_ME_TAB_SA-MATNR AND
               MEAN_TAB_KEY_SA-MEINH = MEAN_ME_TAB_SA-MEINH. " AND
*              MEAN_TAB_KEY_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
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
        ELSEIF ( SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002' ) AND
               FLAG_INTENSIFY IS INITIAL.
*       Bei jedem weiteren Eintrag zu einer Mengeneinheit wird die
*       Bezeichnung ausgeblendet.
          SCREEN-ACTIVE = 0.
        ENDIF.

* EAN-Lieferantenbezug-Handling
        IF RMMW2_LIEF IS INITIAL.
*         Wenn kein Lieferant angegeben ist, wird  RMMZU-LIEFZU,
*         MLEA-LFEAN und MLEA-LARTN generell auf Anzeige gestellt.
          IF SCREEN-GROUP1 = '003' OR SCREEN-GROUP2 = '003' OR
             SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004'.
            SCREEN-INPUT       = 0.
            SCREEN-REQUIRED    = 0.
          ENDIF.
        ENDIF.

* Hier werden nur die Felder für MLEA-LARTN freigeschaltet, für die
* die Lieferanten-EAN als Haupt-EAN gekennzeichnet ist.
        IF NOT RMMW2_LIEF IS INITIAL.
          IF NOT MLEA-LFEAN IS INITIAL.
            IF SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004'.
              IF MEAN_ME_TAB_SA-MATNR = RMMW2_SATN.
* für Sammelartikel generell keine Lieferantenartikelnummer pflegbar
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

        IF SCREEN-GROUP1 = '005' OR SCREEN-GROUP2 = '005'.
*         MATNR (SA / VA) immer auf Ausgabe stellen, dies geht nicht
*         über Feldattribute, da ja in den "leeren" Zeilen noch eingaben
*         möglich sein müssen.
          SCREEN-INPUT       = 0.
          SCREEN-REQUIRED    = 0.
        ENDIF.

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
*         Prf. Berechtigung für zentrale Daten
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
           RMMW2_LIEF IS INITIAL AND
           ( SCREEN-GROUP1 = '004' OR SCREEN-GROUP2 = '004' ).
          SCREEN-INPUT       = 0.
          SCREEN-REQUIRED    = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.                               " EAN_FAUSW_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_CHECK_SA_VA
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM EAN_CHECK_SA_VA.

  CLEAR MEAN_ME_TAB_SA.    "wegen evtl. neuer noch nicht übernomm. Zeile
  READ TABLE MEAN_ME_TAB_SA INDEX EAN_AKT_ZEILE.
* hier kein CHECK SY-SUBRC wg. evtl. neuem Satz möglich (dann könnte
* man zuerst die Konsistenzchecks machen, bevor z. Bsp. eine EAN int.
* vergeben wird).

* Es wird nur für die EANs geprüft, bei deren Eintrag sich etwas
* verändert hat.
  IF MEAN-EAN11 = MEAN_ME_TAB_SA-EAN11 AND
     MEAN-EANTP = MEAN_ME_TAB_SA-NUMTP AND
     MEAN_ME_TAB_SA-EAN_GEPRF = X.
*  Zeile unverändert
    IF MEAN-EAN11       IS INITIAL AND
       NOT MEAN-EANTP   IS INITIAL AND
       EAN_FEHLERFLG_ME IS INITIAL.
*  EAN muss noch intern ermittelt werden --> FB-Aufruf aber nur, wenn
*  die Mengeneinheit korrekt eingegeben wurde (EAN_FEHLERFLAG_ME ist
*  initial).
*  MESSAGE W069(WE).                " EAN wird intern ermittelt
*  --> Meldung aus EAN_SYSTEMATIC in MARA_EAN11
      CLEAR MEAN_ME_TAB_SA-EAN_GEPRF.
    ENDIF.

  ELSE.
*   Zeile geändert oder neu --> ggf. Meldungen ausgeben + Prüfen
    CLEAR MEAN_ME_TAB_SA-EAN_GEPRF.
*   Zeile geändert: -> nicht in den Zweig für den Fehlerfall
*   "M3 348" springen (in MARA_EAN11).
*   Dies gilt nur ! für dieses Modul nicht für die anderen Module,
*   die MARA_EAN11 aufrufen ! ! !
    CLEAR EAN_FEHLERFLG.

    IF MEAN-EAN11 IS INITIAL.
      IF MEAN-EANTP IS INITIAL.
        IF NOT MEAN_ME_TAB_SA-EAN11 IS INITIAL.

*         EAN-Lieferantenbezug-Handling
*         ->  Abfragen (POP-UP) und Löschen von ggf. vorhandenen
*             EAN-Lieferantenbezügen
          PERFORM DEL_EAN_LIEF_SA USING FLAG_EXIT.
          CASE FLAG_EXIT.
            WHEN 'N'.
*             "NEIN" -> nur diese Zeile nicht löschen
              EXIT.
            WHEN 'A'.
*             "ABBRUCH" -> Löschen abbrechen
              EXIT FROM STEP-LOOP.
          ENDCASE.
*           Beim Löschen der Zeile muß in jedem Falle RMMZU-LIEFZU und
*           MLEA-LFEAN gelöscht werden. RMMZU-LIEFZU auch deswegen,
*           damit in TMLEA_SA keine MEAN-Sätze mit leerer (zum Löschen
*           vorgem.) EAN aufgenommen werden (in BELEGEN_MEAN_ME_TAB_SA).
          CLEAR: RMMZU-LIEFZU, MLEA-LFEAN.   " Dynprofelder
          CLEAR: MLEA-LARTN.           " Dynprofeld
          MESSAGE W067(WE).            " bisherige EAN gelöscht
* Muß außerhalb des FBs EAN_SYSTEMATIC (MARA_EAN11) ausgegeben werden.
* Der FB darf dann nicht mehr aufgerufen werden, da ansonsten
* das POP-UP "Bitte neue Haupt-EAN auswählen" aufgerufen wird.
* Bem.: Diese Funktionalität wird an anderer Stelle (z. Bsp. Mengenein-
* heitenbild ) benötigt.

          MEAN_ME_TAB_SA-EAN_GEPRF = X.
*         Prüfung für EAN und Typ nicht mehr ausführen
        ENDIF.
      ELSE.
*       ->  Abfragen (POP-UP) und Ändern von ggf. vorhandenen
*           EAN-Lieferantenbezügen
        PERFORM UPD_EAN_LIEF_SA USING FLAG_EXIT.
        CASE FLAG_EXIT.
          WHEN 'N'.
*           "NEIN" -> nur diese Zeile nicht Ändern
            EXIT.
          WHEN 'A'.
*           "ABBRUCH" -> Ändern abbrechen
            EXIT FROM STEP-LOOP.
        ENDCASE.
*       MESSAGE W069(WE).              " EAN wird intern ermittelt
*       Meldung aus EAN_SYSTEMATIC in MARA_EAN11
      ENDIF.
    ENDIF.

  ENDIF.

* EAN-Lieferantenbezug-Handling
* für: EAN geändert
  IF MEAN-EAN11 NE MEAN_ME_TAB_SA-EAN11 AND
     NOT MEAN-EAN11 IS INITIAL.
* -> Abfragen (POP-UP) und Ändern von ggf. vorhandenen
*    EAN-Lieferantenbezügen
    PERFORM UPD_EAN_LIEF_SA USING FLAG_EXIT.
    CASE FLAG_EXIT.
      WHEN 'N'.
*       "NEIN" -> nur diese Zeile nicht Ändern
        EXIT.
      WHEN 'A'.
*       "ABBRUCH" -> Ändern abbrechen
        EXIT FROM STEP-LOOP.
    ENDCASE.
  ENDIF.

  IF NOT EAN_FEHLERFLG IS INITIAL. " gesetzt, wenn vorher Error ausgeg.
    CLEAR MEAN_ME_TAB_SA-EAN_GEPRF.    " nochmal reingehen ! !
  ENDIF.

* EAN-Lieferantenbezug-Handling
  IF MEAN-EAN11 IS INITIAL           AND
     MEAN-EANTP IS INITIAL.
    IF NOT MLEA-LFEAN   IS INITIAL OR
       NOT RMMZU-LIEFZU IS INITIAL OR
       NOT MLEA-LARTN IS INITIAL.
      CLEAR: MLEA-LARTN.
      MEAN_ME_TAB_SA-EAN_GEPRF = X.
      CLEAR: MLEA-LFEAN, RMMZU-LIEFZU.
* Falls nach der Meldung M3 898 "Bitte Haupt-EAN zum Lief. angeben"
* diese Haupt-EAN-Lief auf einer Zeile ohne Eintrag markiert wird,
* würde als Seiteneffekt in die MEAN_ME_TAB_SA eine leere Zeile einge-
* tragen, da der PBO dann nochmal prozessiert wird mit dieser
* ansonsten leeren Zeile.
* Dasselbe gilt für RMMZU-LIEFZU.
* Dies wird realisiert, indem das FLAG_EXIT hier dazu mißbraucht
* wird, den Tabellenupdate zu verhindern.
      FLAG_EXIT = 'N'.
    ENDIF.
  ENDIF.

  CHECK MEAN_ME_TAB_SA-EAN_GEPRF IS INITIAL.
* Zeile noch zu prüfen  ?

*--- Letzter geprüfter Stand von EAN und Nummerntyp ermitteln
  READ TABLE LMEAN_ME_TAB_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                                      MEINH = MEAN_ME_TAB_SA-MEINH
                                      EAN11 = MEAN_ME_TAB_SA-EAN11.
  IF SY-SUBRC NE 0.
    CLEAR: LMEAN_ME_TAB_SA-EAN11, LMEAN_ME_TAB_SA-NUMTP.
  ENDIF.

* note 428345
  DATA HELP_MEAN_TAB LIKE MEANI OCCURS 0 WITH HEADER LINE.
  CLEAR HELP_MEAN_TAB. REFRESH HELP_MEAN_TAB.
  LOOP AT MEAN_ME_TAB_SA WHERE MATNR = MEAN-MATNR.
    MOVE-CORRESPONDING MEAN_ME_TAB_SA TO HELP_MEAN_TAB.
    APPEND HELP_MEAN_TAB.
  ENDLOOP.
* note 1455075: sort table to check correctly for duplicate EANs
  SORT HELP_MEAN_TAB.


  CALL FUNCTION 'MARA_EAN11'
       EXPORTING
            P_MATNR         = MEAN-MATNR           " Dynprofeld
            P_NUMTP         = MEAN-EANTP                    "
            P_EAN11         = MEAN-EAN11                    "
            P_MEINH         = SMEINH-MEINH                  "
            RET_EAN11       = LMEAN_ME_TAB_SA-EAN11  " letzt. gepr. Std.
            RET_NUMTP       = LMEAN_ME_TAB_SA-NUMTP         "
            BINPT_IN        = SY-BINPT
            P_MESSAGE       = ' '
*           SPERRMODUS      = 'E'
            KZ_MEAN_TAB_UPD = X        " MEAN_ME_TAB nicht ändern !
            ERROR_FLAG      = EAN_FEHLERFLG
            P_HERKUNFT      = 'Z'      " für zusätzl. EAN
       IMPORTING
            VB_FLAG_MEAN    = RMMG2-VB_MEAN
            P_NUMTP         = MEAN-EANTP
            P_EAN11         = MEAN-EAN11
            MSGID           = MSGID    " s. weiter unten
            MSGTY           = MSGTY
            MSGNO           = MSGNO
            MSGV1           = MSGV1
            MSGV2           = MSGV2
            MSGV3           = MSGV3
            MSGV4           = MSGV4
       TABLES
            MARM_EAN        = MARM_EAN " Benötigt zum Puffern !
            MEAN_ME_TAB     = HELP_MEAN_TAB                 "note 428345
            ME_TAB          = ME_TAB
            MEAN_ME_TAB_SA  = MEAN_ME_TAB_SA                "note 1469296
       EXCEPTIONS
            EAN_ERROR       = 1
            OTHERS          = 2.

  IF SY-SUBRC NE 0.
    CLEAR MEAN_ME_TAB_SA-EAN_GEPRF.
*   CLEAR auf MEAN_ME_TAB_SA-GEPRF, weil dieses KZ durch die zwar
*   nicht veränderte aber in MARA_EAN11 durchgeloopte ( = veränderte
*   Kopfzeile) MEAN_ME_TAB_SA nicht mehr richtig sitzt.
    BILDFLAG = X.
    EAN_FEHLERFLG = X.
    MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
*   Ausgabe der Warnungen 068 und 069 (EAN wird geändert / intern
*   vergeben) nachdem die neue EAN aufs Bild geschossen wurde.
    IF MSGNO = 069 OR MSGNO = 068.
*   neue EAN aufs Dynprofeld schieben

*   UPC-E muß konvertiert werden, da der Exit noch nicht gelaufen ist an
*   dieser Stelle
      EAN_BUFF = MEAN-EAN11.
      CALL FUNCTION 'CONVERSION_EAN_OUTPUT'
           EXPORTING
                INPUT   = MEAN-EAN11
                EAN_TYP = MEAN-EANTP
           IMPORTING
                OUTPUT  = MEAN-EAN11.
      PERFORM SET_SCREEN_FIELD_VALUE USING 'MEAN-EAN11' MEAN-EAN11.

*     jetzt erst Warnung ausgeben
      MESSAGE ID MSGID TYPE MSGTY NUMBER MSGNO
              WITH MSGV1 MSGV2 MSGV3 MSGV4.

      MEAN-EAN11 = EAN_BUFF.
    ENDIF.

    CLEAR EAN_FEHLERFLG.
    MEAN_ME_TAB_SA-EAN_GEPRF = X.      " Zeile geprüft und O.K.
  ENDIF.

ENDFORM.                               " EAN_CHECK_SA_VA


*&---------------------------------------------------------------------*
*&      Form  MEAN_ME_TAB_SA_AKT
*&---------------------------------------------------------------------*
FORM MEAN_ME_TAB_SA_AKT.

* wegen Fall: Falsche Meinh eingegeben und dann gelöscht -> es soll
* keine ganz leere Zeile in MEAN_ME_TAB_SA übernommen werden !

  IF NOT MEAN-MATNR IS INITIAL   OR
     NOT SMEINH-MEINH IS INITIAL OR
     NOT MEAN-EAN11 IS INITIAL   OR
     NOT MEAN-EANTP IS INITIAL.
    MEAN_ME_TAB_SA-MATNR     = MEAN-MATNR.
    MEAN_ME_TAB_SA-MEINH     = SMEINH-MEINH.
    MEAN_ME_TAB_SA-EAN11     = MEAN-EAN11.
    MEAN_ME_TAB_SA-NUMTP     = MEAN-EANTP.
    MEAN_ME_TAB_SA-HPEAN     = MEAN-HPEAN.
*   MEAN_ME_TAB_SA-EAN_GEPRF = X.           " hier falsch
    IF EAN_AKT_ZEILE > EAN_LINES.
      APPEND MEAN_ME_TAB_SA.
      EAN_LINES = EAN_LINES + 1.
    ELSE.
      MODIFY MEAN_ME_TAB_SA INDEX EAN_AKT_ZEILE.
    ENDIF.

    MEAN_TAB_CHECK = X.

  ENDIF.

ENDFORM.                               " MEAN_ME_TAB_SA_AKT


*&---------------------------------------------------------------------*
*&      Form  TMLEA_SA_AKT
*&---------------------------------------------------------------------*
FORM TMLEA_SA_AKT.

  REFRESH HMLEA. CLEAR HMLEA.

  IF SY-STEPL = 1.
    CLEAR MLEA_LFEAN_KEY_SA.
  ENDIF.

* TMLEA_SA nur updaten, wenn in POP-UP mit Abfrage "Löschen" oder
* "Ändern" "JA" angegeben wurde (s. Modul CHECK_EAN_ZUS_SA).
  CHECK FLAG_EXIT IS INITIAL.

* Im Sammelartikelfalle die SA_TAB lesen
  check not mean_me_tab_sa-meinh is initial.      "bk/5.0

  READ TABLE TMLEA_SA WITH KEY
                           MATNR = MEAN_ME_TAB_SA-MATNR
                           MEINH = MEAN_ME_TAB_SA-MEINH
                           LIFNR = RMMW2_LIEF
                           EAN11 = MEAN_ME_TAB_SA-EAN11 BINARY SEARCH.
  HTABIX = SY-TABIX.
  IF SY-SUBRC = 0.
* Lieferantenbezug vorhanden in TMLEA_SA
    IF RMMZU-LIEFZU IS INITIAL.
*   Lieferantenbezug wurde gelöscht auf Bild
*   -> es darf hier auch keine Haupt-EAN-Lief gesetzt sein !
      IF NOT TMLEA_SA-LFEAN IS INITIAL.
        CLEAR MLEA-LFEAN.              " Dynpro-Feld ! !
        CLEAR MLEA-LARTN.              " Dynprofeld
      ENDIF.
      DELETE TMLEA_SA INDEX HTABIX.
    ELSE.
*   Lieferantenbezug unverändert, evtl. aber MLEA-LFEAN verändert
      TMLEA_SA-LFEAN = MLEA-LFEAN.
*     Wenn LFEAN leer, dann LARTN auch löschen
      IF TMLEA_SA-LFEAN IS INITIAL.
        clear TMLEA_SA-LARTN.
        clear MLEA-LARTN.
      ENDIF.

* Lieferanten-Artikel-Nummer übernehmen
      IF NOT MLEA-LARTN IS INITIAL.
        TMLEA_SA-LARTN = MLEA-LARTN.
      ELSE.
*       LARTN von evtl. anderer Haupt-EAN-Lief dieser Meinh übernehmen
        HMLEA[] = LMLEA_SA[].
        READ TABLE HMLEA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                                  MEINH = MEAN_ME_TAB_SA-MEINH
                                  LIFNR = RMMW2_LIEF
*                                 EAN11 = MEAN_ME_TAB_SA-EAN11
                                  BINARY SEARCH.
        HTABIX_EAN = SY-TABIX.
        IF SY-SUBRC = 0.
          LOOP AT HMLEA FROM HTABIX_EAN.
            IF HMLEA-MATNR <> MEAN_ME_TAB_SA-MATNR OR
               HMLEA-MEINH <> MEAN_ME_TAB_SA-MEINH OR
               HMLEA-LIFNR <> RMMW2_LIEF.
              EXIT.
            ENDIF.
            IF NOT HMLEA-LFEAN IS INITIAL.
              IF HMLEA-EAN11 <> MEAN_ME_TAB_SA-EAN11.
*               ggf. LARTN von der alten Haupt-EAN übernehmen.
                IF NOT TMLEA_SA-LFEAN IS INITIAL.
                 TMLEA_SA-LARTN = HMLEA-LARTN.  " Tabellenfeld belegen
                ENDIF.
                EXIT.
              ELSE.
*               Löschfall
                CLEAR TMLEA_SA-LARTN.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
      MODIFY TMLEA_SA INDEX HTABIX.
    ENDIF.

  ELSE.
*   noch kein Lieferantenbezug vorhanden
    IF NOT RMMZU-LIEFZU IS INITIAL AND
       NOT RMMW2_LIEF IS INITIAL.
*   Lieferantenbezug neu gesetzt
      TMLEA_SA-MANDT = SY-MANDT.
      TMLEA_SA-MATNR = MEAN_ME_TAB_SA-MATNR.
      TMLEA_SA-MEINH = MEAN_ME_TAB_SA-MEINH.
      TMLEA_SA-LIFNR = RMMW2_LIEF.
      CLEAR TMLEA_SA-LFNUM.
      TMLEA_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
*     CLEAR TMLEA_SA-LFEAN.               " wird später gesetzt
      TMLEA_SA-LFEAN = MLEA-LFEAN.     " Haupt-EAN-Lief pro Meinh setzen
      TMLEA_SA-LARTN = MLEA-LARTN.

      INSERT TMLEA_SA INDEX HTABIX.
*     TMLEA_SA ist sortiert nach MATNR, MEINH, LIFNR und EAN11 !
    ENDIF.
  ENDIF.

* Aktualisieren aller weiterer Lieferantenbeziehungen für die EAN,
* falls sie geändert wurde.
  CHECK NOT EAN_UPD IS INITIAL. " wenn nicht initial -> EAN geändert

  READ TABLE TMLEA_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                               MEINH = MEAN_ME_TAB_SA-MEINH
*                              LIFNR = RMMW2_LIEF
*                              EAN11 = MEAN_ME_TAB_SA-EAN11
                               BINARY SEARCH.
  IF SY-SUBRC = 0.
    HTABIX = SY-TABIX.

    LOOP AT TMLEA_SA FROM HTABIX.
      IF TMLEA_SA-MATNR NE MEAN_ME_TAB_SA-MATNR OR
         TMLEA_SA-MEINH NE MEAN_ME_TAB_SA-MEINH.
        EXIT.
      ENDIF.
      IF TMLEA_SA-EAN11 = EAN_UPD.
*       alte noch upzudatende EAN durch neue ersetzen; hier werden
*       nur Sätze zu Lieferanten ungleich dem aktuellen bearbeitet,
*       da der Satz für den aktuellen Lieferanten beim Ändern gelöscht
*       und hier (oben) wieder mit neuer EAN eingefügt wurde.
        TMLEA_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
        CLEAR TMLEA_SA-LFNUM.                               "note 921066
        MODIFY TMLEA_SA.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " TMLEA_SA_AKT


*&---------------------------------------------------------------------*
*&      Form  DEL_EAN_LIEF_SA
*&---------------------------------------------------------------------*
*       Prüft, ob bei einer zu löschenden EAN ein Lieferantenbezug
*       besteht. Wenn ja, werden alle Lieferantenbezüge zur EAN
*       mitgelöscht, falls dies in einem Pop-UP bestätigt wurde.
*----------------------------------------------------------------------*
FORM DEL_EAN_LIEF_SA USING FLAG_EXIT TYPE C.

  CLEAR FLAG_EXIT.

* Check, ob Lieferantenbezug besteht:
  READ TABLE TMLEA_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                               MEINH = MEAN_ME_TAB_SA-MEINH
*                              LIFNR = RMMW2_LIEF
                               EAN11 = MEAN_ME_TAB_SA-EAN11
                               BINARY SEARCH.
  CHECK SY-SUBRC = 0.
* es existiert ein relevanter Lieferantenbezug zur EAN
* Pop-Up: Löschen Ja / Nein aufrufen
  CLEAR TITEL_BUF.
  CONCATENATE TEXT-070 MEAN_ME_TAB_SA-EAN11 INTO TITEL_BUF
              SEPARATED BY LEERZ.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
       EXPORTING
            DEFAULTOPTION = 'N'        " NEIN-Button vorwählen
            TEXTLINE1     = TEXT-071
            TEXTLINE2     = TEXT-072
            TITEL         = TITEL_BUF
*           START_COLUMN  = 25
*           START_ROW     = 6
       IMPORTING
            ANSWER        = ANTWORT.

  IF ANTWORT NE 'J'.
*  "Löschen ?" wurde mit NEIN oder Abbruch bestätigt !
    FLAG_EXIT = ANTWORT.               " N oder A ! !
    EXIT.                              " -> raus aus Form-Routine
  ENDIF.

* => Löschen wird durchgeführt -> alle Lieferantenbezüge zu
*  Material, Mengeneinheit und EAN werden aus TMLEA_SA gelöscht !

  READ TABLE TMLEA_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                               MEINH = MEAN_ME_TAB_SA-MEINH
*                              LIFNR = RMMW2_LIEF
*                              EAN11 = MEAN_ME_TAB_SA-EAN11
                                       BINARY SEARCH.
  IF SY-SUBRC = 0.
    HTABIX = SY-TABIX.

    CLEAR LIEF_TAB. REFRESH LIEF_TAB.
    CLEAR FLAG_LFEAN_MSG.

    LOOP AT TMLEA_SA FROM HTABIX.
      IF TMLEA_SA-MATNR NE MEAN_ME_TAB_SA-MATNR OR
         TMLEA_SA-MEINH NE MEAN_ME_TAB_SA-MEINH.
        EXIT.
      ENDIF.
      IF TMLEA_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
*     Zuerst prüfen, ob für einen Lieferanten ungleich dem
*     aktuellen Lieferanten der Satz mit gesetztem Haupt-EAN-Lief
*     (LFEAN) gelöscht werden soll. Falls ja, wird dieser Lieferant
*     in LIEF_TAB vermerkt. Für alle Lief. in LIEF_TAB muß das
*     KZ (LFEAN) neu vergeben werden, falls hier nicht der letzte
*     Eintrag zum Lieferanten gelöscht wird.
        IF TMLEA_SA-LIFNR NE RMMW2_LIEF  AND
           NOT TMLEA_SA-LFEAN IS INITIAL.
          LIEF_TAB-LIFNR = TMLEA_SA-LIFNR.
          APPEND LIEF_TAB.
        ENDIF.
*     Lieferantenbezug zur EAN löschen
        DELETE TMLEA_SA.
      ENDIF.
    ENDLOOP.

*   Kennzeichen Haupt-EAN-Lief wird für alle Lieferanten aus LIEF_TAB
*   automatisch neu vergeben. Zuerst wird versucht, das Kennzeichen
*   für die erste EAN der selben Mengeneinheit zu vergeben.
    LOOP AT LIEF_TAB.
      READ TABLE TMLEA_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                                   MEINH = MEAN_ME_TAB_SA-MEINH
                                   LIFNR = LIEF_TAB-LIFNR
*                                  EAN11 = MEAN_ME_TAB_SA-EAN11
                                           BINARY SEARCH.
      IF SY-SUBRC = 0.
        HTABIX = SY-TABIX.
        TMLEA_SA-LFEAN = X.
        MODIFY TMLEA_SA INDEX HTABIX.
        FLAG_LFEAN_MSG = X.

      ENDIF.
    ENDLOOP.

*   Meldung ausgeben, wenn für betroffene Lieferanten-Bezüge das
*   Kennz. Haupt-EAN-Lief neu gesetzt wurde.
    IF NOT FLAG_LFEAN_MSG IS INITIAL.
      MESSAGE I152(MH).
    ENDIF.

  ENDIF.

ENDFORM.                               "  DEL_EAN_LIEF_SA


*&---------------------------------------------------------------------*
*&      Form  UPD_EAN_LIEF_SA
*&---------------------------------------------------------------------*
*       Prüft, ob bei einer zu ändernden EAN ein Lieferantenbezug
*       besteht. Wenn ja, werden alle Lieferantenbezüge zur EAN
*       mitgeändert, falls dies in einem Pop-UP bestätigt wurde.
*       Form wird nur im Retail-Fall aufgerufen.
*----------------------------------------------------------------------*
FORM UPD_EAN_LIEF_SA USING FLAG_EXIT TYPE C.

  CLEAR: FLAG_EXIT, EAN_UPD.

* Check, ob Lieferantenbezug besteht:
  READ TABLE TMLEA_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                               MEINH = MEAN_ME_TAB_SA-MEINH
*                              LIFNR = RMMW2_LIEF
                               EAN11 = MEAN_ME_TAB_SA-EAN11
                                       BINARY SEARCH.
  IF SY-SUBRC = 0.
* es existiert ein relevanter Lieferantenbezug zur EAN
* Pop-Up: Ändern Ja / Nein aufrufen
    CLEAR TITEL_BUF.
    CONCATENATE TEXT-073 MEAN_ME_TAB_SA-EAN11 INTO TITEL_BUF
                SEPARATED BY LEERZ.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
         EXPORTING
              DEFAULTOPTION = 'N'      " NEIN-Button vorwählen
              TEXTLINE1     = TEXT-074
              TEXTLINE2     = TEXT-075
              TITEL         = TITEL_BUF
*             START_COLUMN  = 25
*             START_ROW     = 6
         IMPORTING
              ANSWER        = ANTWORT.

    IF ANTWORT NE 'J'.
*    "Ändern ?" wurde mit NEIN oder Abbruch bestätigt !
      FLAG_EXIT = ANTWORT.             " N oder A ! !
      EXIT.                            " -> raus aus Form-Routine
    ENDIF.

*   => Ändern wird durchgeführt - > dies geschieht durch
*   merken der betroffenen EAN in EAN_UPD und Löschen des Satzes
*   für den aktuellen Lieferanten.
*   Im Form TMLEA_SA_AKT wird für alle Sätze mit der gemerkten EAN
*   in der TMLEA_SA die neue EAN eingetragen. Dies geschieht somit
*   für alle Lieferanten außer dem aktuellen. Der Satz mit dem aktuellen
*   Lieferanten wird neu eingefügt.

    READ TABLE TMLEA_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                                 MEINH = MEAN_ME_TAB_SA-MEINH
*                                LIFNR = RMMW2_LIEF
*                                EAN11 = MEAN_ME_TAB_SA-EAN11
                                         BINARY SEARCH.
    IF SY-SUBRC = 0.
      HTABIX = SY-TABIX.

      LOOP AT TMLEA_SA FROM HTABIX.
        IF TMLEA_SA-MATNR NE MEAN_ME_TAB_SA-MATNR OR
           TMLEA_SA-MEINH NE MEAN_ME_TAB_SA-MEINH.
          EXIT.
        ENDIF.
        IF TMLEA_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
          IF TMLEA_SA-LIFNR NE RMMW2_LIEF AND
             EAN_UPD IS INITIAL.
*           Lieferantenbezug zur EAN für alle anderen Lieferanten merken
            EAN_UPD = TMLEA_SA-EAN11.
          ELSE.
*           Satz mit aktuellem Lieferant wird gelöscht.
            DELETE TMLEA_SA.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.                               " UPD_EAN_LIEF_SA


*&---------------------------------------------------------------------*
*&      Form  EAN_OKCODE_SA_VA
*&---------------------------------------------------------------------*
FORM EAN_OKCODE_SA_VA.

  IF RMMZU-OKCODE EQ FCODE_EADE.       " Einträge löschen
    FLAG_DEL_EAN = X.                  " merken für UPDATE MEINH, MARM
    BILDFLAG = X.
    CLEAR RMMZU-OKCODE.

    GET CURSOR LINE EAN_ZEILEN_NR.     " Zeile bestimmen
    EAN_AKT_ZEILE = EAN_ERSTE_ZEILE + EAN_ZEILEN_NR.

    READ TABLE MEAN_ME_TAB_SA INDEX EAN_AKT_ZEILE.
    IF SY-SUBRC = 0.
*     DELETE MEAN_ME_TAB_SA INDEX EAN_AKT_ZEILE.
*     hier kein DELETE auf Tabellensatz, da erst noch geprüft werden
*     muß, ob es der letzte Satz zu einer Mengeneinheit ist. Dieser
*     darf dann nicht gelöscht werden.

      IF NOT MEAN_ME_TAB_SA-EAN11 IS INITIAL.
*       EAN-Lieferantenbezug-Handling
*       ->  Abfragen (POP-UP) und Löschen von ggf. vorhandenen
*           EAN-Lieferantenbezügen
        PERFORM DEL_EAN_LIEF_SA USING FLAG_EXIT.
        CHECK FLAG_EXIT IS INITIAL.
*       FLAG_EXIT initial, wenn POP-UP mit "JA" verlassen

        MESSAGE S067(WE).
*       Bisherige EAN wird gelöscht

      ENDIF.

      CLEAR: MEAN_ME_TAB_SA-EAN11,
             MEAN_ME_TAB_SA-NUMTP,
             MEAN_ME_TAB_SA-HPEAN.
      MODIFY MEAN_ME_TAB_SA INDEX EAN_AKT_ZEILE.
*     zum Löschen vorgemerkt
*     dieses CLEAR entspricht dem Löschen von Hand ohne Löschbutton
      MEAN_ME_TAB_CHECK = X.   " Prüfung "Tabelle bereinigen" anstoßen

    ENDIF.
  ENDIF.

ENDFORM.                               " EAN_OKCODE_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_CHECK_NEW_ME_SA_VA
*&---------------------------------------------------------------------*
FORM EAN_CHECK_NEW_ME_SA_VA.

  LOOP AT MEAN_ME_TAB_SA.
    HTABIX = SY-TABIX.
    READ TABLE MEINH_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                                 MEINH = MEAN_ME_TAB_SA-MEINH
                                 BINARY SEARCH.

    IF SY-SUBRC NE 0 AND
       NOT MEAN_ME_TAB_SA-MEINH IS INITIAL.
      CLEAR RMMZU-OKCODE.
      IF BILDFLAG IS INITIAL.
        BILDFLAG = X.
        EAN_FEHLERFLG_ME = X.        " darf nur gesetzt werden, wenn die
                                       " Zeile nicht gelöscht wird
        MESSAGE S232(MH) WITH MEAN_ME_TAB_SA-MEINH
                              MEAN_ME_TAB_SA-MATNR.
*       Mengeneinheit & zum Material & ist nicht gepflegt
      ENDIF.
      MEAN_TAB_KEY_SA-MATNR = MEAN_ME_TAB_SA-MATNR.  " Mengeneinh. Key
      MEAN_TAB_KEY_SA-MEINH = MEAN_ME_TAB_SA-MEINH.  " merken
      MEAN_TAB_KEY_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.

*     Wenn mit Löschbutton versucht wird, die falsche Zeile zu korr.,
*     wird sie gelöscht und das Flag wird zurückgesetzt.
      IF NOT FLAG_DEL_EAN IS INITIAL.
        CLEAR EAN_FEHLERFLG_ME.
        DELETE MEAN_ME_TAB_SA.
      ENDIF.

      EXIT.
    ENDIF.

* wenn die Mengeneinheit noch nicht z. Material erfaßt wurde und nach
* obiger Meldung diese per Hand aus dem Feld gelöscht wird, wird die
* ganze Zeile gelöscht, allerdings nur, wenn die Zeile sonst auch leer
* ist. Wenn schon Eingaben in der Zeile vorhanden sind, wird eine
* Message ausgegeben.
    IF FLAG_DEL_EAN IS INITIAL AND
       MEAN_ME_TAB_SA-MEINH IS INITIAL.

      IF MEAN_ME_TAB_SA-EAN11 IS INITIAL AND
         MEAN_ME_TAB_SA-NUMTP IS INITIAL.
        CLEAR EAN_FEHLERFLG_ME.
        DELETE MEAN_ME_TAB_SA.
      ENDIF.

      IF NOT MEAN_ME_TAB_SA-EAN11 IS INITIAL OR
         NOT MEAN_ME_TAB_SA-NUMTP IS INITIAL.
        CLEAR RMMZU-OKCODE.
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          EAN_FEHLERFLG_ME = X.
          MESSAGE S578.
*       Bitte Mengeneinheit eingeben
        ENDIF.
        MEAN_TAB_KEY_SA-MATNR = MEAN_ME_TAB_SA-MATNR.  " Mengeneinh. Key
        MEAN_TAB_KEY_SA-MEINH = MEAN_ME_TAB_SA-MEINH.  " merken
        MEAN_TAB_KEY_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
        EXIT.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                               " EAN_CHECK_NEW_ME_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_PREP_SA_VA
*&---------------------------------------------------------------------*
FORM EAN_PREP_SA_VA.

  LOOP AT MEAN_ME_TAB_SA.
    IF  ( MEAN_ME_TAB_SA-EAN11 = HILFS_EAN    AND
          NOT MEAN_ME_TAB_SA-EAN11 IS INITIAL AND
          MEAN_ME_TAB_SA-MEINH = HILFS_MEEIN  AND
          MEAN_ME_TAB_SA-MATNR = HILFS_MATNR ).
      MEAN_ME_TAB_CHECK = X.
    ELSE.
      HILFS_EAN   = MEAN_ME_TAB_SA-EAN11.
      HILFS_MEEIN = MEAN_ME_TAB_SA-MEINH.
      HILFS_MATNR = MEAN_ME_TAB_SA-MATNR.
    ENDIF.

* Wenn eine MEINH keine EAN zugeordnet hat, darf auch das KZ Haupt-EAN
* nicht gesetzt sein -> MEAN_ME_TAB_SA wird nachbearbeitet.
* --> in Modul CLEAN_MEINH behandelt
    IF MEAN_ME_TAB_SA-EAN11 IS INITIAL AND
       NOT MEAN_ME_TAB_SA-HPEAN IS INITIAL.
      MEAN_ME_TAB_CHECK = X.
    ENDIF.

* evtl. Sparen einiger redundanter Loop-Steps
    IF NOT MEAN_ME_TAB_CHECK IS INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.                               " EAN_PREP_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_DUB_DEL_SA_VA
*&---------------------------------------------------------------------*
FORM EAN_DUB_DEL_SA_VA.

  LOOP AT MEAN_ME_TAB_SA.
    HTABIX  = SY-TABIX + 1.
*   Fall: Löschen
    IF MEAN_ME_TAB_SA-EAN11 IS INITIAL.
*     wenn EAN11 hier noch initial, dann soll gelöscht werden
      IF NOT MEAN_ME_TAB_SA-HPEAN IS INITIAL.
*       Fall: Mengeneinheit ohne EAN --> HPEAN wird zurückgesetzt
        CLEAR MEAN_ME_TAB_SA-HPEAN.
        MODIFY MEAN_ME_TAB_SA.
      ENDIF.
      CLEAR MEAN_ME_BUF_SA.
      READ TABLE MEAN_ME_TAB_SA INDEX HTABIX INTO MEAN_ME_BUF_SA.
*       Falls ein weiterer Satz zur selben Mengeneinheit existiert, kann
*       gelöscht werden, ansonsten bleibt der Satz mit den initialen
*       Feldern EAN11 und NUMTP bestehen. Bem.: Die Einträge mit den
*       leeren EANs zu einer Mengeneinheit stehen immer VOR denjenigen
*       mit gefüllter EAN (wegen Sortierung);
      IF MEAN_ME_BUF_SA-MATNR EQ MEAN_ME_TAB_SA-MATNR AND
         MEAN_ME_BUF_SA-MEINH EQ MEAN_ME_TAB_SA-MEINH AND
         NOT MEAN_ME_TAB_SA-MEINH IS INITIAL.    " siehe nächstes IF
        DELETE MEAN_ME_TAB_SA.
      ENDIF.
* Fall: Die Mengeneinheit ist leer aber die restl. Felder sollen mit
* Löschbutton gelöscht werden.
      IF MEAN_ME_TAB_SA-MEINH IS INITIAL.
        DELETE MEAN_ME_TAB_SA.
      ENDIF.
    ENDIF.

*     Fall: Doppelter Eintrag ( zu einer Mengeneinheit wurde die selbe
*     EAN mehrfach erfaßt);
    IF  ( MEAN_ME_TAB_SA-EAN11 = HILFS_EAN    AND
          NOT MEAN_ME_TAB_SA-EAN11 IS INITIAL AND
*           (die "leeren" EANs werden schon beim Löschen behandelt)
          MEAN_ME_TAB_SA-MEINH = HILFS_MEEIN  AND
          MEAN_ME_TAB_SA-MATNR = HILFS_MATNR ).
      DELETE MEAN_ME_TAB_SA.
    ELSE.
      HILFS_MATNR = MEAN_ME_TAB_SA-MATNR.
      HILFS_EAN   = MEAN_ME_TAB_SA-EAN11.
      HILFS_MEEIN = MEAN_ME_TAB_SA-MEINH.
    ENDIF.

  ENDLOOP.

ENDFORM.                               " EAN_DUB_DEL_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_CHECK_HP_SA_VA
*&---------------------------------------------------------------------*
FORM EAN_CHECK_HP_SA_VA.

* Automatisches Setzen der Haupt-EAN zu einer Mengeneinheit, wenn keine
* EAN markiert ist.
  DO.
    CLEAR TMEAN_CORR_SA.
    CLEAR: HILFS_MEEIN, HILFS_EAN, HILFS_MATNR, MEAN_TAB_KEY_SA.

    ZAEHLER = 1.   " Zaehler für Anzahl Kz Haupt-EAN pro Mengeneinheit

*   Voraussetzung: Tabelle ist sortiert !
    LOOP AT MEAN_ME_TAB_SA.
*   Der Zähler wurde vor dem  Loop auf 1 ( = alles O.K.) gesetzt,
*   für den Fall, daß die erste MEINH untersucht wird.
      CASE ZAEHLER.
        WHEN 0.                     " evtl. Fehlerfall: keine Haupt-EAN
          IF HILFS_MEEIN NE MEAN_ME_TAB_SA-MEINH OR
             HILFS_MATNR NE MEAN_ME_TAB_SA-MATNR.
*         Wechsel MEINH und bei voriger MEINH keine Haupt-EAN
            IF NOT HILFS_EAN IS INITIAL.
*           Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
*           Es kann nicht vorkommen, daß mehr als eine leere EAN
*           für eine MEINH in der Tabelle existiert.
              IF RMMZU-OKCODE NE FCODE_EAFP AND
                 RMMZU-OKCODE NE FCODE_EAPP AND
                 RMMZU-OKCODE NE FCODE_EANP AND
                 RMMZU-OKCODE NE FCODE_EALP.
*                Blättern muß hier ausnahmsweise erlaubt werden, um den
*                Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
*             automatisches Setzen der Haupt-EAN auf den ersten Eintrag
*             zur Mengeneinheit, wenn keine EAN markiert ist anstatt
*             der Ausgabe einer Meldung
              TMEAN_CORR_SA-MATNR = HILFS_MATNR.
              TMEAN_CORR_SA-MEINH = HILFS_MEEIN.
              TMEAN_CORR_SA-EAN11 = HILFS_EAN.
              EXIT.
            ELSE.                      " Ausnahme: kein Fehlerfall
              HILFS_EAN   = MEAN_ME_TAB_SA-EAN11.
*             Fall: keine Haupt-EAN markiert aber auch keine EAN
*             angegeben --> keine Meldung ausgeben, aber neue EAN merken
*             für evtl. spätere Meldung bzgl. der neuen MEINH.
            ENDIF.
          ELSE.
*           MEINH unverändert
            IF NOT MEAN_ME_TAB_SA-HPEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.

        WHEN 1.                        " HPEAN eindeutig
          IF HILFS_MEEIN NE MEAN_ME_TAB_SA-MEINH OR
             HILFS_MATNR NE MEAN_ME_TAB_SA-MATNR.
*           Wechsel MEINH und vorige MEINH O.K.
            ZAEHLER = 0.
            IF NOT MEAN_ME_TAB_SA-HPEAN IS INITIAL.
*           schon für 1. Eintrag der neuen MEINH Haupt-EAN gefunden
              ZAEHLER = ZAEHLER + 1.
            ELSE.
*           Wenn das Haupt-EAN KZ nicht gesetzt ist und die EAN ist
*           leer, ist trotzdem alles O.K. --> Zähler auf 1 setzen.
              IF MEAN_ME_TAB_SA-EAN11 IS INITIAL.
                ZAEHLER = 1.
              ENDIF.
            ENDIF.
            HILFS_MATNR = MEAN_ME_TAB_SA-MATNR. " neue MEINH merken
            HILFS_MEEIN = MEAN_ME_TAB_SA-MEINH. " neue MEINH merken
            HILFS_EAN   = MEAN_ME_TAB_SA-EAN11. " erste neue EAN merken
          ELSE.
*           MEINH unverändert
            IF NOT MEAN_ME_TAB_SA-HPEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.

        WHEN OTHERS.                   " Fehlerfall: mehrere Haupt-EAN
          IF HILFS_MEEIN NE MEAN_ME_TAB_SA-MEINH OR
             HILFS_MATNR NE MEAN_ME_TAB_SA-MATNR.
*           Wechsel MEINH und bei voriger MEINH mehrere Haupt-EAN
            IF NOT HILFS_EAN IS INITIAL.
*             Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
              IF RMMZU-OKCODE NE FCODE_EAFP AND
                 RMMZU-OKCODE NE FCODE_EAPP AND
                 RMMZU-OKCODE NE FCODE_EANP AND
                 RMMZU-OKCODE NE FCODE_EALP.
*                 Blättern muß hier ausnahmsweise erlaubt werden, um den
*                 Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
              IF BILDFLAG IS INITIAL.
                BILDFLAG = X.
                EAN_FEHLERFLG = X.
                MESSAGE S234(MH) WITH HILFS_MATNR HILFS_MEEIN.
*               Die Haupt-EAN zur MEINH ist nicht eindeutig
*               MEAN_ME_TAB_SA-Satz merken wegen Cursorpositionierung
                MEAN_TAB_KEY_SA-MATNR = HILFS_MATNR.
                MEAN_TAB_KEY_SA-MEINH = HILFS_MEEIN.
                MEAN_TAB_KEY_SA-EAN11 = HILFS_EAN.
              ENDIF.
              EXIT.
            ENDIF.
          ELSE.
*             MEINH unverändert
            IF NOT MEAN_ME_TAB_SA-HPEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

* Auswertung der letzten MEINH nach dem Loop !
    IF TMEAN_CORR_SA IS INITIAL.
      CASE ZAEHLER.
        WHEN 0.                        " Fehlerfall: keine Haupt-EAN
*           bei letzter MEINH keine Haupt-EAN
          IF NOT HILFS_EAN IS INITIAL.
*           Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
            IF RMMZU-OKCODE NE FCODE_EAFP AND
               RMMZU-OKCODE NE FCODE_EAPP AND
               RMMZU-OKCODE NE FCODE_EANP AND
               RMMZU-OKCODE NE FCODE_EALP.
*                Blättern muß hier ausnahmsweise erlaubt werden, um den
*                Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
            TMEAN_CORR_SA-MATNR = HILFS_MATNR.
            TMEAN_CORR_SA-MEINH = HILFS_MEEIN.
            TMEAN_CORR_SA-EAN11 = HILFS_EAN.
          ENDIF.

        WHEN 1.                        " HPEAN eindeutig
*         letzte MEINH O.K.

        WHEN OTHERS.                   " Fehlerfall: mehrere Haupt-EAN
*           bei letzter MEINH mehrere Haupt-EAN
          IF NOT HILFS_EAN IS INITIAL.
*             Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
            IF RMMZU-OKCODE NE FCODE_EAFP AND
               RMMZU-OKCODE NE FCODE_EAPP AND
               RMMZU-OKCODE NE FCODE_EANP AND
               RMMZU-OKCODE NE FCODE_EALP.
*                Blättern muß hier ausnahmsweise erlaubt werden, um den
*                Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
            IF BILDFLAG IS INITIAL.
              BILDFLAG = X.
              EAN_FEHLERFLG = X.
              MESSAGE S234(MH) WITH HILFS_MATNR HILFS_MEEIN.
*               Die Haupt-EAN zur MEINH ist nicht eindeutig
*               MEAN_ME_TAB_SA-Satz merken wegen Cursorpositionierung
              MEAN_TAB_KEY_SA-MATNR = HILFS_MATNR.
              MEAN_TAB_KEY_SA-MEINH = HILFS_MEEIN.
              MEAN_TAB_KEY_SA-EAN11 = HILFS_EAN.
            ENDIF.
          ENDIF.
      ENDCASE.

    ENDIF.

    IF NOT EAN_FEHLERFLG IS INITIAL.
      CLEAR TMEAN_CORR_SA.
      EXIT.                            " raus aus DO- Schleife
    ELSE.
      IF TMEAN_CORR_SA IS INITIAL.
        EXIT.                          " raus aus DO- Schleife
      ENDIF.
      READ TABLE MEAN_ME_TAB_SA WITH KEY
                             MATNR = TMEAN_CORR_SA-MATNR
                             MEINH = TMEAN_CORR_SA-MEINH
                             EAN11 = TMEAN_CORR_SA-EAN11 BINARY SEARCH.
      IF SY-SUBRC = 0.
*         sollte hier immer so sein
        MEAN_ME_TAB_SA-HPEAN = X.
        MODIFY MEAN_ME_TAB_SA INDEX SY-TABIX.
      ENDIF.
    ENDIF.

  ENDDO.

ENDFORM.                               " EAN_CHECK_HP_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_UPDHP_SA_VA
*&---------------------------------------------------------------------*
*       Prüft, ob sich die Haupt-EAN innerhalb einer Mengeneinheit
*       gegenüber dem MARM (MEINH) - und/oder MARA - Satz geändert hat.
*       Wenn ja, muß der MARM - Eintrag upgedatet werden, da dort
*       nur die Haupt-EAN gepflegt wird. Handelt es sich zusätzlich
*       noch um die Basismengeneinheit, muß auch der MARA - Satz
*       aktualisiert werden.
*       Dies wird für alle Mengeneinheiten durchgeführt.
*----------------------------------------------------------------------*
FORM EAN_UPDHP_SA_VA.

  LOOP AT MEAN_ME_TAB_SA.
    IF NOT MEAN_ME_TAB_SA-HPEAN IS INITIAL OR " Haupt-EAN gefunden
    ( MEAN_ME_TAB_SA-HPEAN IS INITIAL     AND " oder EAN zur Mengeneinh.
      MEAN_ME_TAB_SA-EAN11 IS INITIAL     AND " wurde gelöscht/ist leer
      MEAN_ME_TAB_SA-NUMTP IS INITIAL     AND
     NOT MEAN_ME_TAB_SA-MEINH IS INITIAL ).

      READ TABLE MEINH_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
                                   MEINH = MEAN_ME_TAB_SA-MEINH
                                   BINARY SEARCH.
      IF SY-SUBRC = 0.                 " sollte hier immer so sein

        HTABIX = SY-TABIX.
        IF MEINH_SA-EAN11 NE MEAN_ME_TAB_SA-EAN11.
*         HPEAN wurde geändert --> MARM (meinh_SA) - Eintrag ändern
          MEINH_SA-EAN11 = MEAN_ME_TAB_SA-EAN11.
          MEINH_SA-NUMTP = MEAN_ME_TAB_SA-NUMTP.
          MODIFY MEINH_SA INDEX HTABIX.
*         UPDKZ in PTAB setzen (nur sicherheitshalber)
          PERFORM SET_UPDATE_TAB USING T_MARM.

          IF NOT MEINH_SA-KZBME IS INITIAL.
*           HPEAN bei Basismengeneinheit geändert --> MARA-Eintr. ändern

            CLEAR HMARA.

            CALL FUNCTION 'MARA_SINGLE_READ'
                 EXPORTING
                      MATNR             = MEAN_ME_TAB_SA-MATNR
                 IMPORTING
                      WMARA             = HMARA
                 EXCEPTIONS
                      LOCK_ON_MATERIAL  = 1
                      LOCK_SYSTEM_ERROR = 2
                      WRONG_CALL        = 3
                      NOT_FOUND         = 4
                      OTHERS            = 5.

            IF SY-SUBRC = 0.

              MARA-EAN11 = MEAN_ME_TAB_SA-EAN11.
              MARA-NUMTP = MEAN_ME_TAB_SA-NUMTP.

              HMARA-EAN11 = MEAN_ME_TAB_SA-EAN11.
              HMARA-NUMTP = MEAN_ME_TAB_SA-NUMTP.

              CLEAR HMARA_TAB. REFRESH HMARA_TAB.
              HMARA_TAB = HMARA.
              APPEND HMARA_TAB.
*             in den Mara-Puffer rein
              CALL FUNCTION 'MARA_SET_DATA_ARRAY'
                   TABLES
                        MARA_TAB = HMARA_TAB.
            ENDIF.

*           UPDKZ in PTAB setzen (nur sicherheitshalber)
            PERFORM SET_UPDATE_TAB USING T_MARA.
          ENDIF.

        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " EAN_UPDHP_SA_VA


*&---------------------------------------------------------------------*
*&      Form  EAN_CHECK_LFEA_SA_VA
*&---------------------------------------------------------------------*
FORM EAN_CHECK_LFEA_SA_VA.

* READ TABLE TMLEA_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
**                             MEINH =
*                              LIFNR = RMMW2_LIEF  BINARY SEARCH.
**                             EAN11 =
* IF SY-SUBRC = 0.
* existiert ein Lieferantenbezug ?
  SORT TMLEA_SA BY MATNR LIFNR MEINH.
* Umsortieren, damit erster Eintrag zum Lieferant gefunden wird.

  LOOP AT MEAN_ME_TAB_SA.

    READ TABLE TMLEA_SA WITH KEY MATNR = MEAN_ME_TAB_SA-MATNR
*                                MEINH =
                                 LIFNR = RMMW2_LIEF  BINARY SEARCH.
*                                EAN11 =
    HTABIX = SY-TABIX.

    CLEAR: HILFS_MEEIN, HILFS_EAN, HILFS_MATNR, MLEA_LFEAN_KEY_SA.

    ZAEHLER = 1.   " Zaehler für Anzahl Kz Haupt-EAN pro Mengeneinheit

*   Voraussetzung: Tabelle ist sortiert nach MATNR, LIFNR, MEINH
    LOOP AT TMLEA_SA FROM HTABIX.
      IF TMLEA_SA-MATNR NE MEAN_ME_TAB_SA-MATNR OR
         TMLEA_SA-LIFNR NE RMMW2_LIEF.
        EXIT.
      ENDIF.

*     Der Zähler wurde vor dem  Loop auf 1 ( = alles O.K.) gesetzt,
*     für den Fall, daß die erste MEINH untersucht wird.
      CASE ZAEHLER.
        WHEN 0.                     " evtl. Fehlerfall: keine Haupt-EAN
          IF HILFS_MEEIN NE TMLEA_SA-MEINH.
*           Wechsel MEINH und bei voriger MEINH keine Haupt-EAN
*           CLEAR RMMZU-OKCODE.
            IF RMMZU-OKCODE NE FCODE_EAFP AND
               RMMZU-OKCODE NE FCODE_EAPP AND
               RMMZU-OKCODE NE FCODE_EANP AND
               RMMZU-OKCODE NE FCODE_EALP.
*              Blättern muß hier ausnahmsweise erlaubt werden, um den
*              Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
            IF BILDFLAG IS INITIAL.
              BILDFLAG = X.
              EAN_FEHLERFLG_LFEAN = X.
              MESSAGE S235(MH)
                 WITH RMMW2_LIEF HILFS_MEEIN TMLEA_SA-MATNR.
*             keine Haupt-EAN-Lief gesetzt
*             TMLEA_SA-Satz merken wegen Cursorpositionierung
              MLEA_LFEAN_KEY_SA-MATNR = HILFS_MATNR.
              MLEA_LFEAN_KEY_SA-MEINH = HILFS_MEEIN.
              MLEA_LFEAN_KEY_SA-EAN11 = HILFS_EAN.
            ENDIF.
            EXIT.
          ELSE.
*         MEINH unverändert
            IF NOT TMLEA_SA-LFEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.

        WHEN 1.                        " LFEAN eindeutig
          IF HILFS_MEEIN NE TMLEA_SA-MEINH.
*           Wechsel MEINH und vorige MEINH O.K.
            ZAEHLER = 0.
            IF NOT TMLEA_SA-LFEAN IS INITIAL.
*             schon für 1. Eintrag der neuen MEINH Haupt-EAN gefunden
              ZAEHLER = ZAEHLER + 1.
            ENDIF.
            HILFS_MATNR = TMLEA_SA-MATNR. " neue MATNR merken
            HILFS_MEEIN = TMLEA_SA-MEINH. " neue MEINH merken
            HILFS_EAN   = TMLEA_SA-EAN11. " erste neue EAN merken
          ELSE.
*           MEINH unverändert
            IF NOT TMLEA_SA-LFEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.

        WHEN OTHERS.                   " Fehlerfall: mehrere Haupt-EAN
          IF HILFS_MEEIN NE TMLEA_SA-MEINH.
*           Wechsel MEINH und bei voriger MEINH mehrere Haupt-EAN
*           CLEAR RMMZU-OKCODE.
            IF RMMZU-OKCODE NE FCODE_EAFP AND
               RMMZU-OKCODE NE FCODE_EAPP AND
               RMMZU-OKCODE NE FCODE_EANP AND
               RMMZU-OKCODE NE FCODE_EALP.
*              Blättern muß hier ausnahmsweise erlaubt werden, um den
*              Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
            IF BILDFLAG IS INITIAL.
              BILDFLAG = X.
              EAN_FEHLERFLG_LFEAN = X.
              MESSAGE S236(MH)
                 WITH RMMW2_LIEF HILFS_MEEIN TMLEA_SA-MATNR.
*             Die Haupt-EAN zur MEINH ist nicht eindeutig
*             tmlea_SA-Satz merken wegen Cursorpositionierung
              MLEA_LFEAN_KEY_SA-MATNR = HILFS_MATNR.
              MLEA_LFEAN_KEY_SA-MEINH = HILFS_MEEIN.
              MLEA_LFEAN_KEY_SA-EAN11 = HILFS_EAN.
            ENDIF.
            EXIT.
          ELSE.
*           MEINH unverändert
            IF NOT TMLEA_SA-LFEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF NOT EAN_FEHLERFLG_LFEAN IS INITIAL.
      EXIT.
    ENDIF.

* Auswertung der letzten MEINH nach dem Loop !
    CASE ZAEHLER.
      WHEN 0.                          " Fehlerfall: keine Haupt-EAN
*       bei letzter MEINH keine Haupt-EAN
*       CLEAR RMMZU-OKCODE.
        IF RMMZU-OKCODE NE FCODE_EAFP AND
           RMMZU-OKCODE NE FCODE_EAPP AND
           RMMZU-OKCODE NE FCODE_EANP AND
           RMMZU-OKCODE NE FCODE_EALP.
*          Blättern muß hier ausnahmsweise erlaubt werden, um den
*          Fehler ggf. auf einer anderen Seite korr. zu können.
          CLEAR RMMZU-OKCODE.
        ENDIF.
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          EAN_FEHLERFLG_LFEAN = X.
          MESSAGE S235(MH) WITH RMMW2_LIEF HILFS_MEEIN TMLEA_SA-MATNR.
*         Bitte zuerst Haupt-EAN zur MEINH angeben
*         tmlea_SA-Satz merken wegen Cursorpositionierung
          MLEA_LFEAN_KEY_SA-MATNR = HILFS_MATNR.
          MLEA_LFEAN_KEY_SA-MEINH = HILFS_MEEIN.
          MLEA_LFEAN_KEY_SA-EAN11 = HILFS_EAN.
        ENDIF.

      WHEN 1.                          " HPEAN eindeutig
*         letzte MEINH O.K.

      WHEN OTHERS.                     " Fehlerfall: mehrere Haupt-EAN
*         bei letzter MEINH mehrere Haupt-EAN
*         CLEAR RMMZU-OKCODE.
        IF RMMZU-OKCODE NE FCODE_EAFP AND
           RMMZU-OKCODE NE FCODE_EAPP AND
           RMMZU-OKCODE NE FCODE_EANP AND
           RMMZU-OKCODE NE FCODE_EALP.
*           Blättern muß hier ausnahmsweise erlaubt werden, um den
*           Fehler ggf. auf einer anderen Seite korr. zu können.
          CLEAR RMMZU-OKCODE.
        ENDIF.
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          EAN_FEHLERFLG_LFEAN = X.
          MESSAGE S236(MH) WITH RMMW2_LIEF HILFS_MEEIN TMLEA_SA-MATNR.
*         Die Haupt-EAN zur MEINH ist nicht eindeutig
*         TMLEA_SA-Satz merken wegen Cursorpositionierung
          MLEA_LFEAN_KEY_SA-MATNR = HILFS_MATNR.
          MLEA_LFEAN_KEY_SA-MEINH = HILFS_MEEIN.
          MLEA_LFEAN_KEY_SA-EAN11 = HILFS_EAN.
        ENDIF.
    ENDCASE.

    IF NOT EAN_FEHLERFLG_LFEAN IS INITIAL.
      EXIT.
    ENDIF.

* ENDIF.
  ENDLOOP.

*   nochmal zurücksortieren
  SORT TMLEA_SA BY MATNR MEINH LIFNR EAN11.

ENDFORM.                               " EAN_CHECK_LFEA_SA_VA
ENHANCEMENT-POINT LMGD2F05_01 SPOTS ES_LMGD2F05 STATIC INCLUDE BOUND .
