*&---------------------------------------------------------------------*
*&      Form  OK_FIXI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form ok_fixi.
  loop at redun where radio = punkt.
    clear redun-radio.
    modify redun.
    exit.
  endloop.
  get cursor field rmclf-texto line zeile1.
  check syst-subrc eq 0.
  check zeile1 ne 0.
  rmclindx-zeile1 = zeile1 + index_neu1 - 1.
  export rmclindx to database indx(cf) id relid.
  read table redun1 index rmclindx-zeile1.
  read table redun index redun1-index.
  if multi_obj = kreuz.
    if redun-obtab is initial.
      sobtab = pobtab.
    else.
      sobtab = redun-obtab.
      if redun-dynnr2 is initial.
*       sm_dynnr        = dynp0499.
        redun-dynnr4    = dynp0499.
        d5xx_dynnr      = dynp0299.
      else.
*       sm_dynnr        = redun-dynnr4.
        d5xx_dynnr      = redun-dynnr2.
      endif.
    endif.
    strlaeng = strlen( redun-obtxt ).
    assign redun-obtxt(strlaeng) to <length>.
  endif.
  set screen dy000.
  leave screen.

endform.                               " OK_FIXI
