*&---------------------------------------------------------------------*
*& Include          SAPMZ_GATEIN_LP_PBO
*&---------------------------------------------------------------------*


MODULE STATUS_9000 OUTPUT.
SET PF-STATUS 'ZGUI_9000'.
SET TITLEBAR 'ZTIT_9000'.
*  PERFORM CLEAR.
CLEAR  : GV_MOD.
PERFORM DISPLAY_LOGO.
ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
  DATA : FCODE TYPE TABLE OF SY-UCOMM.
  IF SY-UCOMM = C_SAVE AND GV_MOD = C_D.
    REFRESH : FCODE.
    APPEND C_SAVE TO FCODE.
  ELSE.
    REFRESH : FCODE.
  ENDIF.
  SET PF-STATUS 'ZGUI_9001' EXCLUDING FCODE.
*  PERFORM display_mode.
  PERFORM FIELD_CAT.
*** Displaying ALV
  PERFORM DISPLAY_DATA.
ENDMODULE.
