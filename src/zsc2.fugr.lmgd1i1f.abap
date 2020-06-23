*&---------------------------------------------------------------------*
*&      Module  MARC-FPRFM  INPUT
*&---------------------------------------------------------------------*
*       Verteilungsprofil des Materials im Lager
*----------------------------------------------------------------------*
* AHE: 11.02.98 - A (4.0c)
* komplett neues Prüfmodul
*----------------------------------------------------------------------*
MODULE MARC-FPRFM INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'W_FRM_MARC_FPRFM'
       EXPORTING
            I_FPRFM              = MARC-FPRFM
            I_WERKS              = MARC-WERKS
*      TABLES
*           T_MATMESS            = TMESSAGE
       EXCEPTIONS
            PROFILE_INCONSISTENT = 1
            PROFILE_NOT_DEFINED  = 2
            PLANT_PROFILE_ERROR  = 3
            OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                             " MARC-FPRFM  INPUT
