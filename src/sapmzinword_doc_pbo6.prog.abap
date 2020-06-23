*&---------------------------------------------------------------------*
*& Include          SAPMZINWORD_DOC_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
  SET PF-STATUS 'ZGUI'.
  SET TITLEBAR 'ZTIT_9000'.
  SET CURSOR FIELD LV_CUR_FIELD.
  PERFORM DISPLAY_MODE.
  PERFORM EXCLUDE_ICONS.
  PERFORM PREPARE_FCAT.
  PERFORM DISPLAY_DATA.
ENDMODULE.
