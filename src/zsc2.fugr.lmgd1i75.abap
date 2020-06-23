*------------------------------------------------------------------
*Module MPOP-GEWGR_HELP
*
*Aufruf der speziellen Eingabehilfe für die Gewichtungsgruppe
*------------------------------------------------------------------
MODULE MPOP-GEWGR_HELP.

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'MPOP_GEWGR_HELP'
       EXPORTING
            DISPLAY = DISPLAY
       IMPORTING
            GEWGR   = MPOP-GEWGR.

ENDMODULE.
