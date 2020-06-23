*&---------------------------------------------------------------------*
*&      Module  MARC-EPRIO_HELP  INPUT
*&---------------------------------------------------------------------*
*                                                          *
*----------------------------------------------------------------------*
MODULE MARC-EPRIO_HELP INPUT.

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'RM_F4_EPRIO'
       EXPORTING
*           CUCOL   = 0
*           CUROW   = 0
            DISPLAY = DISPLAY
*           TITEL   = ' '
       CHANGING
            EPRIO   = MARC-EPRIO
       EXCEPTIONS
            OTHERS  = 1.

ENDMODULE.                 " MARC-EPRIO_HELP  INPUT
