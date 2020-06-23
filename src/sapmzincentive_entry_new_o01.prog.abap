*&---------------------------------------------------------------------*
*& Include          SAPMZINCENTIVE_ENTRY_NEW_O01
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


IF it_item IS NOT INITIAL.
  LOOP AT SCREEN.
    IF screen-name = 'LV_WERKS'.
       screen-input = '0'.
       screen-active = '1'.
       MODIFY SCREEN.
     ENDIF.
  ENDLOOP.
ENDIF.


ENDMODULE.
