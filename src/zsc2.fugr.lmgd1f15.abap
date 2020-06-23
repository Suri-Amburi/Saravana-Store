*&---------------------------------------------------------------------*
*&      Form  ME_MODIF_ZEILE
*&---------------------------------------------------------------------*
*   Die fehlerhaften Zeilen werden helleuchtend angezeigt.
*----------------------------------------------------------------------*
FORM ME_MODIF_ZEILE.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP1 = '002' OR
       SCREEN-GROUP2 = '001' OR SCREEN-GROUP2 = '002'.  "mk/4.0A
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
* Zur Cursorpositionierung
  MOVE SY-STEPL TO ME_ZEILEN_NR.

ENDFORM.                               " ME_MODIF_ZEILE
