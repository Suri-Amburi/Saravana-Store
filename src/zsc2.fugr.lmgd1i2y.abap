*------------------------------------------------------------------
*  Module MARC-BSTMA.
*  Maximale Bestellmenge muß größer Mindestbestellmenge und
*  größer dem Rundungswert sein.
*------------------------------------------------------------------
MODULE MARC-BSTMA.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_BSTMA'
       EXPORTING
            P_BSTMA      = MARC-BSTMA
            P_BSTMI      = MARC-BSTMI
            P_BSTRF      = MARC-BSTRF
            P_KZ_NO_WARN = ' '.
* EXCEPTIONS
*      P_ERR_MARC_BSTMA = 01.

ENDMODULE.
