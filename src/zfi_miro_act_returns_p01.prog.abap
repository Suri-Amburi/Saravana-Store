*&---------------------------------------------------------------------*
*& Include          ZFI_MIRO_P01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  PERFORM VALIDATE_DATA.
  PERFORM GET_DATA USING P_QR CHANGING GV_SUBRC.
  IF GV_SUBRC IS INITIAL.
    PERFORM DEBIT_NOTE USING GV_RETURN_PO CHANGING GV_SUBRC.
  ENDIF.
  CHECK GV_SUBRC IS INITIAL AND INVOICEDOCNUMBER IS NOT INITIAL.
  PERFORM DISPLAY_MESSAGES.
