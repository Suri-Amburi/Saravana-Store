*&---------------------------------------------------------------------*
*& Include          ZFI_TDS_SELSCREEN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZFI_TDS_SELSCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS : P_BUKRS LIKE BSEG-BUKRS OBLIGATORY,
             P_YEAR  LIKE BSEG-GJAHR OBLIGATORY.

SELECT-OPTIONS:   S_SECCO FOR BSEG-SECCO OBLIGATORY,        "Note 1847679
                  S_QSCOD FOR J_1IEWTNUMGR-QSCOD OBLIGATORY.
PARAMETERS :      P_LEDGER LIKE T881-RLDNR ."Note 1615465
SELECTION-SCREEN END OF BLOCK B1.
SKIP.
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
PARAMETER:   P_MNTH TYPE  J_1I_MONTH,
             P_QRTR TYPE  J_1I_QRTR.
PARAMETER:   P_REV TYPE C AS CHECKBOX DEFAULT 'X'.          "2035236
SELECTION-SCREEN END OF BLOCK B2.
SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-003.
SELECT-OPTIONS: S_LIFNR FOR BSEG-LIFNR .
PARAMETERS: P_EXEMP AS CHECKBOX USER-COMMAND P_E,
            P_PAN   AS CHECKBOX USER-COMMAND P_P.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS:S_KUNNR FOR BSEG-KUNNR.
SELECTION-SCREEN END OF BLOCK B3.
SELECTION-SCREEN BEGIN OF BLOCK B4 WITH FRAME TITLE TEXT-039 .
PARAMETERS:
  P_INTC RADIOBUTTON GROUP REPO,
  P_BNKC RADIOBUTTON GROUP REPO,
  P_CERT RADIOBUTTON GROUP REPO,
  P_CONS RADIOBUTTON GROUP REPO DEFAULT 'X',
  P_NOCH RADIOBUTTON GROUP REPO.
SELECTION-SCREEN END OF BLOCK B4.

AT SELECTION-SCREEN.
  PERFORM GET_YEAR_FROM_FISCALYEAR. "Note 1592267
  PERFORM FETCH_PERIOD_INTERVAL USING FIRST_DATE
                                      P_QRTR
                                      P_MNTH
                             CHANGING STARTDATE
                                            ENDDATE.
  PERFORM RESTRICT_PERIOD_SELECTION USING P_MNTH
                                          P_QRTR.
  PERFORM RESTRICT_PARTNER_SELECTION.
  PERFORM RESTRICT_VENDOR_OPTIONS   USING P_EXEMP
                                        P_PAN.
*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON BUKRS
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON P_BUKRS.

  CALL FUNCTION 'FI_COMPANY_CODE_CHECK'
    EXPORTING
      I_BUKRS      = P_BUKRS
    EXCEPTIONS
      COMPANY_CODE = 1
      OTHERS       = 2.

  IF SY-SUBRC NE 0 .
    MESSAGE E128(8I)  .
  ENDIF.
*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON LIFNR
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON S_LIFNR.
  DATA: WA_LFB1 LIKE LFB1.
  IF NOT S_LIFNR IS INITIAL.
    SELECT SINGLE * FROM LFB1 INTO WA_LFB1
            WHERE LIFNR IN S_LIFNR
    AND   BUKRS =  P_BUKRS.
    IF SY-SUBRC NE 0 .
*      MESSAGE E396 WITH S_LIFNR-LOW .
    ENDIF .
  ENDIF .
*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON KUNNR
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON S_KUNNR.
  DATA: WA_KNB1 LIKE KNB1.
  IF NOT S_KUNNR IS INITIAL .
    SELECT SINGLE * FROM KNB1 INTO WA_KNB1
           WHERE  KUNNR IN S_KUNNR
    AND    BUKRS  = P_BUKRS.
    IF SY-SUBRC NE 0 .
*      MESSAGE E715 WITH S_KUNNR-LOW .
    ENDIF .
  ENDIF .
*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON QSCOD
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON S_QSCOD.
  DATA: WA_T059O LIKE T059O.
  IF S_QSCOD NE ''.
    SELECT SINGLE * FROM T059O INTO WA_T059O
            WHERE LAND1 = 'IN'
    AND WT_QSCOD IN S_QSCOD.
    IF SY-SUBRC NE 0.
*      MESSAGE E703 WITH S_QSCOD-LOW.
    ENDIF .
  ENDIF.
*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON SECCO
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON P_MNTH.

  IF NOT P_MNTH IS INITIAL .
    TRANSLATE P_MNTH TO UPPER CASE.                         "#EC *
    IF P_MNTH EQ 'JANUARY' OR P_MNTH EQ 'FEBRUARY' OR P_MNTH EQ 'MARCH' OR P_MNTH EQ 'APRIL' OR P_MNTH EQ 'MAY' OR P_MNTH EQ 'JUNE' OR
      P_MNTH EQ 'JULY' OR P_MNTH EQ 'AUGUST' OR P_MNTH EQ 'SEPTEMBER' OR P_MNTH EQ 'OCTOBER' OR P_MNTH EQ 'NOVEMBER' OR P_MNTH EQ 'DECEMBER'.
    ELSE.
*      MESSAGE E000 WITH 'InCorrect Month'.
    ENDIF .
  ENDIF.
*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON Quarter
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON P_QRTR.

  IF NOT P_QRTR IS INITIAL .
    TRANSLATE P_QRTR TO UPPER CASE.                         "#EC *
    IF P_QRTR EQ 'Q1' OR P_QRTR EQ 'Q2' OR P_QRTR EQ 'Q3' OR P_QRTR EQ 'Q4'.
    ELSE.
*      MESSAGE E000 WITH 'InCorrect Quarter'.                "#EC NOTEXT
    ENDIF .
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  PERFORM HIDE_VENDOR_OPTIONS.
  PERFORM FILL_LEDGER. "Note 1615465

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_MNTH.
  PERFORM GET_MONTH_LIST CHANGING P_MNTH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_QRTR.
  PERFORM GET_QUARTER_LIST CHANGING P_QRTR.

AT SELECTION-SCREEN ON S_SECCO.
  DATA: WA_J_1BBRANCH LIKE J_1BBRANCH.
  DATA: WA_SECCODE LIKE SECCODE.
  IF NOT S_SECCO IS INITIAL .
*    SELECT SINGLE * FROM j_1bbranch INTO wa_j_1bbranch "Note2372121
*                  WHERE bukrs  = p_bukrs
*                  AND   branch IN s_secco.
*    IF sy-subrc NE 0 .
*      MESSAGE e738  WITH s_secco space.
*    ENDIF.

    SELECT SINGLE * FROM SECCODE INTO WA_SECCODE
    WHERE BUKRS  =  P_BUKRS
    AND   SECCODE IN S_SECCO.
    IF SY-SUBRC NE 0 .
*      MESSAGE E738  WITH S_SECCO SPACE.
    ENDIF .

  ENDIF .
*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON MONTH
*&---------------------------------------------------------------------*
