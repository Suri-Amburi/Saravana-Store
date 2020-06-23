*&---------------------------------------------------------------------*
*&      Form  OK_F22
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form ok_f22.
*--------- Blätterfunktion: P-
  if syst-dynnr = dy603 or syst-dynnr = dy604.
    index_neu = index_neu - anzloop.
    if index_neu le 0.
      index_neu = 1.
    endif.
  else.
    perform blaettern.
  endif.
endform.
