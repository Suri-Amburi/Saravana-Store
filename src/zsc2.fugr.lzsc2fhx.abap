*----------------------------------------------------------------------*
*   INCLUDE LMGD2FHX                                                   *
*----------------------------------------------------------------------*

*------------------------------------------------------------------
*Formroutinen für die speziellen Help-Module zur Eingabehilfe
*------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Aufruf der speziellen Eingabehilfe für EINE-RDPRF
*&---------------------------------------------------------------------*
MODULE EINE-RDPRF_HELP INPUT.

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'MARC_RDPRF_HELP'
       EXPORTING WERK     = EINE-WERKS
                 DISPLAY  = DISPLAY
                 NO_REFWK = X
       IMPORTING RDPRF   = EINE-RDPRF.

ENDMODULE.                 " EINE-RDPRF_HELP  INPUT

