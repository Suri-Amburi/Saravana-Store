*------------------------------------------------------------------
*  Module MARC-LGPRO.                 ch/24.10.95   neu zu 3.0B
*  Prüfen, ob das Material im Produktionslagerort bereits exisitiert .
*  (bzw. gerade angelegt wird)
*------------------------------------------------------------------
MODULE MARC-LGPRO.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_LGPRO'
       EXPORTING
            P_MATNR      = MARA-MATNR
            P_WERKS      = MARC-WERKS
            P_LGORT      = MARD-LGORT
            P_LGPRO      = MARC-LGPRO
            P_NEUFLAG    = NEUFLAG
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           OTHERS       = 1.

ENDMODULE.
