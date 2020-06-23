*&---------------------------------------------------------------------*
*&      Module  BELEGEN_MEAN_ME_TAB  INPUT
*&---------------------------------------------------------------------*
*       Übernahme Daten aus Dynpro in Step-Loop Tabelle MEAN_ME_TAB
*----------------------------------------------------------------------*
MODULE BELEGEN_MEAN_ME_TAB INPUT.
* AHE: 13.06.96 - A
  IF NOT RMMG2-FLG_RETAIL IS INITIAL OR GV_FLAG_GTIN_VP = 'X'.
*   Retail-Fall: EAN-Lieferantenbezug-Handling
*   Wenn ein Abfrage-Pop-UP mit "NEIN" verlassen wurde, darf die Zeile
*   nicht geändert oder gelöscht werden (hier zunächst dann nur EAN
*   gelöscht).
    CHECK FLAG_EXIT NE 'N'.
  ENDIF.
* AHE: 13.06.96 - E

  PERFORM MEAN_ME_TAB_AKT.             "aktualisieren der MEAN_ME_TAB

* AHE: 06.06.96 - A

  IF NOT RMMG2-FLG_RETAIL IS INITIAL OR GV_FLAG_GTIN_VP = 'X'.

*   Retail-Fall: EAN-Lieferantenbezug-Handling
    PERFORM TMLEA_AKT.                 "aktualisieren der TMLEA
  ENDIF.
* AHE: 06.06.96 - E

ENDMODULE.                             " BELEGEN_MEAN_ME_TAB  INPUT
