*&---------------------------------------------------------------------*
*&      Module  DATENUEBERNAHME_MEINH INPUT
*&---------------------------------------------------------------------*
*   Übernehmen der Daten in die Tabelle MEINH.                         *
*----------------------------------------------------------------------*
MODULE DATENUEBERNAHME_MEINH INPUT.

* Gleiche Abfrage wie bei Prüfungen cfo/7.2./96
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CHECK SMEINH-MEINH NE SPACE.

*--- Übernehmen der Eingabe.
  MODIFY MEINH INDEX ME_AKT_ZEILE.
  CLEAR SMEINH.

* AHE: 19.06.96 - A
  IF NOT RMMG2-FLG_RETAIL IS INITIAL.
*   Retail-Fall: EAN-Lieferantenbezug-Handling
*   Wenn ein Abfrage-Pop-UP mit "NEIN" verlassen wurde, darf die EAN
*   nicht geändert werden
    CHECK FLAG_EXIT NE 'N'.

    PERFORM TMLEA_AKT_MEINH.           "aktualisieren der TMLEA
  ENDIF.
* AHE: 19.06.96 - E


ENDMODULE.                             " DATENUEBERNAHME_MEINH INPUT
