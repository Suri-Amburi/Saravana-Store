*&---------------------------------------------------------------------*
*& Report ZMM_GATE_ENTRY_BDC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_GATE_ENTRY_BDC.

INCLUDE ZMM_GATE_ENTRY_BDC_T01.
INCLUDE ZMM_GATE_ENTRY_BDC_S01.
INCLUDE ZMM_GATE_ENTRY_BDC_F01.

*TYPES:BEGIN OF GTY_DISPLAY,
*        LR_NO            TYPE ZLR,
*        TRANSPORTER_CODE TYPE ZTRANS,
*        SMALL_BUNDLES    TYPE CHAR10,
*        BIG_BUNDLES      TYPE CHAR10,
*        PO_NUM           TYPE CHAR10,
*        TYPE             TYPE BAPI_MTYPE,
*        MESSAGE          TYPE BAPIRET2-MESSAGE,
*        PO_NUMBER        TYPE CHAR10,
*      END OF GTY_DISPLAY,
*      GTY_T_DISPLAY TYPE STANDARD TABLE OF GTY_DISPLAY.
*
*DATA: GWA_DISPLAY TYPE GTY_DISPLAY,
*      GIT_DISPLAY TYPE GTY_T_DISPLAY.

START-OF-SELECTION.
  PERFORM GET_DATA .
  PERFORM PROCESS_DATA.
