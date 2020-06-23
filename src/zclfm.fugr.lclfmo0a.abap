*------------------------------------------------------------------*
*       MODULE Drucktaste                                          *
*------------------------------------------------------------------*
*       Wenn keine inkonsistenzen, dann Drucktaste ausblenden      *
*------------------------------------------------------------------*
module drucktaste output.
  check inkonsi is initial.
  loop at screen.
    if screen-name = 'RMCLF-INKON'.
      screen-invisible = on.
      modify screen.
      exit.
    endif.
  endloop.
endmodule.
