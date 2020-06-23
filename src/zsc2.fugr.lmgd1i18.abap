*------------------------------------------------------------------
*  Module MARA-EKWSL
*
* Es wird ueberprueft, ob der eingegebene Werteschluessel in T405 ist.
*------------------------------------------------------------------
MODULE MARA-EKWSL.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.


  CALL FUNCTION 'MARA_EKWSL'
       EXPORTING
            P_MARA_EKWSL = MARA-EKWSL
       IMPORTING
            WT405        = T405.
*      EXCEPTIONS
*           ERROR_NACHRICHT = 01.

ENDMODULE.
