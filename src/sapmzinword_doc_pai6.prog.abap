*&---------------------------------------------------------------------*
*& Include          SAPMZINWORD_DOC_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  DATA(OK_UCOMM)  = OK_CODE.
  GET CURSOR FIELD LV_CUR_FIELD.
  CASE OK_UCOMM.
    WHEN C_SAVE.
      IF LV_MOD <> C_D.
        PERFORM SAVE_DATA.
        LV_MOD = C_D.
      ENDIF.
    WHEN C_ENTER.
*      PERFORM VALIDATE_CHARGES.
      PERFORM UPDATE_TOTALS.
    WHEN C_DISPLAY.
      LV_MOD = C_D.
      PERFORM GET_DATA.
    WHEN C_EDIT.
*      IF P_QR_CODE IS NOT INITIAL.
      CLEAR : LV_TRNS, WA_HDR.
      LV_MOD = C_EDIT.
*        MESSAGE S025(ZMSG_CLS) DISPLAY LIKE 'E'.
*        LEAVE TO LIST-PROCESSING.
*      ELSE.
*        LV_MOD = C_EDIT.
      PERFORM GET_DATA.
*      ENDIF.
    WHEN C_BACK OR C_EXIT OR C_CANCEL.
      LEAVE TO SCREEN 0.
    WHEN C_TAT.
*** Tatkal PO Creation
      PERFORM CREATE_TATKAL_PO.
    WHEN C_MATH.
*** Quantity Matched
      PERFORM UPDATE_STATUS.
    WHEN C_DEBIT.
*** Debit Note Creation
      LEAVE TO TRANSACTION 'ZR_PO'.
    WHEN C_PRINT.
*** Printing Form : Inward Doc
      IF WA_HDR-QR_CODE IS NOT INITIAL.
        PERFORM TP2_FORM IN PROGRAM ZMM_GRPO_DET_REP USING WA_HDR-QR_CODE.
      ENDIF.
    WHEN C_TAT_D.
***  Calling Tatkal PO
      CHECK  WA_HDR-TAT_PO IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          LV_EBELN       = WA_HDR-TAT_PO
          TATKAL_PO      = C_X   " Purchasing Document Number
          PRINT_PRIEVIEW = C_X.             " Single-Character Flag
    WHEN C_DEBIT_D.
***  Calling Tatkal PO
      CHECK  WA_HDR-RETURN_PO IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          LV_EBELN       = WA_HDR-RETURN_PO
          RETURN_PO      = C_X         " Purchasing Document Number
          PRINT_PRIEVIEW = C_X.             " Single-Character Flag
    WHEN C_REFRESH.
    WHEN C_CLOSE.
      PERFORM COMPLITE_DOC.
    WHEN C_INV.
      SUBMIT ZFI_MIRO WITH P_QR = WA_HDR-QR_CODE AND RETURN.
    WHEN C_APR1.
***  APPROVAL 1
      SELECT SINGLE PARID FROM USR05 INTO LV_APPROVAL WHERE BNAME = SY-UNAME AND PARID = C_APPROVAL1 .
      IF SY-SUBRC IS INITIAL.
***     Invocie & Debit Note
        SUBMIT ZFI_MIRO WITH P_QR = WA_HDR-QR_CODE AND RETURN.
      ELSE.
        MESSAGE S056(ZMSG_CLS) DISPLAY LIKE 'E' WITH 'Level 1'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
    WHEN C_APR2.
***  Approval 2
      SELECT SINGLE PARID FROM USR05 INTO LV_APPROVAL WHERE BNAME = SY-UNAME AND PARID = C_APPROVAL2 .
      IF SY-SUBRC IS INITIAL.
        PERFORM UPDATE_INVOCIE_APPROVE USING 'L2' 'Level 2'.
      ELSE.
        MESSAGE S056(ZMSG_CLS) DISPLAY LIKE 'E' WITH 'Level 2'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
    WHEN C_APR3.
***  Approval 3
      SELECT SINGLE PARID FROM USR05 INTO LV_APPROVAL WHERE BNAME = SY-UNAME AND PARID = C_APPROVAL3.
      IF SY-SUBRC IS INITIAL.
        PERFORM UPDATE_INVOCIE_APPROVE USING 'L3' 'Level 3'.
      ELSE.
        MESSAGE S056(ZMSG_CLS) DISPLAY LIKE 'E' WITH 'Level 3'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
    WHEN C_PAY.
***  Payment FB05
      SUBMIT ZFI_PAYMENT WITH P_QR = WA_HDR-QR_CODE AND RETURN.
    WHEN C_GRPO_P.
      PERFORM PRINT_GRPO_PRICE_LIST.
    WHEN C_GRPO_S.
      PERFORM PRINT_GRPO_SUMMERY.
    WHEN C_TRNS.
***  Calling Service PO
      CHECK  WA_HDR-SERVICE_PO IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          LV_EBELN       = WA_HDR-SERVICE_PO
          PRINT_PRIEVIEW = C_X
          SERVICE_PO     = C_X.
    WHEN C_PAY_ADV.
      PERFORM PAYMENT_ADVICE.
    WHEN C_AUDITOR.
      PERFORM UPDATE_AUDITOR_CHECK.
  ENDCASE.
  CLEAR : OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_PO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_PO INPUT.
  PERFORM VALIDATE_PO.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CLEAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR INPUT.
  IF OK_CODE = C_EXIT OR OK_CODE = C_CANCEL.
    PERFORM CLEAR.
  ENDIF.
  IF SY-UCOMM = C_CLEAR.
    PERFORM CLEAR_ALL.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_QR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_QR INPUT.
  PERFORM VALIDATE_QR.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_HEADER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_HEADER INPUT.
  PERFORM VALIDATE_HEADER .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_TRANS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TRANS INPUT.
  PERFORM F4_TRANS.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CLEAR_ALL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_ALL INPUT.
  PERFORM CLEAR_ALL.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_CHARGES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_CHARGES INPUT.
  PERFORM VALIDATE_CHARGES.
ENDMODULE.
