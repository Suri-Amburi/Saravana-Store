*&---------------------------------------------------------------------*
*&      Form  EAN_SET_ZEILE
*&---------------------------------------------------------------------*
*       Zeile wird intensified geschaltet und Cursorposition gemerkt
*----------------------------------------------------------------------*
FORM EAN_SET_ZEILE.

  LOOP AT SCREEN.
    SCREEN-INTENSIFIED = 1.
    MODIFY SCREEN.
  ENDLOOP.

* damit der Cursor auf die erste Zeile der falschen Meinh. auf dem
* Bild positioniert wird.
  CHECK EAN_ZEILEN_NR IS INITIAL.
* Zur Cursorpositionierung
  MOVE SY-STEPL TO EAN_ZEILEN_NR.

ENDFORM.                               " EAN_SET_ZEILE
