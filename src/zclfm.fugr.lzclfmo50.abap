*---------------------------------------------------------------------*
*       MODULE NEUE_EINTRAEGEOBJ OUTPUT.                              *
*---------------------------------------------------------------------*
*       Neue Eintraege in Tabelle klastab.                             *
*---------------------------------------------------------------------*
MODULE NEUE_EINTRAEGEOBJ OUTPUT.

  CHECK SOKCODE = OKEINT.
  CLEAR KLASTAB.
  DESCRIBE TABLE KLASTAB LINES ANZZEILEN.
*  SYST-TFILL = ANZLOOP - 1.
  SYST-TFILL = ANZLOOP - anzzeilen.    " geändert ST 4.6A
  DO SYST-TFILL TIMES.
    APPEND KLASTAB.
  ENDDO.

  if anzzeilen >= 12.
    if index_neu eq '1'
        AND TC_OBJ_CLASS-TOP_LINE eq 3.
      index_alt = '1'.
    endif.
  else.
    if index_neu eq '1'
        AND ( TC_OBJ_CLASS-TOP_LINE eq 1 )
        OR  ( TC_OBJ_CLASS-TOP_LINE eq 3 ).
      index_alt = '1'.
    endif.
  endif.

  if index_alt <= index_neu.
*  IF ANZZEILEN > 0.                       " geändert ST 4.6A
    IF ANZZEILEN >= 12 AND TC_OBJ_CLASS-TOP_LINE = 1.
      RMCLF-PAGPOS = anzzeilen - 12 + 2.
      INDEX_NEU    = anzzeilen - 12 + 2.
      INDEX_ALT = INDEX_NEU.
      SET CURSOR FIELD 'RMCLF-WGHIE1' line 12.
    ELSEIF TC_OBJ_CLASS-TOP_LINE > 1.
      RMCLF-PAGPOS = TC_OBJ_CLASS-TOP_LINE. " geändert ST 4.6A
      INDEX_NEU    = TC_OBJ_CLASS-TOP_LINE.
      anzzeilen = anzzeilen - TC_OBJ_CLASS-TOP_LINE + 2.

      if anzzeilen > 12.
        SET CURSOR FIELD 'RMCLF-WGHIE1' line 12.
        index_neu = index_neu + 1.
      else.
        SET CURSOR FIELD 'RMCLF-WGHIE1' line anzzeilen.
      endif.
      INDEX_ALT = INDEX_NEU.
      anzzeilen = anzzeilen + TC_OBJ_CLASS-TOP_LINE - 2.
    ELSE.
      RMCLF-PAGPOS = 1.                " geändert ST 4.6A
      INDEX_NEU    = 1.
      anzzeilen = anzzeilen + 1.
      SET CURSOR FIELD 'RMCLF-WGHIE1' line anzzeilen.
      anzzeilen = anzzeilen - 1.
    ENDIF.
  ELSE.
*   RMCLF-PAGPOS = 1.                      " geändert ST 4.6A
*   INDEX_NEU    = 1.
*   anzzeilen = anzzeilen + 1.
    anzzeilen    = anzzeilen - index_neu + 2.
    SET CURSOR FIELD 'RMCLF-WGHIE1' line anzzeilen.
*   anzzeilen = anzzeilen - 1.
  ENDIF.


ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE LIST_WWS_OBJ OUTPUT                                    *
*---------------------------------------------------------------------*
*       Anzeige der Hierarchiewarengruppen.                           *
*---------------------------------------------------------------------*
MODULE LIST_WWS_OBJ OUTPUT.

*  ANZLOOP = SYST-LOOPC.
*  CHECK KLASTAB-INDEX_TAB GT 0 .
  sokcode = 'EINT'.                          " geändert ST 4.6A
  if KLASTAB-INDEX_TAB > 0.                  " geändert ST 4.6A
    READ TABLE ALLKSSK INDEX KLASTAB-INDEX_TAB.
    RMCLF-WGHIE1 = KLASTAB-OBJEK.
    RMCLF-KTEXT  = ALLKSSK-KSCHL.
  endif.
  IF KLASTAB-MARKUPD = KREUZ.
    RMCLF-KREUZ = KREUZ.
  ENDIF.
  IF SOKCODE = OKEINT OR ANZZEILEN = 0.
*    IF RMCLF-WGHIE1 IS INITIAL.       "HW 323229
*      LOOP AT SCREEN.
*      IF SCREEN-GROUP3 = GROUP3INT.
*          SCREEN-INPUT = ON.
*          SCREEN-INTENSIFIED = ON.
*        ENDIF.
*        IF SY-TCODE = 'CLW2'.                "geändert ST 4.6B
*           SCREEN-INPUT = OFF.               "Anzeige
*        ENDIF.
*          MODIFY SCREEN.
*      ENDLOOP.
*    ENDIF.
      LOOP AT SCREEN.                  "HW 323229
        IF SY-TCODE = 'CLW2'.          "Im Anzeigen alles übersteuern
          SCREEN-INPUT = OFF.          "Alle Felder zu
        else.
           SCREEN-INPUT = OFF.
           IF SCREEN-NAME = 'RMCLF-KREUZ'.   "Im Ändern Ankreuzfeld auf
              SCREEN-INPUT = ON.
           ELSEIF RMCLF-WGHIE1 IS INITIAL.   "Offen für neue Einträge
              SCREEN-INPUT = ON.
           ENDIF.
        endif.
        MODIFY SCREEN.
      ENDLOOP.
    ELSE.
*-- Zeilen auf Anzeige schalten, falls Anzeigemodus
    IF TCD_STAT IS INITIAL.
*-- Anzeige!
      LOOP AT SCREEN.
        IF SCREEN-NAME  NE 'RMCLF-KREUZ' AND SCREEN-INPUT = ON.
          SCREEN-INPUT = OFF.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_CURRENT_WWS_LINE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURRENT_WWS_LINE OUTPUT.
*-- Initialwerte für den jeweiligen Screen setzen
  REFRESH CONTROL 'TC_OBJ_CLASS' FROM SCREEN SY-DYNNR .
  TC_OBJ_CLASS-LINES        = ANZLOOP.             "geändert ST 4.6A
  TC_OBJ_CLASS-TOP_LINE     = INDEX_NEU.
ENDMODULE.                 " SET_CURRENT_LINE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURRENT_LINE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURRENT_LINE OUTPUT.
*-- Initialwerte für den jeweiligen Screen setzen
  REFRESH CONTROL 'TC_OBJ_CLASS' FROM SCREEN SY-DYNNR .
*  TC_OBJ_CLASS-LINES        = ANZLOOP.             "geändert ST 4.6A
  TC_OBJ_CLASS-TOP_LINE     = INDEX_NEU.
ENDMODULE.                 " SET_CURRENT_LINE  OUTPUT
