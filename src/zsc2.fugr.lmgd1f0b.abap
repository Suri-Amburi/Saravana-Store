*&---------------------------------------------------------------------*
*&      Form  MODIF_ZEILE
*&---------------------------------------------------------------------*
*Die fehlerhaften Zeilen werden helleuchten angezeigt.
*------------------------------------------------------------------
FORM MODIF_ZEILE.

  LOOP AT SCREEN.
*   if screen-group1 = '001.  "mk/4.0A
    IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001'.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " MODIF_ZEILE
