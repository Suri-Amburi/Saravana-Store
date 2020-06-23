*&---------------------------------------------------------------------*
*&      Module  ANZEIGEN_EAN_ZUS OUTPUT
*&---------------------------------------------------------------------*
*    Ermitteln Anzahl Einträge.
*    Fuellen der Loop-Zeile mit den Daten aus der internen Tabelle
*----------------------------------------------------------------------*
MODULE ANZEIGEN_EAN_ZUS OUTPUT.

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
* alt:  MEAN-EAN11 = MEAN_ME_TAB-EAN11.
* alt:  MEAN-EANTP = MEAN_ME_TAB-NUMTP.
    MEAN-EAN11   = MEAN_ME_TAB-EAN11.
    MEAN-EANTP   = MEAN_ME_TAB-NUMTP.
    MEAN-HPEAN   = MEAN_ME_TAB-HPEAN.
    SMEINH-MEINH = MEAN_ME_TAB-MEINH.
* Start: Segment Column addition
    MEAN-SGT_CATV = MEAN_ME_TAB-SGT_CATV.
* End
*   Lesen der Bezeichnungen für die Mengeneinheiten nach T006A-MSEHT
*   Hier wird nicht mit der Ausblendtechnik (FELDBEZTAB) gearbeitet,
*   da nicht notwendig.
    CALL FUNCTION 'ZUS_EAN_READ_DESCRIPTION'
      EXPORTING
        P_MEAN_MEINH = MEAN_ME_TAB-MEINH
      IMPORTING
        WT006A       = T006A     " T006A-MSEHT belegt
      EXCEPTIONS
        OTHERS       = 1.

* AHE: 30.05.96 - A
    IF NOT RMMG2-FLG_RETAIL IS INITIAL.
* Retail-Fall: EAN-Lieferantenbezug-Handling

* Lieferantenzuordnung für aktuellen Lieferanten anzeigen
      READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                                MEINH = MEAN_ME_TAB-MEINH
                                LIFNR = RMMW2_LIEF
                                EAN11 = MEAN_ME_TAB-EAN11 BINARY SEARCH.
      IF SY-SUBRC = 0.
*     Es existiert eine Lieferantenzuordnung für diese EAN und
*     den aktuellen Lieferanten (falls Lief noch nicht spezifiziert:
*     Abfrage auch O.K.);
        RMMZU-LIEFZU  = X.
        MLEA-LFEAN = TMLEA-LFEAN.  " falls in MLEA Haupt-Lief gesetzt...
* AHE: 27.01.99 - A (4.6a)
* neues Feld MLEA-LARTN
        IF NOT MLEA-LFEAN IS INITIAL.
*       Lieferantenartikelnummer nur bei Haupt-EANs
          MLEA-LARTN = TMLEA-LARTN.
        ENDIF.
* AHE: 27.01.99 - E
      ELSE.
        CLEAR MLEA-LFEAN.              " KZ-Haupt-Lief löschen
* AHE: 27.01.99 - A (4.6a)
        CLEAR MLEA-LARTN.
* AHE: 27.01.99 - E
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
*           Es existiert eine Lieferantenzuordnung für diese EAN und
*           einen anderen Lieferanten.
            RMMZU-LIEFBEZ = X.         " nur Anzeigefeld !
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

* AHE: 23.08.96 - A
* Fehler bei Haupt-EAN-Lief KZ (nicht eindeutig oder keins angegeben).
      IF NOT EAN_FEHLERFLG_LFEAN IS INITIAL       AND
         MLEA_LFEAN_KEY-MEINH = MEAN_ME_TAB-MEINH.          "AND
*        MLEA_LFEAN_KEY-EAN11 = MEAN_ME_TAB-EAN11.
        PERFORM EAN_SET_ZEILE_LFEAN.
      ENDIF.
* AHE: 23.08.96 - E

    ENDIF.
* AHE: 30.05.96 - E

* Cursor positionieren und hervorheben der Zeile, falls im vorherigen
* PAI ein Fehler (S-Meldung) ausgegeben wurde.
* Der Fehler bezieht sich dann auf das KZ HPEAN !
    IF NOT EAN_FEHLERFLG IS INITIAL           AND
       MEAN_TAB_KEY-MEINH = MEAN_ME_TAB-MEINH. " AND
*      MEAN_TAB_KEY-EAN11 = MEAN_ME_TAB-EAN11.
      PERFORM EAN_SET_ZEILE.
    ENDIF.

  ENDIF.

ENDMODULE.                             " ANZEIGEN_EAN_ZUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MLEA_GET_SUB  OUTPUT
*&---------------------------------------------------------------------*
*       Relevant data for the screen is read from the buffer for each  *
*       function group, and set in an intermediate buffer              *
*----------------------------------------------------------------------*
MODULE MLEA_GET_SUB OUTPUT.

  PERFORM MLEA_GET_SUB IN PROGRAM (GV_PROG) IF FOUND.

ENDMODULE.                 " MLEA_GET_SUB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MLEA_SET_SUB  OUTPUT
*&---------------------------------------------------------------------*
*       Any data changes are checked and retured to intermediate buffer*
*----------------------------------------------------------------------*
MODULE MLEA_SET_SUB OUTPUT.

  PERFORM MLEA_SET_SUB IN PROGRAM (GV_PROG) IF FOUND.

ENDMODULE.                 " MLEA_SET_SUB  OUTPUT
