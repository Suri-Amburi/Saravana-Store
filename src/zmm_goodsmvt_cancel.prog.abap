*&---------------------------------------------------------------------*
*& Report ZMM_GOODSMVT_CANCEL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_GOODSMVT_CANCEL.

INCLUDE ZMM_GOODSMVT_CANCEL_TOP.
INCLUDE ZMM_GOODSMVT_CANCEL_SEL.
INCLUDE ZMM_GOODSMVT_CANCEL_SUB.

START-OF-SELECTION.

  PERFORM FETCH_MAT_DOC.
  CHECK IT_LOG[] IS NOT INITIAL .
  PERFORM LAYOUT.
  PERFORM PREPARE_FIELDCAT.
  PERFORM DISPLAY.
