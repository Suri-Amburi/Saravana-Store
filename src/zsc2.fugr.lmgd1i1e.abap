* AHE: 15.03.98 - A (4.0c)
*&---------------------------------------------------------------------*
*&      Module  MARC-SHPRO  INPUT
*&---------------------------------------------------------------------*
*       Prüfung auf gültiges Bedarfsvorlauf-Periodenprofil
*----------------------------------------------------------------------*
MODULE MARC-SHPRO INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_SHPRO'
       EXPORTING
            P_WERKS          = MARC-WERKS
            P_SHPRO          = MARC-SHPRO
*      TABLES
*           RETURN           = TMESSAGE
       EXCEPTIONS
            P_ERR_MARC_SHPRO = 1
            OTHERS           = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                             " MARC-SHPRO  INPUT
