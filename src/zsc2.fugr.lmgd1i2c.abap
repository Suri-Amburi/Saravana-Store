*------------------------------------------------------------------
*  Module MARC-PLIFZ.
*  Pruefung der Planlieferzeit.
*------------------------------------------------------------------
MODULE MARC-PLIFZ.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_PLIFZ'
       EXPORTING
            P_DISMM      = MARC-DISMM
            P_BESKZ      = MARC-BESKZ
            P_PLIFZ      = MARC-PLIFZ
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MARC_PLIFZ = 01.

ENDMODULE.
