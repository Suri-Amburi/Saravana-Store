*------------------------------------------------------------------
*                  Setzen_Nachricht
*
*Eintraege mit DELFLG werden geloescht.
*Pruefen der Eintraege auf doppelte Schluessel, falls ein neuer
*Eintrag hinzugefuegt wurde.
*Setzen haengende Nachricht, falls doppelte Schluessel vorkommen.
*Lesen des 1. Kurztextes in der internen Tabelle. Wenn kein Kurztext
*vorhanden ist, Ausgabe einer hängenden Nachricht.
*Lesen des Textes zur Anmeldesprache. Ist dieser nicht vorhanden,
*Setzen Fehlerflag.
*------------------------------------------------------------------
MODULE SETZEN_NACHRICHT.

* CHECK ( TRAEGER_PROGRAMM NE MAIN_PGM AND            unnötig geworden !
*         TRAEGER_DYNPRO NE KTEXT_DYNP     ) OR            "
*       ( SY-REPID = MAIN_PGM AND                          "
*         SY-DYNNR = KTEXT_DYNP     ).                     "

  CLEAR KT_FEHLERFLG.

  LOOP AT KTEXT.

*-----Loeschen Eintrag, falls delflg sitzt--------------------------
    IF KTEXT-DELFLG NE SPACE.
      DELETE KTEXT.

*-----Pruefen auf doppelten Eintrag---------------------------------
    ELSE.
      IF KTEXT-DOPFLG NE SPACE
                                   AND BILDFLAG_OLD IS INITIAL.
        PERFORM PRUEFEN_DOPEINTRAG.
      ENDIF.
    ENDIF.
  ENDLOOP.

*-----Ausgeben Fehlernachricht bei doppelten Eintraegen-------------
  IF KT_FEHLERFLG = FDSPRACH.
    IF NOT SY-BINPT IS INITIAL OR NOT SY-BATCH IS INITIAL.
      MESSAGE E321 WITH KT_SAVSPRAS.
    ENDIF.
*    clear rmmzu-okcode. "not needed (at least in retail) wk to 4.0
    IF BILDFLAG_OLD IS INITIAL.
      BILDFLAG = X.
      MESSAGE S321 WITH KT_SAVSPRAS.
    ENDIF.
  ENDIF.

  READ TABLE KTEXT INDEX 1.
*----- Eintrag vorhanden --------------------------------
  IF SY-SUBRC = 0.
    KT_LINES = SY-TFILL.
    IF RMMG2-FLG_RETAIL IS INITIAL OR RMMW2-VARNR IS INITIAL. "wk to 4.0
      MOVE-CORRESPONDING KTEXT TO MAKT.
    ELSE.
      RMMW1_BEZ-VARTX = KTEXT-MAKTX.
    ENDIF.
    IF KTEXT-SPRAS NE SY-LANGU.
      READ TABLE KTEXT WITH KEY SY-LANGU.
      IF SY-SUBRC EQ 0.
*---- Eintrag zur Anmeldesprache vorhanden ------------
        IF RMMG2-FLG_RETAIL IS INITIAL OR RMMW2-VARNR IS INITIAL.
          MOVE-CORRESPONDING KTEXT TO MAKT.
        ELSE.
          RMMW1_BEZ-VARTX = KTEXT-MAKTX.
        ENDIF.
        RMMG1-SPRAS = SY-LANGU.
      ELSE.
        RMMG1-SPRAS = KTEXT-SPRAS.
      ENDIF.
    ELSE.
      RMMG1-SPRAS = SY-LANGU.
    ENDIF.
  ELSE.
*-----kein Eintrag vorhanden --------------------------------------
    IF NOT SY-BINPT IS INITIAL OR NOT SY-BATCH IS INITIAL.
      MESSAGE E325.
    ENDIF.
    RMMG1-SPRAS = SY-LANGU.
    KT_LINES = 0.
*    clear rmmzu-okcode. "not needed (at least retail) copied wk to 4.0
    IF RMMG2-FLG_RETAIL IS INITIAL OR RMMW2-VARNR IS INITIAL.
      CLEAR MAKT-MAKTX.
    ELSE.
      CLEAR RMMW1_BEZ-VARTX.
    ENDIF.
    KT_FEHLERFLG = FKEINTRAG.
    KT_ZEILEN_NR = 1.
    CHECK BILDFLAG_OLD IS INITIAL.
    BILDFLAG = X.
    MESSAGE S325.
  ENDIF.
** change tc wk to 4.0
  IF NOT FLG_TC IS INITIAL.
    TC_KTXT-LINES = KT_LINES.
  ENDIF.
ENDMODULE.
