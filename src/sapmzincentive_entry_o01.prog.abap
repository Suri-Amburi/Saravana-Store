*&---------------------------------------------------------------------*
*& Include          SAPMZINCENTIVE_ENTRY_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
 SET PF-STATUS '1000'.
 SET TITLEBAR  '1000' WITH sy-uname sy-datum.

  IF container IS INITIAL.
   PERFORM alv_grid.
 ENDIF.
ENDMODULE.