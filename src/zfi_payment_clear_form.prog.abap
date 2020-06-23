*&---------------------------------------------------------------------*
*& Include          ZFI_PAYMENT_CLEAR_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form VALIDATE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_DATA .
BREAK breddy.
  IF  LV_INV IS NOT INITIAL.
    SELECT SINGLE * FROM RBKP INTO WA_RBKP_IV WHERE BELNR = LV_INV.
    DATA(LV_DOC) = WA_RBKP_IV-BELNR && WA_RBKP_IV-GJAHR.
    SELECT SINGLE * FROM BKPF INTO WA_BKPF WHERE AWKEY = LV_DOC.
    SELECT SINGLE * FROM BSIK INTO WA_BSIK WHERE BUKRS = WA_BKPF-BUKRS AND BELNR = WA_BKPF-BELNR  AND GJAHR = WA_BKPF-GJAHR.
    PERFORM FM_BAPI_CLEAR .
  ENDIF.

ENDFORM.
FORM MSG_INIT.
  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXCEPTIONS
      LOG_NOT_ACTIVE       = 1
      WRONG_IDENTIFICATION = 2
      OTHERS               = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
FORM MSG_STOP.
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      A_MESSAGE         = 1
      E_MESSAGE         = 2
      W_MESSAGE         = 3
      I_MESSAGE         = 4
      S_MESSAGE         = 5
      DEACTIVATED_BY_MD = 6
      OTHERS            = 7.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXCEPTIONS
      INCONSISTENT_RANGE = 1
      NO_MESSAGES        = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FM_BAPI_CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FM_BAPI_CLEAR .

********************** Local Declartion ********************************
  DATA : LS_STATUS TYPE ZINW_T_STATUS.
  DATA : LV_MODE  TYPE C VALUE 'N',
         LV_MSGID LIKE SY-MSGID,
         LV_MSGNO LIKE SY-MSGNO,
         LV_MSGTY LIKE SY-MSGTY,
         LV_MSGV1 LIKE SY-MSGV1,
         LV_MSGV2 LIKE SY-MSGV2,
         LV_MSGV3 LIKE SY-MSGV3,
         LV_MSGV4 LIKE SY-MSGV4,
         LV_SUBRC LIKE SY-SUBRC.

  DATA: LT_BLNTAB  TYPE TABLE OF BLNTAB,
        LS_BLNTAB  TYPE BLNTAB,
        LT_CLEAR   TYPE TABLE OF FTCLEAR,
        LS_CLEAR   TYPE FTCLEAR,
        LT_POST    TYPE TABLE OF FTPOST,
        LS_POST    TYPE FTPOST,
        LT_TAX     TYPE TABLE OF FTTAX,
        LV_DOC_DT  TYPE C LENGTH 10,
        LV_POST_DT TYPE C LENGTH 10,
        LV_COUNT   TYPE I VALUE 0,
        LV_MESSAGE TYPE C LENGTH 100.

*** Step:1 Starting Interface
  CALL FUNCTION 'POSTING_INTERFACE_START'
    EXPORTING
      I_CLIENT           = SY-MANDT
      I_FUNCTION         = 'C'
      I_MODE             = LV_MODE
      I_UPDATE           = 'S'
    EXCEPTIONS
      CLIENT_INCORRECT   = 1
      FUNCTION_INVALID   = 2
      GROUP_NAME_MISSING = 3
      MODE_INVALID       = 4
      UPDATE_INVALID     = 5
      OTHERS             = 6.
  IF SY-SUBRC <> 0.
    MESSAGE 'Error initializing posting interface' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  CLEAR  : LV_MSGID, LV_MSGNO, LV_MSGTY, LV_MSGV1, LV_MSGV2, LV_MSGV3, LV_MSGV4, LV_SUBRC.
  CLEAR  : LV_DOC_DT, LV_POST_DT,  LS_CLEAR, LS_POST , LV_COUNT .

*** Filling Tables
*** Header Info in LT_POST Table

  LS_POST-STYPE = 'K'.                           " Header
  LS_POST-COUNT =  LV_COUNT + 1.

  IF WA_BKPF-BLDAT IS NOT INITIAL.
    LV_DOC_DT =  WA_BKPF-BLDAT+6(2) && '.' && WA_BKPF-BLDAT+4(2) && '.' && WA_BKPF-BLDAT+0(4).
  ENDIF.

  IF WA_BKPF-BLART IS NOT INITIAL.
    LV_POST_DT =  LV_DOC_DT.
  ENDIF.

  LS_POST-FNAM = 'BKPF-BUKRS'.         ""Company Cd
  LS_POST-FVAL = WA_BKPF-BUKRS .
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-WAERS'.          "Doc Currency
  LS_POST-FVAL = WA_BKPF-WAERS.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-BLART'.          "Doc Type
  LS_POST-FVAL =  'KZ' .
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-BLDAT'.         "Doc Date
  LS_POST-FVAL =  LV_DOC_DT.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-BUDAT'.         "Posting Dt
  LS_POST-FVAL = LV_POST_DT.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM =  'BKPF-XBLNR'.        "Ref Doc
  LS_POST-FVAL = WA_BKPF-XBLNR.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BKPF-MONAT'.                "Period
  LS_POST-FVAL = WA_BKPF-MONAT.
  APPEND LS_POST TO LT_POST.

*** item

  CLEAR: LV_COUNT.
  LS_POST-STYPE = 'P'.                          " For Item
  LV_COUNT = LV_COUNT + 1 .
  LS_POST-COUNT =  LV_COUNT .

  LS_POST-FNAM = 'RF05A-NEWBS'.                 "Post Key
  LS_POST-FVAL = '50'.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'RF05A-NEWKO'.                 "GL Account
  LS_POST-FVAL = C_GL.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BSEG-WRBTR'.                  "DC Amount
  LV_AMOUNT =    WA_RBKP_IV-RMWWR .
  LS_POST-FVAL = LV_AMOUNT .
  CONDENSE LS_POST-FVAL.
  APPEND LS_POST TO LT_POST.

  LS_POST-FNAM = 'BSEG-BUPLA'.                 "bUSINESS Place
  LS_POST-FVAL = WA_BSIK-BUPLA.
  APPEND LS_POST TO LT_POST.

  LS_CLEAR-AGKOA = 'K'.                         "D-cust, K:v-vend
  LS_CLEAR-AGKON = WA_BSIK-LIFNR.               "Vendor Account
  LS_CLEAR-AGBUK = WA_BSIK-BUKRS.
  LS_CLEAR-XNOPS = 'X'.
  LS_CLEAR-XFIFO = SPACE.
  LS_CLEAR-AGUMS = SPACE.
  LS_CLEAR-AVSID = SPACE.
  LS_CLEAR-SELFD = 'XBLNR'.
  LS_CLEAR-SELVON = WA_BKPF-XBLNR.

  APPEND LS_CLEAR TO LT_CLEAR.
  CLEAR: LS_CLEAR.

  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
      I_AUGLV                    = 'UMBUCHNG'
      I_TCODE                    = 'FB05'
    IMPORTING
      E_MSGID                    = LV_MSGID
      E_MSGNO                    = LV_MSGNO
      E_MSGTY                    = LV_MSGTY
      E_MSGV1                    = LV_MSGV1
      E_MSGV2                    = LV_MSGV2
      E_MSGV3                    = LV_MSGV3
      E_MSGV4                    = LV_MSGV4
      E_SUBRC                    = LV_SUBRC
    TABLES
      T_BLNTAB                   = LT_BLNTAB
      T_FTCLEAR                  = LT_CLEAR
      T_FTPOST                   = LT_POST
      T_FTTAX                    = LT_TAX
    EXCEPTIONS
      CLEARING_PROCEDURE_INVALID = 1
      CLEARING_PROCEDURE_MISSING = 2
      TABLE_T041A_EMPTY          = 3
      TRANSACTION_CODE_INVALID   = 4
      AMOUNT_FORMAT_ERROR        = 5
      TOO_MANY_LINE_ITEMS        = 6
      COMPANY_CODE_INVALID       = 7
      SCREEN_NOT_FOUND           = 8
      NO_AUTHORIZATION           = 9
      OTHERS                     = 10.
  CLEAR: LV_MESSAGE.

  CALL FUNCTION 'FORMAT_MESSAGE'
    EXPORTING
      ID        = LV_MSGID
      LANG      = SY-LANGU
      NO        = LV_MSGNO
      V1        = LV_MSGV1
      V2        = LV_MSGV2
      V3        = LV_MSGV3
      V4        = LV_MSGV4
    IMPORTING
      MSG       = LV_MESSAGE
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

** Step:3 Closing Interface
  CALL FUNCTION 'POSTING_INTERFACE_END'
    EXPORTING
      I_BDCIMMED              = ' '
    EXCEPTIONS
      SESSION_NOT_PROCESSABLE = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.
    MESSAGE 'Error Ending posting interface' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
BREAK BREDDY .
  IF LV_MESSAGE IS NOT INITIAL.
    CLEAR LV_COUNT .
    LV_COUNT = LV_COUNT + 1 .
    LS_ALV-SNO = LV_COUNT .
*    ls_alv-
    LS_ALV-BUKRS = WA_BSIK-BUKRS .
    LS_ALV-GJAHR = WA_BSIK-GJAHR .
    LS_ALV-LIFNR = WA_BSIK-LIFNR .
    LS_ALV-WRBTR = WA_BSIK-WRBTR .
    SELECT SINGLE NAME1 FROM LFA1 INTO  LS_ALV-NAME1 WHERE LIFNR = WA_BSIK-LIFNR .
*    ls_alv-NAME1 =
    LS_ALV-V_BELNR   =  WA_BSIK-BELNR.
    LS_ALV-V_AUGBL   =  LV_MSGV1.
    LS_ALV-V_MESSAGE = LV_MESSAGE.
*        IF lv_msgty = 'A'.
*          ls_alv-c_type  =  lv_msgty.
*          ls_alv-c_message = 'Document already cleared'.
*        ENDIF.
*        ls_alv-c_type    =  lv_msgty.

*        APPEND ls_alv TO gt_alv.
*        CLEAR: ls_alv.
  ENDIF.

  APPEND LS_ALV TO GT_ALV.
  CLEAR: LS_ALV.

  PERFORM FM_DISP_ALV.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FM_DISP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FM_DISP_ALV .
  DATA: STR_REC_L_FCAT TYPE SLIS_FIELDCAT_ALV,
        ITAB_L_FCAT    TYPE TABLE OF SLIS_FIELDCAT_ALV.

  DATA: STR_REC_L_LAYOUT TYPE SLIS_LAYOUT_ALV.

  STR_REC_L_FCAT-FIELDNAME = 'SNO'.
  STR_REC_L_FCAT-SELTEXT_M = 'Sr.No.'.
  STR_REC_L_FCAT-SELTEXT_S = 'Sr.No.'.
  STR_REC_L_FCAT-SELTEXT_L = 'Sr.No.'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '7'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

*  STR_REC_L_FCAT-FIELDNAME = 'BUKRS'.
*  STR_REC_L_FCAT-SELTEXT_M = 'Company Code'.
*  STR_REC_L_FCAT-SELTEXT_S = 'Company Code'.
*  STR_REC_L_FCAT-SELTEXT_L = 'Company Code'.
*  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
*  STR_REC_L_FCAT-OUTPUTLEN = '15'.
*  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
*  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'GJAHR'.
  STR_REC_L_FCAT-SELTEXT_M = 'Fiscal Year'.
  STR_REC_L_FCAT-SELTEXT_S = 'Fiscal Year'.
  STR_REC_L_FCAT-SELTEXT_L = 'Fiscal Year'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '10'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'LIFNR'.
  STR_REC_L_FCAT-SELTEXT_M = 'Vendor No.'.
  STR_REC_L_FCAT-SELTEXT_S = 'Vendor No.'.
  STR_REC_L_FCAT-SELTEXT_L = 'Vendor No.'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '10'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'NAME1'.
  STR_REC_L_FCAT-SELTEXT_M = 'Vendor Name'.
  STR_REC_L_FCAT-SELTEXT_S = 'Vendor Name'.
  STR_REC_L_FCAT-SELTEXT_L = 'Vendor Name'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '15'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'WRBTR'.
  STR_REC_L_FCAT-SELTEXT_M = 'Clearing Amount'.
  STR_REC_L_FCAT-SELTEXT_S = 'Clearing Amount'.
  STR_REC_L_FCAT-SELTEXT_L = 'Clearing Amount'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '10'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'V_BELNR'.
  STR_REC_L_FCAT-SELTEXT_M = 'Doc. No.'.
  STR_REC_L_FCAT-SELTEXT_S = 'Doc. No.'.
  STR_REC_L_FCAT-SELTEXT_L = 'Doc. No.'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '10'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'V_AUGBL'.
  STR_REC_L_FCAT-SELTEXT_M = 'Clearing Doc.No.'.
  STR_REC_L_FCAT-SELTEXT_S = 'Clearing Doc.No.'.
  STR_REC_L_FCAT-SELTEXT_L = 'Clearing Doc.No.'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '15'.
  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_FCAT-FIELDNAME = 'V_MESSAGE'.
  STR_REC_L_FCAT-SELTEXT_M = 'Message'.
  STR_REC_L_FCAT-SELTEXT_S = 'Message'.
  STR_REC_L_FCAT-SELTEXT_L = 'Message'.
  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
  STR_REC_L_FCAT-OUTPUTLEN = '50'.

  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
  CLEAR  STR_REC_L_FCAT.

  STR_REC_L_LAYOUT-ZEBRA = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IS_LAYOUT     = STR_REC_L_LAYOUT
      IT_FIELDCAT   = ITAB_L_FCAT
    TABLES
      T_OUTTAB      = GT_ALV
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
