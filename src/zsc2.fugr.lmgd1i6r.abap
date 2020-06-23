*---------------------------------------------------------------------*
* Module RM03M-SPRAS.                                                 *
*---------------------------------------------------------------------*
*       prueft die Gueltigkeit der eingegebenen Sprache und           *
*       modifiziert XTHEAD.   (Langtextbilder)                        *
*---------------------------------------------------------------------*
MODULE RM03M-SPRAS.
 CALL FUNCTION 'LANGTEXT_SPRAS_ANLEGEN_AENDERN'
      EXPORTING
           P_SPRAS = RM03M-SPRAS.
ENDMODULE.
