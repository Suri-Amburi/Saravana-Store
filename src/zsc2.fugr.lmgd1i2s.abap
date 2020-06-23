*------------------------------------------------------------------
*  Module MARC-DISPO.
*  Pruefung des Disponenten.
*------------------------------------------------------------------
MODULE MARC-DISPO.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_DISPO'
       EXPORTING
            P_DISPO      = MARC-DISPO
            P_WERKS      = RMMG1-WERKS
            P_KZ_NO_WARN = ' '.
*  EXCEPTIONS
*       ERR_MARC_DISPO = 01.
*       ERR_T024D      = 02.

ENDMODULE.
