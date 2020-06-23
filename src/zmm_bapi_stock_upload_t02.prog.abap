*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD_T01
*&---------------------------------------------------------------------*

*** File Structure
DATA:
  GT_FILE TYPE TABLE OF ZB1_STOCK,
  FNAME   TYPE LOCALFILE,
  ENAME   TYPE CHAR4.

CONSTANTS :
  C_X(1) VALUE 'X',
  C_S(1) VALUE 'S',
  C_E(1) VALUE 'E'.
