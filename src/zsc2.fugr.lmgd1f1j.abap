*&---------------------------------------------------------------------*
*&      Form  EAN_SET_ZEILE_LFEAN
*&---------------------------------------------------------------------*
*       Prinzip: Alle Zeilen zur beteiligten Mengeneinheit intensified
*       schalten. Cursorposition aber von der Zeile merken, die in
*       MLEA_LFEAN_KEY voll spezifiziert ist (incl. EAN).
*----------------------------------------------------------------------*
FORM EAN_SET_ZEILE_LFEAN.

  LOOP AT SCREEN.
    SCREEN-INTENSIFIED = 1.
    MODIFY SCREEN.
  ENDLOOP.

* Cursor auf die gemerkte Zeile (MEINH und EAN) positionieren
  CHECK EAN_ZEILEN_NR IS INITIAL.
* Zur Cursorpositionierung
  IF MLEA_LFEAN_KEY-MEINH = MEAN_ME_TAB-MEINH AND
     MLEA_LFEAN_KEY-EAN11 = MEAN_ME_TAB-EAN11.
    MOVE SY-STEPL TO EAN_ZEILEN_NR.
  ENDIF.

ENDFORM.                               " EAN_SET_ZEILE_LFEAN
