*----------------------------------------------------------------------*
* Aufruf der speziellen Eingabehilfe für MARC-ABCIN      neu zu 4.0C/ch
*----------------------------------------------------------------------*
MODULE MARC_ABCIN_HELP.
 PERFORM SET_DISPLAY.

 CALL FUNCTION 'MARC_ABCIN_HELP'
      EXPORTING
           WERK    = MARC-WERKS
           DISPLAY = DISPLAY
      IMPORTING
           ABCIN   = MARC-ABCIN.

ENDMODULE.
