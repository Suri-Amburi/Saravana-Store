*----------------------------------------------------------------------*
*   INCLUDE LMGD2I03                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  CHECK_PG INPUT
*&---------------------------------------------------------------------*
* Lesen der Zeile. Zur Zeit keine weitere Prüfung notwendig.
*----------------------------------------------------------------------*
MODULE CHECK_PG INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK RMMZU-OKCODE NE FCODE_PGDE.
* CHECK BILDFLAG IS INITIAL.

  CLEAR TMALG.   " wegen evtl. neuer noch nicht übernommener Zeile

  READ TABLE TMALG INDEX PG_AKT_ZEILE.

ENDMODULE.                             " CHECK_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  OKCODE_PG  INPUT
*&---------------------------------------------------------------------*
MODULE OKCODE_PG INPUT.

* Wenn Bildflag außerhalb bereits gesetzt wurde und im Bildbaustein die
* Aktion Blättern im Bildbaustein angewählt wurde, darf das Blättern
* nicht ausgeführt werden (sonst werden ungeprüfte Daten fortge-
* schrieben).
  IF NOT PG_BILDFLAG_OLD IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_PGFP OR
       RMMZU-OKCODE = FCODE_PGPP OR
       RMMZU-OKCODE = FCODE_PGNP OR
       RMMZU-OKCODE = FCODE_PGLP  ).
    CLEAR RMMZU-OKCODE.                " kein Blättern ! !
  ENDIF.

* AHE: 24.07.96 - A
* Umstellung auf Table-Control
  IF PG_BILDFLAG_OLD IS INITIAL.
    IF NOT FLG_TC IS INITIAL.
*   Blättern erlauben für Table-Control
      PG_ERSTE_ZEILE = TC_LAY-TOP_LINE - 1.
*   wurde geblättert mit TabCtrl ?
      IF TC_LAY-TOP_LINE NE TC_LAY_TOPL_BUF.
        TC_LAY_TOPL_BUF = TC_LAY-TOP_LINE.
        PERFORM PARAM_SET.
      ENDIF.
    ENDIF.
  ENDIF.
* AHE. 24.07.96 - E

  PERFORM OK_CODE_PG.

ENDMODULE.                             " OKCODE_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_HPPG  INPUT
*&---------------------------------------------------------------------*
*       Zu einer Mengeneinheit muß genau eine Haupt-Plazierungsgruppe
*       vorhanden sein, falls mindestens eine Plazierungsgruppe einer
*       Mengeneinheit zugeordnet wurde.
*----------------------------------------------------------------------*
MODULE CHECK_HPPG INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

* AHE: 13.02.97 - A
* Automatisches Setzen des Hauptlayoutbausteins zu einer Mengeneinheit,
* wenn kein Layoutbaustein markiert ist.
  DO.
    CLEAR TMALG_CORR.
* AHE: 13.02.97 - E
    CLEAR: HILFS_MEEIN_PG, HILFS_LAYGR, TMALG_KEY.

    ZAEHLER = 1. " Zaehler für Anzahl Kz Haupt-Pl.Grp. pro Mengeneinheit

* Voraussetzung: Tabelle ist sortiert !
    LOOP AT TMALG.
*  Der Zähler wurde vor dem  Loop auf 1 ( = alles O.K.) gesetzt,
*  für den Fall, daß die erste MEINH untersucht wird.
      CASE ZAEHLER.
       WHEN 0.                   " evtl. Fehlerfall: keine Haupt-Pl.Grp.
          IF HILFS_MEEIN_PG NE TMALG-MEINH.
*            Wechsel MEINH und bei voriger MEINH keine Haupt-Pl.Grp.
            IF NOT HILFS_LAYGR IS INITIAL.
*             Meldung nur, wenn eine Pl.Grp. vorhanden (1. wurde
*             gemerkt).
*             Es kann nicht vorkommen, daß mehr als eine leere Pl.Grp.
*             für eine MEINH in der Tabelle existiert.
*           CLEAR RMMZU-OKCODE.
              IF RMMZU-OKCODE NE FCODE_PGFP AND
                 RMMZU-OKCODE NE FCODE_PGPP AND
                 RMMZU-OKCODE NE FCODE_PGNP AND
                 RMMZU-OKCODE NE FCODE_PGLP.
*              Blättern muß hier ausnahmsweise erlaubt werden, um den
*              Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
* AHE: 13.02.97 - A
* automatisches Setzen des Hauptlayoutbausteins auf den ersten Eintrag
* zur Mengeneinheit, wenn kein Layoutbaustein markiert ist anstatt
* der Ausgabe einer Meldung
              TMALG_CORR-MEINH = HILFS_MEEIN_PG.
              TMALG_CORR-LAYGR = HILFS_LAYGR.
*           IF BILDFLAG IS INITIAL.
*             BILDFLAG = X.
*             PG_FEHLERFLG = X.
*             MESSAGE S202(MH) WITH HILFS_MEEIN_PG.
*             Bitte zuerst Haupt-Pl.Grp. zur MEINH angeben
*             TMALG-Satz merken wegen Cursorpositionierung
*             TMALG_KEY-MEINH = HILFS_MEEIN_PG.
*             TMALG_KEY-LAYGR = HILFS_LAYGR.
*           ENDIF.
* AHE: 13.02.97 - E
              EXIT.
            ELSE.                      " Ausnahme: kein Fehlerfall
              HILFS_LAYGR   = TMALG-LAYGR.
*            Fall: keine Haupt-Pl.Grp. markiert aber auch keine Pl.Grp.
*            angegeben --> keine Meldung ausgeben, aber neue Pl.Grp.
*            merken für evtl. spätere Meldung bzgl. der neuen MEINH.
            ENDIF.
          ELSE.
*           MEINH unverändert
            IF NOT TMALG-HPLGR IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-Pl.Grp. gefunden
            ENDIF.
          ENDIF.

        WHEN 1.                        " HPLGR eindeutig
          IF HILFS_MEEIN_PG NE TMALG-MEINH.
*            Wechsel MEINH und vorige MEINH O.K.
            ZAEHLER = 0.
            IF NOT TMALG-HPLGR IS INITIAL.
*            schon für 1. Eintrag der neuen MEINH Haupt-Pl.Grp. gefunden
              ZAEHLER = ZAEHLER + 1.
            ELSE.
*           Wenn das Haupt-Pl.Grp. KZ nicht gesetzt ist und die Pl.Grp.
*           ist leer, ist trotzdem alles O.K. --> Zähler auf 1 setzen.
              IF TMALG-LAYGR IS INITIAL.
                ZAEHLER = 1.
              ENDIF.
            ENDIF.
            HILFS_MEEIN_PG = TMALG-MEINH." neue MEINH merken
            HILFS_LAYGR    = TMALG-LAYGR." erste neue Pl.Grp. merken
          ELSE.
*           MEINH unverändert
            IF NOT TMALG-HPLGR IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-Pl.Grp. gefunden
            ENDIF.
          ENDIF.

      WHEN OTHERS.                 " Fehlerfall: mehrere Haupt-Pl.Grp.'s
          IF HILFS_MEEIN_PG NE TMALG-MEINH.
*         Wechsel MEINH und bei voriger MEINH mehrere Haupt-Pl.Grp.
            IF NOT HILFS_LAYGR IS INITIAL.
*           Meldung nur, wenn eine Pl.Grp. vorhanden (1. wurde gemerkt).
*           CLEAR RMMZU-OKCODE.
              IF RMMZU-OKCODE NE FCODE_PGFP AND
                 RMMZU-OKCODE NE FCODE_PGPP AND
                 RMMZU-OKCODE NE FCODE_PGNP AND
                 RMMZU-OKCODE NE FCODE_PGLP.
*              Blättern muß hier ausnahmsweise erlaubt werden, um den
*              Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
              IF BILDFLAG IS INITIAL.
                BILDFLAG = X.
                PG_FEHLERFLG = X.
                MESSAGE S203(MH) WITH HILFS_MEEIN_PG.
*             Die Haupt-Plazierungsgruppe zur MEINH ist nicht eindeutig
*             TMALG-Satz merken wegen Cursorpositionierung
                TMALG_KEY-MEINH = HILFS_MEEIN_PG.
                TMALG_KEY-LAYGR = HILFS_LAYGR.
              ENDIF.
              EXIT.
            ENDIF.
          ELSE.
*         MEINH unverändert
            IF NOT TMALG-HPLGR IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-Pl.Grp. gefunden
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

* Auswertung der letzten MEINH nach dem Loop !
* AHE: 13.02.97 - A
    IF TMALG_CORR IS INITIAL.
* AHE: 13.02.97 - E
      CASE ZAEHLER.
        WHEN 0.                        " Fehlerfall: keine Haupt-Pl.Grp.
*     bei letzter MEINH keine Haupt-Pl.Grp.
          IF NOT HILFS_LAYGR IS INITIAL.
*       Meldung nur, wenn eine Pl.Grp. vorhanden (1. wurde gemerkt).
*       CLEAR RMMZU-OKCODE.
            IF RMMZU-OKCODE NE FCODE_PGFP AND
               RMMZU-OKCODE NE FCODE_PGPP AND
               RMMZU-OKCODE NE FCODE_PGNP AND
               RMMZU-OKCODE NE FCODE_PGLP.
*          Blättern muß hier ausnahmsweise erlaubt werden, um den
*          Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
* AHE: 13.02.97 - A
            TMALG_CORR-MEINH = HILFS_MEEIN_PG.
            TMALG_CORR-LAYGR = HILFS_LAYGR.
*       IF BILDFLAG IS INITIAL.
*         BILDFLAG = X.
*         PG_FEHLERFLG = X.
*         MESSAGE S202(MH) WITH HILFS_MEEIN_PG.
*         Bitte zuerst Haupt-Plazierungsgruppe zur MEINH angeben
*         TMALG-Satz merken wegen Cursorpositionierung
*         TMALG_KEY-MEINH = HILFS_MEEIN_PG.
*         TMALG_KEY-LAYGR = HILFS_LAYGR.
*       ENDIF.
* AHE: 13.02.97 - E
          ENDIF.

        WHEN 1.                        " HPLGR eindeutig
*         letzte MEINH O.K.

        WHEN OTHERS.             " Fehlerfall: mehrere Haupt-Pl.Grp.
*        bei letzter MEINH mehrere Haupt-Pl.Grp.
          IF NOT HILFS_LAYGR IS INITIAL.
*       Meldung nur, wenn eine Pl.Grp. vorhanden (1. wurde gemerkt).
*       CLEAR RMMZU-OKCODE.
            IF RMMZU-OKCODE NE FCODE_PGFP AND
               RMMZU-OKCODE NE FCODE_PGPP AND
               RMMZU-OKCODE NE FCODE_PGNP AND
               RMMZU-OKCODE NE FCODE_PGLP.
*          Blättern muß hier ausnahmsweise erlaubt werden, um den
*          Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
            IF BILDFLAG IS INITIAL.
              BILDFLAG = X.
              PG_FEHLERFLG = X.
              MESSAGE S203(MH) WITH HILFS_MEEIN_PG.
*         Die Haupt-Plazierungsgruppe zur MEINH ist nicht eindeutig
*         TMALG-Satz merken wegen Cursorpositionierung
              TMALG_KEY-MEINH = HILFS_MEEIN_PG.
              TMALG_KEY-LAYGR = HILFS_LAYGR.
            ENDIF.
          ENDIF.
      ENDCASE.

* AHE: 13.02.97 - A
    ENDIF.

    IF NOT PG_FEHLERFLG IS INITIAL.
      CLEAR TMALG_CORR.
      EXIT.                            " raus aus DO- Schleife
    ELSE.
      IF TMALG_CORR IS INITIAL.
        EXIT.                          " raus aus DO- Schleife
      ENDIF.
      READ TABLE TMALG WITH KEY MEINH = TMALG_CORR-MEINH
                                LAYGR = TMALG_CORR-LAYGR BINARY SEARCH.
      IF SY-SUBRC = 0.
*   sollte hier immer so sein
        TMALG-HPLGR = X.
        MODIFY TMALG INDEX SY-TABIX.
      ENDIF.
    ENDIF.

  ENDDO.
* AHE: 13.02.97 - E

ENDMODULE.                             " CHECK_HPPG INPUT


*&---------------------------------------------------------------------*
*&      Module  OKCODE_PGDE  INPUT
*&---------------------------------------------------------------------*
*       Bereitet Löschen Plazierungsgruppen vor; Hier wird nur
*       LÖSCHEN per Button behandelt. Das eigentliche Löschen in der
*       Tabelle TMALG geschieht später.
*----------------------------------------------------------------------*
MODULE OKCODE_PGDE INPUT.

  CLEAR FLAG_DEL_PG.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  IF NOT PG_BILDFLAG_OLD IS INITIAL AND
      RMMZU-OKCODE = FCODE_PGDE.
    CLEAR RMMZU-OKCODE.
  ENDIF.

  IF RMMZU-OKCODE EQ FCODE_PGDE.       " Einträge löschen
    FLAG_DEL_PG = X.
    BILDFLAG = X.
    CLEAR RMMZU-OKCODE.

    GET CURSOR LINE PG_ZEILEN_NR.      " Zeile bestimmen
    PG_AKT_ZEILE = PG_ERSTE_ZEILE + PG_ZEILEN_NR.

    READ TABLE TMALG INDEX PG_AKT_ZEILE.
    IF SY-SUBRC = 0.
*     DELETE TMALG INDEX PG_AKT_ZEILE.
*     hier kein DELETE auf Tabellensatz, da erst noch geprüft werden
*     muß, ob es der letzte Satz zu einer Mengeneinheit ist. Dieser
*     darf dann nicht gelöscht werden (wegen Vorblenden);

      IF NOT TMALG-LAYGR IS INITIAL.
*        MESSAGE S201(MH).
*       Bisherige Plazierungsgruppe wird gelöscht
      ENDIF.

      CLEAR: TMALG-LAYGR,
* AHE: 03.06.96 - A
             TMALG-SORF1,
* AHE: 03.06.96 - E
* AHE: 19.03.98 - A (4.0c)
* 2 neue Felder
             TMALG-FACIN,
             TMALG-SHELF,
* AHE: 19.03.98 - E
* AHE: 07.01.99 - A (4.6a)
* 5 neue Felder
             TMALG-LMVER,
             TMALG-FRONT,
             TMALG-SHQNM,
             TMALG-SHQNO,
             TMALG-PREQN,
* AHE: 07.01.99 - E
             TMALG-HPLGR.
      MODIFY TMALG INDEX PG_AKT_ZEILE. " zum Löschen vorgemerkt
*     dieses CLEAR entspricht dem Löschen von Hand ohne Löschbutton
      TMALG_CHECK = X.   " Prüfung "Tabelle bereinigen" anstoßen

    ENDIF.
  ENDIF.

ENDMODULE.                             " OKCODE_PGDE  INPUT


*&---------------------------------------------------------------------*
*&      Module  DUB_DEL_PG  INPUT
*&---------------------------------------------------------------------*
*       zu löschende und doppelt eingetragene Sätze werden aus der
*       internen Tabelle entfernt.
*       Außerdem werden die evtl. gesetzten KZ HPLGR gelöscht für die
*       Mengeneinheiten, die keine Plazierungsgruppen zugeordnet haben.
*       Falls zu einer Mengeneinheit die letzte Pl.Grp. gelöscht werden
*       soll, wird dieser Satz nicht aus der Tabelle gelöscht, sondern
*       nur das Feld für die Plazierungsgruppe initialisiert. Grund:
*       Man muß die Möglichkeit haben, auch zu einer Mengeneinheit, die
*       noch keine Pl.Grp. zugeordnet hat (entweder nach Löschen der
*       letzten Pl.Grp. oder sie hatte noch keine Pl.Grp.), Pl.Grp.'s
*       zu erfassen (Vorblendtechnik).
*----------------------------------------------------------------------*
MODULE DUB_DEL_PG INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Wenn nicht per Button (per OKCODE) gelöscht wird, dann CHECK auf
* BILDFLAG. FLAG_DEL_PG ist gesetzt, wenn OKCODE mit "PGDE" belegt.
* Das Module DUB_DEL_PG hier muß beim Löschen
* ablaufen, darf dies aber bei einem vorausgegangenen Fehler nicht tun
* (dann ist das Bildflag gesetzt).
  IF FLAG_DEL_PG IS INITIAL.
    CHECK BILDFLAG IS INITIAL.
  ENDIF.

  CLEAR: HILFS_LAYGR, HILFS_MEEIN_PG.

* TMALG_CHECK ist nur gesetzt, wenn das BILDFLAG initial ist.
  IF NOT TMALG_CHECK IS INITIAL.
*   TMALG ist noch zu bereinigen. D.h.: die "gelöschten"
*   (Feld LAYGR wurde initialisiert) oder
*   doppelt eingetragenen Sätze werden aus der Tabelle gelöscht.
*   Außerdem werden für MEINHs ohne Pl.Grp.'s die KZ HPLGR gelöscht, da
*   eine nicht vorhandene Pl.Grp. keine Haupt-Plazierungsgruppe
*   sein kann.

    LOOP AT TMALG.
      HTABIX  = SY-TABIX + 1.
*     Fall: Löschen
      IF TMALG-LAYGR IS INITIAL.
*       wenn LAYGR hier noch initial, dann soll gelöscht werden
        IF NOT TMALG-HPLGR IS INITIAL.
*         Fall: Mengeneinheit ohne Pl.Grp. --> HPLGR wird zurückgesetzt
          CLEAR TMALG-HPLGR.
          MODIFY TMALG.
        ENDIF.
        CLEAR TMALG_BUF.
        READ TABLE TMALG INDEX HTABIX INTO TMALG_BUF.
*       Falls ein weiterer Satz zur selben Mengeneinheit existiert, kann
*       gelöscht werden, ansonsten bleibt der Satz mit dem initialen
*       Feld LAYGR bestehen. Bem.: Die Einträge mit den leeren Pl.Grp.'s
*       zu einer Mengeneinheit stehen immer VOR denjenigen mit gefüllter
*       Plazierungsgruppe (wegen Sortierung);
        IF TMALG_BUF-MEINH EQ TMALG-MEINH AND
           NOT TMALG-MEINH IS INITIAL. " siehe nächstes IF
          DELETE TMALG.
        ENDIF.
* Fall: Die Mengeneinheit ist leer aber die restl. Felder sollen mit
* Löschbutton gelöscht werden.
        IF TMALG-MEINH IS INITIAL.
          DELETE TMALG.
        ENDIF.
      ENDIF.

*     Fall: Doppelter Eintrag ( zu einer Mengeneinheit wurde die selbe
*     Plazierungsgruppe mehrfach erfaßt);
      IF  ( TMALG-LAYGR = HILFS_LAYGR  AND
            NOT TMALG-LAYGR IS INITIAL AND
*           (die "leeren" Pl.Grp.'s werden schon beim Löschen behandelt)
            TMALG-MEINH = HILFS_MEEIN_PG ).
        DELETE TMALG.
      ELSE.
        HILFS_LAYGR    = TMALG-LAYGR.
        HILFS_MEEIN_PG = TMALG-MEINH.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDMODULE.                             " DUB_DEL_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  BILDFLAG_BLAETTERN_PG  INPUT
*&---------------------------------------------------------------------*
* Bildflag wird bei Blätter-Okcode außerhalb in anderen Subscreens
* immer gesetzt, damit beim Blättern keine Warnungen kommen,
* die aus anderen Subscreens herrühren. Ist Blättern für diesen
* Subscreen bestimmt, Bildflag zurücksetzen, damit Prüfungen für
* diesen Subscreen ablaufen können.
*----------------------------------------------------------------------*
MODULE BILDFLAG_BLAETTERN_PG INPUT.

  IF NOT BILDFLAG IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_PGFP OR
       RMMZU-OKCODE = FCODE_PGPP OR
       RMMZU-OKCODE = FCODE_PGNP OR
       RMMZU-OKCODE = FCODE_PGLP OR
       RMMZU-OKCODE = FCODE_PGDE ).
    CLEAR BILDFLAG.
  ENDIF.
* Wenn man auf diesem Subscreen blättert, sollen keine Warnungen aus
* anderen Subscreens hochkommen.

*---Bildflag merken, weil Blättern nicht durchgeführt wird, wenn
*---Bildflag außerhalb gesetzt wurde.
  PG_BILDFLAG_OLD = BILDFLAG.

ENDMODULE.                             " BILDFLAG_BLAETTERN_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  PREPARE_PG  INPUT
*&---------------------------------------------------------------------*
*       Sortiert die interne Tabelle und setzt Flag zum Bereinigen
*       der Tabelle, falls mindestens einmal vorkommt, daß eine
*       Plazierungsgruppe zu einer Mengeneinheit doppelt eingetragen
*       wurde.
*----------------------------------------------------------------------*
MODULE PREPARE_PG INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  CLEAR: HILFS_LAYGR, HILFS_MEEIN_PG.

* Falls doppelte Einträge innerhalb einer Mengeneinheit vorkommen,
* Flag setzen, um TMALG nachzubearbeiten.
* Abfrage ist korrekt, da TMALG sortiert ist nach PLazierungsgruppe
  IF TMALG_CHECK IS INITIAL.
    LOOP AT TMALG.
      IF  ( TMALG-LAYGR = HILFS_LAYGR  AND
            NOT TMALG-LAYGR IS INITIAL AND
            TMALG-MEINH = HILFS_MEEIN_PG ).
        TMALG_CHECK = X.
      ELSE.
        HILFS_LAYGR    = TMALG-LAYGR.
        HILFS_MEEIN_PG = TMALG-MEINH.
      ENDIF.

* Wenn eine MEINH keine Plazierungsgruppe zugeordnet hat, darf auch das
* KZ Haupt-Plazierungsgruppe nicht gesetzt sein -> TMALG wird
* nachbearbeitet.
* --> in Modul CLEAN_MEINH_PG behandelt
      IF TMALG-LAYGR IS INITIAL AND
         NOT TMALG-HPLGR IS INITIAL.
        TMALG_CHECK = X.
      ENDIF.

* evtl. Sparen einiger redundanter Loop-Steps
      IF NOT TMALG_CHECK IS INITIAL.
        EXIT.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDMODULE.                             " PREPARE_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_NEW_MEINH_PG  INPUT
*&---------------------------------------------------------------------*
*       Prüft, ob die evtl. neu eingegebenen Mengeneinheiten
*       schon zum Material / Artikel erfaßt wurden. Nur dann ist
*       ein solcher neuer Eintrag erlaubt.
*----------------------------------------------------------------------*
MODULE CHECK_NEW_MEINH_PG INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
* CHECK BILDFLAG IS INITIAL.

* Wenn nicht per Button (per OKCODE) gelöscht wird, dann CHECK auf
* BILDFLAG. FLAG_DEL_PG ist gesetzt, wenn OKCODE mit "PGDE" belegt.
* Das Module CHECK_NEW_MEINH_PG muß trotz OKCODE "PGDE" ablaufen
* darf dies aber bei einem vorausgegangenen Fehler nicht tun
* (dann ist das Bildflag gesetzt).
  IF FLAG_DEL_PG IS INITIAL.
    CHECK BILDFLAG IS INITIAL.
  ENDIF.

  LOOP AT TMALG.
    HTABIX = SY-TABIX.
    READ TABLE MEINH WITH KEY TMALG-MEINH.

    IF SY-SUBRC NE 0 AND
       NOT TMALG-MEINH IS INITIAL.
      CLEAR RMMZU-OKCODE.
      IF BILDFLAG IS INITIAL.
        BILDFLAG = X.
        PG_FEHLERFLG_ME = X.   " darf nur gesetzt werden, wenn die
                                       " Zeile nicht gelöscht wird
        MESSAGE S758 WITH TMALG-MEINH.
*       Mengeneinheit & zum Material ist nicht gepflegt
      ENDIF.
      TMALG_KEY-MEINH = TMALG-MEINH.   " Zeile merken
      TMALG_KEY-LAYGR = TMALG-LAYGR.

*     Wenn mit Löschbutton versucht wird, die falsche Zeile zu korr.,
*     wird sie gelöscht und das Flag wird zurückgesetzt.
      IF NOT FLAG_DEL_PG IS INITIAL.
        CLEAR PG_FEHLERFLG_ME.
        DELETE TMALG.
      ENDIF.

      EXIT.
    ENDIF.

* wenn die Mengeneinheit noch nicht z. Material erfaßt wurde und nach
* obiger Meldung diese per Hand aus dem Feld gelöscht wird, wird die
* ganze Zeile gelöscht, allerdings nur, wenn die Zeile sonst auch leer
* ist. Wenn schon Eingaben in der Zeile vorhanden sind, wird eine
* Message ausgegeben.
    IF FLAG_DEL_PG IS INITIAL AND
       TMALG-MEINH IS INITIAL.

      IF TMALG-LAYGR IS INITIAL.
        CLEAR PG_FEHLERFLG_ME.
        DELETE TMALG.
      ELSE.                            " Plazierungsgruppe belegt
        CLEAR RMMZU-OKCODE.
        IF BILDFLAG IS INITIAL.
          BILDFLAG = X.
          PG_FEHLERFLG_ME = X.
          MESSAGE S578.
*       Bitte Mengeneinheit angeben
        ENDIF.
        TMALG_KEY-MEINH = TMALG-MEINH. " Zeile merken
        TMALG_KEY-LAYGR = TMALG-LAYGR.
        EXIT.
      ENDIF.

    ENDIF.

  ENDLOOP.

* restliche evtl. vorhandene Einträge zur nicht erlaubten Mengeneinheit
* rauslöschen.
* IF NOT TMALG_KEY-MEINH IS INITIAL.
*   LOOP AT TMALG WHERE MEINH = TMALG_KEY-MEINH.
*     DELETE TMALG.
*   ENDLOOP.
* ENDIF.

ENDMODULE.                             " CHECK_NEW_MEINH_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  ZEILE_ERMITTELN_PG  INPUT
*&---------------------------------------------------------------------*
MODULE ZEILE_ERMITTELN_PG INPUT.

  IF SY-STEPL = 1.
    CLEAR PG_FEHLERFLG.
  ENDIF.

*  Akt. Tabellenzeile ermitteln
  PG_AKT_ZEILE = PG_ERSTE_ZEILE + SY-STEPL.

ENDMODULE.                             " ZEILE_ERMITTELN_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  INIT_PG  INPUT
*&---------------------------------------------------------------------*
*       Initialisiert diverse Flags
*----------------------------------------------------------------------*
MODULE INIT_PG INPUT.

  CLEAR: PG_FEHLERFLG_ME, PG_FEHLERFLG, TMALG_KEY.
* Initialisieren von Fehlerflags und Key zum merken der Zeile mit Fehler

ENDMODULE.                             " INIT_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  CLEAN_MEINH_PG  INPUT
*&---------------------------------------------------------------------*
*       Löscht die Einträge zu denjenigen Mengeneinheiten, für die
*       außer der Mengeneinheit nichts erfaßt wurde, wieder raus,
*       damit keine "leeren" Sätze auf die DB gelangen
*----------------------------------------------------------------------*
MODULE CLEAN_MEINH_PG INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  LOOP AT TMALG.
    IF NOT TMALG-MEINH IS INITIAL AND
*      TMALG-HPLGR     IS INITIAL AND
       TMALG-LAYGR     IS INITIAL.
      DELETE TMALG.
    ENDIF.
  ENDLOOP.

ENDMODULE.                             " CLEAN_MEINH_PG  INPUT


*&---------------------------------------------------------------------*
*&      Module  BELEGEN_TMALG  INPUT
*&---------------------------------------------------------------------*
*       Übernahme Daten aus Dynpro in Step-Loop Tabelle TMALG
*----------------------------------------------------------------------*
MODULE BELEGEN_TMALG INPUT.

  PERFORM TMALG_AKT.                   " aktualisieren der TMALG

ENDMODULE.                             " BELEGEN_TMALG  INPUT


*&---------------------------------------------------------------------*
*&      Module  SORT_MALG  INPUT
*&---------------------------------------------------------------------*
MODULE SORT_MALG INPUT.

  SORT TMALG BY MEINH LAYGR.
* Sortierung für verschiedene Konsistenzchecks benötigt

ENDMODULE.                             " SORT_MALG  INPUT


*&---------------------------------------------------------------------*
*&      Module  MALG_LAYGR  INPUT
*&---------------------------------------------------------------------*
*       Für Grunddatenbild "interne Logistikdaten"
*       Hauptplazierungsgruppe für Basismengeneinheit updaten
*----------------------------------------------------------------------*
MODULE MALG_LAYGR INPUT.

* AHE: 11.06.97 - A zu 1.2B2
* CHECK BILDFLAG IS INITIAL.
* muß rausgenommen werden wegen Fall: M3818 als 'W' konfiguriert, welche
* genau 1 mal als S-Meldung mit gesetztem Bildflag ausgegeben wird.
* Layoutbaustein würde dann nicht übernommen.
* AHE: 11.06.97 - E

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  READ TABLE TMALG WITH KEY MEINH = MARA-MEINS
                            HPLGR = X.

* Hier wird immer die  Haupt-Plazierungsgruppe zur Basismengeneinheit
* bearbeitet.
* Liest den ersten Satz mit diesem Key. Dieser kommt höchstens einmal
* vor (wird auf Zusatzbild f. Plazierungsgrupppen sichergestellt).

  IF SY-SUBRC = 0.
    IF MALG-LAYGR IS INITIAL.          " Eintrag wurde gelöscht
* AHE: 03.06.96 - A
      CLEAR MALG-SORF1.                " muß dann auch leer sein
* AHE: 03.06.96 - E
      CLEAR TMALG.
      DELETE TMALG INDEX SY-TABIX.
      READ TABLE TMALG WITH KEY MEINH = MARA-MEINS.
      IF SY-SUBRC = 0.
*        Es gibt noch einen weiteren Eintrag zur Basismengeneinheit, der
*        dann als Hauptplazierungsgruppe genommen wird. Es wird der
*        erste markiert, der gefunden wird.
        TMALG-HPLGR = X.
        MODIFY TMALG INDEX SY-TABIX.
      ENDIF.
    ELSE.
      TMALG-LAYGR = MALG-LAYGR.        " Eintrag wurde geändert
* AHE: 03.06.96 - A
      TMALG-SORF1 = MALG-SORF1.
* AHE: 03.06.96 - E
      MODIFY TMALG INDEX SY-TABIX.     " = Satz mit gesetzten HPLGR
*      Test, ob nicht schon ein Eintrag mit der neuen LAYGR vorhanden
      READ TABLE TMALG WITH KEY MEINH = MARA-MEINS
                                LAYGR = MALG-LAYGR
                                HPLGR = SPACE.
      IF SY-SUBRC = 0.
*        rauslöschen, sonst ist die LAYGR doppelt erfaßt zur MEINH
        DELETE TMALG INDEX SY-TABIX.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR TMALG.                       " Eintrag neu
    TMALG-MANDT = SY-MANDT.
    TMALG-MATNR = RMMG1-MATNR.
    TMALG-MEINH = MARA-MEINS.
    TMALG-LAYGR = MALG-LAYGR.
* AHE: 03.06.96 - A
    IF NOT MALG-LAYGR IS INITIAL.
      TMALG-SORF1 = MALG-SORF1.
    ENDIF.
* AHE: 03.06.96 - E
    TMALG-HPLGR = X.
    APPEND TMALG.
    SORT TMALG BY MEINH LAYGR.
  ENDIF.

ENDMODULE.                             " MALG_LAYGR  INPUT
