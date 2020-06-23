*&---------------------------------------------------------------------*
*& Include          ZMM_MAT_PROF_CNTR_T01
*&---------------------------------------------------------------------*

*** Data Declerations

TYPES :
  BEGIN OF TY_FILE,
    MATNR TYPE CHAR40,
  END OF  TY_FILE,

  BEGIN OF TY_MSGS,
    MATNR   TYPE CHAR40,
    PLANT   TYPE WERKS_D,
    MESSAGE TYPE CHAR40,
  END OF  TY_MSGS.

*** File Type table
DATA :
  GT_FILE TYPE TABLE OF TY_FILE,
  GT_MSGS TYPE TABLE OF TY_MSGS.
