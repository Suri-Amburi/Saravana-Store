*&---------------------------------------------------------------------*
*& Include          ZFI_CNF_AC_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY DEFAULT '1000',
            p_lifnr TYPE lifnr OBLIGATORY,
            p_year  TYPE gjahr OBLIGATORY. " NO INTERVALS NO-EXTENSION OBLIGATORY.

SELECT-OPTIONS:  s_date  FOR lv_date.
**PARAMETERS : r_report RADIOBUTTON GROUP g1 ,
**             r_form   RADIOBUTTON GROUP g1.
SELECTION-SCREEN: END OF BLOCK b1.
