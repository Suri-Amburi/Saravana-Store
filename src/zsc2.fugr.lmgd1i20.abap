*-----------------------------------------------------------------------
*  Module MARC-SFEPR
*  Falls Serienplanung erlaubt ist, muß auch ein Serienfertigungsprofil
*  angegeben werden
*-----------------------------------------------------------------------
MODULE MARC-SFEPR.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_SFEPR'
       EXPORTING
            P_SAUFT      = MARC-SAUFT
            P_SFEPR      = MARC-SFEPR
            P_AKTYP      = T130M-AKTYP
            P_Y_SAUFT    = *MARC-SAUFT
            P_Y_SFEPR    = *MARC-SFEPR
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MARC_SFEPR = 01.

ENDMODULE.
