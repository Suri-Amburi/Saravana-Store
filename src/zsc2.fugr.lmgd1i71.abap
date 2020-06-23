*----------------------------------------------------------------------*
*       Aufruf der speziellen Eingabehilfe für MARC-MRPPP              *
*----------------------------------------------------------------------*
MODULE MARC-MRPPP_HELP.
 PERFORM SET_DISPLAY.

 CALL FUNCTION 'MARC_MRPPP_HELP'
      EXPORTING WERK    = MARC-WERKS
                DISPLAY = DISPLAY
      IMPORTING MRPPP   = MARC-MRPPP.
ENDMODULE.
