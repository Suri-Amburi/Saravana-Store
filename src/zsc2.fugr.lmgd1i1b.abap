*------------------------------------------------------------------
*           MAKT-Maktx
*
*Bei der Ersterfassung wird der Kurztext in die interne Tabelle
*aufgenommen, als Sprache wird die System-Anmeldesprache vorausgesetzt.
*Die nachträgliche Änderung des Kurztextes ist nur auf dem separaten
*Kurztextbild möglich (sowohl beim Erfassen weiterer Fachbereiche als
*auch beim Ändern). Dies wird über eine Sonderfeldauswahl zur
*Feldgruppe gesteuert.
*------------------------------------------------------------------
MODULE MAKT-MAKTX.
* CHECK T130M-AKTYP EQ AKTYPH AND NEUFLAG NE SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*  CHECK BILDFLAG IS INITIAL.           "mk/21.04.95
*JB/4.6C: Damit der Kurztext auf dem Langtextbild in die Puffer
*         geschrieben wird.
* note 572589 Kurztext generell in Puffer schreiben

  CHECK KZ_KTEXT_ON_DYNP IS INITIAL.   "br/04.05.95

*mk/4.0 Kopie LMGD2I05 wieder mit Original LMGD1I01 vereint
*dazu flg_retail-Abfrage ergänzt und statt Abfrage auf rmmw2-varnr
*Abfrage auf mara-attyp
  IF NOT RMMG2-FLG_RETAIL IS INITIAL.
* check rmmw2-varnr is initial. "//br030496 .. nicht bei Varianten !
    CHECK MARA-ATTYP NE ATTYP_VAR.
  ENDIF.

  CALL FUNCTION 'MAKT_MAKTX'
       EXPORTING
            MARA_MATNR = MARA-MATNR
            WMAKT      = MAKT
*      IMPORTING                          "br/08.05.95
*           KT_FLAG1   = RMMZU-KT_FLAG1   "br/08.05.95
       TABLES
            T_KTEXT    = KTEXT.


ENDMODULE.
