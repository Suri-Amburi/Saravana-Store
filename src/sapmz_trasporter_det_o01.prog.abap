*&---------------------------------------------------------------------*
*& Include          SAPMZ_TRASPORTER_DET_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
  SET PF-STATUS '9001'.
  SET TITLEBAR 'INVOICE'.

  PERFORM GET_BILL .
ENDMODULE.
