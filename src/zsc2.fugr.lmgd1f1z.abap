* AHE: 02.06.98 - A HW 105556
*&---------------------------------------------------------------------*
*&      Form  NEXT_PAGE_VW
*&      Blättern zur nächsten Seite Verbrauchswerte
*&---------------------------------------------------------------------*
FORM NEXT_PAGE_VW USING ERSTE_ZEILE   LIKE SY-TABIX
                        ZLEPROSEITE   LIKE SY-LOOPC
                        LINES         LIKE SY-TABIX.

  ERSTE_ZEILE = ERSTE_ZEILE + ZLEPROSEITE.

  IF ERSTE_ZEILE GE LINES.
*   ERSTE_ZEILE = LINES - 1.
    ERSTE_ZEILE = LINES.
  ENDIF.

  PERFORM PARAM_SET.

ENDFORM.          "NEXT_PAGE_VW
