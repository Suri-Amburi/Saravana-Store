*&---------------------------------------------------------------------*
*& Include          SAPMZ_PACKING_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  DATA(ok_code) = ok_9000.
  CLEAR : ok_9000.
  CASE ok_code.
    WHEN c_exit.
      LEAVE PROGRAM.
    WHEN c_pdn.
      PERFORM process_pg_dn.
    WHEN c_pup.
      PERFORM process_pg_up.
    WHEN c_sel.
      IF gv_sel IS NOT INITIAL.
        PERFORM clear_data.
        PERFORM get_count.
        CALL SCREEN 9001.
      ELSE.
***     Message :  Enter Selected Line
        MESSAGE s007(zmsg_cls) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  ok_code = ok_9001.
  CLEAR : ok_9001.
  CASE ok_code.
    WHEN c_back.
      CLEAR : svbeln .
      LEAVE TO SCREEN 0.
    WHEN c_enter OR space.
      PERFORM scan_batch.
    WHEN c_ohu.
      PERFORM create_hu.
    WHEN c_chu.
      PERFORM close_hu.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_DELV  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_delv INPUT.
  PERFORM clear_data.
  DATA : lv_b_qty TYPE lips-lfimg.
  READ TABLE gt_lips ASSIGNING FIELD-SYMBOL(<ls_lisp>) with KEY vbeln = svbeln.
  IF sy-subrc = 0.
    gv_del = <ls_lisp>-vbeln.
    SELECT vbeln, posnr, lfimg, kcmeng, werks FROM lips INTO TABLE @DATA(lt_qty) WHERE vbeln = @gv_del.
    LOOP AT lt_qty ASSIGNING FIELD-SYMBOL(<ls_qty>).
      AT FIRST.
        gv_plant = <ls_qty>-werks.
      ENDAT.
      ADD <ls_qty>-lfimg  TO gv_t_qty.
      ADD <ls_qty>-kcmeng TO lv_b_qty.
    ENDLOOP.
    gv_p_qty = gv_t_qty - lv_b_qty.
  ELSE.
***  Message :  Invalid Line
    CLEAR : svbeln.
    MESSAGE 'Invalid Delv. No. ' && svbeln TYPE 'W'.
    EXIT.
  ENDIF.
  CALL SCREEN 9001.
ENDMODULE.
