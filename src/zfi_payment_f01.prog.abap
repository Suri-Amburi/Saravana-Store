*&---------------------------------------------------------------------*
*& Include          ZFlt_PAYMENT_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form VALIDATE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_data .
  IF p_qr IS NOT INITIAL.
    SELECT SINGLE * FROM zinw_t_hdr INTO gs_hdr WHERE qr_code = p_qr.
    IF gs_hdr-status = c_06.
      SELECT SINGLE * FROM rbkp INTO wa_rbkp_iv WHERE belnr = gs_hdr-invoice AND gjahr = gs_hdr-inv_gjahr.
      DATA(lv_doc) = wa_rbkp_iv-belnr && wa_rbkp_iv-gjahr.
      SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE awkey = lv_doc.
      SELECT SINGLE * FROM bsik INTO wa_bsik WHERE bukrs = wa_bkpf-bukrs AND belnr = wa_bkpf-belnr  AND gjahr = wa_bkpf-gjahr.
      IF gs_hdr-return_po IS NOT INITIAL.
        SELECT SINGLE * FROM rbkp INTO wa_rbkp_dn WHERE belnr = gs_hdr-debit_note AND gjahr = gs_hdr-inv_gjahr.
        lv_doc = wa_rbkp_dn-belnr && wa_rbkp_dn-gjahr.
        SELECT SINGLE * FROM bkpf INTO wa_bkpf_dn WHERE awkey = lv_doc.
      ENDIF.
      PERFORM fm_bapi_clear.
    ELSE.
      CASE gs_hdr-status.
        WHEN c_01 OR c_02 OR c_03 OR c_04 OR space.
          MESSAGE s046(zmsg_cls) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        WHEN c_05.
          MESSAGE s051(zmsg_cls) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        WHEN c_07.
          MESSAGE s050(zmsg_cls) DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.

FORM msg_init.
  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXCEPTIONS
      log_not_active       = 1
      wrong_identification = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.

FORM msg_stop.
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      a_message         = 1
      e_message         = 2
      w_message         = 3
      i_message         = 4
      s_message         = 5
      deactivated_by_md = 6
      OTHERS            = 7.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXCEPTIONS
      inconsistent_range = 1
      no_messages        = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.

FORM fm_bapi_clear.
********************** Local Declartion ********************************
  DATA : ls_status TYPE zinw_t_status.
  DATA : lv_mode  TYPE c VALUE 'N',
         lv_msgid LIKE sy-msgid,
         lv_msgno LIKE sy-msgno,
         lv_msgty LIKE sy-msgty,
         lv_msgv1 LIKE sy-msgv1,
         lv_msgv2 LIKE sy-msgv2,
         lv_msgv3 LIKE sy-msgv3,
         lv_msgv4 LIKE sy-msgv4,
         lv_subrc LIKE sy-subrc.

  DATA: lt_blntab  TYPE TABLE OF blntab,
        ls_blntab  TYPE blntab,
        lt_clear   TYPE TABLE OF ftclear,
        ls_clear   TYPE ftclear,
        lt_post    TYPE TABLE OF ftpost,
        ls_post    TYPE ftpost,
        lt_tax     TYPE TABLE OF fttax,
        lv_doc_dt  TYPE c LENGTH 10,
        lv_post_dt TYPE c LENGTH 10,
        lv_count   TYPE i VALUE 0,
        lv_message TYPE c LENGTH 100,
        ls_paymode TYPE zqr_t_add.

  BREAK samburi.
*** Step:1 Starting Interface
  CALL FUNCTION 'POSTING_INTERFACE_START'
    EXPORTING
      i_client           = sy-mandt
      i_function         = 'C'
      i_mode             = lv_mode
      i_update           = 'S'
    EXCEPTIONS
      client_incorrect   = 1
      function_invalid   = 2
      group_name_missing = 3
      mode_invalid       = 4
      update_invalid     = 5
      OTHERS             = 6.
  IF sy-subrc <> 0.
    MESSAGE 'Error initializing posting interface' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CLEAR  : lv_msgid, lv_msgno, lv_msgty, lv_msgv1, lv_msgv2, lv_msgv3, lv_msgv4, lv_subrc.
  CLEAR  : lv_doc_dt, lv_post_dt,  ls_clear, ls_post , lv_count .
  REFRESH : lt_post.
*** Filling Tables
*** Header Info in LT_POST Table
  ls_post-stype = 'K'.                           " Header
  ls_post-count =  lv_count + 1.

  IF wa_bkpf-bldat IS NOT INITIAL.
    lv_doc_dt =  wa_bkpf-bldat+6(2) && '.' && wa_bkpf-bldat+4(2) && '.' && wa_bkpf-bldat+0(4).
  ENDIF.
  lv_doc_dt = sy-datum+6(2) && '.' && sy-datum+4(2) && '.' && sy-datum+0(4).

  IF wa_bkpf-blart IS NOT INITIAL.
    lv_post_dt =  lv_doc_dt.
  ENDIF.

  ls_post-fnam = 'BKPF-BUKRS'.              " Company Code
  ls_post-fval = wa_bkpf-bukrs .
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-WAERS'.              " Doc Currency
  ls_post-fval = wa_bkpf-waers.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-BLART'.              " Doc Type
  ls_post-fval =  'KZ' .
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-BLDAT'.              " Doc Date
  ls_post-fval =  lv_doc_dt.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-BUDAT'.              " Posting Date
  ls_post-fval = lv_post_dt.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-XBLNR'.              " Ref Doc
  ls_post-fval = p_pmode.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-MONAT'.              " Period
  ls_post-fval = wa_bkpf-monat.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BKPF-BKTXT'.             " Payment Mode
  ls_post-fval = 'TEST'.
  APPEND ls_post TO lt_post.

*** item
  CLEAR: lv_count.
  ls_post-stype = 'P'.                      " For Item
  lv_count = lv_count + 1 .
  ls_post-count =  lv_count .

  ls_post-fnam = 'RF05A-NEWBS'.             " Post Key
  ls_post-fval = '50'.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'RF05A-NEWKO'.             " GL Account
  ls_post-fval = c_gl.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BSEG-WRBTR'.              " DC Amount
  lv_amount    = wa_rbkp_iv-rmwwr - wa_rbkp_dn-rmwwr.
  ls_post-fval = lv_amount .
  CONDENSE ls_post-fval.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'BSEG-BUPLA'.              " Business Place
  ls_post-fval = wa_bsik-bupla.
  APPEND ls_post TO lt_post.

  ls_post-fnam = 'COBL-GSBER'.              " Business Area
  ls_post-fval = wa_rbkp_iv-gsber.
  APPEND ls_post TO lt_post.

  ls_clear-agkoa = 'K'.                      " D-cust, K:v-vend
  ls_clear-agkon = wa_rbkp_iv-lifnr.         " Vendor Account
  ls_clear-agbuk = wa_bkpf-bukrs.
  ls_clear-xnops = 'X'.
  ls_clear-xfifo = space.
  ls_clear-agums = space.
  ls_clear-avsid = space.
*  ls_clear-selfd = 'XBLNR'.
*  ls_clear-selvon = wa_bkpf-xblnr.

  ls_clear-selfd = 'BELNR'.
  ls_clear-selvon = wa_bkpf-belnr.
  APPEND ls_clear TO lt_clear.
  CLEAR: ls_clear.
  IF wa_bkpf_dn IS NOT INITIAL.
    ls_clear-agkoa = 'K'.                     " D-cust, K:v-vend
    ls_clear-agkon = wa_rbkp_iv-lifnr.        " Vendor Account
    ls_clear-agbuk = wa_bkpf_dn-bukrs.
    ls_clear-xnops = 'X'.
    ls_clear-xfifo = space.
    ls_clear-agums = space.
    ls_clear-avsid = space.
    ls_clear-selfd = 'BELNR'.
    ls_clear-selvon = wa_bkpf_dn-belnr.
    APPEND ls_clear TO lt_clear.
    CLEAR: ls_clear.
  ENDIF.


**************************if Return po
*  IF GS_HDR-RETURN_PO IS NOT INITIAL.
***** Rerutn PO
*    LS_POST-FNAM = 'BKPF-BUKRS'.         ""Company Cd
*    LS_POST-FVAL = WA_BKPF-BUKRS .
*    APPEND LS_POST TO LT_POST.
*
*    LS_POST-FNAM = 'BKPF-WAERS'.          "Doc Currency
*    LS_POST-FVAL = WA_BKPF-WAERS.
*    APPEND LS_POST TO LT_POST.
*
*    LS_POST-FNAM = 'BKPF-BLART'.          "Doc Type
*    LS_POST-FVAL =  'KZ' .
*    APPEND LS_POST TO LT_POST.
*
*    LS_POST-FNAM = 'BKPF-BLDAT'.         "Doc Date
*    LS_POST-FVAL =  LV_DOC_DT.
*    APPEND LS_POST TO LT_POST.
*
*    LS_POST-FNAM = 'BKPF-BUDAT'.         "Posting Dt
*    LS_POST-FVAL = LV_POST_DT.
*    APPEND LS_POST TO LT_POST.
*
*    LS_POST-FNAM =  'BKPF-XBLNR'.        "Ref Doc
*    LS_POST-FVAL = wa_rbkp_dn-XBLNR.
*    APPEND LS_POST TO LT_POST.
*
*    LS_POST-FNAM = 'BKPF-MONAT'.                "Period
*    LS_POST-FVAL = WA_BKPF-MONAT.
*    APPEND LS_POST TO LT_POST.
*
****
*    LS_POST-STYPE = 'P'.                          " For Item
*    LV_COUNT = LV_COUNT + 1 .
*    LS_POST-COUNT =  LV_COUNT .
*
*    LS_POST-FNAM = 'RF05A-NEWBS'.                 "Post Key
**    LS_POST-FVAL = '50'.
*    LS_POST-FVAL = '38'.
*    APPEND LS_POST TO LT_POST.
*
*    LS_POST-FNAM = 'RF05A-NEWKO'.                 "GL Account
*    LS_POST-FVAL = wa_rbkp_dn-LIFNR.  "'SC0000012'.
*    APPEND LS_POST TO LT_POST.
*
*    LS_POST-FNAM = 'BSEG-WRBTR'.                  "DC Amount
*    LS_POST-FVAL =   wa_rbkp_dn-RMWWR.
*    CONDENSE LS_POST-FVAL.
*    APPEND LS_POST TO LT_POST.
*
*    LS_CLEAR-AGKOA = 'S'.                         "D-cust, K:v-vend s:G/L aCCOUNT
*    LS_CLEAR-AGKON = C_GL.                        "Vendor Account
*    LS_CLEAR-XNOPS = 'X'.
*    LS_CLEAR-XFIFO = SPACE.
*    LS_CLEAR-AGUMS = SPACE.
*    LS_CLEAR-AVSID = SPACE.
*    LS_CLEAR-SELFD = 'XBLNR'.
*    LS_CLEAR-SELVON = wa_rbkp_dn-XBLNR.
*
*    APPEND LS_CLEAR TO LT_CLEAR.
*    CLEAR: LS_CLEAR.
*  ENDIF.

  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
*     i_auglv                    = 'UMBUCHNG'
      i_auglv                    = 'AUSGZAHL'
      i_tcode                    = 'FB05'
    IMPORTING
      e_msgid                    = lv_msgid
      e_msgno                    = lv_msgno
      e_msgty                    = lv_msgty
      e_msgv1                    = lv_msgv1
      e_msgv2                    = lv_msgv2
      e_msgv3                    = lv_msgv3
      e_msgv4                    = lv_msgv4
      e_subrc                    = lv_subrc
    TABLES
      t_blntab                   = lt_blntab
      t_ftclear                  = lt_clear
      t_ftpost                   = lt_post
      t_fttax                    = lt_tax
    EXCEPTIONS
      clearing_procedure_invalid = 1
      clearing_procedure_missing = 2
      table_t041a_empty          = 3
      transaction_code_invalid   = 4
      amount_format_error        = 5
      too_many_line_items        = 6
      company_code_invalid       = 7
      screen_not_found           = 8
      no_authorization           = 9
      OTHERS                     = 10.
  CLEAR: lv_message.
  CALL FUNCTION 'FORMAT_MESSAGE'
    EXPORTING
      id        = lv_msgid
      lang      = sy-langu
      no        = lv_msgno
      v1        = lv_msgv1
      v2        = lv_msgv2
      v3        = lv_msgv3
      v4        = lv_msgv4
    IMPORTING
      msg       = lv_message
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  TRY.
      gs_hdr-acc_doc_no = lt_blntab[ 1 ]-belnr.
      gs_hdr-acc_gjahr  = lt_blntab[ 1 ]-gjahr.
    CATCH cx_sy_itab_line_not_found.
  ENDTRY.

  IF gs_hdr-acc_doc_no IS NOT INITIAL.
*** Update Header Status
    gs_hdr-status = c_07.
    ls_paymode-qr_code = p_qr.
    ls_paymode-payment_mode = p_pmode.
    MODIFY zinw_t_hdr FROM gs_hdr.
    MODIFY zqr_t_add FROM ls_paymode.
*** For Updating Status Table
    ls_status-qr_code      = gs_hdr-qr_code.
    ls_status-inwd_doc     = gs_hdr-inwd_doc.
    ls_status-status_field = c_qr_code.
    ls_status-status_value = c_qr07.
    ls_status-description  = 'Payment Posted'.
    ls_status-created_by   = sy-uname.
    ls_status-created_date = sy-datum.
    ls_status-created_time = sy-uzeit.
    MODIFY zinw_t_status FROM ls_status.
    MESSAGE s048(zmsg_cls) WITH lv_msgv1.
  ELSE.
    MESSAGE lv_message TYPE 'E'.
  ENDIF.
** Step:3 Closing Interface
  CALL FUNCTION 'POSTING_INTERFACE_END'
    EXPORTING
      i_bdcimmed              = ' '
    EXCEPTIONS
      session_not_processable = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE 'Error Ending posting interface' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
*  PERFORM FM_DISP_ALV.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FM_DISP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fm_disp_alv .
  DATA: str_rec_l_fcat TYPE slis_fieldcat_alv,
        itab_l_fcat    TYPE TABLE OF slis_fieldcat_alv.

  DATA: str_rec_l_layout TYPE slis_layout_alv.

  str_rec_l_fcat-fieldname = 'SNO'.
  str_rec_l_fcat-seltext_m = 'Sr.No.'.
  str_rec_l_fcat-seltext_s = 'Sr.No.'.
  str_rec_l_fcat-seltext_l = 'Sr.No.'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '7'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'GJAHR'.
  str_rec_l_fcat-seltext_m = 'Fiscal Year'.
  str_rec_l_fcat-seltext_s = 'Fiscal Year'.
  str_rec_l_fcat-seltext_l = 'Fiscal Year'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '10'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'LIFNR'.
  str_rec_l_fcat-seltext_m = 'Vendor No.'.
  str_rec_l_fcat-seltext_s = 'Vendor No.'.
  str_rec_l_fcat-seltext_l = 'Vendor No.'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '10'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'NAME1'.
  str_rec_l_fcat-seltext_m = 'Vendor Name'.
  str_rec_l_fcat-seltext_s = 'Vendor Name'.
  str_rec_l_fcat-seltext_l = 'Vendor Name'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '15'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'WRBTR'.
  str_rec_l_fcat-seltext_m = 'Clearing Amount'.
  str_rec_l_fcat-seltext_s = 'Clearing Amount'.
  str_rec_l_fcat-seltext_l = 'Clearing Amount'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '10'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

*  STR_REC_L_FCAT-FIELDNAME = 'C_BELNR'.
*  STR_REC_L_FCAT-SELTEXT_M = 'Doc. No.'.
*  STR_REC_L_FCAT-SELTEXT_S = 'Doc. No.'.
*  STR_REC_L_FCAT-SELTEXT_L = 'Doc. No.'.
*  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
*  STR_REC_L_FCAT-OUTPUTLEN = '10'.
*  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
*  CLEAR  STR_REC_L_FCAT.
*
*  STR_REC_L_FCAT-FIELDNAME = 'C_AUGBL'.
*  STR_REC_L_FCAT-SELTEXT_M = 'Clearing Doc.No.'.
*  STR_REC_L_FCAT-SELTEXT_S = 'Clearing Doc.No.'.
*  STR_REC_L_FCAT-SELTEXT_L = 'Clearing Doc.No.'.
*  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
*  STR_REC_L_FCAT-OUTPUTLEN = '15'.
*  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
*  CLEAR  STR_REC_L_FCAT.

**  str_rec_l_fcat-fieldname = 'C_TYPE'.
**  str_rec_l_fcat-seltext_m = 'Message Type'.
**  str_rec_l_fcat-seltext_s = 'Message Type'.
**  str_rec_l_fcat-seltext_l = 'Message Type'.
**  str_rec_l_fcat-tabname   = 'GT_ALV'.
**  str_rec_l_fcat-outputlen = '13'.
**  APPEND str_rec_l_fcat TO itab_l_fcat.
**  CLEAR  str_rec_l_fcat.

*  STR_REC_L_FCAT-FIELDNAME = 'C_MESSAGE'.
*  STR_REC_L_FCAT-SELTEXT_M = 'Message'.
*  STR_REC_L_FCAT-SELTEXT_S = 'Message'.
*  STR_REC_L_FCAT-SELTEXT_L = 'Message'.
*  STR_REC_L_FCAT-TABNAME   = 'GT_ALV'.
*  STR_REC_L_FCAT-OUTPUTLEN = '50'.
*  APPEND STR_REC_L_FCAT TO ITAB_L_FCAT.
*  CLEAR  STR_REC_L_FCAT.

  str_rec_l_fcat-fieldname = 'V_BELNR'.
  str_rec_l_fcat-seltext_m = 'Doc. No.'.
  str_rec_l_fcat-seltext_s = 'Doc. No.'.
  str_rec_l_fcat-seltext_l = 'Doc. No.'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '10'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'V_AUGBL'.
  str_rec_l_fcat-seltext_m = 'Clearing Doc.No.'.
  str_rec_l_fcat-seltext_s = 'Clearing Doc.No.'.
  str_rec_l_fcat-seltext_l = 'Clearing Doc.No.'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '15'.
  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_fcat-fieldname = 'V_MESSAGE'.
  str_rec_l_fcat-seltext_m = 'Message'.
  str_rec_l_fcat-seltext_s = 'Message'.
  str_rec_l_fcat-seltext_l = 'Message'.
  str_rec_l_fcat-tabname   = 'GT_ALV'.
  str_rec_l_fcat-outputlen = '50'.

  APPEND str_rec_l_fcat TO itab_l_fcat.
  CLEAR  str_rec_l_fcat.

  str_rec_l_layout-zebra = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout     = str_rec_l_layout
      it_fieldcat   = itab_l_fcat
    TABLES
      t_outtab      = gt_alv
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
