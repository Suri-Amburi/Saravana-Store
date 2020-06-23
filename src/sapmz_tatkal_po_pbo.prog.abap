*&---------------------------------------------------------------------*
*& Include          SAPMZ_TATKAL_PO_PBO
*&---------------------------------------------------------------------*

MODULE STATUS_9000 OUTPUT.
  DATA : FCODE TYPE TABLE OF SY-UCOMM.
  IF GV_MOD = C_D.
    APPEND C_SAVE TO FCODE.
  ENDIF.
  SET PF-STATUS 'ZGUI_9000' EXCLUDING FCODE.
  SET TITLEBAR 'ZTIT'.
  SET CURSOR FIELD GV_CUR_FIELD.
  CLEAR : GS_HDR-CHARG, GV_SUBRC.
  PERFORM DISPLAY_MODE.
*** Displaying ALV
  IF GRID IS NOT BOUND .
    PERFORM DISPLAY_ALV.
  ELSE.
    IF GT_ITEM IS NOT INITIAL.
      GRID->REFRESH_TABLE_DISPLAY( ).
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
 SET PF-STATUS 'ZGUI_9001'.
 SET TITLEBAR 'ZTIT9001'.
ENDMODULE.
