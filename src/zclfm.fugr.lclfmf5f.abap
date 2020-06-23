*&---------------------------------------------------------------------*
*&      Form  OK_F24
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form ok_f24.
*--------- Blätterfunktion: P++
  if syst-dynnr = dy603 or syst-dynnr = dy604.
    index_neu = anzzeilen - anzloop + 1.
  else.
    perform blaettern.
  endif.

endform.
