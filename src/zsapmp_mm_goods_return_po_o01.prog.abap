*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_GOODS_RETURN_PO_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'STATUS'.
  SET TITLEBAR 'TITLE'.
  IF lv_ebeln IS NOT INITIAL AND gv_mblnr_n IS NOT INITIAL.

*    LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT.
*    APPEND LS_EXCLUDE TO LT_EXCLUDE.
    SET PF-STATUS 'STATUS' EXCLUDING 'SAVE' .

  ENDIF.

IF lv_ebeln IS NOT INITIAL.
      LOOP AT SCREEN.
    IF screen-name =  'LV_BATCH'.
      screen-input  = '0' .
      screen-active = '1'.
      MODIFY SCREEN .
    ENDIF.
  ENDLOOP.
ENDIF.

IF it_final IS NOT INITIAL.
      LOOP AT SCREEN.
    IF screen-name =  'LV_WERKS' OR screen-name = 'LV_LIFNR'.
      screen-input  = '0' .
      screen-active = '1'.
      MODIFY SCREEN .
    ENDIF.
  ENDLOOP.
ENDIF.

IF rad2 IS INITIAL.
  LOOP AT SCREEN.
    IF screen-group1 =  'B1'.
      screen-input  = '0' .
      screen-invisible = '1'.
      MODIFY SCREEN .
    ENDIF.
  ENDLOOP.
ENDIF.

IF rad2 IS NOT INITIAL.
 SELECT SINGLE name1 FROM lfa1 INTO lv_name1 WHERE lifnr = lv_lifnr.
ENDIF.

   IF grid IS BOUND.
    ls_stable-row = 'X'.
    ls_stable-col = 'X'.
    CALL METHOD grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
    ENDIF .
  ENDIF .

*  PERFORM get_data .
ENDMODULE.
