*&---------------------------------------------------------------------*
*& Include          ZMM_BUN_TRANSIT_S01
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : S_MATKL FOR GV_MATKL,
                 S_RANGE FOR GV_RANGE.
PARAMETERS : P_F TYPE CHAR1 RADIOBUTTON GROUP G1,
             P_S TYPE CHAR1 RADIOBUTTON GROUP G1.
SELECTION-SCREEN END OF BLOCK B1.
