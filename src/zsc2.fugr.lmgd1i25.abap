*------------------------------------------------------------------
*  Module MARC-SOBSL.
*  Pruefung des Sonderbeschaffungsschlüssels
*------------------------------------------------------------------
MODULE MARC-SOBSL.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_SOBSL'
       EXPORTING
            P_MATNR      = MARC-MATNR
            P_BESKZ      = MARC-BESKZ
            P_WERKS      = RMMG1-WERKS
            P_T134_KZPRC = T134-KZPRC
            NEUFLAG      = NEUFLAG
            P_KZ_NO_WARN = ' '
            P_NFMAT      = MARC-NFMAT              "354141
       CHANGING
            P_SOBSL      = MARC-SOBSL.              "354141
*       EXCEPTIONS                                  "note 1398475
*            ERR_MARC_SOBSL = 01.                   "note 1398475
*            ERR_T460A      = 02.

ENDMODULE.
