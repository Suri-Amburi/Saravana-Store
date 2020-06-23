*&---------------------------------------------------------------------*
*& Include          ZMM_BUN_TRANSIT_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9003 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9003 OUTPUT.
  SET PF-STATUS 'ZGUI_9003'.
  CLEAR :GV_SUBRC.
  IF CONTAINER IS NOT BOUND.
    CREATE OBJECT CONTAINER
      EXPORTING
        CONTAINER_NAME = 'MYCONTAINER'.
    CREATE OBJECT GRID
      EXPORTING
        I_PARENT = CONTAINER.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
    PERFORM PREPARE_FCAT.
    PERFORM DISPLAY_DATA_SCR3.

  ELSE.
    IF GT_ITEM IS NOT INITIAL.
      IF GRID IS BOUND.
        DATA: IS_STABLE TYPE LVC_S_STBL, LV_LINES TYPE INT2.
        IS_STABLE = 'XX'.
        IF GRID IS BOUND.
          CALL METHOD GRID->REFRESH_TABLE_DISPLAY
            EXPORTING
              IS_STABLE = IS_STABLE               " With Stable Rows/Columns
            EXCEPTIONS
              FINISHED  = 1                       " Display was Ended (by Export)
              OTHERS    = 2.
          IF SY-SUBRC <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.
