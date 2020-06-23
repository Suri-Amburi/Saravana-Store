*&---------------------------------------------------------------------*
*&      Module  OKCODE_VERBRAUCH  INPUT
*&---------------------------------------------------------------------*
MODULE OKCODE_VERBRAUCH INPUT.

  IF NOT VW_BILDFLAG_OLD IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_VWFP OR
       RMMZU-OKCODE = FCODE_VWPP OR
       RMMZU-OKCODE = FCODE_VWNP OR
       RMMZU-OKCODE = FCODE_VWLP OR
       RMMZU-OKCODE = FCODE_GESV OR    " Spezielle F-Codes
       RMMZU-OKCODE = FCODE_UNGV  ).
    CLEAR RMMZU-OKCODE.
  ENDIF.
*wk/4.0 switch to tc
  IF VW_BILDFLAG_OLD IS INITIAL.
    IF NOT FLG_TC IS INITIAL.
      VW_ERSTE_ZEILE = TC_VERB-TOP_LINE - 1.
      IF TC_VERB-TOP_LINE NE TC_VERB_TOP_LINE_BUF.
        PERFORM PARAM_SET.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM OK_CODE_VERBRAUCH.

ENDMODULE.                             " OKCODE_VERBRAUCH  INPUT
