*------------------------------------------------------------------
*  Module MARC-BSTFE.
*  Beim Verfahren 'Feste Bestellmenge' muß das Feld gefüllt sein
*  Beim Verfahren 'Fix/Splitting ebenfalls  (Verfahren = S, Kz. = S )
*------------------------------------------------------------------
MODULE MARC-BSTFE.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_BSTFE'
       EXPORTING
            P_BSTFE      = MARC-BSTFE
            P_DISPR      = MARC-DISPR
            P_DISLS      = MARC-DISLS
            P_KZ_NO_WARN = ' '
       IMPORTING
            P_BSTFE      = MARC-BSTFE.
*      EXCEPTIONS
*           P_ERR_MARC_BSTFE = 01
*           ERR_T439A        = 02.

ENDMODULE.
