*&---------------------------------------------------------------------*
*&      Module  INITIALISIERUNG  OUTPUT
*&---------------------------------------------------------------------*
*Setzen Materialnummer.
*Sortierung der internen Tabelle, falls der aktuelle Eintrag nicht
*an erster Stelle steht.
*------------------------------------------------------------------
MODULE INITIALISIERUNG OUTPUT.

  IF RMMZU-KINIT = SPACE.
    RMMZU-KINIT = X.

    CLEAR: KT_ERSTE_ZEILE.

*--Ermitteln der Anzahl der Kurztexteinträge ----------------------
    DESCRIBE TABLE KTEXT LINES KT_LINES.

*--Kurztextab. neu sort. - Text zur akt. Spr. an erste Stelle ------
    IF RMMG2-FLG_RETAIL IS INITIAL.
      READ TABLE KTEXT WITH KEY SPRAS = MAKT-SPRAS MAKTX = MAKT-MAKTX.
    ELSE.
      READ TABLE KTEXT WITH KEY SPRAS = RMMG1-SPRAS.
    ENDIF.
    IF SY-SUBRC = 0.
**      check not sy-tabix = 1. "need to get to tc wk 4.0
      DELETE KTEXT INDEX SY-TABIX.
      INSERT KTEXT INDEX 1.

    ENDIF.
  ELSE.
    IF KT_LINES = 0.
      KT_ERSTE_ZEILE = 0.
    ELSEIF KT_ERSTE_ZEILE GE KT_LINES.
      KT_ERSTE_ZEILE = KT_LINES - 1.
    ENDIF.
  ENDIF.
** switch to tc wk to 4.0
  IF NOT FLG_TC IS INITIAL.
    REFRESH CONTROL 'TC_KTXT' FROM SCREEN SY-DYNNR.
    TC_KTXT-LINES = KT_LINES.
    TC_KTXT-TOP_LINE = KT_ERSTE_ZEILE + 1.
    TC_KTXT_TOP_LINE_BUF = TC_KTXT-TOP_LINE.
*  tc_ktxt_buf = tc_ktxt.
    ASSIGN TC_KTXT TO <F_TC>.
  ENDIF.
ENDMODULE.                             " INITIALISIERUNG  OUTPUT
