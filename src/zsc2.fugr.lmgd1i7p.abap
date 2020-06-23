*----------------------------------------------------------------------*
*   INCLUDE LMGD1I7P                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  MESUB_HELP  INPUT
*&---------------------------------------------------------------------*
*       jw/4.6A: F4-Hilfe für die untergeordnete Mengeneinheit
*----------------------------------------------------------------------*

MODULE MESUB_HELP INPUT.

  PERFORM SET_DISPLAY.

*  CALL FUNCTION 'SMEINH_MEINH_HELP'
*       EXPORTING
*            DISPLAY = DISPLAY
*            P_MATNR = mara-matnr
*       IMPORTING
*            MEINH   = smeinh-mesub
*       EXCEPTIONS
*            OTHERS  = 1.

  PERFORM SMEINH_MESUB_HELP.

ENDMODULE.                             " MESUB_HELP  INPUT
































