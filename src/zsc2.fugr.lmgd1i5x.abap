*&---------------------------------------------------------------------*
*&      Module  RM03E-MEGRP_HELP  INPUT
*&---------------------------------------------------------------------*
*       Aufruf spezielle Eingabehilfe für Mengeneinheiten.             *
*----------------------------------------------------------------------*
MODULE RM03E-MEGRP_HELP INPUT.

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'RM03E_MEGRP_HELP'
       EXPORTING
            DISPLAY = DISPLAY
       IMPORTING
            MEGRP   = RM03E-MEGRP.

ENDMODULE.                             " RM03E-MEGRP_HELP  INPUT
