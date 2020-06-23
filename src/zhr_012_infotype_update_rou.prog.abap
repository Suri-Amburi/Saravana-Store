*&---------------------------------------------------------------------*
*&  Include           ZHR_012_INFOTYPE_UPDATE_ROU
*&---------------------------------------------------------------------*

PERFORM GET_DATA     CHANGING IT_FINAL.
PERFORM PROCESS_DATA USING    IT_FINAL.
PERFORM DISPLAY_DATA.
