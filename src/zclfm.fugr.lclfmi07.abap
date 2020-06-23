*------------------------------------------------------------------*
*       MODULE SEITE_REQ INPUT                                     *
*------------------------------------------------------------------*
*       Positionierung des ersten Eintrags auf der Seite           *
*       (Wird in RMCLF-PAGPOS gemerkt)                             *
*------------------------------------------------------------------*
module seite_req input.

*-- RMCLF-PAGPOS wurde von außen eingegeben
  tc_obj_class-top_line = rmclf-pagpos .

endmodule.
