*&---------------------------------------------------------------------*
*& Include          ZSD_VK11_P01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  PERFORM GET_DATA CHANGING GIT_FILE.
  PERFORM PROCESS_DATA USING GIT_FILE.
