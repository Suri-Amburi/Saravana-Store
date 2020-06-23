*&---------------------------------------------------------------------*
*& Include          ZMM_SCAN_BATCH_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'ZGUI'.
  SET TITLEBAR 'ZTIT_9000'.
  IF gv_mode = c_d.
    LOOP AT SCREEN.
      IF screen-name = 'GS_BATCHES-SCAN_BATCH'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF grid IS BOUND.
  CALL METHOD grid->refresh_table_display.
  ELSE.
    PERFORM display_data.
  ENDIF.

ENDMODULE.
