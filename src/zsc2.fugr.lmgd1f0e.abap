*&---------------------------------------------------------------------*
*&      Form  OK_CODE_VERBRAUCH
*&---------------------------------------------------------------------*
FORM OK_CODE_VERBRAUCH.

  CASE RMMZU-OKCODE.
    WHEN FCODE_BABA.
      CLEAR RMMZU-VWINIT. "clear Initflag beim Verlassen d. Bildes
*----- Erste Seite - Steuern First Page ------------------------------
    WHEN FCODE_VWFP.
      PERFORM FIRST_PAGE USING VW_ERSTE_ZEILE.
*----- Seite vor - Steuern Next Page ---------------------------------
    WHEN FCODE_VWNP.
* AHE: 02.06.98 - A HW 105556
* die Korrektur wirkt ab 4.0 nicht mehr, da die VB-Werte dann mit TC
* pflegbar sind. Fehler liegt dann in falsch gesetztem
* TC_VERB-TOP_LINE im PAI, der dann VW_ERSTE_ZEILE falsch belegt.
* --> Basis ??
*     PERFORM NEXT_PAGE USING VW_ERSTE_ZEILE VW_ZLEPROSEITE
*                             VW_LINES.
      PERFORM NEXT_PAGE_VW USING VW_ERSTE_ZEILE VW_ZLEPROSEITE
                                 VW_LINES.
* AHE: 02.06.98 - E
*----- Seite zurueck - Steuern Previous Page -------------------------
    WHEN FCODE_VWPP.
      PERFORM PREV_PAGE USING VW_ERSTE_ZEILE VW_ZLEPROSEITE.

*----- Bottom - Steuern Last Page ------------------------------------
    WHEN FCODE_VWLP.
      PERFORM LAST_PAGE USING VW_ERSTE_ZEILE VW_LINES
                              VW_ZLEPROSEITE SPACE.
    WHEN FCODE_GESV.
      KZVERB = 'G'.   " zugehöriger Text wird in PBO-Module gesetzt
*           Weiters Handling für FCODE in Bildfolge (T133D)
*   AHE: 17.09.96 - A
*   OKCODE-Handling komplett hierher verlegt
      BILDFLAG = X.
      CLEAR RMMZU-OKCODE.
*   AHE: 17.09.96 - E
    WHEN FCODE_UNGV.
      KZVERB = 'U'.   " zugehöriger Text wird in PBO-Module gesetzt
*           Weiters Handling für FCODE in Bildfolge (T133D)
*   AHE: 17.09.96 - A
*   OKCODE-Handling komplett hierher verlegt
      BILDFLAG = X.
      CLEAR RMMZU-OKCODE.
*   AHE: 17.09.96 - E

*----- SPACE - Enter -------------------------------------------------
    WHEN FCODE_SPACE.
*           Datenfreigabe in Bildfolge (T133D) behandelt

* ---- Sonstige Funktionen wie Springen etc. --------------------------
    WHEN OTHERS.

"{ Begin ENHO AD_MPN_PUR2_LMGD1F0E IS-AD-MPN AD_MPN_IC }
*    A&D 3.0; MPN-Projekt; Cora Zimmermann; 24.11.1998
*    special ok-codes for total consumption display
*       perform mpn_ok_code_verbrauch changing rmmzu-okcode.
* Wolfgang Kalthoff
       CALL FUNCTION 'PIC_OK_CODE_VERBRAUCH'
            CHANGING
                 OKCODE  = rmmzu-okcode.

*       perform mpn_ok_code_verbrauch(sy-repid) changing rmmzu-okcode
*         if found.
"{ End ENHO AD_MPN_PUR2_LMGD1F0E IS-AD-MPN AD_MPN_IC }

ENHANCEMENT-POINT OK_CODE_VERBRAUCH_01 SPOTS ES_LMGD1F0E INCLUDE BOUND.
  ENDCASE.

ENDFORM.                               " OK_CODE_VERBRAUCH
