*------------------------------------------------------------------
*Module MFHM-MGFORM_HELP.
*Aufruf der speziellen Eingabehilfe für MFHM-MGFORM
*------------------------------------------------------------------
MODULE MFHM-MGFORM_HELP.

DATA HMGFORM LIKE MFHM-MGFORM.  " //br200896
                                "
  PERFORM SET_DISPLAY.          "

CALL FUNCTION 'C_VALID_FORMULA'
    EXPORTING  VKAPF_IMP = X
*   IMPORTING IDENT_EXP  = MFHM-MGFORM. "  //br200896
    IMPORTING IDENT_EXP  = HMGFORM.     "

  IF DISPLAY IS INITIAL.        " //br200896
    MFHM-MGFORM = HMGFORM.      "
  ENDIF.                        "

ENDMODULE.
