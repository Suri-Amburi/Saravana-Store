*&---------------------------------------------------------------------*
*&      Module  CHECK_HPEAN  INPUT
*&---------------------------------------------------------------------*
*       Zu einer Mengeneinheit muß genau eine Haupt-EAN vorhanden
*       sein, falls mindestens eine EAN zu einer Mengeneinheit
*       existiert.
*----------------------------------------------------------------------*
MODULE CHECK_HPEAN INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

* AHE: 13.02.97 - A
* Automatisches Setzen der Haupt-EAN zu einer Mengeneinheit, wenn keine
* EAN markiert ist.
  DO.
    CLEAR TMEAN_CORR.
* AHE: 13.02.97 - E
    CLEAR: HILFS_MEEIN, HILFS_EAN, MEAN_TAB_KEY.

    ZAEHLER = 1.   " Zaehler für Anzahl Kz Haupt-EAN pro Mengeneinheit

* Voraussetzung: Tabelle ist sortiert !
    LOOP AT MEAN_ME_TAB.
*  Der Zähler wurde vor dem  Loop auf 1 ( = alles O.K.) gesetzt,
*  für den Fall, daß die erste MEINH untersucht wird.
      CASE ZAEHLER.
        WHEN 0.                     " evtl. Fehlerfall: keine Haupt-EAN
          IF HILFS_MEEIN NE MEAN_ME_TAB-MEINH.
*            Wechsel MEINH und bei voriger MEINH keine Haupt-EAN
            IF NOT HILFS_EAN IS INITIAL.
*             Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
*             Es kann nicht vorkommen, daß mehr als eine leere EAN
*             für eine MEINH in der Tabelle existiert.
*           CLEAR RMMZU-OKCODE.
              IF RMMZU-OKCODE NE FCODE_EAFP AND
                 RMMZU-OKCODE NE FCODE_EAPP AND
                 RMMZU-OKCODE NE FCODE_EANP AND
                 RMMZU-OKCODE NE FCODE_EALP.
*              Blättern muß hier ausnahmsweise erlaubt werden, um den
*              Fehler ggf. auf einer anderen Seite korr. zu können.
                CLEAR RMMZU-OKCODE.
              ENDIF.
* AHE: 13.02.97 - A
* automatisches Setzen der Haupt-EAN auf den ersten Eintrag
* zur Mengeneinheit, wenn keine EAN markiert ist anstatt
* der Ausgabe einer Meldung
              TMEAN_CORR-MEINH = HILFS_MEEIN.
              TMEAN_CORR-EAN11 = HILFS_EAN.
*           IF BILDFLAG IS INITIAL.
*             BILDFLAG = X.
*             EAN_FEHLERFLG = X.
*             MESSAGE S535 WITH HILFS_MEEIN.
*             Bitte zuerst Haupt-EAN zur MEINH angeben
*             MEAN_ME_TAB-Satz merken wegen Cursorpositionierung
*             MEAN_TAB_KEY-MEINH = HILFS_MEEIN.
*             MEAN_TAB_KEY-EAN11 = HILFS_EAN.
*          ENDIF.
* AHE: 13.02.97 - E
              EXIT.
            ELSE.                      " Ausnahme: kein Fehlerfall
              HILFS_EAN   = MEAN_ME_TAB-EAN11.
*            Fall: keine Haupt-EAN markiert aber auch keine EAN
*            angegeben --> keine Meldung ausgeben, aber neue EAN merken
*            für evtl. spätere Meldung bzgl. der neuen MEINH.
            ENDIF.
          ELSE.
*           MEINH unverändert
            IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.

        WHEN 1.                        " HPEAN eindeutig
          IF HILFS_MEEIN NE MEAN_ME_TAB-MEINH.
*            Wechsel MEINH und vorige MEINH O.K.
            ZAEHLER = 0.
            IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
*            schon für 1. Eintrag der neuen MEINH Haupt-EAN gefunden
              ZAEHLER = ZAEHLER + 1.
            ELSE.
*           Wenn das Haupt-EAN KZ nicht gesetzt ist und die EAN ist
*           leer, ist trotzdem alles O.K. --> Zähler auf 1 setzen.
              IF MEAN_ME_TAB-EAN11 IS INITIAL.
                ZAEHLER = 1.
              ENDIF.
            ENDIF.
            HILFS_MEEIN = MEAN_ME_TAB-MEINH.    " neue MEINH merken
            HILFS_EAN   = MEAN_ME_TAB-EAN11.    " erste neue EAN merken
          ELSE.
*           MEINH unverändert
            IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.

        WHEN OTHERS.                   " Fehlerfall: mehrere Haupt-EAN
          IF HILFS_MEEIN NE MEAN_ME_TAB-MEINH.
*            Wechsel MEINH und bei voriger MEINH mehrere Haupt-EAN
            IF NOT HILFS_EAN IS INITIAL.
*             Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
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
                EAN_FEHLERFLG = X.
                MESSAGE S714 WITH HILFS_MEEIN.
*             Die Haupt-EAN zur MEINH ist nicht eindeutig
*             MEAN_ME_TAB-Satz merken wegen Cursorpositionierung
                MEAN_TAB_KEY-MEINH = HILFS_MEEIN.
                MEAN_TAB_KEY-EAN11 = HILFS_EAN.
              ENDIF.
              EXIT.
            ENDIF.
          ELSE.
*           MEINH unverändert
            IF NOT MEAN_ME_TAB-HPEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

* Auswertung der letzten MEINH nach dem Loop !
* AHE: 13.02.97 - A
    IF TMEAN_CORR IS INITIAL.
* AHE: 13.02.97 - E
      CASE ZAEHLER.
        WHEN 0.                        " Fehlerfall: keine Haupt-EAN
*        bei letzter MEINH keine Haupt-EAN
          IF NOT HILFS_EAN IS INITIAL.
*          Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
*       CLEAR RMMZU-OKCODE.
            IF RMMZU-OKCODE NE FCODE_EAFP AND
               RMMZU-OKCODE NE FCODE_EAPP AND
               RMMZU-OKCODE NE FCODE_EANP AND
               RMMZU-OKCODE NE FCODE_EALP.
*          Blättern muß hier ausnahmsweise erlaubt werden, um den
*          Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
* AHE: 13.02.97 - A
            TMEAN_CORR-MEINH = HILFS_MEEIN.
            TMEAN_CORR-EAN11 = HILFS_EAN.
*       IF BILDFLAG IS INITIAL.
*         BILDFLAG = X.
*         EAN_FEHLERFLG = X.
*         MESSAGE S535 WITH HILFS_MEEIN.
*         Bitte zuerst Haupt-EAN zur MEINH angeben
*         MEAN_ME_TAB-Satz merken wegen Cursorpositionierung
*         MEAN_TAB_KEY-MEINH = HILFS_MEEIN.
*         MEAN_TAB_KEY-EAN11 = HILFS_EAN.
*       ENDIF.
* AHE: 13.02.97 - E
          ENDIF.

        WHEN 1.                        " HPEAN eindeutig
*         letzte MEINH O.K.

        WHEN OTHERS.                   " Fehlerfall: mehrere Haupt-EAN
*        bei letzter MEINH mehrere Haupt-EAN
          IF NOT HILFS_EAN IS INITIAL.
*          Meldung nur, wenn eine EAN vorhanden (1. wurde gemerkt).
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
              EAN_FEHLERFLG = X.
              MESSAGE S714 WITH HILFS_MEEIN.
*         Die Haupt-EAN zur MEINH ist nicht eindeutig
*         MEAN_ME_TAB-Satz merken wegen Cursorpositionierung
              MEAN_TAB_KEY-MEINH = HILFS_MEEIN.
              MEAN_TAB_KEY-EAN11 = HILFS_EAN.
            ENDIF.
          ENDIF.
      ENDCASE.

* AHE: 13.02.97 - A
    ENDIF.

    IF NOT EAN_FEHLERFLG IS INITIAL.
      CLEAR TMEAN_CORR.
      EXIT.                            " raus aus DO- Schleife
    ELSE.
      IF TMEAN_CORR IS INITIAL.
        EXIT.                          " raus aus DO- Schleife
      ENDIF.
      READ TABLE MEAN_ME_TAB WITH KEY
                             MEINH = TMEAN_CORR-MEINH
                             EAN11 = TMEAN_CORR-EAN11 BINARY SEARCH.
      IF SY-SUBRC = 0.
*   sollte hier immer so sein
        MEAN_ME_TAB-HPEAN = X.
        MODIFY MEAN_ME_TAB INDEX SY-TABIX.
      ENDIF.
    ENDIF.

  ENDDO.
* AHE: 13.02.97 - E

ENDMODULE.                             " CHECK_HPEAN  INPUT
