*&---------------------------------------------------------------------*
*& Include          ZFI_AS91_AB01_ABLDT_SUB
*&---------------------------------------------------------------------*
PERFORM GET_DATA     CHANGING I_EXCELTAB.
PERFORM PROCESS_DATA USING    I_EXCELTAB.
PERFORM ERRMSG       USING    I_ERRMSG.
