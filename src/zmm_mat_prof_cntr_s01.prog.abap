*&---------------------------------------------------------------------*
*& Include          ZMM_MAT_PROF_CNTR_S01
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS : P_FILE TYPE STRING.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK BLCK1 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
SELECTION-SCREEN COMMENT 1(79) TEXT-003.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 2.
SELECTION-SCREEN COMMENT 6(79) TEXT-004.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK BLCK1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.
