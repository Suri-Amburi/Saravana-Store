*&---------------------------------------------------------------------*
*&      Module  OK_CODE_KTEXT_I INPUT
*&---------------------------------------------------------------------*
MODULE OK_CODE_KTEXT_I INPUT.

  DATA: ZEILE_OFFS LIKE SY-TABIX.

  CHECK T130M-AKTYP EQ AKTYPH OR T130M-AKTYP EQ AKTYPV.

  IF NOT KT_FLAG2 IS INITIAL.
    ZEILE_OFFS = 1.
    CLEAR KT_FLAG2.
  ELSE.
    ZEILE_OFFS = 0.
  ENDIF.

  IF RMMZU-OKCODE = FCODE_KTDE.
*----Loeschen Eintrag------------------------------------------
    GET CURSOR LINE KT_ZEILEN_NR.
    KT_AKT_ZEILE = KT_ERSTE_ZEILE + KT_ZEILEN_NR + ZEILE_OFFS.
    READ TABLE KTEXT INDEX KT_AKT_ZEILE.
    IF SY-SUBRC = 0.
      DELETE KTEXT INDEX KT_AKT_ZEILE.
    ENDIF.
    BILDFLAG = X.
    CLEAR RMMZU-OKCODE.
  ENDIF.

ENDMODULE.                             " OK_CODE_KTEXT_I  INPUT
