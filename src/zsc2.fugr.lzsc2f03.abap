*---------------------------------------------------------------------*
*       MODULE OKCODE_BE INPUT                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE OKCODE_BE INPUT.
*wk/4.0 switch to tc
  IF NOT FLG_TC IS INITIAL.
    TC_BON-LINES = BE_LINES.
    BE_ERSTE_ZEILE = TC_BON-TOP_LINE - 1.
    IF TC_BON-TOP_LINE NE TC_BON_TOP_LINE_BUF.
      PERFORM PARAM_SET.
    ENDIF.
  ENDIF.
*
  CASE RMMZU-OKCODE.
    WHEN FCODE_BABA.
      CLEAR KZ_BON_ETI_TEXT_INIT.
    WHEN FCODE_BEDE.
      BILDFLAG = X.        "gleiches Bild nochmal prozessieren
      CLEAR RMMZU-OKCODE.
* JH/04.11.96 (Anfang)
* Coding in eigenes Modul verlagert
*           Test: Cursor auf korrektem Feld?
*           CLEAR DYNPRO_FELD.
*           GET CURSOR FIELD DYNPRO_FELD.
*           IF DYNPRO_FELD NE 'MAMT-SPRAS' AND
*              DYNPRO_FELD NE 'MAMT-MEINH' AND
*              DYNPRO_FELD NE 'MAMT-MTXID' AND
*              DYNPRO_FELD NE 'MAMT-LFDNR' AND "JH/04.11.96 Feld 'Nr'
*              DYNPRO_FELD NE 'MAMT-MAKTM'.    "nicht ausschließen
*                     MESSAGE S115(MH).
*                     EXIT.
*           ENDIF.
*           Test: Cursor auf belegter Zeile?
*           READ TABLE TMAMT_BE INDEX DELETE_ZEILEN_NR.
*           IF SY-SUBRC NE 0.
*              MESSAGE S115(MH).               "JH/04.11.96
*              EXIT.
*           ENDIF.
*           CLEAR SPRAS_ALT.
*           CLEAR MEINH_ALT.
*           CLEAR MTXID_ALT.
*           CLEAR LFDNR_ALT.
*           SPRAS_ALT = TMAMT_BE-SPRAS.
*           MEINH_ALT = TMAMT_BE-MEINH.
*           MTXID_ALT = TMAMT_BE-MTXID.
*           LFDNR_ALT = TMAMT_BE-LFDNR.
*           Eintrag löschen
*           IF SY-SUBRC = 0.
*              DELETE TMAMT_BE INDEX DELETE_ZEILEN_NR.
*           ENDIF.
*           DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
*           Nachfolgende Zeilen bei mehrzeiligem Text verschieben
*           LOOP AT TMAMT_BE WHERE MANDT = SY-MANDT AND
*                                  MATNR = MARA-MATNR AND
*                                  SPRAS = SPRAS_ALT AND
*                                  MEINH = MEINH_ALT AND
*                                  MTXID = MTXID_ALT AND
*                                  LFDNR > LFDNR_ALT.     "#EC PORTABLE
*                    TMAMT_BE-LFDNR = TMAMT_BE-LFDNR - 1.
*                    MODIFY TMAMT_BE.
*                    IF SY-SUBRC = 0.     "JH/04.11.96 Meld. nur einmal
*                       MESSAGE S112(MH). "und nicht pro Durchlauf
*                    ENDIF.
*           ENDLOOP.
*           IF SY-SUBRC = 0.     "JH/04.11.96 Meldung nur einmal
*              MESSAGE S112(MH). "und nicht pro Durchlauf ausgeben
*           ENDIF.
* JH/04.11.96 (Ende)
*----- Erste Seite - KurzText First Page -----------------------------
    WHEN FCODE_BEFP.
      PERFORM FIRST_PAGE USING BE_ERSTE_ZEILE.
*----- Seite vor - KurzText Next Page --------------------------------
    WHEN FCODE_BENP.
      PERFORM NEXT_PAGE USING BE_ERSTE_ZEILE BE_ZLEPROSEITE
                              BE_LINES.
*----- Seite zurueck - KurzText previous Page ------------------------
    WHEN FCODE_BEPP.
      PERFORM PREV_PAGE USING BE_ERSTE_ZEILE BE_ZLEPROSEITE.
*----- Bottom - KurzText Last Page -----------------------------------
    WHEN FCODE_BELP.
      PERFORM LAST_PAGE USING BE_ERSTE_ZEILE BE_LINES
                             BE_ZLEPROSEITE X.
    WHEN FCODE_BEIR.
      BILDFLAG = 'X'.    "gleiches Bild nochmal prozessieren
      CLEAR RMMZU-OKCODE.
* JH/04.11.96 (Anfang)
* Coding bereits in MODULE INSERT_ROW_BE durchlaufen
*           CLEAR DYNPRO_FELD.
*           GET CURSOR FIELD DYNPRO_FELD.
*           IF DYNPRO_FELD NE 'MAMT-SPRAS' AND
*              DYNPRO_FELD NE 'MAMT-MEINH' AND
*              DYNPRO_FELD NE 'MAMT-MTXID' AND
*              DYNPRO_FELD NE 'MAMT-MAKTM'.
*                     MESSAGE S115(MH).
*                     EXIT.
*           ENDIF.
*           GET CURSOR LINE BE_ZEILEN_NR.
*           BE_AKT_ZEILE = BE_ERSTE_ZEILE + BE_ZEILEN_NR.
*           READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
*           IF SY-SUBRC NE 0.
*              MESSAGE S115(MH).
*              EXIT.
*           ENDIF.
* JH/04.11.96 (Ende)
* JH/06.11.96 (Anfang)
* Auf die nächste Seite blättern, falls Insert für die letzte Zeile
* durchgeführt wurde
      IF BE_ZEILEN_NR = BE_ZLEPROSEITE.
        PERFORM NEXT_PAGE USING BE_ERSTE_ZEILE BE_ZLEPROSEITE
                                BE_LINES.
        CURSOR_ZEILEN_NR = INSERT_ROW_ZEILEN_NR - BE_ERSTE_ZEILE + 1.
      ENDIF.
* JH/06.11.96 (Ende)
*----- SPACE - Enter -------------------------------------------------
    WHEN FCODE_SPACE.
* JH/08.01.97/1.2B (Anfang)
* Das Setzen von BILDFLAG muß unterbunden werden, damit die evtl.
* geänderten MAMT-Daten nicht nur in die internen U-Puffertabellen,
* sondern auch in die internen T-Puffertabellen (FGrp MG25) übernommen
* werden, sodaß nach dem Ausführen von 'Enter' und 'Beenden' evtl.
* durchgeführte Änderungen im MATERIAL_CHANGE_CHECK_RETAIL erkannt
* werden können
*         Datenfreigabe auf Zusatzbild heißt Bildwiederholung
*         IF T133A-BILDT EQ '2'.
*            BILDFLAG = X.
*         ENDIF.
* JH/08.01.97/1.2B (Ende)
*         Datenfreigabe auf Hauptbild heißt nächstes Hauptbild
      IF T133A-BILDT EQ '1' AND BILDFLAG IS INITIAL.
        IF FEHLER_BE IS INITIAL.
          CLEAR KZ_BON_ETI_TEXT_INIT.
        ENDIF.
      ENDIF.
* ----------Sonstige Funktionen wie Springen etc.----------------------
    WHEN OTHERS.
      CLEAR KZ_BON_ETI_TEXT_INIT.
  ENDCASE.
ENDMODULE.


*---------------------------------------------------------------------*
*       FORM OKCODE_BT_TEXT                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM OKCODE_BT_TEXT.
  CASE RMMZU-OKCODE.
    WHEN FCODE_BABA.
*    PERFORM SICHERHEITS_POPUP_Bt.  "Später aktivieren unter
                                       "OKCODE 'Abbrechen' aufrufen

    WHEN FCODE_BTFP.                   "First Page
      PERFORM FIRST_PAGE USING BT_ERSTE_ZEILE.

    WHEN FCODE_BTNP.                   "Next Page
      PERFORM NEXT_PAGE USING BT_ERSTE_ZEILE BT_ZLEPROSEITE
                              BT_LINES.

    WHEN FCODE_BTPP.                   "Previous Page
      PERFORM PREV_PAGE USING BT_ERSTE_ZEILE BT_ZLEPROSEITE.

    WHEN FCODE_BTLP.                   "Last Page
      PERFORM LAST_PAGE USING BT_ERSTE_ZEILE BT_LINES
                              BE_ZLEPROSEITE X.

    WHEN FCODE_SPACE.                  "Enter
      IF T133A-BILDT EQ BILDT_Z.       "Datenfreigabe heißt Wiederholen
        BILDFLAG = X.                  "allerdings nur auf Zusatzbild
      ENDIF.

    WHEN FCODE_BTSA.                   "Enter
      BILDFLAG = X.                    "Datenfreigabe heißt Wiederholen
                                       "auch auf Hauptbild, allerdings
                                       "nur wenn geändert wurde

    WHEN FCODE_BTDE.                   "Löschen
      IF MAMT_DEL_KEY NE SPACE.
        READ TABLE TMAMT_BT WITH KEY MAMT_DEL_KEY.
        IF SY-SUBRC = 0.
          DELETE TMAMT_BT INDEX SY-TABIX.
          BT_LINES = BT_LINES - 1.
          BT_UPDATE_KZ = X.
        ENDIF.
      ENDIF.

    WHEN OTHERS.                "Sonstige Funktionen wie Springen etc
      CLEAR KZ_BONTEXT_INIT.
  ENDCASE.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM OKCODE_ET_TEXT                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM OKCODE_ET_TEXT.
  CASE RMMZU-OKCODE.
    WHEN FCODE_BABA.
*    PERFORM SICHERHEITS_POPUP_et.  "Später aktivieren unter
                                       "OKCODE 'Abbrechen' aufrufen

    WHEN FCODE_ETFP.                   "First Page
      PERFORM FIRST_PAGE USING ET_ERSTE_ZEILE.

    WHEN FCODE_ETNP.                   "Next Page
      PERFORM NEXT_PAGE USING ET_ERSTE_ZEILE ET_ZLEPROSEITE
                              ET_LINES.

    WHEN FCODE_ETPP.                   "Previous Page
      PERFORM PREV_PAGE USING ET_ERSTE_ZEILE ET_ZLEPROSEITE.

    WHEN FCODE_ETLP.                   "Last Page
      PERFORM LAST_PAGE USING ET_ERSTE_ZEILE ET_LINES
                              ET_ZLEPROSEITE X.

    WHEN FCODE_SPACE.                  "Enter
      BILDFLAG = X.                    "Datenfreigabe heißt Wiederholen

    WHEN FCODE_ETDE.                   "Löschen
      IF MAMT_DEL_KEY NE SPACE.
        READ TABLE TMAMT_ET WITH KEY MAMT_DEL_KEY.
        IF SY-SUBRC = 0.
          DELETE TMAMT_ET INDEX SY-TABIX.
          ET_LINES = ET_LINES - 1.
          ET_UPDATE_KZ = X.
        ENDIF.
      ENDIF.

    WHEN OTHERS.                "Sonstige Funktionen wie Springen etc
      CLEAR KZ_ETITEXT_INIT.
  ENDCASE.
ENDFORM.


*                   Bon-/Etiketten-Texte prüfen
FORM PRUEFEN_TEXT_EINGABE_BE.
* Prüfen ob ein Eintrag durch überschreiben hinzugefügt werden soll
  IF MAMT-MAKTM NE TMAMT_BE-MAKTM.                          "WG 220496
    IF BE_AKT_ZEILE = SY-TABIX.        "Es wurde der Text eines schon
      TMAMT_BE-MAKTM = MAMT-MAKTM.     "vorhandenen Bon-/Etiketten-
      MODIFY TMAMT_BE INDEX SY-TABIX.  "textes abgeändert --> OK
      BE_UPDATE_KZ = X.
    ELSE.                              "Es wurde ein schon bestehender
      MESSAGE S068(MH).                "Text irgendwo widerholt einge-
    ENDIF.                             "geben
  ELSE.
    MESSAGE S068(MH).
  ENDIF.
ENDFORM.


*                   Bontexte prüfen
FORM PRUEFEN_TEXT_EINGABE_BT.
* Prüfen ob ein Eintrag durch überschreiben hinzugefügt werden soll
  IF MAMT-MAKTM NE TMAMT_BT-MAKTM.                          "WG 220496
    IF BT_AKT_ZEILE = SY-TABIX.        "Es wurde der Text eines schon
      TMAMT_BT-MAKTM = MAMT-MAKTM.     "vorhandenen Etikettentextes ab-
      MODIFY TMAMT_BT INDEX SY-TABIX.  "geändert --> OK
      BT_UPDATE_KZ = X.
    ELSE.                              "Es wurde ein schon bestehender
      MESSAGE S069(MH).                "Text irgendwo widerholt einge-
    ENDIF.                             "geben
  ELSE.
    MESSAGE S069(MH).
  ENDIF.
ENDFORM.


*                   Etikettentexte prüfen
FORM PRUEFEN_TEXT_EINGABE_ET.
* Prüfen ob ein Eintrag durch überschreiben hinzugefügt werden soll
  IF MAMT-MAKTM NE TMAMT_ET-MAKTM.                          "WG 220496
    IF ET_AKT_ZEILE = SY-TABIX.        "Es wurde der Text eines schon
      TMAMT_ET-MAKTM = MAMT-MAKTM.     "vorhandenen Etikettentextes ab-
      MODIFY TMAMT_ET INDEX SY-TABIX.  "geändert --> OK
      ET_UPDATE_KZ = X.
    ELSE.                              "Es wurde ein schon bestehender
      MESSAGE S071(MH).                "Text irgendwo widerholt einge-
    ENDIF.                             "geben
  ELSE.
    MESSAGE S071(MH).
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM PRUEFEN_MUSSFELDER_BE                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM PRUEFEN_MUSSFELDER_BE.
* JH/10.01.97 Altes Coding von Wolfgang G. auskommentiert, da bisher
* nicht benutzt
*RF_INITIAL_BE = 0.
*
*IF NOT MAMT-SPRAS IS INITIAL.
*   RF_INITIAL_BE = RF_INITIAL_BE + 1.
*ENDIF.
*
*IF NOT MAMT-MEINH IS INITIAL.
*   RF_INITIAL_BE = RF_INITIAL_BE + 1.
*ENDIF.
*
*IF NOT MAMT-MTXID IS INITIAL.
*   RF_INITIAL_BE = RF_INITIAL_BE + 1.
*ENDIF.
*
*IF NOT MAMT-LFDNR IS INITIAL.
*   RF_INITIAL_BE = RF_INITIAL_BE + 1.
*ENDIF.
*
*IF NOT MAMT-MAKTM IS INITIAL.
*   RF_INITIAL_BE = RF_INITIAL_BE + 1.
*ENDIF.
*
*IF RF_INITIAL_BE NE 5 AND
*   RF_INITIAL_BE NE 0.
*   MESSAGE E072(MH).
*ENDIF.
* JH/13.10.97 Nachfolgendes Coding ins übergeorsnete MODULE-Coding
* zurückverlagert
* Prüfen ob alle Felder eingegeben wurden, falls aktuelle Zeile nicht
* gelöscht wird
* IF ( RMMZU-OKCODE NE FCODE_BEDE )
* OR ( RMMZU-OKCODE = FCODE_BEDE AND DELETE_ZEILEN_NR NE BE_AKT_ZEILE ).
* Falls mindestens ein Feld belegt ist
*   IF ( NOT MAMT-SPRAS IS INITIAL )
*   OR ( NOT MAMT-MEINH IS INITIAL )
*   OR ( NOT MAMT-MTXID IS INITIAL )
*   OR ( NOT MAMT-MAKTM IS INITIAL ).
* Müssen alle Felder belegt sein
*     IF ( MAMT-SPRAS IS INITIAL )
*     OR ( MAMT-MEINH IS INITIAL )
*     OR ( MAMT-MTXID IS INITIAL )
*     OR ( MAMT-MAKTM IS INITIAL ).
*       MESSAGE E072(MH).
*     ENDIF.
*   ENDIF.
* ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM PRUEFEN_MUSSFELDER_BT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM PRUEFEN_MUSSFELDER_BT.
* Prüfen ob alle Felder eingegeben wurden
  RF_INITIAL_BT = 0.

  IF NOT MAMT-SPRAS IS INITIAL.
    RF_INITIAL_BT = RF_INITIAL_BT + 1.
  ENDIF.

  IF NOT MAMT-MEINH IS INITIAL.
    RF_INITIAL_BT = RF_INITIAL_BT + 1.
  ENDIF.

  IF NOT MAMT-LFDNR IS INITIAL.
    RF_INITIAL_BT = RF_INITIAL_BT + 1.
  ENDIF.

  IF NOT MAMT-MAKTM IS INITIAL.
    RF_INITIAL_BT = RF_INITIAL_BT + 1.
  ENDIF.

  IF RF_INITIAL_BT NE 4 AND
     RF_INITIAL_BT NE 0.
    MESSAGE E072(MH).
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM PRUEFEN_MUSSFELDER_ET                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM PRUEFEN_MUSSFELDER_ET.
* Prüfen ob alle Felder eingegeben wurden
  RF_INITIAL_ET = 0.

  IF NOT MAMT-SPRAS IS INITIAL.
    RF_INITIAL_ET = RF_INITIAL_ET + 1.
  ENDIF.

  IF NOT MAMT-MEINH IS INITIAL.
    RF_INITIAL_ET = RF_INITIAL_ET + 1.
  ENDIF.

  IF NOT MAMT-LFDNR IS INITIAL.
    RF_INITIAL_ET = RF_INITIAL_ET + 1.
  ENDIF.

  IF NOT MAMT-MAKTM IS INITIAL.
    RF_INITIAL_ET = RF_INITIAL_ET + 1.
  ENDIF.

  IF RF_INITIAL_ET NE 4 AND
     RF_INITIAL_ET NE 0.
    MESSAGE E072(MH).
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM SICHERHEITS_POPUP_BE                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM SICHERHEITS_POPUP_BE.
  IF BE_UPDATE_KZ NE SPACE.
    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
              DIAGNOSETEXT1 = TEXT-001
              TEXTLINE1     = TEXT-002
              TEXTLINE2     = TEXT-003
              TITEL         = TEXT-004
         IMPORTING
              ANSWER        = ANTWORT_BE.
    CASE ANTWORT_BE.
      WHEN 'J'.
        BE_UPDATE_KZ = SPACE.
      WHEN 'N'.
        REFRESH TMAMT_BE.
        CLEAR KZ_BON_ETI_TEXT_INIT.
        BE_UPDATE_KZ = SPACE.
      WHEN 'A'.
        CLEAR RMMZU-OKCODE.
        BILDFLAG = X.                  "Abbrechen heißt wiederholen
    ENDCASE.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM SICHERHEITS_POPUP_BT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM SICHERHEITS_POPUP_BT.
  IF BT_UPDATE_KZ NE SPACE.
    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
              DIAGNOSETEXT1 = TEXT-001
              TEXTLINE1     = TEXT-002
              TEXTLINE2     = TEXT-003
              TITEL         = TEXT-004
         IMPORTING
              ANSWER        = ANTWORT_BT.
    CASE ANTWORT_BT.
      WHEN 'J'.
        BT_UPDATE_KZ = SPACE.
      WHEN 'N'.
        REFRESH TMAMT_BT.
        CLEAR KZ_BONTEXT_INIT.
        BT_UPDATE_KZ = SPACE.
      WHEN 'A'.
        CLEAR RMMZU-OKCODE.
        BILDFLAG = X.                  "Abbrechen heißt wiederholen
    ENDCASE.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM SICHERHEITS_POPUP_ET                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM SICHERHEITS_POPUP_ET.
  IF ET_UPDATE_KZ NE SPACE.
    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
              DIAGNOSETEXT1 = TEXT-001
              TEXTLINE1     = TEXT-002
              TEXTLINE2     = TEXT-003
              TITEL         = TEXT-004
         IMPORTING
              ANSWER        = ANTWORT_ET.
    CASE ANTWORT_ET.
      WHEN 'J'.
        ET_UPDATE_KZ = SPACE.
      WHEN 'N'.
        REFRESH TMAMT_ET.
        CLEAR KZ_ETITEXT_INIT.
        ET_UPDATE_KZ = SPACE.
      WHEN 'A'.
        CLEAR RMMZU-OKCODE.
        BILDFLAG = X.                  "Abbrechen heißt wiederholen
    ENDCASE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ERSTE_ZEILE_AENDERN
*&---------------------------------------------------------------------*
FORM ERSTE_ZEILE_AENDERN.

  READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
  CLEAR SPRAS_ALT.
  CLEAR MEINH_ALT.
  CLEAR MTXID_ALT.
  CLEAR SPRAS_NEU.
  CLEAR MEINH_NEU.
  CLEAR MTXID_NEU.

  MOVE TMAMT_BE-SPRAS TO SPRAS_ALT.
  MOVE TMAMT_BE-MEINH TO MEINH_ALT.
  MOVE TMAMT_BE-MTXID TO MTXID_ALT.

  MOVE-CORRESPONDING MAMT TO TMAMT_BE.
  MOVE SY-MANDT TO TMAMT_BE-MANDT.
  MOVE MARA-MATNR TO TMAMT_BE-MATNR.
  MODIFY TMAMT_BE INDEX BE_AKT_ZEILE.
  MOVE TMAMT_BE-SPRAS TO SPRAS_NEU.
  MOVE TMAMT_BE-MEINH TO MEINH_NEU.
  MOVE TMAMT_BE-MTXID TO MTXID_NEU.

  IF TMAMT_BE-SPRAS NE SPRAS_ALT OR
     TMAMT_BE-MEINH NE MEINH_ALT OR
     TMAMT_BE-MTXID NE MTXID_ALT.
    LOOP AT TMAMT_BE WHERE MANDT = SY-MANDT AND
                           MATNR = MARA-MATNR AND
                           SPRAS = SPRAS_ALT AND
                           MEINH = MEINH_ALT AND
                           MTXID = MTXID_ALT.
      MOVE SPRAS_NEU TO TMAMT_BE-SPRAS.
      MOVE MEINH_NEU TO TMAMT_BE-MEINH.
      MOVE MTXID_NEU TO TMAMT_BE-MTXID.
      MODIFY TMAMT_BE.
    ENDLOOP.
    READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
  ENDIF.

ENDFORM.                               " ERSTE_ZEILE_AENDERN
