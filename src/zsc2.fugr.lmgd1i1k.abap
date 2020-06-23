*----------------------------------------------------------------------
*  Module MARC-FVIDK.                                  "4.0A  BE/120897
*  Prüfen der Fertigungsversion gegen die Tabelle MKAL
*----------------------------------------------------------------------
MODULE MARC-FVIDK.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_FVIDK'
       EXPORTING
            WMARC_FVIDK = MARC-FVIDK
            WMARC_WERKS = MARC-WERKS
            WMARC_MATNR = MARC-MATNR.

ENDMODULE.
