*------------------------------------------------------------------*
*       MODULE SEITE INPUT                                         *
*------------------------------------------------------------------*
*       Positionierung des ersten Eintrags auf der Seite           *
*       (Wird in RMCLF-PAGPOS gemerkt)                             *
*------------------------------------------------------------------*
module seite input.

*-- Abfrage der TOP_LINE
  if rmclf-pagpos ne tc_obj_class-top_line and                 "1624600
    okcode <> okstat.                                          "1624600
    rmclf-pagpos = tc_obj_class-top_line .                  "WFS
  endif.                                                    "WFS
  describe table klastab lines syst-tfill.
  if rmclf-pagpos = 0.
    rmclf-pagpos = ein.
  endif.
  if rmclf-pagpos > syst-tfill.
    rmclf-pagpos = syst-tfill.
  endif.
  index_neu = rmclf-pagpos.

endmodule.
