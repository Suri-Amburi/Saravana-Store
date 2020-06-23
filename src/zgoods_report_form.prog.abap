*&---------------------------------------------------------------------*
*& Include          ZGOODS_REPORT_FORM
*&---------------------------------------------------------------------*

PERFORM ZGOODS_REPORT_GETDATA .
END-OF-SELECTION .
PERFORM ZGOODS_REPORT_PROCESSDATA .
