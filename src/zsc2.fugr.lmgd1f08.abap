*&---------------------------------------------------------------------*
*&      Form  OK_CODE_KTEXT
*&---------------------------------------------------------------------*
FORM OK_CODE_KTEXT.

  CASE RMMZU-OKCODE.
       WHEN FCODE_BABA.
            CLEAR RMMZU-KINIT. " Initflag wird bei Verlassen d. Bildes
                               " zurückgesetzt
*----- Erste Seite - KurzText First Page -----------------------------
       WHEN FCODE_KTFP.
            PERFORM FIRST_PAGE USING KT_ERSTE_ZEILE.
*----- Seite vor - KurzText Next Page --------------------------------
       WHEN FCODE_KTNP.
           PERFORM NEXT_PAGE USING KT_ERSTE_ZEILE KT_ZLEPROSEITE
                                   KT_LINES.
*----- Seite zurueck - KurzText previous Page ------------------------
       WHEN FCODE_KTPP.
            PERFORM PREV_PAGE USING KT_ERSTE_ZEILE KT_ZLEPROSEITE.
*----- Bottom - KurzText Last Page -----------------------------------
       WHEN FCODE_KTLP.
           PERFORM LAST_PAGE USING KT_ERSTE_ZEILE KT_LINES
                                   KT_ZLEPROSEITE X.
*----- SPACE - Enter -------------------------------------------------
       WHEN FCODE_SPACE.
         IF T133A-BILDT = BILDT_Z.
* JH/08.01.97/1.2B (Anfang)
* Das Setzen von BILDFLAG muß unterbunden werden, damit die evtl.
* geänderten MAKT-Daten nicht nur in die internen U-Puffertabellen,
* sondern auch in die internen T-Puffertabellen (FGrp MG23) übernommen
* werden, sodaß nach dem Ausführen von 'Enter' und 'Beenden' evtl.
* durchgeführte Änderungen im MATERIAL_CHANGE_CHECK(_RETAIL) erkannt
* werden können
*           Datenfreigabe auf Zusatzbild heißt Wiederholen
*           BILDFLAG = X.
* JH/08.01.97/1.2B (Ende)
         ELSE.
*         Datenfreigabe auf Hauptbild heißt nächstes Hauptbild
          IF KT_FEHLERFLG IS INITIAL AND BILDFLAG IS INITIAL.
            CLEAR RMMZU-KINIT. " Initflag wird bei Verlassen d. Bildes
           ENDIF.              " zurückgesetzt
         ENDIF.
* ----------Sonstige Funktionen wie Springen etc.----------------------
       WHEN OTHERS.
         IF KT_FEHLERFLG IS INITIAL AND BILDFLAG IS INITIAL.
           CLEAR RMMZU-KINIT.
         ENDIF.
  ENDCASE.

ENDFORM.                    " OK_CODE_KTEXT
