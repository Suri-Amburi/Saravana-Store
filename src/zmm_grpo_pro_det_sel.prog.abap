*&---------------------------------------------------------------------*
*& Include          ZMM_GRPO_PRO_DET_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN : BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : S_MBLNR FOR MBLNR,
                 S_DATE  FOR LV_DATE .

SELECTION-SCREEN : END OF BLOCK B1.
