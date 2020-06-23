*&---------------------------------------------------------------------*
*&      Module  OK_CODE_EAN_ZUS  INPUT
*&---------------------------------------------------------------------*
FORM OK_CODE_EAN_ZUS.

*--Ermitteln der aktuellen Anzahl Einträge
  DESCRIBE TABLE MEAN_ME_TAB LINES EAN_LINES.

  CASE RMMZU-OKCODE.
*------Zurück -------------------------------------------------------
    WHEN FCODE_BABA.
      CLEAR RMMZU-EINIT. " Initflag wird bei Verlassen d. Bildes
                                       " zurückgesetzt

*----- Erste Seite - Zus. EAN First Page -----------------------------
    WHEN FCODE_EAFP.
      PERFORM FIRST_PAGE USING EAN_ERSTE_ZEILE.

*----- Seite vor - Zus. EAN  Next Page --------------------------------
    WHEN FCODE_EANP.
      PERFORM NEXT_PAGE USING EAN_ERSTE_ZEILE EAN_ZLEPROSEITE
                              EAN_LINES.

*----- Seite zurueck - Zus. EAN previous Page ------------------------
    WHEN FCODE_EAPP.
      PERFORM PREV_PAGE USING EAN_ERSTE_ZEILE EAN_ZLEPROSEITE.

*----- Bottom - Zus. EAN Last Page -----------------------------------
    WHEN FCODE_EALP.
      PERFORM LAST_PAGE USING EAN_ERSTE_ZEILE EAN_LINES
                              EAN_ZLEPROSEITE X.

*-------andere----------------------------------------------------------
*   WHEN OTHERS.
*     IF EAN_FEHLERFLG    IS INITIAL AND
*        EAN_FEHLERFLG_ME IS INITIAL.
*       CLEAR RMMZU-EINIT.
*     ENDIF.

  ENDCASE.

ENDFORM.                               " OK_CODE_EAN_ZUS  INPUT
