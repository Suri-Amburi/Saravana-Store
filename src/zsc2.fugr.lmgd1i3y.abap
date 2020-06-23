***********************************************************************
*         MFHM-EHOFFE                                                 *
***********************************************************************
*   Verproben Einheit Vor-/Nachlaufzeitverschiebung Ende
***********************************************************************
MODULE MFHM-EHOFFE INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MFHM_EHOFFE'
       EXPORTING
            P_MFHM_EHOFFE   = MFHM-EHOFFE
            P_MFHM_OFFSTE   = MFHM-OFFSTE
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
            MEINS_IMP         = MFHM-EHOFFE
            MSGTY_IMP         = 'E'
            SPRAS_IMP         = SY-LANGU
       EXCEPTIONS
            OK_DIMENSION_TIME = 01.

ENDMODULE.
