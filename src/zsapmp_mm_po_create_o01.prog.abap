*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_PO_CREATE_O01
*&---------------------------------------------------------------------*

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC1'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC1_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_ITEM LINES TC1-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC1'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE TC1_GET_LINES OUTPUT.
  G_TC1_LINES = SY-LOOPC.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
 SET PF-STATUS 'STATUS_9000'.
 SET TITLEBAR 'TITLE_9000'.
  IF WA_HEADER-AEDAT IS INITIAL.
  WA_HEADER-AEDAT  = SY-DATUM.
ENDIF.
  IF WA_HEADER-LGORT IS INITIAL.
  WA_HEADER-LGORT  = 'FG01'.
ENDIF.
 PERFORM clear .
 CLEAR : wa_header-site , wa_header-lifnr .
 PERFORM get_data.
* CLEAR : wa_header.
ENDMODULE.
