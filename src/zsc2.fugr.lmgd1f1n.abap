*&---------------------------------------------------------------------*
*&      Form  TMLEA_AKT
*&---------------------------------------------------------------------*
*       Aktualisieren der Tabelle TMLEA (Liefbez. - EAN)
*       Form wird nur im Retail-Fall aufgerufen
*----------------------------------------------------------------------*
* AHE: 06.06.96 - Neues Form ! !
FORM TMLEA_AKT.

* AHE: 28.01.99 - A (4.6a)
  REFRESH HMLEA. CLEAR HMLEA.
* AHE: 28.01.99 - E

  IF SY-STEPL = 1.
    CLEAR MLEA_LFEAN_KEY.
  ENDIF.

* TMLEA nur updaten, wenn in POP-UP mit Abfrage "Löschen" oder "Ändern"
* "JA" angegeben wurde (s. Modul CHECK_EAN_ZUS).
  CHECK FLAG_EXIT IS INITIAL.

* MLEA updaten wenn die MENGENEINHEIT auch gefuellt ist        321772
  CHECK NOT MEAN_ME_TAB-MEINH IS INITIAL.


  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                            MEINH = MEAN_ME_TAB-MEINH
                            LIFNR = RMMW2_LIEF
                            EAN11 = MEAN_ME_TAB-EAN11 BINARY SEARCH.
  HTABIX = SY-TABIX.
  IF SY-SUBRC = 0.
* Lieferantenbezug vorhanden in TMLEA
    IF RMMZU-LIEFZU IS INITIAL.
*   Lieferantenbezug wurde gelöscht auf Bild
*   -> es darf hier auch keine Haupt-EAN-Lief gesetzt sein !
      IF NOT TMLEA-LFEAN IS INITIAL.
        CLEAR MLEA-LFEAN.              " Dynpro-Feld ! !
* AHE: 27.01.99 - A ( 4.6a)
        CLEAR MLEA-LARTN.              " Dynprofeld
* AHE: 27.01.99 - E
      ENDIF.
      DELETE TMLEA INDEX HTABIX.
* AHE: 23.08.96 - A
    ELSE.
*   Lieferantenbezug unverändert, evtl. aber MLEA-LFEAN verändert
      TMLEA-LFEAN = MLEA-LFEAN.
*     Wenn LFEAN leer, dann LARTN auch löschen
      IF TMLEA-LFEAN IS INITIAL.
        clear TMLEA-LARTN.
        clear MLEA-LARTN.
      ENDIF.
* AHE: 27.01.99 - A ( 4.6a)
* Lieferanten-Artikel-Nummer übernehmen
      IF NOT MLEA-LARTN IS INITIAL.
        TMLEA-LARTN = MLEA-LARTN.
      ELSE.
*       LARTN von evtl. anderer Haupt-EAN-Lief dieser Meinh übernehmen
        HMLEA[] = LMLEA[].
        READ TABLE HMLEA WITH KEY MATNR = RMMW1_MATN
                                  MEINH = MEAN_ME_TAB-MEINH
                                  LIFNR = RMMW2_LIEF
*                                 EAN11 = MEAN_ME_TAB-EAN11
                                  BINARY SEARCH.
        HTABIX_EAN = SY-TABIX.
        IF SY-SUBRC = 0.
          LOOP AT HMLEA FROM HTABIX_EAN.
            IF HMLEA-MATNR <> RMMW1_MATN OR
               HMLEA-MEINH <> MEAN_ME_TAB-MEINH OR
               HMLEA-LIFNR <> RMMW2_LIEF.
              EXIT.
            ENDIF.
            IF NOT HMLEA-LFEAN IS INITIAL.
              IF HMLEA-EAN11 <> MEAN_ME_TAB-EAN11.
*               ggf. LARTN von der alten Haupt-EAN übernehmen.
                IF NOT TMLEA-LFEAN IS INITIAL.
                 TMLEA-LARTN = HMLEA-LARTN.  " Tabellenfeld belegen
                ENDIF.
                EXIT.
              ELSE.
*               Löschfall
                CLEAR TMLEA-LARTN.
              ENDIF.
            ELSE.
              CLEAR TMLEA-LARTN.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
* AHE: 27.01.99 - E
      MODIFY TMLEA INDEX HTABIX.
* AHE: 23.08.96 - E
    ENDIF.
  ELSE.
*   noch kein Lieferantenbezug vorhanden
* AHE:_ 27.01.99 - A (4.6a)
*   IF NOT RMMZU-LIEFZU IS INITIAL
    IF NOT RMMZU-LIEFZU IS INITIAL AND
       NOT RMMW2_LIEF IS INITIAL.
* AHE: 27.01.99 - E
*   Lieferantenbezug neu gesetzt
      TMLEA-MANDT = SY-MANDT.
      TMLEA-MATNR = RMMW1_MATN.
      TMLEA-MEINH = MEAN_ME_TAB-MEINH.
      TMLEA-LIFNR = RMMW2_LIEF.
      CLEAR TMLEA-LFNUM.
      TMLEA-EAN11 = MEAN_ME_TAB-EAN11.
* AHE: 23.08.96 - A
*     CLEAR TMLEA-LFEAN.               " wird später gesetzt
      TMLEA-LFEAN = MLEA-LFEAN.        " Haupt-EAN-Lief pro Meinh setzen

* AHE: 27.01.99 - A ( 4.6a)
      TMLEA-LARTN = MLEA-LARTN.
* AHE: 27.01.99 - E

* AHE: 23.08.96 - E
      INSERT TMLEA INDEX HTABIX.
*     TMLEA ist sortiert nach MATNR, MEINH, LIFNR und EAN11 !
    ENDIF.
  ENDIF.

* AHE: 23.08.96 - A
* >> jetzt Haupt-EAN-Lief pro Mengeneinheit !!

* falls MLEA-LFEAN gesetzt wurde (Haupt-Lief in MLEA), merken
* des Keys und nach Step-Loop-Abarbeitung TMLEA updaten.
* Eindeutigkeit des Keys ist gesichert, da MLEA-LFEAN als Radiobutton
* definiert ist.

* IF NOT MLEA-LFEAN IS INITIAL AND
*    NOT RMMZU-LIEFZU IS INITIAL.
*   MLEA_LFEAN_KEY-MEINH = MEAN_ME_TAB-MEINH.
*   MLEA_LFEAN_KEY-EAN11 = MEAN_ME_TAB-EAN11.
* ENDIF.
* AHE: 23.08.96 - E

* Aktualisieren aller weiterer Lieferantenbeziehungen für die EAN,
* falls sie geändert wurde.
  CHECK NOT EAN_UPD IS INITIAL. " wenn nicht initial -> EAN geändert

  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                            MEINH = MEAN_ME_TAB-MEINH
*                           LIFNR = RMMW2_LIEF
*                           EAN11 = MEAN_ME_TAB-EAN11
                                    BINARY SEARCH.
  IF SY-SUBRC = 0.
    HTABIX = SY-TABIX.

    LOOP AT TMLEA FROM HTABIX.
      IF TMLEA-MATNR NE RMMW1_MATN OR
         TMLEA-MEINH NE MEAN_ME_TAB-MEINH.
        EXIT.
      ENDIF.
      IF TMLEA-EAN11 = EAN_UPD.
*       alte noch upzudatende EAN durch neue ersetzen; hier werden
*       nur Sätze zu Lieferanten ungleich dem aktuellen bearbeitet,
*       da der Satz für den aktuellen Lieferanten beim Ändern gelöscht
*       und hier (oben) wieder mit neuer EAN eingefügt wurde.
        TMLEA-EAN11 = MEAN_ME_TAB-EAN11.
        MODIFY TMLEA.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " TMLEA_AKT
