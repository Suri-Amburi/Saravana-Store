***********************************************************************
*         MFHM-EWFORM                                                 *
***********************************************************************
*   Prüfen, ob angegebene Einsatzwertformel zulässig                  *
***********************************************************************
MODULE MFHM-EWFORM INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'CF_CK_FORMEL'
       EXPORTING
            FORMEL_IMP = MFHM-EWFORM
            MSGTY_IMP  = 'E'
            SPRAS_IMP  = SY-LANGU.

ENDMODULE.
