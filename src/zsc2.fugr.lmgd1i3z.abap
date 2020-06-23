***********************************************************************
*         MFHM-EHOFFB                                                 *
***********************************************************************
*   Verproben Einheit Vor-/Nachlaufzeitverschiebung Start
***********************************************************************
MODULE MFHM-EHOFFB INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MFHM_EHOFFB'
       EXPORTING
            P_MFHM_EHOFFB   = MFHM-EHOFFB
            P_MFHM_OFFSTB   = MFHM-OFFSTB
       EXCEPTIONS
            ERROR_EXIT      = 01
            ERROR_NACHRICHT = 02.

  CASE SY-SUBRC.
    WHEN 01.
      EXIT.
    WHEN 02.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO.
  ENDCASE.

* ---   Verproben Zeiteinheit   ---
  CALL FUNCTION 'CF_CK_EINH_TIME'
       EXPORTING
            MEINS_IMP         = MFHM-EHOFFB
            MSGTY_IMP         = 'E'
            SPRAS_IMP         = SY-LANGU
       EXCEPTIONS
            OK_DIMENSION_TIME = 01.

ENDMODULE.
