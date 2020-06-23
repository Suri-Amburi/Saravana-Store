*&---------------------------------------------------------------------*
*& Include          ZEAN_POS_UPLOAD_S01
*&---------------------------------------------------------------------*

*** Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS : P_FILE TYPE STRING.
SELECTION-SCREEN END OF BLOCK B1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILENAME CHANGING P_FILE.
