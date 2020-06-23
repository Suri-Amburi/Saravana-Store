*&---------------------------------------------------------------------*
*& Include          ZMM_GRPO_PRO_DET_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GETDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM getdata .
***  BREAK BREDDY.
***  SELECT
***  ZINW_T_HDR~REC_DATE ,
***  ZINW_T_HDR~LIFNR,
***  ZINW_T_HDR~LR_NO,
***  ZINW_T_HDR~ACT_NO_BUD,
***  ZINW_T_HDR~TRNS,
***  ZINW_T_HDR~NAME1,
***  ZINW_T_HDR~BILL_NUM,
***  ZINW_T_HDR~BILL_DATE,
***  ZINW_T_HDR~NET_AMT,
***  ZINW_T_HDR~LR_DATE ,
***  ZINW_T_HDR~MBLNR,
***  ZINW_T_HDR~TOTAL,
***  ZINW_T_HDR~PUR_TOTAL,
***  ZINW_T_HDR~QR_CODE ,
***  ADRC~CITY1,
***  MKPF~BUDAT INTO TABLE @GT_DATA
***  FROM ZINW_T_HDR AS ZINW_T_HDR
***  INNER JOIN LFA1 AS LFA1 ON ZINW_T_HDR~LIFNR = LFA1~LIFNR
***  INNER JOIN ADRC AS ADRC ON LFA1~ADRNR = ADRC~ADDRNUMBER
***  INNER JOIN MKPF AS MKPF ON ZINW_T_HDR~MBLNR = MKPF~MBLNR
****  LEFT OUTER JOIN ZINW_T_STATUS AS ZINW_T_STATUS ON ZINW_T_HDR~QR_CODE = ZINW_T_STATUS~QR_CODE  "WHERE ZINW_T_STATUS~STATUS_VALUE = 'QR02'
***  WHERE ZINW_T_HDR~MBLNR IN @S_MBLNR
***  AND MKPF~BUDAT IN  @S_DATE .
***  IF GT_DATA IS NOT INITIAL .
***    SELECT
***      QR_CODE ,
***      CREATED_DATE ,
***      STATUS_VALUE   FROM ZINW_T_STATUS INTO TABLE @DATA(IT_ZINW_T_STATUS)
***                   FOR ALL ENTRIES IN @GT_DATA
***                   WHERE QR_CODE  = @GT_DATA-QR_CODE
***                   AND STATUS_VALUE = 'QR02' .
***
***  ENDIF .

  DATA(lv_select) = cl_shdb_seltab=>combine_seltabs(
   it_named_seltabs = VALUE #( ( name = 'MBLNR' dref = REF #( s_mblnr[] ) )
                               )

                               iv_client_field = 'MANDT'
                                ) .

  DATA(lv_select1) = cl_shdb_seltab=>combine_seltabs(
  it_named_seltabs = VALUE #( ( name = 'BUDAT' dref = REF #( s_date[] ) )
                            )
                              iv_client_field = 'MANDT'
                             ).

  zcl_zgr_p=>get_output_prd(
  EXPORTING
*    lv_date       = s_date-high
    lv_select     = lv_select
    lv_select1     = lv_select1
   IMPORTING
    et_final_data = it_final1
   ).

  DATA : sl_no(3) TYPE i VALUE 0.
  LOOP AT it_final1 ASSIGNING FIELD-SYMBOL(<ls_data>).

    sl_no = sl_no + 1 .
    wa_final-sl_no = sl_no .
    wa_final-rec_date     = <ls_data>-rec_date .
    wa_final-lifnr         = <ls_data>-lifnr .
    wa_final-lr_no         = <ls_data>-lr_no .
    wa_final-act_no_bud    = <ls_data>-act_no_bud .
    wa_final-trns          = <ls_data>-trns .
    wa_final-name1         = <ls_data>-name1 .
    wa_final-bill_num      = <ls_data>-bill_num .
    wa_final-bill_date     = <ls_data>-bill_date .
    wa_final-net_amt       = <ls_data>-net_amt .
    wa_final-lr_date       = <ls_data>-lr_date .
    wa_final-mblnr         = <ls_data>-mblnr .
    wa_final-city1         = <ls_data>-city1 .
    wa_final-created_date  = <ls_data>-created_date .
    wa_final-budat         = <ls_data>-budat .
    wa_final-lv_gr_pr  = <ls_data>-total - <ls_data>-pur_total .
    wa_final-lv_pr_per = ( <ls_data>-total - <ls_data>-pur_total ) / <ls_data>-pur_total * 100.
    wa_final-net_pr    = <ls_data>-total - <ls_data>-net_amt .
    wa_final-net_per   = ( <ls_data>-total - <ls_data>-net_amt ) / <ls_data>-net_amt * 100.
    APPEND wa_final TO it_final.
    CLEAR : wa_final .


  ENDLOOP.

*******  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
*******    sl_no = sl_no + 1 .
*******    wa_final-sl_no = sl_no .
*******    wa_final-rec_date     = <ls_data>-rec_date .
*******    wa_final-lifnr         = <ls_data>-lifnr .
*******    wa_final-lr_no         = <ls_data>-lr_no .
*******    wa_final-act_no_bud    = <ls_data>-act_no_bud .
*******    wa_final-trns          = <ls_data>-trns .
*******    wa_final-name1         = <ls_data>-name1 .
*******    wa_final-bill_num      = <ls_data>-bill_num .
*******    wa_final-bill_date     = <ls_data>-bill_date .
*******    wa_final-net_amt       = <ls_data>-net_amt .
*******    wa_final-lr_date       = <ls_data>-lr_date .
*******    wa_final-mblnr         = <ls_data>-mblnr .
*******    wa_final-city1         = <ls_data>-city1 .
*******    BY PRIYANKA
*******    READ TABLE it_zinw_t_status ASSIGNING FIELD-SYMBOL(<ls_date>)
*******                                WITH KEY qr_code = <ls_data>-qr_code
*******                                         status_value = 'QR02'.
*******    IF sy-subrc = 0.
*******      wa_final-created_date  = <ls_date>-created_date .
*******    ENDIF.
*******    wa_final-budat         = <ls_data>-budat .
*******
*******    wa_final-lv_gr_pr  = <ls_data>-total - <ls_data>-pur_total .
*******    wa_final-lv_pr_per = ( <ls_data>-total - <ls_data>-pur_total ) / <ls_data>-pur_total * 100.
*******    wa_final-net_pr    = <ls_data>-total - <ls_data>-net_amt .
*******    wa_final-net_per   = ( <ls_data>-total - <ls_data>-net_amt ) / <ls_data>-net_amt * 100.
*******    APPEND wa_final TO it_final.
*******    CLEAR : wa_final .
*******
*******  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .

  DATA : wa_layout   TYPE slis_layout_alv.


  DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
        wa_fieldcat TYPE slis_fieldcat_alv.

  DATA: it_sort TYPE slis_t_sortinfo_alv,
        wa_sort TYPE slis_sortinfo_alv.

  wa_fieldcat-fieldname = 'SL_NO'.
  wa_fieldcat-seltext_l =  'Serial No'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'REC_DATE'.
  wa_fieldcat-seltext_l =  'Bill Recieved'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-seltext_l =  'Vendor'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'LR_NO'.
  wa_fieldcat-seltext_l =  'LR No'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'ACT_NO_BUD'.
  wa_fieldcat-seltext_l =  'Bundle'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'TRNS'.
  wa_fieldcat-seltext_l =  'Transporter'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_l =  'Vendor Name'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'BILL_NUM'.
  wa_fieldcat-seltext_l =  'Bill No'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'BILL_DATE'.
  wa_fieldcat-seltext_l =  'Bill Date'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'NET_AMT'.
  wa_fieldcat-seltext_l =  'Net Amount'.
  wa_fieldcat-do_sum =  'X'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'CITY1'.
  wa_fieldcat-seltext_l =  'Area'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'CREATED_DATE'.
  wa_fieldcat-seltext_l =  'Bundle Recieved Date'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'MBLNR'.
  wa_fieldcat-seltext_l =  'GRPO No'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'BUDAT'.
  wa_fieldcat-seltext_l =  'GRPO Date'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'LR_DATE'.
  wa_fieldcat-seltext_l =  'Transporter Date'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'LV_GR_PR'.
  wa_fieldcat-seltext_l =  'Gross Profit(Value)'.
  wa_fieldcat-do_sum =  'X'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'LV_PR_PER'.
  wa_fieldcat-seltext_l =  'Gross Profit(%)'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'NET_PR'.
  wa_fieldcat-seltext_l =  'Net Profit(Value)'.
  wa_fieldcat-do_sum =  'X'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'NET_PER'.
  wa_fieldcat-seltext_l =  'Net Profit(%)'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .


  wa_layout-zebra = 'X'.
  wa_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active    = ' '
      i_callback_program = ' '
      is_layout          = wa_layout
      it_fieldcat        = it_fieldcat
*     IT_SORT            = IT_SORT
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
*     I_SAVE             = 'A'
    TABLES
      t_outtab           = it_final
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.



ENDFORM.
