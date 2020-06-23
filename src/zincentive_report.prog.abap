*&---------------------------------------------------------------------*
*& Report ZINCENTIVE_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zincentive_report.

INCLUDE zincentive_report_top.
INCLUDE zincentive_report_sel.

START-OF-SELECTION.
PERFORM get_data.
PERFORM loop_data.
PERFORM display.

INCLUDE zincentive_report_form.
