*&---------------------------------------------------------------------*
*& Include          SAPMZ_PACKING_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
* SET PF-STATUS 'ZGUI_9000'.
* SET TITLEBAR 'xxx'.
 SET TITLEBAR 'TITLE_9001'.
  CLEAR : ITEM_DATA.
  IF GT_LIPS IS INITIAL.
    PERFORM GET_DATA.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  SET CURSOR FIELD GV_CUR_FIELD.
  CLEAR : GV_CHARG.
ENDMODULE.
