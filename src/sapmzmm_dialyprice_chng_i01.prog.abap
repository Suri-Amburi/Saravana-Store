*&---------------------------------------------------------------------*
*& Include          SAPMZMM_DIALYPRICE_CHNG_I01
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
    WHEN 'FETCH'.
      PERFORM get_matlist.
    WHEN 'POST'.
      PERFORM goods_movement.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_LINE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_line INPUT.
  IF gs_matlist-sellprice IS NOT INITIAL.
    gs_matlist-sellprice = ceil( gs_matlist-sellprice ).
  ENDIF.
  MODIFY gt_matlist FROM gs_matlist  INDEX tc_matlist-current_line.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_chain INPUT.

IF gs_matlist-sellprice IS NOT INITIAL.
  IF gs_matlist-sellprice < gs_matlist-prchprice .
    MESSAGE 'Selling Price Should Not Be Less Than Purchase Price' TYPE 'E'.
  ENDIF.
ENDIF.
ENDMODULE.
