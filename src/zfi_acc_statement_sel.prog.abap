*&---------------------------------------------------------------------*
*& Include          ZFI_ACC_STATEMENT_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY DEFAULT '1000',
            p_lifnr TYPE lifnr OBLIGATORY,
            p_year  TYPE gjahr OBLIGATORY.

SELECT-OPTIONS:  s_date  FOR lv_date.
PARAMETERS : report RADIOBUTTON GROUP g1,
             form   RADIOBUTTON GROUP g1.
SELECTION-SCREEN: END OF BLOCK b1.
