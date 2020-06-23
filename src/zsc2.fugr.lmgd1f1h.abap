*&---------------------------------------------------------------------*
*&      Form  DEL_EAN_LIEF
*&---------------------------------------------------------------------*
*       Prüft, ob bei einer zu löschenden EAN ein Lieferantenbezug
*       besteht. Wenn ja, werden alle Lieferantenbezüge zur EAN
*       mitgelöscht, falls dies in einem Pop-UP bestätigt wurde.
*       Form wird nur im Retail-Fall aufgerufen.
*----------------------------------------------------------------------*
* AHE: 11.06.96 - Neues Form ! !
FORM DEL_EAN_LIEF USING FLAG_EXIT TYPE C.

  CLEAR FLAG_EXIT.

* Check, ob Lieferantenbezug besteht:
  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                            MEINH = MEAN_ME_TAB-MEINH
*                           LIFNR = RMMW2_LIEF
                            EAN11 = MEAN_ME_TAB-EAN11.
*                                    BINARY SEARCH.   BKE 419340
  CHECK SY-SUBRC = 0.
* es existiert ein relevanter Lieferantenbezug zur EAN
* Pop-Up: Löschen Ja / Nein aufrufen
  CLEAR TITEL_BUF.
  CONCATENATE TEXT-070 MEAN_ME_TAB-EAN11 INTO TITEL_BUF
              SEPARATED BY LEERZ.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
       EXPORTING
            DEFAULTOPTION = 'N'        " NEIN-Button vorwählen
            TEXTLINE1     = TEXT-071
            TEXTLINE2     = TEXT-072
            TITEL         = TITEL_BUF
*           START_COLUMN  = 25
*           START_ROW     = 6
       IMPORTING
            ANSWER        = ANTWORT.

  IF ANTWORT NE 'J'.
*  "Löschen ?" wurde mit NEIN oder Abbruch bestätigt !
    FLAG_EXIT = ANTWORT.               " N oder A ! !
    EXIT.                              " -> raus aus Form-Routine
  ENDIF.

* => Löschen wird durchgeführt -> alle Lieferantenbezüge zu
*  Material, Mengeneinheit und EAN werden aus TMLEA gelöscht !

  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                            MEINH = MEAN_ME_TAB-MEINH
*                           LIFNR = RMMW2_LIEF
*                           EAN11 = MEAN_ME_TAB-EAN11
                                    BINARY SEARCH.
  IF SY-SUBRC = 0.
    HTABIX = SY-TABIX.

    CLEAR LIEF_TAB. REFRESH LIEF_TAB.
    CLEAR FLAG_LFEAN_MSG.

    LOOP AT TMLEA FROM HTABIX.
      IF TMLEA-MATNR NE RMMW1_MATN OR
         TMLEA-MEINH NE MEAN_ME_TAB-MEINH.
        EXIT.
      ENDIF.
      IF TMLEA-EAN11 = MEAN_ME_TAB-EAN11.
*     Zuerst prüfen, ob für einen Lieferanten ungleich dem
*     aktuellen Lieferanten der Satz mit gesetztem Haupt-EAN-Lief
*     (LFEAN) gelöscht werden soll. Falls ja, wird dieser Lieferant
*     in LIEF_TAB vermerkt. Für alle Lief. in LIEF_TAB muß das
*     KZ (LFEAN) neu vergeben werden, falls hier nicht der letzte
*     Eintrag zum Lieferanten gelöscht wird.
        IF TMLEA-LIFNR NE RMMW2_LIEF  AND
           NOT TMLEA-LFEAN IS INITIAL.
          LIEF_TAB-LIFNR = TMLEA-LIFNR.
          APPEND LIEF_TAB.
        ENDIF.
*     Lieferantenbezug zur EAN löschen
        DELETE TMLEA.
      ENDIF.
    ENDLOOP.

*   Kennzeichen Haupt-EAN-Lief wird für alle Lieferanten aus LIEF_TAB
*   automatisch neu vergeben. Zuerst wird versucht, das Kennzeichen
*   für die erste EAN der selben Mengeneinheit zu vergeben.
    LOOP AT LIEF_TAB.
      READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                                MEINH = MEAN_ME_TAB-MEINH
                                LIFNR = LIEF_TAB-LIFNR
*                               EAN11 = MEAN_ME_TAB-EAN11
                                        BINARY SEARCH.
      IF SY-SUBRC = 0.
        HTABIX = SY-TABIX.
        TMLEA-LFEAN = X.
        MODIFY TMLEA INDEX HTABIX.
        FLAG_LFEAN_MSG = X.

* AHE: 23.08.96 - A
*     ELSE.
*     Fall: kein Eintrag zum Lieferanten zur hier bearbeiteten
*     Mengeneinheit mehr vorhanden (der letzte Satz dazu wurde gerade
*     gelöscht). -> Erste EAN zum Lieferanten wird zur Haupt-EAN-Lief,
*     falls noch ein Eintrag vorhanden ist.
*       CLEAR TMLEA.
*       READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
*                                 MEINH = MEAN_ME_TAB-MEINH
*        s. Bemerkung !!          LIFNR = LIEF_TAB-LIFNR
*                                 EAN11 = MEAN_ME_TAB-EAN11
*                                         BINARY SEARCH.
* Bemerkung: "READ Table" nur mit MATNR und LIFNR als Key findet u. U.
* nicht den ersten in der Tabelle stehenden Satz (wegen Binary Search
* Verfahren). Deswegen wird hier über TMLEA geloopt -> es ist immer
* sichergestellt, daß der ERSTE Eintrag des Lieferanten zum
* Haupt-EAN-Lief gemacht wird (aus optischen Gründen wichtig !!).

*       IF SY-SUBRC = 0.
*         HTABIX = SY-TABIX.
*
*         LOOP AT TMLEA FROM HTABIX.
*           IF TMLEA-MATNR NE RMMW1_MATN.
*             EXIT.
*           ENDIF.
*           IF TMLEA-LIFNR = LIEF_TAB-LIFNR.
*             TMLEA-LFEAN = X.
*             MODIFY TMLEA.
*             FLAG_LFEAN_MSG = X.
*             EXIT.
*           ENDIF.
*         ENDLOOP.
*       ENDIF.
* AHE: 23.08.96 - E
      ENDIF.
    ENDLOOP.

*   Meldung ausgeben, wenn für betroffene Lieferanten-Bezüge das
*   Kennz. Haupt-EAN-Lief neu gesetzt wurde.
    IF NOT FLAG_LFEAN_MSG IS INITIAL.
      MESSAGE I152(MH).
    ENDIF.

  ENDIF.

ENDFORM.                               " DEL_EAN_LIEF
