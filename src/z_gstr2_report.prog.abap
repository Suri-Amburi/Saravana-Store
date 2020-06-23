*&---------------------------------------------------------------------*
*& Report Z_GSTR2_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_GSTR2_REPORT.
TYPE-POOLS:SLIS.
INCLUDE Z_GSTR2_REPORT_top .
INCLUDE Z_GSTR2_REPORT_select .

START-OF-SELECTION .
  INCLUDE Z_GSTR2_REPORT_sub .
  INCLUDE Z_GSTR2_REPORT_form .
