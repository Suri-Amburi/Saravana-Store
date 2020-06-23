*&---------------------------------------------------------------------*
*& Include          SAPMZ_LOCAL_PURCH_GR_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
  DATA(OK_CODE) = OK_9000.
  CLEAR :OK_9000.
  CASE OK_CODE.
    WHEN C_SAVE.
      IF GV_MODE <> C_D.
        PERFORM SAVE_DATA CHANGING GV_SUBRC.
      ENDIF.
    WHEN C_BACK OR C_CANCEL OR C_EXIT.
      PERFORM : CLEAR_DATA.
      LEAVE TO SCREEN 0.
    WHEN C_REFRESH.
    WHEN SPACE.
      IF GV_SUBRC IS INITIAL.
        PERFORM : CLEAR_DATA.
        PERFORM GET_DATA CHANGING GV_SUBRC.
        CHECK GV_SUBRC IS INITIAL.
        PERFORM DISPLAY_DATA CHANGING GV_SUBRC.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_DATA INPUT.
  PERFORM VALIDATE_DATA.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  OK_CODE = OK_9000.
  CLEAR :OK_9000.
  CASE OK_CODE.
    WHEN C_BACK OR C_CANCEL OR C_EXIT.
      PERFORM : CLEAR_DATA.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
