*&---------------------------------------------------------------------*
*&      Form  OK_CODE_PROGNOSE
*&---------------------------------------------------------------------*
FORM OK_CODE_PROGNOSE.

  CASE RMMZU-OKCODE.
    WHEN FCODE_BABA.
      CLEAR RMMZU-PWINIT. "clear Initflag beim Verlassen d. Bildes
*----- Erste Seite - Steuern First Page ------------------------------
    WHEN FCODE_PWFP.
      PERFORM FIRST_PAGE USING PW_ERSTE_ZEILE.
*----- Seite vor - Steuern Next Page ---------------------------------
    WHEN FCODE_PWNP.
      PERFORM NEXT_PAGE USING PW_ERSTE_ZEILE PW_ZLEPROSEITE
                              PW_LINES.
*----- Seite zurueck - Steuern Previous Page -------------------------
    WHEN FCODE_PWPP.
      PERFORM PREV_PAGE USING PW_ERSTE_ZEILE PW_ZLEPROSEITE.

*----- Bottom - Steuern Last Page ------------------------------------
    WHEN FCODE_PWLP.
      PERFORM LAST_PAGE USING PW_ERSTE_ZEILE PW_LINES
                              PW_ZLEPROSEITE SPACE.

*----- SPACE - Enter -------------------------------------------------
    WHEN FCODE_SPACE.
*           Datenfreigabe in Bildfolge (T133D) behandelt

* ---- Sonstige Funktionen wie Springen etc. --------------------------
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " OK_CODE_PROGNOSE
