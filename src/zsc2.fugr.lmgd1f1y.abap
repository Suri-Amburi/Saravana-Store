*&---------------------------------------------------------------------*
*&      Form  LAST_PAGE
*&      Blättern zur letzten Seite
*&---------------------------------------------------------------------*
FORM LAST_PAGE USING ERSTE_ZEILE LIKE SY-TABIX
                     LINES       LIKE SY-TABIX
                     ZLEPROSEITE LIKE SY-LOOPC
                     NEW_LINE    LIKE SY-DATAR.

DATA: HELP LIKE SY-TABIX.

  ERSTE_ZEILE = LINES - ZLEPROSEITE.

  IF ERSTE_ZEILE < 0.
    ERSTE_ZEILE = 0.
  ENDIF.

  IF NEW_LINE NE SPACE.
    HELP = ERSTE_ZEILE + ZLEPROSEITE.
    IF T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ
       AND HELP LE LINES.
      ERSTE_ZEILE = ERSTE_ZEILE + 1.
    ENDIF.
  ENDIF.

  PERFORM PARAM_SET.

ENDFORM.          "LAST_PAGE
