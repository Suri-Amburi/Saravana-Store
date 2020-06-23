*----------------------------------------------------------------------*
*       Aufruf der speziellen Eingabehilfe für MARC-RWPRO              *
*----------------------------------------------------------------------*
MODULE MARC-RWPRO_HELP.
 PERFORM SET_DISPLAY.

 CALL FUNCTION 'MARC_RWPRO_HELP'
      EXPORTING WERK    = MARC-WERKS
                DISPLAY = DISPLAY
      IMPORTING RWPRO   = MARC-RWPRO.
ENDMODULE.
