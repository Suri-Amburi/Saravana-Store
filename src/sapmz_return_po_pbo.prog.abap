*&---------------------------------------------------------------------*
*& Include          SAPMZ_RETURN_PO_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  DATA : FCODE TYPE TABLE OF SY-UCOMM.
  DATA: IT_LIST  TYPE VRM_VALUES.
  DATA: WA_LIST  TYPE VRM_VALUE.
  REFRESH : IT_LIST.
  CLEAR : WA_LIST.
  WA_LIST-KEY = '01'.
  WA_LIST-TEXT = 'SHORTAGE'.
  APPEND WA_LIST TO IT_LIST.
  WA_LIST-KEY = '02'.
  WA_LIST-TEXT = 'DAMAGE'.
  APPEND WA_LIST TO IT_LIST.

  SORT IT_LIST ASCENDING BY KEY.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = 'DROP_DOWN'
      VALUES          = IT_LIST
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.
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
