***********************************************************************
*         MFHM-BZOFFE                                                 *
***********************************************************************
*   Prüfen, ob angegebener Bezug Ende zulässig                        *
***********************************************************************
MODULE MFHM-BZOFFE INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* ---   Bezugstermin verproben   ---
  CALL FUNCTION 'CF_CK_BZOFF'
       EXPORTING
            BZOFF_IMP             = MFHM-BZOFFE
            BZOFF_NOT_INITIAL_IMP = 'X'
            MSGTY_IMP             = 'E'
            SPRAS_IMP             = SY-LANGU.

ENDMODULE.
