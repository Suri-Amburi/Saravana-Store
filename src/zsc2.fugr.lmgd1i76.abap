*------------------------------------------------------------------
*Module MFHM-EWFORM_HELP.
*Aufruf der speziellen Eingabehilfe für MFHM-EWFORM
*------------------------------------------------------------------
MODULE MFHM-EWFORM_HELP.

DATA HEWFORM LIKE MFHM-EWFORM.  " //br200896
                                "
  PERFORM SET_DISPLAY.          "

CALL FUNCTION 'C_VALID_FORMULA'
    EXPORTING  VKAPF_IMP = X
*   IMPORTING IDENT_EXP  = MFHM-EWFORM.
    IMPORTING IDENT_EXP  = HEWFORM.

  IF DISPLAY IS INITIAL.        " //br200896
    MFHM-EWFORM = HEWFORM.      "
  ENDIF.                        "

ENDMODULE.
