*&---------------------------------------------------------------------*
*& Include          SAPMZ_FV_PROCESS_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
  SET PF-STATUS 'ZPF_9001'.
  IF GR_GRID IS BOUND.
    CALL METHOD GR_GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

    DATA : IS_STABLE TYPE LVC_S_STBL, LV_LINES TYPE INT2.
*** Event is triggered when data is changed in the output
    IS_STABLE = 'XX'.
*** Refreshing Data with Cusrsor Hold
    IF GR_GRID IS BOUND.
      CALL METHOD GR_GRID->REFRESH_TABLE_DISPLAY
        EXPORTING
          IS_STABLE = IS_STABLE        " With Stable Rows/Columns
        EXCEPTIONS
          FINISHED  = 1                " Display was Ended (by Export)
          OTHERS    = 2.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM PREPARE_FCAT.
    PERFORM DISPLAY_DATA.
  ENDIF.
ENDMODULE.
