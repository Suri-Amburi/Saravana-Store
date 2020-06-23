***********************************************************************
*         MFHM-FGRU1                                                  *
***********************************************************************
*   Prüfen, ob angegebener Gruppierungsschlüssel zulässig             *
***********************************************************************
MODULE MFHM-FGRU1 INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'CF_CK_FGRUP'
       EXPORTING
            FGRUP_IMP = MFHM-FGRU1
            MSGTY_IMP = 'E'
            SPRAS_IMP = SY-LANGU.

ENDMODULE.
