*&---------------------------------------------------------------------*
*&      Form  FELDER_ANZEIGEN
*&---------------------------------------------------------------------*
* Im Anzeigemodus werden die Felder nur angezeigt.
*------------------------------------------------------------------
FORM FELDER_ANZEIGEN.

  LOOP AT SCREEN.
    SCREEN-INPUT    = 0.
    SCREEN-REQUIRED = 0.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " FELDER_ANZEIGEN

*&---------------------------------------------------------------------*
*&      Form  FELDER_ANZEIGEN
*&---------------------------------------------------------------------*
* Für initiale Zeilen werden keine Mußfelder angezeigt.
*------------------------------------------------------------------
FORM RESET_REQ_FIELDS.                             "note 707765

  LOOP AT SCREEN.
    SCREEN-REQUIRED = 0.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
