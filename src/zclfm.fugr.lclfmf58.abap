*&---------------------------------------------------------------------*
*&      Form  ok_MADE
*&---------------------------------------------------------------------*
*       Remove all marks in table control.
*----------------------------------------------------------------------*
form ok_made.

  clear klastab-markupd .
  modify klastab transporting markupd
                 where markupd eq kreuz.
  clear cn_mark.
  clear markzeile1.

endform.                               " ok_MADE
