*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD_T01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_STOCK_UPLOAD1_TOP
*&---------------------------------------------------------------------*

*** File Structure
TYPES :
  BEGIN OF TY_FILE,
    SLNO(4),
    MATERIAL(40),
    PLANT(20),
    STGE_LOC(20),
    MOVE_TYPE(20),
    AMOUNT(23),
    ENTRY_QNT(10),
    ENTRY_UOM(3),
    BATCH(10),
    B1_BATCH(40),
    B1_VENDOR(10),
    DOC_DATE(10),
    PSTNG_DATE(10),
    SPEC_STOCK(20),
  END OF TY_FILE,

*** Final table for Display Status
  BEGIN OF TY_FINAL,
    SLNO(5),
    MATNR         TYPE MARA-MATNR,
    CHARG         TYPE MSEG-CHARG,
    MBLNR         TYPE MKPF-MBLNR,
    MJAHR         TYPE MKPF-MJAHR,
    MSGTY         TYPE TEXT1,
    MSG           TYPE TEXT255,
    B1_BATCH(40),
    B1_VENDOR(10),
  END OF TY_FINAL.

DATA:
  GT_FILE  TYPE TABLE OF TY_FILE,
  GT_FINAL TYPE TABLE OF TY_FINAL,
  GS_FINAL TYPE TY_FINAL,
  FNAME    TYPE LOCALFILE,
  ENAME    TYPE CHAR4.
