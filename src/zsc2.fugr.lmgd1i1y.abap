*------------------------------------------------------------------
*  Module MARC-VBAMG.
*  Pruefung der Basismenge zur Versandbearbeitungszeit.
*------------------------------------------------------------------
MODULE MARC-VBAMG.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_VBAMG'
       EXPORTING
            WMARC_VBAMG = MARC-VBAMG
            WMARC_VBEAZ = MARC-VBEAZ.

ENDMODULE.
