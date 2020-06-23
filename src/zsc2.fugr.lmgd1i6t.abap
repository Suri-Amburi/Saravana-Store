***INCLUDE LMGD1I15.
*---------------------------------------------------------------------*
* Module ITHEAD_SELKZ_SUCHEN                                          *
*---------------------------------------------------------------------*
*       Das Selektionskennzeichen in der Tabelle XTHEAD wird          *
*       aktualisiert. (Langtextbilder)                                *
*---------------------------------------------------------------------*
MODULE ITHEAD_SELKZ_SUCHEN INPUT.
*<<<<<<BEGIN OF INSERTION NOTE 200815<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
IF NOT RMMG2-FLG_RETAIL IS INITIAL.
  CASE RMMZU-OKCODE.
    WHEN FCODE_PAG1.
      RMMZU-OKCODE = FCODE_LTFP.
    WHEN FCODE_PAGP.
      RMMZU-OKCODE = FCODE_LTPP.
    WHEN FCODE_PAGN.
      RMMZU-OKCODE = FCODE_LTNP.
    WHEN FCODE_PAGL.
      RMMZU-OKCODE = FCODE_LTLP.
  ENDCASE.
ENDIF.
*<<<<<<END OF INSERTION NOTE 200815<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   CALL FUNCTION 'ITHEAD_SELKZ_SUCHEN'
        EXPORTING
             OK_CODE = RMMZU-OKCODE
        IMPORTING                               "ch zu 4.5B
             SPRAS   = RMMZU-LTEXT_SPRAS.       "H: 114262
ENDMODULE.






















