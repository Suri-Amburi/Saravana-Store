*&---------------------------------------------------------------------*
*&      Form  ok_TRCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form ok_trce.

  call function 'CUTC_SHOW_SETTINGS'
       EXCEPTIONS
            others = 1.

endform.                               " ok_TRCE
