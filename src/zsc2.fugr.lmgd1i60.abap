*&---------------------------------------------------------------------*
*&      Module  OK_CODE_MEINH_I  INPUT
*&---------------------------------------------------------------------*
*       OK-CODE 'Löschen' durchführen, da Löschen vor Fehlerprüfungen  *
*       erfolgen muß (zur Löschung vorgesehene Zeilen sollen nicht     *
*       geprüft werden.
*----------------------------------------------------------------------*
MODULE OK_CODE_MEINH_I INPUT.

  DATA: HANTWORT LIKE SY-DATAR.        "cfo/9.9.96 Antwort aus E-Box
                                       "zum Löschen
  DATA: del_meinh like meinh-meinh.    "JW/4.6A geloeschte ME

* Gleiche Abfrage wie bei den Prüfungen cfo/7.2.96/
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
* CHECK T130M-AKTYP EQ AKTYPH OR T130M-AKTYP EQ AKTYPV.

  IF RMMZU-OKCODE = FCODE_MEDE.
*----PF14-Loeschen Eintrag------------------------------------------

    GET CURSOR LINE ME_ZEILEN_NR.
    ME_AKT_ZEILE = ME_ERSTE_ZEILE + ME_ZEILEN_NR.
    READ TABLE MEINH INDEX ME_AKT_ZEILE.
    IF SY-SUBRC = 0.
      RET_EAN11 = MEINH-EAN11.         " CFO: 08.02.96
      PERFORM ME_LOESCHUNG_PRUEFEN CHANGING HANTWORT.
      IF HANTWORT = 'J'.
* cfo/11.9.96 auskommentiert, da Prüfungen in Form-Routine
* ME_LOESCHUNG_PRUEFEN reingezogen wurde.
* AHE: 20.06.96 - A
*       Prüfen, ob EAN Lieferantenbezug hat. Wenn ja, darf Zeile mit
*       EAN hier nicht gelöscht werden.
*       PERFORM DEL_EAN_LIEF_MEINH USING FLAG_EXIT.
*       CASE FLAG_EXIT.
*         WHEN 'N'.
*           "NEIN" -> nur diese Zeile nicht Ändern
*           EXIT.
*       ENDCASE.
* AHE: 20.06.96 - E
        del_meinh = meinh-meinh.           "JW/4.6A
        DELETE MEINH INDEX ME_AKT_ZEILE.

* note 700229
        DELETE OLD_MEINH WHERE MEINH = DEL_MEINH.

* JW/4.6A - Anfang: Geloeschte Mengeneinheit auch bei mesub anderer ME's
*       loeschen, damit wird mesub bei diesen ME's im naechsten pbo
*       auf die Basis-ME gesetzt
        loop at meinh where mesub = del_meinh.
          clear meinh-mesub.
          modify meinh.
        endloop.

* JW/4.6A - Ende

* cfo/11.9.96 auskommentiert, da Prüfungen in Form-Routine
* ME_LOESCHUNG_PRUEFEN reingezogen wurde.
*       Prüfen, ob die gelöschte ME eine doppelt erfasste ME ist, also
*       nochmal in MEINH enthalten ist.
*       READ TABLE MEINH WITH KEY MEINH-MEINH BINARY SEARCH.
*       READ TABLE MEINH WITH KEY MEINH-MEINH. " CFO: 08.02.96
*       IF SY-SUBRC NE 0.
*         Alle EANs zur ME löschen.
*         LOOP AT MEAN_ME_TAB WHERE MEINH = MEINH-MEINH.
*           DELETE MEAN_ME_TAB.
*         ENDLOOP.
*         IF SY-SUBRC = 0.
*           RMMG2-VB_MEAN = X.
*         ENDIF.
*       ELSE.
*         Falls die HauptEAN der gelöschten ME bereits in MEAN_ME_TAB
*         eingetragen wurde, muß sie dort gelöscht werden. Alle anderen
*         Zusätzlichen EANs bleiben bestehen.
*         READ TABLE MEAN_ME_TAB WITH KEY
*                                     MEINH = MEINH-MEINH
*                                     EAN11 = RET_EAN11 " CFO: 08.02.96
*                                     BINARY SEARCH.
*         IF SY-SUBRC = 0.
*           DELETE MEAN_ME_TAB INDEX SY-TABIX.
*           RMMG2-VB_MEAN = X.
*         ENDIF.
*       ENDIF.
      ENDIF.
    ENDIF.
    BILDFLAG = X.
    CLEAR RMMZU-OKCODE.
*   DELFLAG = X.            cfo/17.05.95/wird nicht mehr benötigt
  ENDIF.

ENDMODULE.                             " OK_CODE_MEINH_I  INPUT
