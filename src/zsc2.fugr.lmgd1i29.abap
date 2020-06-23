*------------------------------------------------------------------
*  Module MARC-SBDKZ.
*  Falls gemäß Materialart/Werk keine mengenmäßige Führung des
*  Materials erlaubt ist, ist nur Einzelfertigung erlaubt
*------------------------------------------------------------------
MODULE MARC-SBDKZ.
  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_SBDKZ'
       EXPORTING
            P_SBDKZ      = MARC-SBDKZ
            P_DISMM      = MARC-DISMM
            P_WERKS      = RMMG1-WERKS
            P_MTART      = RMMG1-MTART
            P_KZ_NO_WARN = ' '.
ENDMODULE.
