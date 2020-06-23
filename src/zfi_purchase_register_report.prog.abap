*&---------------------------------------------------------------------*
*& Report ZFI_PURCHASE_REGISTER_REPORT
*&---------------------------------------------------------------------*
*& TC     : Suri
*& T-Code : ZPUR_REG
*& Purpous : PURCHASE REGISTER REPORT
*&---------------------------------------------------------------------*
REPORT ZFI_PURCHASE_REGISTER_REPORT.


INCLUDE ZFI_PUR_REGISTER_TOP.
INCLUDE ZFI_PUR_REGISTER_SEL.
INCLUDE ZFI_PUR_REGISTER_FORM.

AT SELECTION-SCREEN.

  SELECT SINGLE * FROM EKBE  WHERE BELNR IN S_BELNR
  AND   BEWTP = 'Q'
  OR    BEWTP = 'N'.
  IF SY-SUBRC <> 0.
    MESSAGE 'Please enter correct Invoice No' TYPE 'E'.
  ENDIF.
  """""""""""""""""""""""""START-OF-SELECTION"""""""""""""""""""

START-OF-SELECTION.
IF P_PUR = 'X'.
  PERFORM FETCH_DATA.
  PERFORM FIELDCATLOG.
  PERFORM OUTPUT.
ELSEIF P_NEW = 'X'.
PERFORM FI_POSTING.
ENDIF.
