*----------------------------------------------------------------------*
*Module  SPEICHERN_ZEILE                                               *
*----------------------------------------------------------------------*
MODULE SPEICHERN_ZEILE.
*
GET CURSOR LINE BE_ZEILEN_NR.                             "JH/04.11.96
IF RMMZU-OKCODE = FCODE_BEDE.
*  CLEAR FEHLER_DELETE.                                   "JH/04.11.96
*  CLEAR DELETE_ZEILEN_NR.                                "JH/04.11.96
*  GET CURSOR LINE DELETE_ZEILEN_NR.                      "JH/04.11.96
*  DELETE_ZEILEN_NR = BE_ERSTE_ZEILE + DELETE_ZEILEN_NR.  "JH/04.11.96
   DELETE_ZEILEN_NR = BE_ERSTE_ZEILE + BE_ZEILEN_NR.      "JH/04.11.96
* JH/07.11.96
* Beim Löschen auch das Feld wo der Cursor stand retten
  GET CURSOR FIELD BE_CURSOR_FELD.
* JH/13.01.97/1.2B (Anfang)
ELSE.
  CLEAR DELETE_ZEILEN_NR.
* JH/13.01.97/1.2B (Ende)
ENDIF.
IF RMMZU-OKCODE = FCODE_BEIR.
*  CLEAR INSERT_ROW_ZEILEN_NR.                             "JH/04.11.96
*  GET CURSOR LINE INSERT_ROW_ZEILEN_NR.                   "JH/04.11.96
*  INSERT_ROW_ZEILEN_NR = BE_ERSTE_ZEILE + INSERT_ROW_ZEILEN_NR. " -"-
   INSERT_ROW_ZEILEN_NR = BE_ERSTE_ZEILE + BE_ZEILEN_NR.   "JH/04.11.96
* JH/13.01.97/1.2B (Anfang)
ELSE.
  CLEAR INSERT_ROW_ZEILEN_NR.
* JH/13.01.97/1.2B (Ende)
ENDIF.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module  EINGABE_TEXTE_BE                                              *
*----------------------------------------------------------------------*
MODULE EINGABE_TEXTE_BE INPUT.
*
*check rmmzu-okcode ne fcode_bede.
*
** eintrag_be
*  1    : die erste Zeile eines bereits vorhandenen Bon- bzw. Etiketten-
*         text wird geändert
*  2    : eine Zeile > 1 eines bereits vorhandenen Bon- bzw. Etiketten-
*         textes wird geändert
*  3    : die erste Zeile eines Bon- bzw. Etikettentext wird hinzugefügt
*  4    : eine weitere Zeile zu einem bereits vorhandenen Bon- bzw.
*         Etikettentext wird hinzugefügt

** fehler_be
*  Space: kein Fehler
*  1    : hinzugefügte oder geänderte Bon- bzw. Etikettentext
*         existiert bereits
*  2    : Bon- bzw. Etikettentext eines hinzugefügten oder geänderten
*         wurde nicht eingegeben
*  3    : Mengeneinheit existiert nicht in MAMT
         "JH/31.10.96 Kennzeichen '3' wird nicht mehr benutzt

CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

IF NOT BILDFLAG IS INITIAL.
   CLEAR RMMZU-OKCODE.
   EXIT.
ENDIF.

EINTRAG_BE = SPACE.

* JH/31.10.96 (Anfang)
* Coding komplett überarbeitet (Optimierungen bei Zugriffen)
*BE_AKT_ZEILE = BE_ERSTE_ZEILE + SY-STEPL.
*READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
*IF SY-TFILL < BE_AKT_ZEILE AND SY-SUBRC = 4.
*   IF MAMT-SPRAS NE SPACE OR
*      MAMT-MEINH NE SPACE OR
*      MAMT-MTXID NE SPACE OR
*      MAMT-MAKTM NE SPACE.
*      EINTRAG_BE = '3'.
*   ENDIF.
*ENDIF.
*
*CHECK EINTRAG_BE EQ SPACE.
*BE_AKT_ZEILE = BE_ERSTE_ZEILE + SY-STEPL.
*READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
*IF SY-SUBRC = 0.
*   IF TMAMT_BE-LFDNR = 1.
*      EINTRAG_BE = '1'.
*   ELSE.
*      EINTRAG_BE = '2'.
*   ENDIF.
*ENDIF.
*
*IF RMMZU-OKCODE = FCODE_BEIR.
*   BE_AKT_ZEILE = BE_ERSTE_ZEILE + SY-STEPL.
*   IF INSERT_ROW_ZEILEN_NR = BE_AKT_ZEILE.
*      READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
*      IF SY-SUBRC = 0.
*         EINTRAG_BE = '4'.
*         ZEILE_EINGEFUEGT = 'X'.
*         CLEAR CURSOR_ZEILEN_NR.
*         IF INSERT_ROW_ZEILEN_NR <= SY-LOOPC.
*            CURSOR_ZEILEN_NR = INSERT_ROW_ZEILEN_NR + 1.
*         ELSE.
*            CURSOR_ZEILEN_NR = INSERT_ROW_ZEILEN_NR
*                              - BE_ERSTE_ZEILE + 1.
*         ENDIF.
*      ELSE.
*      ENDIF.
*  ENDIF.
*ENDIF.
DATA SY_SUBRC LIKE SY-SUBRC.  "um Tabelle TMAMT_BE nicht mehrfach lesen
                              "zu müssen

BE_AKT_ZEILE = BE_ERSTE_ZEILE + SY-STEPL.
READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
SY_SUBRC = SY-SUBRC.
IF SY-TFILL < BE_AKT_ZEILE AND SY_SUBRC = 4.
   IF MAMT-SPRAS NE SPACE OR
      MAMT-MEINH NE SPACE OR
      MAMT-MTXID NE SPACE OR
      MAMT-MAKTM NE SPACE.
      EINTRAG_BE = '3'.
* JH/05.11.96 (Anfang)
* Falls erste Zeile neu angelegt wird und Funktion 'Zeile einfügen'
* aufgerufen wurde, Cursorposition fürs Einfügen merken
      IF  ( RMMZU-OKCODE = FCODE_BEIR )
      AND ( INSERT_ROW_ZEILEN_NR = BE_AKT_ZEILE ).
        ZEILE_EINGEFUEGT = 'X'.
        CURSOR_ZEILEN_NR = INSERT_ROW_ZEILEN_NR - BE_ERSTE_ZEILE + 1.
      ENDIF.
* JH/05.11.96 (Ende)
   ENDIF.
ENDIF.

CHECK EINTRAG_BE EQ SPACE.
IF SY_SUBRC = 0.
   IF TMAMT_BE-LFDNR = 1.
      EINTRAG_BE = '1'.
   ELSE.
      EINTRAG_BE = '2'.
   ENDIF.
ENDIF.

IF  ( RMMZU-OKCODE = FCODE_BEIR )
AND ( INSERT_ROW_ZEILEN_NR = BE_AKT_ZEILE )
AND ( SY_SUBRC = 0 ). "SY_SUBRC <> 0 kann hier nicht mehr auftreten????
  EINTRAG_BE = '4'.
  ZEILE_EINGEFUEGT = 'X'.
  CURSOR_ZEILEN_NR = INSERT_ROW_ZEILEN_NR - BE_ERSTE_ZEILE + 1.
ENDIF.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module  PRUEFEN_TEXTE_BE                                              *
*----------------------------------------------------------------------*
MODULE PRUEFEN_TEXTE_BE INPUT.
*
  CHECK EINTRAG_BE NE SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  BE_AKT_ZEILE = BE_ERSTE_ZEILE + SY-STEPL.
* READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.    "JH/31.10.96

  CLEAR TMAMT_BE.
  CLEAR ZEILENNR_DOPPELTER_EINTRAG.
  CLEAR FEHLER_BE.
  CLEAR FEHLER_INSERT_ROW.
* CLEAR TMAMT_BE.                     "JH/31.10.96
  CASE BE_TEXTART.
  WHEN '00'.
       LOOP AT TMAMT_BE WHERE MANDT = SY-MANDT AND
                              MATNR = MARA-MATNR AND
                              SPRAS = MAMT-SPRAS AND
                              MEINH = MAMT-MEINH AND
                              MTXID = MAMT-MTXID AND
                              LFDNR = 1.
          ZEILENNR_DOPPELTER_EINTRAG = SY-TABIX.
      ENDLOOP.
  WHEN '01'.
       LOOP AT TMAMT_BE WHERE MANDT = SY-MANDT AND
                              MATNR = MARA-MATNR AND
                              SPRAS = MAMT-SPRAS AND
                              MEINH = MAMT-MEINH AND
                              MTXID = '01'       AND
                              LFDNR = 1.
          ZEILENNR_DOPPELTER_EINTRAG = SY-TABIX.
      ENDLOOP.
  WHEN '02'.
       LOOP AT TMAMT_BE WHERE MANDT = SY-MANDT AND
                              MATNR = MARA-MATNR AND
                              SPRAS = MAMT-SPRAS AND
                              MEINH = MAMT-MEINH AND
                              MTXID = '02'       AND
                              LFDNR = 1.
          ZEILENNR_DOPPELTER_EINTRAG = SY-TABIX.
      ENDLOOP.
  ENDCASE.
  IF SY-DATAR NE SPACE. "gesetzt wenn Daten in Dynpro eingegeben wurden
    IF SY-SUBRC = 4.
      FEHLER_BE = ' '.
    ELSE.
      IF ZEILENNR_DOPPELTER_EINTRAG NE BE_AKT_ZEILE.
        FEHLER_BE = '1'.
      ELSE.
        FEHLER_BE = ' '.
      ENDIF.
    ENDIF.
  ELSE.
     FEHLER_BE = ' '.
  ENDIF.

  IF FEHLER_BE EQ SPACE.
      IF MAMT-MAKTM EQ SPACE.
         FEHLER_BE = '2'.
      ELSE.
         FEHLER_BE = SPACE.
      ENDIF.
  ENDIF.

  CASE EINTRAG_BE.
  WHEN '1'. "erste Zeile eines vorh. Bon- bzw. Etikettentextes ändern
       CLEAR EINTRAG_BE.
       CASE FEHLER_BE.
       WHEN SPACE. "kein Fehler
* JH/04.11.96 (Anfang)
* Nachfolgendes Coding als FORM-Routine
*           READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
*           CLEAR SPRAS_ALT.
*           CLEAR MEINH_ALT.
*           CLEAR MTXID_ALT.
*           CLEAR SPRAS_NEU.
*           CLEAR MEINH_NEU.
*           CLEAR MTXID_NEU.
*
*           MOVE TMAMT_BE-SPRAS TO SPRAS_ALT.
*           MOVE TMAMT_BE-MEINH TO MEINH_ALT.
*           MOVE TMAMT_BE-MTXID TO MTXID_ALT.
*
*           MOVE-CORRESPONDING MAMT TO TMAMT_BE.
*           MOVE SY-MANDT TO TMAMT_BE-MANDT.
*           MOVE MARA-MATNR TO TMAMT_BE-MATNR.
*           MODIFY TMAMT_BE INDEX BE_AKT_ZEILE.
*           MOVE TMAMT_BE-SPRAS TO SPRAS_NEU.
*           MOVE TMAMT_BE-MEINH TO MEINH_NEU.
*           MOVE TMAMT_BE-MTXID TO MTXID_NEU.
*
*           IF TMAMT_BE-SPRAS NE SPRAS_ALT OR
*              TMAMT_BE-MEINH NE MEINH_ALT OR
*              TMAMT_BE-MTXID NE MTXID_ALT.
*              LOOP AT TMAMT_BE WHERE MANDT = SY-MANDT AND
*                                     MATNR = MARA-MATNR AND
*                                     SPRAS = SPRAS_ALT AND
*                                     MEINH = MEINH_ALT AND
*                                     MTXID = MTXID_ALT.
*                       MOVE SPRAS_NEU TO TMAMT_BE-SPRAS.
*                       MOVE MEINH_NEU TO TMAMT_BE-MEINH.
*                       MOVE MTXID_NEU TO TMAMT_BE-MTXID.
*                       MODIFY TMAMT_BE.
*               ENDLOOP.
*               READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
*           ENDIF.
            PERFORM ERSTE_ZEILE_AENDERN.
* JH/04.11.96 (Ende)
       WHEN '1'. "Fehler: doppeltes Vorkommen
           CLEAR FEHLER_BE.
           IF RMMZU-OKCODE NE FCODE_BEDE.
              IF SY-DATAR NE SPACE."JH/311096????gar nicht anders mögl.?
                 SET CURSOR FIELD 'MAMT-SPRAS' LINE SY-STEPL.
                 MESSAGE E104(MH).
              ENDIF.
           ELSE.
              IF DELETE_ZEILEN_NR NE BE_AKT_ZEILE.
                 IF SY-DATAR NE SPACE."????GAR NICHT ANDERS MÖGL.?
                    SET CURSOR FIELD 'MAMT-SPRAS' LINE SY-STEPL.
                    MESSAGE E104(MH).
                 ENDIF.
              ENDIF.
           ENDIF.
       WHEN '2'. "Fehler: Text wurde nicht eingegeben
            CLEAR FEHLER_BE.
            IF RMMZU-OKCODE NE FCODE_BEDE.
               SET CURSOR FIELD 'MAMT-MAKTM' LINE SY-STEPL.
               MESSAGE E105(MH).
            ELSE.
               IF DELETE_ZEILEN_NR NE BE_AKT_ZEILE.
                  SET CURSOR FIELD 'MAMT-MAKTM' LINE SY-STEPL.
                  MESSAGE E105(MH).
               ENDIF.
           ENDIF.
       ENDCASE.
  WHEN '2'. "eine Zeile > 1 eines vorh. Bon- bzw. Etiketten ändern
       CLEAR EINTRAG_BE.
       CASE FEHLER_BE.
       WHEN SPACE. "Kein Fehler
            READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
            MOVE SY-MANDT TO TMAMT_BE-MANDT.
            MOVE MARA-MATNR TO TMAMT_BE-MATNR.
            MOVE MAMT-MAKTM TO TMAMT_BE-MAKTM.
            MODIFY TMAMT_BE INDEX BE_AKT_ZEILE.
       WHEN '1'. "Fehler: doppeltes Vorkommen ????möglich????
           CLEAR FEHLER_BE.
           IF RMMZU-OKCODE NE FCODE_BEDE.
              IF SY-DATAR NE SPACE."????GAR NICHT ANDERS MÖGL.?
                 SET CURSOR FIELD 'MAMT-SPRAS' LINE SY-STEPL.
                 MESSAGE E104(MH).
              ENDIF.
           ELSE.
              IF DELETE_ZEILEN_NR NE BE_AKT_ZEILE.
                 IF SY-DATAR NE SPACE."????GAR NICHT ANDERS MÖGL.?
                    SET CURSOR FIELD 'MAMT-SPRAS' LINE SY-STEPL.
                    MESSAGE E104(MH).
                 ENDIF.
              ENDIF.
           ENDIF.
       WHEN '2'. "Fehler: Text wurde nicht eingegeben
            CLEAR FEHLER_BE.
            IF RMMZU-OKCODE NE FCODE_BEDE.
               SET CURSOR FIELD 'MAMT-MAKTM' LINE SY-STEPL.
               MESSAGE E105(MH).
            ELSE.
               IF DELETE_ZEILEN_NR NE BE_AKT_ZEILE.
                  SET CURSOR FIELD 'MAMT-MAKTM' LINE SY-STEPL.
                  MESSAGE E105(MH).
               ENDIF.
           ENDIF.
       ENDCASE.
  WHEN '3'. "erste Zeile eines Bon- bzw. Etikettentextes hinzufügen
       CASE FEHLER_BE.
       WHEN SPACE. "Kein Fehler
            CLEAR TMAMT_BE.
            MOVE-CORRESPONDING MAMT TO TMAMT_BE.
            MOVE SY-MANDT TO TMAMT_BE-MANDT.
            MOVE MARA-MATNR TO TMAMT_BE-MATNR.
            ZEILENNR_BETEXT = 1.
            MOVE ZEILENNR_BETEXT TO TMAMT_BE-LFDNR.
            CASE BE_TEXTART.
*           WHEN '00', dann wurde MTXID auf dem Dynpro eingegeben
            WHEN '01'.
                 MOVE '01' TO TMAMT_BE-MTXID.
            WHEN '02'.
                 MOVE '02' TO TMAMT_BE-MTXID.
            ENDCASE.
            APPEND TMAMT_BE.
            DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
       WHEN '1'. "Fehler: doppeltes Vorkommen
           CLEAR FEHLER_BE.
           IF RMMZU-OKCODE NE FCODE_BEDE.
              IF SY-DATAR NE SPACE."????GAR NICHT ANDERS MÖGL.?
                 SET CURSOR FIELD 'MAMT-SPRAS' LINE SY-STEPL.
                 MESSAGE E104(MH).
              ENDIF.
           ELSE.
              IF DELETE_ZEILEN_NR NE BE_AKT_ZEILE.
                 IF SY-DATAR NE SPACE."????GAR NICHT ANDERS MÖGL.?
                    SET CURSOR FIELD 'MAMT-SPRAS' LINE SY-STEPL.
                    MESSAGE E104(MH).
                 ENDIF.
              ENDIF.
           ENDIF.
       WHEN '2'. "Fehler: Text wurde nicht eingegeben
            CLEAR FEHLER_BE.
            IF RMMZU-OKCODE NE FCODE_BEDE.
               SET CURSOR FIELD 'MAMT-MAKTM' LINE SY-STEPL.
               MESSAGE E105(MH).
            ELSE.
               IF DELETE_ZEILEN_NR NE BE_AKT_ZEILE.
                  SET CURSOR FIELD 'MAMT-MAKTM' LINE SY-STEPL.
                  MESSAGE E105(MH).
               ENDIF.
           ENDIF.
       ENDCASE.
  WHEN '4'. "weitere Zeile zu vorh. Bon- bzw. Etikettentext hinzufügen
          CASE FEHLER_BE.
          WHEN SPACE. "Kein Fehler
* JH/04.11.96 (Anfang)
* Leider gehen etwaige Änderungen von AME u. ID verloren, wenn die
* Funktion 'Zeile einfügen' in der ersten Zeile eines mehrzeiligen
* Textes aufgerufen wird und vorher im Feld AME bzw. ID eine neue
* Eingabe erfolgte -> Coding entsprechend Fall '1' anwendem, plus der
* Unterscheidung auf welcher Zeile der Cursor steht
*           READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
*           TMAMT_BE-MAKTM = MAMT-MAKTM.
*           MODIFY TMAMT_BE INDEX BE_AKT_ZEILE.
            READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
            IF TMAMT_BE-LFDNR > 1.
* Cursor steht auf einer der nachfolgenden Zeilen eines mehrzeiligen
* Textes -> nur Text änderbar
              TMAMT_BE-MAKTM = MAMT-MAKTM.
              MODIFY TMAMT_BE INDEX BE_AKT_ZEILE.
            ELSE.
* Cursor steht auf der ersten Zeile -> alle Felder änderbar
              PERFORM ERSTE_ZEILE_AENDERN.
            ENDIF.
* JH/04.11.96 (Ende)
          WHEN '1'. "Fehler: doppeltes Vorkommen
           CLEAR FEHLER_BE.
           IF RMMZU-OKCODE NE FCODE_BEDE.
              IF SY-DATAR NE SPACE."????GAR NICHT ANDERS MÖGL.?
                 SET CURSOR FIELD 'MAMT-SPRAS' LINE SY-STEPL.
                 MESSAGE E104(MH).
              ENDIF.
           ELSE."????nicht möglich????weil FCODE_BEIR vorliegt
              IF DELETE_ZEILEN_NR NE BE_AKT_ZEILE.
                 IF SY-DATAR NE SPACE."????GAR NICHT ANDERS MÖGL.?333333
                    SET CURSOR FIELD 'MAMT-SPRAS' LINE SY-STEPL.
                    MESSAGE E104(MH).
                 ENDIF.
              ENDIF.
           ENDIF.
          WHEN '2'. "Fehler: Text wurde nicht eingegeben
            CLEAR FEHLER_BE.
            IF RMMZU-OKCODE NE FCODE_BEDE.
               SET CURSOR FIELD 'MAMT-MAKTM' LINE SY-STEPL.
               MESSAGE E105(MH).
            ELSE."????nicht möglich????weil FCODE_BEIR vorliegt
               IF DELETE_ZEILEN_NR NE BE_AKT_ZEILE.
                  SET CURSOR FIELD 'MAMT-MAKTM' LINE SY-STEPL.
                  MESSAGE E105(MH).
               ENDIF.
           ENDIF.
         ENDCASE.
  ENDCASE.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module  INSERT_ROW                                                   *
*----------------------------------------------------------------------*
MODULE INSERT_ROW_BE INPUT.
*
*CHECK RMMZU-OKCODE NE FCODE_BEDE.  "JH/04.11.96
CHECK RMMZU-OKCODE EQ FCODE_BEIR.

* Test: Cursor auf korrektem Feld?
CLEAR DYNPRO_FELD.
GET CURSOR FIELD DYNPRO_FELD.
IF DYNPRO_FELD NE 'MAMT-SPRAS' AND
   DYNPRO_FELD NE 'MAMT-MEINH' AND
   DYNPRO_FELD NE 'MAMT-MTXID' AND
   DYNPRO_FELD NE 'MAMT-LFDNR' AND "JH/04.11.96 'Nr' nicht ausschließen
   DYNPRO_FELD NE 'MAMT-MAKTM'.
       MESSAGE S115(MH).
       EXIT.
ENDIF.

* Test: Cursor auf belegter Zeile?                 "JH/04.11.96
*GET CURSOR LINE BE_ZEILEN_NR.                     "JH/04.11.96
*BE_AKT_ZEILE = BE_ERSTE_ZEILE + BE_ZEILEN_NR.     "JH/04.11.96
*READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.           "JH/04.11.96
READ TABLE TMAMT_BE INDEX INSERT_ROW_ZEILEN_NR.    "JH/04.11.96
IF SY-SUBRC NE 0.
   MESSAGE S115(MH).
   EXIT.
ENDIF.

*READ TABLE TMAMT_BE INDEX INSERT_ROW_ZEILEN_NR.   "JH/04.11.96

CLEAR SPRAS_ALT.
CLEAR MEINH_ALT.
CLEAR MTXID_ALT.
MOVE TMAMT_BE-SPRAS TO SPRAS_ALT.
MOVE TMAMT_BE-MEINH TO MEINH_ALT.
MOVE TMAMT_BE-MTXID TO MTXID_ALT.
MOVE TMAMT_BE-LFDNR TO LFDNR_ALT.

CLEAR TMAMT_BE.
* Nachfolgende Zeilen bei mehrzeiligem Text verschieben
LOOP AT TMAMT_BE WHERE MANDT = SY-MANDT AND
                       MATNR = MARA-MATNR AND
                       SPRAS = SPRAS_ALT AND
                       MEINH = MEINH_ALT AND
                       MTXID = MTXID_ALT AND
                       LFDNR > LFDNR_ALT.           "#EC PORTABLE
               TMAMT_BE-LFDNR = TMAMT_BE-LFDNR + 1.
               MODIFY TMAMT_BE.
*              IF SY-SUBRC = 0.      "JH/04.11.96 Meldung nur einmal
*                  MESSAGE S118(MH). "und nicht pro Durchlauf ausgeben
*              ENDIF.
ENDLOOP.
IF SY-SUBRC = 0.      "JH/04.11.96 Meldung nur einmal
  MESSAGE S118(MH). "und nicht pro Durchlauf ausgeben
ENDIF.

* Neuen Eintrag einfügen
CLEAR TMAMT_BE.
MOVE SY-MANDT      TO TMAMT_BE-MANDT.
MOVE MARA-MATNR    TO TMAMT_BE-MATNR.
MOVE SPRAS_ALT     TO TMAMT_BE-SPRAS.
MOVE MEINH_ALT     TO TMAMT_BE-MEINH.
MOVE MTXID_ALT     TO TMAMT_BE-MTXID.
TMAMT_BE-LFDNR =  ( LFDNR_ALT + 1 ).
* JH/05.11.96
* Weil das SORT für TMAMT_BE wegfällt, muß 'sortiert' eingefügt werden
*APPEND TMAMT_BE.
SY-TABIX = INSERT_ROW_ZEILEN_NR + 1.
INSERT TMAMT_BE INDEX SY-TABIX.

DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module  BE_ME_PRUEFEN                                                 *
*----------------------------------------------------------------------*
MODULE BE_ME_PRUEFEN INPUT.
*
*check rmmzu-okcode ne fcode_bede.
BE_AKT_ZEILE = BE_ERSTE_ZEILE + SY-STEPL.
READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
* JH/29.10.96 (Anfang)
* Bei Eingabe einer neuen Zeile führt das READ zu keinem Treffer
* -> nachfolgendes Coding wird durchlaufen, wenn der zuletzt gelesene
* Eintrag die Bedingung TMAMT_BE-LFDNR = 1 erfüllt -> eine unerlaubte
* ME-Eingabe wird nicht immer direkt erkannt -> SY-SUBRC testen!
IF SY-SUBRC = 0.
* Dynprozeile wurde schon in int. Tabelle übernommen
* JH/29.10.96 (Ende)
  IF TMAMT_BE-LFDNR = 1.
*   JH/29.10.96
*   Bei mehrzeiligen Texten nur die ME der ersten Zeile testen, weil
*   bei den weiteren Zeilen eine Änderung der ME nicht möglich ist
*   (es sei denn, die erste Zeile eines mehrzeiligen Eintrags wird
*   gelöscht und es wurde vorher eine andere ME eingegeben ->
*   nachfolgende Zeilen erben die neue ME)

* JH/10.01.97/1.2B (Anfang)
* Da MAMT-MEINH kein Mußfeld mehr ist, kann das Feld nun auch leer sein
* -> Test auf korrekte ME nur wenn Feld belegt ist
    IF NOT MAMT-MEINH IS INITIAL.
* JH/10.01.97/1.2B (Ende)

* JH/29.10.96 (Anfang)
* Wenn schon sortiert wird, dann sollte man auch binär suchen
* -> sortieren unnötig, da MEINH bereits sortiert, und vor allem nicht
* bei jedem LOOP-Durchlauf sortieren
*   SORT MEINH BY MEINH.
*   READ TABLE MEINH WITH KEY MEINH = MAMT-MEINH.
      READ TABLE MEINH WITH KEY MEINH = MAMT-MEINH. " note 877320
* JH/29.10.96 (Ende)
      IF SY-SUBRC NE 0.
* JH/29.10.96 (Anfang)
* Fall abfangen, daß bei mehrzeiligen Texten eine Zeile gelöscht wird
* und zuvor eine nicht definierte ME bei der ersten Zeile eingegeben
* wurde, damit Fehler direkt erkannt wird
* Anschön: Fehlermeldung erscheint jetzt auch, wenn nur eine Textzeile
* vorliegt, die gelöscht werden soll und in der eine nicht definierte
* ME eingegeben wurde -> ????Verbesserung: Lesen der TMAMT_BE und fest-
* stellen, ob weitere Zeilen zur alten Sprache, ME und TextId vorliegen?
*     IF RMMZU-OKCODE NE FCODE_BEDE.
        IF ( RMMZU-OKCODE NE FCODE_BEDE )
        OR ( ( RMMZU-OKCODE   =  FCODE_BEDE ) AND
             ( TMAMT_BE-MEINH NE MAMT-MEINH )     ).
* JH/29.10.96 (Ende)
          CLEAR RMMZU-OKCODE.
          SET CURSOR FIELD 'MAMT-MEINH' LINE SY-STEPL.
          MESSAGE E133(MH) WITH MAMT-MEINH.
        ENDIF.
      ENDIF.
    ENDIF.                           "JH/10.01.97/1.2B
  ENDIF.
* JH/29.10.96 (Anfang)
ELSE.
* Neueingabe einer Zeile am Ende -> Eintrag noch nicht in TMAMT_BE enth.

* JH/10.01.97/1.2B (Anfang)
* Da MAMT-MEINH kein Mußfeld mehr ist, kann das Feld nun auch leer sein
* -> Test auf korrekte ME nur wenn Feld belegt ist
  IF NOT MAMT-MEINH IS INITIAL.
* JH/10.01.97/1.2B (Ende)
    READ TABLE MEINH WITH KEY MEINH = MAMT-MEINH. " note 877320
    IF SY-SUBRC NE 0.
      IF RMMZU-OKCODE NE FCODE_BEDE.
        CLEAR RMMZU-OKCODE.
        SET CURSOR FIELD 'MAMT-MEINH' LINE SY-STEPL.
        MESSAGE E133(MH) WITH MAMT-MEINH.
      ENDIF.
    ENDIF.                    "JH/10.01.97/1.2B
  ENDIF.
* JH/29.10.96 (Ende)
ENDIF.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module  BE_ME_ANZEIGEN                                                *
*----------------------------------------------------------------------*
MODULE BE_ME_ANZEIGEN INPUT.
*
* JH/09.01.97/1.2B (Anfang)
* Unterscheidung nach RMMG2-FLG_RETAIL unnötig, weil Funktion sowieso
* nur im Retail aufrufbar, und Unterscheidung führt sogar zu einer
* fehlerhaften Verarbeitung, wenn nämlich vor der Anzeige von Bon-/
* Etikettentexten noch nicht die Sicht 'Grunddaten' angesprungen wurde,
* ist RMMW1_MATN im Retailfall noch unbelegt
* -> für die F4-Hilfe den Wert in RMMG1-MATNR nehmen, denn dieser
*    enthält den aktuellen Artikel (z.B. die Variante, wenn man sich
*    auf Ebene der Variante befindet anstatt dem Sammelartikel)
* IF NOT RMMG2-FLG_RETAIL IS INITIAL.
*
*   HMATNR = RMMW1_MATN.
* ELSE.
*   HMATNR = RMMG1-MATNR.
* ENDIF.
* JH/09.01.97/1.2B (Ende)

* Ermitteln, ob Änderungs- oder Anzeigemodus vorliegt
* DISPLAY = 'X' bedeutet Anzeigemodus -> aus der F4-Werteliste kann
* kein Wert selektiert werden -> reine Anzeigefunktion
  PERFORM SET_DISPLAY.

  CALL FUNCTION 'SMEINH_MEINH_HELP'
       EXPORTING
            DISPLAY = DISPLAY
*           P_MATNR = HMATNR         "JH/09.01.97/1.2B
            P_MATNR = RMMG1-MATNR    "JH/09.01.97/1.2B
       IMPORTING
            MEINH   = MAMT-MEINH
       EXCEPTIONS
            OTHERS  = 1.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module  UPDATE_TMAMT_FROM_TMAMT_BE                                    *
*----------------------------------------------------------------------*
MODULE UPDATE_TMAMT_FROM_TMAMT_BE.
*
CLEAR TMAMT.
REFRESH TMAMT.

LOOP AT TMAMT_BE.
     MOVE-CORRESPONDING TMAMT_BE TO TMAMT.
     APPEND TMAMT.
ENDLOOP.
*JH/04.11.96  TMAMT muß sortiert sein
SORT TMAMT BY SPRAS  MEINH  MTXID  LFDNR.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module  UPDATE_TMAMT_FROM_TMAMT_ET                                    *
*----------------------------------------------------------------------*
MODULE UPDATE_TMAMT_FROM_TMAMT_ET.
*
CLEAR TMAMT.
REFRESH TMAMT.

LOOP AT TMAMT_BE.
     MOVE-CORRESPONDING TMAMT_BE TO TMAMT.
     APPEND TMAMT.
ENDLOOP.

LOOP AT TMAMT_BT.
     MOVE-CORRESPONDING TMAMT_BT TO TMAMT.
     APPEND TMAMT.
ENDLOOP.
*mk/15.08.96  TMAMT muß sortiert sein
SORT TMAMT BY SPRAS  MEINH  MTXID  LFDNR.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module  UPDATE_TMAMT_FROM_TMAMT_BT                                    *
*----------------------------------------------------------------------*
MODULE UPDATE_TMAMT_FROM_TMAMT_BT.
*
CLEAR TMAMT.
REFRESH TMAMT.

LOOP AT TMAMT_BE.
     MOVE-CORRESPONDING TMAMT_BE TO TMAMT.
     APPEND TMAMT.
ENDLOOP.

LOOP AT TMAMT_ET.
     MOVE-CORRESPONDING TMAMT_ET TO TMAMT.
     APPEND TMAMT.
ENDLOOP.
*mk/15.08.96  TMAMT muß sortiert sein
SORT TMAMT BY SPRAS  MEINH  MTXID  LFDNR.
*
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DELETE_ROW_BE  INPUT
*&---------------------------------------------------------------------*
MODULE DELETE_ROW_BE INPUT.      "JH/04.11.96 Neues Modul

CHECK RMMZU-OKCODE EQ FCODE_BEDE.

* Test: Cursor auf korrektem Feld?
CLEAR DYNPRO_FELD.
GET CURSOR FIELD DYNPRO_FELD.
IF DYNPRO_FELD NE 'MAMT-SPRAS' AND
   DYNPRO_FELD NE 'MAMT-MEINH' AND
   DYNPRO_FELD NE 'MAMT-MTXID' AND
   DYNPRO_FELD NE 'MAMT-LFDNR' AND "JH/04.11.96 'Nr' nicht ausschließen
   DYNPRO_FELD NE 'MAMT-MAKTM'.
          MESSAGE S115(MH).
          EXIT.
ENDIF.
* Test: Cursor auf belegter Zeile?
READ TABLE TMAMT_BE INDEX DELETE_ZEILEN_NR.
IF SY-SUBRC NE 0.
   MESSAGE S115(MH).               "JH/04.11.96
   EXIT.
ENDIF.
CLEAR SPRAS_ALT.
CLEAR MEINH_ALT.
CLEAR MTXID_ALT.
CLEAR LFDNR_ALT.
SPRAS_ALT = TMAMT_BE-SPRAS.
MEINH_ALT = TMAMT_BE-MEINH.
MTXID_ALT = TMAMT_BE-MTXID.
LFDNR_ALT = TMAMT_BE-LFDNR.
*           Eintrag löschen
IF SY-SUBRC = 0.
   DELETE TMAMT_BE INDEX DELETE_ZEILEN_NR.
   ZEILE_GELOESCHT = 'X'.
ENDIF.
DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
*           Nachfolgende Zeilen bei mehrzeiligem Text verschieben
LOOP AT TMAMT_BE WHERE MANDT = SY-MANDT AND
                       MATNR = MARA-MATNR AND
                       SPRAS = SPRAS_ALT AND
                       MEINH = MEINH_ALT AND
                       MTXID = MTXID_ALT AND
                       LFDNR > LFDNR_ALT.     "#EC PORTABLE
         TMAMT_BE-LFDNR = TMAMT_BE-LFDNR - 1.
         MODIFY TMAMT_BE.
         IF SY-SUBRC = 0.     "JH/04.11.96 Meldung nur einmal ausgeben
            MESSAGE S112(MH). "und nicht pro Durchlauf
         ENDIF.
ENDLOOP.
IF SY-SUBRC = 0.     "JH/04.11.96 Meldung nur einmal ausgeben
   MESSAGE S112(MH). "und nicht pro Durchlauf
ENDIF.
ENDMODULE.                 " DELETE_ROW_BE  INPUT
*&---------------------------------------------------------------------*
*&      Module  PRUEFEN_MUSSFELDER_BE  INPUT
*&---------------------------------------------------------------------*
*       JH/10.01.97/1.2B Prüfen Mußfelder f. Bon-/Etikettentexte
*       Eingabefelder im Dynpro von Muß- zu Kannfeldern geändert ->
*       bei Eingabefehler wird E-Message ausgegeben -> ein Löschen der
*       fehlerhaften Eingabe ist zwar nicht durch den Löschbutton
*       möglich, aber durch Überschreiben der Eingabedaten mit SPACE
*       (um ein Löschen über den Löschbutton zu unterstützen, müßte
*       anstatt der E-Message eine S-Message ausgegeben werden. Dazu
*       müßte aber die nachfolgende Ablauflogik überarbeitet werden,
*       damit die eingegebenen Daten nicht übernommen werden ...
*       -> zu großer Änderungsaufwand!)
*----------------------------------------------------------------------*
MODULE PRUEFEN_MUSSFELDER_BE INPUT.

  BE_AKT_ZEILE = BE_ERSTE_ZEILE + SY-STEPL.
  READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.
  IF SY-SUBRC = 0.
* Dynprozeile wurde schon in int. Tabelle übernommen
    IF TMAMT_BE-LFDNR = 1.
*     Bei mehrzeiligen Texten nur die ersten Zeile testen, weil bei
*     weiteren Zeilen keine Eingabe von Keydaten möglich ist

*     Da keine automatische Mußfeldprüfung mehr abläuft, kann man nun
*     die Felder einer bereits übernommenen Textzeile mit SPACE über-
*     schreiben -> Fehlermeldung ausgeben, damit nicht später die
*     unpassende Meldung kommt, daß ein Text einzugeben ist.
*     Anmerkung: Ein Löschen durch Überschreiben mit SPACE ist nur bei
*     einer am Ende eingegeben Zeile erlaubt, die noch nicht in die
*     interne Tabelle übernommen wurde, oder bei Zeilen, die gelöscht
*     werden
      IF ( RMMZU-OKCODE NE FCODE_BEDE )
      OR (     RMMZU-OKCODE = FCODE_BEDE
           AND DELETE_ZEILEN_NR NE BE_AKT_ZEILE ).
* Alle Eingabefelder müssen belegt sein
        IF ( MAMT-SPRAS IS INITIAL )
        OR ( MAMT-MEINH IS INITIAL )
        OR ( ( BE_TEXTART = '00' ) AND ( MAMT-MTXID IS INITIAL ) )
        OR ( MAMT-MAKTM IS INITIAL ).
          MESSAGE E072(MH).
        ENDIF.
      ELSE.
* Zeile wird gelöscht -> alter Inhalt ist egal -> keine Prüfung notw.
      ENDIF.
    ENDIF.
  ELSE.
* Neueingabe einer Zeile am Ende -> Eintrag noch nicht in TMAMT_BE enth.
* Falls mindestens ein Feld der letzten Zeile belegt ist ...
    IF ( NOT MAMT-SPRAS IS INITIAL )
    OR ( NOT MAMT-MEINH IS INITIAL )
    OR ( NOT MAMT-MTXID IS INITIAL )
    OR ( NOT MAMT-MAKTM IS INITIAL ).
* ... müssen alle Felder der letzten Zeile belegt sein
      IF ( MAMT-SPRAS IS INITIAL )
      OR ( MAMT-MEINH IS INITIAL )
      OR ( ( BE_TEXTART = '00' ) AND ( MAMT-MTXID IS INITIAL ) )
      OR ( MAMT-MAKTM IS INITIAL ).
        MESSAGE E072(MH).
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " PRUEFEN_MUSSFELDER_BE  INPUT
