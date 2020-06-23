*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  IF GRID IS BOUND.
    CALL METHOD GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
  ENDIF.
  SET PF-STATUS 'ZGUI_100'.
  PERFORM DISPLAY_MODE.
  PERFORM EXCLUDE_ICONS.
  PERFORM PREPARE_FCAT.
**  PERFORM DISPLAY_DATA.
ENDMODULE.
