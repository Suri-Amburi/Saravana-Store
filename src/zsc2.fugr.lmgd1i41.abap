***********************************************************************
*         MFHM-BZOFFB                                                 *
***********************************************************************
*   Prüfen, ob angegebener Bezug Start zulässig                       *
***********************************************************************
MODULE MFHM-BZOFFB INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'CF_CK_BZOFF'
       EXPORTING
            BZOFF_IMP             = MFHM-BZOFFB
            BZOFF_NOT_INITIAL_IMP = 'X'
            MSGTY_IMP             = 'E'
            SPRAS_IMP             = SY-LANGU.

ENDMODULE.
