*&---------------------------------------------------------------------*
*& Include          SAPMZMM_FRT_VEG_STORE_RECV_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  DATA(lc_okcode) = ok_9001.
  CLEAR: ok_9001.

  CASE lc_okcode.
    WHEN c_back.
      LEAVE TO SCREEN 0.
    WHEN c_exit.
      LEAVE PROGRAM.
    WHEN c_canc.
      LEAVE TO SCREEN 0.
    WHEN 'ENTE'.
      PERFORM get_matlist.
    WHEN 'POST'.
      PERFORM goods_movement.
  ENDCASE.
ENDMODULE.
