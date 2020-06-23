*&---------------------------------------------------------------------*
*&      Form  MEINH_UMRECH_ANZEIGEN
*&---------------------------------------------------------------------*
*       Mengeneinheit und Umrechnungsfaktoren zur Eingabe sperren.     *
*----------------------------------------------------------------------*
FORM MEINH_UMRECH_ANZEIGEN.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP1 = '002' OR
       SCREEN-GROUP2 = '001' OR SCREEN-GROUP2 = '002'.  "mk/4.0A
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " MEINH_UMRECH_ANZEIGEN
