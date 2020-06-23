*&---------------------------------------------------------------------*
*& Include          SAPMZ_LOCAL_PURCH_GR_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'ZGUI_9000'.
  SET TITLEBAR 'ZTIT_9000'.

IF lv_budat IS INITIAL.
  lv_budat = sy-datum.
ENDIF.

  CLEAR :gv_subrc.
  IF container IS NOT BOUND.
    CREATE OBJECT container
      EXPORTING
        container_name = 'CONTAINER'.
    CREATE OBJECT grid
      EXPORTING
        i_parent = container.
  ELSE.
    IF gt_item IS NOT INITIAL.
      IF grid IS BOUND.
        DATA: is_stable TYPE lvc_s_stbl, lv_lines TYPE int2.
        is_stable = 'XX'.
        IF grid IS BOUND.
          CALL METHOD grid->refresh_table_display
            EXPORTING
              is_stable = is_stable               " With Stable Rows/Columns
            EXCEPTIONS
              finished  = 1                       " Display was Ended (by Export)
              OTHERS    = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*** Display  Mode
  IF gv_mode  = c_d.
    LOOP AT SCREEN.
      IF screen-group1 = 'BUTTON'.
        CONTINUE.
      ENDIF.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.
