*&---------------------------------------------------------------------*
*&      Form  OKB_TRCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_trce.
  call function 'CUTC_SHOW_SETTINGS'                        "#EC EXISTS
       exceptions
            others = 1.

endform.                               " OKB_TRCE
