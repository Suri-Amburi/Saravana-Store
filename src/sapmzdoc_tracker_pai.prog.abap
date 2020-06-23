*&---------------------------------------------------------------------*
*& Include          SAPMZDOC_TRACKER_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  DATA(OK_CODE) = OK_9001.
  CLEAR : OK_9001.
  CASE OK_CODE.
    WHEN C_CANCEL OR C_BACK OR C_EXIT.
      PERFORM CLEAR_DATA.
      LEAVE TO SCREEN 0.
    WHEN C_ENTER OR ' '.
      PERFORM SCAN_QR USING GV_QR.
    WHEN C_SAVE OR 'SPOS'.
      PERFORM SAVE_DATA.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
