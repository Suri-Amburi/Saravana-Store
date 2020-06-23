***INCLUDE RBDAUTHI.
*---------------------------------------------------------------------*
*       FORM AUTHORITY_CHECK_CUSTOMER_MODEL                           *
*---------------------------------------------------------------------*
FORM AUTHORITY_CHECK_CUSTOMER_MODEL USING VALUE(A_ACTVT)
                                          VALUE(A_CUSTMODEL)
                                          VALUE(A_OWN_REACTION).
  AUTHORITY-CHECK OBJECT 'B_ALE_MODL'
                  ID 'ACTVT' FIELD A_ACTVT
                  ID 'CUSTMODEL' FIELD A_CUSTMODEL.
  IF SY-SUBRC <> 0 AND NOT A_OWN_REACTION IS INITIAL.
    MESSAGE ID 'B1' TYPE 'E' NUMBER '125'
      WITH 'B_ALE_MODL' A_ACTVT A_CUSTMODEL ''.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM AUTHORITY_CHECK_LOGICAL_SYSTEM                           *
*---------------------------------------------------------------------*
FORM AUTHORITY_CHECK_LOGICAL_SYSTEM USING VALUE(A_LOGSYS)
                                          VALUE(A_OWN_REACTION).
  AUTHORITY-CHECK OBJECT 'B_ALE_LSYS'
                  ID 'LOGSYS' FIELD A_LOGSYS.
  IF SY-SUBRC <> 0 AND NOT A_OWN_REACTION IS INITIAL.
    MESSAGE ID 'B1' TYPE 'E' NUMBER '125'
      WITH 'B_ALE_LSYS' A_LOGSYS '' ''.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM AUTHORITY_CHECK_REDUCTION                                *
*---------------------------------------------------------------------*
FORM AUTHORITY_CHECK_REDUCTION USING VALUE(A_REFMESTYP)
                                     VALUE(A_MESTYP)
                                     VALUE(A_OWN_REACTION).
  AUTHORITY-CHECK OBJECT 'B_ALE_REDU'
                  ID 'REFMESTYP' FIELD A_REFMESTYP
                  ID 'EDI_MES' FIELD A_MESTYP.
  IF SY-SUBRC <> 0 AND NOT A_OWN_REACTION IS INITIAL.
    MESSAGE ID 'B1' TYPE 'E' NUMBER '125'
      WITH 'B_ALE_REDU' A_REFMESTYP A_MESTYP ''.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM AUTHORITY_CHECK_IDOC                                     *
*---------------------------------------------------------------------*
FORM AUTHORITY_CHECK_IDOC USING VALUE(A_ACTVT)
                                VALUE(A_EDI_DIR)
                                VALUE(A_EDI_MES)
                                VALUE(A_EDI_PRN)
                                VALUE(A_EDI_PRT)
                                VALUE(A_EDI_TCD)
                                VALUE(A_OWN_REACTION).
  AUTHORITY-CHECK OBJECT 'S_IDOCMONI'
                  ID 'ACTVT' FIELD A_ACTVT
                  ID 'EDI_DIR' FIELD A_EDI_DIR
                  ID 'EDI_MES' FIELD A_EDI_MES
                  ID 'EDI_PRN' FIELD A_EDI_PRN
                  ID 'EDI_PRT' FIELD A_EDI_PRT
                  ID 'EDI_TCD' FIELD A_EDI_TCD.
  IF SY-SUBRC <> 0 AND NOT A_OWN_REACTION IS INITIAL.
    MESSAGE ID 'B1' TYPE 'E' NUMBER '125'
      WITH 'B_ALE_REDU' A_ACTVT A_EDI_DIR A_EDI_MES.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM AUTHORITY_CHECK_MASTER_DATA                              *
*---------------------------------------------------------------------*
FORM AUTHORITY_CHECK_MASTER_DATA USING VALUE(A_MESTYP)
                                       VALUE(A_OWN_REACTION).
  AUTHORITY-CHECK OBJECT 'B_ALE_MAST'
                  ID 'EDI_MES' FIELD A_MESTYP.
  IF SY-SUBRC <> 0 AND NOT A_OWN_REACTION IS INITIAL.
    MESSAGE ID 'B1' TYPE 'E' NUMBER '125'
      WITH 'B_ALE_MAST' A_MESTYP '' ''.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM AUTHORITY_CHECK_RECEIVE                                  *
*---------------------------------------------------------------------*
FORM AUTHORITY_CHECK_RECEIVE USING VALUE(A_MESTYP)
                                   VALUE(A_OWN_REACTION).
  AUTHORITY-CHECK OBJECT 'B_ALE_RECV'
                  ID 'EDI_MES' FIELD A_MESTYP.
  IF SY-SUBRC <> 0 AND NOT A_OWN_REACTION IS INITIAL.
    MESSAGE ID 'B1' TYPE 'E' NUMBER '125'
      WITH 'B_ALE_RECV' A_MESTYP '' ''.
  ENDIF.
ENDFORM.
