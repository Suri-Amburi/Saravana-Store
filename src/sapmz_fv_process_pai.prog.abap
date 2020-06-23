*&---------------------------------------------------------------------*
*& Include          SAPMZ_FV_PROCESS_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  DATA(OK_CODE) = OK_9001.
  CLEAR :OK_9001.
  CASE OK_CODE.
    WHEN C_CLEAR.
      PERFORM CLEAR_ALL.
    WHEN C_BACK OR C_CANCEL OR C_EXIT.
      PERFORM : CLEAR.
      LEAVE TO SCREEN 0.
    WHEN SPACE.
    WHEN C_SAVE.
      IF GS_HDR-MBLNR_541 IS INITIAL.
        PERFORM POST_DATA.
      ELSE.
        MESSAGE I087(ZMSG_CLS).
      ENDIF.
    WHEN C_STOCK.
      PERFORM DISPLAY_STOCK.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9100 INPUT.
OK_CODE = OK_9100.
  CLEAR :OK_9100.
  CASE OK_CODE.
    WHEN C_BACK OR C_CANCEL OR C_EXIT.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CLEAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear INPUT.
CLEAR : ok_9100.
LEAVE TO SCREEN 0.
ENDMODULE.
