*&---------------------------------------------------------------------*
*& Include          ZSAPMP_FI_CFO_DIARY_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
 SET PF-STATUS 'ZSTATUS'.
 SET TITLEBAR 'CFO DIARY'.
* BREAK-POINT.
  IF lv_date7 is INITIAL.
     lv_date7 = syst-datum.
  ENDIF.
*BREAK-POINT.
PERFORM GET_AMOUNT .
PERFORM GET_BANK_AMT.
ENDMODULE.
