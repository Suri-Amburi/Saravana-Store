*&---------------------------------------------------------------------*
*& Include          SAPMZ_GATEIN_LP_PAI
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
  DATA(OK_CODE) = OK_9000.
  CLEAR : OK_9000.
  CASE OK_CODE.
    WHEN C_BACK OR C_CANCEL OR C_EXIT.
      PERFORM CLEAR.
    WHEN C_EXECUTE.
      PERFORM GET_DATA.
    WHEN C_RB.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  OK_CODE = OK_9001.
  CLEAR : OK_9001.
  CASE OK_CODE.
    WHEN C_BACK OR C_CANCEL.
      PERFORM CLEAR.
      LEAVE TO SCREEN 0.
    WHEN  C_EXIT.
      LEAVE PROGRAM.
    WHEN C_SAVE.
      PERFORM SAVE_DATA.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CANCEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CANCEL INPUT.
  IF OK_9000 = C_BACK OR OK_9000 = C_EXIT OR OK_9000 = C_CANCEL.
    CLEAR : OK_9000.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.
