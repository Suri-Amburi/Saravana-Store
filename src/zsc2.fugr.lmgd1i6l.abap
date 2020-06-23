*---------------------------------------------------------------------*
*            XTHEAD_VORL_UPD                                          *
*---------------------------------------------------------------------*
*     - Alle noch nicht bearbeiteten Vorlage-Texte werden gesichert   *
*---------------------------------------------------------------------*
MODULE XTHEAD_VORL_UPD.
  CALL FUNCTION 'XTHEAD_VORL_UPD'
       EXPORTING
            OK_CODE = RMMZU-OKCODE
            P_AKTYP = T130M-AKTYP.
ENDMODULE.
