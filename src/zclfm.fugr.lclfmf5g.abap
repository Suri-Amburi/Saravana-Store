*&---------------------------------------------------------------------*
*&      Form  OK_F23
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form ok_f23.
*--------- Blätterfunktion: P+
  if syst-dynnr = dy603 or syst-dynnr = dy604.
    index_neu = index_neu + anzloop.
    if index_neu > anzzeilen.
      index_neu = index_neu - anzloop.
    endif.
  else.
    perform blaettern.
  endif.
endform.
