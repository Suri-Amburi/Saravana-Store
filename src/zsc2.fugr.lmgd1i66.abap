*&---------------------------------------------------------------------*
*&      Module  MLEA_LFEAN  INPUT
*&---------------------------------------------------------------------*
*       Updaten der Tabelle TMLEA bezgl. LFEAN - Kennzeichen
*       D.h. bei geändertem KZ: in altem Satz KZ rauslöschen und in
*       neuen Satz aufnehmen.
*----------------------------------------------------------------------*
MODULE MLEA_LFEAN INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  CLEAR: FLAG_NEW_LFEAN, FLAG_LFEAN.

  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
*                           MEINH = MEAN_ME_TAB-MEINH
                            LIFNR = RMMW2_LIEF        BINARY SEARCH.
*                           EAN11 = MEAN_ME_TAB-EAN11 BINARY SEARCH.
  IF SY-SUBRC = 0.
* es gibt Lieferantenbezug zu diesem Material
* Wegen Sort nach Matnr, Meinh, Lifnr, EAN11 neu positionieren !!
    READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN BINARY SEARCH.
*                             MEINH = MEAN_ME_TAB-MEINH
*                             LIFNR = RMMW2_LIEF
*                             EAN11 = MEAN_ME_TAB-EAN11 BINARY SEARCH.
*   Lesen geht hier zwangsläufig immer gut !
    HTABIX = SY-TABIX.

    IF NOT MLEA_LFEAN_KEY-MEINH IS INITIAL AND
       NOT MLEA_LFEAN_KEY-EAN11 IS INITIAL.
*     Lieferanten Haupt-EAN befindet sich auf der aktuellen Seite und
*     wurde evtl. umgesetzt.

      FLAG_NEW_LFEAN = X.

      LOOP AT TMLEA FROM HTABIX.
        IF TMLEA-MATNR NE RMMW1_MATN.
          EXIT.
        ENDIF.
        IF NOT TMLEA-LFEAN IS INITIAL   AND
               TMLEA-LIFNR = RMMW2_LIEF.
*       alter Haupt-EAN-Lief gefunden
          IF TMLEA-MEINH NE MLEA_LFEAN_KEY-MEINH OR
             TMLEA-EAN11 NE MLEA_LFEAN_KEY-EAN11.
*            Haupt-EAN-Lief hat sich geändert. -> alter Eintrag löschen
            CLEAR TMLEA-LFEAN.
            MODIFY TMLEA.
            EXIT.
          ELSE.
*           Haupt-EAN-Lief hat sich nicht geändert
            CLEAR FLAG_NEW_LFEAN.
            FLAG_LFEAN = X.            " Haupt-EAN-Lief ist gesetzt !
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF NOT FLAG_NEW_LFEAN IS INITIAL.
*       neues KZ Haupt-EAN-Lief ist noch in TMLEA einzutragen
        READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                                  MEINH = MLEA_LFEAN_KEY-MEINH
                                  LIFNR = RMMW2_LIEF
                                  EAN11 = MLEA_LFEAN_KEY-EAN11
                                  BINARY SEARCH.
        IF SY-SUBRC = 0.
*       sollte hier immer so sein !
          TMLEA-LFEAN = X.
          MODIFY TMLEA INDEX SY-TABIX.
          FLAG_LFEAN = X.              " Haupt-EAN-Lief ist gesetzt !
        ENDIF.
      ENDIF.
    ENDIF.

* Test, ob in TMLEA ein Haupt-EAN-Lief gesetzt ist !
    IF FLAG_LFEAN IS INITIAL.       " noch kein Haupt-EAN-Lief gesetzt ?
      LOOP AT TMLEA FROM HTABIX.
        IF TMLEA-MATNR NE RMMW1_MATN.
          EXIT.
        ENDIF.
        IF NOT TMLEA-LFEAN IS INITIAL   AND
               TMLEA-LIFNR = RMMW2_LIEF.
          FLAG_LFEAN = X.              " Haupt-EAN-Lief ist gesetzt !
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF FLAG_LFEAN IS INITIAL.
*   Kennzeichen Haupt-EAN-Lief ist zum aktuellen Lieferanten nicht
*   gesetzt.
*     CLEAR RMMZU-OKCODE.
      IF RMMZU-OKCODE NE FCODE_EAFP AND
         RMMZU-OKCODE NE FCODE_EAPP AND
         RMMZU-OKCODE NE FCODE_EANP AND
         RMMZU-OKCODE NE FCODE_EALP.
*        Blättern muß hier ausnahmsweise erlaubt werden, um den
*        Fehler ggf. auf einer anderen Seite korrigieren zu können.
        CLEAR RMMZU-OKCODE.
      ENDIF.
      IF BILDFLAG IS INITIAL.
        BILDFLAG = X.
*       EAN_FEHLERFLG = X.       " hier nicht benötigt
*       MESSAGE S898 WITH RMMW2_LIEF.
      ENDIF.
      EXIT.
    ENDIF.

  ENDIF.

ENDMODULE.                             " MLEA_LFEAN  INPUT
