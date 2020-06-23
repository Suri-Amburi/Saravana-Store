*----------------------------------------------------------------------*
*       Aufruf der speziellen Eingabehilfe für MARC-LFRHY              *
*----------------------------------------------------------------------*
MODULE MARC-LFRHY_HELP.
 PERFORM SET_DISPLAY.

 CALL FUNCTION 'MARC_LFRHY_HELP'
      EXPORTING WERK    = MARC-WERKS
                DISPLAY = DISPLAY
      IMPORTING LFRHY   = MARC-LFRHY.
ENDMODULE.                 " MARC-LFRHY_HELP  INPUT
