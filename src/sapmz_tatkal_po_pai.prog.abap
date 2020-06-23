*&---------------------------------------------------------------------*
*& Include          SAPMZ_TATKAL_PO_PAI
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
  DATA(OK_CODE) = OK_9000.
  CLEAR :  OK_9000.
  CASE OK_CODE.
    WHEN C_SAVE.
      PERFORM SAVE_DATA.
    WHEN C_BACK OR C_CANCEL.
      PERFORM CLEAR.
      LEAVE TO SCREEN 0.
    WHEN C_EXIT.
      LEAVE PROGRAM.
    WHEN C_ENTER OR C_SPACE.
      GET CURSOR FIELD GV_CUR_FIELD VALUE GV_CUR_VALUE.
      PERFORM SCAN_BATCH.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATIONS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATIONS INPUT.
  PERFORM VALIDATIONS.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  OK_CODE = OK_9001.
  CLEAR :  OK_9001.
  CASE OK_CODE.
    WHEN C_SAVE.
      PERFORM SAVE_DATA.
    WHEN C_BACK OR C_CANCEL.
      LEAVE TO SCREEN 0.
    WHEN C_EXIT.
      LEAVE PROGRAM.
    WHEN C_ENTER OR C_SPACE.
      MOVE-CORRESPONDING GS_INW_HDR TO GS_HDR.
      CALL SCREEN 9000.
  ENDCASE.
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
*&      Module  CANCEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CANCEL INPUT.
  OK_CODE = OK_9001.
  CLEAR : OK_9001.
  IF OK_CODE = C_CANCEL OR OK_CODE = C_BACK OR OK_CODE = C_EXIT .
    LEAVE TO SCREEN 0.
  ENDIF.
  CLEAR : OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CANCEL_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CANCEL_9000 INPUT.
 OK_CODE = OK_9000.
  CLEAR : OK_9000.
  IF OK_CODE = C_CANCEL OR OK_CODE = C_BACK OR OK_CODE = C_EXIT .
    LEAVE PROGRAM.
  ENDIF.
  CLEAR : OK_CODE.
ENDMODULE.
