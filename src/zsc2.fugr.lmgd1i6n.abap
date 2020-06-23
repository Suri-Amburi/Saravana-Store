*---------------------------------------------------------------------*
*            XTHEAD_LEER_DEL                                          *
*---------------------------------------------------------------------*
*     - Alle noch nicht bearbeiteten Vorlage-Texte werden gesichert   *
*---------------------------------------------------------------------*
MODULE MESSAGE_LANGTEXTE.
  CALL FUNCTION 'MESSAGE_LANGTEXTE'
       EXPORTING
            OK_CODE  = RMMZU-OKCODE
            P_AKTYP  = T130M-AKTYP
            ltext_required = ltext_required                     "TF 4.6A
       CHANGING
            BILDFLAG = BILDFLAG.
ENDMODULE.
