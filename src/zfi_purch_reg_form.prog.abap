*&---------------------------------------------------------------------*
*& Include          ZFI_PURCH_REG_FORM
*&---------------------------------------------------------------------*

FORM get_purch_history .

**-> Fetching_from_DB ->
  PERFORM gui_status_display USING space 'Fetching from DB'.

*--> Purchase_history ->
  SELECT ebeln
         ebelp
         zekkn
         vgabe
         gjahr
         belnr
         buzei
         bewtp
         bwart
         budat
         bldat
         menge
         bpmng
         dmbtr
         wrbtr
         waers
         arewr
         wesbs
         bpwes
         shkzg
         bwtar
         elikz
         xblnr
         lfgja
         lfbnr
         lfpos
         reewr
         refwr
         matnr
         werks
         knumv
         mwskz
         bamng
         charg
         srvpos
         packno
         introw
         wkurs
         vbeln_st
         vbelp_st
         FROM ekbe INTO TABLE gt_ekbe
         WHERE vgabe IN (  '2' , '3' ) AND budat IN s_budat
         AND werks IN s_werks "AND ebeln IN s_ebeln
*         AND belnr IN s_belnr
    AND gjahr IN s_gjahr.   " AND shkzg = 'S' . "#EC CI_NO_TRANSFORM

*--> Domestic_vendor_documents_for_Import ->
  SELECT ebeln
         ebelp
         stunr
         zaehk
         vgabe
         gjahr
         belnr
         buzei
         bewtp
         budat
         menge
         dmbtr
         wrbtr
         waers
         kschl
         shkzg
         xblnr
         frbnr
         lifnr
         reewr
         refwr
         bwtar
         wkurs FROM ekbz INTO TABLE gt_ekbz
****         FOR ALL ENTRIES IN gt_ekbe
         WHERE "ebeln IN s_ebeln
    vgabe IN ( '2' , '3' )
        AND budat IN s_budat    "AND shkzg = 'S'
*         AND belnr IN s_belnr
    AND gjahr IN s_gjahr                           "#EC CI_NO_TRANSFORM
         AND lifnr IN s_lifnr.

  IF gt_ekbe[] IS NOT INITIAL.

    SELECT belnr
           gjahr
           buzei
           ebeln
           ebelp
           zekkn
           bukrs
           matnr
           hsn_sac
           mwskz
           wrbtr
           menge
           meins
           werks
           pstyp
           knttp
           bstme
           kschl
           sgtxt
           shkzg
           introw
           packno
           lfbnr
           lfgja
           lfpos
           customs_val
           licno
           zeile
           zaehk
           bnkan
           FROM rseg INTO TABLE gt_rseg FOR ALL ENTRIES IN gt_ekbe
           WHERE belnr = gt_ekbe-belnr AND gjahr = gt_ekbe-gjahr AND lifnr IN s_lifnr . "#EC CI_NO_TRANSFORM
  ENDIF.

  IF gt_ekbz[] IS NOT INITIAL.
    SELECT belnr
       gjahr
       buzei
       ebeln
       ebelp
       zekkn
       bukrs
       matnr
       hsn_sac
       mwskz
       wrbtr
       menge
       meins
       werks
       pstyp
       knttp
       bstme
       kschl
       sgtxt
       shkzg
       introw
       packno
       lfbnr
       lfgja
       lfpos
       customs_val
       licno
       zeile
       zaehk
       bnkan
        FROM rseg APPENDING TABLE gt_rseg FOR ALL ENTRIES IN gt_ekbz
       WHERE belnr = gt_ekbz-belnr AND gjahr = gt_ekbz-gjahr AND lifnr = gt_ekbz-lifnr. "#EC CI_NO_TRANSFORM


  ENDIF.

*--> If_any_record_exists_for_the_interval ->
  IF gt_ekbe[] IS NOT INITIAL.

*--> Tax_amount ->
    SELECT belnr
           bukrs
           gjahr
           budat
           rmwwr
           beznk
           wmwst1
           mwskz1
           stcd3
           bldat
           lifnr
           waers
           xblnr
           rbstat
           stblg
           regio
           landl
           plc_sup
           knumve
           gsber
           sgtxt
           kursf
           FROM rbkp INTO TABLE gt_rbkp
          FOR ALL ENTRIES IN gt_ekbe
          WHERE belnr = gt_ekbe-belnr AND gjahr = gt_ekbe-gjahr AND stblg = space. "#EC CI_NO_TRANSFORM

  ENDIF.

  IF gt_ekbz[] IS NOT INITIAL.
*--> Invoice_receipt_Tax_header ->
    SELECT  belnr
            bukrs
            gjahr
            budat
            rmwwr
            beznk
            wmwst1
            mwskz1
            stcd3
            bldat
            lifnr
            waers
            xblnr
            rbstat
            stblg
            regio
            landl
            plc_sup
            knumve
            gsber
            sgtxt
            kursf   FROM rbkp APPENDING TABLE gt_rbkp
           FOR ALL ENTRIES IN gt_ekbz
           WHERE belnr = gt_ekbz-belnr AND gjahr = gt_ekbz-gjahr . "#EC CI_NO_TRANSFORM

*--> Tax_for_import_documents ->
    SELECT belnr
           gjahr
           mwskz
           wmwst
           fwbas
           hwste
           hwbas
           txjcd
           txjdp
           kschl
           taxps FROM rbtx INTO TABLE gt_rbtx
           FOR ALL ENTRIES IN gt_ekbz
           WHERE belnr = gt_ekbz-belnr
           AND gjahr = gt_ekbz-gjahr.              "#EC CI_NO_TRANSFORM
  ENDIF.

  IF gt_rbkp[] IS NOT INITIAL.
*--> vendor_details_ekbz->

    SELECT
      lifnr
      name1
      name2
      name3
      name4
      ort01
      regio
      land1
      ven_class
      stcd3
      j_1ipanref
      FROM lfa1 INTO TABLE gt_lfa1
      FOR ALL ENTRIES IN gt_rbkp[]
      WHERE lifnr = gt_rbkp-lifnr .                "#EC CI_NO_TRANSFORM
  ENDIF.

  IF gt_ekbe[] IS NOT INITIAL.
*--> PO Header Details ->
    SELECT ebeln
           bsart
           bedat
           bstyp
           ekorg
           ekgrp
           lifnr
           knumv
            FROM ekko INTO TABLE gt_ekko
           FOR ALL ENTRIES IN gt_ekbe
           WHERE ebeln = gt_ekbe-ebeln.
*           AND lifnr IN s_lifnr .                  "#EC CI_NO_TRANSFORM
  ENDIF.
*--> Import_purchase_POs ->
  IF gt_ekbz[] IS NOT INITIAL.
    SELECT ebeln
       bsart
       bedat
       bstyp
       ekorg
       ekgrp
       lifnr
       knumv
        FROM ekko APPENDING TABLE gt_ekko
       FOR ALL ENTRIES IN gt_ekbz
       WHERE ebeln = gt_ekbz-ebeln
       AND lifnr IN s_lifnr .                      "#EC CI_NO_TRANSFORM
  ENDIF.

*--> PO Item_details ->
  IF gt_ekko[] IS NOT INITIAL.

    SELECT
      ebeln
      ebelp
      werks
      txz01
      packno
      menge
      navnw
      matnr
      meins
      mwskz
      FROM ekpo INTO TABLE gt_ekpo
      FOR ALL ENTRIES IN gt_ekko[]
      WHERE ebeln = gt_ekko-ebeln .                "#EC CI_NO_TRANSFORM
  ENDIF.

  IF gt_ekpo[] IS NOT INITIAL.
    SELECT
      mblnr
      mjahr
      zeile
      ebeln
      ebelp
      budat_mkpf
      FROM mseg INTO TABLE gt_mseg
      FOR ALL ENTRIES IN gt_ekpo
      WHERE ebeln = gt_ekpo-ebeln AND ebelp = gt_ekpo-ebelp. "#EC CI_NO_TRANSFORM

  ENDIF.
*  IF gt_rseg[] IS NOT INITIAL.
  IF gt_ekpo[] IS NOT INITIAL.
*--> Get_tax_conditions ->
    SELECT * FROM a003 APPENDING TABLE gt_a003
      FOR ALL ENTRIES IN gt_ekpo WHERE mwskz = gt_ekpo-mwskz  . "#EC CI_NO_TRANSFORM

    BREAK ppadhy.
    IF gt_a003[] IS NOT INITIAL.
      SELECT knumh
             kopos
             mwsk1
             kschl
             kbetr FROM konp INTO TABLE gt_konp
             FOR ALL ENTRIES IN gt_a003 WHERE knumh = gt_a003-knumh . "#EC CI_NO_TRANSFORM

      DELETE gt_konp[] WHERE mwsk1 = '1Q' AND kschl = 'JIIG'.

    ENDIF.
  ENDIF.

  IF gt_ekpo[] IS NOT INITIAL.

***--> inport_costs ->
    SELECT * FROM v_mara_makt
      INTO TABLE gt_material
      FOR ALL ENTRIES IN gt_ekpo
      WHERE matnr = gt_ekpo-matnr .                "#EC CI_NO_TRANSFORM

  ENDIF.

  IF gt_ekpo[] IS NOT INITIAL.
    SELECT matnr
           steuc
           werks FROM marc INTO TABLE gt_marc
           FOR ALL ENTRIES IN gt_ekpo
           WHERE matnr = gt_ekpo-matnr AND werks = gt_ekpo-werks. "#EC CI_NO_TRANSFORM
  ENDIF.
  IF gt_ekbe[] IS NOT INITIAL.
*--> entry_sheet ->
    SELECT * FROM essr INTO TABLE gt_essr FOR ALL ENTRIES IN gt_ekbe[]
      WHERE lblni = gt_ekbe-lfbnr AND ebeln = gt_ekbe-ebeln AND ebelp = gt_ekbe-ebelp. "#EC CI_NO_TRANSFORM
  ENDIF.

*--> Entry_sheet_packno ->
  IF gt_essr[] IS NOT INITIAL .

    SELECT packno
           introw
           extrow
           srvpos
           ktext1
           sub_packno
           menge
           act_menge
           meins
           brtwr
           netwr
           matkl
           tbtwr
           act_wert
           navnw
           baswr
           kknumv
           userf1_num
           belnr
           taxtariffcode FROM esll INTO TABLE gt_esll
           FOR ALL ENTRIES IN gt_essr
           WHERE packno = gt_essr-packno   .       "#EC CI_NO_TRANSFORM
  ENDIF.
*--> Service_item_details ->
  IF gt_esll[] IS NOT INITIAL.
    SELECT packno
           introw
           extrow
           srvpos
           ktext1
           sub_packno
           menge
           act_menge
           meins
           brtwr
           netwr
           matkl
           tbtwr
           act_wert
           navnw
           baswr
           kknumv
           userf1_num
           belnr
           taxtariffcode  FROM esll APPENDING TABLE gt_esll
           FOR ALL ENTRIES IN gt_esll
           WHERE packno = gt_esll-sub_packno ."AND introw = gt_ekbe-introw .      "#EC CI_NO_TRANSFORM
  ENDIF.
*  ENDIF.


  SELECT * FROM t059w INTO TABLE gt_t059w WHERE land1 = 'IN' AND spras = 'E'. "#EC CI_NO_TRANSFORM
  SELECT * FROM t059zt INTO TABLE gt_t059zt WHERE land1 = 'IN' AND spras = 'E' . "#EC CI_NO_TRANSFORM
  IF gt_ekko[] IS NOT INITIAL.
    SELECT * FROM lfbw INTO TABLE gt_lfbw
        FOR ALL ENTRIES IN gt_ekko WHERE lifnr = gt_ekko-lifnr . "#EC CI_NO_TRANSFORM
  ENDIF.

*--> Country_code ->
  IF gt_lfa1[] IS NOT INITIAL.
    SELECT * FROM t005t INTO TABLE gt_t005t FOR ALL ENTRIES IN gt_lfa1[] WHERE spras = 'E' AND land1 = gt_lfa1-land1 . "#EC CI_NO_TRANSFORM
*--> state_code ->
    SELECT * FROM t005u INTO TABLE gt_t005u FOR ALL ENTRIES IN gt_lfa1[] WHERE spras = 'E' AND land1 = gt_lfa1-land1 AND bland = gt_lfa1-regio. "#EC CI_NO_TRANSFORM
  ENDIF.

  IF gt_rbkp[] IS NOT INITIAL.
    SELECT * FROM t005u APPENDING TABLE gt_t005u FOR ALL ENTRIES IN gt_rbkp[] WHERE spras = 'E' AND land1 = 'IN' AND bland = gt_rbkp-plc_sup. "#EC CI_NO_TRANSFORM
  ENDIF.


  SORT gt_rseg BY belnr gjahr buzei ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM gt_rseg COMPARING belnr gjahr buzei ebeln ebelp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .


  IF gt_rbkp[] IS NOT INITIAL.

    SELECT  bukrs,
         belnr,
         gjahr,
         bldat,
         awkey,
         bktxt,
         xblnr
         FROM bkpf INTO TABLE @DATA(it_bkpf) WHERE belnr = @gt_rbkp-belnr AND
                                                   bukrs = @gt_rbkp-bukrs AND
                                                   gjahr = @gt_rbkp-gjahr.
  ENDIF.

**  SELECT invoice, bill_num, debit_note INTO TABLE @DATA(lt_inw_hdr)
**     FROM zinw_t_hdr FOR ALL ENTRIES IN @it_bkpf
**     WHERE invoice = @it_bkpf-awkey+0(10) OR debit_note = @it_bkpf-awkey+0(10) AND inv_gjahr = @it_bkpf-gjahr.
  IF gt_rbkp[] IS NOT INITIAL.
    SELECT invoice, bill_num, debit_note INTO TABLE @DATA(lt_inw_hdr)
       FROM zinw_t_hdr FOR ALL ENTRIES IN @gt_rbkp
       WHERE invoice = @gt_rbkp-belnr AND inv_gjahr = @gt_rbkp-gjahr.
  ENDIF.

  IF gt_ekko[] IS NOT INITIAL.

    SELECT ekgrp, eknam FROM t024 INTO TABLE @DATA(it_t024)
      FOR ALL ENTRIES IN @gt_ekko
      WHERE ekgrp = @gt_ekko-ekgrp.

  ENDIF.

  IF gt_material[] IS NOT INITIAL.
    SELECT matkl, wgbez60 FROM t023t INTO TABLE @DATA(it_t023t)
    FOR ALL ENTRIES IN @gt_material
    WHERE matkl = @gt_material-matkl AND spras = @sy-langu.
  ENDIF.

  IF gt_ekbe[] IS NOT INITIAL.
    SELECT ebeln , ebelp, gjahr, belnr, buzei, bewtp, bwart, lfgja, lfbnr, budat FROM ekbe INTO TABLE @DATA(gt_ekbe_gr)
      FOR ALL ENTRIES IN @gt_ekbe
      WHERE ebeln = @gt_ekbe-ebeln AND ebelp = @gt_ekbe-ebelp AND bewtp = 'E'.

    SELECT ebeln , ebelp, gjahr, belnr, buzei, bewtp, bwart, lfgja, lfbnr, budat, bldat FROM ekbe INTO TABLE @DATA(gt_ekbe_inv)
    FOR ALL ENTRIES IN @gt_ekbe
    WHERE ebeln = @gt_ekbe-ebeln AND ebelp = @gt_ekbe-ebelp AND bewtp = 'Q'.
  ENDIF.

  IF gt_ekko[] IS NOT INITIAL.

    SELECT
      knumv, kposn, kschl, kbetr, kwert FROM prcd_elements INTO TABLE @DATA(it_prcd)
      FOR ALL ENTRIES IN @gt_ekko WHERE knumv = @gt_ekko-knumv  .

  ENDIF.

*--> Get_mantainance_dtls_for_ZPR01 ->
  SELECT * FROM tvarvc INTO TABLE @DATA(smtvarvc) WHERE name LIKE 'ZPR01%' .

  DATA : srno TYPE int8 .
*--> Progress_indicator ->
  DATA: curline(10), maxline(10),
        perc        TYPE i, text TYPE text100,
        lv_count    TYPE i,
        lv_count01  TYPE i.

  maxline = lines( gt_ekbe[] ) .
  lv_count = maxline / 10 .
  curline  = lv_count .
  BREAK ppadhy.
  LOOP AT gt_ekbe.

    READ TABLE gt_rbkp WITH KEY belnr = gt_ekbe-belnr gjahr = gt_ekbe-gjahr .
    IF sy-subrc <> 0.
      DELETE gt_ekbe WHERE belnr = gt_ekbe-belnr AND gjahr = gt_ekbe-gjahr .
    ENDIF.

  ENDLOOP.

*--> Purchasing_history ->
  LOOP AT gt_ekbe.
***    ADD 1 TO srno .
***    GW_FINAL-slno = srno .

    IF curline = sy-tabix .
      ADD lv_count TO curline .
      perc = ( curline * 100 ) / maxline.
      PERFORM gui_status_display USING perc 'Processing Purchase History'.
    ENDIF.

    READ TABLE gt_rbkp WITH KEY belnr = gt_ekbe-belnr gjahr = gt_ekbe-gjahr .
    IF sy-subrc IS INITIAL.
*************************************************************************
*      IF gt_rbkp-stblg IS NOT INITIAL .
*        CLEAR : gw_final,lv_awkey .
*        CONTINUE .
*      ENDIF.
**************************************************************************
      gw_final-supl_invdt = gt_rbkp-bldat .  "Supplier_invoice_date
*      gw_final-plc_sup = gt_rbkp-plc_sup .
      READ TABLE gt_t005u WITH KEY bland = gt_rbkp-plc_sup .
      IF sy-subrc IS INITIAL.
        gw_final-plc_sup = gt_t005u-bezei .
      ENDIF.
      gw_final-gsber = gt_rbkp-gsber .
      gw_final-sgtxt = gt_rbkp-xblnr .
      gw_final-kursf = gt_rbkp-kursf .  "Exchange_rate
      gw_final-bukrs = gt_rbkp-bukrs .
    ENDIF.

    READ TABLE it_bkpf INTO DATA(wa_bkpf) WITH KEY  bukrs = gt_rbkp-bukrs
                                             belnr = gt_rbkp-belnr
                                             gjahr = gt_rbkp-gjahr.
    IF sy-subrc = 0.
      gw_final-sgtxt = wa_bkpf-bktxt.
    ENDIF.

*    IF gw_final-sgtxt IS NOT INITIAL.
***     Invoice : Vendor Bill Number from Inward Doc
    READ TABLE lt_inw_hdr ASSIGNING <ls_inw_hdr> WITH KEY invoice = gt_rbkp-belnr.
    IF sy-subrc IS INITIAL.
      gw_final-sgtxt = <ls_inw_hdr>-bill_num.
    ELSE.
***       Debit Note : Vendor Bill Number from Inward Doc
      READ TABLE lt_inw_hdr ASSIGNING <ls_inw_hdr1> WITH KEY debit_note = wa_bkpf-awkey+0(10).
      IF sy-subrc IS INITIAL.
        if <ls_inw_hdr1>-debit_note IS NOT INITIAL.
        gw_final-sgtxt = <ls_inw_hdr1>-bill_num.
        endif.
      ELSEIF wa_bkpf-xblnr IS NOT INITIAL.
***        Returns : Vendor Bill Number
        gw_final-sgtxt = wa_bkpf-xblnr.
      ENDIF.
    ENDIF.
*    ENDIF.

    IF gw_final-sgtxt IS INITIAL.
      gw_final-sgtxt = gt_rbkp-xblnr .
    ENDIF.

    READ TABLE gt_ekbe_gr INTO DATA(gs_ekbe_gr) WITH KEY ebeln = gt_ekbe-ebeln  ebelp = gt_ekbe-ebelp  bewtp = 'E'.
    IF sy-subrc = 0.
      gw_final-budat_mkpf = gs_ekbe_gr-budat.
    ENDIF.

    READ TABLE gt_ekbe_inv INTO DATA(gs_ekbe_inv) WITH KEY ebeln = gt_ekbe-ebeln  ebelp = gt_ekbe-ebelp  bewtp = 'Q'.
    IF sy-subrc = 0.
      gw_final-inv_postdt = gs_ekbe_inv-budat.
      gw_final-inv_docdt  = gs_ekbe_inv-bldat.
    ENDIF.

    SELECT SINGLE gtext FROM tgsbt INTO gw_final-gtext WHERE gsber = gw_final-gsber AND spras = sy-langu.

    gw_final-budat = gt_ekbe-budat .
**    gw_final-inv_docdt  = gt_ekbe-bldat .
**    gw_final-inv_postdt = gt_ekbe-budat .
    gw_final-werks = gt_ekbe-werks .
    gw_final-matnr = gt_ekbe-matnr .
    gw_final-shkzg = gt_ekbe-shkzg .
    gw_final-buzei = gt_ekbe-buzei .

********************************************************************************
    READ TABLE gt_material WITH KEY matnr = gw_final-matnr .
    IF sy-subrc IS INITIAL.
      gw_final-maktx = gt_material-maktx .
      gw_final-mtart = gt_material-mtart .
      READ TABLE it_t023t INTO DATA(wa_t023t) WITH KEY matkl = gt_material-matkl.
      IF sy-subrc = 0.
        gw_final-wgbez60 = wa_t023t-wgbez60 .
      ENDIF.

    ENDIF.

    READ TABLE gt_rseg WITH KEY belnr = gt_ekbe-belnr gjahr = gt_ekbe-gjahr buzei = gt_ekbe-buzei .
    IF sy-subrc IS INITIAL.

      gw_final-meins = gt_rseg-bstme ."meins .
      gw_final-bnkan = gt_rseg-bnkan  ."meins .
*      gw_final-mwskz = gt_rseg-mwskz.
    ENDIF.

    READ TABLE gt_marc WITH KEY matnr = gw_final-matnr werks = gt_ekbe-werks.
    IF sy-subrc IS INITIAL.
      gw_final-steuc = gt_marc-steuc .
    ENDIF.
    gw_final-ebeln = gt_ekbe-ebeln .
    gw_final-ebelp = gt_ekbe-ebelp .
    READ TABLE gt_ekko WITH KEY ebeln = gw_final-ebeln .
    IF sy-subrc IS INITIAL  .
***      gw_final-lifnr = gt_ekko-lifnr.
      gw_final-bsart = gt_ekko-bsart.
      gw_final-bedat = gt_ekko-bedat.
      MOVE-CORRESPONDING gt_ekko TO gw_final .
      READ TABLE it_t024 INTO DATA(wa_t024) WITH KEY ekgrp = gt_ekko-ekgrp.
      IF sy-subrc = 0.
        gw_final-eknam = wa_t024-eknam.
      ENDIF.
      gw_final-lifnr = gt_rbkp-lifnr .    "Invoicing_party
      READ TABLE gt_lfa1 WITH KEY lifnr = gw_final-lifnr .
      IF sy-subrc IS INITIAL.
        gw_final-stcd3 = gt_lfa1-stcd3 .
***        gw_final-supl_regio = gt_lfa1-regio .
        READ TABLE gt_t005u WITH KEY land1 = gt_lfa1-land1 bland = gt_lfa1-regio .
        IF sy-subrc IS INITIAL.
          gw_final-supl_regio = gt_t005u-bezei.
        ENDIF.
        READ TABLE gt_t005t WITH KEY land1 = gt_lfa1-land1 .
        IF sy-subrc IS INITIAL.
          gw_final-supl_cntry = gt_t005t-landx .
        ENDIF.
*        gw_final-supl_cntry = gt_lfa1-land1 .
        gw_final-supl_name = gt_lfa1-name1 .
      ENDIF.

      READ TABLE gt_ekpo WITH KEY ebeln = gw_final-ebeln ebelp = gt_ekbE-ebelp .
      IF sy-subrc IS INITIAL.
        gw_final-werks = gt_ekpo-werks .
        gw_final-matnr = gt_ekpo-matnr .
        gw_final-mwskz = gt_ekpo-mwskz. .
      ENDIF.

    ENDIF.
*--> MIRO_Document ->
    gw_final-mr_belnr = gt_ekbe-belnr .
*--> FI Document ->
    lv_awkey = |{ gt_ekbe-belnr }{ gt_ekbe-gjahr }|.
    SELECT SINGLE belnr gjahr xblnr xblnr_alt awref_rev xreversing FROM bkpf
      INTO ( gw_final-fi_belnr ,gw_final-gjahr, gw_final-invoice , gw_final-odn , gw_final-awref_rev , gw_final-xreversing )
      WHERE awkey = lv_awkey
      AND glvor = 'RMRP'.                               "#EC CI_NOFIRST
*    gw_final-gjahr = gt_ekbe-gjahr .

****    IF gt_ekbe-mwskz+0(1) = 'Z'.     "ZA,ZB,ZC   "Exclding_VAT
*--> Check_for_VAT ->
    READ TABLE smtvarvc INTO DATA(swtvarvc) WITH KEY name = 'ZPR01_VAT' low = gt_ekbe-mwskz .
    IF sy-subrc IS INITIAL .
      gw_final-grs_value = gt_ekbe-reewr .
      gw_final-grs_value01 = gt_ekbe-refwr  .
    ELSE.
      IF gt_ekbe-reewr < gt_ekbe-dmbtr .
        gw_final-grs_value = gt_ekbe-reewr .
        gw_final-grs_value01 = gt_ekbe-refwr  .
      ELSE.
        gw_final-grs_value = gt_ekbe-dmbtr . "Gross
        gw_final-grs_value01 = gt_ekbe-wrbtr .
      ENDIF.
    ENDIF.

*--> Basic_GL ->
    SELECT SINGLE hkont FROM bseg INTO gw_final-hkont WHERE bukrs = '2022'
                 AND  belnr = gw_final-fi_belnr AND gjahr = gw_final-gjahr AND xhres = abap_true AND hkont <> ' '.
*--> GL_Desc ->
    IF gt_final[] IS INITIAL.
      SELECT SINGLE txt50 FROM skat INTO gw_final-gl_desc
        WHERE spras = sy-langu AND ktopl  = gw_final-bukrs
        AND saknr = gw_final-hkont.
    ELSE .
      READ TABLE gt_final INTO DATA(dummy01) WITH KEY hkont = gw_final-hkont TRANSPORTING gl_desc.
      IF sy-subrc IS INITIAL.
        gw_final-gl_desc = dummy01-gl_desc .
      ELSE .
        SELECT SINGLE txt50 FROM skat INTO gw_final-gl_desc
        WHERE spras = sy-langu AND ktopl  = gw_final-bukrs
        AND saknr = gw_final-hkont.
      ENDIF.
    ENDIF.

    PERFORM get_tds .


    gw_final-menge = gt_ekbe-menge .

    IF gw_final-grs_value IS NOT INITIAL AND gw_final-menge IS NOT INITIAL.
      gw_final-rate = gw_final-grs_value / gw_final-menge .
    ENDIF.

    gw_final-waers01 = gt_ekbe-waers .
    gw_final-waers = 'INR' .


    gw_final-base_amt = gw_final-grs_value.    " + gw_final-bnkan  .

*--> GST_Based_on_tax_code ->
    LOOP AT  gt_a003 WHERE mwskz = gt_ekpo-mwskz .
      LOOP AT  gt_konp WHERE knumh = gt_a003-knumh  .
        CASE gt_konp-kschl .
          WHEN 'JICG' .
            gw_final-cgstp = ( gt_konp-kbetr * 10 ) / 100.
            gw_final-cgst = ( gw_final-grs_value * ( gw_final-cgstp / 100 ) ).
          WHEN 'JISG' .
            gw_final-sgstp = ( gt_konp-kbetr * 10 ) / 100.
            gw_final-sgst = ( gw_final-grs_value * ( gw_final-sgstp / 100 ) ).
          WHEN 'JIIG' .
            gw_final-igstp = ( gt_konp-kbetr * 10 ) / 100.
            gw_final-igst = ( gw_final-grs_value * ( gw_final-igstp / 100 ) ).

          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDLOOP .


*      LOOP AT Gt_ekko INTO data(wa_ekko) WHERE ebeln = gt_ekbe-ebeln .
    LOOP AT it_prcd INTO DATA(wa_prcd) WHERE knumv = gt_ekko-knumv AND kposn = gt_ekbe-ebelp.
      CASE wa_prcd-kschl.
        WHEN 'ZDS1' .
          gw_final-disc = wa_prcd-kwert + gw_final-disc.
        WHEN 'ZDS2'.
          gw_final-disc1 = wa_prcd-kwert + gw_final-disc1.
        WHEN 'ZDS3'.
          gw_final-disc2 = wa_prcd-kwert + gw_final-disc2.
*      	WHEN .
        WHEN OTHERS.
      ENDCASE.


    ENDLOOP.

*    ENDLOOP.

    IF gw_final-tot_taxamt IS INITIAL.
*--> Total_tax_amt ->
      gw_final-tot_taxamt = gw_final-cgst + gw_final-sgst + gw_final-igst + gw_final-ugst + gw_final-vat.  "+ gw_final-cess
    ENDIF.

    IF  gw_final-mwskz = '30' OR gw_final-mwskz = '3A' OR gw_final-mwskz = '3B' OR gw_final-mwskz = '3C' OR gw_final-mwskz = '3D' OR gw_final-mwskz = '3E'
        OR gw_final-mwskz = '3F' OR gw_final-mwskz = '3G' OR gw_final-mwskz = '3H' OR gw_final-mwskz = '3I' OR gw_final-mwskz = '3J'  OR
        gw_final-mwskz = '40' OR gw_final-mwskz = '4A' OR gw_final-mwskz = '4B' OR gw_final-mwskz = '4C' OR gw_final-mwskz = '4D' OR gw_final-mwskz = '4E'
        OR gw_final-mwskz = '4F' OR gw_final-mwskz = '4G' OR gw_final-mwskz = '4H' OR gw_final-mwskz = '4I' OR gw_final-mwskz = '4J'.
      gw_final-zrev = syes .
      gw_final-tot_inv = gw_final-grs_value .
*      gw_final-tot_inv_tds = gw_final-tot_inv + gw_final-tds_amt + gw_final-bnkan .
    ELSE.
      gw_final-zrev = sno .
      gw_final-tot_inv = gw_final-grs_value + gw_final-tot_taxamt .
*      gw_final-tot_inv_tds = gw_final-tot_inv + gw_final-tds_amt + gw_final-bnkan  .
    ENDIF.

*************************************added ***********************************************************
    IF gw_final-shkzg = 'H'.
      gw_final-tot_inv_tds = gw_final-tot_inv - gw_final-tds_amt + gw_final-bnkan  .
    ELSE.
      gw_final-tot_inv_tds = gw_final-tot_inv + gw_final-tds_amt + gw_final-bnkan.
    ENDIF.

********************************************************************************************



    IF gw_final-bsart = 'ZSER' .    "For_service_PO_entrysheet
      gw_final-lblni = gt_ekbe-lfbnr  .   "Entry_sheet

      IF gt_ekbe-packno IS NOT INITIAL.
        READ TABLE gt_esll WITH KEY packno = gt_ekbe-packno introw = gt_ekbe-introw .
        IF sy-subrc IS  INITIAL.
          gw_final-maktx = gt_esll-ktext1 .   "Service_text
          gw_final-meins = gt_esll-meins  .   "Unit of measure
          gw_final-steuc  = gt_esll-taxtariffcode . "HSN
*        gw_final-menge =
        ENDIF.
      ELSE.
        READ TABLE gt_essr WITH KEY lblni = gt_ekbe-lfbnr .
        IF sy-subrc IS INITIAL.
          READ TABLE gt_esll WITH KEY packno = gt_essr-packno  .
          IF sy-subrc IS INITIAL.
            READ TABLE gt_esll WITH KEY packno = gt_esll-sub_packno introw = gt_ekbe-ebelp .
            IF sy-subrc IS  INITIAL.
              gw_final-maktx = gt_esll-ktext1 .   "Service_text
              gw_final-meins = gt_esll-meins  .   "Unit of measure
              gw_final-steuc  = gt_esll-taxtariffcode . "HSN
*        gw_final-menge =
            ELSE.
              READ TABLE gt_esll WITH KEY packno = gt_esll-sub_packno .
              IF sy-subrc IS INITIAL.
                gw_final-maktx = gt_esll-ktext1 .   "Service_text
                gw_final-meins = gt_esll-meins  .   "Unit of measure
                gw_final-steuc  = gt_esll-taxtariffcode . "HSN
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.


    ENDIF.
    IF gw_final-kursf IS INITIAL.
      gw_final-kursf = 1.
    ENDIF.
**--> Landing_cost ->  <- 09.06.2019 02:51:47
*    READ TABLE smtvarvc INTO swtvarvc WITH KEY name = 'ZPR01_LCOST' low = gw_final-mwskz .
*    IF sy-subrc IS INITIAL.
*      gw_final-zinp = sno .
*      gw_final-lcost = gw_final-tot_inv + gw_final-bnkan.   "Invoce_amt_before_tds
*    ELSE .
*      gw_final-zinp = syes .
*      gw_final-lcost = gw_final-base_amt + gw_final-bnkan.    "TAXABLE_Amt
*    ENDIF.

    IF  gw_final-mwskz = '50' OR gw_final-mwskz = '5A' OR gw_final-mwskz = '5B' OR gw_final-mwskz = '5C' OR gw_final-mwskz = '5D' OR gw_final-mwskz = '5E'
        OR gw_final-mwskz = '5F' OR gw_final-mwskz = '5G' OR gw_final-mwskz = '5H' OR gw_final-mwskz = '5I'   .
      gw_final-zinp = syes .
      gw_final-lcost = gw_final-base_amt + gw_final-bnkan.    "TAXABLE_Amt
    ELSE.
      gw_final-zinp = sno .
      gw_final-lcost = gw_final-tot_inv + gw_final-bnkan.
    ENDIF.


*    IF gw_final-shkzg = 'H'.
    IF gw_final-xreversing = 'X'.
      gw_final-menge = gw_final-menge * -1.
      gw_final-grs_value =  gw_final-grs_value * -1.
      gw_final-grs_value01 =  gw_final-grs_value01 * -1.
      gw_final-base_amt = gw_final-base_amt * -1.
      gw_final-cgst = gw_final-cgst * -1.
      gw_final-sgst = gw_final-sgst * -1.
      gw_final-igst = gw_final-igst * -1.
      gw_final-cess = gw_final-cess * -1.
      gw_final-tot_taxamt = gw_final-tot_taxamt * -1.
      gw_final-tot_inv = gw_final-tot_inv * -1.
      gw_final-bnkan = gw_final-bnkan * -1.
      gw_final-lcost = gw_final-lcost * -1.
      gw_final-zmis = gw_final-zmis * -1.
*      gw_final-tot_inv_tds = gw_final-tot_inv_tds * -1.
    ENDIF.

    APPEND gw_final TO gt_final .
    CLEAR gw_final .

  ENDLOOP.

  CLEAR : gt_ekbe , gt_lfa1 , gt_ekbz , gt_esll , gt_rseg .
  CLEAR : maxline , lv_count , curline .
  maxline = lines( gt_ekbz[] ) .
  lv_count = maxline / 10 .
  curline  = lv_count .

*--> GST_Vendor ->
  SELECT * FROM tvarvc INTO TABLE @DATA(stvarv)
    WHERE name = 'GST_VEND' .

*--> Condition_types ->
  SELECT * FROM t685t INTO TABLE @DATA(gt_t685t) FOR ALL ENTRIES IN @gt_ekbz WHERE spras = 'E' AND kschl = @gt_ekbz-kschl .
  SORT gt_ekbz BY ebeln ebelp belnr gjahr buzei .
  DATA(gt_ekbz01) = gt_ekbz[] .

  DELETE ADJACENT DUPLICATES FROM gt_ekbz COMPARING ebeln ebelp belnr gjahr buzei .
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
  LOOP AT gt_ekbz ."WHERE ebeln = gw_ezkb01-ebeln AND belnr = gw_ezkb01-belnr AND gjahr = gw_ezkb01-gjahr .
    IF curline = sy-tabix .
      ADD lv_count TO curline .
      perc = ( curline * 100 ) / maxline.
      PERFORM gui_status_display USING perc 'Processing Local Entries for Import'.
    ENDIF.
****    gw_final-bukrs = '2022' .
***    ADD 1 TO srno .
***    GW_FINAL-slno = srno .
    gw_final-budat = gt_ekbz-budat .
    gw_final-ebeln = gt_ekbz-ebeln .
    gw_final-ebelp = gt_ekbz-ebelp .
***    gw_final-lifnr = gt_ekbz-lifnr.
    gw_final-shkzg = gt_ekbz-shkzg.
    gw_final-buzei = gt_ekbz-buzei.

*********************************added on 05.01.2019***************************
    IF gt_ekbz-vgabe = '2' AND gt_ekbz-shkzg = 'S'.
      gw_final-doctype = 'Invoice'.
    ELSEIF gt_ekbz-vgabe = '3' AND gt_ekbz-shkzg = 'S'.
      gw_final-doctype = 'Subsequent Debit Note'.
    ELSEIF gt_ekbz-vgabe = '3' AND gt_ekbz-shkzg = 'H'.
      gw_final-doctype = 'Subsequent Credit Note'.
    ELSEIF gt_ekbz-vgabe = '2' AND gt_ekbz-shkzg = 'H'.
      gw_final-doctype = 'Credit Note'.
    ENDIF.
********************************************************************************


    READ TABLE gt_ekko WITH KEY ebeln = gw_final-ebeln .
    IF sy-subrc IS INITIAL  .
      MOVE-CORRESPONDING gt_ekko TO gw_final .
      READ TABLE gt_ekpo WITH KEY ebeln = gt_ekbz-ebeln ."ebelp = gt_ekbz-ebelp .
      IF sy-subrc IS INITIAL.
        gw_final-werks = gt_ekpo-werks .
        gw_final-matnr = gt_ekpo-matnr .
        gw_final-mwskz = gt_ekpo-mwskz. .
      ENDIF.

      READ TABLE gt_mseg WITH KEY ebeln = gt_ekpo-ebeln ebelp = gt_ekpo-ebelp.
      IF sy-subrc = 0.
        gw_final-budat_mkpf = gt_mseg-budat_mkpf.
      ENDIF.
*      GW_FINAL-werks = gt_ekko-werks .

      gw_final-bsart = gt_ekko-bsart.

    ENDIF.
    READ TABLE gt_rbkp WITH KEY belnr = gt_ekbz-belnr gjahr = gt_ekbz-gjahr .
    IF sy-subrc IS INITIAL.
*****************************************************************
*      IF gt_rbkp-stblg IS NOT INITIAL .
*        CLEAR : gw_final,lv_awkey .
*        CONTINUE .
*      ENDIF.
********************************************************
      gw_final-supl_invdt = gt_rbkp-bldat .  "Supplier_invoice_date
      gw_final-inv_docdt  = gt_rbkp-bldat .
      gw_final-inv_postdt = gt_rbkp-budat .

***      gw_final-plc_sup = gt_rbkp-plc_sup .
      READ TABLE gt_t005u WITH KEY  bland = gt_rbkp-plc_sup .
      IF sy-subrc IS INITIAL.
        gw_final-plc_sup = gt_t005u-bezei.
      ENDIF.
      gw_final-gsber = gt_rbkp-gsber .
      gw_final-sgtxt = gt_rbkp-sgtxt .
      gw_final-lifnr = gt_rbkp-lifnr .    "Invoicing_party
      READ TABLE gt_lfa1 WITH KEY lifnr = gw_final-lifnr .
      IF sy-subrc IS INITIAL.
        gw_final-stcd3 = gt_lfa1-stcd3 .
***        gw_final-supl_regio = gt_lfa1-regio .
        READ TABLE gt_t005u WITH KEY land1 = gt_lfa1-land1 bland = gt_lfa1-regio .
        IF sy-subrc IS INITIAL.
          gw_final-supl_regio = gt_t005u-bezei.
        ENDIF.
***        gw_final-supl_cntry = gt_lfa1-land1 .
        READ TABLE gt_t005t WITH KEY land1 = gt_lfa1-land1 .
        IF sy-subrc IS INITIAL.
          gw_final-supl_cntry = gt_t005t-landx .
        ENDIF.
        gw_final-supl_name = gt_lfa1-name1 .
      ENDIF.
    ENDIF.
    gw_final-mr_belnr = gt_ekbz-belnr .
    READ TABLE gt_rseg WITH KEY ebeln = gt_ekbz-ebeln ebelp = gt_ekbz-ebelp belnr = gt_ekbz-belnr gjahr = gt_ekbz-gjahr buzei = gt_ekbz-buzei .
    IF sy-subrc IS INITIAL.
*      gw_final-bukrs = gt_rseg-bukrs .
*      gw_final-mwskz = gt_rseg-mwskz .
      gw_final-meins = gt_rseg-bstme ."meins .
*      gw_final-matnr = gt_rseg-matnr .

    ENDIF.

    READ TABLE gt_material WITH KEY matnr = gw_final-matnr .
    IF sy-subrc IS INITIAL.
      gw_final-maktx = gt_material-maktx .
      gw_final-mtart = gt_material-mtart .
      gw_final-matkl = gt_material-matkl .
    ENDIF.
    READ TABLE gt_marc WITH KEY matnr = gw_final-matnr .
    IF sy-subrc IS INITIAL.
      gw_final-steuc = gt_marc-steuc .
    ENDIF.

*--> FI Document ->
    lv_awkey = |{ gt_ekbz-belnr }{ gt_ekbz-gjahr }|.
    SELECT SINGLE belnr gjahr xblnr xblnr_alt awref_rev xreversing FROM bkpf
      INTO ( gw_final-fi_belnr , gw_final-gjahr , gw_final-invoice , gw_final-odn , gw_final-awref_rev , gw_final-xreversing  )
      WHERE awkey = lv_awkey AND glvor = 'RMRP'.        "#EC CI_NOFIRST
*--> Basic_GL ->
    SELECT SINGLE hkont FROM bseg INTO gw_final-hkont WHERE bukrs = '2022'
           AND  belnr = gw_final-fi_belnr AND gjahr = gw_final-gjahr AND xhres = abap_true AND hkont <> ' '.
    gw_final-gjahr = gt_ekbz-gjahr .
*--> Get_TDS ->  <- 07.06.2019 12:33:44
    PERFORM get_tds .
*    gw_final-grs_value = gt_ekbz-dmbtr . "Gross     *******************
*--> GL_Desc ->  <- 31.05.2019 18:16:43
    IF gt_final[] IS INITIAL.
      SELECT SINGLE txt50 FROM skat INTO gw_final-gl_desc
        WHERE spras = sy-langu AND ktopl  = gw_final-bukrs
        AND saknr = gw_final-hkont.
    ELSE .
      READ TABLE gt_final INTO dummy01 WITH KEY hkont = gw_final-hkont TRANSPORTING gl_desc.
      IF sy-subrc IS INITIAL.
        gw_final-gl_desc = dummy01-gl_desc .
      ELSE .
        SELECT SINGLE txt50 FROM skat INTO gw_final-gl_desc
        WHERE spras = sy-langu AND ktopl  = gw_final-bukrs
        AND saknr = gw_final-hkont.
      ENDIF.
    ENDIF.


    gw_final-menge = gt_ekbz-menge .

***    READ TABLE gt_rbtx WITH KEY belnr = gt_ekbz-belnr gjahr = gt_ekbz-gjahr mwskz = gw_final-mwskz .
***    IF sy-subrc IS INITIAL.
***      gw_final-grs_value = gt_rbtx-fwbas .      "Taxable_amount
***    ENDIF.

    LOOP AT gt_rseg WHERE ebeln = gt_ekbz-ebeln AND ebelp = gt_ekbz-ebelp AND belnr = gt_ekbz-belnr AND zaehk = gt_ekbz-zaehk AND gjahr = gt_ekbz-gjahr AND buzei = gt_ekbz-buzei.

      CASE gt_rseg-kschl.
*        WHEN 'ZOFR' OR 'ZOFV' .
*          gw_final-zocean = gw_final-zocean +  gt_rseg-wrbtr .
*        WHEN 'ZOI2' OR 'ZOIN' .
*          gw_final-zins = gw_final-zins +  gt_rseg-wrbtr .
        WHEN 'JCDB' OR 'JCUC' OR 'JSHE'  OR 'ZJCU' OR 'ZSWC' OR 'ZSWU' .
          gw_final-zbasc = gw_final-zbasc +  gt_rseg-wrbtr .
        WHEN 'JEDB' OR 'JEDS' .
          gw_final-zeces = gw_final-zeces +  gt_rseg-wrbtr .
*        WHEN 'ZAN2' OR 'ZAND' .
*          gw_final-zant = gw_final-zant +  gt_rseg-wrbtr .
*        WHEN 'ZAGC' OR 'ZCFS' OR 'ZCLC'  .
*          gw_final-zagen = gw_final-zagen +  gt_rseg-wrbtr .
        WHEN 'ZFRA' OR 'ZFRB' OR 'ZFRC' OR 'ZFRR' OR 'ZFRD' OR 'ZFRE' OR 'ZFRF' OR 'FRA1' OR 'FRB1' OR 'FRC1' OR 'FRC2' OR 'ZFRL' OR 'ZFBB' OR 'FRB2' OR 'FRA2' .
          gw_final-zfrght = gw_final-zfrght + gt_rseg-wrbtr .
*        WHEN 'ZIN1' OR 'ZIN2'.
*          gw_final-zins = gw_final-zins + gt_rseg-wrbtr."wa_prcd-kwert .
        WHEN 'ZLBR' .  "OR 'ZPK3' OR 'ZPM3' .
          gw_final-zins = gw_final-zins + gt_rseg-wrbtr."wa_prcd-kwert .
        WHEN  'ZPK3' OR 'ZPM3' OR 'ZPK1' OR 'ZPK2' OR 'ZPM1' OR 'ZPM2' .
          gw_final-zpkg = gw_final-zpkg + gt_rseg-wrbtr."wa_prcd-kwert .
        WHEN  'ZMIS' .
          gw_final-zmis = gw_final-zmis + gt_rseg-wrbtr."wa_prcd-kwert .
        WHEN 'ZCSC'  .
*            gw_final-cessp = gt_konp-kbetr .  "Per MT/KG
          gw_final-cess = gw_final-cess + gt_rseg-wrbtr .
        WHEN OTHERS ."'ZHSS' OR 'ZHSV' OR 'ZOTH' OR 'ZRBE' OR 'ZSLC' OR 'ZSTD' OR 'ZSTP' OR 'ZSVB' OR 'ZSVL' OR 'ZWFC' OR 'ZTAX' OR 'ZDCC' OR 'ZCDC'.
          gw_final-zoth = gw_final-zoth +  gt_rseg-wrbtr .
      ENDCASE .
      IF gt_rseg-customs_val IS NOT INITIAL.
        gw_final-ascval = gw_final-ascval + gt_rseg-customs_val .
      ENDIF.
    ENDLOOP.
*--> If_taxable_not_found

    gw_final-grs_value =    gw_final-zins +  gw_final-zbasc
     + gw_final-zfrght  + gw_final-zoth +  gw_final-zeces + gw_final-zpkg + gw_final-zmis .

    IF gw_final-grs_value IS INITIAL.
      gw_final-grs_value = gt_ekbz-dmbtr . "Gross     *******************
    ENDIF.



    " + gw_final-zant  + gw_final-zagen gw_final-zocean +
    gw_final-base_amt = gw_final-grs_value + gw_final-ascval  .

*--> GST_Based_on_tax_code ->  <- 22.05.2019 1:19:22 PM
    LOOP AT  gt_a003 WHERE mwskz = gw_final-mwskz .
      LOOP AT  gt_konp WHERE knumh = gt_a003-knumh  .
        CASE gt_konp-kschl .
          WHEN 'JICG' OR 'JICN'.
            gw_final-cgstp = ( gt_konp-kbetr * 10 ) / 100.
            gw_final-cgst = ( gw_final-base_amt * ( gw_final-cgstp / 100 ) ).
          WHEN 'JISG' OR ' JISN'.
            gw_final-sgstp = ( gt_konp-kbetr * 10 ) / 100.
            gw_final-sgst = ( gw_final-base_amt * ( gw_final-sgstp / 100 ) ).
          WHEN 'JIIG' OR 'JIMD' OR 'JIIN' OR 'JIMN'. .
            gw_final-igstp = ( gt_konp-kbetr * 10 ) / 100.
            gw_final-igst = ( gw_final-base_amt * ( gw_final-igstp / 100 ) ).
          WHEN 'JIUG' OR 'JIUN'.
            gw_final-ugstp = ( gt_konp-kbetr * 10 ) / 100 .
            gw_final-ugst = ( gw_final-base_amt * ( gw_final-ugstp / 100 ) ).
          WHEN 'ZVAT'.  "VAT
            gw_final-vatp = ( gt_konp-kbetr * 10 ) / 100 .
            gw_final-vat = ( gw_final-base_amt * ( gw_final-vatp / 100 ) ).
*          WHEN 'JCUC' OR 'JCIN' .
          WHEN 'ZCSC'  .
            gw_final-cessp = gt_konp-kbetr .  "Per MT/KG
            gw_final-cess = gw_final-menge * gw_final-cessp .
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDLOOP .

****    IF gw_final-tot_taxamt IS INITIAL.
*****--> Total_tax_amt ->  <- 23.05.2019 11:36:19
****      gw_final-tot_taxamt = gw_final-cgst + gw_final-sgst + gw_final-igst + gw_final-ugst .
****    ENDIF.

    gw_final-waers01 = gw_final-waers = 'INR' .
*    gw_final-waers = gt_ekbz-waers .
**    gw_final-invoice = gt_ekbz-xblnr .    "Invoice
*    gw_final-tot_inv = gt_ekbz-reewr .
    gw_final-frbnr = gt_ekbz-frbnr .
*    GW_FINAL-mwskz = gt_ekbz-mwskz .
*--> Total_tax_amt ->  <- 23.05.2019 11:36:19
    IF gw_final-grs_value IS NOT INITIAL AND gw_final-menge IS NOT INITIAL.
      gw_final-rate = gw_final-grs_value / gw_final-menge .
    ENDIF.

    gw_final-grs_value01 = gw_final-grs_value .
    gw_final-tot_taxamt = gw_final-cgst + gw_final-sgst + gw_final-igst + gw_final-ugst.   " + gw_final-cess.

*    READ TABLE smtvarvc INTO swtvarvc WITH KEY name = 'ZPR01_RCM' low = gw_final-mwskz .
*    IF sy-subrc IS NOT INITIAL.
*      gw_final-zrev = sno .
**--> total_invoice ->  <- 23.05.2019 11:36:33
*      gw_final-tot_inv = gw_final-base_amt + gw_final-tot_taxamt .
*      gw_final-tot_inv_tds = gw_final-tot_inv + gw_final-tds_amt  .
*    ELSE.
*      gw_final-zrev = syes .
**--> total_invoice ->  <- 23.05.2019 11:36:33
*      gw_final-tot_inv = gw_final-base_amt + gw_final-bnkan .
*      gw_final-tot_inv_tds = gw_final-tot_inv + gw_final-tds_amt .
*    ENDIF.    "RCM_TAX



******************Changed by ppadhy**********************
    IF  gw_final-mwskz = '30' OR gw_final-mwskz = '3A' OR gw_final-mwskz = '3B' OR gw_final-mwskz = '3C' OR gw_final-mwskz = '3D' OR gw_final-mwskz = '3E'
        OR gw_final-mwskz = '3F' OR gw_final-mwskz = '3G' OR gw_final-mwskz = '3H' OR gw_final-mwskz = '3I' OR gw_final-mwskz = '3J'  OR
        gw_final-mwskz = '40' OR gw_final-mwskz = '4A' OR gw_final-mwskz = '4B' OR gw_final-mwskz = '4C' OR gw_final-mwskz = '4D' OR gw_final-mwskz = '4E'
        OR gw_final-mwskz = '4F' OR gw_final-mwskz = '4G' OR gw_final-mwskz = '4H' OR gw_final-mwskz = '4I' OR gw_final-mwskz = '4J'.
      gw_final-zrev = syes .
      gw_final-tot_inv = gw_final-base_amt + gw_final-bnkan .
*      gw_final-tot_inv_tds = gw_final-tot_inv + gw_final-tds_amt .    "commented on 04.01.2019
    ELSE.
      gw_final-zrev = sno .
      gw_final-tot_inv = gw_final-base_amt + gw_final-tot_taxamt .
*      gw_final-tot_inv_tds = gw_final-tot_inv + gw_final-tds_amt .    "commented on 04.01.2019
    ENDIF.

************************************added on 04.01.2020***********************************************************
    IF gw_final-shkzg = 'H'.
      gw_final-tot_inv_tds = gw_final-tot_inv - gw_final-tds_amt  .
    ELSE.
      gw_final-tot_inv_tds = gw_final-tot_inv + gw_final-tds_amt .
    ENDIF.

********************************************************************************************
    IF gw_final-kursf IS INITIAL.
      gw_final-kursf = 1.
    ENDIF.

    slifnr = |{ gw_final-lifnr ALPHA = OUT }| .
    READ TABLE stvarv WITH KEY low = slifnr TRANSPORTING NO FIELDS .
    IF sy-subrc IS INITIAL  .
      CLEAR : gw_final-rate , gw_final-grs_value01 , gw_final-grs_value  , gw_final-tot_inv,gw_final-tot_inv_tds , gw_final-lcost.  "gw_final-base_amt
      gw_final-tot_inv_tds = gw_final-tot_inv = gw_final-tot_taxamt .
    ENDIF.


    IF  gw_final-mwskz = '50' OR gw_final-mwskz = '5A' OR gw_final-mwskz = '5B' OR gw_final-mwskz = '5C' OR gw_final-mwskz = '5D' OR gw_final-mwskz = '5E'
       OR gw_final-mwskz = '5F' OR gw_final-mwskz = '5G' OR gw_final-mwskz = '5H' OR gw_final-mwskz = '5I'   .
      gw_final-zinp = syes .
      gw_final-lcost = gw_final-base_amt + gw_final-bnkan.    "TAXABLE_Amt
    ELSE.
      gw_final-zinp = sno .
      gw_final-lcost = gw_final-tot_inv + gw_final-bnkan.
    ENDIF.


    READ TABLE stvarv WITH KEY low = slifnr TRANSPORTING NO FIELDS .
    IF sy-subrc IS INITIAL  .
      CLEAR : gw_final-lcost.  "gw_final-base_amt
    ENDIF.


*    IF gw_final-shkzg = 'H'.
    IF gw_final-xreversing = 'X'.
      gw_final-menge = gw_final-menge * -1.
      gw_final-grs_value =  gw_final-grs_value * -1.
      gw_final-grs_value01 =  gw_final-grs_value01 * -1.
      gw_final-ascval = gw_final-ascval * -1.
      gw_final-zfrght = gw_final-zfrght * -1.
      gw_final-zpkg = gw_final-zpkg * -1.
      gw_final-zins = gw_final-zins * -1.
      gw_final-zbasc = gw_final-zbasc * -1.
      gw_final-zeces = gw_final-zeces * -1.
      gw_final-zoth = gw_final-zoth * -1.
      gw_final-base_amt = gw_final-base_amt * -1.
      gw_final-cgst = gw_final-cgst * -1.
      gw_final-sgst = gw_final-sgst * -1.
      gw_final-igst = gw_final-igst * -1.
      gw_final-tot_taxamt = gw_final-tot_taxamt * -1.
      gw_final-tot_inv = gw_final-tot_inv * -1.
      gw_final-bnkan = gw_final-bnkan * -1.
      gw_final-lcost = gw_final-lcost * -1.
      gw_final-zmis = gw_final-zmis * -1.
*      gw_final-tot_inv_tds = gw_final-tot_inv_tds * -1.


    ENDIF.


    APPEND gw_final TO gt_final01 .
    CLEAR gw_final .
  ENDLOOP.



  SORT gt_final01 BY ebeln ebelp mr_belnr fi_belnr gjahr buzei .
  DELETE gt_final01 WHERE werks NOT IN s_werks[] .
  DELETE ADJACENT DUPLICATES FROM gt_final01 COMPARING ebeln ebelp mr_belnr fi_belnr gjahr buzei .
  APPEND LINES OF gt_final01 TO gt_final .

  DELETE gt_final WHERE lifnr NOT IN s_lifnr[].
  IF r1 IS NOT INITIAL.
    DELETE gt_final WHERE bsart = 'ZTSR'.
  ELSEIF r3 IS NOT INITIAL.
    DELETE gt_final WHERE bsart <> 'ZTSR'.
  ENDIF.
***  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GUI_STATUS_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->p_perc text
*      -->p_text text
*&---------------------------------------------------------------------*
FORM gui_status_display USING p_perc TYPE i
                              p_text TYPE text100.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = p_perc
      text       = p_text.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_tds .
*--> Check_for_initial_document ->  <- 23.05.2019 17:29:24
  READ TABLE gt_final INTO DATA(dummy) WITH KEY mr_belnr = gw_final-mr_belnr gjahr = gw_final-gjahr  .
  IF sy-subrc IS NOT INITIAL.
    READ TABLE gt_final01 INTO dummy WITH KEY mr_belnr = gw_final-mr_belnr gjahr = gw_final-gjahr   .
  ENDIF.
*--> Withholding_details ->  <- 23.05.2019 13:56:56
  IF sy-subrc IS NOT INITIAL.

    CLEAR wa_with_item .
    SELECT SINGLE bukrs belnr gjahr buzei witht wt_withcd qsatz wt_qbshb FROM with_item INTO wa_with_item WHERE bukrs = '2022'
                 AND  belnr = gw_final-fi_belnr AND gjahr = gw_final-gjahr AND witht IN ('W1','W2','W3','W4','W5','W6','W7','98','99') AND hkont <> ' '.
    IF sy-subrc IS INITIAL . "AND wa_with_item-qsatz IS NOT INITIAL.
***      SELECT SINGLE * FROM lfbw INTO wa_lfbw WHERE lifnr = gw_final-lifnr AND witht = wa_with_item-witht.
      READ TABLE gt_lfbw WITH KEY lifnr = gw_final-lifnr witht = wa_with_item-witht .
      gw_final-wt_exnr   = gt_lfbw-wt_exnr.
      gw_final-wt_exrt   = gt_lfbw-wt_exrt.
      gw_final-wt_exdf   = gt_lfbw-wt_exdf.
      gw_final-wt_exdt   = gt_lfbw-wt_exdt.


      READ TABLE gt_t059w WITH KEY wt_wtexrs = gt_lfbw-wt_wtexrs  spras = 'EN'  land1 = 'IN'.
      IF sy-subrc IS INITIAL.
        gw_final-wt_wtexrs = gt_t059w-text30.
      ENDIF.


***      IF wa_with_item-witht CP 'W*'.
      READ TABLE gt_t059zt WITH KEY spras = 'EN' land1 = 'IN'
      witht = wa_with_item-witht wt_withcd = wa_with_item-wt_withcd. .
      IF sy-subrc IS INITIAL.
        gw_final-tds_desc = gt_t059zt-text40.
      ENDIF.

*      IF lv_cnt = 1.
      gw_final-tds_amt     = wa_with_item-wt_qbshb.
      gw_final-tdsp     = wa_with_item-qsatz.
*      ENDIF.
      gw_final-tds_code     = wa_with_item-wt_withcd.
      gw_final-tds_type     = wa_with_item-witht.
    ENDIF.
***  ENDIF.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_output1 .

  DATA: it_fcat   TYPE slis_t_fieldcat_alv, "WITH HEADER LINE,
        wa_fcat   TYPE slis_fieldcat_alv,
        wa_layout TYPE slis_layout_alv,
        it_sort   TYPE slis_t_sortinfo_alv,
        wa_sort   TYPE slis_sortinfo_alv.

  wa_fcat-fieldname            = 'BUKRS'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Company Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'BSART'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Document Type'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'EBELN'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'PO No'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

**  wa_fcat-fieldname            = 'EBELP'.
**  wa_fcat-tabname              = 'GT_FINAL'.
**  wa_fcat-seltext_l            = 'PO Item'.
***  wa_fcat-outputlen            =  15.
**  APPEND wa_fcat TO it_fcat.
**  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'BEDAT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'PO Document Date'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'EKNAM'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Purchasing Group'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'WERKS'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Plant'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'LIFNR'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Vendor Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SUPL_NAME'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Vendor Name'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SUPL_REGIO'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Supplier Region'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'STCD3'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'GSTN No'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

**  wa_fcat-fieldname            = 'SUPL_REGIO'.
**  wa_fcat-tabname              = 'GT_FINAL'.
**  wa_fcat-seltext_l            = 'Supplier Region'.
***  wa_fcat-outputlen            =  15.
**  APPEND wa_fcat TO it_fcat.
**  CLEAR wa_fcat.

**  wa_fcat-fieldname            = 'BUDAT_MKPF'.
**  wa_fcat-tabname              = 'GT_FINAL'.
**  wa_fcat-seltext_l            = 'Goods Receipt Posting Date'.
***  wa_fcat-outputlen            =  15.
**  APPEND wa_fcat TO it_fcat.
**  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'MR_BELNR'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'MIRO Document No'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'FI_BELNR'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'FI Document No'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'INV_DOCDT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Invoice Document Date'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'INV_POSTDT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Invoice Posting Date'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.
*********************************************************************************************************

  wa_fcat-fieldname            = 'SGTXT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Reference'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'GSBER'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Business Area Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'GTEXT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Business Area Description'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'WGBEZ60'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Material Group'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'STEUC'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'HSN Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'MWSKZ'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Tax Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname          =  'BASE_AMT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Taxable Value'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'CGSTP'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'CGST %'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'CGST'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'CGST Amount'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SGSTP'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'SGST %'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SGST'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'SGST Amount'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'IGSTP'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'IGST %'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'IGST'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'IGST Amount'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

**  wa_fcat-fieldname            = 'TOT_TAXAMT'.
**  wa_fcat-tabname              = 'GT_FINAL'.
**  wa_fcat-seltext_l            = 'Total Tax Amt.'.
***  wa_fcat-outputlen            =  15.
**  APPEND wa_fcat TO it_fcat.
**  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'DISC'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Discount1'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'DISC1'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Discount2'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'DISC2'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Discount3'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'TOT_INV'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Total Amount'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.
*************************************************************************************************************

  wa_layout-colwidth_optimize = 'X'.
  wa_layout-zebra = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'TOP-OF-PAGE '
      is_layout              = wa_layout
      it_fieldcat            = it_fcat[]
      it_sort                = it_sort
      i_default              = 'X'
*     it_events              = it_events
      i_save                 = 'A'
    TABLES
      t_outtab               = gt_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.

ENDFORM.

FORM top-of-page.

*  *ALV Header declarations
  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        lv_name1      TYPE name1,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c,
        lv_top(255)   TYPE c.

  wa_header-typ  = 'H'.
  wa_header-info = 'Super Saravana Store (Purchase Register) '.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

  wa_header-typ  = 'S'.
  wa_header-key = 'Date: '.

  CONCATENATE  sy-datum+6(2) '.'
               sy-datum+4(2) '.'
               sy-datum(4) INTO wa_header-info.   "todays date
  APPEND wa_header TO t_header.
  CLEAR: wa_header.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PURCH_HISTORY_SER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_purch_history_ser .

  SELECT
  ekbe~ebeln,
  ekbe~ebelp,
  ekbe~zekkn,
  ekbe~vgabe,
  ekbe~gjahr,
  ekbe~belnr,
  ekbe~buzei,
  ekbe~bewtp,
  ekbe~reewr,
  ekko~bsart
  FROM ekbe AS ekbe
  INNER JOIN ekko AS ekko ON ekbe~ebeln = ekko~ebeln
  WHERE ekko~bsart = 'ZTSR'
  AND budat IN @s_budat AND werks IN @s_werks
  AND gjahr IN @s_gjahr AND ekbe~vgabe = '2'"AND bewtp = 'E'
  INTO TABLE @DATA(it_ekbe).                       "#EC CI_NO_TRANSFORM

  IF it_ekbe IS NOT INITIAL.
    SELECT
      mblnr,
      mjahr,
      zeile,
      ebeln,
      ebelp,
      sakto,
      werks,
      gsber
      FROM mseg INTO TABLE @DATA(it_mseg)
      FOR ALL ENTRIES IN @it_ekbe
      WHERE ebeln = @it_ekbe-ebeln AND ebelp = @it_ekbe-ebelp.

    SELECT
      ebeln,
      ebelp,
      mwskz
      FROM ekpo INTO TABLE @DATA(it_ekpo)
      FOR ALL ENTRIES IN @it_ekbe
      WHERE ebeln = @it_ekbe-ebeln AND ebelp = @it_ekbe-ebelp.
  ENDIF.

  IF it_ekpo IS NOT INITIAL.
    SELECT * FROM a003 INTO TABLE @DATA(it_a003)
      FOR ALL ENTRIES IN @it_ekpo WHERE mwskz = @it_ekpo-mwskz  . "#EC CI_NO_TRANSFORM
  ENDIF.

  IF it_a003 IS NOT INITIAL.
    SELECT
      knumh,
      kopos,
      mwsk1,
      kschl,
      kbetr
      FROM konp INTO TABLE @DATA(it_konp)
      FOR ALL ENTRIES IN @it_a003 WHERE knumh = @it_a003-knumh . "#EC CI_NO_TRANSFORM

    DELETE it_konp WHERE mwsk1 = '1Q' AND kschl = 'JIIG'.
  ENDIF.

  IF it_ekbe IS NOT INITIAL.
    SELECT
      bukrs,
      belnr,
      gjahr,
      buzei,
      bschl,
      ebeln,
      ebelp,
      gsber,
      dmbtr,
      kostl,
      saknr,
      hkont,
      lifnr,
      sgtxt,
      secco
      FROM bseg INTO TABLE @DATA(it_bseg)
      FOR ALL ENTRIES IN @it_ekbe
      WHERE ebeln = @it_ekbe-ebeln AND ebelp = @it_ekbe-ebelp AND bschl = '81'.
  ENDIF.

  IF it_bseg IS NOT INITIAL.
    SELECT * FROM tgsbt INTO TABLE @DATA(it_text)
      FOR ALL ENTRIES IN @it_bseg
       WHERE gsber = @it_bseg-gsber AND spras = @sy-langu.

    SELECT * FROM skat INTO TABLE @DATA(it_text_bus)
      FOR ALL ENTRIES IN @it_bseg
      WHERE saknr = @it_bseg-hkont AND spras = @sy-langu.
  ENDIF.

  IF it_bseg IS NOT INITIAL.

    SELECT
      lifnr,
      name1,
      regio,
      land1,
      stcd3
      FROM lfa1 INTO TABLE @DATA(it_lfa1)
      FOR ALL ENTRIES IN @it_bseg
      WHERE lifnr = @it_bseg-lifnr.

  ENDIF.

  IF it_lfa1 IS NOT INITIAL.

    SELECT * FROM t005u INTO TABLE @DATA(it_t005u)
      FOR ALL ENTRIES IN @it_lfa1
      WHERE land1 = @it_lfa1-land1 AND bland = @it_lfa1-regio .

  ENDIF.

  IF it_ekbe IS NOT INITIAL.
    SELECT ebeln , ebelp, gjahr, belnr, buzei, bewtp, bwart, lfgja, lfbnr, budat, bldat FROM ekbe INTO TABLE @DATA(it_ekbe_inv)
  FOR ALL ENTRIES IN @it_ekbe
  WHERE ebeln = @it_ekbe-ebeln AND ebelp = @it_ekbe-ebelp AND bewtp = 'Q'.
  ENDIF.

  TYPES  : BEGIN OF ty_awkey  ,
             awkey TYPE bkpf-awkey,
           END OF ty_awkey .
  DATA : it_awkey TYPE TABLE OF ty_awkey,
         wa_awkey TYPE ty_awkey.
*--> FI Document ->
  LOOP AT it_ekbe ASSIGNING FIELD-SYMBOL(<w_ekbe>).
    wa_awkey-awkey = <w_ekbe>-belnr && <w_ekbe>-gjahr.

    APPEND wa_awkey TO it_awkey .
    CLEAR wa_awkey .
  ENDLOOP.

  SELECT
    bkpf~belnr,
    bkpf~bukrs,
    bkpf~gjahr,
    bkpf~awkey,
    bkpf~xblnr,
    bkpf~awref_rev,
    bkpf~aworg_rev
    FROM bkpf INTO TABLE @DATA(it_bkpf)
    FOR ALL ENTRIES IN @it_awkey
    WHERE awkey  = @it_awkey-awkey AND glvor = 'RMRP' AND xreversing <> 'X'.

  LOOP AT it_bkpf ASSIGNING FIELD-SYMBOL(<w_bkpf>).
    READ TABLE it_ekbe INTO DATA(w_ekbe) WITH KEY belnr =  <w_bkpf>-awref_rev gjahr = <w_bkpf>-aworg_rev .
    IF sy-subrc = 0 .
      DELETE it_ekbe WHERE belnr =  <w_bkpf>-awref_rev AND gjahr = <w_bkpf>-aworg_rev .
    ENDIF.

    READ TABLE it_ekbe INTO DATA(w_ekbe1) WITH KEY belnr = <w_bkpf>-awkey+0(10).
    IF sy-subrc = 0.
      CHECK <w_bkpf>-awref_rev IS NOT INITIAL.
      DELETE it_ekbe WHERE belnr = <w_bkpf>-awkey+0(10).
    ENDIF.

  ENDLOOP.

*--> MIRO_Document ->
**    gw_final-mr_belnr = gt_ekbe-belnr .


  BREAK ppadhy.
  LOOP AT it_ekbe INTO DATA(wa_ekbe).

    gw_final-ebeln     = wa_ekbe-ebeln.
    gw_final-bsart     = wa_ekbe-bsart.
    gw_final-mr_belnr  = wa_ekbe-belnr.

    READ TABLE it_bseg INTO DATA(wa_bseg) WITH KEY ebeln = wa_ekbe-ebeln ebelp = wa_ekbe-ebelp.
    IF sy-subrc = 0.
      gw_final-bukrs     = wa_bseg-bukrs.
      gw_final-gsber     = wa_bseg-gsber.
      gw_final-hkont     = wa_bseg-hkont.
      gw_final-kostl     = wa_bseg-kostl.
      gw_final-secco     = wa_bseg-secco.
      gw_final-grs_value = wa_bseg-dmbtr.
      gw_final-base_amt  = gw_final-grs_value.
    ENDIF.

    READ TABLE it_bkpf INTO DATA(wa_bkpf) WITH KEY awkey = wa_ekbe-belnr && wa_ekbe-gjahr.
    IF sy-subrc = 0.
      gw_final-fi_belnr  = wa_bkpf-belnr.
      gw_final-sgtxt     = wa_bkpf-xblnr.
    ENDIF.

    READ TABLE it_text_bus INTO DATA(wa_text_bus) WITH KEY saknr = wa_bseg-hkont.
    IF sy-subrc = 0.
      gw_final-gl_desc = wa_text_bus-txt50.
    ENDIF.

    READ TABLE it_text INTO DATA(wa_text) WITH KEY gsber = wa_bseg-gsber.
    IF sy-subrc = 0.
      gw_final-gtext = wa_text-gtext.
    ENDIF.

    READ TABLE it_mseg INTO DATA(wa_mseg) WITH KEY ebeln = wa_ekbe-ebeln ebelp = wa_ekbe-ebelp.
    IF sy-subrc = 0.
      gw_final-werks = wa_mseg-werks.
    ENDIF.

    READ TABLE it_lfa1 INTO DATA(wa_lfa1) WITH KEY lifnr = wa_bseg-lifnr.
    IF sy-subrc = 0.
      gw_final-lifnr     = wa_lfa1-lifnr.
      gw_final-supl_name = wa_lfa1-name1.
      gw_final-stcd3     = wa_lfa1-stcd3.
    ENDIF.

    READ TABLE it_t005u INTO DATA(wa_t005u) WITH KEY land1 = wa_lfa1-land1 bland = wa_lfa1-regio .
    IF sy-subrc IS INITIAL.
      gw_final-supl_regio = wa_t005u-bezei.
    ENDIF.

    READ TABLE it_ekbe_inv INTO DATA(wa_ekbe_inv) WITH KEY ebeln = wa_ekbe-ebeln  ebelp = wa_ekbe-ebelp  bewtp = 'Q'.
    IF sy-subrc = 0.
      gw_final-inv_postdt = wa_ekbe_inv-budat.
      gw_final-inv_docdt  = wa_ekbe_inv-bldat.
    ENDIF.

    READ TABLE it_ekpo INTO DATA(wa_ekpo) WITH KEY ebeln = wa_ekbe-ebeln  ebelp = wa_ekbe-ebelp.
    IF sy-subrc = 0.
      gw_final-mwskz = wa_ekpo-mwskz.
    ENDIF.

    gw_final-base_amt = gw_final-grs_value.    " + gw_final-bnkan  .
*    BREAK ppadhy.
*--> GST_Based_on_tax_code ->
    LOOP AT  it_a003 INTO DATA(wa_a003) WHERE mwskz = wa_ekpo-mwskz .
      LOOP AT  it_konp INTO DATA(wa_konp) WHERE knumh = wa_a003-knumh  .
        CASE wa_konp-kschl .
          WHEN 'JICG' .
            gw_final-cgstp = ( wa_konp-kbetr * 10 ) / 100.
            gw_final-cgst  = ( gw_final-grs_value * ( gw_final-cgstp / 100 ) ).
          WHEN 'JISG' .
            gw_final-sgstp = ( wa_konp-kbetr * 10 ) / 100.
            gw_final-sgst  = ( gw_final-grs_value * ( gw_final-sgstp / 100 ) ).
          WHEN 'JIIG' .
            gw_final-igstp = ( wa_konp-kbetr * 10 ) / 100.
            gw_final-igst  = ( gw_final-grs_value * ( gw_final-igstp / 100 ) ).

          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDLOOP .

    gw_final-tot_taxamt = gw_final-cgst + gw_final-sgst + gw_final-igst.
    gw_final-tot_inv    = gw_final-grs_value + gw_final-tot_taxamt.

    APPEND gw_final TO gt_final.
    CLEAR gw_final.
  ENDLOOP.

  BREAK ppadhy.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA_SER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data_ser .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT1_SER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_output1_ser .

  DATA: it_fcat   TYPE slis_t_fieldcat_alv, "WITH HEADER LINE,
        wa_fcat   TYPE slis_fieldcat_alv,
        wa_layout TYPE slis_layout_alv,
        it_sort   TYPE slis_t_sortinfo_alv,
        wa_sort   TYPE slis_sortinfo_alv.

  wa_fcat-fieldname            = 'BUKRS'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Company Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'BSART'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Document Type'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'EBELN'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'PO No'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'WERKS'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Plant'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'LIFNR'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Vendor Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SUPL_NAME'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Vendor Name'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SUPL_REGIO'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Supplier Region'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'STCD3'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'GSTN No'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

***  wa_fcat-fieldname            = 'SECCO'.
***  wa_fcat-tabname              = 'GT_FINAL'.
***  wa_fcat-seltext_l            = 'SAC Code'.
****  wa_fcat-outputlen            =  15.
***  APPEND wa_fcat TO it_fcat.
***  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'MR_BELNR'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'MIRO Document No'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'FI_BELNR'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'FI Document No'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'INV_DOCDT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Invoice Document Date'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'INV_POSTDT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Invoice Posting Date'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'HKONT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'G/L Account'.
  wa_fcat-datatype             = 'NUMC'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'GL_DESC'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'G/L Description'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.
*********************************************************************************************************

  wa_fcat-fieldname            = 'SGTXT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Reference'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'GSBER'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Business Area Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'GTEXT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Business Area Description'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'MWSKZ'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Tax Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname          =  'BASE_AMT'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Taxable Value'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'CGSTP'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'CGST %'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'CGST'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'CGST Amount'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SGSTP'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'SGST %'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'SGST'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'SGST Amount'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'IGSTP'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'IGST %'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'IGST'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'IGST Amount'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'TOT_INV'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Total Amount'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'KOSTL'.
  wa_fcat-tabname              = 'GT_FINAL'.
  wa_fcat-seltext_l            = 'Cost Center'.
  wa_fcat-datatype             = 'NUMC'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.
*************************************************************************************************************

  wa_layout-colwidth_optimize = 'X'.
  wa_layout-zebra = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'TOP-OF-PAGE '
      is_layout              = wa_layout
      it_fieldcat            = it_fcat[]
      it_sort                = it_sort
      i_default              = 'X'
*     it_events              = it_events
      i_save                 = 'A'
    TABLES
      t_outtab               = gt_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.

ENDFORM.
