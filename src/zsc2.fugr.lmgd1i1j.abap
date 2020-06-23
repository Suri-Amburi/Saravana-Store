*----------------------------------------------------------------------
*  Module MARC-VSPVB.                                  "4.0A  BE/130897
*  Prüfen Vorschlags-Produktionsversorgungsbereich
*----------------------------------------------------------------------
MODULE MARC-VSPVB.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_VSPVB'
       EXPORTING
            WMARC_VSPVB = MARC-VSPVB
            WMARC_LGPRO = MARC-LGPRO
            WMARC_WERKS = MARC-WERKS.

ENDMODULE.
