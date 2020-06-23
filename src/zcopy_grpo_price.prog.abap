*&---------------------------------------------------------------------*
*& Report ZMM_GRPO_PRICE_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

***********     for discount (&WA_HEADER-DIS_T)
REPORT zcopy_grpo_price.

TYPES : BEGIN OF ty_mseg,
          mblnr TYPE mblnr,
          mjahr TYPE mjahr,
          bwart TYPE bwart,
          zeile TYPE mblpo,
          lifnr TYPE elifn,
          werks TYPE werks_d,
          matnr TYPE matnr,
          menge TYPE menge_d,
          ebeln	TYPE bstnr,
          ebelp TYPE ebelp,
          charg TYPE charg_d,
        END OF ty_mseg.

TYPES : BEGIN OF ty_mkpf ,
          mblnr TYPE mblnr,
          mjahr TYPE mjahr,
          bldat TYPE bldat,
        END OF ty_mkpf.

TYPES: BEGIN OF ty_lfa1,
         lifnr TYPE lifnr,
         land1 TYPE land1_gp,
         name1 TYPE name1_gp,
         "STRAS TYPE STRAS_GP,
         "ORT01 TYPE ORT01_GP,
         stcd3 TYPE stcd3,
         regio TYPE regio,
         adrnr TYPE adrnr,
       END OF ty_lfa1.

TYPES : BEGIN OF ty_t001w,
          werks TYPE werks_d,
          name1 TYPE name1,
          stras TYPE stras,
          ort01 TYPE ort01,
          land1 TYPE land1,
        END OF ty_t001w.

TYPES: BEGIN OF ty_konv,
         knumv TYPE knumv,
         kposn TYPE kposn,
         stunr TYPE stunr,
         zaehk TYPE dzaehk,
         kschl TYPE kscha,
         kbetr TYPE kbetr,
       END OF ty_konv.

TYPES: BEGIN OF ty_ekpo,
         ebeln TYPE ebeln,                              "Purchasing Document Number
         ebelp TYPE ebelp,                              "Item Number of Purchasing Document
         werks TYPE ewerk,                              "Plant
         matnr TYPE matnr,                              "Material Number
         mwskz TYPE mwskz,                              "Tax on Sales/Purchases Code
         menge TYPE bstmg,                              "Purchase Order Quantity
         netpr TYPE bprei,                              "Net Price in Purchasing Document (in Document Currency)
         peinh TYPE epein,                              "Price unit
         netwr TYPE bwert,                              "Net Order Value in PO Currency
         bukrs TYPE bukrs,
         retpo TYPE retpo,
       END OF ty_ekpo.
TYPES : BEGIN OF ty_ekko,
          ebeln TYPE ebeln,
          knumv TYPE knumv,
          bsart TYPE bsart,
        END OF ty_ekko.

TYPES : BEGIN OF ty_t005u,
          spras TYPE spras,
          land1 TYPE land1,
          bland TYPE regio,
          bezei TYPE bezei20,
        END OF ty_t005u.

TYPES: BEGIN OF ty_makt,
         matnr TYPE matnr,
         spras TYPE spras,
         maktx TYPE maktx,
       END OF ty_makt.

TYPES : BEGIN OF ty_zinw_t_item ,
          qr_code  TYPE zqr_code,
          ebeln	   TYPE ebeln,
          ebelp	   TYPE ebelp,
*          SNO      TYPE INT2,
          matnr	   TYPE matnr,
          lgort	   TYPE lgort_d,
          werks	   TYPE ewerk,
          menge_p  TYPE zmenge_p,
          meins	   TYPE bstme,
          maktx	   TYPE maktx,
          netpr_p	 TYPE zbprei_p,
          netwr_p	 TYPE zbprei_pt,
          netpr_gp TYPE zbprei_gp,
          netpr_s  TYPE zbprei_s,
          menge    TYPE bstmg,
          margn    TYPE zmargn,
        END OF ty_zinw_t_item ,
        BEGIN OF ty_prcd,
          knumv TYPE  prcd_elements-knumv,
          kposn TYPE  prcd_elements-kposn,
          kschl TYPE  prcd_elements-kschl,
          knumh TYPE  prcd_elements-knumh,
          kbetr TYPE  prcd_elements-kbetr,
          kwert TYPE  prcd_elements-kwert,
        END OF ty_prcd.

DATA: it_lfa1         TYPE TABLE OF  ty_lfa1,
      wa_lfa1         TYPE  ty_lfa1,
      it_t001w        TYPE TABLE OF ty_t001w,
      wa_t001w        TYPE  ty_t001w,
      it_konv         TYPE TABLE OF  ty_konv,
      it_mseg         TYPE TABLE OF  ty_mseg,
      it_mseg1        TYPE TABLE OF  ty_mseg,
      it_zinw_t_item1 TYPE TABLE OF ty_zinw_t_item,
      wa_zinw_t_item1 TYPE  ty_zinw_t_item,
      wa_konv         TYPE  ty_konv,
      wa_mseg1        TYPE  ty_mseg,
      it_ekpo         TYPE TABLE OF  ty_ekpo,
      it_ekpo1        TYPE TABLE OF  ty_ekpo,
      wa_ekpo         TYPE   ty_ekpo,
      wa_ekpo1        TYPE   ty_ekpo,
      it_ekko         TYPE TABLE OF  ty_ekko,
      wa_ekko         TYPE  ty_ekko,
      it_ekko1         TYPE TABLE OF  ty_ekko,
      wa_ekko1         TYPE  ty_ekko,
      it_makt         TYPE TABLE OF  ty_makt,
      it_makt1        TYPE TABLE OF  ty_makt,
      wa_makt         TYPE  ty_makt,
      wa_makt1        TYPE  ty_makt,
      wa_t005u        TYPE  ty_t005u.

*      it_prcd TYPE TABLE OF ty_prcd,
*      wa_prcd TYPE ty_prcd.

DATA : it_zinw_t_hdr  TYPE TABLE OF zinw_t_hdr,
       wa_zinw_t_hdr  TYPE zinw_t_hdr,
       it_zinw_t_item TYPE TABLE OF zinw_t_item,
       wa_zinw_t_item TYPE zinw_t_item.
DATA : wa_header TYPE  zgrpo_h_price,
       it_final  TYPE TABLE OF zgrpo_i_price,
       wa_final  TYPE  zgrpo_i_price.

DATA : lv_slno TYPE  i,
       lv1     TYPE  string,
       lva     TYPE  string,
       lvb     TYPE  string,
       lvc     TYPE  string,
       lv2     TYPE  string,
       lv3     TYPE  string.
DATA : lv_heading(30) TYPE c,
       lv_hed(15)     TYPE c,
       lv_val(15)     TYPE c,
       lv_per         TYPE kbetr,
       lv_per1        TYPE kbetr,
       lv_s(01)       TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETER : p_qr TYPE zqr_code.
SELECTION-SCREEN : END OF BLOCK b1.

PERFORM grpo_price_form USING p_qr.
*&---------------------------------------------------------------------*
*& Form GRPO_PRICE_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_QR
*&---------------------------------------------------------------------*
FORM grpo_price_form  USING p_qr.

  IF p_qr IS NOT INITIAL.
    SELECT * FROM zinw_t_hdr INTO TABLE it_zinw_t_hdr
             WHERE qr_code = p_qr
             AND status GE '04'.
  ENDIF.

  READ TABLE  it_zinw_t_hdr INTO wa_zinw_t_hdr INDEX 1.

  IF wa_zinw_t_hdr IS NOT INITIAL .
    SELECT * FROM zinw_t_item INTO TABLE it_zinw_t_item
                              WHERE qr_code = wa_zinw_t_hdr-qr_code.
  ENDIF.

  IF it_zinw_t_hdr IS NOT INITIAL .

    SELECT
    mkpf~mblnr ,
    mkpf~mjahr ,
    mkpf~bldat FROM mkpf INTO TABLE @DATA(it_mkpf)
               FOR ALL ENTRIES IN @it_zinw_t_hdr
               WHERE mblnr = @it_zinw_t_hdr-mblnr OR mblnr = @it_zinw_t_hdr-mblnr_103.

    SELECT * FROM zinw_t_status INTO TABLE @DATA(it_zinw_t_status)
                                FOR ALL ENTRIES IN @it_zinw_t_hdr
                                WHERE qr_code = @it_zinw_t_hdr-qr_code.
  ENDIF.
  IF it_mkpf IS NOT INITIAL.
    SELECT
      mblnr
      mjahr
      bwart
      zeile
      lifnr
      werks
      matnr
      menge
      ebeln
      ebelp
      charg
      FROM mseg INTO TABLE it_mseg
      FOR ALL ENTRIES IN it_mkpf
      WHERE mblnr = it_mkpf-mblnr .
  ENDIF.


  IF it_zinw_t_item IS NOT INITIAL.
    SELECT
    ebeln
    ebelp
    werks
    matnr
    mwskz
    menge
    netpr
    peinh
    netwr
    bukrs
    retpo
    FROM ekpo INTO TABLE it_ekpo
              FOR ALL ENTRIES IN it_zinw_t_item
              WHERE ebeln = it_zinw_t_item-ebeln
              AND matnr = it_zinw_t_item-matnr
              AND ebelp = it_zinw_t_item-ebelp.

    SELECT
      mara~matnr,
      mara~ean11 FROM mara INTO TABLE @DATA(it_mara)
                 FOR ALL ENTRIES IN @it_zinw_t_item
                 WHERE matnr = @it_zinw_t_item-matnr.
  ENDIF.

  IF it_ekpo IS NOT INITIAL.

    SELECT * FROM a003 INTO TABLE @DATA(it_a003)
             FOR ALL ENTRIES IN @it_ekpo
             WHERE mwskz = @it_ekpo-mwskz.

  ENDIF.

  IF it_a003 IS NOT INITIAL.

    SELECT * FROM konp INTO TABLE @DATA(it_konp)
             FOR ALL ENTRIES IN @it_a003
             WHERE knumh = @it_a003-knumh.

  ENDIF.

  READ TABLE it_zinw_t_item INTO wa_zinw_t_item INDEX 1 .
  IF wa_zinw_t_hdr IS NOT INITIAL.
    SELECT SINGLE lifnr
                  land1
                  name1
                  stcd3
                  regio
                  adrnr FROM lfa1 INTO wa_lfa1
                        WHERE lifnr = wa_zinw_t_hdr-lifnr.
  ENDIF.

  IF wa_lfa1 IS NOT INITIAL.

    SELECT SINGLE adrc~addrnumber,
                 adrc~city1,
                 adrc~post_code1,
                 adrc~street,
                 adrc~house_num1,
                 adrc~str_suppl1,
                 adrc~str_suppl2,
                 adrc~str_suppl3 FROM adrc INTO @DATA(wa_adrc) WHERE addrnumber =  @wa_lfa1-adrnr.

  ENDIF.
  IF wa_zinw_t_item  IS NOT INITIAL .
    SELECT SINGLE  werks
                   name1
                   stras
                   ort01
                   land1  FROM t001w INTO wa_t001w
                   WHERE werks = wa_zinw_t_item-werks.



  ENDIF.
  IF it_zinw_t_item IS NOT INITIAL .
    SELECT matnr
         spras
         maktx FROM makt INTO TABLE it_makt
         FOR ALL ENTRIES IN it_zinw_t_item
         WHERE matnr = it_zinw_t_item-matnr.       "#EC CI_NO_TRANSFORM
  ENDIF .
  IF wa_lfa1 IS NOT INITIAL .
    SELECT SINGLE spras
                  land1
                  bland
                  bezei FROM t005u INTO wa_t005u
                  WHERE spras = 'EN'
                  AND  land1 = wa_lfa1-land1
                  AND bland = wa_lfa1-regio.

    SELECT SINGLE * FROM t005t INTO @DATA(wa_t005t)
             WHERE spras = @sy-langu
             AND   land1 = @wa_lfa1-land1.
  ENDIF.

  IF it_zinw_t_item IS NOT INITIAL.
    SELECT  ebeln
            knumv
            bsart FROM ekko INTO TABLE it_ekko
            FOR ALL ENTRIES IN  it_zinw_t_item
            WHERE ebeln = it_zinw_t_item-ebeln .


  ENDIF.

***********************  ADDED ON(18-20-20)     ************************
  SELECT prcd_elements~knumv,
         prcd_elements~kposn,
         prcd_elements~kschl,
         prcd_elements~knumh,
         prcd_elements~kbetr,
         prcd_elements~kwert
    FROM prcd_elements INTO TABLE @DATA(it_prcd)
         FOR ALL ENTRIES IN @it_ekko
         WHERE knumv = @it_ekko-knumv AND kschl in ('ZDS1' , 'ZDS2' ,'ZDS3' ,'ZFRB').

********************  END(18-20-20)   ***********************

  IF it_ekko IS NOT INITIAL.
    SELECT knumv
           kposn
           stunr
           zaehk
           kschl
           kbetr FROM konv INTO TABLE it_konv
           FOR ALL ENTRIES IN it_ekko
           WHERE knumv = it_ekko-knumv.            "#EC CI_NO_TRANSFORM
  ENDIF.
************for local po**************
  IF wa_zinw_t_hdr IS NOT INITIAL .
    SELECT
      mblnr
      mjahr
      bwart
      zeile
      lifnr
      werks
      matnr
      menge
      ebeln
      ebelp
      charg FROM mseg INTO TABLE it_mseg1
            WHERE mblnr = wa_zinw_t_hdr-mblnr
            AND bwart in ( '109' , '101' ).       " added 107 on (28-2-20)
  ENDIF .
  IF it_mseg1 IS NOT INITIAL.
    SELECT
    ebeln
    ebelp
    werks
    matnr
    mwskz
    menge
    netpr
    peinh
    netwr
    bukrs
    retpo
    FROM ekpo INTO TABLE it_ekpo1
              FOR ALL ENTRIES IN it_mseg1
              WHERE ebeln = it_mseg1-ebeln
              AND matnr = it_mseg1-matnr
              AND ebelp = it_mseg1-ebelp.
  ENDIF .
  IF it_mseg IS NOT INITIAL .
    SELECT
      qr_code
      ebeln
      ebelp
      matnr
      lgort
      werks
      menge_p
      meins
      maktx
      netpr_p
      netwr_p
      netpr_gp
      netpr_s
      menge
      margn  FROM zinw_t_item INTO TABLE it_zinw_t_item1
           FOR ALL ENTRIES IN it_mseg
           WHERE ebeln = it_mseg-ebeln
           AND    ebelp = it_mseg-ebelp AND qr_code = p_qr.

  ENDIF.

  IF it_zinw_t_item1 IS NOT INITIAL.
    SELECT  ebeln
            knumv
            bsart FROM ekko INTO TABLE it_ekko1
            FOR ALL ENTRIES IN  it_zinw_t_item1
            WHERE ebeln = it_zinw_t_item1-ebeln .


  ENDIF.

***********************  ADDED ON(18-20-20)     ************************
  SELECT prcd_elements~knumv,
         prcd_elements~kposn,
         prcd_elements~kschl,
         prcd_elements~knumh,
         prcd_elements~kbetr,
         prcd_elements~kwert
    FROM prcd_elements INTO TABLE @DATA(it_prcd1)
         FOR ALL ENTRIES IN @it_ekko1
         WHERE knumv = @it_ekko1-knumv AND kschl in ('ZDS1' , 'ZDS2' ,'ZDS3' ,'ZFRB').



  IF it_ekpo1 IS NOT INITIAL.
    SELECT matnr
           spras
           maktx FROM makt INTO TABLE it_makt1
           FOR ALL ENTRIES IN it_ekpo1
           WHERE matnr = it_ekpo1-matnr.

    SELECT
    mara~matnr,
    mara~ean11 FROM mara INTO TABLE @DATA(it_mara1)
               FOR ALL ENTRIES IN @it_ekpo1
               WHERE matnr = @it_ekpo1-matnr.

    SELECT * FROM a003 INTO TABLE @DATA(it_a0031)
     FOR ALL ENTRIES IN @it_ekpo1
     WHERE mwskz = @it_ekpo1-mwskz.

  ENDIF.

  IF it_a0031 IS NOT INITIAL.

    SELECT * FROM konp INTO TABLE @DATA(it_konp1)
             FOR ALL ENTRIES IN @it_a0031
             WHERE knumh = @it_a0031-knumh.

  ENDIF.
****************************************

SELECT a~matnr,
       b~kbetr,
       a~knumh INTO TABLE @DATA(it_data)
       FROM  a515 AS a
       INNER JOIN konp AS b ON a~knumh = b~knumh
       FOR ALL ENTRIES IN @it_zinw_t_item
       WHERE a~matnr = @it_zinw_t_item-matnr
       AND   a~kschl = 'ZMRP'.


*    IF it_zinw_t_item1 IS NOT INITIAL.
*    SELECT  ebeln
*            knumv
*            bsart FROM ekko INTO TABLE it_ekko1
*            FOR ALL ENTRIES IN  it_zinw_t_item1
*            WHERE ebeln = it_zinw_t_item1-ebeln .
*
*
*  ENDIF.
*
************************  ADDED ON(18-20-20)     ************************
*  SELECT prcd_elements~knumv,
*         prcd_elements~kposn,
*         prcd_elements~kschl,
*         prcd_elements~knumh,
*         prcd_elements~kbetr,
*         prcd_elements~kwert
*    FROM prcd_elements INTO TABLE @DATA(it_prcd1)
*         FOR ALL ENTRIES IN @it_ekko1
*         WHERE knumv = @it_ekko1-knumv AND kschl in ('ZDS1' , 'ZDS2' ,'ZDS3' ,'ZFRB').


*break breddy.
* WA_HEADER-V_LAND1  =   WA_LFA1-LAND1 .
  wa_header-v_name1    =   wa_zinw_t_hdr-name1 .
*WA_HEADER-V_STRAS   =   WA_LFA1-STRAS .
  wa_header-city1      =   wa_adrc-city1.
  wa_header-post_code1 =   wa_adrc-post_code1.
  wa_header-street     =   wa_adrc-street.
  wa_header-house_num1 =   wa_adrc-house_num1.
  wa_header-str_suppl1 =   wa_adrc-str_suppl1.
  wa_header-str_suppl2 =   wa_adrc-str_suppl2.
  wa_header-str_suppl3 =   wa_adrc-str_suppl3.
  wa_header-landx      =   wa_t005t-landx .
  wa_header-v_stcd3    =   wa_lfa1-stcd3 .
  wa_header-v_regio    =   wa_t005u-bezei.
*WA_HEADER-NAME1 = WA_T001W-NAME1 .
*WA_HEADER-STRAS = WA_T001W-STRAS .
*WA_HEADER-ORT01 = WA_T001W-ORT01 .
*WA_HEADER-LAND1 = WA_T001W-LAND1 .
*  WA_HEADER-GRPO_NO   = WA_ZINW_T_HDR-GRPO_NO .
*  WA_HEADER-GRPO_DT = WA_ZINW_T_HDR-GRPO_DATE .
  wa_header-lifnr     = wa_zinw_t_hdr-lifnr .
  wa_header-bill_num  = wa_zinw_t_hdr-bill_num .
  wa_header-bill_date = wa_zinw_t_hdr-bill_date.
  wa_header-lr_no     = wa_zinw_t_hdr-lr_no .
  READ TABLE it_zinw_t_status ASSIGNING FIELD-SYMBOL(<wa_status>) WITH KEY qr_code = wa_zinw_t_hdr-qr_code .
  IF sy-subrc = 0 .
    wa_header-gpro_by   = <wa_status>-created_by .
  ENDIF.

  wa_header-discount  = wa_zinw_t_hdr-discount .
  wa_header-doc_no    = wa_zinw_t_hdr-mblnr .

  REFRESH : it_final.
  DATA : lv_tax TYPE konp-kbetr.
  READ TABLE it_ekko INTO wa_ekko INDEX 1.
  IF wa_ekko-bsart = 'ZLOP'.
    CLEAR : lv_slno .

    LOOP AT it_mseg1 INTO wa_mseg1
       WHERE mblnr = wa_zinw_t_hdr-mblnr." AND bwart = '109' .   " commented (bwart = '109'. on (28-2-20)

      lv_slno = lv_slno + 1.
      wa_final-slno = lv_slno .
      wa_final-qty  = wa_mseg1-menge.
      wa_header-qtyt = wa_header-qtyt  + wa_final-qty.      " COMMENTED ON (9-2-20)
      wa_final-b_code =  wa_mseg1-charg .
      wa_final-whs =  wa_mseg1-werks .

      READ TABLE it_zinw_t_item1 INTO wa_zinw_t_item1 WITH KEY ebeln = wa_mseg1-ebeln ebelp = wa_mseg1-ebelp qr_code = p_qr.
      IF sy-subrc = 0.
        wa_final-avl_qty   = wa_zinw_t_item1-menge.
        wa_header-avl_qtyt = wa_header-avl_qtyt  +  wa_final-avl_qty.
        wa_final-margn     =  wa_zinw_t_item1-margn.
        wa_final-sell_price =  wa_zinw_t_item1-netpr_s.
        wa_final-unit_price =  wa_zinw_t_item1-netpr_p.
        WA_final-itemno = wa_zinw_t_item1-EBELP.
      ENDIF.
*      WA_FINAL-S_TOTAL = WA_FINAL-SELL_PRICE *  WA_FINAL-AVL_QTY.
      wa_final-s_total = wa_final-sell_price *   wa_mseg1-menge .
      wa_header-s_total = wa_header-s_total + wa_final-s_total.
      wa_header-fright    =  wa_header-fright + wa_zinw_t_hdr-frt_amt .
      wa_final-maktx =  wa_zinw_t_item-maktx.

      READ TABLE it_ekpo1 INTO wa_ekpo1 WITH KEY ebeln = wa_mseg1-ebeln ebelp = wa_mseg1-ebelp.
*      WA_FINAL-U_TOTAL = WA_FINAL-UNIT_PRICE *  WA_FINAL-AVL_QTY.
      wa_final-u_total = wa_final-unit_price *   wa_mseg1-menge .
      wa_header-u_total = wa_header-u_total +  wa_final-u_total.
*      *      ****************      ADDED ON(18-2-20)    ***********************
*      READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd>) WITH KEY knumv = wa_ekko-knumv kposn = wa_ekpo1-ebelp kschl = 'ZDS1'.
*      IF sy-subrc = 0.
*        wa_final-kbetr =   <ls_prcd>-kbetr.
*        wa_header-dis_t = ( wa_final-u_total * wa_final-kbetr ) / 100.   " for discount
*      ENDIF.

*       READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_1>) WITH KEY KNUMV = wa_ekko-knumv kposn = WA_final-itemno kschl = 'ZDS1'.
*        IF sy-subrc = 0.
*      wa_final-kbetr =   <ls_prcd_1>-kbetr.
*      wa_final-dis_tt = ( wa_ZINW_T_ITEM-netwr_p * wa_final-kbetr ) / 100.
*      wa_header-dis_t = wa_header-dis_t +  wa_final-dis_tt.
*      WA_FINAL-ADIS = wa_ZINW_T_ITEM-netwr_p + wa_final-dis_tt.
**endif.
*        ENDIF.
*         READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_2>) WITH KEY KNUMV = wa_ekko-knumv kposn = WA_final-itemno kschl = 'ZDS2'.
*        IF sy-subrc = 0.
*         wa_final-kbetr =   <ls_prcd_2>-kbetr.
*         wa_final-dis_tt2 = ( wa_final-ADIS * wa_final-kbetr ) / 100.
*      wa_header-dis_t2 = ( wa_header-dis_t2 +  wa_final-dis_tt2 ).
*ENDIF.
*READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_3>) WITH KEY
*KNUMV = wa_ekko-knumv kposn = WA_final-itemno kschl = 'ZDS3'.
*        IF sy-subrc = 0.
*          wa_final-kbetr =   <ls_prcd_3>-kbetr.
**      wa_final-dis_tt3 = ( wa_final-dis_tt2 * wa_final-kbetr ) / 10.
*wa_final-dis_tt3 = ( WA_ZINW_T_ITEM-MENGE_P * wa_final-kbetr ).
*      wa_header-dis_t3 = wa_header-dis_t3 +  wa_final-dis_tt3.
*ENDIF.
* wa_header-N_dis =  wa_header-dis_t +
*wa_header-dis_t2  + wa_header-dis_t3 .
* wa_header-af_dis = wa_header-U_TOTAL + wa_header-N_DIS.
*
*READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_F>) WITH KEY
* KNUMV = wa_ekko-knumv kposn = WA_final-itemno kschl = 'ZFRB'.
*        IF sy-subrc = 0.
*   WA_FINAL-FRIGHT = <ls_prcd_F>-KBETR.
*          ENDIF.
*

******************      END(18-2-20)   ***************

      READ TABLE it_mara ASSIGNING FIELD-SYMBOL(<ls_mara>) WITH KEY matnr = wa_ekpo1-matnr.
      IF sy-subrc = 0.
        wa_final-ean11 = <ls_mara>-ean11.
      ENDIF.
      READ TABLE it_makt1 INTO wa_makt1 WITH KEY matnr = wa_ekpo1-matnr .
      IF sy-subrc = 0.
        wa_final-maktx = wa_makt1-maktx .
      ENDIF.

*************************************************************
    READ TABLE it_data ASSIGNING FIELD-SYMBOL(<skn>)
    WITH KEY matnr =  wa_ekpo1-matnr.
      IF sy-subrc = 0.
        wa_final-mrp = <skn>-kbetr.
      ENDIF.
*************************************************************
*      IF WA_MSEG1 IS NOT INITIAL.
      READ TABLE it_mkpf ASSIGNING FIELD-SYMBOL(<wa_mkpf>) WITH KEY mblnr = wa_zinw_t_hdr-mblnr.
      wa_header-doc_date = <wa_mkpf>-bldat .
**      ****************      ADDED ON(18-2-20)    ***********************
*       READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd>) WITH KEY KNUMV = wa_ekko-knumv kposn = WA_EKPO1-ebelp kschl = 'ZDS1'.
*        IF sy-subrc = 0.
*      wa_final-kbetr =   <ls_prcd>-kbetr.
*        ENDIF.
*
*******************      END(18-2-20)   ***************
*      ENDIF.
      READ TABLE it_ekko INTO wa_ekko WITH KEY ebeln = wa_zinw_t_item-ebeln.
      IF wa_ekko-bsart = 'ZTAT'.

        lv_heading = 'Tatkal GRPO Price Report'.

      ELSE.
        lv_heading = 'GRPO Price Report'.

      ENDIF.

***********************      added on (25-5-20),   ********************
*      *************
      READ TABLE it_ekko1 INTO wa_ekko1 WITH KEY ebeln = wa_zinw_t_item1-ebeln.
       READ TABLE it_prcd1 ASSIGNING FIELD-SYMBOL(<ls_prcd_A>) WITH KEY KNUMV = wa_ekko1-knumv kposn = WA_final-itemno kschl = 'ZDS1'.
        IF sy-subrc = 0.
      wa_final-kbetr =   <ls_prcd_A>-kbetr.
      wa_final-dis_tt = ( wa_ZINW_T_ITEM-netwr_p * wa_final-kbetr ) / 100.
      wa_header-dis_t = wa_header-dis_t +  wa_final-dis_tt.
      WA_FINAL-ADIS = wa_ZINW_T_ITEM-netwr_p + wa_final-dis_tt.
*endif.
        ENDIF.
         READ TABLE it_prcd1 ASSIGNING FIELD-SYMBOL(<ls_prcd_B>) WITH KEY KNUMV = wa_ekko1-knumv kposn = WA_final-itemno kschl = 'ZDS2'.
        IF sy-subrc = 0.
         wa_final-kbetr =   <ls_prcd_B>-kbetr.
         wa_final-dis_tt2 = ( wa_final-ADIS * wa_final-kbetr ) / 100.
      wa_header-dis_t2 = ( wa_header-dis_t2 +  wa_final-dis_tt2 ).
ENDIF.
READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_C>) WITH KEY
KNUMV = wa_ekko1-knumv kposn = WA_final-itemno kschl = 'ZDS3'.
        IF sy-subrc = 0.
          wa_final-kbetr =   <ls_prcd_C>-kbetr.
*      wa_final-dis_tt3 = ( wa_final-dis_tt2 * wa_final-kbetr ) / 10.
wa_final-dis_tt3 = ( WA_ZINW_T_ITEM-MENGE_P * wa_final-kbetr ).
      wa_header-dis_t3 = wa_header-dis_t3 +  wa_final-dis_tt3.
ENDIF.
 wa_header-N_dis =  wa_header-dis_t +
wa_header-dis_t2  + wa_header-dis_t3 .
 wa_header-af_dis = wa_header-U_TOTAL + wa_header-N_DIS.

READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_F1>) WITH KEY
 KNUMV = wa_ekko1-knumv kposn = WA_final-itemno kschl = 'ZFRB'.
        IF sy-subrc = 0.
   WA_FINAL-FRIGHT = <ls_prcd_F1>-kwert.
   wa_header-fright = wa_header-fright + wa_final-fright.
          ENDIF.
******************      end(25-5-20)  ****************
          break clikhitha.

*      READ TABLE IT_EKPO INTO WA_EKPO WITH KEY EBELN =   WA_ZINW_T_ITEM-EBELN MATNR = WA_ZINW_T_ITEM-MATNR EBELP = WA_ZINW_T_ITEM-EBELP.
      LOOP AT it_a003 ASSIGNING FIELD-SYMBOL(<wa_a0031>) WHERE mwskz = wa_ekpo1-mwskz.
        if sy-subrc = 0.    " added on (28-2-20_
        IF <wa_a0031>-kschl = 'JIIG'.
          lv_hed = 'IGST'.
*        LV_VAL = 'IGST Value'.
          READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<wa_konp1>) WITH KEY knumh = <wa_a0031>-knumh.
          IF sy-subrc = 0.
            lv_per =  <wa_konp1>-kbetr / 10   .                        """""| && | { '%' } |.
            lv_tax = ( lv_per * wa_ekpo1-netwr ) / 100.
*            LV_TAX = ( LV_PER * WA_ZINW_T_ITEM-NETWR_P ) / 100.
*            ADD LV_TAX TO WA_FINAL-NETPR_GP.
            wa_final-netpr_gp = lv_tax .
            wa_header-netpr_t = wa_header-netpr_t + wa_final-netpr_gp .
*            EXIT.
          ENDIF.
        ELSEIF <wa_a0031>-kschl = 'JICG' OR <wa_a0031>-kschl = 'JISG'.
          CLEAR : lv_hed , lv_val.
          READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<wa_konp3>) WITH KEY knumh = <wa_a0031>-knumh.
          lv_hed = 'CGST'.
*        LV_VAL = 'CGST/SGST Val'.
          IF sy-subrc = 0.
            CLEAR: lv_tax,lv_per.
            lv_per =  <wa_konp3>-kbetr / 10 .
*          LV_S = '/'.                           """""| && | { '/' } |.
            lv_tax = ( lv_per * wa_ekpo1-netwr ) / 100.
*            LV_TAX = ( LV_PER1 * WA_ZINW_T_ITEM-NETWR_P ) / 100.
*            ADD LV_TAX TO WA_FINAL-NETPR_GP.
            wa_final-netpr_gp = lv_tax.
            wa_header-netpr_t = wa_header-netpr_t + wa_final-netpr_gp .
          ENDIF.
        ENDIF.
        ENDIF.    " added (28-2-20)
        WA_HEADER-ROUNDING = wa_header-af_dis + WA_header-FRIGHT. " ADDED ON (25-5-20)
*        IF lv_hed = 'CGST'.
*        WA_HEADER-N_VALUE = WA_HEADER-ROUNDING + wa_header-netpr_t.
*        ELSE .
*           WA_HEADER-N_VALUE = WA_HEADER-ROUNDING + wa_header-netpr_t + wa_header-netpr_t.
*        ENDIF.
      ENDLOOP.
*      WA_HEADER-ROUNDING = wa_header-af_dis + WA_FINAL-FRIGHT. " ADDED ON (25-5-20)
*      WA_HEADER-N_VALUE = WA_HEADER-ROUNDING +
*       IF <wa_a0031>-kschl = 'JIIG'.
*        WA_HEADER-N_VALUE = WA_HEADER-ROUNDING + wa_header-netpr_t.
*        ELSE .
*           WA_HEADER-N_VALUE = WA_HEADER-ROUNDING + wa_header-netpr_t + wa_header-netpr_t.
*        ENDIF.
      APPEND wa_final TO it_final.
      CLEAR wa_final.
    ENDLOOP.   " commented on (27-3-2020)
*    WA_HEADER-QTYT = WA_HEADER-QTYT  + WA_FINAL-QTY.      " ADDED ON (9-2-20)
    IF lv_hed = 'CGST'.
      wa_header-netvalue =  wa_header-tax + wa_header-fright + wa_header-u_total + wa_header-netpr_t + wa_header-netpr_t.
    ELSE.
      wa_header-netvalue =  wa_header-tax + wa_header-fright + wa_header-u_total + wa_header-netpr_t .
    ENDIF.

  ELSE.
*    BREAK BREDDY.
    CLEAR : lv_slno , wa_header-avl_qtyt ,wa_header-fright , wa_header-qtyt , wa_header-qtyt ,  wa_header-s_total , wa_header-u_total ,wa_header-doc_date,
    wa_header-netpr_t .

    break clikhitha.
    LOOP AT it_zinw_t_item INTO wa_zinw_t_item.
      wa_final-itemno = wa_zinw_t_item-ebelp.

*************************************************************
    READ TABLE it_data ASSIGNING FIELD-SYMBOL(<skn1>)
    WITH KEY matnr =  wa_zinw_t_item-matnr.
      IF sy-subrc = 0.
        wa_final-mrp = <skn1>-kbetr.
      ENDIF.
*************************************************************
*    WA_HEADER-BLDAT = WA_MKPF-BLDAT.  "" dt
      lv_slno = lv_slno + 1.
      wa_final-slno = lv_slno .

*  LV1 = WA_ZINW_T_ITEM-MENGE .
*  SPLIT LV1 AT '.' INTO LV3 LV2.
      wa_final-avl_qty = wa_zinw_t_item-menge.
      wa_header-avl_qtyt = wa_header-avl_qtyt  +  wa_final-avl_qty.     " COMMENTED  ON (9-2-20)

      wa_header-fright    =  wa_header-fright + wa_zinw_t_hdr-frt_amt .
*    WA_HEADER-TAX =  WA_HEADER-TAX + WA_ZINW_T_ITEM-NETPR_GP.
*CONDENSE  WA_HEADER-AVL_QTYT NO-GAPS.

*  LVA = WA_ZINW_T_ITEM-MENGE_P.
*  SPLIT LV1 AT '.' INTO LVB LVC.
      wa_final-qty  = wa_zinw_t_item-menge_p.
      wa_header-qtyt = wa_header-qtyt  + wa_final-qty.

*  WA_FINAL-NETWR = WA_ZINW_T_ITEM-NETWR_P .
*  WA_FINAL-NETPR =  WA_ZINW_T_ITEM-NETPR_P.
      wa_final-maktx =  wa_zinw_t_item-maktx.

      wa_final-margn =  wa_zinw_t_item-margn.
      wa_final-sell_price =  wa_zinw_t_item-netpr_s.
      wa_final-unit_price =  wa_zinw_t_item-netpr_p.

*  WA_FINAL-AV_QTY =  WA_ZINW_T_ITEM-MENGE.
*  WA_FINAL-QTY =  WA_ZINW_T_ITEM-MENGE_P.
*      WA_FINAL-S_TOTAL = WA_FINAL-SELL_PRICE *  WA_FINAL-AVL_QTY.
      wa_final-s_total = wa_final-sell_price *  wa_zinw_t_item-menge_p..
      wa_header-s_total = wa_header-s_total + wa_final-s_total.
      wa_final-u_total = wa_final-unit_price *  wa_zinw_t_item-menge_p..
      wa_header-u_total = wa_header-u_total +  wa_final-u_total.
      READ TABLE it_mara ASSIGNING FIELD-SYMBOL(<ls_mara1>) WITH KEY matnr = wa_zinw_t_item-matnr.
      IF sy-subrc = 0.
        wa_final-ean11 = <ls_mara1>-ean11.
      ENDIF.
      READ TABLE it_mseg ASSIGNING FIELD-SYMBOL(<wa_mseg>) WITH KEY mblnr = wa_zinw_t_hdr-mblnr
      matnr = wa_zinw_t_item-matnr ebelp = wa_zinw_t_item-ebelp  ebeln = wa_zinw_t_item-ebeln.
      IF sy-subrc = 0.
        wa_final-b_code =  <wa_mseg>-charg .
        wa_final-whs =  <wa_mseg>-werks .
      ENDIF.
*  READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_ZINW_T_ITEM-MATNR .
*  IF SY-SUBRC = 0.
*    WA_FINAL-MAKTX = WA_MAKT-MAKTX .
*  ENDIF.
      IF <wa_mseg> IS ASSIGNED.
        READ TABLE it_mkpf ASSIGNING FIELD-SYMBOL(<wa_mkpf1>) WITH KEY mblnr = wa_zinw_t_hdr-mblnr.
        wa_header-doc_date = <wa_mkpf1>-bldat .
      ENDIF.

      READ TABLE it_ekko INTO wa_ekko WITH KEY ebeln = wa_zinw_t_item-ebeln.
      IF wa_ekko-bsart = 'ZTAT'.

        lv_heading = 'Tatkal GRPO Price Report'.

      ELSE.
        lv_heading = 'GRPO Price Report'.

      ENDIF.

******************      ADDED ON(18-2-20)    ***********************
       READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_1>) WITH KEY KNUMV = wa_ekko-knumv kposn = WA_final-itemno kschl = 'ZDS1'.
        IF sy-subrc = 0.
      wa_final-kbetr =   <ls_prcd_1>-kbetr.
      wa_final-dis_tt = ( wa_ZINW_T_ITEM-netwr_p * wa_final-kbetr ) / 100.
      wa_header-dis_t = wa_header-dis_t +  wa_final-dis_tt.
      WA_FINAL-ADIS = wa_ZINW_T_ITEM-netwr_p + wa_final-dis_tt.
*endif.
        ENDIF.
         READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_2>) WITH KEY KNUMV = wa_ekko-knumv kposn = WA_final-itemno kschl = 'ZDS2'.
        IF sy-subrc = 0.
         wa_final-kbetr =   <ls_prcd_2>-kbetr.
         wa_final-dis_tt2 = ( wa_final-ADIS * wa_final-kbetr ) / 100.
      wa_header-dis_t2 = ( wa_header-dis_t2 +  wa_final-dis_tt2 ).
ENDIF.
READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_3>) WITH KEY
KNUMV = wa_ekko-knumv kposn = WA_final-itemno kschl = 'ZDS3'.
        IF sy-subrc = 0.
          wa_final-kbetr =   <ls_prcd_3>-kbetr.
*      wa_final-dis_tt3 = ( wa_final-dis_tt2 * wa_final-kbetr ) / 10.
wa_final-dis_tt3 = ( WA_ZINW_T_ITEM-MENGE_P * wa_final-kbetr ).
      wa_header-dis_t3 = wa_header-dis_t3 +  wa_final-dis_tt3.
ENDIF.
 wa_header-N_dis =  wa_header-dis_t +
wa_header-dis_t2  + wa_header-dis_t3 .
 wa_header-af_dis = wa_header-U_TOTAL + wa_header-N_DIS.

READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<ls_prcd_F>) WITH KEY
 KNUMV = wa_ekko-knumv kposn = WA_final-itemno kschl = 'ZFRB'.
        IF sy-subrc = 0.
   WA_FINAL-FRIGHT = <ls_prcd_F>-kwert.
   wa_header-fright = wa_header-fright + wa_final-fright.
          ENDIF.
*******************      END(18-2-20)   ***************
      READ TABLE it_ekpo INTO wa_ekpo WITH KEY ebeln =   wa_zinw_t_item-ebeln matnr = wa_zinw_t_item-matnr ebelp = wa_zinw_t_item-ebelp.
*      LOOP AT IT_A003 ASSIGNING FIELD-SYMBOL(<WA_A003>) WHERE MWSKZ = WA_EKPO-MWSKZ.
      READ TABLE it_a003 ASSIGNING FIELD-SYMBOL(<wa_a003>) WITH KEY mwskz = wa_ekpo-mwskz.
      IF sy-subrc IS INITIAL.
        IF <wa_a003>-kschl = 'JIIG'.
          lv_hed = 'IGST'.
*        LV_VAL = 'IGST Value'.
          READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<wa_konp>) WITH KEY knumh = <wa_a003>-knumh.
          IF sy-subrc = 0.
            lv_per =  <wa_konp>-kbetr / 10   .                        """""| && | { '%' } |.
*            LV_TAX = ( <WA_KONP>-KBETR * WA_EKPO-NETWR ) / 1000.
            lv_tax = ( lv_per * wa_zinw_t_item-netwr_p ) / 100.
*            ADD LV_TAX TO WA_FINAL-NETPR_GP.
            wa_final-netpr_gp = lv_tax .
*            WA_FINAL-NETPR_GP = WA_ZINW_T_ITEM-NETWR_P + WA_ZINW_T_ITEM-NETWR_P .
            wa_header-netpr_t = wa_header-netpr_t + wa_final-netpr_gp .
*            EXIT.
          ENDIF.
        ELSEIF <wa_a003>-kschl = 'JICG' OR <wa_a003>-kschl = 'JISG'.
          CLEAR : lv_hed , lv_val.
          READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<wa_konp2>) WITH KEY knumh = <wa_a003>-knumh.
          lv_hed = 'CGST'.
*        LV_VAL = 'CGST/SGST Val'.
          IF sy-subrc = 0.
            CLEAR: lv_tax,lv_per.
            lv_per =  <wa_konp2>-kbetr / 10 .
            lv_per1 = lv_per + lv_per .
*          LV_S = '/'.                           """""| && | { '/' } |.
*            LV_TAX = ( <WA_KONP2>-KBETR * WA_EKPO-NETWR ) / 1000.
            lv_tax = ( lv_per1 * wa_zinw_t_item-netwr_p ) / 100.
*            ADD LV_TAX TO WA_FINAL-NETPR_GP.
            wa_final-netpr_gp = lv_tax.

            wa_header-netpr_t =  wa_final-netpr_gp  + wa_header-netpr_t .

          ENDIF.
        ENDIF.
      ENDIF.
*      ENDLOOP.
*      WA_HEADER-NETPR_T = ( WA_HEADER-NETPR_T / 2 ) .

  WA_HEADER-ROUNDING = wa_header-af_dis + WA_header-FRIGHT.
  IF lv_hed = 'IGST'.
        WA_HEADER-N_VALUE = WA_HEADER-ROUNDING + wa_header-netpr_t.
        ELSE .
           WA_HEADER-N_VALUE = WA_HEADER-ROUNDING + wa_header-netpr_t + wa_header-netpr_t.
        ENDIF.
*        &&&&&&&&&&&&&&&&&&&&&&&&&&&&&   (25-5-20)
      APPEND wa_final TO it_final.
      CLEAR :  wa_final.", wa_header.

    ENDLOOP   .    " commented on (27-3-2020)
*        &&&&&&&&&&&&&&&&&&&&&&&&
*     WA_HEADER-AVL_QTYT = WA_HEADER-AVL_QTYT  +  WA_FINAL-AVL_QTY.    " ADDED (9-2-20)

    IF lv_hed = 'CGST' .
      wa_header-netpr_t = ( wa_header-netpr_t / 2 ) .
    ENDIF.
    wa_header-netvalue =  wa_header-tax + wa_header-fright + wa_header-u_total + wa_header-netpr_t .
  ENDIF .     " commented on (25-5-20)
*  ***************************************************************************
********************************  added (13-2-20)    *************************
  IF wa_ekko-bsart NE 'ZTAT'.
*    READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<wa_konpt>) INDEX 1.
    loop at it_konp ASSIGNING FIELD-SYMBOL(<wa_konpt>).
    IF sy-subrc = 0.
      IF <wa_konpt>-kschl = 'JIIG'.
            lv_per = <wa_konpt>-kbetr / 10.   " added on (25-5-20)
            lv_tax  = (  WA_HEADER-ROUNDING * lv_per ) / 100.
            wa_header-netpr_t = lv_tax.
*        wa_header-netpr_t = wa_zinw_t_hdr-pur_tax .    " commeneted on (25-5-20)
      ELSEIF <wa_konpt>-kschl = 'JICG' OR <wa_konpt>-kschl = 'JISG'.
        lv_per = <wa_konpt>-kbetr / 10.   " added on (25-5-20)
            lv_tax  = (  WA_HEADER-ROUNDING * lv_per ) / 100.
            wa_header-netpr_t = lv_tax .
*        wa_header-netpr_t = wa_zinw_t_hdr-pur_tax / 2.       " commeneted on (25-5-20)
*        wa_header-netpr_t = wa_zinw_t_hdr-pur_tax / 2.       " commeneted on (25-5-20)
      ENDIF.
    ENDIF.
    wa_header-netvalue = wa_zinw_t_hdr-net_amt .
*  ENDIF.
endloop.
ENDIF.
  IF wa_ekko-bsart NE 'ZTAT'.
       IF <wa_konpt>-kschl = 'JIIG'.
        WA_HEADER-N_VALUE = WA_HEADER-ROUNDING +  lv_tax.
        else.
          WA_HEADER-N_VALUE = WA_HEADER-ROUNDING +  lv_tax + lv_tax.
          ENDIF.
        ENDIF.

*added on (25-5-20)
*  APPEND wa_final TO it_final.
*      CLEAR :  wa_final.", wa_header.
*
*    ENDLOOP .
*    ENDIF.
*************added on (26-5-20)
*  IF <wa_konpt>-kschl = 'JIIG'.
*********************     IF wa_ekko-bsart NE 'ZTAT'.
*********************       IF <wa_konpt>-kschl = 'JIIG'.
*********************        WA_HEADER-N_VALUE = WA_HEADER-ROUNDING +  lv_tax.
*********************        else.
*********************          WA_HEADER-N_VALUE = WA_HEADER-ROUNDING +  lv_tax + lv_tax.
*********************          ENDIF.
*********************        ENDIF.
*        ELSE .
*           WA_HEADER-N_VALUE = WA_HEADER-ROUNDING + wa_header-netpr_t + wa_header-netpr_t.
*        ENDIF.
*********  end (25-5-20)
******************************  end(13-2-20)   **************************


  DATA fmname TYPE rs38l_fnam.


  IF wa_zinw_t_hdr-status GE '04'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZGRPOPRICE_COPY'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        fm_name            = fmname
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION fmname
      EXPORTING
        wa_header        = wa_header
        lv_heading       = lv_heading
        lv_hed           = lv_hed
*       LV_VAL           = LV_VAL
        lv_per           = lv_per
*       LV_TRAYS         = LV_TRAYS
*       LV_BUNDLES       = LV_BUNDLES
*       LV_VBELN         = LV_VBELN
      TABLES
        it_final         = it_final
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.
*    IF SY-SUBRC <> 0.
    IF sy-subrc = 0.
      CLEAR : wa_header , wa_final , wa_zinw_t_item, wa_lfa1, wa_t001w, wa_zinw_t_item1, wa_mseg1, wa_konv,  wa_ekpo,  wa_ekpo1,wa_makt1.
      REFRESH : it_final, it_konp , it_ekpo, it_t001w ,it_zinw_t_hdr ,it_zinw_t_item, it_lfa1, it_t001w, it_konv, it_ekpo1, it_ekko, it_makt1 .
* Implement suitable error handling here
    ENDIF.

  ELSE.
    MESSAGE 'Invalid QR Code' TYPE 'E'.
  ENDIF.
endform.
******************added for mail (27-3-20)*************
