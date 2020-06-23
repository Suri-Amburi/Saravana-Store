*&---------------------------------------------------------------------*
*& Report ZFI_GSTR1_REPORTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_GSTR1_REPORTS.


SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS: R1  RADIOBUTTON GROUP R,
            R2  RADIOBUTTON GROUP R,
            R3  RADIOBUTTON GROUP R,
            R4  RADIOBUTTON GROUP R,
*            R6  RADIOBUTTON GROUP R,
            R7  RADIOBUTTON GROUP R,
*            R8  RADIOBUTTON GROUP R,
*            R9  RADIOBUTTON GROUP R,
            R10 RADIOBUTTON GROUP R,
*            R11 RADIOBUTTON GROUP R,
*            R12 RADIOBUTTON GROUP R,
            R5  RADIOBUTTON GROUP R,
            R13 RADIOBUTTON GROUP R.
SELECTION-SCREEN: END OF BLOCK B1.

START-OF-SELECTION.

  IF R1 = 'X'.

    CALL TRANSACTION 'ZGSTR1_HSN'.

  ELSEIF R2 = 'X'.

    CALL TRANSACTION 'ZGSTR1_B2B'.

  ELSEIF R3 = 'X'.

    CALL TRANSACTION 'ZGSTR1_B2C'.

  ELSEIF R4 = 'X'.

    CALL TRANSACTION 'ZGSTR1_EXP'.

  ELSEIF R5 = 'X'.
    CALL TRANSACTION 'ZGSTR1_CR'.
*  ELSEIF R6 = 'X'.
*    CALL TRANSACTION 'ZGSTR1_DN'.
  ELSEIF R7 = 'X'.
    CALL TRANSACTION 'ZSUBCR'.
*  ELSEIF R8 = 'X'.
*    CALL TRANSACTION 'ZGSTR_CANN'.
*  ELSEIF R9 = 'X'.
*    CALL TRANSACTION 'ZGSTR_CANS'.
  ELSEIF R10 = 'X'.
    CALL TRANSACTION 'ZCSTAI'.
*  ELSEIF R11 = 'X'.
*    CALL TRANSACTION 'ZCSTAIC' .
*  ELSEIF R12 = 'X'.
*    CALL TRANSACTION 'ZCRCNL' .
  ELSEIF R13 = 'X'.
    CALL TRANSACTION 'ZSRET' .

  ENDIF.