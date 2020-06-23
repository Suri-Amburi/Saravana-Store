*&---------------------------------------------------------------------*
*& Include          SAPMZ_PACKING_PAI
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
    WHEN C_EXIT.
      LEAVE PROGRAM.
    WHEN C_PDN.
      PERFORM PROCESS_PG_DN.
    WHEN C_PUP.
      PERFORM PROCESS_PG_UP.
    WHEN C_SEL.
      IF GV_SEL IS NOT INITIAL.
        PERFORM CLEAR_DATA.
        PERFORM GET_COUNT.
        CALL SCREEN 9001.
    ELSE.
***     Message :  Enter Selected Line
      MESSAGE S007(ZMSG_CLS) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
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
    WHEN C_BACK.
      CLEAR : svbeln .
      LEAVE TO SCREEN 0.
    WHEN C_ENTER OR SPACE.
      PERFORM SCAN_BATCH.
    WHEN C_OHU.
      PERFORM CREATE_HU.
    WHEN C_CHU.
      PERFORM CLOSE_HU.
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
