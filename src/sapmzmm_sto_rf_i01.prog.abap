*&---------------------------------------------------------------------*
*& Include          SAPMZMM_STO_RF_I01
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
      PERFORM clear_all.
    WHEN c_exit.
      LEAVE PROGRAM.
    WHEN 'ENTE'.
      IF gv_batch IS NOT INITIAL AND gv_qty IS NOT INITIAL.
        gv_cnt = gv_cnt + 1.
        PERFORM fill_screen.
      ENDIF.
    WHEN 'FTCH'.
      gv_check = 'X'.
      PERFORM get_matlist.
    WHEN 'STO'.
      IF gv_check IS NOT INITIAL.
        PERFORM goods_movement.
      ELSE.
        MESSAGE 'Please read data first' TYPE 'I'.
      ENDIF.

  ENDCASE.
ENDMODULE.
