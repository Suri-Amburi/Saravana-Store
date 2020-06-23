*&---------------------------------------------------------------------*
*& Report ZHR_PAY_SLIP_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHR_PAY_SLIP_REP.

INCLUDE ZHR_PAY_SLIP_TOP.

START-OF-SELECTION.

GET PERNR.
INCLUDE ZHR_PAY_SLIP_SUB.
INCLUDE ZHR_PAY_SLIP_FORM.
