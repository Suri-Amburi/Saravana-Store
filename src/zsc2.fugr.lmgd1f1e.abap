*&---------------------------------------------------------------------*
*&      Form  UPD_EAN_LIEF_MEINH
*&---------------------------------------------------------------------*
*       Prüft, ob bei einer zu ändernden EAN ein Lieferantenbezug
*       besteht. Wenn ja, werden alle Lieferantenbezüge zur EAN
*       mitgeändert, falls dies in einem Pop-UP bestätigt wurde.
*       Form wird nur im Retail-Fall aufgerufen.
*----------------------------------------------------------------------*
* AHE: 19.06.96 - Neues Form ! !
FORM UPD_EAN_LIEF_MEINH USING FLAG_EXIT TYPE C.

  CLEAR: FLAG_EXIT, EAN_UPD.

* Check, ob Lieferantenbezug besteht:
  IF RMMW2-attyp = '01' and NOT RMMW2-varnr is initial.
   READ TABLE TMLEA WITH KEY MATNR = RMMW2-varnr
                            MEINH = MEINH-MEINH
*                           LIFNR = RMMW2_LIEF
                            EAN11 = MEINH-EAN11
                                    BINARY SEARCH.
  else.
  READ TABLE TMLEA WITH KEY MATNR = RMMW1_MATN
                            MEINH = MEINH-MEINH
*                           LIFNR = RMMW2_LIEF
                            EAN11 = MEINH-EAN11
                                    BINARY SEARCH.
  endif.
  IF SY-SUBRC = 0.
* es existiert ein relevanter Lieferantenbezug zur EAN
* Pop-Up: Ändern Ja / Nein aufrufen
    CLEAR TITEL_BUF.
    CONCATENATE TEXT-073 MEINH-EAN11 INTO TITEL_BUF
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

* Bild wiederholen nach POP-UP
* geht nicht, da dann die L-Strukturen nicht upgedatet werden.
*   IF BILDFLAG IS INITIAL.
*     BILDFLAG = X.
*   ENDIF.

    IF ANTWORT NE 'J'.
*    "Ändern ?" wurde mit NEIN oder Abbruch bestätigt !
      FLAG_EXIT = ANTWORT.             " N oder A ! !
      EXIT.                            " -> raus aus Form-Routine
    ENDIF.

*   => Ändern wird durchgeführt - > dies geschieht durch merken der
*   betroffenen EAN in EAN_UPD.
*   Im Modul DATENUEBERNAHME_MEINH wird für alle Sätze mit der
*   gemerkten EAN in der TMLEA die neue EAN eingetragen. Dies geschieht
*   somit für alle Lieferanten.

    EAN_UPD = TMLEA-EAN11.

  ENDIF.

ENDFORM.                               " UPD_EAN_LIEF
