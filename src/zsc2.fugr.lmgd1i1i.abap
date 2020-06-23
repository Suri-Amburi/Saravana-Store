*----------------------------------------------------------------------
*  Module MARD-LWMKB.                                  "4.0A  BE/130897
*  Prüfen Kommisionierbereich für Lean-WM
*----------------------------------------------------------------------
MODULE MARD-LWMKB.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARD_LWMKB'
       EXPORTING
            WMARD_LWMKB = MARD-LWMKB
            WMARC_WERKS = MARC-WERKS
            WMARD_LGORT = MARD-LGORT.

ENDMODULE.
