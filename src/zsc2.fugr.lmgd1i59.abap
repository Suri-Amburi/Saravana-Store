*&---------------------------------------------------------------------*
*&      Module  OK_CODE_KTEXT_II INPUT
*&---------------------------------------------------------------------*
MODULE OK_CODE_KTEXT_II INPUT.

* es darf nicht geblättert werden, wenn ein Fehler aus einem Feld
* kommt, das vor dem Kurztext - Subscreen liegt, da keine Prüfungen
* mehr durchgeführt werden, wenn das Bildflag (S-Meldg. bei Fehler)
* sitzt

  IF NOT BILDFLAG IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_KTFP OR
       RMMZU-OKCODE = FCODE_KTPP OR
       RMMZU-OKCODE = FCODE_KTNP OR
       RMMZU-OKCODE = FCODE_KTLP  ).
    CLEAR RMMZU-OKCODE.
  ENDIF.
** change tc to 4.0 wk
  IF BILDFLAG IS INITIAL.
    IF NOT FLG_TC IS INITIAL.
      KT_ERSTE_ZEILE = TC_KTXT-TOP_LINE - 1.
      IF TC_KTXT-TOP_LINE NE TC_KTXT_TOP_LINE_BUF.
        PERFORM PARAM_SET.
      ENDIF.
    ENDIF.
  ENDIF.
  PERFORM OK_CODE_KTEXT.

ENDMODULE.                             " OK_CODE_KTEXT_II INPUT
