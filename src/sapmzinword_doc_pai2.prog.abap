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
*      PERFORM UPDATE_TOTALS.
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
***  Calling Return PO
      CHECK  WA_HDR-RETURN_PO IS NOT INITIAL.
      CALL FUNCTION 'ZFM_PURCHASE_FORM'
        EXPORTING
          LV_EBELN       = WA_HDR-RETURN_PO
          RETURN_PO      = C_X         " Purchasing Document Number
          PRINT_PRIEVIEW = C_X.             " Single-Character Flag
    WHEN C_REFRESH.
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
