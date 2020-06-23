***********************************************************************
*         MFHM-STEUF
***********************************************************************
*   Prüfen, ob angegebener Steuerschlüssel zulässig                   *
***********************************************************************
MODULE MFHM-STEUF INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'CF_CK_STEUF'
       EXPORTING
            STEUF_IMP             = MFHM-STEUF
            STEUF_NOT_INITIAL_IMP = MFHM-STEUF_REF
            MSGTY_IMP             = 'E'
            SPRAS_IMP             = SY-LANGU.

ENDMODULE.
