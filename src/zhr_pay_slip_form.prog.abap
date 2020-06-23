*&---------------------------------------------------------------------*
*& Include          ZHR_PAY_SLIP_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEL_DATA .

  RP-PROVIDE-FROM-LAST P0000 SPACE PN-BEGDA PN-ENDDA.
  RP-PROVIDE-FROM-LAST P0001 SPACE PN-BEGDA PN-ENDDA.
  RP-PROVIDE-FROM-LAST P2001 SPACE PN-BEGDA PN-ENDDA.
  it_p0000[] = p0000[].


sort it_p0000 BY begda ASCENDING.
    read table it_p0000 into wa_p0000 index 1.
  WA_HEADER-PERNR = wa_P0000-PERNR.
  WA_HEADER-JOIN_D = wa_P0000-BEGDA.
  WA_HEADER-ENAME = P0001-ENAME.
  WA_HEADER-CADER = P0001-PERSK.
  WA_HEADER-LOP_DAY = P2001-ABWTG.

*  WA_FINAL-NO_WORK_DAY = P0001-A0BWTG.
*  WA_FINAL-LOP_DAY = P0001-LOP_DAY.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form RT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RT .

  REFRESH: GIT_RGDIR.
  CALL FUNCTION 'CU_READ_RGDIR'
    EXPORTING
      PERSNR          = PERNR-PERNR
*     BUFFER          =
*     NO_AUTHORITY_CHECK       = ' '
* IMPORTING
*     MOLGA           =
    TABLES
      IN_RGDIR        = GIT_RGDIR
    EXCEPTIONS
      NO_RECORD_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

**** payslip for month and year ****
  DATA : LV_MONTH(10),
         LV_MNUM(2),
         LV_YR(4),
         LV_FPPER TYPE FPPER.

  IF PNPTIMR6 = 'X'.
    CONCATENATE  PNPDISPJ  PNPDISPP INTO LV_FPPER.
  ENDIF.
  .
  IF PNPXABKR IS NOT INITIAL.
    READ TABLE GIT_RGDIR INTO LS_RGDIR WITH KEY PAYTY = '' SRTZA = 'A' FPPER = LV_FPPER.
*  else.
*    read table git_rgdir into ls_rgdir with key payty = '' srtza = 'A'  fpbeg = pnpbegda
*                                 fpend = pnpendda.
  ENDIF.
*SELECT SINGLE
*  SPRAS
*  MNR
*  KTX
*  LTX FROM T247 INTO WA_T247
*                WHERE SPRAS = SY-LANGU
*                AND MNR = PNPDISPP.

*WA_HEADER-MONTH = WA_T247-LTX.
*CONCATENATE WA_T247-LTX PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
*WA_HEADER-YEAR = WA_T247-KTX.

CASE PNPDISPP.
  WHEN '01'.
      CONCATENATE 'April' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
  WHEN '02'.
      CONCATENATE 'May' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
  WHEN '03'.
      CONCATENATE 'June' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
  WHEN '04'.
      CONCATENATE 'July' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
  WHEN '05'.
      CONCATENATE 'August' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
  WHEN '06'.
      CONCATENATE 'September' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
  WHEN '07'.
      CONCATENATE 'October' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
  WHEN '08'.
      CONCATENATE 'November' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.
  WHEN '09'.
      CONCATENATE 'December' PNPDISPJ INTO WA_HEADER-MONTH SEPARATED BY ' '.

ENDCASE.




  CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
    EXPORTING
      CLUSTERID                    = 'IN'
      EMPLOYEENUMBER               = PERNR-PERNR
      SEQUENCENUMBER               = LS_RGDIR-SEQNR
    CHANGING
      PAYROLL_RESULT               = PAY_RESULTS
    EXCEPTIONS
      ILLEGAL_ISOCODE_OR_CLUSTERID = 1
      ERROR_GENERATING_IMPORT      = 2
      IMPORT_MISMATCH_ERROR        = 3
      SUBPOOL_DIR_FULL             = 4
      NO_READ_AUTHORITY            = 5
      NO_RECORD_FOUND              = 6
      VERSIONS_DO_NOT_MATCH        = 7
      ERROR_READING_ARCHIVE        = 8
      ERROR_READING_RELID          = 9
      OTHERS                       = 10.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  SORT PAY_RESULTS-INTER-RT BY LGART.

*BREAK breddy.
  LOOP AT PAY_RESULTS-INTER-RT INTO WA_RT.
    CLEAR: WA_T512T.
    SELECT SINGLE * FROM   T512T INTO WA_T512T  WHERE SPRSL = 'EN' AND
      LGART = WA_RT-LGART AND
      MOLGA = 40.
*READ TABLE T512T into wa_T512T with key lgart = wa_rt-lgart.

*      IF wa_rt2-betrg < 0.
*        wa_rt2-betrg = -1 * wa_rt2-betrg.
*      ENDIF.
    CASE WA_RT-LGART.


      WHEN '1000'.
        WA_FINAL-ALL_AMT    = WA_RT-BETRG.
        WA_FINAL-ALL_DESC    = WA_T512T-LGTXT.
      WHEN '1001'.
        WA_FINAL-ALL_AMT  = WA_RT-BETRG.
        WA_FINAL-ALL_DESC    = WA_T512T-LGTXT.
      WHEN '1003'.
        WA_FINAL-ALL_AMT   = WA_RT-BETRG.
        WA_FINAL-ALL_DESC    = WA_T512T-LGTXT.
      WHEN '1005'.
        WA_FINAL-ALL_AMT    = WA_RT-BETRG.
        WA_FINAL-ALL_DESC   = WA_T512T-LGTXT.
      WHEN '/560'.
        WA_HEADER-NET_PAY      = WA_RT-BETRG.
*        wa_final-desc    = wa_t512t-lgtxt.
      WHEN '/3F1'.
        WA_FINAL-DED_AMT    = WA_RT-BETRG.
        WA_FINAL-DED_DESC    = WA_T512T-LGTXT.
      WHEN '/3F1'.
        WA_HEADER-TOT_DED      = WA_RT-BETRG.
*        wa_final-desc    = wa_t512t-lgtxt.
      WHEN '/101'.
        WA_HEADER-GROSS        = WA_RT-BETRG.
      WHEN '/814'.
        WA_HEADER-NDW          = WA_RT-BETRG.
*        CONDENSE wa_header-ndw.

*        wa_final-desc    = wa_t512t-lgtxt.
    ENDCASE.
    WA_FINAL-SNO = LV_SL_NO.
    APPEND WA_FINAL TO IT_FINAL.
    LV_SL_NO = LV_SL_NO + 1.
    CLEAR: WA_FINAL.
  ENDLOOP.

  DATA : AMOUNT     TYPE PC207-BETRG.
*         WORDS(100) TYPE C.
  AMOUNT = WA_HEADER-NET_PAY.
  CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
    EXPORTING
      AMT_IN_NUM         = AMOUNT
    IMPORTING
      AMT_IN_WORDS       = WA_HEADER-WORDS
    EXCEPTIONS
      DATA_TYPE_MISMATCH = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_F
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_F .

  DATA : FNAME TYPE RS38L_FNAM.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZHR_PAYSLIP_FORM'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = FNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION FNAME
    EXPORTING
      WA_HEADER = WA_HEADER
    TABLES
      IT_FINAL  = IT_FINAL.

*END-OF-SELECTION.

ENDFORM.
