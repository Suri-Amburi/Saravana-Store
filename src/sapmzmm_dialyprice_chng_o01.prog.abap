*&---------------------------------------------------------------------*
*& Include          SAPMZMM_DIALYPRICE_CHNG_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'PF_9001'.
  SET TITLEBAR 'T9001'.
*--> Added Vertical Scrollbar -> sjena <- 07.02.2020 13:59:56
  CHECK gt_matlist IS NOT INITIAL.
  DESCRIBE TABLE gt_matlist LINES DATA(lv_lines).
  tc_matlist-lines = lv_lines + 1.
  tc_matlist-v_scroll = abap_true.
ENDMODULE.
