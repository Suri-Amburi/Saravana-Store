*&---------------------------------------------------------------------*
*&      Form  UPD_EAN_LIEF
*&---------------------------------------------------------------------*
*       Prüft, ob bei einer zu ändernden EAN ein Lieferantenbezug
*       besteht. Wenn ja, werden alle Lieferantenbezüge zur EAN
*       mitgeändert, falls dies in einem Pop-UP bestätigt wurde.
*       Form wird nur im Retail-Fall aufgerufen.
*----------------------------------------------------------------------*
* AHE: 12.06.96 - Neues Form ! !
FORM UPD_EAN_LIEF USING FLAG_EXIT TYPE C.

  CLEAR: FLAG_EXIT, EAN_UPD.

* Check, ob Lieferantenbezug besteht:
  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                            MEINH = MEAN_ME_TAB-MEINH
*                           LIFNR = RMMW2_LIEF
                            EAN11 = MEAN_ME_TAB-EAN11.
*                                    BINARY SEARCH.    "BKE note 898596
  IF SY-SUBRC = 0.
* es existiert ein relevanter Lieferantenbezug zur EAN
* Pop-Up: Ändern Ja / Nein aufrufen
    CLEAR TITEL_BUF.
    CONCATENATE TEXT-073 MEAN_ME_TAB-EAN11 INTO TITEL_BUF
                SEPARATED BY LEERZ.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
         EXPORTING
              DEFAULTOPTION = 'N'      " NEIN-Button vorwählen
              TEXTLINE1     = TEXT-074
              TEXTLINE2     = TEXT-075
              TITEL         = TITEL_BUF
*             START_COLUMN  = 25
*             START_ROW     = 6
         IMPORTING
              ANSWER        = ANTWORT.

    IF ANTWORT NE 'J'.
*    "Ändern ?" wurde mit NEIN oder Abbruch bestätigt !
      FLAG_EXIT = ANTWORT.             " N oder A ! !
      EXIT.                            " -> raus aus Form-Routine
    ENDIF.

*   => Ändern wird durchgeführt - > dies geschieht durch
*   merken der betroffenen EAN in EAN_UPD und Löschen des Satzes
*   für den aktuellen Lieferanten.
*   Im Form TMLEA_AKT wird für alle Sätze mit der gemerkten EAN
*   in der TMLEA die neue EAN eingetragen. Dies geschieht somit
*   für alle Lieferanten außer dem aktuellen. Der Satz mit dem aktuellen
*   Lieferanten wird neu eingefügt.

    READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                              MEINH = MEAN_ME_TAB-MEINH
*                             LIFNR = RMMW2_LIEF
*                             EAN11 = MEAN_ME_TAB-EAN11
                                      BINARY SEARCH.
    IF SY-SUBRC = 0.
      HTABIX = SY-TABIX.

      LOOP AT TMLEA FROM HTABIX.
        IF TMLEA-MATNR NE RMMW1_MATN OR
           TMLEA-MEINH NE MEAN_ME_TAB-MEINH.
          EXIT.
        ENDIF.
        IF TMLEA-EAN11 = MEAN_ME_TAB-EAN11.
          IF TMLEA-LIFNR NE RMMW2_LIEF.
* note 611579
            IF EAN_UPD IS INITIAL.
*           Lieferantenbezug zur EAN für alle anderen Lieferanten merken
              EAN_UPD = TMLEA-EAN11.
            ENDIF.
          ELSE.
*           Satz mit aktuellem Lieferant wird gelöscht.
            DELETE TMLEA.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.                               " UPD_EAN_LIEF
