*----------------------------------------------------------------------
*Module MARD_LWMKB_HELP.                                     "BE/051197
*Aufruf der speziellen Eingabehilfe für Kommissionierbereich.
*----------------------------------------------------------------------
MODULE MARD_LWMKB_HELP.                                      "BE/051197

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'MARD_LWMKB_HELP'
       EXPORTING
            DISPLAY    = DISPLAY
            WERK       = MARC-WERKS
            LAGER      = MARD-LGORT
       IMPORTING
            LWMKB      = MARD-LWMKB.

ENDMODULE.
