* AHE: 12.05.98 - A (4.0c)
*&---------------------------------------------------------------------*
*&      Module  MARC-PRENO  INPUT
*&---------------------------------------------------------------------*
*       Prüfen Außenhandelsdaten: Negativbescheinigungsfelder
*       MARC-PRENO, MARC-PREND, MARC-PRENC
*----------------------------------------------------------------------*
MODULE MARC-PRENO INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_PRENO'
       EXPORTING
            WMARC          = MARC
            P_KZ_NO_WARN   = ' '
       EXCEPTIONS
            ERR_MARC_PRENO = 1
            OTHERS         = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                 " MARC-PRENO  INPUT
