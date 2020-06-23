*&---------------------------------------------------------------------*
*&      Form  NTGEW_ANZEIGEN
*&---------------------------------------------------------------------*
*       Nettogewicht ist bei alternativMEs zur Eingabe gesperrt.       *
*----------------------------------------------------------------------*
FORM NTGEW_ANZEIGEN.

  LOOP AT SCREEN.
*   if screen-group1 = '005'.   mk/4.0A
    IF SCREEN-GROUP1 = '005' OR SCREEN-GROUP2 = '005'.
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


ENDFORM.                               " NTGEW_ANZEIGEN
