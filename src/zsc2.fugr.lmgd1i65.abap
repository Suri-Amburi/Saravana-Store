*&---------------------------------------------------------------------*
*&      Module  CHECK_LFEAN  INPUT
*&---------------------------------------------------------------------*
*       Zu einer Mengeneinheit muß genau eine Haupt-EAN-Lief vorhanden
*       sein, wenn es einen Lieferantenbezug gibt.
*----------------------------------------------------------------------*
MODULE CHECK_LFEAN INPUT.

  DATA LS_MLEA LIKE MLEA.                                  "note 1085078

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
*                           MEINH =
                            LIFNR = RMMW2_LIEF        BINARY SEARCH.
*                           EAN11 =
  IF SY-SUBRC = 0.
*   Es existiert ein Lieferantenbezug
    SORT TMLEA BY MATNR LIFNR MEINH.
*   Umsortieren, damit erster Eintrag zum Lieferant gefunden wird.
*   Nochmal lesen zum Positionieren.
    READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
*                             MEINH =
                              LIFNR = RMMW2_LIEF        BINARY SEARCH.
*                             EAN11 =
    HTABIX = SY-TABIX.

    CLEAR: HILFS_MEEIN, HILFS_EAN, MLEA_LFEAN_KEY.

    ZAEHLER = 1.   " Zaehler für Anzahl Kz Haupt-EAN pro Mengeneinheit

*   Voraussetzung: Tabelle ist sortiert nach MATNR, LIFNR, MEINH
    LOOP AT TMLEA FROM HTABIX.
      IF TMLEA-MATNR NE RMMW1_MATN OR
         TMLEA-LIFNR NE RMMW2_LIEF.
        EXIT.
      ENDIF.

*   Der Zähler wurde vor dem  Loop auf 1 ( = alles O.K.) gesetzt,
*   für den Fall, daß die erste MEINH untersucht wird.
      CASE ZAEHLER.
        WHEN 0.                     " evtl. Fehlerfall: keine Haupt-EAN
          IF HILFS_MEEIN NE TMLEA-MEINH.
*           Wechsel MEINH und bei voriger MEINH keine Haupt-EAN
*           CLEAR RMMZU-OKCODE.

*           note 1085078: set LFEAN for single MLEA entries
            IF ZAEHLER2 = 1.
*             get previous TMLEA entry to set LFEAN
              READ TABLE TMLEA INTO LS_MLEA
                               WITH KEY MATNR = RMMW1_MATN
                                        LIFNR = RMMW2_LIEF
                                        MEINH = HILFS_MEEIN
                                        BINARY SEARCH.
              LS_MLEA-LFEAN = 'X'.
              MODIFY TMLEA INDEX SY-TABIX FROM LS_MLEA.

*             Wechsel MEINH und vorige MEINH now O.K.
              ZAEHLER = 0.
              ZAEHLER2 = 1.

              IF NOT TMLEA-LFEAN IS INITIAL.
*             schon für 1. Eintrag der neuen MEINH Haupt-EAN gefunden
                ZAEHLER = ZAEHLER + 1.
              ENDIF.
              HILFS_MEEIN = TMLEA-MEINH. " neue MEINH merken
              HILFS_EAN   = TMLEA-EAN11. " erste neue EAN merken
              CONTINUE.
            ENDIF.

            IF RMMZU-OKCODE NE FCODE_EAFP AND
               RMMZU-OKCODE NE FCODE_EAPP AND
               RMMZU-OKCODE NE FCODE_EANP AND
               RMMZU-OKCODE NE FCODE_EALP.
*               Blättern muß hier ausnahmsweise erlaubt werden, um den
*               Fehler ggf. auf einer anderen Seite korr. zu können.
              CLEAR RMMZU-OKCODE.
            ENDIF.
            IF BILDFLAG IS INITIAL.
              BILDFLAG = X.
              EAN_FEHLERFLG_LFEAN = X.
              MESSAGE S159(MH) WITH RMMW2_LIEF HILFS_MEEIN.
*               keine Haupt-EAN-Lief gesetzt
*               TMLEA-Satz merken wegen Cursorpositionierung
              MLEA_LFEAN_KEY-MEINH = HILFS_MEEIN.
              MLEA_LFEAN_KEY-EAN11 = HILFS_EAN.
            ENDIF.
            EXIT.
          ELSE.
*           MEINH unverändert
            IF NOT TMLEA-LFEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.

        WHEN 1.                        " LFEAN eindeutig
          IF HILFS_MEEIN NE TMLEA-MEINH.
*           Wechsel MEINH und vorige MEINH O.K.
            ZAEHLER = 0.

*           note 1085078: to set LFEAN for single MLEA entries
            ZAEHLER2 = 0.

            IF NOT TMLEA-LFEAN IS INITIAL.
*             schon für 1. Eintrag der neuen MEINH Haupt-EAN gefunden
              ZAEHLER = ZAEHLER + 1.
            ENDIF.
            HILFS_MEEIN = TMLEA-MEINH. " neue MEINH merken
            HILFS_EAN   = TMLEA-EAN11. " erste neue EAN merken
          ELSE.
*           MEINH unverändert
            IF NOT TMLEA-LFEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.

        WHEN OTHERS.                   " Fehlerfall: mehrere Haupt-EAN
          IF HILFS_MEEIN NE TMLEA-MEINH.
*            Wechsel MEINH und bei voriger MEINH mehrere Haupt-EAN
*             CLEAR RMMZU-OKCODE.
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
              EAN_FEHLERFLG_LFEAN = X.
              MESSAGE S898 WITH RMMW2_LIEF HILFS_MEEIN.
*               Die Haupt-EAN zur MEINH ist nicht eindeutig
*               TMLEA-Satz merken wegen Cursorpositionierung
              MLEA_LFEAN_KEY-MEINH = HILFS_MEEIN.
              MLEA_LFEAN_KEY-EAN11 = HILFS_EAN.
            ENDIF.
            EXIT.
          ELSE.
*           MEINH unverändert
            IF NOT TMLEA-LFEAN IS INITIAL.
              ZAEHLER = ZAEHLER + 1.   " Haupt-EAN gefunden
            ENDIF.
          ENDIF.
      ENDCASE.
      ZAEHLER2 = ZAEHLER2 + 1. "note1085078: count MLEA of current uom
    ENDLOOP.

* Auswertung der letzten MEINH nach dem Loop !
    CASE ZAEHLER.
      WHEN 0.                          " Fehlerfall: keine Haupt-EAN
*        bei letzter MEINH keine Haupt-EAN
*         CLEAR RMMZU-OKCODE.

*       note 1085078: set LFEAN for single MLEA entries
        IF ZAEHLER2 = 1.
*         get previous TMLEA entry to set LFEAN
          READ TABLE TMLEA INTO LS_MLEA
                           WITH KEY MATNR = RMMW1_MATN
                                    LIFNR = RMMW2_LIEF
                                    MEINH = HILFS_MEEIN
                                    BINARY SEARCH.
          LS_MLEA-LFEAN = 'X'.
          MODIFY TMLEA INDEX SY-TABIX FROM LS_MLEA.
        ELSE.

          IF RMMZU-OKCODE NE FCODE_EAFP AND
             RMMZU-OKCODE NE FCODE_EAPP AND
             RMMZU-OKCODE NE FCODE_EANP AND
             RMMZU-OKCODE NE FCODE_EALP.
*             Blättern muß hier ausnahmsweise erlaubt werden, um den
*             Fehler ggf. auf einer anderen Seite korr. zu können.
            CLEAR RMMZU-OKCODE.
          ENDIF.
          IF BILDFLAG IS INITIAL.
            BILDFLAG = X.
            EAN_FEHLERFLG_LFEAN = X.
            MESSAGE S159(MH) WITH RMMW2_LIEF HILFS_MEEIN.
*             Bitte zuerst Haupt-EAN zur MEINH angeben
*             TMLEA-Satz merken wegen Cursorpositionierung
            MLEA_LFEAN_KEY-MEINH = HILFS_MEEIN.
            MLEA_LFEAN_KEY-EAN11 = HILFS_EAN.
          ENDIF.
        ENDIF.

      WHEN 1.                          " HPEAN eindeutig
*         letzte MEINH O.K.

      WHEN OTHERS.                     " Fehlerfall: mehrere Haupt-EAN
*        bei letzter MEINH mehrere Haupt-EAN
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
          MESSAGE S898 WITH RMMW2_LIEF HILFS_MEEIN.
*           Die Haupt-EAN zur MEINH ist nicht eindeutig
*           TMLEA-Satz merken wegen Cursorpositionierung
          MLEA_LFEAN_KEY-MEINH = HILFS_MEEIN.
          MLEA_LFEAN_KEY-EAN11 = HILFS_EAN.
        ENDIF.
    ENDCASE.

*   nochmal zurücksortieren
    SORT TMLEA BY MATNR MEINH LIFNR.

  ENDIF.

ENDMODULE.                             " CHECK_LFEAN  INPUT
