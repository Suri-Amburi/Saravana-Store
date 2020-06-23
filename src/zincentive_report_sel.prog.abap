*&---------------------------------------------------------------------*
*& Include          ZINCENTIVE_REPORT_SEL
*&---------------------------------------------------------------------

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_werks FOR lv_werks,
                  s_date  FOR lv_date OBLIGATORY,
                  s_pernr FOR lv_pernr.
SELECTION-SCREEN : END OF BLOCK b1.
