*&---------------------------------------------------------------------*
*& Include          ZPHOTO_PO_APP_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HDR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM hdr_data .

*  PERFORM HDR_DATA .
*  refresh : ls_hdr.
   CLEAR : zph_t_hdr ,it_hdr, it_lfa1.
  SELECT
    vendor
    pgroup
    pur_group
    indent_no
    pdate
    sup_sal_no
    sup_name
    vendor_name
    transporter
    vendor_location
    delivery_at
    lead_time
    e_msg
    s_msg
    freight_charges   " Added by Suri : 26.03.2020
    FROM zph_t_hdr INTO TABLE it_hdr
          WHERE pdate IN s_date .

********************            added on (3-3-20)         ****************************

  SELECT zph_t_hdr~vendor
             FROM zph_t_hdr INTO TABLE @DATA(it_lfa2) FOR ALL ENTRIES IN @it_hdr
                  WHERE e_msg = 'Vendor is not exist' AND indent_no = @it_hdr-indent_no.
*  DESCRIBE TABLE IT_lfa2 LINES DATA(LV_LINES).
*CLEAR : IT_LFA1.
  SELECT lifnr
        zztemp_vendor
        regio FROM lfa1 INTO TABLE it_lfa1
        FOR ALL ENTRIES IN it_lfa2
        WHERE zztemp_vendor = it_lfa2-vendor.
*       READ TABLE IT_LFA1 INTO WA_LFA1 INDEX 1.."LV_LINES.

*********************************    end on (3-3-20)      ****************************************

  IF it_hdr IS NOT INITIAL .
    SELECT
      ekko~zindent FROM ekko INTO TABLE @DATA(it_ekko)
              FOR ALL ENTRIES IN @it_hdr
             WHERE zindent = @it_hdr-indent_no.

    SELECT
      zph_t_item~e_msg ,
      zph_t_item~indent_no ,
      zph_t_item~s_msg FROM zph_t_item INTO TABLE @DATA(lt_msgs)
                       FOR ALL ENTRIES IN @it_hdr
                       WHERE indent_no  = @it_hdr-indent_no .

  ENDIF .



  LOOP AT it_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr>).

*********************    added on (3-3-20)     ****************
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <ls_hdr>-vendor+0(10)
        IMPORTING
          output = <ls_hdr>-vendor+0(10).
    ENDIF.
*IF WA_LFA1-ZZTEMP_VENDOR IS NOT INITIAL .
*      WA_FINAL-VENDOR      = WA_LFA1-LIFNR.
**      WA_FINAL-VENDOR      = WA_LFA1-ZZTEMP_VENDOR.
*    ELSE.
*
*      WA_FINAL-VENDOR      = <LS_HDR>-VENDOR.     " commented by likhitha
*    ENDIF.

    READ TABLE it_lfa1 INTO wa_lfa1 WITH KEY zztemp_vendor = <ls_hdr>-vendor.
    IF sy-subrc EQ 0.
      wa_final-vendor      = wa_lfa1-lifnr.
    ELSE.
      wa_final-vendor      = <ls_hdr>-vendor.
    ENDIF.
    CLEAR : wa_lfa1.
************       enf(3-3-20),,   ****************

*    wa_final-vendor               = <ls_hdr>-vendor .                       " commented on (3-3-20)
    wa_final-pgroup               = <ls_hdr>-pgroup .
    wa_final-pur_group            = <ls_hdr>-pur_group .
    wa_final-indent_no            = <ls_hdr>-indent_no .
    wa_final-pdate                = <ls_hdr>-pdate .
    wa_final-sup_sal_no           = <ls_hdr>-sup_sal_no .
    wa_final-sup_name             = <ls_hdr>-sup_name .
    wa_final-vendor_name          = <ls_hdr>-vendor_name .
    wa_final-transporter          = <ls_hdr>-transporter .
    wa_final-vendor_location      = <ls_hdr>-vendor_location .
    wa_final-delivery_at          = <ls_hdr>-delivery_at .
    wa_final-lead_time            = <ls_hdr>-lead_time .
    wa_final-e_msg                = <ls_hdr>-e_msg .
    wa_final-s_msg                = <ls_hdr>-s_msg .
    wa_final-freight_charges      = <ls_hdr>-freight_charges .  " Added by Suri : 26.03.2020
*   ENDIF .                                               " added on(3-3-20)

    READ TABLE lt_msgs ASSIGNING FIELD-SYMBOL(<ls_msgs>) WITH KEY indent_no = <ls_hdr>-indent_no .

    IF sy-subrc = 0.
      IF wa_final-e_msg IS INITIAL .
        IF <ls_msgs>-e_msg IS NOT INITIAL .
          wa_final-e_msg  = 'Item data have Errors' .
        ENDIF .
      ENDIF .
      IF  wa_final-e_msg IS NOT INITIAL OR <ls_msgs>-e_msg IS NOT INITIAL .
        wa_cellcolor-fname = 'E_MSG' .
        wa_cellcolor-color-col = 6. "color code 1-7, if outside rage defaults to 7
        wa_cellcolor-color-int = '1'. "1 = Intensified on, 0 = Intensified off
        wa_cellcolor-color-inv = '0'. "1 = text colour, 0 = background colour
        APPEND wa_cellcolor TO wa_final-cellcolors.
        CLEAR wa_cellcolor.

      ELSEIF wa_final-s_msg IS NOT INITIAL .
        wa_cellcolor-fname = 'S_MSG' .
        wa_cellcolor-color-col = 5. "color code 1-7, if outside rage defaults to 7
        wa_cellcolor-color-int = '1'. "1 = Intensified on, 0 = Intensified off
        wa_cellcolor-color-inv = '0'. "1 = text colour, 0 = background colour
        APPEND wa_cellcolor TO wa_final-cellcolors.
        CLEAR wa_cellcolor.
      ENDIF.
    ENDIF.
    IF it_final IS INITIAL .

      READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<es_ekko>) WITH KEY zindent = <ls_hdr>-indent_no .
      IF sy-subrc NE 0 .
        APPEND wa_final TO it_final.
      ENDIF .
      CLEAR : wa_final .

    ELSE .

      READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<ls_ekko>) WITH KEY zindent = <ls_hdr>-indent_no .
      IF sy-subrc NE 0 .
        APPEND wa_final TO it_final.
      ENDIF .
      CLEAR : wa_final .

    ENDIF .
  ENDLOOP.

  PERFORM display .

ENDFORM .
FORM gui_stat USING rt_extab TYPE slis_t_extab .

*  SET PF-STATUS 'ZSTATUS' EXCLUDING RT_EXTAB .
  SET PF-STATUS 'ZSTANDARD' EXCLUDING rt_extab .
***  SET TITLEBAR TEXT-001 .

ENDFORM.
FORM user_command_scr2 USING  r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.

  IF lv_ebeln IS NOT INITIAL .
    SELECT
      ekko~ebeln ,
    ekko~zindent FROM ekko INTO TABLE @DATA(it_ekko1)
           WHERE ebeln = @lv_ebeln.
  ENDIF .


  CASE   r_ucomm .
    WHEN '&IC1'.
      FIELD-SYMBOLS : <ls_final> LIKE LINE OF it_final.
      READ TABLE it_final ASSIGNING <ls_final> INDEX rs_selfield-tabindex.
      IF sy-subrc = 0.
        PERFORM call_screen2 USING  <ls_final>-indent_no  .
      ENDIF.
    WHEN 'REFRESH' .
      REFRESH : it_final , it_hdr  .

      SELECT
     vendor
     pgroup
     pur_group
     indent_no
     pdate
     sup_sal_no
     sup_name
     vendor_name
     transporter
     vendor_location
     delivery_at
     lead_time
     e_msg
     s_msg
      freight_charges                 " Added by Suri : 26.03.2020
          FROM zph_t_hdr INTO TABLE it_hdr
           WHERE pdate IN s_date .

      IF it_hdr IS NOT INITIAL .
        SELECT
          ekko~zindent FROM ekko INTO TABLE @DATA(it_ekko)
                  FOR ALL ENTRIES IN @it_hdr
                 WHERE zindent = @it_hdr-indent_no.

        SELECT
          zph_t_item~e_msg ,
          zph_t_item~indent_no ,
          zph_t_item~s_msg FROM zph_t_item INTO TABLE @DATA(lt_msgs)
                           FOR ALL ENTRIES IN @it_hdr
                           WHERE indent_no  = @it_hdr-indent_no .

      ENDIF .
      LOOP AT it_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr>).
        wa_final-vendor               = <ls_hdr>-vendor+0(10).    " o(10) added on(3-3-20)

*        wa_final-vendor               = <ls_hdr>-vendor .      " commented on (3-3-20)
        wa_final-pgroup               = <ls_hdr>-pgroup .
        wa_final-pur_group            = <ls_hdr>-pur_group .
        wa_final-indent_no            = <ls_hdr>-indent_no .
        wa_final-pdate                = <ls_hdr>-pdate .
        wa_final-sup_sal_no           = <ls_hdr>-sup_sal_no .
        wa_final-sup_name             = <ls_hdr>-sup_name .
        wa_final-vendor_name          = <ls_hdr>-vendor_name .
        wa_final-transporter          = <ls_hdr>-transporter .
        wa_final-vendor_location      = <ls_hdr>-vendor_location .
        wa_final-delivery_at          = <ls_hdr>-delivery_at .
        wa_final-lead_time            = <ls_hdr>-lead_time .
        wa_final-e_msg                = <ls_hdr>-e_msg .
        wa_final-s_msg                = <ls_hdr>-s_msg .
        wa_final-freight_charges      = <ls_hdr>-freight_charges .  " Added by Suri : 26.03.2020
        READ TABLE lt_msgs ASSIGNING FIELD-SYMBOL(<ls_msgs>) WITH KEY indent_no = <ls_hdr>-indent_no .

        IF sy-subrc = 0.
          IF wa_final-e_msg IS INITIAL .
            IF <ls_msgs>-e_msg IS NOT INITIAL .
              wa_final-e_msg  = 'Item data have Errors' .
            ENDIF .
          ENDIF .
          IF  wa_final-e_msg IS NOT INITIAL OR <ls_msgs>-e_msg IS NOT INITIAL .
            wa_cellcolor-fname = 'E_MSG' .
            wa_cellcolor-color-col = 6. "color code 1-7, if outside rage defaults to 7
            wa_cellcolor-color-int = '1'. "1 = Intensified on, 0 = Intensified off
            wa_cellcolor-color-inv = '0'. "1 = text colour, 0 = background colour
            APPEND wa_cellcolor TO wa_final-cellcolors.
            CLEAR wa_cellcolor.

          ELSEIF wa_final-s_msg IS NOT INITIAL .
            wa_cellcolor-fname = 'S_MSG' .
            wa_cellcolor-color-col = 5. "color code 1-7, if outside rage defaults to 7
            wa_cellcolor-color-int = '1'. "1 = Intensified on, 0 = Intensified off
            wa_cellcolor-color-inv = '0'. "1 = text colour, 0 = background colour
            APPEND wa_cellcolor TO wa_final-cellcolors.
            CLEAR wa_cellcolor.
          ENDIF.
        ENDIF.
        IF it_final IS INITIAL .

          READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<es_ekko>) WITH KEY zindent = <ls_hdr>-indent_no .
          IF sy-subrc NE 0 .
            APPEND wa_final TO it_final.
          ENDIF .
          CLEAR : wa_final .

        ELSE .

          READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<ls_ekko>) WITH KEY zindent = <ls_hdr>-indent_no .
          IF sy-subrc NE 0 .
            APPEND wa_final TO it_final.
          ENDIF .
          CLEAR : wa_final .

        ENDIF .
      ENDLOOP.

      PERFORM display .

*
*      READ TABLE IT_EKKO1 ASSIGNING FIELD-SYMBOL(<LS_EKKO>) WITH KEY EBELN = LV_EBELN.
*      IF SY-SUBRC = 0.
*        DELETE IT_FINAL WHERE INDENT_NO = <LS_EKKO>-ZINDENT .
*      ENDIF.
*      RS_SELFIELD-REFRESH = 'X'.

    WHEN 'BACK_B'OR 'EXIT_C' OR 'CANCEL_C'.
      PERFORM : clear_data.
      LEAVE PROGRAM .
  ENDCASE .


ENDFORM .
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_FINAL>_VENDOR
*&---------------------------------------------------------------------*
FORM call_screen2  USING    p_indent.
  CLEAR : lv_ebeln .
*  BREAK BREDDY .
  CLEAR : wa_final1 .
  REFRESH : it_final1.
  it_final1 = it_final.
*  CASE SY-UCOMM.
*    WHEN '&IC1'.
*      READ TABLE IT_FINAL1 ASSIGNING FIELD-SYMBOL(<LS_FINAL1>) INDEX RS_SELFIELD-TABINDEX.
  DELETE it_final1 WHERE indent_no <> p_indent .
*  ENDCASE.

  SELECT
    indent_no
    vendor
    pgroup
    item
    category_code
    style
    from_size
    to_size
    color
    quantity
    price
    remarks
    e_msg
    s_msg
    ztext100
    discount2
    discount3
    FROM zph_t_item INTO TABLE it_item
          FOR ALL ENTRIES IN it_final1
          WHERE indent_no = it_final1-indent_no
          AND   pgroup = it_final1-pgroup .
*          AND   INDENT_NO NE ' '.

  SELECT
    mara~matnr FROM mara INTO TABLE @DATA(it_mara)
               FOR ALL ENTRIES IN @it_item
               WHERE matkl = @it_item-category_code .

  LOOP AT it_item ASSIGNING FIELD-SYMBOL(<ls_item>).

****************    added on (3-3-20)   ***************
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <ls_item>-vendor+0(10)
        IMPORTING
          output = <ls_item>-vendor+0(10).
    ENDIF.
*****************    end (3-3-20)     ***************

    wa_final2-item = <ls_item>-item.  "sy-tabix * 10. *--> Change of index to actual line item -> sjena <- 15.02.2020 13:25:13
****************    added on (3-3-20)    **************************
    IF wa_lfa1-zztemp_vendor IS NOT INITIAL .
      wa_final2-vendor      = wa_lfa1-lifnr.   " COMMENTED ON (12-3-20)
*      WA_FINAL2-VENDOR      = WA_LFA1-ZZTEMP_VENDOR .
    ELSE.
      wa_final2-vendor        = <ls_item>-vendor .
    ENDIF.

*************    end (3-3-20)   ********************
***    wa_final2-vendor = <ls_item>-vendor .              " commented on (3-3-20)
    wa_final2-indent_no = <ls_item>-indent_no .
    wa_final2-pgroup = <ls_item>-pgroup.
    wa_final2-category_code = <ls_item>-category_code.
    wa_final2-style = <ls_item>-style.
    wa_final2-to_size = <ls_item>-to_size.
    wa_final2-from_size = <ls_item>-from_size .
    wa_final2-color = <ls_item>-color.
    wa_final2-quantity = <ls_item>-quantity.
    wa_final2-price = <ls_item>-price.
    wa_final2-remarks = <ls_item>-remarks.
    wa_final2-e_msg = <ls_item>-e_msg.
    wa_final2-s_msg = <ls_item>-s_msg.
    wa_final2-ztext100 = <ls_item>-ztext100.
    lv_vendor = <ls_item>-vendor.

    wa_final2-discount2 = <ls_item>-discount2.
    wa_final2-discount3 = <ls_item>-discount3.

    APPEND wa_final2 TO it_final2 .
    CLEAR : wa_final2 .
  ENDLOOP.


  CALL SCREEN 9000.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'ZGUI_9000'.
  SET TITLEBAR 'TITLE'.
  CLEAR :gv_subrc.

  IF container IS NOT BOUND.
    CREATE OBJECT container
      EXPORTING
        container_name = 'MYCONTAINER'.
    CREATE OBJECT grid
      EXPORTING
        i_parent = container.
    PERFORM exclude_tb_functions CHANGING gt_exclude.
    PERFORM prepare_fcat.
    PERFORM display_data_scr3.
  ELSE.

    IF it_final1 IS NOT INITIAL.
      IF grid IS BOUND.
        DATA: is_stable TYPE lvc_s_stbl, lv_lines TYPE int2.
        is_stable = 'XX'.
        IF grid IS BOUND.
          CALL METHOD grid->refresh_table_display
            EXPORTING
              is_stable = is_stable               " With Stable Rows/Columns
            EXCEPTIONS
              finished  = 1                       " Display was Ended (by Export)
              OTHERS    = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.
*  BREAK BREDDY .



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
*  DATA(OK_CODE) = OK_9003.
*  CLEAR :OK_9003.

*  BREAK BREDDY.

  DATA : lv_indent TYPE zindent .
  DATA :    c_save   TYPE syucomm  VALUE 'SAVE'.
  CLEAR: lv_indent .
  IF lv_ebeln IS NOT INITIAL .
    SELECT SINGLE
      ekko~zindent FROM ekko INTO  lv_indent
                   WHERE ebeln = lv_ebeln .
  ENDIF .

  CASE ok_code.
    WHEN c_back OR c_cancel OR c_exit.
      PERFORM : clear_data.
      DELETE it_final WHERE indent_no = lv_indent .
      PERFORM display .

      LEAVE TO SCREEN 0.
    WHEN c_save.
      DATA : header  LIKE bapimepoheader,
             headerx LIKE bapimepoheaderx.
      DATA : item                TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
             poschedule          TYPE TABLE OF bapimeposchedule WITH HEADER LINE,
             poschedulex         TYPE TABLE OF bapimeposchedulx WITH HEADER LINE,
             itemx               TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
             wa_itemx            TYPE bapimepoitemx,
             it_return           TYPE TABLE OF bapiret2,
             it_errorcat         TYPE TABLE OF slis_t_fieldcat_alv,
             wa_errorcat         TYPE  slis_t_fieldcat_alv,
             wa_return           TYPE  bapiret2,
             poservicestext      TYPE TABLE OF bapieslltx,
             potextitem          TYPE TABLE OF bapimepotext,
             wa_poservicestext   TYPE bapieslltx,
             wa_potextitem       TYPE bapimepotext,
             wa_no_price_from_po TYPE bapiflag-bapiflag,
             wa_poaccount        TYPE bapimepoaccount,
             it_poaccount        TYPE TABLE OF bapimepoaccount,
             wa_poaccountx       TYPE bapimepoaccountx,
             it_poaccountx       TYPE TABLE OF bapimepoaccountx.


      DATA : lv_tebeln(40) TYPE c.
      DATA : lv_tex(20) TYPE c.
      DATA : lv_error(50)  TYPE c,
             lv_error1(50) TYPE c.
      DATA : wa_po_item TYPE zph_t_item,
             wa_item    TYPE bapimepoitem,
             wa_theader TYPE thead,
*         IT_LFA1    TYPE TABLE OF TY_LFA1,
*         WA_LFA1    TYPE TY_LFA1,
             wa_t500w   TYPE t500w.
*         WA_T001W   TYPE TY_T001W,
*         IT_A792    TYPE TABLE OF TY_A792,
*         WA_A792    TYPE TY_A792.

      DATA : wa_lines TYPE  tline,
             lines    TYPE TABLE OF tline,
             lv_text  TYPE tdobname,
             lv_matnr TYPE char40.
      DATA : lv_amnt TYPE bapicurext.
      DATA : ibapicondx TYPE TABLE OF bapimepocondx WITH HEADER LINE.
      DATA : ibapicond TYPE TABLE OF bapimepocond WITH HEADER LINE.
      DATA : im_header TYPE  ty_final.
      DATA : im_header_tt TYPE TABLE OF  zph_t_hdr,
*      DATA : LV_POITEM TYPE EBELP,
             lv_ername    TYPE ernam.
      DATA : lv_size1 TYPE p DECIMALS 0 .
      DATA : a(13) TYPE c,
             b(13) TYPE c,
             c(13) TYPE c.

      DATA : lv_doc TYPE esart .
      DATA : lv_mwsk1 .
      DATA:
        bapi_te_poitem  TYPE bapi_te_mepoitem,
        bapi_te_poitemx TYPE bapi_te_mepoitemx.
      DATA : lv_frm_size TYPE zsize_val-zsize,
             wa_s_size   TYPE zsize_val-zsize.
      DATA : lv_to_size TYPE zsize_val-zsize .
      DATA : pocond     TYPE TABLE OF bapimepocond WITH HEADER LINE,
             wa_pocond  TYPE bapimepocond,
             pocondx    TYPE TABLE OF bapimepocondx WITH HEADER LINE,
             wa_pocondx TYPE  bapimepocondx,
             pocondhdr  TYPE TABLE OF bapimepocondheader,
             pocondhdrx TYPE TABLE OF bapimepocondheaderx.

      CONSTANTS : c_zds1(4)            VALUE 'ZDS1',
                  c_zds2(4)            VALUE 'ZDS2',
                  c_zds3(4)            VALUE 'ZDS3',
                  c_zfrb(4)            VALUE 'ZFRB',
                  c_zzgroup_margin(14) VALUE 'ZZGROUP_MARGIN'.
      REFRESH: item[] ,    itemx[] , pocond[] ,pocondx[] ,extensionin[] , potextitem[].
*      BREAK BREDDY .
      it_fin[] = it_final1[] .
*      DELETE IT_FIN WHERE VENDOR = LV_INDENT .

      READ  TABLE it_fin INTO im_header INDEX 1.
      it_final3[] = it_final2[] .

********************************ADDED BY SKN ON 15.03.2020**********************************************
      IF im_header-pur_group IS NOT INITIAL AND im_header-pur_group = 'P34'.
        SELECT SINGLE eknam FROM t024 INTO @DATA(lv_eknam) WHERE ekgrp = 'P34'.
        IF lv_eknam IS NOT INITIAL.
          SELECT SINGLE gl_account,costcenter FROM zgl_acc_t INTO @DATA(wa_data)
                                         WHERE   wwgha = @lv_eknam
                                         AND     werks = @im_header-delivery_at.
        ENDIF.
      ENDIF.
*******************************************************************************
*** Start Of Changes by Suri : For Group/ Vendor level Discount : 23.03.2020 : 11.11.00

** Get Groupwise Discount
      SELECT SINGLE low
        INTO @DATA(lv_group_margin)
        FROM tvarvc WHERE name = @c_zzgroup_margin AND low = @im_header-pgroup AND sign = 'I'.
      IF sy-subrc IS INITIAL.
        SELECT SINGLE kbetr
                      FROM konp
                      INNER JOIN a924 ON konp~knumh = a924~knumh INTO @DATA(lv_discount)
                      WHERE a924~lifnr = @im_header-vendor AND a924~userf1_txt = @im_header-pgroup
                      AND   a924~kschl = @c_zds1 AND datab LE @sy-datum AND datbi GE @sy-datum AND loevm_ko = @space.
      ENDIF.
*** End Of Changes by Suri : For Group/ Vendor level Discount : 23.03.2020 : 11.11.00
*      BREAK BREDDY .
      CLEAR  : wa_ekko .
      READ TABLE it_final2 ASSIGNING FIELD-SYMBOL(<s_final2>) INDEX 1 .
      IF sy-subrc = 0 .
        SELECT SINGLE
          zindent
*          USER_NAME
           FROM ekko INTO wa_ekko
                     WHERE   zindent =  <s_final2>-indent_no .

      ENDIF .
**********************************       ADDED BY LIKHITHA  ***********************
*      *******************************************
*      IF LV_EBELN IS INITIAL .
      IF wa_ekko-zindent IS INITIAL.
*        SHIFT <S_FINAL2>-FROM_SIZE LEFT DELETING LEADING '0' .
*        SHIFT <S_FINAL2>-TO_SIZE LEFT DELETING LEADING '0' .
**
*        LV_FRM_SIZE = <S_FINAL2>-FROM_SIZE .
*        LV_TO_SIZE = <S_FINAL2>-TO_SIZE .
**        DATA(LV_SIZE) = <S_FINAL2>-TO_SIZE - <S_FINAL2>-FROM_SIZE .
**        LV_SIZE1 = LV_SIZE .
**        LV_SIZE = LV_SIZE + 1 .
**        DO LV_SIZE TIMES.
*        LOOP AT S_SIZE.
*          CONDENSE LV_FRM_SIZE .
*          S_SIZE-LOW = LV_FRM_SIZE .
*          S_SIZE-HIGH = LV_TO_SIZE .
**          ADD 1 TO LV_FRM_SIZE .
*          S_SIZE-SIGN = 'I' .
*          S_SIZE-OPTION = 'EQ' .
*          CONDENSE S_SIZE .
*          APPEND S_SIZE .
*          CLEAR S_SIZE  .
*        ENDLOOP .
**        ENDDO .



        SELECT
          mara~matkl ,
          mara~brand_id FROM mara INTO TABLE @DATA(it_brand)
                   FOR ALL ENTRIES IN @it_final3
                   WHERE matkl = @it_final3-category_code AND brand_id NE ' '.


*        BREAK BREDDY .
        IF  it_final3 IS NOT INITIAL.
*****FOR ITEM DATA*******
***   Start of Changes By Suri : 25.11.2019
***   For Custom logic for Size
          TYPES :
            BEGIN OF ty_cat_size,
              item  TYPE ebelp,
              matkl TYPE mara-matkl,
              size  TYPE mara-size1,
            END OF ty_cat_size.
          DATA : lt_cat_size TYPE STANDARD TABLE OF ty_cat_size,
                 r_range     TYPE RANGE OF wrf_atwrt.
          SELECT * FROM zsize_val INTO TABLE @DATA(lt_size).
          SORT  lt_size BY zitem.
          REFRESH : lt_cat_size, r_range.
          LOOP AT it_final3 ASSIGNING FIELD-SYMBOL(<ls_final3>).
            DATA(lv_item) = <ls_final3>-item.   " 21.2.2020 ITEM ISSUE
            IF <ls_final3>-from_size IS NOT INITIAL.
*              DATA(lv_item) = sy-tabix * 10.

              READ TABLE lt_size WITH KEY zsize = <ls_final3>-from_size TRANSPORTING NO FIELDS.
              DATA(lv_from) = sy-tabix.
              READ TABLE lt_size WITH KEY zsize = <ls_final3>-to_size TRANSPORTING NO FIELDS.
              DATA(lv_to) = sy-tabix.
              IF lv_to IS NOT INITIAL .
                LOOP AT lt_size ASSIGNING FIELD-SYMBOL(<ls_size>) FROM lv_from TO lv_to.
                  APPEND VALUE #( sign  = 'I' option = 'EQ' low = <ls_size>-zsize ) TO r_range.
                  APPEND VALUE #( item = lv_item matkl = <ls_final3>-category_code size = <ls_size>-zsize ) TO lt_cat_size.
                ENDLOOP.
              ELSE.
                READ TABLE lt_size ASSIGNING <ls_size> INDEX lv_from.
                IF sy-subrc = 0.
                  APPEND VALUE #( sign  = 'I' option = 'EQ' low = <ls_size>-zsize ) TO r_range.
                  APPEND VALUE #( item  = lv_item matkl = <ls_final3>-category_code size = <ls_size>-zsize ) TO lt_cat_size.
                ENDIF.
              ENDIF.
            ELSE.
              APPEND VALUE #( sign  = 'I' option = 'EQ' low = space ) TO r_range.
              APPEND VALUE #( item = lv_item matkl = <ls_final3>-category_code size = space  ) TO lt_cat_size.
            ENDIF.
******added by bhavani for the blank sizes 19.12.2019*************
*              ELSEIF <LS_FINAL3>-FROM_SIZE IS INITIAL.
**                LOOP AT LT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE1>) FROM LV_FROM TO LV_TO.
*                  APPEND VALUE #( SIGN  = 'I' OPTION = 'EQ' LOW = space ) TO R_RANGE.
*                  APPEND VALUE #( ITEM = LV_ITEM MATKL = <LS_FINAL3>-CATEGORY_CODE SIZE = <LS_SIZE>-ZSIZE  ) TO LT_CAT_SIZE.
**                ENDLOOP.
*              ENDIF.
*            ENDIF.
*******end of changes 19.12.2019***********************************
          ENDLOOP.
          SORT r_range BY low.
          DELETE ADJACENT DUPLICATES FROM r_range COMPARING low.
          SORT lt_cat_size BY item matkl size.
          DELETE ADJACENT DUPLICATES FROM lt_cat_size COMPARING item matkl size.
***   End of Changes By Suri : 25.11.2019
*break KKIRTI.
          IF it_brand IS  INITIAL .
            SELECT mara~matnr,
                   mara~matkl,                   mara~size1,
                   mara~zzprice_frm,
                   mara~zzprice_to ,
                   mara~meins,
                   mara~bstme
                   INTO TABLE @DATA(lt_mara)
                   FROM mara AS mara
                   FOR ALL ENTRIES IN @it_final3
                   WHERE mara~matkl = @it_final3-category_code
                   AND zzprice_frm <= @it_final3-price     AND zzprice_to  >= @it_final3-price
                  AND mara~size1 IN @r_range
                  AND   mara~mstae = ' ' .

          ELSE.
*** Test : SS
            SELECT mara~matnr,
                   mara~matkl,
                   mara~size1,
                   mara~zzprice_frm,
                   mara~zzprice_to ,
                   mara~meins,
                   mara~bstme
                   INTO TABLE @lt_mara
                   FROM mara AS mara
                   FOR ALL ENTRIES IN @it_final3
                   WHERE mara~matkl = @it_final3-category_code
                   AND mara~size1 IN @r_range
                   AND   mara~mstae = ' ' .
***   END OF CHANGES BY SURI : 25.11.2019
*** Test : SS
          ENDIF .
        ENDIF .
*********only for set materials added by bhavani***************
        IF it_final3 IS NOT INITIAL .
          SELECT mara~matnr,
                mara~matkl,
                mara~size1,
                mara~zzprice_frm,
                mara~zzprice_to ,
                mara~meins,
                mara~bstme
                INTO TABLE @DATA(lt_set)
                FROM mara AS mara
                FOR ALL ENTRIES IN @it_final3
                WHERE mara~matkl = @it_final3-category_code
                 AND   mara~mstae = ' ' .
*                   AND MARA~SIZE1 >= @IT_FINAL3-FROM_SIZE AND MARA~SIZE1 <= @IT_FINAL3-TO_SIZE.
*                   AND ZZPRICE_FRM >= @IT_FINAL3-PRICE     AND ZZPRICE_TO  <= @IT_FINAL3-PRICE.
*       AND MARA~SIZE1 IN @R_RANGE.
          DELETE lt_set WHERE meins <> c_set .
        ENDIF .

**********ended by bhavani********************************************


*********Added by bhavani 28.11.2019 for set material**********
*        READ TABLE IT_FINAL3 ASSIGNING FIELD-SYMBOL(<LS_FINAL3>) WITH KEY  =  C_SET.
        IF lt_set IS NOT INITIAL .
          SELECT mast~matnr,
             mast~werks,
             mast~stlnr,
             mast~stlal,
             stpo~stlkn,
             stpo~idnrk,
             stpo~posnr,
             stpo~menge,
             stpo~matkl,
             stpo~meins
             INTO TABLE @DATA(lt_comp)
             FROM mast AS mast
             INNER JOIN stpo AS stpo ON stpo~stlty = @c_m AND mast~stlnr = stpo~stlnr
             FOR ALL ENTRIES IN @lt_set
             WHERE mast~matnr = @lt_set-matnr.
        ENDIF.
********Ended by bhavani 28.11.2019***************************
**************    ADDED ON (12-3-20)   ******************
**        SELECT ZPH_T_HDR~VENDOR
**           FROM ZPH_T_HDR INTO TABLE @DATA(IT_LFA2) FOR ALL ENTRIES IN @IT_HDR
**                WHERE E_MSG = 'Vendor is not exist' AND INDENT_NO = @IT_HDR-INDENT_NO.
**
**     DATA: LV_LIFNR TYPE LFA1-LIFNR.
**        DATA: LV_LIFNR1 TYPE LFA1-LIFNR.
**        DATA: LV_ZZTEMP_VENDOR TYPE LFA1-ZZTEMP_VENDOR.
**        DATA : LV_REGIO TYPE LFA1-REGIO.
**        SELECT SINGLE
**               LIFNR
**         FROM LFA1 INTO LV_LIFNR
**          WHERE LIFNR = IM_HEADER-VENDOR.
**        IF LV_LIFNR IS INITIAL.
**
**          SELECT SINGLE LIFNR ZZTEMP_VENDOR REGIO FROM LFA1 INTO ( LV_LIFNR1 , LV_ZZTEMP_VENDOR , LV_REGIO ) WHERE ZZTEMP_VENDOR = IM_HEADER-VENDOR.
**          HEADER-VENDOR = LV_LIFNR1.
**        ELSE.
**          IF SY-SUBRC = 0.
**            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**              EXPORTING
**                INPUT  = IM_HEADER-VENDOR+0(10)
**              IMPORTING
**                OUTPUT = IM_HEADER-VENDOR+0(10).
**          ENDIF.
***          HEADER-VENDOR = IM_HEADER-VENDOR .                     " commented
**        ENDIF.
**
**         IF lt_mara IS NOT INITIAL .
**          SELECT
**          a792~wkreg ,
**          a792~regio ,
**          a792~steuc ,
**          a792~knumh ,
**          marc~matnr ,
**          t001w~werks
**           FROM marc AS marc
**           INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
**           INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
**           INTO TABLE @DATA(it_hsnN)
**           FOR ALL ENTRIES IN @lt_mara
**           WHERE marc~matnr = @lt_mara-matnr
**           AND a792~regio   = @LV_REGIO
**           AND t001w~werks = @im_header-delivery_at.
**        ENDIF .

*ENDIF.
*       ELSE.
************************        END(12-3-20)   **************
        SELECT SINGLE
           lfa1~regio FROM lfa1 INTO  @DATA(ls_lfa1)
             WHERE lifnr = @im_header-vendor+0(10) .      " 0(10) added on (3-3-20)

*ENDIF.                      " ADDED ON (12-3-20)
        IF lt_mara IS NOT INITIAL .
          SELECT
          a792~wkreg ,
          a792~regio ,
          a792~steuc ,
          a792~knumh ,
          marc~matnr ,
          t001w~werks
           FROM marc AS marc
           INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
           INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
           INTO TABLE @DATA(it_hsn)
           FOR ALL ENTRIES IN @lt_mara
           WHERE marc~matnr = @lt_mara-matnr
           AND a792~regio   = @ls_lfa1
           AND t001w~werks = @im_header-delivery_at.
        ENDIF .



        IF lt_comp IS NOT INITIAL.
          SELECT
          a792~wkreg ,
          a792~regio ,
          a792~steuc ,
          a792~knumh ,
          marc~matnr ,
          t001w~werks
           FROM marc AS marc
*           INNER JOIN STPO AS STPO ON MARC~MATNR = STPO~IDNRK
           INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
           INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
           INTO TABLE @DATA(it_hsn_s)
           FOR ALL ENTRIES IN @lt_comp
           WHERE marc~matnr = @lt_comp-idnrk
           AND a792~regio   = @ls_lfa1
           AND t001w~werks = @im_header-delivery_at.
*          SORT IT_HSN_S BY  KNUMH MATNR .
*          DELETE ADJACENT DUPLICATES FROM IT_HSN_S COMPARING KNUMH MATNR .

        ENDIF.

        IF it_hsn IS NOT INITIAL .
          SELECT
            konp~knumh ,
            konp~mwsk1 FROM konp INTO TABLE @DATA(it_konp)
                       FOR ALL ENTRIES IN @it_hsn
                       WHERE knumh = @it_hsn-knumh .
        ENDIF .
*****************  added on (12-3-20)    ********************

*      if it_hsnn IS NOT INITIAL .
*        SELECT
*            konp~knumh ,
*            konp~mwsk1 FROM konp INTO TABLE @DATA(it_konp)
*                       FOR ALL ENTRIES IN @it_hsnn
*                       WHERE knumh = @it_hsn-knumh .
*        ENDIF .

******************        end(12-3-20)    *******************

        IF it_hsn_s IS NOT INITIAL .
          SELECT
            konp~knumh ,
            konp~mwsk1 FROM konp INTO TABLE @DATA(it_konp_s)
                       FOR ALL ENTRIES IN @it_hsn_s
                       WHERE knumh = @it_hsn_s-knumh .
        ENDIF .

        IF im_header-vendor IS NOT INITIAL .
          SELECT SINGLE
           lfa1~adrnr FROM lfa1 INTO @DATA(p_adrnr)
                      WHERE lifnr = @im_header-vendor+0(10) .       " 0(10) added on (3-3-20)
        ENDIF .
        IF p_adrnr IS NOT INITIAL .
          SELECT SINGLE
            adrc~addrnumber ,
            adrc~city1 FROM adrc INTO @DATA(wa_city)
                    WHERE addrnumber = @p_adrnr .
        ENDIF .

        IF wa_city-city1 = 'CHENNAI'.

          lv_doc = 'ZLOP' .

        ELSE .

          lv_doc = 'ZOSP'.

        ENDIF.

*****************      commented on (3-3-20)   *******************
***        IF sy-subrc = 0.
***          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
***            EXPORTING
***              input  = im_header-vendor
***            IMPORTING
***              output = im_header-vendor.
***        ENDIF.
*****************        end (3-3-20)    ***************
        header-comp_code = '1000' .
        headerx-comp_code = 'X'.
        IF im_header-pdate IS NOT INITIAL.
          header-doc_date =  im_header-pdate.
        ELSE.
          header-doc_date = sy-datum .
        ENDIF.
        headerx-doc_date = 'X' .
        header-creat_date = sy-datum .
        headerx-creat_date = 'X' .
****************        added on (3-3-20),     ********************
        DATA: lv_lifnr TYPE lfa1-lifnr.
        DATA: lv_lifnr1 TYPE lfa1-lifnr.
        DATA: lv_zztemp_vendor TYPE lfa1-zztemp_vendor.
        DATA : lv_regio TYPE lfa1-regio.
        SELECT SINGLE
               lifnr
         FROM lfa1 INTO lv_lifnr
          WHERE lifnr = im_header-vendor.
        IF lv_lifnr IS INITIAL.

          SELECT SINGLE lifnr zztemp_vendor regio FROM lfa1 INTO ( lv_lifnr1 , lv_zztemp_vendor , lv_regio ) WHERE zztemp_vendor = im_header-vendor.
          header-vendor = lv_lifnr1.
        ELSE.
          IF sy-subrc = 0.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = im_header-vendor+0(10)
              IMPORTING
                output = im_header-vendor+0(10).
          ENDIF.
          header-vendor = im_header-vendor .                     " commented
        ENDIF.
****************        end (3-3-20)     *******************
***        header-vendor = im_header-vendor .    " commented on (3-3-20)
        headerx-vendor = 'X' .
        header-doc_type = lv_doc .
        headerx-doc_type = 'X' .
        header-langu = sy-langu .
        header-langu = 'X' .
        header-purch_org = '1000'.
        headerx-purch_org = 'X'.
        header-pur_group =  im_header-pur_group .
        headerx-pur_group =  'X' .

        READ TABLE it_final1 INTO wa_final1 INDEX 1.                        " ADDED BY LIKHITHA
        wa_extensionin-structure  = 'BAPI_TE_MEPOHEADER'.
        bapi_te_po-po_number      = ' '.
        bapi_te_po-zindent          = <s_final2>-indent_no.
        bapi_te_po-user_name          = wa_final1-sup_name.         " ADDED BY LIKHITHA
        wa_extensionin-valuepart1 = bapi_te_po.
        APPEND wa_extensionin TO extensionin.

        wa_extensionin-structure  = 'BAPI_TE_MEPOHEADERX'.
        bapi_te_pox-po_number     = ' '.
        bapi_te_pox-zindent  = 'X'.
        bapi_te_pox-user_name  = 'X'.                    " ADDED BY LIKHITHA
        wa_extensionin-valuepart1 = bapi_te_pox.
        APPEND wa_extensionin TO extensionin.
        CLEAR wa_extensionin.

*** End Of Changes by Suri : Freight charges : 23.03.2020 : 11.11.00
*** Freight charges
        APPEND VALUE #( cond_type = c_zfrb cond_value = im_header-freight_charges / 10 change_id = 'I' ) TO pocondhdr[] .
        APPEND VALUE #( cond_type = c_x cond_value = c_x change_id = c_x ) TO pocondhdrx[] .
*** End Of Changes by Suri : For Group/ Vendor level Discount : 23.03.2020 : 11.11.00
************************************          added by likhitha    ************************************
*WA_EXTENSIONIN-STRUCTURE  = 'BAPI_TE_MEPOHEADER'.
*        BAPI_TE_PO-PO_NUMBER      = ' '.
*        BAPI_TE_PO-USER_NAME          = <S_FINAL2>-SUP_NAME.
*        WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_PO.
*        APPEND WA_EXTENSIONIN TO EXTENSIONIN.
*
*        WA_EXTENSIONIN-STRUCTURE  = 'BAPI_TE_MEPOHEADERX'.
*        BAPI_TE_POX-PO_NUMBER     = ' '.
*        BAPI_TE_POX-USER_NAME  = 'X'.
*        WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POX.
*        APPEND WA_EXTENSIONIN TO EXTENSIONIN.
*        CLEAR WA_EXTENSIONIN.
***************************************************************************************



        DATA lv_line TYPE ebelp .
        DATA : lv_text1     TYPE ztext,
               lv_text2     TYPE zp_remarks, "ZREMARK,                        " ADDED BY LIKHITHA
               lv_price(11) TYPE c.
        REFRESH : it_return .

        LOOP AT it_final3 ASSIGNING FIELD-SYMBOL(<ls_fin>).
*          IF SL_ITEM = ' '.
*
*            SL_ITEM = '10' .
*
*          ENDIF.

********Added by Bhavani********************
          lv_price = <ls_fin>-price .
          CONDENSE lv_price .
*          CONCATENATE <LS_FIN>-CATEGORY_CODE <LS_FIN>-FROM_SIZE <LS_FIN>-TO_SIZE LV_PRICE INTO LV_TEXT1 .
*          LV_TEXT1 = <LS_FIN>-ZTEXT100.
*******Ended By Bhavani*********************
          DATA(lv_index) = sy-tabix.
          DATA(lt_count) = lt_mara.
*          DATA(LT_SET) = LT_MARA[].
*          DELETE LT_SET WHERE MEINS <> C_SET .
          DELETE lt_count WHERE matkl <> <ls_fin>-category_code.
          IF lt_count IS INITIAL.
            DATA(lv_msg) = 'No material found for Category ' && <ls_fin>-category_code .
            MESSAGE lv_msg TYPE 'E'.
          ENDIF.
          READ TABLE it_brand ASSIGNING FIELD-SYMBOL(<ls_brand>) WITH KEY matkl = <ls_fin>-category_code .
          IF sy-subrc NE 0.
            DELETE lt_count WHERE zzprice_frm > <ls_fin>-price.
*            IF SY-SUBRC = O.
*               MESSAGE 'No material found ' TYPE 'W' .
*               ENDIF.

            DELETE lt_count WHERE zzprice_to < <ls_fin>-price.
            IF lt_count IS INITIAL.
              lv_msg = 'No material found for Category ' && <ls_fin>-category_code .
              MESSAGE lv_msg TYPE 'E'.
            ENDIF.
*            IF SY-SUBRC = 0.
********************************            ADDED BY LIKHITHA     ***********************************
*            READ TABLE LT_MARA  ASSIGNING FIELD-SYMBOL(<LS_MARA1>)  WITH KEY MATKL = <LS_FIN>-CATEGORY_CODE .
*             IF SY-SUBRC = 0.
*            IF <LS_MARA1>-ZZPRICE_FRM > <LS_FIN>-PRICE  AND <LS_MARA1>-ZZPRICE_TO < <LS_FIN>-PRICE.
*               MESSAGE 'No material found ' TYPE 'E' .
*               ENDIF.
*            ENDIF.
*            *****************************    END   ***************************
          ENDIF.
*          **************************            ADDED BY LIKHITHA,      ******************************
*            IF LV_PRICE NE <LS_FIN>-PRICE.
*              MESSAGE 'No material found ' TYPE 'W' .
*              endif.
*            ******************    END  *********************
*          DELETE LT_COUNT WHERE ZZPRICE_FRM <= <LS_FIN>-PRICE AND ZZPRICE_TO >= <LS_FIN>-PRICE.
***       Start of Chages by Suri : 25.11.2019
          CLEAR : lv_count.
          IF <ls_fin>-from_size IS NOT INITIAL.
            IF <ls_fin>-from_size <> c_set .
              LOOP AT lt_count ASSIGNING FIELD-SYMBOL(<ls_mara>) WHERE matkl = <ls_fin>-category_code.
                READ TABLE lt_cat_size ASSIGNING FIELD-SYMBOL(<ls_ca_size>) WITH KEY matkl = <ls_fin>-category_code size = <ls_mara>-size1 item = <ls_fin>-item.
                IF sy-subrc = 0.
                  CHECK it_brand IS INITIAL.
                  IF <ls_mara>-zzprice_frm LE <ls_fin>-price AND <ls_mara>-zzprice_to GE <ls_fin>-price.
                  ELSE.
                    <ls_mara>-matkl = 'XXX'.
                  ENDIF.
                ELSE.
                  <ls_mara>-matkl = 'XXX'.
                ENDIF.
*                  IF LT_COUNT IS INITIAL.
*                     WA_FINAL-E_MSG = 'No material found'.
*                     ENDIF.
              ENDLOOP.
*              DELETE LT_COUNT WHERE MATKL = 'XXX'.
*          DESCRIBE TABLE LT_COUNT LINES LV_COUNT.
*            IF LT_COUNT IS INITIAL.
*                     WA_FINAL-E_MSG = 'No material found'.
*                     ENDIF.
**************************            ADDED BY LIKHITHA,      ******************************
*           data : ERR TYPE ZEMSG.
*            DATA : IT_PH_HDR  TYPE TABLE OF ZPH_T_HDR,
*                    WA_PH_HDR  TYPE  ZPH_T_HDR.
              DELETE lt_count WHERE matkl = 'XXX'.
              IF lt_count IS INITIAL.
                lv_msg = 'No material found for Category ' && <ls_fin>-category_code .
                MESSAGE lv_msg TYPE 'E'.
              ENDIF.
              DESCRIBE TABLE lt_count LINES lv_count.
            ENDIF.
          ENDIF.

*              else.
*            ******************    END  *********************
***       End of Chages by Suri : 25.11.2019
*          READ TABLE LT_SET ASSIGNING FIELD-SYMBOL(<LS_CHECK>) WITH KEY MATKL = <LS_FIN>-CATEGORY_CODE .
*          IF SY-SUBRC = 0 .
          IF <ls_fin>-from_size = c_set .
            SORT lt_set BY matkl matnr .
            LOOP AT lt_set ASSIGNING FIELD-SYMBOL(<ls_marp>) WHERE matkl = <ls_fin>-category_code.

******START CHANGES BY BHAVANI 28.11.2019****

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  input  = <ls_marp>-matnr
                IMPORTING
                  output = <ls_marp>-matnr.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = wa_item-po_item
                IMPORTING
                  output = wa_item-po_item.

*            IF   <LS_MARP>-MEINS =    C_SET .

              wa_item-po_item = wa_itemx-po_item =  sl_item.
*              READ TABLE IT_HSN ASSIGNING FIELD-SYMBOL(<LS_HSN1>) WITH KEY MATNR = <LS_MARP>-MATNR .
*              IF SY-SUBRC = 0.
*                CLEAR :  LV_MWSK1 .
*                READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<LS_KONP1>) WITH KEY KNUMH = <LS_HSN1>-KNUMH .
*                IF SY-SUBRC = 0.
*                  WA_ITEM-TAX_CODE = <LS_KONP1>-MWSK1.
*                  WA_ITEMX-TAX_CODE = 'X'.
*                  LV_MWSK1 = <LS_KONP1>-MWSK1.
*                ENDIF.
*              ENDIF.
*              endif.                                            " added by likhitha
              SORT lt_comp BY matnr stlnr stlkn idnrk posnr .
              LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>) WHERE matnr = <ls_marp>-matnr.
*                IF SL_ITEM = ' '.
*
*                  SL_ITEM = '10' .
*
*                ENDIF.
***       Itam Data
***       QUANTITY DIVISION


                READ TABLE it_hsn_s ASSIGNING FIELD-SYMBOL(<ls_hsn_s>) WITH KEY matnr = <ls_comp>-idnrk .
                IF sy-subrc = 0.
                  CLEAR :  lv_mwsk1 .
                  READ TABLE it_konp_s ASSIGNING FIELD-SYMBOL(<ls_konp_s>) WITH KEY knumh = <ls_hsn_s>-knumh .
                  IF sy-subrc = 0.
                    wa_item-tax_code = <ls_konp_s>-mwsk1.
                    wa_itemx-tax_code = 'X'.
                    lv_mwsk1 = <ls_konp_s>-mwsk1.
                  ENDIF.
                ENDIF.




                DATA(lt_comp_t) = lt_comp.
                DELETE lt_comp_t WHERE matnr <> <ls_marp>-matnr.
                IF lt_comp_t IS INITIAL.
                  lv_msg = 'No material found for Category ' && <ls_fin>-category_code .
                  MESSAGE lv_msg TYPE 'E'.
                ENDIF.
                DESCRIBE TABLE lt_comp_t LINES DATA(lv_linesc).
                wa_item-po_item = wa_itemx-po_item =  sl_item.
                SHIFT <ls_marp>-matnr LEFT DELETING LEADING '0'.
                wa_item-material_long      = <ls_comp>-idnrk.
                wa_itemx-material_long  = c_x.
                wa_item-quantity      =  <ls_fin>-quantity / lv_linesc .
                c = wa_item-quantity .
                CONDENSE c .
                SPLIT c AT '.' INTO a b .


                wa_item-quantity = a .
                wa_itemx-quantity         =  c_x .
                wa_item-plant         =   im_header-delivery_at.
                wa_itemx-plant         =   c_x .
                wa_item-stge_loc = 'FG01' .
                wa_itemx-stge_loc = 'X' .
                wa_item-net_price     = <ls_fin>-price .
                wa_itemx-net_price = 'X'.
*            WA_ITEM-IR_IND        = C_X.
*            WA_ITEM-GR_BASEDIV    = C_X.
                wa_item-ir_ind = 'X'.
                wa_itemx-ir_ind = 'X'.
                wa_item-gr_basediv = 'X'.
                wa_itemx-gr_basediv = 'X'.

                wa_potextitem-po_item = sl_item.
                wa_potextitem-text_id = 'F03'.
                wa_potextitem-text_form = '*'.
                wa_potextitem-text_line = <ls_fin>-remarks.
                APPEND wa_potextitem TO potextitem.

                wa_potextitem-po_item = sl_item.
                wa_potextitem-text_id = 'F08'.
                wa_potextitem-text_form = '*'.
                wa_potextitem-text_line = <ls_fin>-color.
                APPEND wa_potextitem TO potextitem.


                wa_potextitem-po_item = sl_item.
                wa_potextitem-text_id = 'F07'.
                wa_potextitem-text_form = '*'.
                wa_potextitem-text_line = <ls_fin>-style.
                APPEND wa_potextitem TO potextitem.
                MOVE <ls_fin>-remarks TO lv_text2.              " added by likhitha
                CONCATENATE <ls_fin>-item <ls_fin>-category_code <ls_fin>-style  <ls_fin>-from_size <ls_fin>-to_size  <ls_fin>-color lv_price  INTO lv_text1 .
********ADDED BY BHAVANI 28.11.2019*********

                CLEAR :bapi_te_poitem ,bapi_te_poitemx.
                BREAK samburi.
***       Item extenction fields
                wa_extensionin-structure = 'BAPI_TE_MEPOITEM'.
                bapi_te_poitem-po_item  = sl_item.
                bapi_te_poitem-zztext100  = lv_text1.
                bapi_te_poitem-zzremarks  = <ls_fin>-remarks.              " ADDED BY LIKHITHA
                wa_extensionin-valuepart1 = bapi_te_poitem.
                APPEND wa_extensionin TO extensionin.
                CLEAR : wa_extensionin.
***       Item extenction fields Updation Flags
                wa_extensionin-structure = 'BAPI_TE_MEPOITEMX'.
                bapi_te_poitemx-po_item = sl_item.
                bapi_te_poitemx-zztext100 = c_x.
                bapi_te_poitemx-zzremarks = c_x.                    " ADDED BY LIKHITHA
                wa_extensionin-valuepart1 = bapi_te_poitemx.
                APPEND wa_extensionin TO extensionin.
                CLEAR wa_extensionin.
******************************  ADDED BY LIKHITHA  *****************************
***                 extenction fields
*                WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEM'.
*                BAPI_TE_POITEM-PO_ITEM  = SL_ITEM.
*                BAPI_TE_POITEM-ZZREMARKS  = lv_text2.
*                WA_EXTENSIONIN-VALUEPART2 = BAPI_TE_POITEM.
*                APPEND WA_EXTENSIONIN TO EXTENSIONIN.
*                CLEAR : WA_EXTENSIONIN.
*
*                  WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEMX'.
*                BAPI_TE_POITEMX-PO_ITEM = SL_ITEM.
*                BAPI_TE_POITEMX-ZZREMARKS = C_X.
*                WA_EXTENSIONIN-VALUEPART2 = BAPI_TE_POITEMX.
*                APPEND WA_EXTENSIONIN TO EXTENSIONIN.
*                CLEAR WA_EXTENSIONIN.
**


*     *****************************      END    *************************************







                CLEAR : lv_text .
********ended by bhavani 28.11.2019*********
                wa_item-plan_del = im_header-lead_time.
                wa_itemx-plan_del = 'X'.


                wa_item-over_dlv_tol  = '10'.           ""tolerance
                wa_itemx-over_dlv_tol  = 'X'.           ""tolerance

*****   For Vessels Converstion KGs to EA
**                IF IM_HEADER-PGROUP = C_VESSELS.
**                  WA_ITEM-ORDERPR_UN  = C_KG.
**                  WA_ITEMX-ORDERPR_UN = C_X.
**                ENDIF.

                IF im_header-pur_group = 'P34'.
                  wa_item-acctasscat = 'K'.
                  wa_itemx-acctasscat = 'X'.
                ENDIF.

                APPEND wa_item TO item[].
                APPEND wa_itemx TO itemx[].
*          MODIFY PO_ITEM FROM   WA_ITEM TRANSPORTING LV_POITEM .
                wa_pocond-cond_type = 'PBXX' .
                wa_pocond-cond_value = <ls_fin>-price  / 10.
                wa_pocond-itm_number = wa_item-po_item  .
                wa_pocond-change_id = 'U' .
                wa_pocondx-cond_type = 'X' .
                wa_pocondx-cond_value = 'X' .
                wa_pocondx-itm_number = 'X' .
                wa_pocondx-change_id = 'X' .

                APPEND wa_pocond TO pocond[] .
                APPEND wa_pocondx TO pocondx[] .

*** Start Of Changes by Suri : For Group / Vendor level Discount : 23.03.2020 : 11.11.00
*** Discount 1  : Group / Vendor level Discount
                IF lv_group_margin IS NOT INITIAL.
                  APPEND VALUE #( cond_type = c_zds1 cond_value = ( lv_discount / 10 ) itm_number = wa_item-po_item change_id = 'I' ) TO pocond[] .
                  APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .
                ENDIF.
*** Discount 2 in %
                APPEND VALUE #( cond_type = c_zds2 cond_value = <ls_fin>-discount2 itm_number = wa_item-po_item change_id = 'I' ) TO pocond[] .
                APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .

*** Discount 3 per Piece
                APPEND VALUE #( cond_type = c_zds3 cond_value = <ls_fin>-discount3 itm_number = wa_item-po_item change_id = 'I' ) TO pocond[] .
                APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .

*** End Of Changes by Suri : For Group/ Vendor level Discount : 23.03.2020 : 11.11.00

*****************************************************************************************
                IF im_header-pur_group = 'P34'.

                  wa_poaccount-po_item    = sl_item.
                  wa_poaccount-gl_account = wa_data-gl_account.
                  wa_poaccount-costcenter = wa_data-costcenter.

                  wa_poaccountx-po_item    = sl_item.
                  wa_poaccountx-gl_account = 'X'.
                  wa_poaccountx-costcenter = 'X'.

                  APPEND wa_poaccount TO it_poaccount.
                  APPEND wa_poaccountx TO it_poaccountx.

                ENDIF.
****************************************************************************************
                CLEAR : wa_item,wa_itemx ,wa_pocond,wa_pocondx ,a , b ,c,wa_poaccount, wa_poaccountx .

                sl_item =  sl_item + 10 .

*            LV_POITEM = LV_POITEM + 10 .
*            CLEAR LV_LINE .

              ENDLOOP.
            ENDLOOP.
          ELSE .
            CLEAR : lv_mwsk1 .
            SORT lt_count BY matkl matnr .
            DATA(lt_size1) = lt_count[].
*            SORT LT_SIZE1 BY SIZE1 .
*            DELETE ADJACENT DUPLICATES FROM LT_SIZE1 COMPARING SIZE1 .
*            DESCRIBE TABLE LT_SIZE1 LINES DATA(LV_SIZE) .
***         Start of Changes By Suri : 20.12.2019
***         Article Count
            SORT lt_size1 BY matkl matnr.
            DELETE ADJACENT DUPLICATES FROM lt_size1 COMPARING matkl matnr.
            DESCRIBE TABLE lt_size1 LINES DATA(lv_size) .
***         End of Changes By Suri : 20.12.2019
            LOOP AT lt_count ASSIGNING <ls_marp> WHERE matkl = <ls_fin>-category_code.
              wa_item-po_item = wa_itemx-po_item =  sl_item.
              READ TABLE it_hsn ASSIGNING FIELD-SYMBOL(<ls_hsnb>) WITH KEY matnr = <ls_marp>-matnr .
              IF sy-subrc = 0.
                READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<ls_konpb>) WITH KEY knumh = <ls_hsnb>-knumh .
                IF sy-subrc = 0.
                  wa_item-tax_code = <ls_konpb>-mwsk1.
                  lv_mwsk1 = <ls_konpb>-mwsk1 .
                  wa_itemx-tax_code = 'X'.
                ENDIF.
              ENDIF.


*
*              IF SL_ITEM = ' '.
*
*                SL_ITEM = '10' .
*
*              ENDIF.



              wa_item-material_long = <ls_marp>-matnr .
              wa_itemx-material_long  = c_x.
              wa_item-po_unit       = <ls_marp>-meins.
*          READ TABLE IT_FINAL3 ASSIGNING FIELD-SYMBOL(<LS_FIN>) INDEX SY-TABIX .  ""CATEGORY_CODE = <LS_MARP>-MATKL FROM_SIZE = <LS_MARP>-SIZE1
*          IF SY-SUBRC = 0.
*            DATA(LT_COUNT) = LT_MARA.
*            DELETE LT_COUNT WHERE MATKL <> <LS_FIN>-CATEGORY_CODE.
*            DELETE LT_COUNT WHERE SIZE1 NOT BETWEEN  <LS_FIN>-FROM_SIZE AND <LS_FIN>-TO_SIZE.
*            DELETE LT_COUNT WHERE ZZPRICE_FRM < <LS_FIN>-PRICE AND ZZPRICE_FRM > <LS_FIN>-PRICE.
**            BREAK BREDDY .
*            SORT LT_COUNT BY SIZE1 .
*            DELETE ADJACENT DUPLICATES FROM LT_COUNT COMPARING SIZE1.
*            DESCRIBE TABLE LT_COUNT LINES LV_COUNT .
*            DELETE LT_COUNT WHERE MATKL <> <LS_FIN>-MATKL.
              wa_item-quantity       =  <ls_fin>-quantity / lv_size .
*          ENDIF.
              c = wa_item-quantity .
              CONDENSE c .
              SPLIT c AT '.' INTO a b .
              wa_item-quantity = a .
              wa_itemx-quantity         =  c_x .
              wa_item-plant         =   im_header-delivery_at.
              wa_itemx-plant         =   c_x .
              wa_item-stge_loc = 'FG01' .
              wa_itemx-stge_loc = 'X' .
              wa_item-net_price     = <ls_fin>-price .
              wa_itemx-net_price = 'X'.
*            WA_ITEM-IR_IND        = C_X.
*            WA_ITEM-GR_BASEDIV    = C_X.
              wa_item-ir_ind = 'X'.
              wa_itemx-ir_ind = 'X'.
              wa_item-gr_basediv = 'X'.
              wa_itemx-gr_basediv = 'X'.

              wa_potextitem-po_item = sl_item.
              wa_potextitem-text_id = 'F03'.
              wa_potextitem-text_form = '*'.
              wa_potextitem-text_line = <ls_fin>-remarks.
              APPEND wa_potextitem TO potextitem.

              wa_potextitem-po_item = sl_item.
              wa_potextitem-text_id = 'F08'.
              wa_potextitem-text_form = '*'.
              wa_potextitem-text_line = <ls_fin>-color.
              APPEND wa_potextitem TO potextitem.


              wa_potextitem-po_item = sl_item.
              wa_potextitem-text_id = 'F07'.
              wa_potextitem-text_form = '*'.
              wa_potextitem-text_line = <ls_fin>-style.
              APPEND wa_potextitem TO potextitem.
*************************** ADDED BY LIKHITHA *******************************
***              WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEM'.
***                BAPI_TE_POITEM-PO_ITEM  = SL_ITEM.
***                BAPI_TE_POITEM-ZZREMARKS  = <LS_FIN>-REMARKS.
***                WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEM.
***                APPEND WA_EXTENSIONIN TO EXTENSIONIN.
***                CLEAR : WA_EXTENSIONIN.
***
***                  WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEMX'.
***                BAPI_TE_POITEMX-PO_ITEM = SL_ITEM.
***                BAPI_TE_POITEMX-ZZREMARKS = C_X.
***                WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEMX.
***                APPEND WA_EXTENSIONIN TO EXTENSIONIN.
***                CLEAR WA_EXTENSIONIN.
****              ****************************************

********added by bhavani 28.11.2019*********

***              CLEAR :BAPI_TE_POITEM ,BAPI_TE_POITEMX.             " commented by likhitha
              CONCATENATE <ls_fin>-item <ls_fin>-category_code <ls_fin>-style  <ls_fin>-from_size <ls_fin>-to_size  <ls_fin>-color lv_price  INTO lv_text1 .
***       Item extenction fields
              wa_extensionin-structure = 'BAPI_TE_MEPOITEM'.
              bapi_te_poitem-po_item  = sl_item.
              bapi_te_poitem-zztext100  = lv_text1.
              bapi_te_poitem-zzremarks  = <ls_fin>-remarks.                  " added by likhitha
              bapi_te_poitem-zzcolor    = <ls_fin>-color.                    " Added by likhitha
              bapi_te_poitem-zzstyle    = <ls_fin>-style.                    " ADDED BY LIKHITHA
              wa_extensionin-valuepart1 = bapi_te_poitem.
*              BAPI_TE_POITEM-ZZREMARKS  = <LS_FIN>-REMARKS.
*              WA_EXTENSIONIN-VALUEPART2 = BAPI_TE_POITEM.
              APPEND wa_extensionin TO extensionin.
              CLEAR : wa_extensionin.
***       Item extenction fields Updation Flags
              wa_extensionin-structure = 'BAPI_TE_MEPOITEMX'.
              bapi_te_poitemx-po_item = sl_item.
              bapi_te_poitemx-zztext100 = c_x.
              bapi_te_poitemx-zzremarks = c_x.                         " ADDED BY LIKHHITHA TO UBDATE IN EKPO
              bapi_te_poitemx-zzcolor  = c_x.                         " added by likhitha
              bapi_te_poitemx-zzstyle = c_x.                            " added by likhitha
              wa_extensionin-valuepart1 = bapi_te_poitemx.
*              BAPI_TE_POITEMX-ZZREMARKS = C_X.
*              WA_EXTENSIONIN-VALUEPART2 = BAPI_TE_POITEMX.
              APPEND wa_extensionin TO extensionin.
              CLEAR wa_extensionin.

*         ************************ ADDED BY LIKHITHA *******************************
*              WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEM'.
*                BAPI_TE_POITEM-PO_ITEM  = SL_ITEM.
*                BAPI_TE_POITEM-ZZREMARKS  = <LS_FIN>-REMARKS.
*                WA_EXTENSIONIN-VALUEPART2 = BAPI_TE_POITEM.
*                APPEND WA_EXTENSIONIN TO EXTENSIONIN.
*                CLEAR : WA_EXTENSIONIN.
*
*                  WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEMX'.
*                BAPI_TE_POITEMX-PO_ITEM = SL_ITEM.
*                BAPI_TE_POITEMX-ZZREMARKS = C_X.
*                WA_EXTENSIONIN-VALUEPART2 = BAPI_TE_POITEMX.
*                APPEND WA_EXTENSIONIN TO EXTENSIONIN.
*                CLEAR WA_EXTENSIONIN.
*              ****************************************end *********
              CLEAR : lv_text .
********ended by bhavani 28.11.2019*********

              wa_item-plan_del = im_header-lead_time.
              wa_itemx-plan_del = 'X'.


              wa_item-over_dlv_tol  = '10'.           ""tolerance
              wa_itemx-over_dlv_tol  = 'X'.           ""tolerance

****   For Vessels Converstion KGs to EA
*              IF IM_HEADER-PGROUP = C_VESSELS.
*                IF <LS_MARP>-MEINS <> <LS_MARP>-BSTME.
*                  WA_ITEM-ORDERPR_UN  = C_KG.
*                  WA_ITEMX-ORDERPR_UN = C_X.
*                ENDIF.
*              ENDIF.

              IF im_header-pur_group = 'P34'.
                wa_item-acctasscat = 'K'.
                wa_itemx-acctasscat = 'X'.
              ENDIF.


              APPEND wa_item TO item[].
              APPEND wa_itemx TO itemx[].
*          MODIFY PO_ITEM FROM   WA_ITEM TRANSPORTING LV_POITEM .
              wa_pocond-cond_type = 'PBXX' .
              wa_pocond-cond_value = <ls_fin>-price  / 10.
              wa_pocond-itm_number = wa_item-po_item  .
              wa_pocond-change_id = 'U' .
              wa_pocondx-cond_type = 'X' .
              wa_pocondx-cond_value = 'X' .
              wa_pocondx-itm_number = 'X' .
              wa_pocondx-change_id = 'X' .

              APPEND wa_pocond TO pocond[] .
              APPEND wa_pocondx TO pocondx[] .

*** Start Of Changes by Suri : For Group / Vendor level Discount : 23.03.2020 : 11.11.00
** Discount 1  : Group / Vendor level Discount
              IF lv_group_margin IS NOT INITIAL.
                APPEND VALUE #( cond_type = c_zds1 cond_value = ( lv_discount / 10 ) itm_number = wa_item-po_item change_id = 'I' ) TO pocond[] .
                APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .
              ENDIF.
*** Discount 2 in %
              APPEND VALUE #( cond_type = c_zds2 cond_value = <ls_fin>-discount2 itm_number = wa_item-po_item change_id = 'I' ) TO pocond[] .
              APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .

*** Discount 3 per Piece
              APPEND VALUE #( cond_type = c_zds3 cond_value = <ls_fin>-discount3 / 10 itm_number = wa_item-po_item change_id = 'I' ) TO pocond[] .
              APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .

*** End Of Changes by Suri : For Group/ Vendor level Discount : 23.03.2020 : 11.11.00


*****************************************************************************************
              IF im_header-pur_group = 'P34'.

                wa_poaccount-po_item    = sl_item.
                wa_poaccount-gl_account = wa_data-gl_account.
                wa_poaccount-costcenter = wa_data-costcenter.

                wa_poaccountx-po_item    = sl_item.
                wa_poaccountx-gl_account = 'X'.
                wa_poaccountx-costcenter = 'X'.

                APPEND wa_poaccount TO it_poaccount.
                APPEND wa_poaccountx TO it_poaccountx.

              ENDIF.
****************************************************************************************



              CLEAR : wa_item,wa_itemx ,wa_pocond,wa_pocondx ,a , b ,c, wa_poaccount,wa_poaccountx .

              sl_item =  sl_item + 10 .

*            LV_POITEM = LV_POITEM + 10 .
*            CLEAR LV_LINE .
            ENDLOOP .
          ENDIF .
*        ENDIF .                                                      " added by likhitha
*          break breddy .
        ENDLOOP.
*        REFRESH IT_ERROR .
*        IF ITEM IS NOT INITIAL .
        CLEAR : sl_item .
        sl_item = '10'.
        DATA(it_tax) = item[] .

        READ TABLE it_tax  WITH KEY tax_code = space TRANSPORTING NO FIELDS.
        IF   sy-subrc <> 0 ."AND FLAG NE 'X'.

          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              poheader         = header
              poheaderx        = headerx
*             POADDRVENDOR     =
*             TESTRUN          =
*             MEMORY_UNCOMPLETE            =
*             MEMORY_COMPLETE  =
*             POEXPIMPHEADER   =
*             POEXPIMPHEADERX  =
*             VERSIONS         =
*             NO_MESSAGING     =
*             NO_MESSAGE_REQ   =
*             NO_AUTHORITY     =
              no_price_from_po = 'X'
*             PARK_COMPLETE    =
*             PARK_UNCOMPLETE  =
            IMPORTING
              exppurchaseorder = lv_ebeln
*             EXPHEADER        =
*             EXPPOEXPIMPHEADER            =
            TABLES
              return           = it_return[]
              poitem           = item[]
              poitemx          = itemx[]
*             POADDRDELIVERY   =
*             POSCHEDULE       =
*             POSCHEDULEX      =
              poaccount        = it_poaccount
*             POACCOUNTPROFITSEGMENT       =
              poaccountx       = it_poaccountx
              pocondheader     = pocondhdr[]
              pocondheaderx    = pocondhdrx[]
              pocond           = pocond[]
              pocondx          = pocondx[]
*             POLIMITS         =
*             POCONTRACTLIMITS =
*             POSERVICES       =
*             POSRVACCESSVALUES            =
*             POSERVICESTEXT   = POSERVICESTEXT[]
              extensionin      = extensionin[]
*             EXTENSIONOUT     =
*             POEXPIMPITEM     =
*             POEXPIMPITEMX    =
*             POTEXTHEADER     =
              potextitem       = potextitem[]
*             ALLVERSIONS      =
*             POPARTNER        =
*             POCOMPONENTS     =
*             POCOMPONENTSX    =
*             POSHIPPING       =
*             POSHIPPINGX      =
*             POSHIPPINGEXP    =
*             SERIALNUMBER     =
*             SERIALNUMBERX    =
*             INVPLANHEADER    =
*             INVPLANHEADERX   =
*             INVPLANITEM      =
*             INVPLANITEMX     =
*             NFMETALLITMS     =
            .
*    ET_RETURN  = IT_RETURN.
*      EBELN = LV_EBELN.
*      BREAK BREDDY .
        ELSE.

          MESSAGE 'Po tax is not maintained ' TYPE 'E' .
        ENDIF .
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        lv_tex = 'Created Successfully' .
*        CLEAR :lv_discount , lv_group_margin.
        CONCATENATE lv_ebeln lv_tex  INTO lv_tebeln SEPARATED BY space.
        IF lv_ebeln IS NOT INITIAL .
          MESSAGE lv_tebeln TYPE  'S' .
        ELSE.

          READ TABLE it_return ASSIGNING FIELD-SYMBOL(<ls_return>) WITH KEY type = 'E' id = '06' number = '070' .
          IF sy-subrc = 0.
            lv_error = 'Please check the quantity you have entered' .
            MESSAGE lv_error TYPE 'E' .

          ENDIF.

        ENDIF.
*        BREAK BREDDY .
*** Start of Changes By Suri : 15.11.2019
*** Send Mail to Vendor
        IF lv_ebeln IS NOT INITIAL.

*          CALL FUNCTION 'ZFM_PURCHASE_FORM'
*            EXPORTING
*              LV_EBELN = LV_EBELN            " Purchasing Document Number
*              REG_PO   = 'X'.                " Purchasing Document Number

          CALL FUNCTION 'ZFM_PURCHASE_FORM1'
            EXPORTING
              lv_ebeln = lv_ebeln
              reg_po   = 'X'.
*   RETURN_PO            =
*   TATKAL_PO            =
*   PRINT_PRIEVIEW       =
*   SERVICE_PO           =
*          .


******Added By Bhavani 27.11.2019***********************
        ELSEIF it_return IS NOT INITIAL AND lv_ebeln IS  INITIAL.


          CALL SCREEN 9001 STARTING AT 20 20 .


*          REFRESH IT_ERRORCAT .
*
*          WA_ERRORCAT-
*
*
*
*
*
*         CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
*                      EXPORTING
**             I_TITLE       =
**             I_SELECTION   = 'X'
**             I_ALLOW_NO_SELECTION          =
**             I_ZEBRA       = ' '
**             I_SCREEN_START_COLUMN         = 0
**             I_SCREEN_START_LINE           = 0
**             I_SCREEN_END_COLUMN           = 0
**             I_SCREEN_END_LINE             = 0
**             I_CHECKBOX_FIELDNAME          =
**             I_LINEMARK_FIELDNAME          =
**             I_SCROLL_TO_SEL_LINE          = 'X'
*                        I_TABNAME     = IT_RETURN
**             I_STRUCTURE_NAME              =
*                        IT_FIELDCAT   = IT_ERRORCAT
**             IT_EXCLUDING  =
**             I_CALLBACK_PROGRAM            =
**             I_CALLBACK_USER_COMMAND       =
**             IS_PRIVATE    =
** IMPORTING
**             ES_SELFIELD   =
**             E_EXIT        =
*                      TABLES
*                        T_OUTTAB      = IT_RETURN
*                      EXCEPTIONS
*                        PROGRAM_ERROR = 1
*                        OTHERS        = 2.
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
*

*******Ended By Bhavani 27.11.2019*********************************
*  CLEAR : HEADER,HEADERX, LV_EBELN .
        ENDIF.
*** End of Changes By Suri : 15.11.2019
      ELSE.

        MESSAGE 'Purchase Order for this Indent Number is already exist' TYPE 'E'.


      ENDIF .
*      ENDIF .
*   CLEAR : HEADER,HEADERX, LV_EBELN .
  ENDCASE.

*  IF C_SAVE IS NOT INITIAL.
*    SET PF-STATUS 'C_SAVE' EXCLUDING 'SAVE' .
* ENDIF .
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_tb_functions  CHANGING p_gt_exclude.
  DATA ls_exclude TYPE ui_func.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find_more.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_average.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gt_exclude.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_fcat .

  REFRESH gt_fieldcat.

  gs_fieldcats-fieldname      = 'INDENT_NO'.
  gs_fieldcats-reptext      = 'Indent No'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.




  gs_fieldcats-fieldname      = 'VENDOR'.
  gs_fieldcats-reptext      = 'Vendor'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'PGROUP'.
  gs_fieldcats-reptext      = 'Group'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'CATEGORY_CODE'.
  gs_fieldcats-reptext      = 'Category Code'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'STYLE'.
  gs_fieldcats-reptext      = 'Style'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'FROM_SIZE'.
  gs_fieldcats-reptext      = 'From Size'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'TO_SIZE'.
  gs_fieldcats-reptext      = 'To Size'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'COLOR'.
  gs_fieldcats-reptext      = 'Color'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'QUANTITY'.
  gs_fieldcats-reptext      = 'Quantity'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'PRICE'.
  gs_fieldcats-reptext      = 'Price'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'REMARKS'.
  gs_fieldcats-reptext      = 'Remarks'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'E_MSG'.
  gs_fieldcats-reptext      = 'Error Message'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

  gs_fieldcats-fieldname      = 'S_MSG'.
  gs_fieldcats-reptext      = 'Success Message'.
  gs_fieldcats-col_opt     = 'X'.
  gs_fieldcats-txt_field   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND gs_fieldcats TO gt_fieldcat.
  CLEAR gs_fieldcats.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA_SCR3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data_scr3 .

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      is_layout                     = gs_layo
      it_toolbar_excluding          = gt_exclude  " Excluded Toolbar Standard Functions
    CHANGING
      it_outtab                     = it_final2
      it_fieldcatalog               = gt_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_data .
  REFRESH : it_final2.
  CLEAR : wa_final2.
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

  REFRESH lt_fieldcat.
  gs_fieldcat-fieldname      = 'VENDOR'.
  gs_fieldcat-seltext_l      = 'Vendor'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'VENDOR_NAME'.
  gs_fieldcat-seltext_l      = 'Vendor Name'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'PGROUP'.
  gs_fieldcat-seltext_l      = 'Group'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'PUR_GROUP'.
  gs_fieldcat-seltext_l      = 'Purchase Group'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'INDENT_NO'.
  gs_fieldcat-seltext_l      = 'Indent Number'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  gs_fieldcat-outputlen      = '30' .
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'SUP_SAL_NO'.
  gs_fieldcat-seltext_l      = 'Supervisor Salary Number'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'SUP_NAME'.
  gs_fieldcat-seltext_l      = 'Supervisor Name'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'TRANSPORTER'.
  gs_fieldcat-seltext_l      = 'Transporter'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'VENDOR_LOCATION'.
  gs_fieldcat-seltext_l      = 'Vendor Location'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'DELIVERY_AT'.
  gs_fieldcat-seltext_l      = 'Delivery At'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'LEAD_TIME '.
  gs_fieldcat-seltext_l      = 'Lead Time'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'E_MSG'.
  gs_fieldcat-seltext_l      = 'Error Message'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname      = 'S_MSG'.
  gs_fieldcat-seltext_l      = 'Success Message'.
  gs_fieldcat-ref_tabname    = 'IT_FINAL'.
  APPEND gs_fieldcat TO lt_fieldcat.
  CLEAR gs_fieldcat.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid         " Name of the calling program
      i_callback_user_command  = 'USER_COMMAND_SCR2'            " EXIT routine for command handling
      i_callback_pf_status_set = 'GUI_STAT'
      is_layout                = wa_layout    " List layout specifications
*     I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
      it_fieldcat              = lt_fieldcat      " Field catalog with field descriptions
      i_default                = 'X'              " I nitial variant active/inactive logic
      i_save                   = 'A'              " Variants can be saved
    TABLES
      t_outtab                 = it_final                 " Table with data to be displayed
    EXCEPTIONS
      program_error            = 1                " Program errors
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  SET PF-STATUS 'ZGUI_9001'.
  SET TITLEBAR 'TITLE1'.
  CLEAR :gv_subrc.

  IF grid1 IS NOT INITIAL .
    CALL METHOD grid1->free.
    CALL METHOD container1->free.
    CLEAR: grid1, container1.
    REFRESH gt_errorcat[] .
  ENDIF.

  IF container1 IS NOT BOUND.
    CREATE OBJECT container1
      EXPORTING
        container_name = 'MYCONTAINER1'.
    CREATE OBJECT grid1
      EXPORTING
        i_parent = container1.
    PERFORM exclude_tb_functions CHANGING gt_exclude.
    PERFORM prepare_fcat1.
    PERFORM display_data_scr4.
  ELSE.
    IF it_return IS NOT INITIAL.
      IF grid1 IS BOUND.
        DATA: is_stable1 TYPE lvc_s_stbl, lv_lines1 TYPE int2.
        is_stable = 'XX'.
        IF grid1 IS BOUND.
          CALL METHOD grid1->refresh_table_display
            EXPORTING
              is_stable = is_stable               " With Stable Rows/Columns
            EXCEPTIONS
              finished  = 1                       " Display was Ended (by Export)
              OTHERS    = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form PREPARE_FCAT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_fcat1 .

  IF it_return IS NOT INITIAL AND gt_errorcat IS INITIAL.

    REFRESH : it_error .
    LOOP AT it_return ASSIGNING FIELD-SYMBOL(<ls_error>).


*      WA_ERROR-FIELD      = <LS_ERROR>-FIELD .
*      WA_ERROR-ID         = <LS_ERROR>-ID .
*      WA_ERROR-LOG_MSG_NO = <LS_ERROR>-LOG_MSG_NO .
*      WA_ERROR-LOG_NO     = <LS_ERROR>-LOG_NO .
      wa_error-message    = <ls_error>-message .
*      WA_ERROR-MESSAGE_V1 = <LS_ERROR>-MESSAGE_V1 .
*      WA_ERROR-MESSAGE_V2 = <LS_ERROR>-MESSAGE_V2 .
*      WA_ERROR-MESSAGE_V3 = <LS_ERROR>-MESSAGE_V3 .
*      WA_ERROR-MESSAGE_V4 = <LS_ERROR>-MESSAGE_V4 .
*      WA_ERROR-NUMBER     = <LS_ERROR>-NUMBER .
*      WA_ERROR-PARAMETER  = <LS_ERROR>-PARAMETER .
*      WA_ERROR-ROW        = <LS_ERROR>-ROW .
*      WA_ERROR-SYSTEM     = <LS_ERROR>-SYSTEM .
      wa_error-type       = <ls_error>-type .

      APPEND wa_error TO it_error .
      CLEAR : wa_error .
    ENDLOOP.

  ENDIF.

  REFRESH gt_errorcat.

*  GS_ERRORCAT-FIELDNAME      = 'FIELD'.
*  GS_ERRORCAT-REPTEXT      = 'Field'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*
*
*  GS_ERRORCAT-FIELDNAME      = 'ID'.
*  GS_ERRORCAT-REPTEXT      = 'Id'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*
*  GS_ERRORCAT-FIELDNAME      = 'LOG_MSG_NO'.
*  GS_ERRORCAT-REPTEXT      = 'Log Message Num'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'LOG_NO'.
*  GS_ERRORCAT-REPTEXT      = 'Log Num'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
  gs_errorcat-fieldname      = 'TYPE'.
  gs_errorcat-reptext      = 'Type'.
  gs_errorcat-col_opt     = 'X'.
  gs_errorcat-txt_field   = 'X'.
  APPEND gs_errorcat TO gt_errorcat.
  CLEAR gs_errorcat.

  gs_errorcat-fieldname      = 'MESSAGE'.
  gs_errorcat-reptext      = 'Message'.
  gs_errorcat-col_opt     = 'X'.
  gs_errorcat-txt_field   = 'X'.
  APPEND gs_errorcat TO gt_errorcat.
  CLEAR gs_errorcat.

*  GS_ERRORCAT-FIELDNAME      = 'MESSAGE_V2'.
*  GS_ERRORCAT-REPTEXT      = 'MESSAGE2'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'MESSAGE_V3'.
*  GS_ERRORCAT-REPTEXT      = 'MESSAGE3'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'MESSAGE_V4'.
*  GS_ERRORCAT-REPTEXT      = 'MESSAGE4'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'NUMBER'.
*  GS_ERRORCAT-REPTEXT      = 'Number'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'PARAMETER'.
*  GS_ERRORCAT-REPTEXT      = 'Parameter'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'ROW'.
*  GS_ERRORCAT-REPTEXT      = 'Row'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'SYSTEM'.
*  GS_ERRORCAT-REPTEXT      = 'System'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.











ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA_SCR4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data_scr4 .


  CALL METHOD grid1->set_table_for_first_display
    EXPORTING
      is_layout                     = gs_layo1
      it_toolbar_excluding          = gt_exclude  " Excluded Toolbar Standard Functions
    CHANGING
      it_outtab                     = it_error
      it_fieldcatalog               = gt_errorcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.



  CASE ok_code.
    WHEN 'BACK_9001' OR 'EXIT_9001' OR 'CAN_9001'.
      LEAVE TO SCREEN 0.
  ENDCASE.

*  BREAK BREDDY .

ENDMODULE.
