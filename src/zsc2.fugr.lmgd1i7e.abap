*------------------------------------------------------------------
*Module MEABM_HELP
*Aufruf der speziellen Eingabehilfe für Längeneinheiten (Abmessungen)
*------------------------------------------------------------------
MODULE MEABM_HELP.

  PERFORM SET_DISPLAY.

  GET CURSOR FIELD FELD1.

  CALL FUNCTION 'UNIT_OF_MEASUREMENT_HELP'
       EXPORTING
             CUCOL              = 0
             CUROW              = 0
             DIMID              = DIMID_LENGTH
             DISPLAY            = DISPLAY
        IMPORTING
             SELECT_UNIT        = HMEINH.

  ASSIGN (FELD1) TO <F1>.
  <F1> = HMEINH.

ENDMODULE.
