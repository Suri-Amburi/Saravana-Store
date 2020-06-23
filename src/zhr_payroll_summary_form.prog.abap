*&---------------------------------------------------------------------*
*& Include          ZHR_PAYROLL_SUMMARY_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  RP-PROVIDE-FROM-LAST P0000 SPACE PN-BEGDA PN-ENDDA.
  RP-PROVIDE-FROM-LAST P0001 SPACE PN-BEGDA PN-ENDDA.
*  RP-PROVIDE-FROM-LAST P0002 SPACE PN-BEGDA PN-ENDDA.

*  WA_FINAL-ENO = P0000-PERNR.
*  WA_FINAL-ENAME = P0001-ENAME.
*  WA_FINAL-SEX = P0002-GESCH.
*  WA_FINAL-DESIG = P0001-PERSK.


ENDFORM.
*&--------------------------------------------------------------------*
*& Form RT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RT_TAB .
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
  ENDIF.

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


  LOOP AT PAY_RESULTS-INTER-RT INTO WA_RT.
*    CLEAR: WA_T512T.
*    SELECT SINGLE * FROM   T512T INTO WA_T512T  WHERE SPRSL = 'EN' AND
*      LGART = WA_RT-LGART AND
*      MOLGA = 40.
*READ TABLE T512T into wa_T512T with key lgart = wa_rt-lgart.

*      IF wa_rt2-betrg < 0.
*        wa_rt2-betrg = -1 * wa_rt2-betrg.
*      ENDIF.

    WA_FINAL-ENO = P0000-PERNR.
    WA_FINAL-ENAME = P0001-ENAME.
*    WA_FINAL-SEX = P0002-GESCH.
*    WA_FINAL-DESIG = P0001-PERSK.
*    CASE WA_RT-LGART.
*
*      WHEN '1000'.
*        WA_FINAL-BASIC = WA_RT-BETRG.
*      WHEN '1001'.
*        WA_FINAL-DA = WA_RT-BETRG.
*      WHEN '1002'.
*        WA_FINAL-HRA = WA_RT-BETRG.
*      WHEN '1003'.
*        WA_FINAL-SP_ALL = WA_RT-BETRG.
*      WHEN '1004'.
*        WA_FINAL-OT_AMT = WA_RT-BETRG.
*      WHEN '1005'.
*        WA_FINAL-LEAVE_IC = WA_RT-BETRG.
*      WHEN '/101'.
*        WA_FINAL-GROSS = WA_RT-BETRG.
*        WA_FINAL-M_GROSS = WA_RT-BETRG.
*      WHEN '/560'.
*        WA_FINAL-S_PY = WA_RT-BETRG.
*      WHEN '/113'.
*        WA_FINAL-ESI = WA_RT-BETRG.
*      WHEN '2000'.
*        WA_FINAL-M_EXP = WA_RT-BETRG.
*      WHEN '/560'.
*        WA_FINAL-NET_SAL = WA_RT-BETRG.
*      WHEN '/814'.
*        WA_FINAL-NO_WRK  = WA_RT-BETRG.
*
*    ENDCASE.
      IF wa_rt = '/560'.
        wa_final-total = wa_rt-betrg.
      ENDIF.

    WA_FINAL-SNO = LV_SL_NO.
    APPEND WA_FINAL TO IT_FINAL.
    LV_SL_NO = LV_SL_NO + 1.
    CLEAR: WA_FINAL.

  ENDLOOP.


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

*  DATA : FNAME TYPE RS38L_FNAM.
*  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*    EXPORTING
*      FORMNAME           = 'ZHR_PAYROLL_FORM'
**     VARIANT            = ' '
**     DIRECT_CALL        = ' '
*    IMPORTING
*      FM_NAME            = FNAME
*    EXCEPTIONS
*      NO_FORM            = 1
*      NO_FUNCTION_MODULE = 2
*      OTHERS             = 3.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*  CALL FUNCTION FNAME
**    EXPORTING
**      WA_HEADER = WA_HEADER
*    TABLES
*      IT_FINAL  = IT_FINAL.

  REFRESH IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'SNO'.
  WA_FIELDCAT-SELTEXT_M = text-001.
  WA_FIELDCAT-JUST = 'C'.
*WA_FIELDCAT-EMPHASIZE = 'C1'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'ENO'.
  WA_FIELDCAT-SELTEXT_M = text-002.
  WA_FIELDCAT-JUST = 'L'.
*WA_FIELDCAT-EMPHASIZE = 'C1'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'ENAME'.
  WA_FIELDCAT-SELTEXT_M = text-003.
  WA_FIELDCAT-JUST = 'L'.
*WA_FIELDCAT-EMPHASIZE = 'C1'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'Total'.
  WA_FIELDCAT-SELTEXT_M = text-004.
  WA_FIELDCAT-JUST = 'L'.
*WA_FIELDCAT-EMPHASIZE = 'C1'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'DESIG'.
*  WA_FIELDCAT-SELTEXT_M = text-005.
*  WA_FIELDCAT-JUST = 'L'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = text-006.
*  WA_FIELDCAT-JUST = 'L'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = text-007.
*  WA_FIELDCAT-JUST = 'C'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = text-008.
*   WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'NO_WRK'.
*  WA_FIELDCAT-SELTEXT_M = text-009.
*  WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = text-010.
*   WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = text-011.
*  WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'BASIC'.
*  WA_FIELDCAT-SELTEXT_M = text-012.
*  WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'DA'.
*  WA_FIELDCAT-SELTEXT_M = text-013.
*  WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'HRA'.
*  WA_FIELDCAT-SELTEXT_M = text-014.
*  WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'SP_ALL'.
*  WA_FIELDCAT-SELTEXT_M = text-015.
*  WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'OT_AMT'.
*  WA_FIELDCAT-SELTEXT_M = text-016.
*  WA_FIELDCAT-JUST = 'R'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'LEAVE_IC'.
*  WA_FIELDCAT-SELTEXT_M = text-017.
*  WA_FIELDCAT-JUST = 'C'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = 'Surrender Wages'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'GROSS'.
*  WA_FIELDCAT-SELTEXT_M = 'GROSS'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'M_GROSS'.
*  WA_FIELDCAT-SELTEXT_M = 'Master Gross'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'S_PY'.
*  WA_FIELDCAT-SELTEXT_M = 'Salary PY'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'ESI'.
*  WA_FIELDCAT-SELTEXT_M = 'ESI'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'M_EXP'.
*  WA_FIELDCAT-SELTEXT_M = 'Miscellaneous Expenses'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = 'Washing Deduction'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = 'Other If Any'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
*  WA_FIELDCAT-FIELDNAME = 'NET_SAL'.
*  WA_FIELDCAT-SELTEXT_M = 'Net Salary'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = 'Signature with Date or Thumb Impression/Cheque and Date in case of payment through Bank'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*
**WA_FIELDCAT-FIELDNAME = ''.
*  WA_FIELDCAT-SELTEXT_M = 'Total'.
**WA_FIELDCAT-EMPHASIZE = 'C1'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISP_DATA .

  wa_layout-colwidth_optimize = 'X'.
  wa_layout-ZEBRA = 'X'.
  wa_layout-EXPAND_ALL = 'X'.


CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
*   I_CALLBACK_PROGRAM                = ' '
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
   IS_LAYOUT                         = wa_layout
   IT_FIELDCAT                       = IT_FIELDCAT
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB                          = IT_FINAL
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.


*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
**     i_callback_program          = sy-repid
**     i_callback_html_top_of_page = 'TOP-OF-PAGE'
*      IT_FIELDCAT   = IT_FIELDCAT
**     it_sort       = i_sort
*    TABLES
*      T_OUTTAB      = IT_FINAL
*    EXCEPTIONS
*      PROGRAM_ERROR = 1
*      OTHERS        = 2.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.

ENDFORM.
