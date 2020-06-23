*&---------------------------------------------------------------------*
*&      Form  ME_PRUEFEN_DOPEINTRAG
*&---------------------------------------------------------------------*
*  Es wird geprueft, ob unter der eingegebenen Mengeneinheit
*  bereits ein Eintrag existiert, wenn ja wird das Fehlerflg gesetzt.
*----------------------------------------------------------------------*
FORM ME_PRUEFEN_DOPEINTRAG.

  IF MEINH-DOPFLG = ME_FLGALT.
    MOVE X TO MEINH-DOPFLG.
    MODIFY MEINH.
    EXIT.
  ELSE.
    CLEAR MEINH-DOPFLG.
    MODIFY MEINH.
  ENDIF.

  ZEILEN_NR = SY-TABIX.
  CLEAR ZAEHLER.

*---Suchen Eintrag mit gleicher Mengeneinheit------------------------
* SELECT * FROM MEINH                                             S5142
  LOOP AT  MEINH
         WHERE MEINH = MEINH-MEINH.
    ZAEHLER = ZAEHLER + 1.
    IF ZAEHLER > 1.
      EXIT.
    ENDIF.
* ENDSELECT.                                                      S5142
  ENDLOOP.

*---Markieren fehlerhafte Eintraege----------------------------------
  IF ZAEHLER > 1.
*    SELECT * FROM MEINH                                          S5142
    CLEAR ZAEHLER2.
    LOOP AT  MEINH
           WHERE MEINH = MEINH-MEINH.
      MOVE ME_FLGALT TO MEINH-DOPFLG.
      ZAEHLER2 = ZAEHLER2 + 1.
      MODIFY MEINH INDEX SY-TABIX.
*    ENDSELECT.                                                   S5142
    ENDLOOP.
  ENDIF.

*---Aktuellen Eintrag nachlesen--------------------------------------
  SY-TABIX = ZEILEN_NR.
  CLEAR ZEILEN_NR.
  READ TABLE MEINH INDEX SY-TABIX.

*---Fehlernachricht setzen-------------------------------------------
  IF ZAEHLER > 1.
    MOVE X TO MEINH-DOPFLG.
    IF ME_FEHLERFLG = SPACE.
      MOVE FDMEINH     TO ME_FEHLERFLG.
      MOVE MEINH-MEINH TO SAVMEINH.
    ENDIF.
    MODIFY MEINH.
  ENDIF.

ENDFORM.                               " ME_PRUEFEN_DOPEINTRAG


*----------------------------------------------------------------------*
* form me_lhmg_bzgl_bme_berechnen.
* Dokumentation siehe form me_lhmg_neuberechnen.
* JW: 21.12.98
*----------------------------------------------------------------------*
FORM ME_LHMG_BZGL_BME_BERECHNEN.

* Formroutine wird nur ausgefuehrt, wenn das Bild zum ersten mal pro-
* zessiert wird.
  CHECK RMMZU-MINIT IS INITIAL.

  CLEAR B_MLGN.
  MOVE-CORRESPONDING MLGN TO B_MLGN.

* Umrechnung lhmg bezueglich Basismengeneinheit
  IF NOT B_MLGN-LHMG1 IS INITIAL.
    READ TABLE MEINH WITH KEY MEINH = B_MLGN-LHME1.
    B_MLGN-LHMG1 = B_MLGN-LHMG1 * MEINH-UMREZ / MEINH-UMREN.
  ENDIF.
  IF NOT B_MLGN-LHMG2 IS INITIAL.
    READ TABLE MEINH WITH KEY MEINH = B_MLGN-LHME2.
    B_MLGN-LHMG2 = B_MLGN-LHMG2 * MEINH-UMREZ / MEINH-UMREN.
  ENDIF.
  IF NOT B_MLGN-LHMG3 IS INITIAL.
    READ TABLE MEINH WITH KEY MEINH = B_MLGN-LHME3.
    B_MLGN-LHMG3 = B_MLGN-LHMG3 * MEINH-UMREZ / MEINH-UMREN.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
* form me_lhmg_neuberechnen.
*----------------------------------------------------------------------*
* Wenn die Umrechnungsfaktoren geaendert wurden, muessen die LHM-Mengen
* der LV-Sicht ebenfalls geaendert werden.
* Dazu werden im PBO (form me_lhmg_bzgl_bme_berechnen) die LHM-Mengen
* bezueglich der Basismengeneinheit mit den alten Umrechnungsfaktoren
* berechnet (b_mlgn). In me_lhmg_neuberechnen werden die LHM-Mengen be-
* zueglich der LHM-Mengeneinheiten neu berechnet.
*
* JW: 21.12.98
*----------------------------------------------------------------------*
FORM ME_LHMG_NEUBERECHNEN.

  CHECK BILDFLAG IS INITIAL.

* umrechnung lhmg bzgl. lhme
  IF NOT B_MLGN-LHMG1 IS INITIAL.
    READ TABLE MEINH WITH KEY MEINH = B_MLGN-LHME1.
    MLGN-LHMG1 = B_MLGN-LHMG1 * MEINH-UMREN / MEINH-UMREZ.
  ENDIF.
  IF NOT B_MLGN-LHMG2 IS INITIAL.
    READ TABLE MEINH WITH KEY MEINH = B_MLGN-LHME2.
    MLGN-LHMG2 = B_MLGN-LHMG2 * MEINH-UMREN / MEINH-UMREZ.
  ENDIF.
  IF NOT B_MLGN-LHMG3 IS INITIAL.
    READ TABLE MEINH WITH KEY MEINH = B_MLGN-LHME3.
    MLGN-LHMG3 = B_MLGN-LHMG3 * MEINH-UMREN / MEINH-UMREZ.
  ENDIF.

  IF NOT LHMG_UPDATEFLG IS INITIAL.
*   Warnung: Änderung der ME führt zu Änderungen in der LHM-Menge
    MESSAGE S119(MM).
    BILDFLAG = X.
  ENDIF.
ENDFORM.
