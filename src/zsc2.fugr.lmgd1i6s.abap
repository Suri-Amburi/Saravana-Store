*---------------------------------------------------------------------*
* Module RM03M-KZSE1.                                                 *
*---------------------------------------------------------------------*
*       Das Selektionskennzeichen in der Tabelle XTHEAD wird          *
*       aktualisiert. (Langtextbilder)                                *
*---------------------------------------------------------------------*
MODULE RM03M-KZSE1.
 CALL FUNCTION 'LANGTEXT_KZSE1'
      EXPORTING
           P_KZSE1 = RM03M-KZSE1.
ENDMODULE.
