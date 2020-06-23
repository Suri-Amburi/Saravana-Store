*------------------------------------------------------------------
*  Module MARC-SAUFT.
*  Bei der Zurücknahme des Kennz. Serienauftrag wird geprüft, ob
*  keine Fertigungsauftragsversionen mit Serienkz. vorhanden
*  sind.
*------------------------------------------------------------------
MODULE MARC-SAUFT.

  CHECK BILDFLAG IS INITIAL.           "mk/21.04.95
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ. "mk/21.04.95

  CALL FUNCTION 'MARC_SAUFT'
       EXPORTING
            P_SAUFT         = MARC-SAUFT
            P_LSAUFT        = LMARC-SAUFT
            P_NEUFLAG       = NEUFLAG
            P_FLGMKALVERARB = RMMG2-MKALVERARB  " vorher: FLGMKALVERARB
            P_RMMG1_MATNR   = RMMG1-MATNR
            P_RMMG1_WERKS   = RMMG1-WERKS
            P_KZ_NO_WARN    = ' '.
*      EXCEPTIONS
*           P_ERR_MARC_SAUFT = 01.

ENDMODULE.
