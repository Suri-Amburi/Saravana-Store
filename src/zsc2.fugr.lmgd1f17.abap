*&---------------------------------------------------------------------*
*&      Form  OK_CODE_MEINH
*&---------------------------------------------------------------------*
*  Bearbeiten Funktionstasteneingaben
*  PF14: Loeschen Zeile
*  PF21 - PF24: Blaettern
*  'EANNR': Ansprung des Popups für die Pflege der Abpackungsdaten
*  Jede weitere Funktion fuehrt zum Verlassen des Dialogbau-
*  steines, wobei dem aufrufenden Standard-Datenbild die gewählte
*  Funktion mitgegeben wird (Ausnahme 'Zurück' und Datenfreigabe)
*----------------------------------------------------------------------*
FORM OK_CODE_MEINH.

  CASE RMMZU-OKCODE.

*------Zurück -------------------------------------------------------
    WHEN FCODE_BABA.
      CLEAR RMMZU-MINIT. " Initflag wird bei Verlassen d. Bildes
                                       " zurückgesetzt

*----- Erste Seite - MengenEinh First Page -----------------------------
    WHEN FCODE_MEFP.
      PERFORM FIRST_PAGE USING ME_ERSTE_ZEILE.

*----- Seite vor - MengenEinh Next Page --------------------------------
    WHEN FCODE_MENP.
      PERFORM NEXT_PAGE USING ME_ERSTE_ZEILE ME_ZLEPROSEITE
                              ME_LINES.

*----- Seite zurueck - MengenEinh previous Page ------------------------
    WHEN FCODE_MEPP.
      PERFORM PREV_PAGE USING ME_ERSTE_ZEILE ME_ZLEPROSEITE.

*----- Botton - MengenEinh Last Page -----------------------------------
    WHEN FCODE_MELP.
      PERFORM LAST_PAGE USING ME_ERSTE_ZEILE ME_LINES
                              ME_ZLEPROSEITE X.

*------ Dropdown-Listbox Mengeneinheitengruppe -------JW/4.6A----------
    when fcode_megr.
      rmmzu-okcode = space.

*------EANNR----------------------------------------------------------
* EAN jetzt im Mengeneinheitenbild, FCODE entfällt.
*      WHEN FCODE_EANN.
*           CLEAR RMMZU-OKCODE.
*           GET CURSOR LINE ME_ZEILEN_NR.
*           ME_AKT_ZEILE = ME_ERSTE_ZEILE + ME_ZEILEN_NR.
*           READ TABLE MEINH INDEX ME_AKT_ZEILE.
*           IF SY-SUBRC EQ 0.
*             CLEAR SMEINH.
*             MOVE-CORRESPONDING MEINH TO SMEINH.
* Bezeichnung muß auf dem EAN-Bild nochmal gelesen werden, da nicht
* in MEINH enthalten. cfo/19.05.95
**            MOVE MEINH-MSEHT         TO T006A-MSEHT.
**            MOVE MARA-MATNR          TO MARM-MATNR.
*---- ermitteln Text zum EAN-Nummerntyp ----------------------------
*             PERFORM TEXT_ZUM_NUMMERNTYP.

*             CALL SCREEN '8021' STARTING AT 30 02
*                                ENDING   AT 78 18.
*             T006A-MSEHT = RM03E-MSEHT.           "3.12.93 / CH
*           ELSE.
*             MESSAGE E339.
*           ENDIF.

*-------andere----------------------------------------------------------

* AHE: 17.06.96 - A
* Blättern Table - Control geht sonst schief;
* Außerdem ist dies hier sowieso falsch, hat sich nur nie ausgewirkt
*      WHEN OTHERS.
*           IF ME_FEHLERFLG IS INITIAL.
*             CLEAR RMMZU-MINIT.
*           ENDIF.
* AHE: 17.06.96 - E
  ENDCASE.

ENDFORM.                               " OK_CODE_MEINH
