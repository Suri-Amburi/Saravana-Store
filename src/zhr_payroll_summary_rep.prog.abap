*&---------------------------------------------------------------------*
*& Report ZHR_PAYROLL_SUMMARY_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHR_PAYROLL_SUMMARY_REP.

INCLUDE ZHR_PAYROLL_SUMMARY_top.

START-OF-SELECTION.
GET pernr.
INCLUDE ZHR_PAYROLL_SUMMARY_SUB.
INCLUDE ZHR_PAYROLL_SUMMARY_FORM.
end-of-SELECTION.
