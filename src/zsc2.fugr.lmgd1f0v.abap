*&---------------------------------------------------------------------*
*&      Form  UMRECH_ANZEIGEN
*&---------------------------------------------------------------------*
*       Umrechnungsfaktoren zur Eingabe sperren.                       *
*----------------------------------------------------------------------*
FORM UMRECH_ANZEIGEN.

  LOOP AT SCREEN.
*   if screen-group1 = '002'.  mk/4.0A
    IF SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002'.
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " UMRECH_ANZEIGEN
