*&---------------------------------------------------------------------*
*&      Form  OKB_UEBN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_uebn.
  if syst-dynnr = dy604 or
     syst-dynnr = dy605.
    set screen dy000.
    leave screen.
  endif.
endform.                               " OKB_UEBN
