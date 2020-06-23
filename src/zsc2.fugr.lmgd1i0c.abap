*----------------------------------------------------------------------
* Module MARA-XGCHP.                                   "4.0A  BE/190897
*
* Prüfen Genehmigung Chargenprotokoll erforderlich
*----------------------------------------------------------------------
MODULE MARA-XGCHP.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_XGCHP'
       EXPORTING
            WMARA_XGCHP   = MARA-XGCHP
            WMARA_XCHPF   = MARA-XCHPF
            CHARGEN_EBENE = RMMG2-CHARGEBENE.

ENDMODULE.
