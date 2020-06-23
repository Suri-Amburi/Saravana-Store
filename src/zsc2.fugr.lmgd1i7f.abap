*------------------------------------------------------------------
*Module MBEW-BKLAS_HELP.
*Aufruf der speziellen Eingabehilfe für Bewertungsklassen
*------------------------------------------------------------------
MODULE MBEW-BKLAS_HELP.

  PERFORM SET_DISPLAY.

  GET CURSOR FIELD FELD3.

  CALL FUNCTION 'MBEW_BKLAS_HELP'
       EXPORTING
            T134_KKREF = T134-KKREF
            WMBEW      = MBEW
            WT149      = T149
            WT149A     = T149A
            DISPLAY    = DISPLAY
       IMPORTING
            BKLAS      = H_BKLAS
            WT149      = T149
            WT149A     = T149A.

  CASE FELD3.
    WHEN 'MBEW-BKLAS'.
      MBEW-BKLAS =  H_BKLAS.
    WHEN 'MBEW-VMBKL'.
      MBEW-VMBKL =  H_BKLAS.
    WHEN 'MBEW-VJBKL'.
      MBEW-VJBKL =  H_BKLAS.
    WHEN 'MBEW-EKLAS'.               "ch zu 4.0
      MBEW-EKLAS =  H_BKLAS.         "ch zu 4.0
    WHEN 'MBEW-QKLAS'.               "ch zu 4.0
      MBEW-QKLAS =  H_BKLAS.         "ch zu 4.0
    WHEN 'MBEW-OKLAS'.               "ch/4.6C (wg. OBEW)
      MBEW-OKLAS =  H_BKLAS.         "ch/4.6C (wg. OBEW)
  ENDCASE.

ENDMODULE.
