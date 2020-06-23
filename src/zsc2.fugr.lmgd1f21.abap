*&---------------------------------------------------------------------*
*&      Form  PREV_PAGE
*&      Blättern zur vorhergehenden Seite
*&---------------------------------------------------------------------*
FORM PREV_PAGE USING ERSTE_ZEILE LIKE SY-TABIX
                     ZLEPROSEITE LIKE SY-LOOPC.

  ERSTE_ZEILE = ERSTE_ZEILE - ZLEPROSEITE.

  IF ERSTE_ZEILE < 0.
    ERSTE_ZEILE = 0.
  ENDIF.

  PERFORM PARAM_SET.

ENDFORM.          "PREV_PAGE
