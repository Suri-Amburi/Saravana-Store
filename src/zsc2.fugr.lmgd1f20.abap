*&---------------------------------------------------------------------*
*&      Form  NEXT_PAGE
*&      Blättern zur nächsten Seite
*&---------------------------------------------------------------------*
FORM NEXT_PAGE USING ERSTE_ZEILE   LIKE SY-TABIX
                     ZLEPROSEITE   LIKE SY-LOOPC
                     LINES         LIKE SY-TABIX.

  ERSTE_ZEILE = ERSTE_ZEILE + ZLEPROSEITE.

  IF ERSTE_ZEILE GE LINES.
    ERSTE_ZEILE = LINES - 1.
  ENDIF.

  PERFORM PARAM_SET.

ENDFORM.          "NEXT_PAGE
