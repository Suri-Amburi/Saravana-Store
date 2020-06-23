*&---------------------------------------------------------------------*
*&      Form  TMLEA_AKT_MEINH
*&---------------------------------------------------------------------*
*       Aktualisieren der Tabelle TMLEA bei geänderter EAN
*       Form wird nur im Retail-Fall aufgerufen
*----------------------------------------------------------------------*
* AHE: 19.06.96 - Neues Form ! !
FORM TMLEA_AKT_MEINH.

* TMLEA nur updaten, wenn in POP-UP mit Abfrage "Ändern"
* "JA" angegeben wurde (s. Modul SMEINH_EAN11).
  CHECK FLAG_EXIT IS INITIAL.

* Aktualisieren aller Lieferantenbeziehungen für die EAN,
* falls sie geändert wurde.
  CHECK NOT EAN_UPD IS INITIAL. " wenn nicht initial -> EAN geändert

  if rmmw2-attyp = '01' and not rmmw2-varnr is initial.
* Variantenartikelfall
   READ TABLE TMLEA WITH KEY MATNR = RMMW2-varnr
                            MEINH = MEINH-MEINH
*                           LIFNR = RMMW2_LIEF
*                           EAN11 = MEINH-EAN11
                                    BINARY SEARCH.
  IF SY-SUBRC = 0.
    HTABIX = SY-TABIX.

    LOOP AT TMLEA FROM HTABIX.
      IF TMLEA-MATNR NE RMMW2-varnr OR
         TMLEA-MEINH NE MEINH-MEINH.
        EXIT.
      ENDIF.
      IF TMLEA-EAN11 = EAN_UPD.
*       alte noch upzudatende EAN durch neue ersetzen; hier werden
*       nur Sätze zu Lieferanten ungleich dem aktuellen bearbeitet,
*       da der Satz für den aktuellen Lieferanten beim Ändern gelöscht
*       und hier (oben) wieder mit neuer EAN eingefügt wurde.
        TMLEA-EAN11 = MEINH-EAN11.
        MODIFY TMLEA.
      ENDIF.
    ENDLOOP.
  ENDIF.

 else.
* Sammelartikel oder Normalfall
  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                            MEINH = MEINH-MEINH
*                           LIFNR = RMMW2_LIEF
*                           EAN11 = MEINH-EAN11
                                    BINARY SEARCH.
  IF SY-SUBRC = 0.
    HTABIX = SY-TABIX.

    LOOP AT TMLEA FROM HTABIX.
      IF TMLEA-MATNR NE RMMW1_MATN OR
         TMLEA-MEINH NE MEINH-MEINH.
        EXIT.
      ENDIF.
      IF TMLEA-EAN11 = EAN_UPD.
*       alte noch upzudatende EAN durch neue ersetzen; hier werden
*       nur Sätze zu Lieferanten ungleich dem aktuellen bearbeitet,
*       da der Satz für den aktuellen Lieferanten beim Ändern gelöscht
*       und hier (oben) wieder mit neuer EAN eingefügt wurde.
        TMLEA-EAN11 = MEINH-EAN11.
        MODIFY TMLEA.
      ENDIF.
    ENDLOOP.
  ENDIF.

 endif.

  CLEAR: EAN_UPD.

ENDFORM.                               " TMLEA_AKT_MEINH
