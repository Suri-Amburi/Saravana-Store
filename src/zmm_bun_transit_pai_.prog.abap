*&---------------------------------------------------------------------*
*& Include          ZMM_BUN_TRANSIT_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9003 INPUT.
break breddy.
  DATA(OK_CODE) = OK_9003.
  CLEAR :OK_9003.
  CASE OK_CODE.
    WHEN C_BACK OR C_CANCEL OR C_EXIT.
      PERFORM : CLEAR_DATA.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
