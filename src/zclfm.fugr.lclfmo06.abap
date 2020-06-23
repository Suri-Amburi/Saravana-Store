*------------------------------------------------------------------*
*       MODULE LIST_IATINN                                         *
*------------------------------------------------------------------*
*       ausgeben der Inkonsistenzen beim löschen                   *
*------------------------------------------------------------------*
module list_iatinn output.
  anzloop = syst-loopc.
  rmclf-atnam = iatinn-atnam.
  rmclf-class = iatinn-class.
  rmclf-objek = iatinn-objek.
  if iatinn-mafid = mafidk.
    rmclf-obtyp = text-300.
  else.
    rmclf-obtyp = iatinn-objtyp.
  endif.
endmodule.
