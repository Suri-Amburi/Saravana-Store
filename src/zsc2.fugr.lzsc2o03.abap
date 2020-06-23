*-------------------------------------------------------------------
* INCLUDE LMGD2O03 .
*   PBO-Module für Bon-/Etikettentexte
*-------------------------------------------------------------------

*----------------------------------------------------------------------*
*Module  INITIAL_BON_ETIKETT_TEXT                                      *
*----------------------------------------------------------------------*
MODULE INITIAL_BON_ETIKETT_TEXT OUTPUT.
*
  BE_TEXTART = '00'.

  IF KZ_BON_ETI_TEXT_INIT = SPACE.

    CLEAR BE_ERSTE_ZEILE.
    CLEAR BE_ZEILEN_NR.                "JH/22.10.97/1.2B
    KZ_BON_ETI_TEXT_INIT = 'X'.

    DESCRIBE TABLE TMAMT LINES BE_LINES.

    IF BE_LINES NE 0.

      CLEAR TMAMT_BE.
      REFRESH TMAMT_BE.

      LOOP AT TMAMT.
        MOVE-CORRESPONDING TMAMT TO TMAMT_BE.
        APPEND TMAMT_BE.
      ENDLOOP.
      DESCRIBE TABLE TMAMT_BE LINES BE_LINES.

    ENDIF.
  ENDIF.

  DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
* JH/05.11.96
* Kein Umsortieren der eingegebenen Texte; führt sonst zu Problemen
* beim Positionieren des Cursors wenn eine Zeile eingefügt wird.
* Außerdem erschwert es die Pflege wenn plötzlich die gerade eingegeb.
* Einträge nach Drücken von RETURN an eine andere Stelle wandern
* (Sortieren ist erst bei Übergabe an TMAMT sinnvoll)
* SORT TMAMT_BE BY SPRAS  MEINH  MTXID  LFDNR.

ENDMODULE.

*----------------------------------------------------------------------*
*Module  INITIAL_BON_TEXT                                              *
*----------------------------------------------------------------------*
MODULE INITIAL_BON_TEXT OUTPUT.
*
  BE_TEXTART = '02'.

  IF KZ_BON_ETI_TEXT_INIT = SPACE.

    CLEAR BE_ERSTE_ZEILE.
    CLEAR BE_ZEILEN_NR.                "JH/22.10.97/1.2B
    KZ_BON_ETI_TEXT_INIT = 'X'.

    DESCRIBE TABLE TMAMT LINES BE_LINES.

    IF BE_LINES NE 0.

      CLEAR TMAMT_BE.
      REFRESH TMAMT_BE.
      CLEAR TMAMT_ET.
      REFRESH TMAMT_ET.

* JH/14.10.98/4.5B/KPr328776 (Anfang)
* Seit es die Tickets&Additionals gibt, gibt es die Textart 01 nicht
* mehr, dafür aber neue Textarten 10, ..., 49
* -> es müssen alle Textarten <> 02 gerettet werden!
*
**Die Einträge zur eigenen Textart ('02') übernehmen
*     LOOP AT TMAMT WHERE MTXID = '02'.
*       MOVE-CORRESPONDING TMAMT TO TMAMT_BE.
*       APPEND TMAMT_BE.
*     ENDLOOP.
*     DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
**Die Einträge der anderen Textart ('01') retten
*     LOOP AT TMAMT WHERE MTXID = '01'.
*       MOVE-CORRESPONDING TMAMT TO TMAMT_ET.
*       APPEND TMAMT_ET.
*     ENDLOOP.
      LOOP AT TMAMT.
        IF TMAMT-MTXID = '02'.
*         Die Einträge zur eigenen Textart ('02') übernehmen
          MOVE-CORRESPONDING TMAMT TO TMAMT_BE.
          APPEND TMAMT_BE.
        ELSE.
*         Die Einträge der anderen Textarten retten
          MOVE-CORRESPONDING TMAMT TO TMAMT_ET.
          APPEND TMAMT_ET.
        ENDIF.
      ENDLOOP.
* Das DESCRIBE für die TMAMT_BE kann entfallen, weil es ein paar Zeilen
* später sowieso nachmal gemacht wird!
* JH/14.10.98/4.5B/KPr328776 (Ende)
    ENDIF.
  ENDIF.

  DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
* JH/05.11.96
* Kein Umsortieren der eingegebenen Texte; führt sonst zu Problemen
* beim Positionieren des Cursors wenn eine Zeile eingefügt wird.
* Außerdem erschwert es die Pflege wenn plötzlich die gerade eingegeb.
* Einträge nach Drücken von RETURN an eine andere Stelle wandern
* (Sortieren ist erst bei Übergabe an TMAMT sinnvoll)
* SORT TMAMT_BE BY SPRAS  MEINH  MTXID  LFDNR.

ENDMODULE.

*----------------------------------------------------------------------*
*Module  INITIAL_ETIKETT_TEXT                                          *
*----------------------------------------------------------------------*
MODULE INITIAL_ETIKETT_TEXT OUTPUT.
*
  BE_TEXTART = '01'.

  IF KZ_BON_ETI_TEXT_INIT = SPACE.

    CLEAR BE_ERSTE_ZEILE.
    CLEAR BE_ZEILEN_NR.                "JH/22.10.97/1.2B
    KZ_BON_ETI_TEXT_INIT = 'X'.

    DESCRIBE TABLE TMAMT LINES BE_LINES.

    IF BE_LINES NE 0.

      CLEAR TMAMT_BE.
      REFRESH TMAMT_BE.
      CLEAR TMAMT_BT.
      REFRESH TMAMT_BT.

* Die Einträge zur eigenen Textart ('01') übernehmen
      LOOP AT TMAMT WHERE MTXID = '01'.
        MOVE-CORRESPONDING TMAMT TO TMAMT_BE.
        APPEND TMAMT_BE.
      ENDLOOP.
      DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
* Die Einträge der anderen Textart ('02') retten
      LOOP AT TMAMT WHERE MTXID = '02'.
        MOVE-CORRESPONDING TMAMT TO TMAMT_BT.
        APPEND TMAMT_BT.
      ENDLOOP.

    ENDIF.
  ENDIF.

  DESCRIBE TABLE TMAMT_BE LINES BE_LINES.
* JH/05.11.96
* Kein Umsortieren der eingegebenen Texte; führt sonst zu Problemen
* beim Positionieren des Cursors wenn eine Zeile eingefügt wird.
* Außerdem erschwert es die Pflege wenn plötzlich die gerade eingegeb.
* Einträge nach Drücken von RETURN an eine andere Stelle wandern
* (Sortieren ist erst bei Übergabe an TMAMT sinnvoll)
* SORT TMAMT_BE BY SPRAS  MEINH  MTXID  LFDNR.

ENDMODULE.

*---------------------------------------------------------------------*
*Module ANZEIGEN_BON_ETIKETT_TEXT  output                             *
*---------------------------------------------------------------------*
MODULE ANZEIGEN_BON_ETIKETT_TEXT OUTPUT.
*
  IF SY-STEPL = 1.
    BE_ZLEPROSEITE = SY-LOOPC.
  ENDIF.

  BE_AKT_ZEILE = BE_ERSTE_ZEILE + SY-STEPL.

  CLEAR MAMT.
  READ TABLE TMAMT_BE INDEX BE_AKT_ZEILE.

  IF SY-SUBRC = 0.
    MAMT = TMAMT_BE.
  ELSE.
    IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ.
      EXIT FROM STEP-LOOP.
    ENDIF.
  ENDIF.

  LOOP AT SCREEN.
    IF MAMT-LFDNR > 1.
      CASE SCREEN-NAME.
        WHEN 'MAMT-SPRAS'.
          SCREEN-ACTIVE = 0.
        WHEN 'MAMT-MEINH'.
          SCREEN-ACTIVE = 0.
        WHEN 'MAMT-MTXID'.
          SCREEN-ACTIVE = 0.
      ENDCASE.
    ENDIF.
    IF SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*
ENDMODULE.

*----------------------------------------------------------------------*
* MODULE BE_ZEILE_INT_TO_CHAR                                          *
*----------------------------------------------------------------------*
MODULE BE_ZEILE_INT_TO_CHAR OUTPUT.
*
  BE_EINTRAEGE_C   = BE_LINES.
  IF BE_LINES = 0.
    BE_ERSTE_ZEILE_C = 0.
  ELSE.
    BE_ERSTE_ZEILE_C = BE_ERSTE_ZEILE + 1.
  ENDIF.
*
ENDMODULE.

*----------------------------------------------------------------------*
*Module ET_ZEILE_INT_TO_CHAR                                           *
*----------------------------------------------------------------------*
MODULE ET_ZEILE_INT_TO_CHAR OUTPUT.
*
  ET_EINTRAEGE_C = ET_LINES.
  IF ET_LINES = 0.
    ET_ERSTE_ZEILE_C = 0.
  ELSE.
    ET_ERSTE_ZEILE_C = ET_ERSTE_ZEILE + 1.
  ENDIF.
*
ENDMODULE.

*---------------------------------------------------------------------*
*Module  BE_SETZEN_CURSOR OUTPUT                                      *
*---------------------------------------------------------------------*
MODULE BE_SETZEN_CURSOR OUTPUT.
* be_zeilen_nr = 0, falls Cursor nicht im STEP-LOOP steht
  CHECK BE_ZEILEN_NR NE SPACE.
* JH/07.11.96 (Anfang)
* SET CURSOR FIELD 'MAMT-SPRAS' LINE BE_ZEILEN_NR.
* CLEAR BE_ZEILEN_NR.
  IF ZEILE_GELOESCHT NE SPACE.
    SET CURSOR FIELD BE_CURSOR_FELD LINE BE_ZEILEN_NR.
    CLEAR ZEILE_GELOESCHT.
    CLEAR BE_ZEILEN_NR.
* IF ZEILE_EINGEFUEGT NE SPACE.
  ELSEIF ZEILE_EINGEFUEGT NE SPACE.
* JH/07.11.96 (Ende)
    SET CURSOR FIELD 'MAMT-MAKTM' LINE CURSOR_ZEILEN_NR.
    CLEAR CURSOR_ZEILEN_NR.
    CLEAR ZEILE_EINGEFUEGT.
    CLEAR BE_ZEILEN_NR.
* JH/07.11.96 (Anfang)
  ELSE.
    SET CURSOR FIELD 'MAMT-SPRAS' LINE BE_ZEILEN_NR.
    CLEAR BE_ZEILEN_NR.
* JH/07.11.96 (Ende)
  ENDIF.
*
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  INIT_tc_bon  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_TC_BON OUTPUT.
  IF NOT FLG_TC IS INITIAL.
    REFRESH CONTROL 'TC_BON' FROM SCREEN SY-DYNNR.
    TC_BON-LINES = BE_LINES.
    TC_BON-TOP_LINE = BE_ERSTE_ZEILE + 1.
    TC_BON_TOP_LINE_BUF = TC_BON-TOP_LINE.
    ASSIGN TC_BON TO <F_TC>.
  ENDIF.
ENDMODULE.                             " INIT_TC_BON  OUTPUT
