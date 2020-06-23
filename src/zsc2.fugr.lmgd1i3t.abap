***********************************************************************
*         MFHM-KTSCH                                                  *
***********************************************************************
*   Prüfen, ob angegebener Vorlagenschlüssel zulässig ist             *
***********************************************************************
MODULE MFHM-KTSCH INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'CF_CK_KTSCH'
       EXPORTING
            KTSCH_IMP = MFHM-KTSCH
            MSGTY_IMP = 'E'
            SPRAS_IMP = SY-LANGU.

ENDMODULE.
