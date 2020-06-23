*------------------------------------------------------------------
*Module MEKFM_HELP
*Aufruf der speziellen Eingabehilfe für kaufm. Maßeinheiten
*------------------------------------------------------------------
MODULE MEKFM_HELP.

  PERFORM SET_DISPLAY.

  GET CURSOR FIELD FELD1.

  CALL FUNCTION 'UNIT_OF_MEASUREMENT_HELP'
       EXPORTING
             CUCOL              = 0
             CUROW              = 0
*            DIMID              = SPACE
             BUSINESS_UOM       = X
             DISPLAY            = DISPLAY
        IMPORTING
             SELECT_UNIT        = HMEINH.

  ASSIGN (FELD1) TO <F1>.
  <F1> = HMEINH.

ENDMODULE.
