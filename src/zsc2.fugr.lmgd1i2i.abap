*------------------------------------------------------------------
*  Module MARC-LAGPR.        "Lagerkostenschlüssel
*  Beim Verfahren 'Optimierungslosgröße' muß das Feld gefüllt sein.
*  Analoges gilt für das Feld MARC-LOSFX, "Losfixkosten
*  das hier mitbehandelt wird.
*------------------------------------------------------------------
MODULE MARC-LAGPR.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_LAGPR'
       EXPORTING
            P_DISLS      = MARC-DISLS
            P_LAGPR      = MARC-LAGPR
            P_LOSFX      = MARC-LOSFX
            P_DISPR      = MARC-DISPR
            P_KZ_NO_WARN = ' '
       IMPORTING
            P_LAGPR      = MARC-LAGPR
            P_LOSFX      = MARC-LOSFX.
ENDMODULE.
