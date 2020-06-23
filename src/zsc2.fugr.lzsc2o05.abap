*----------------------------------------------------------------------*
*   INCLUDE LMGD2O05                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PG_INITIALISIERUNG  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Initflag, Ermitteln Anzahl Zeilen, Mengeneinheiten,
*       die zum Material gehören auch ohne Plazierungsgruppen
*       vorblenden.
*----------------------------------------------------------------------*
MODULE PG_INITIALISIERUNG OUTPUT.

  IF RMMZU-PGINIT IS INITIAL.
    RMMZU-PGINIT = X.
    CLEAR: PG_ERSTE_ZEILE.
  ENDIF.

  CLEAR: PG_ZEILEN_NR.

  IF T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
    LOOP AT MEINH.
      READ TABLE TMALG WITH KEY MEINH = MEINH-MEINH.
      IF SY-SUBRC NE 0.
*       noch kein Eintrag zur Mengeneinheit im Bild Plazierungsgruppen
*       vorhanden.
*       Mengeneinheit aus MEINH mit leeren Einträgen übernehmen
*       als Voreinstellung
*       Solche Einträge werden am Ende des Bildes wieder gelöscht
*       (Modul CLEAN_MEINH_PG);
        CLEAR TMALG.
        TMALG-MEINH = MEINH-MEINH.
        APPEND TMALG.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Sortierung notwendig für Feldauswahl
  SORT TMALG BY MEINH LAYGR.

* Initialisieren der Kennzeichen zur Aktualisierung von int. Tabellen
  CLEAR: TMALG_CHECK,
         HILFS_MEEIN_PG.               " für Feldauswahl

*--Ermitteln der aktuellen Anzahl Einträge
  DESCRIBE TABLE TMALG LINES PG_LINES.

* AHE: 24.07.96 - A
* Umstellung auf Table-Control
  IF NOT FLG_TC IS INITIAL.
    REFRESH CONTROL 'TC_LAY' FROM SCREEN SY-DYNNR.
    ASSIGN TC_LAY TO <F_TC>.
    TC_LAY-LINES    = PG_LINES.
    TC_LAY-TOP_LINE = PG_ERSTE_ZEILE + 1.
    TC_LAY_TOPL_BUF = TC_LAY-TOP_LINE. " Puffer für TCtrl
* AHE: 24.07.96 - E
  ENDIF.
ENDMODULE.                             " PG_INITIALISIERUNG  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  ANZEIGEN_PG OUTPUT
*&---------------------------------------------------------------------*
*    Ermitteln Anzahl Einträge.
*    Fuellen der Loop-Zeile mit den Daten aus der internen Tabelle
*----------------------------------------------------------------------*
MODULE ANZEIGEN_PG OUTPUT.

  IF SY-STEPL = 1.
    PG_ZLEPROSEITE = SY-LOOPC.

* Auf die fehlerhafte Zeile positionieren, wenn eine nicht erlaubte
* Mengeneinheit eingegeben wurde. Diese kann wegen SORT von TMALG
* auf einer anderen Seite stehen.

    IF NOT PG_FEHLERFLG_ME IS INITIAL.
      READ TABLE TMALG WITH KEY MEINH = TMALG_KEY-MEINH.
      IF SY-SUBRC = 0.
        PG_ERSTE_ZEILE = SY-TABIX - 1.
      ENDIF.
    ENDIF.

  ENDIF.

  PG_AKT_ZEILE = PG_ERSTE_ZEILE + SY-STEPL.

*-------Anzeigen interne Tabelle---------------------------------

  READ TABLE TMALG INDEX PG_AKT_ZEILE.

  IF SY-SUBRC = 0.
    SMEINH-MEINH = TMALG-MEINH.
    MALG-LAYGR   = TMALG-LAYGR.
    MALG-HPLGR   = TMALG-HPLGR.
* AHE: 22.05.96 - A
    MALG-SORF1   = TMALG-SORF1.
* AHE: 22.05.96 - E
* AHE: 19.03.98 - A (4.0c)
* 2 neue Felder
    MALG-FACIN   = TMALG-FACIN.
    MALG-SHELF   = TMALG-SHELF.
* AHE: 19.03.98 - E

* AHE: 07.01.99 - A (4.6a)
* 5 neue Felder
    CLEAR MALG-LMVER.          " <<== da noch nicht unterstützt !
*   MALG-LMVER = TMALG-LMVER.  " <<== da noch nicht unterstützt !
    MALG-FRONT = TMALG-FRONT.
    MALG-SHQNM = TMALG-SHQNM.
    MALG-SHQNO = TMALG-SHQNO.
    MALG-PREQN = TMALG-PREQN.
* AHE: 07.01.99 - E

*   Lesen der Bezeichnungen für die Mengeneinheiten nach T006A-MSEHT
*   Hier wird nicht mit der Ausblendtechnik (FELDBEZTAB) gearbeitet,
*   da nicht notwendig.
    CALL FUNCTION 'ZUS_EAN_READ_DESCRIPTION'
         EXPORTING
              P_MEAN_MEINH = TMALG-MEINH
         IMPORTING
              WT006A       = T006A     " T006A-MSEHT belegt
         EXCEPTIONS
              OTHERS       = 1.


*   Lesen Bezeichnung Plazierungsgruppe. Hier wird ebenfalls ohne
*   Ausblendtechnik (FELDBEZTAB) gearbeitet.
    IF NOT MALG-LAYGR IS INITIAL.
      SELECT SINGLE * FROM TWMLT
       WHERE LAYGR = MALG-LAYGR AND
             SPRAS = SY-LANGU.

      IF SY-SUBRC NE 0.
        CLEAR TWMLT-LTEXT.
      ENDIF.

    ELSE.
      CLEAR TWMLT-LTEXT.
    ENDIF.


* Cursor positionieren und hervorheben der Zeile, falls im vorherigen
* PAI ein Fehler (S-Meldung) ausgegeben wurde.
* Der Fehler bezieht sich dann auf das KZ HPLGR !
    IF NOT PG_FEHLERFLG IS INITIAL      AND
       TMALG_KEY-MEINH = TMALG-MEINH.  " AND
*      TMALG_KEY-LAYGR = TMALG-LAYGR.
      PERFORM PG_SET_ZEILE.
    ENDIF.

  ENDIF.

ENDMODULE.                             " ANZEIGEN_PG  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  PG_EINTRAEGE_ERMITT  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Anzahl Einträge und Nummer des Eintrags in der          *
*       ersten Zeile (für Anzeige: Einträge ____ / ____ ).            *
*----------------------------------------------------------------------*
MODULE PG_EINTRAEGE_ERMITT OUTPUT.

  PG_EINTRAEGE_C   = PG_LINES.
  IF PG_LINES = 0.
    PG_ERSTE_ZEILE_C = 0.
  ELSE.
    PG_ERSTE_ZEILE_C = PG_ERSTE_ZEILE + 1.
  ENDIF.

ENDMODULE.                             " PG_EINTRAEGE_ERMITT  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  FELDAUSWAHL_PG  OUTPUT
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
MODULE FELDAUSWAHL_PG OUTPUT.

  PG_AKT_ZEILE = PG_ERSTE_ZEILE + SY-STEPL.

  READ TABLE TMALG INDEX PG_AKT_ZEILE.
  IF SY-SUBRC = 0.
* Belegte Zeilen: Es wird jeder erste Eintrag einer Mengeneinheit
* intensified geschaltet. Beim Anzeigen wird die gesamte Zeile auf "nur
* Ausgabe" geschaltet.

    IF TMALG-MEINH = HILFS_MEEIN_PG.
*   MEINH hat sich nicht geändert
      CLEAR FLAG_INTENSIFY_PG.
    ELSE.
*   neue MEINH
      FLAG_INTENSIFY_PG = X.
      HILFS_MEEIN_PG = TMALG-MEINH.
    ENDIF.

    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ.  " Anzeigen
      LOOP AT SCREEN.
        SCREEN-INPUT       = 0.
        SCREEN-REQUIRED    = 0.
*     Jede erste neue MEINH intensified schalten und alle Bezeichnungen
*     für die nächsten Einträge dieser Mengeneinheit ausblenden.
        IF NOT FLAG_INTENSIFY_PG IS INITIAL AND
*          screen-group1 = '001'.   mk/4.0A
          ( SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001' ).
          SCREEN-INTENSIFIED = 1.
*       elseif screen-group1 = '002' and  mk/4.0A
        ELSEIF ( SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002' ) AND
               FLAG_INTENSIFY_PG IS INITIAL.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    ELSE.                              " Anlegen / Ändern

      LOOP AT SCREEN.
*       if screen-group1 = '001'.   mk/4.0A
        IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001'.
          IF NOT TMALG-MEINH IS INITIAL.
            SCREEN-INPUT       = 0.
            SCREEN-REQUIRED    = 0.
*           Cursor positionieren und hervorheben der Zeile,
*           falls im vorherigen PAI ein Fehler (S-Meldung)
*           ausgegeben wurde. Außerdem freischalten
*           der Mengeneinheit zur Korrektur.
            IF NOT PG_FEHLERFLG_ME IS INITIAL   AND
               TMALG_KEY-MEINH = TMALG-MEINH. " AND
*              TMALG_KEY-LAYGR = TMALG-LAYGR.
              SCREEN-INPUT       = 1.
*             SCREEN-REQUIRED    = 1.
              SCREEN-INTENSIFIED = 1.
*             Zur Cursorpositionierung
              MOVE SY-STEPL TO PG_ZEILEN_NR.
*             PERFORM PG_SET_ZEILE.
            ENDIF.
*           Jede erste neue MEINH intensified schalten
            IF NOT FLAG_INTENSIFY_PG IS INITIAL.
              SCREEN-INTENSIFIED = 1.
            ENDIF.
          ENDIF.
*       elseif screen-group1 = '002' and  mk/4.0A
        ELSEIF ( SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002' ) AND
               FLAG_INTENSIFY_PG IS INITIAL.
*       Bei jedem weiteren Eintrag zu einer Mengeneinheit wird die
*       Bezeichnung ausgeblendet.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

  ELSE.

*   Leere Zeilen: Beim "Anzeigen" werden diese Zeilen komplett auf "nur
*   Ausgabe" geschaltet.
    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ. " Anzeigen
      LOOP AT SCREEN.
        SCREEN-INPUT       = 0.
        SCREEN-REQUIRED    = 0.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

  ENDIF.
ENDMODULE.                             " FELDAUSWAHL_PG  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  PG_SETZEN_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Cursor auf PG_ZEILEN_NR abhängig vom Fehler
*----------------------------------------------------------------------*
MODULE PG_SETZEN_CURSOR OUTPUT.

  CHECK PG_ZEILEN_NR NE SPACE.

  IF NOT PG_FEHLERFLG_ME IS INITIAL.
    SET CURSOR FIELD 'SMEINH-MEINH' LINE PG_ZEILEN_NR.
  ELSE.
    SET CURSOR FIELD 'MALG-HPLGR' LINE PG_ZEILEN_NR.
  ENDIF.

  CLEAR PG_ZEILEN_NR.

ENDMODULE.                             " PG_SETZEN_CURSOR  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  RM03E_PLGR  OUTPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE RM03E_PLGR OUTPUT.

  CLEAR RM03E-PLGR.

  LOOP AT TMALG WHERE MEINH NE MARA-MEINS OR
                     ( MEINH = MARA-MEINS AND
                       HPLGR = SPACE ).
* es existiert noch ein weiterer Eintrag gegenüber dem Eintrag auf dem
* Grunddatenbild
* (hier = Hauptplazierungsgruppe zur Basismengeneinheit)
    RM03E-PLGR = X.
    EXIT.
  ENDLOOP.

ENDMODULE.                             " RM03E_PLGR  OUTPUT
