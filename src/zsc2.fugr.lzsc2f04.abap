*----------------------------------------------------------------------*
*   INCLUDE LMGD2F04                                                   *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*   FORM TMALG_AKT
*---------------------------------------------------------------------
*   Aktualisieren der int. Tabelle TMALG wg. Benutzereingabe
*---------------------------------------------------------------------

 FORM TMALG_AKT.
* Verarbeitung im Dialog

* AHE: 23.07.96 - A
* wegen Fall: Falsche Meinh eingegeben und dann gelöscht -> es soll
* keine ganz leere Zeile in TMALG übernommen werden !
   IF NOT SMEINH-MEINH IS INITIAL OR
      NOT MALG-LAYGR   IS INITIAL.
* AHE: 23.07.96 - E
     TMALG-MANDT  = SY-MANDT.
     TMALG-MATNR  = RMMG1-MATNR.
     TMALG-MEINH  = SMEINH-MEINH.
     TMALG-LAYGR  = MALG-LAYGR.
*   AHE: 22.05.96 - A
     TMALG-SORF1  = MALG-SORF1.
*   AHE: 22.05.96 - E
     TMALG-HPLGR  = MALG-HPLGR.
* AHE: 19.03.98 - A (4.0c)
* 2 neue Felder
     TMALG-FACIN  = MALG-FACIN.
     TMALG-SHELF  = MALG-SHELF.
* AHE: 19.03.98 - E
* AHE: 07.01.99 - A (4.6a)
* 5 neue Felder
     CLEAR MALG-LMVER.         " <<== da noch nicht unterstützt
     TMALG-LMVER  = MALG-LMVER.
     TMALG-FRONT  = MALG-FRONT.
     TMALG-SHQNM  = MALG-SHQNM.
     TMALG-SHQNO  = MALG-SHQNO.
     TMALG-PREQN  = MALG-PREQN.
* AHE: 07.01.99 - E

     IF PG_AKT_ZEILE > PG_LINES.
       APPEND TMALG.
       PG_LINES = PG_LINES + 1.
     ELSE.
       MODIFY TMALG INDEX PG_AKT_ZEILE.
     ENDIF.

   ENDIF.                              " AHE: 23.07.96

 ENDFORM.


*&---------------------------------------------------------------------*
*&      Module  OK_CODE_PG  INPUT
*&---------------------------------------------------------------------*
 FORM OK_CODE_PG.

*--Ermitteln der aktuellen Anzahl Einträge
   DESCRIBE TABLE TMALG LINES PG_LINES.

   CASE RMMZU-OKCODE.
*------Zurück -------------------------------------------------------
     WHEN FCODE_BABA.
       CLEAR RMMZU-PGINIT. " Initflag wird bei Verlassen d. Bildes
                                       " zurückgesetzt

*----- Erste Seite - Plazierungsgruppe First Page ----------------------
     WHEN FCODE_PGFP.
       PERFORM FIRST_PAGE USING PG_ERSTE_ZEILE.

*----- Seite vor - Plazierungsgruppe Next Page -------------------------
     WHEN FCODE_PGNP.
       PERFORM NEXT_PAGE USING PG_ERSTE_ZEILE PG_ZLEPROSEITE
                               PG_LINES.

*----- Seite zurueck - Plazierungsgruppe Previous Page -----------------
     WHEN FCODE_PGPP.
       PERFORM PREV_PAGE USING PG_ERSTE_ZEILE PG_ZLEPROSEITE.

*----- Bottom - Plazierungsgruppe Last Page ----------------------------
     WHEN FCODE_PGLP.
       PERFORM LAST_PAGE USING PG_ERSTE_ZEILE PG_LINES
                               PG_ZLEPROSEITE X.

*-------andere----------------------------------------------------------
*   WHEN OTHERS.
*     IF PG_FEHLERFLG    IS INITIAL AND
*        PG_FEHLERFLG_ME IS INITIAL.
*       CLEAR RMMZU-PGINIT.
*     ENDIF.

   ENDCASE.

 ENDFORM.                              " OK_CODE_PG  INPUT


*&---------------------------------------------------------------------*
*&      Form  PG_SET_ZEILE
*&---------------------------------------------------------------------*
*       Zeile wird intensified geschaltet und Cursorposition gemerkt
*----------------------------------------------------------------------*
 FORM PG_SET_ZEILE.

   LOOP AT SCREEN.
     SCREEN-INTENSIFIED = 1.
     MODIFY SCREEN.
   ENDLOOP.

* damit der Cursor auf die erste Zeile der falschen Meinh. auf dem
* Bild positioniert wird.
   CHECK PG_ZEILEN_NR IS INITIAL.
* Zur Cursorpositionierung
   MOVE SY-STEPL TO PG_ZEILEN_NR.

 ENDFORM.                              " PG_SET_ZEILE
