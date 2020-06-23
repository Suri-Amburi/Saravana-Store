*&---------------------------------------------------------------------*
*&      Form  OKB_PICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_pick.

  case syst-dynnr.
    when dy601.
      get cursor field fname line zeile1.
      fname = 'RMCLF-STATU'.
      check syst-subrc eq 0.
      check zeile1 ne 0.
      zeile1 = zeile1 + index_neu1 - 1.
      read table itclc index zeile1.
      check syst-subrc = 0.
      cl_status_neu = itclc-statu.
    when dy602.
      get cursor field rmclf-texto line zeile1.
      check syst-subrc eq 0.
      check zeile1 ne 0.
      zeile1 = zeile1 + index_neu1 - 1.
      read table redun1 index zeile1.
      read table redun  index redun1-index.
      if multi_obj = kreuz and not redun-obtab is initial.
        if redun-dynnr2 is initial.
*         sm_dynnr        = dynp0499.
          redun-dynnr4    = dynp0499.
          d5xx_dynnr      = dynp0299.
        else.
*         sm_dynnr        = redun-dynnr4.
          d5xx_dynnr      = redun-dynnr2.
        endif.
        strlaeng = strlen( redun-obtxt ).
        assign redun-obtxt(strlaeng) to <length>.
      endif.
  endcase.
  set screen dy000.
  leave screen.

endform.                               " OKB_PICK
