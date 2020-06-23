*------------------------------------------------------------------
*           Pruefen_Dopeintrag
*
*- Es wird geprueft, ob unter dem eingegebenen Sprachenschluessel
*  bereits ein Eintrag existiert, wenn ja wird das Fehlerflg gesetzt.
*------------------------------------------------------------------
FORM PRUEFEN_DOPEINTRAG.

  IF KTEXT-DOPFLG = FLGALT.
    MOVE X TO KTEXT-DOPFLG.
    MODIFY KTEXT.
    EXIT.
  ELSE.
    CLEAR KTEXT-DOPFLG.
    MODIFY KTEXT.
  ENDIF.

  KT_ZEILEN_NR = SY-TABIX.
  CLEAR ZAEHLER.

*---Suchen Eintrag mit gleichem Sprachenschluessel-------------------
  LOOP AT  KTEXT
         WHERE SPRAS = KTEXT-SPRAS.
    ZAEHLER = ZAEHLER + 1.
    IF ZAEHLER > 1.
      EXIT.
    ENDIF.
  ENDLOOP.

*---Markieren fehlerhafte Eintraege----------------------------------
  IF ZAEHLER > 1.
    LOOP AT  KTEXT
           WHERE SPRAS = KTEXT-SPRAS.
      MOVE FLGALT TO KTEXT-DOPFLG.
      MODIFY KTEXT INDEX SY-TABIX.
    ENDLOOP.
  ENDIF.

*---Aktuellen Eintrag nachlesen--------------------------------------
  SY-TABIX = KT_ZEILEN_NR.
  READ TABLE KTEXT INDEX SY-TABIX.

*---Fehlernachricht setzen-------------------------------------------
  IF ZAEHLER > 1.
    MOVE X TO KTEXT-DOPFLG.
    IF KT_FEHLERFLG = SPACE.
      KT_FEHLERFLG =  FDSPRACH.
      KT_SAVSPRAS  = KTEXT-SPRAS.
    ENDIF.
    MODIFY KTEXT.
  ENDIF.

ENDFORM.

