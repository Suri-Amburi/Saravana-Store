*------------------------------------------------------------------
*        Lagerplatzbestand.
* Der maximale Lagerplatzbestand eines Lagertyps darf nicht kleiner
* sein als der minimale.
*------------------------------------------------------------------
MODULE LAGERPLATZBESTAND.

 CHECK BILDFLAG = SPACE.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ. "MK/19.04.95

 CALL FUNCTION 'LAGERPLATZBESTAND'
     EXPORTING
          P_MLGT_LPMIN    = MLGT-LPMIN
          P_MLGT_LPMAX    = MLGT-LPMAX .
*    EXCEPTIONS
*         ERROR_NACHRICHT = 01.

ENDMODULE.
