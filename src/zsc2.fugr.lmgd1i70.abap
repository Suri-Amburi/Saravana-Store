*----------------------------------------------------------------------*
*       Aufruf der speziellen Eingabehilfe für MARC-RDPRF              *
*----------------------------------------------------------------------*
MODULE MARC-RDPRF_HELP.
 PERFORM SET_DISPLAY.

 CALL FUNCTION 'MARC_RDPRF_HELP'
      EXPORTING WERK    = MARC-WERKS
                DISPLAY = DISPLAY
      IMPORTING RDPRF   = MARC-RDPRF.
ENDMODULE.
