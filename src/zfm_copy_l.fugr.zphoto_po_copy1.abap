FUNCTION ZPHOTO_PO_COPY1.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_HEADER_TT) TYPE  ZPH_HED_TT
*"  EXPORTING
*"     VALUE(HEADER_RETURN) TYPE  ZHED_ES
*"     VALUE(ITEM_RETURN) TYPE  ZITEM_ES
*"  TABLES
*"      PH_ITEM STRUCTURE  ZPH_ITEM
*"--------------------------------------------------------------------
**&---------------------------------------------------------------------*
**& TC      : Bhabani
**& FC      : Praveen
**& Purpose : RFC For Photo App
**& Date    : 18.10.2019
**&---------------------------------------------------------------------*
**"----------------------------------------------------------------------
*  TABLES :  MARA .
*  SELECT-OPTIONS : S_SIZE FOR MARA-SIZE1 NO-DISPLAY.
  DATA : it_header  TYPE TABLE OF zph_hed,
         wa_header  TYPE  zph_hed,
         it_item    TYPE TABLE OF zph_item,
         lt_item    TYPE TABLE OF zph_item,
         wa_item    TYPE  zph_item,
         it_ph_hdr  TYPE TABLE OF zph_t_hdr,
         wa_ph_hdr  TYPE  zph_t_hdr,
         it_ph_item TYPE TABLE OF zph_t_item,
         wa_ph_item TYPE  zph_t_item,
         sl_no(05)  TYPE  i.

  DATA : lv_he TYPE zemsg,
         lv_ie TYPE zemsg.

  CONSTANTS: c_e(1)               VALUE 'E',
             c_x(1)               VALUE 'X',
             c_zds1(4)            VALUE 'ZDS1',
             c_zds2(4)            VALUE 'ZDS2',
             c_zds3(4)            VALUE 'ZDS3',
             c_zfrb(4)            VALUE 'ZFRB',
             c_zzgroup_margin(14) VALUE 'ZZGROUP_MARGIN'.


  READ TABLE im_header_tt INTO wa_header INDEX 1.
  IF sy-subrc  = 0.
***Start of Changes by Suri : 07.06.2020 : For End Catergory RFC
    IF wa_header-category_type <> c_e.

*    SELECT SINGLE
*      KLAH~CLASS FROM KLAH  INTO @DATA(LV_GROUP)
**                 FOR ALL ENTRIES IN @ph_hdr
*                 WHERE CLASS = @WA_HEADER-GROUP.

*CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*  EXPORTING
*    INPUT         = WA_HEADER-VENDOR
* IMPORTING
*   OUTPUT        = WA_HEADER-VENDOR
*          .

*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          INPUT         = WA_HEADER-VENDOR
*       IMPORTING
*         OUTPUT        = WA_HEADER-VENDOR
*                .
      IF wa_header-vendor IS NOT INITIAL.
*      IF WA_LFA1-LIFNR IS NOT INITIAL.
        DATA : lv_lifnr TYPE lifnr.
        lv_lifnr = wa_header-vendor+0(10).
        lv_lifnr = |{ lv_lifnr ALPHA = IN }|.
        SELECT SINGLE
          lfa1~lifnr,
          lfa1~name1,
          lfa1~adrnr
           FROM lfa1 INTO @DATA(wa_vendor)
                     WHERE lifnr = @lv_lifnr.
      ENDIF .

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          INPUT         = WA_VENDOR
*       IMPORTING
*         OUTPUT        = WA_VENDOR
*                .

      IF wa_vendor IS NOT INITIAL.
        SELECT SINGLE
           adrc~addrnumber ,
           adrc~city1 FROM adrc INTO @DATA(wa_city)
                      WHERE addrnumber = @wa_vendor-adrnr .

      ENDIF.
*
*    IF  PH_ITEM IS NOT INITIAL .
      SELECT
        t023~matkl
         FROM t023 INTO TABLE @DATA(it_t023)
                   FOR ALL ENTRIES IN @ph_item
                   WHERE matkl = @ph_item-category_code .
*                   AND   MATNR = @PH_ITEM-MATNR.
*    ENDIF .


      IF wa_header-delivery_at IS NOT INITIAL .
        SELECT SINGLE
          t001w~werks FROM t001w INTO @DATA(wa_plant)
                      WHERE werks = @wa_header-delivery_at .

      ENDIF.
      SELECT SINGLE
        t024~ekgrp FROM t024 INTO @DATA(p_group)
                   WHERE ekgrp = @wa_header-pur_group .

      wa_ph_hdr-indent_no       = wa_header-indent_no .            ""Indent Number
      wa_ph_hdr-pdate           = wa_header-date .                 ""Date
      wa_ph_hdr-sup_sal_no      = wa_header-sup_sal_no .           ""Supervisor Salary number
      wa_ph_hdr-sup_name        = wa_header-sup_name .             ""Supervisor Name
      wa_ph_hdr-freight_charges = wa_header-freight_charges .      " Fright Charges   : Added by Suri : 26.03.2020 : 11:28:00


      IF p_group IS NOT INITIAL.
        wa_ph_hdr-pur_group       = wa_header-pur_group .
      ENDIF.


      IF wa_vendor IS NOT INITIAL.
        wa_ph_hdr-vendor          = wa_header-vendor .               ""Vendor Code
        wa_ph_hdr-vendor_name     = wa_vendor-name1 .          ""Vendor Name
      ENDIF.

      IF wa_city IS NOT INITIAL.
        wa_ph_hdr-vendor_location = wa_city-city1 .       ""Vendor Location
      ENDIF.

*    IF LV_GROUP IS NOT INITIAL.
      wa_ph_hdr-pgroup     = wa_header-group .
*    ENDIF.

      IF wa_plant IS NOT INITIAL.
        wa_ph_hdr-delivery_at     = wa_header-delivery_at.           ""Delivery Location
      ENDIF.

      IF wa_vendor IS INITIAL AND  wa_plant IS NOT INITIAL AND p_group IS NOT INITIAL .
*      WA_PH_HDR-VENDOR          = WA_VENDOR-LIFNR.
        wa_ph_hdr-vendor          = wa_header-vendor .                 ""Vendor Code
        wa_ph_hdr-vendor_name     = wa_vendor-name1 .          ""Vendor Name
        wa_ph_hdr-e_msg           = 'Vendor is not exist' .
      ELSEIF wa_vendor IS NOT INITIAL  AND wa_plant IS INITIAL AND p_group IS NOT INITIAL.
        wa_ph_hdr-delivery_at     = wa_header-delivery_at.
        wa_ph_hdr-e_msg           = 'Plant is not exist' .
      ELSEIF wa_vendor IS NOT INITIAL AND  wa_plant IS NOT INITIAL AND p_group IS  INITIAL.
        wa_ph_hdr-vendor          = wa_header-vendor .                 ""Vendor Code
        wa_ph_hdr-vendor_name     = wa_vendor-name1 .          ""Vendor Name
        wa_ph_hdr-pgroup          = wa_header-group  .
        wa_ph_hdr-e_msg           = 'Purchase group is not exist' .
      ELSEIF wa_vendor IS  INITIAL  AND wa_plant IS  INITIAL AND p_group IS NOT INITIAL.
        wa_ph_hdr-vendor          = wa_header-vendor .                 ""Vendor Code
        wa_ph_hdr-vendor_name     = wa_vendor-name1 .          ""Vendor Name
        wa_ph_hdr-delivery_at     = wa_header-delivery_at.
        wa_ph_hdr-e_msg           = 'Vendor and Plant does not exist' .
      ELSEIF wa_vendor IS  NOT INITIAL  AND wa_plant IS  INITIAL AND p_group IS INITIAL.
        wa_ph_hdr-delivery_at     = wa_header-delivery_at.
        wa_ph_hdr-pgroup          = wa_header-group  .
        wa_ph_hdr-e_msg           = 'Plant and Purchase group does not exist' .
      ELSEIF wa_vendor IS  INITIAL  AND wa_plant IS NOT INITIAL AND p_group IS INITIAL.
        wa_ph_hdr-delivery_at     = wa_header-delivery_at.
        wa_ph_hdr-pgroup          = wa_header-group  .
        wa_ph_hdr-e_msg           = 'Vendor and Purchase group does not exist' .
      ELSEIF wa_vendor IS INITIAL  AND wa_plant IS  INITIAL  AND p_group IS  INITIAL.
        wa_ph_hdr-vendor          = wa_header-vendor .               ""Vendor Code
        wa_ph_hdr-vendor_name     = wa_vendor-name1 .          ""Vendor Name
        wa_ph_hdr-pgroup          = wa_header-group .
        wa_ph_hdr-delivery_at     = wa_header-delivery_at.
        wa_ph_hdr-e_msg           = 'Vendor and Group and Plant does not exist and Purchase group does not exist ' .
      ELSEIF wa_vendor IS NOT INITIAL AND wa_plant IS NOT INITIAL AND p_group IS  NOT INITIAL.
        wa_ph_hdr-s_msg = 'Data Successfully Saved'.

      ELSEIF wa_vendor IS NOT INITIAL AND  wa_plant IS NOT INITIAL  AND p_group IS  INITIAL.
        wa_ph_hdr-pur_group         = wa_header-pur_group.               ""Vendor Code
        wa_ph_hdr-e_msg           = 'Purchase group is not exist ' .

      ELSEIF wa_vendor IS  INITIAL AND  wa_plant IS NOT INITIAL  AND p_group IS  INITIAL.
        wa_ph_hdr-pur_group         = wa_header-pur_group.               ""Vendor Code
        wa_ph_hdr-e_msg           = 'Purchase group and Vendor does not exist ' .

      ELSEIF wa_vendor IS  INITIAL  AND wa_plant IS NOT INITIAL  AND p_group IS  INITIAL.
        wa_ph_hdr-pur_group         = wa_header-pur_group.               ""Vendor Code
        wa_ph_hdr-e_msg           = 'Purchase group , Vendor and Group does not exist ' .

      ELSEIF wa_vendor IS  INITIAL  AND wa_plant IS  INITIAL  AND p_group IS  INITIAL.
        wa_ph_hdr-pur_group         = wa_header-pur_group.               ""Vendor Code
        wa_ph_hdr-e_msg           = 'Purchase group , Vendor and Plant does not exist ' .
      ENDIF.

      wa_ph_hdr-lead_time       = wa_header-lead_time.             ""Lead time
      wa_ph_hdr-transporter     = wa_header-transporter.

      lv_he   = wa_ph_hdr-e_msg .

      IF wa_ph_hdr-e_msg IS NOT INITIAL.

        header_return-error_message = wa_ph_hdr-e_msg .

      ELSEIF wa_ph_hdr-s_msg IS NOT INITIAL .
        header_return-success_message = wa_ph_hdr-s_msg .

      ENDIF.

      APPEND wa_ph_hdr TO it_ph_hdr .
      CLEAR : wa_ph_hdr .


      SELECT
        mara~brand_id FROM mara INTO TABLE @DATA(it_brand)
                 FOR ALL ENTRIES IN @ph_item
                 WHERE matkl = @ph_item-category_code AND brand_id NE ' '.


      LOOP AT ph_item ASSIGNING FIELD-SYMBOL(<wa_item>).

        IF <wa_item>-to_size IS INITIAL.

          <wa_item>-to_size = <wa_item>-from_size .

        ENDIF .


        TRANSLATE <wa_item>-to_size TO UPPER CASE .
        TRANSLATE <wa_item>-from_size TO UPPER CASE .


*      APPEND  <WA_ITEM> TO LT_ITEM .
      ENDLOOP .

*
*    SELECT
*      MARA~MATNR,
*      MARA~MATKL,
*      MARA~SIZE1,
*      MARA~SIZE1,
*      MARA~ZZPRICE_FRM,
*      MARA~ZZPRICE_TO ,
*      MARA~MEINS     FROM MARA INTO TABLE @DATA(IT_MARA)
*                     FOR ALL ENTRIES IN @PH_ITEM
*                     WHERE MATKL = @PH_ITEM-CATEGORY_CODE
*                     AND  FROM_SIZE >= @PH_ITEM-FROM_SIZE AND  TO_SIZE <= @PH_ITEM-TO_SIZE
*                     AND ZZPRICE_FRM <= @PH_ITEM-PRICE     AND ZZPRICE_TO  >= @PH_ITEM-PRICE.
*
*    SELECT SINGLE ZITEM FROM ZSIZE_VAL INTO @DATA(GV_FROM) WHERE ZSIZE = @PH_ITEM-FROM_SIZE .
*    SELECT SINGLE ZITEM FROM ZSIZE_VAL INTO @DATA(GV_TO) WHERE ZSIZE = @PH_ITEM-TO_SIZE .
*    SELECT
*      ZSIZE_VAL~ZITEM,
*      ZSIZE_VAL~ZSIZE FROM ZSIZE_VAL INTO TABLE @DATA(IT_SIZE)
*                      WHERE ZITEM BETWEEN @GV_FROM AND @GV_TO.

***    BREAK BREDDY .

***   Start of Changes By Suri : 25.11.2019
***   For Custom logic for Size
      DATA :
        r_range TYPE RANGE OF wrf_atwrt.
      IF ph_item-from_size IS NOT INITIAL.
        SELECT * FROM zsize_val INTO TABLE @DATA(lt_size).
        READ TABLE lt_size WITH KEY zsize = ph_item-from_size TRANSPORTING NO FIELDS.
        DATA(lv_from) = sy-tabix.
        READ TABLE lt_size WITH KEY zsize = ph_item-to_size TRANSPORTING NO FIELDS.
        DATA(lv_to) = sy-tabix.
        LOOP AT lt_size ASSIGNING FIELD-SYMBOL(<ls_size>) FROM lv_from TO lv_to.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_size>-zsize ) TO r_range.
        ENDLOOP.
      ENDIF.

***   End of Changes By Suri : 25.11.2019
      IF it_brand IS  INITIAL.
        SELECT mara~matnr,
               mara~matkl,
               mara~size1,
               mara~zzprice_frm,
               mara~zzprice_to ,
               mara~meins
              INTO TABLE @DATA(lt_mara)
              FROM mara AS mara
              FOR ALL ENTRIES IN @ph_item
              WHERE mara~matkl =  @ph_item-category_code
              AND zzprice_frm <=  @ph_item-price AND zzprice_to  >=  @ph_item-price
              AND mara~size1 IN @r_range.
*
      ELSE.
*      SELECT MARA~MATNR,
*       MARA~MATKL,
*       MARA~SIZE1,
*       MARA~ZZPRICE_FRM,
*       MARA~ZZPRICE_TO ,
*       MARA~MEINS ,
*       ZSIZE_VAL~ZITEM,
*       ZSIZE_VAL~ZSIZE INTO TABLE @LT_MARA
*       FROM MARA AS MARA
*       INNER JOIN ZSIZE_VAL AS ZSIZE_VAL ON MARA~SIZE1 = ZSIZE_VAL~ZSIZE
*       FOR ALL ENTRIES IN @PH_ITEM
*       WHERE MARA~MATKL =  @PH_ITEM-CATEGORY_CODE
*       AND  ZSIZE_VAL~ZSIZE >=  @PH_ITEM-FROM_SIZE AND ZSIZE_VAL~ZSIZE <=  @PH_ITEM-TO_SIZE
*       AND  MARA~SIZE1 >=   ZSIZE_VAL~ZSIZE AND MARA~SIZE1 <=   ZSIZE_VAL~ZSIZE.
*             AND ZZPRICE_FRM <=  @PH_ITEM-PRICE     AND ZZPRICE_TO  >=  @PH_ITEM-PRICE.

        SELECT mara~matnr,
               mara~matkl,
               mara~size1,
               mara~zzprice_frm,
               mara~zzprice_to ,
               mara~meins
               INTO TABLE @lt_mara
               FROM mara AS mara
               FOR ALL ENTRIES IN @ph_item
               WHERE mara~matkl = @ph_item-category_code
               AND mara~size1 IN @r_range.
      ENDIF.
      DATA : lv_text100    TYPE ztext,
             lv_priceb(11) TYPE c.

      LOOP AT ph_item ASSIGNING FIELD-SYMBOL(<ls_item>).

        sl_no = sl_no + 10 .
        wa_ph_item-item = sl_no .
        wa_ph_item-vendor = wa_header-vendor .
        wa_ph_item-pgroup = wa_header-group.
        wa_ph_item-indent_no = wa_header-indent_no.

*      READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>) WITH KEY MATKL = <LS_ITEM>-CATEGORY_CODE . ""size1 >= <LS_ITEM>-FROM_SIZE  SIZE1 <= @<LS_ITEM>-TO_SIZE. .

        IF lt_mara IS INITIAL .
          wa_ph_item-e_msg = 'Category Code have no data in SAP' .
        ENDIF .
        READ TABLE it_t023 ASSIGNING FIELD-SYMBOL(<ls_t023>) WITH KEY matkl = <ls_item>-category_code .
        ""MATNR = <LS_ITEM>-MATNR.
        IF sy-subrc = 0.
          IF <ls_t023>-matkl IS NOT INITIAL AND lt_mara IS NOT INITIAL .
            wa_ph_item-category_code = <ls_item>-category_code .
            wa_ph_item-s_msg = 'Data Successfully Saved' .
          ELSEIF <ls_t023>-matkl IS NOT INITIAL .
            wa_ph_item-category_code = <ls_item>-category_code .
            wa_ph_item-s_msg = 'Data Successfully Saved' .
          ELSEIF <ls_t023>-matkl IS INITIAL AND lt_mara IS INITIAL .
            wa_ph_item-category_code = <ls_item>-category_code .
            wa_ph_item-e_msg = 'Please check the data for Category code' .
          ELSEIF lt_mara IS INITIAL .
            wa_ph_item-e_msg = 'Category Code doesnot exist' .
          ELSEIF <ls_t023>-matkl IS INITIAL .
            wa_ph_item-category_code = <ls_item>-category_code .
            wa_ph_item-e_msg = 'Category Code doesnot exist' .
          ENDIF.
        ENDIF.

********************      ADDED BY LIKHITHA    **************************
*       IF  WA_PH_ITEM-PRICE < WA_ITEM-PRICE ."AND WA_PH_ITEM-PRICE NE <LS_ITEM>-PRICE.
*        IF WA_PH_ITEM-PRICE > <LS_ITEM>-PRICE.
*         WA_PH_ITEM-E_MSG = 'NO DATA MAINTAIN' .
*         ENDIF.

**********************      END      **********************

        wa_ph_item-style = <ls_item>-style .
        wa_ph_item-from_size = <ls_item>-from_size .
        wa_ph_item-to_size = <ls_item>-to_size .

        IF wa_ph_item-to_size IS INITIAL.

          wa_ph_item-to_size = <ls_item>-from_size .

        ENDIF.
        wa_ph_item-color = <ls_item>-color .
        wa_ph_item-quantity = <ls_item>-quantity .

*      IF <LS_MARA>-BRAND_ID IS INITIAL.
        wa_ph_item-price = <ls_item>-price .
*      ENDIF.
*** Start of Chnages by Suri : Additional Discounts  : 26.03.2020 : 11:28:00
        wa_ph_item-discount2 = <ls_item>-discount2.
        wa_ph_item-discount3 = <ls_item>-discount3.
*** End of Chnages by Suri : Additional Discounts  : 26.03.2020 : 11:28:00
        wa_ph_item-remarks = <ls_item>-remarks .
        lv_ie = wa_ph_item-e_msg  .
        IF wa_ph_item-e_msg IS NOT INITIAL.

          item_return-error_message = wa_ph_item-e_msg .

        ELSEIF wa_ph_item-s_msg IS NOT INITIAL .
          item_return-success_message = wa_ph_item-s_msg .

        ENDIF.
        lv_priceb = wa_ph_item-price .
        CONDENSE lv_priceb .
        CONCATENATE wa_ph_item-item wa_ph_item-category_code wa_ph_item-style wa_ph_item-from_size wa_ph_item-to_size  wa_ph_item-color lv_priceb  INTO lv_text100 .
        wa_ph_item-ztext100 = lv_text100 .
        APPEND wa_ph_item TO it_ph_item .
        CLEAR : wa_ph_item , lv_priceb , lv_text100.
      ENDLOOP.


      READ TABLE it_ph_hdr  ASSIGNING FIELD-SYMBOL(<wa_ph_hed>) INDEX 1.
      IF sy-subrc = 0.
        IF lv_he IS NOT INITIAL OR lv_ie IS NOT INITIAL.
          <wa_ph_hed>-status = 'E'.
        ELSE.
          <wa_ph_hed>-status = 'S'.
        ENDIF.
        MODIFY it_ph_hdr FROM <wa_ph_hed>  TRANSPORTING status WHERE indent_no = <wa_ph_hed>-indent_no .
      ENDIF.



      IF it_ph_hdr IS NOT INITIAL.
        MODIFY zph_t_hdr FROM TABLE it_ph_hdr .
      ENDIF.

      IF it_ph_item IS NOT INITIAL.
        MODIFY zph_t_item FROM TABLE it_ph_item .
      ENDIF.
    ELSE.
*** For End Category : RFC
      DATA : lv_error(1),
             lv_count     TYPE ebelp,
             lv_text(200).

      DATA : header              LIKE bapimepoheader,
             headerx             LIKE bapimepoheaderx,
             item                TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
             ls_item             TYPE bapimepoitem,
             poschedule          TYPE TABLE OF bapimeposchedule WITH HEADER LINE,
             poschedulex         TYPE TABLE OF bapimeposchedulx WITH HEADER LINE,
             itemx               TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
             ls_itemx            TYPE bapimepoitemx,
             return              TYPE TABLE OF bapiret2,
             errorcat            TYPE TABLE OF slis_t_fieldcat_alv,
             ls_errorcat         TYPE  slis_t_fieldcat_alv,
             poservicestext      TYPE TABLE OF bapieslltx,
             potextitem          TYPE TABLE OF bapimepotext,
             ls_poservicestext   TYPE bapieslltx,
             ls_potextitem       TYPE bapimepotext,
             ls_no_price_from_po TYPE bapiflag-bapiflag,
             ls_poaccount        TYPE bapimepoaccount,
             poaccount           TYPE TABLE OF bapimepoaccount,
             ls_poaccountx       TYPE bapimepoaccountx,
             poaccountx          TYPE TABLE OF bapimepoaccountx,
             pocondhdr           TYPE TABLE OF bapimepocondheader,
             pocondhdrx          TYPE TABLE OF bapimepocondheaderx,
             pocond              TYPE TABLE OF bapimepocond WITH HEADER LINE,
             ls_pocond           TYPE bapimepocond,
             pocondx             TYPE TABLE OF bapimepocondx WITH HEADER LINE,
             ls_pocondx          TYPE  bapimepocondx,
             extensionin         TYPE TABLE OF bapiparex,
             wa_extensionin      TYPE  bapiparex,
             bapi_te_po          TYPE bapi_te_mepoheader,
             bapi_te_pox         TYPE bapi_te_mepoheaderx,
             bapi_te_poitem      TYPE bapi_te_mepoitem,
             bapi_te_poitemx     TYPE bapi_te_mepoitemx.


***  Validations
***  Indent
      SELECT SINGLE ebeln INTO @DATA(lv_ebeln) FROM ekko WHERE zindent = @wa_header-indent_no.
      IF sy-subrc = 0.
        header_return-error_message = 'Indent is already available'.
        lv_error = c_e.
        EXIT.
      ENDIF.

***  Header Data
      wa_ph_hdr-indent_no       = wa_header-indent_no.
      wa_ph_hdr-pgroup          = wa_header-pur_group.
      wa_ph_hdr-pur_group       = wa_header-pur_group.
      wa_ph_hdr-pdate           = wa_header-date.
      wa_ph_hdr-sup_sal_no      = wa_header-sup_sal_no.
      wa_ph_hdr-sup_name        = wa_header-sup_name.
      wa_ph_hdr-vendor_name     = wa_header-vendor_name.
      wa_ph_hdr-transporter     = wa_header-transporter.
      wa_ph_hdr-vendor_location = wa_header-vendor_location.
      wa_ph_hdr-delivery_at     = wa_header-delivery_at.
      wa_ph_hdr-lead_time       = wa_header-lead_time.
      wa_ph_hdr-vendor          = wa_header-vendor.

*** Vendor
      CLEAR : lv_lifnr.
      lv_lifnr = wa_header-vendor+0(10).
      lv_lifnr = |{ lv_lifnr ALPHA = IN }|.
      SELECT SINGLE lfa1~lifnr, lfa1~name1, lfa1~ort01, lfa1~regio FROM lfa1 INTO @DATA(ls_vendor) WHERE lifnr = @lv_lifnr.
      IF sy-subrc <> 0.
        header_return-error_message = 'Vendor Does not Exist'.
        lv_error = c_e.
      ENDIF.

      TRANSLATE  ls_vendor-ort01 TO UPPER CASE.
*** Bapi Header Data

*** Get Groupwise Discount
      SELECT SINGLE low INTO @DATA(lv_group_margin) FROM tvarvc WHERE name = @c_zzgroup_margin AND low = @wa_header-pur_group AND sign = 'I'.
      IF sy-subrc IS INITIAL.
        SELECT SINGLE kbetr
                      FROM konp
                      INNER JOIN a924 ON konp~knumh = a924~knumh INTO @DATA(lv_discount)
                      WHERE a924~lifnr = @lv_lifnr AND a924~userf1_txt = @wa_header-pur_group
                      AND   a924~kschl = @c_zds1 AND datab LE @sy-datum AND datbi GE @sy-datum AND loevm_ko = @space.
      ENDIF.

      IF ls_vendor-ort01 = 'CHENNAI'.
        header-doc_type = 'ZLOP'.
      ELSE.
        header-doc_type = 'ZOSP'.
      ENDIF.
      headerx-doc_type = c_x .

      IF wa_header-date IS NOT INITIAL.
        header-doc_date =  wa_header-date.
      ELSE.
        header-doc_date = sy-datum .
      ENDIF.
      headerx-doc_date = c_x .

      header-comp_code    = '1000' .
      headerx-comp_code   = c_x.
      header-creat_date   = sy-datum .
      headerx-creat_date  = c_x .
      header-vendor       = lv_lifnr.
      headerx-vendor      = c_x .
      header-langu        = sy-langu.
      header-langu        = c_x .
      header-purch_org    = '1000'.
      headerx-purch_org   = c_x.
      header-pur_group    = wa_header-pur_group .
      headerx-pur_group   = c_x .

      bapi_te_po-zindent          = wa_header-indent_no.
      bapi_te_po-user_name        = wa_header-sup_name.
      APPEND VALUE #( structure  = 'BAPI_TE_MEPOHEADER' valuepart1 = bapi_te_po ) TO extensionin.
      CLEAR : bapi_te_po.
      bapi_te_pox-zindent          = c_x.
      bapi_te_pox-user_name        = c_x.
      APPEND VALUE #( structure  = 'BAPI_TE_MEPOHEADERX' valuepart1 = bapi_te_pox ) TO extensionin.
      CLEAR : bapi_te_po.

*** HSN & Tax Code
      SELECT
       a792~wkreg ,
       a792~regio ,
       a792~steuc ,
       marc~matnr ,
       konp~mwsk1
       FROM marc AS marc
       INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
       INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
       INNER JOIN konp AS konp ON konp~knumh = a792~knumh
       INTO TABLE @DATA(lt_hsn)
       FOR ALL ENTRIES IN @ph_item
       WHERE marc~matnr = @ph_item-matnr
       AND a792~regio   = @ls_vendor-regio
       AND t001w~werks  = @wa_header-delivery_at AND konp~loevm_ko = @space AND a792~datbi GE @sy-datum AND a792~datab LE @sy-datum.

*** Item Data
      CLEAR : lv_count.
      IF ph_item IS NOT INITIAL.
        LOOP AT ph_item ASSIGNING FIELD-SYMBOL(<ls_ph_item>).

          READ TABLE lt_hsn ASSIGNING FIELD-SYMBOL(<ls_hsn>) WITH KEY matnr = <ls_ph_item>-matnr.
          IF sy-subrc = 0.
***     Tax Code Validation
            lv_count = lv_count + 10.
            ls_item-quantity       = <ls_ph_item>-quantity.
            ls_itemx-quantity      = c_x .
            ls_item-plant          = wa_header-delivery_at.
            ls_itemx-plant         = c_x .
            ls_item-stge_loc       = 'FG01' .
            ls_itemx-stge_loc      = c_x .
            ls_item-net_price      = <ls_ph_item>-price.
            ls_itemx-net_price     = c_x.
            ls_item-ir_ind         = c_x.
            ls_itemx-ir_ind        = c_x.
            ls_item-gr_basediv     = c_x.
            ls_itemx-gr_basediv    = c_x.
            ls_item-plan_del       = wa_header-lead_time.
            ls_itemx-plan_del      = c_x.
            ls_item-over_dlv_tol   = '10'.         " Tolerance
            ls_itemx-over_dlv_tol  = c_x.

*** Consumbales - to Cost Center
            IF wa_header-pur_group = 'P34'.
              ls_item-acctasscat   = 'K'.
              ls_itemx-acctasscat  = 'X'.
            ENDIF.

            APPEND ls_item TO item[].
            APPEND ls_itemx TO itemx[].

            APPEND VALUE #( po_item   = lv_count text_id   = 'F03' text_form = '*' text_line = <ls_ph_item>-remarks ) TO potextitem.
            APPEND VALUE #( po_item   = lv_count text_id   = 'F08' text_form = '*' text_line = <ls_ph_item>-color ) TO potextitem.
            APPEND VALUE #( po_item   = lv_count text_id   = 'F07' text_form = '*' text_line = <ls_ph_item>-style ) TO potextitem.

            lv_text =  lv_count && <ls_ph_item>-category_code && <ls_ph_item>-style && <ls_ph_item>-from_size && <ls_ph_item>-to_size  && <ls_ph_item>-color && <ls_ph_item>-price.
            CLEAR :bapi_te_poitem,bapi_te_poitemx.

***     Item extenction fields
            bapi_te_poitem-po_item    = lv_count.
            bapi_te_poitem-zztext100  = lv_text.
            bapi_te_poitem-zzremarks  = <ls_ph_item>-remarks.
            bapi_te_poitem-zzcolor    = <ls_ph_item>-color.
            bapi_te_poitem-zzstyle    = <ls_ph_item>-style.
            APPEND VALUE #( structure = 'BAPI_TE_MEPOITEM' valuepart1 = bapi_te_poitem ) TO extensionin.

***     Item extenction fields Updation Flags
            bapi_te_poitemx-po_item   = lv_count.
            bapi_te_poitemx-zztext100 = c_x.
            bapi_te_poitemx-zzremarks = c_x.
            bapi_te_poitemx-zzcolor   = c_x.
            bapi_te_poitemx-zzstyle   = c_x.
            APPEND VALUE #( structure = 'BAPI_TE_MEPOITEMX' valuepart1 = bapi_te_poitemx ) TO extensionin.

*** Conditions
            APPEND VALUE #( cond_type = 'PBXX' cond_value = <ls_ph_item>-price  / 10 itm_number = lv_count change_id = 'U'  ) TO pocond[].
            APPEND VALUE #( cond_type = c_x cond_value = c_x  itm_number = c_x change_id = c_x ) TO pocondx[].

*** Start Of Changes by Suri : For Group / Vendor level Discount : 23.03.2020 : 11.11.00
** Discount 1  : Group / Vendor level Discount
            IF lv_group_margin IS NOT INITIAL.
              APPEND VALUE #( cond_type = c_zds1 cond_value = ( lv_discount / 10 ) itm_number = lv_count change_id = 'I' ) TO pocond[] .
              APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .
            ENDIF.
*** Discount 2 in %
            APPEND VALUE #( cond_type = c_zds2 cond_value = <ls_ph_item>-discount2 itm_number = lv_count change_id = 'I' ) TO pocond[] .
            APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .

*** Discount 3 per Piece
            APPEND VALUE #( cond_type = c_zds3 cond_value = <ls_ph_item>-discount3 itm_number = lv_count change_id = 'I' ) TO pocond[] .
            APPEND VALUE #( cond_type = c_x cond_value = c_x itm_number = c_x change_id = c_x ) TO pocondx[] .

*** Freight charges
            APPEND VALUE #( cond_type = c_zfrb cond_value = wa_header-freight_charges / 10 change_id = 'I' ) TO pocond[] .
            APPEND VALUE #( cond_type = c_x cond_value = c_x change_id = c_x ) TO pocondx[] .

*** End Of Changes by Suri : For Group/ Vendor level Discount : 23.03.2020 : 11.11.00
          ELSE.
*** No Tax Code Found
          ENDIF.
        ENDLOOP.
        CALL FUNCTION 'BAPI_PO_CREATE1'
          EXPORTING
            poheader         = header
            poheaderx        = headerx
            no_price_from_po = 'X'
          IMPORTING
            exppurchaseorder = lv_ebeln
          TABLES
            return           = return[]
            poitem           = item[]
            poitemx          = itemx[]
            poaccount        = poaccount
            poaccountx       = poaccountx
            pocondheader     = pocondhdr[]
            pocondheaderx    = pocondhdrx[]
            pocond           = pocond[]
            pocondx          = pocondx[]
            extensionin      = extensionin[]
            potextitem       = potextitem[].
      ELSE.
        wa_ph_hdr-e_msg  = 'No items Found'.
      ENDIF.
    ENDIF .
  ENDIF .

ENDFUNCTION.
