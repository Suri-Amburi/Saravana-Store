*&---------------------------------------------------------------------*
*& Include          ZFI_IBANKMASTER_C02_ROUTINE
*&---------------------------------------------------------------------*
  PERFORM GET_DATA CHANGING IT_FILE.
  PERFORM PROCESS_DATA USING IT_FILE.
  PERFORM FIELDCAT.
  PERFORM DISPLAY_DATA.
