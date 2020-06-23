*&---------------------------------------------------------------------*
*&      Form  OKB_MADE
*&---------------------------------------------------------------------*
*       Remove all marks in table control.
*----------------------------------------------------------------------*
form okb_made.

  clear klastab-markupd .
  modify klastab transporting markupd
                 where markupd eq kreuz.
  clear cn_mark.
  clear markzeile1.

endform.                               " OKB_MADE
