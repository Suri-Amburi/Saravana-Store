*&---------------------------------------------------------------------*
*& Include          SAPMZMM_STO_RF_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'PF_9001'.
  SET TITLEBAR 'T9001'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_UPDATE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE screen_update OUTPUT.

  IF gv_fwhs IS NOT INITIAL.
    SET CURSOR FIELD 'GV_TSTORE'.
    LOOP AT SCREEN.
      IF screen-name = 'GV_FWHS'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF gv_fwhs IS NOT INITIAL AND gv_tstore IS NOT INITIAL.
    SET CURSOR FIELD 'GV_BATCH'.
    LOOP AT SCREEN.
      IF screen-name = 'GV_TSTORE'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF gv_batch IS NOT INITIAL.
    SET CURSOR FIELD 'GV_QTY'.
  ENDIF.
ENDMODULE.
