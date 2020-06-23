*&---------------------------------------------------------------------*
*&      Module  EAN_INITIALISIERUNG  OUTPUT
*&---------------------------------------------------------------------*
*       Setzen Initflag, Ermitteln Anzahl Zeilen, Mengeneinheiten
*       aus Mengeneinh.-Bild auch ohne EANs vorblenden.
*----------------------------------------------------------------------*
MODULE EAN_INITIALISIERUNG OUTPUT.

  IF RMMZU-EINIT IS INITIAL.
    RMMZU-EINIT = X.
    CLEAR: EAN_ERSTE_ZEILE.
  ENDIF.

  CLEAR: EAN_ZEILEN_NR.

  IF T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
    LOOP AT MEINH.
      READ TABLE MEAN_ME_TAB WITH KEY MEINH-MEINH.
      IF SY-SUBRC NE 0.
*       noch kein Eintrag zur Mengeneinheit im Bild Zus. EAN vorhanden
*       Mengeneinheit aus MEINH mit leeren Einträgen übernehmen
*       als Voreinstellung
*       Solche Einträge werden am Ende des Bildes wieder gelöscht
*       (Modul CLEAN_MEINH);
        CLEAR MEAN_ME_TAB.
        MEAN_ME_TAB-MEINH = MEINH-MEINH.
        APPEND MEAN_ME_TAB.
      ENDIF.
    ENDLOOP.
  ENDIF.


* AHE: 04.06.96 - A
* Retail-Fall: EAN-Lieferantenbezug-Handling
  IF NOT RMMG2-FLG_RETAIL IS INITIAL.
* Lieferant (aus RMMW2) lesen für Zuordnung EAN - Lieferant
* RMMW2-LIFNR wird aus RMMW1-LIFNR im Keyumsetzer versorgt. RMMW1-LIFNR
* ist der aktuelle Lieferant, der auch im Kopf-Subscreen angezeigt wird.
* Außerdem wird die MATNR aus dem Kopf-Subscreen besorgt.
    CALL FUNCTION 'GET_ZUS_RETAIL'
         IMPORTING
              RMMW2_LIFNR = RMMW2_LIEF
              RMMW1_MATNR = RMMW1_MATN

* AHE: 01.03.99 - A (4.6a)
* bei der Pflege einer Variante muß RMMW2_VARN genommen werden, da in
* RMMW1_MATN der Sammelartikel steht.
*             RMMW2_VARNR = RMMW2_VARN.
              RMMW2_VARNR = RMMW2_VARN.

    IF NOT RMMW2_VARN IS INITIAL.
      RMMW1_MATN = RMMW2_VARN.       " wegen Verwendung RMMW1_MATN
    ENDIF.
* AHE: 01.03.99 - E

  ENDIF.
* AHE: 04.06.96 - E


* Sortierung notwendig für Feldauswahl
  SORT MEAN_ME_TAB BY MEINH EAN11.

* Initialisieren der Kennzeichen zur Aktualisierung von int. Tabellen
  CLEAR: MEAN_ME_TAB_CHECK,
         HILFS_MEEIN.                  " für Feldauswahl

*--Ermitteln der aktuellen Anzahl Einträge ME - EANs
  DESCRIBE TABLE MEAN_ME_TAB LINES EAN_LINES.

* AHE: 15.07.96 - A
* Umstellung auf Table-Control
  IF NOT FLG_TC IS INITIAL.
    REFRESH CONTROL 'TC_EAN' FROM SCREEN SY-DYNNR.
    TC_EAN-LINES    = EAN_LINES.
    TC_EAN-TOP_LINE = EAN_ERSTE_ZEILE + 1.
    TC_EAN_TOPL_BUF = TC_EAN-TOP_LINE. " Puffer für TCtrl
    ASSIGN TC_EAN TO <F_TC>.           "wk/4.0
  ENDIF.
* AHE: 15.07.96 - E

ENDMODULE.                             " EAN_INITIALISIERUNG  OUTPUT
