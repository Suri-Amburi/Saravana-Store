*------------------------------------------------------------------
*  Module MPOP-MODAW.
* Ein Prognosemodell oder eine Modellauswahl müssen angegeben werden.
* Modellauswahl nur bei Prognosemodellen der exp. Glättung erster
* Ordnung sinnvoll.
*------------------------------------------------------------------
MODULE MPOP-MODAW.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

*mk/3.1g vorgezogen wegen performance
*mk/3.0c prüfung nur sinnvoll, wenn mpop überhaupt aktiv ist, speziell
*fehlermeldung, wenn initial (analog zum material_update_all)
  CHECK AKTVSTATUS CA STATUS_P.

* AHE: 28.03.96 - A
* Prüfung soll nur ablaufen, wenn nicht mit Buttons oder über Menü
* auf Prognosedialog, Prognose- oder Verbrauchswerte verzweigt wird.
*mk/3.1G Abfrage auf konfigurierbare Fcodes ist falsch
* check ( rmmzu-okcode ne fcode_verb and   "Verbräuche Button
*         rmmzu-okcode ne fcode_prgw and   "Prognosewerte Button
*         rmmzu-okcode ne fcode_prgd ).    "Prognose Button
* AHE: 15.05.96
*         RMMZU-OKCODE NE FCODE_VERM ).    "Verbräuche Menüfunktion
* AHE: 28.03.96 - E

* AHE: 15.05.96 - A
* Check, ob Zusatzfunktion "Verbrauch" im Menü angewählt.
* DATA: BEGIN OF TT133D OCCURS 0.   mk/3.1G global definiert
*         INCLUDE STRUCTURE T133D.
* DATA: END OF TT133D.

  CLEAR TT133D. REFRESH TT133D.

  CALL FUNCTION 'T133D_ARRAY_READ'
       EXPORTING
            BILDSEQUENZ = BILDSEQUENZ
       TABLES
            TT133D      =  TT133D
       EXCEPTIONS
            WRONG_CALL  = 01.

* Zusatzfkt. sind konfigurierbar. -> Lesen des Fcodes der Funktion
* "Verbrauch".
* read table tt133d with key routn    = form_verb
*                            fcode(2) = prae_funk_zusatz.
* if sy-subrc eq 0.
*   Menüpunkt "Verbrauch" angewählt ? Wenn ja, keine weitere Prüfung
*   mehr in diesem Modul.
*   check rmmzu-okcode ne tt133d-fcode.
* endif.
* AHE: 15.05.96 - E

*mk/3.1G auch, wenn als PB-Funktion konfiguriert, außerdem auch die
*Funktionen Prognosewerte bzw. Prognose durchführen zu berücksichtigen
   CLEAR FLAG1.
   LOOP AT TT133D WHERE ROUTN = FORM_VERB OR ROUTN = FORM_PRGD OR
                        ROUTN = FORM_PRGW OR ROUTN = FORM_PRGWO.
     IF RMMZU-OKCODE EQ TT133D-FCODE.
       FLAG1 = X.
       EXIT.
     ENDIF.
   ENDLOOP.
   CHECK  FLAG1 IS INITIAL.

*mk/3.0C Prüfung nur sinnvoll, wenn MPOP überhaupt aktiv ist, speziell
*Fehlermeldung, wenn initial (analog zum material_update_all)
* check aktvstatus ca status_p.    mk/3.1G vorgezogen
* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_MODAW = X ) AND
     ( ( UMPOP-PRMOD NE MPOP-PRMOD ) OR
* Note 316843
*      ( UMPOP-MODAW NE MPOP-MODAW ) ).
       ( UMPOP-MODAW NE MPOP-MODAW ) OR
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
       ( UMPOP-MATNR NE MPOP-MATNR ) OR
       ( UMPOP-WERKS NE MPOP-WERKS ) ).
    CLEAR RMMZU-PS_MODAW.
  ENDIF.

  CLEAR RMMZU-CURS_FELD.               " AHE: 04.08.95
* Damit nicht nach der Fehlerkorrektur der Cursor nochmal auf das
* inzwischen evtl. korrigierte Feld positioniert wird. AHE: 04.08.95

* Wenn Prüfstatus nicht gesetzt, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.
  IF RMMZU-PS_MODAW IS INITIAL.
    CALL FUNCTION 'MPOP_MODAW'
         EXPORTING
              P_PRMOD          = MPOP-PRMOD
              P_MODAW          = MPOP-MODAW
              P_PROPR          = MPOP-PROPR
              P_KZRFB          = KZRFB
              P_PS_MODAW       = RMMZU-PS_MODAW
              P_KZ_NO_WARN     = ' '
         IMPORTING
              P_MODAW          = MPOP-MODAW
              P_PS_MODAW       = RMMZU-PS_MODAW
         EXCEPTIONS
              P_ERR_MPOP_MODAW = 01.
* Errormeldung als S-Meldung ausgeben
    IF SY-SUBRC NE 0.
      BILDFLAG = X.
      RMMZU-CURS_FELD = MPOP_PRMOD.    " AHE: 04.08.95
*     RMMZU-CURS_FELD = MPOP_MODAW. " evtl. auch Cursor hierhin, da dann
*                                   " Feld immer auf akt. Bild vorh.
*                                   " AHE: 04.08.95
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
* Warnung als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_MODAW NE SPACE.
      BILDFLAG = X.
      MESSAGE S458.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMPOP = MPOP.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt). Da nach der Warnung keine Aktionen im Prüfbaustein statt-
* finden, kann dieser Zweig hier entfallen.
  ENDIF.

ENDMODULE.
