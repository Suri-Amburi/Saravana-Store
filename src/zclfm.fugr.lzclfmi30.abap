*------------------------------------------------------------------*
*       Hier werden alle Module abgelegt, die die Hilfe-           *
*       funktion F1/F4 für Felder darstellen                       *
*       MODULE VALUE_STATUS INPUT                                  *
*------------------------------------------------------------------*
*       MODULE HELP_OBJEK INPUT                                    *
*------------------------------------------------------------------*
*       F1 Objekt                                                  *
*------------------------------------------------------------------*
module help_objek.
  perform help_f1_objek.
endmodule.

*------------------------------------------------------------------*
*       MODULE VALUE_STATUS INPUT                                  *
*------------------------------------------------------------------*
*       F4 Status                                                  *
*------------------------------------------------------------------*
module value_statu.

  perform help_f4_status using classif_status.

endmodule.
