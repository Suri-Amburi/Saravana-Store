***********************************************************************
*         MFHM-PLANV                                                  *
***********************************************************************
*   Prüfen, ob angegebene Planvariante zulässig                       *
***********************************************************************
MODULE MFHM-PLANV INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* ---   Planverwendung verproben   ----
  CALL FUNCTION 'CF_CK_PLANV'
       EXPORTING
            PLANV_IMP             = MFHM-PLANV
            PLANV_NOT_INITIAL_IMP = 'X'
            MSGTY_IMP             = 'E'
            SPRAS_IMP             = SY-LANGU.
* ---  Prüfen Verwendung bei Änderung Planverwendung   ---

  IF T130M-AKTYP = AKTYPV.
    CALL FUNCTION 'CF_CK_PLANV_CHANGE'
         EXPORTING
              PLANV_NEW_IMP   = MFHM-PLANV
              PLANV_OLD_IMP   = *MFHM-PLANV
              OBJTY_IMP       = MFHM-OBJTY
              OBJID_IMP       = MFHM-OBJID
              MSGTY_IMP       = 'E'
         EXCEPTIONS
              OK_PLANV_CHANGE = 01
              NO_OBJID        = 02
              NO_OBJTY        = 03.
  ENDIF.

ENDMODULE.
