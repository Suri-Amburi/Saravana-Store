*&---------------------------------------------------------------------*
*& Include          ZFI_PUR_WITHOUT_PO_F01
*&---------------------------------------------------------------------*

FORM get_data4 .
  BREAK ppadhy.
  DATA(s_cond1) = |blart IN ( 'KR' , 'KG' )| .

  SELECT
    bukrs
    belnr
    gjahr
    xblnr
    xblnr_alt
    kursf
    blart
    stblg
    budat
    FROM bkpf INTO TABLE gt_bkpf "for all entries in gt_bseg
    WHERE budat IN s_budat AND (s_cond1) AND xreversal = space .

  DATA(s_cond) = |bschl IN ( '31','40' , '21' , '50' )|." AND ktosl IN ( 'EGK' ,' '  )| .

  IF gt_bkpf IS NOT INITIAL.
    SELECT
      belnr
      gjahr
      budat
      stcd3
      bldat
      lifnr
      waers
      xblnr
      rbstat
      stblg
      mwskz1
      regio
      plc_sup
      knumve
      sgtxt
      FROM rbkp INTO TABLE gt_rbkp
      FOR ALL ENTRIES IN gt_bkpf
      WHERE belnr = gt_bkpf-belnr AND gjahr = gt_bkpf-gjahr AND lifnr IN s_lifnr.

    SELECT
       bukrs
       belnr
       gjahr
       buzei
       bschl
       koart
       umskz
       vbel2
       posn2
       hsn_sac
       lifnr
       h_budat
       h_bldat
       menge
       meins
       wrbtr
       h_waers
       h_blart
       werks
       txgrp
       kunnr
       hkont
       mwskz
       ktosl
       plc_sup
       bupla
       gsber
       kostl
       pswbt
       anln1
       anln2
       qsskz
       buzid
       sgtxt
       FROM bseg INTO TABLE gt_bseg  FOR ALL ENTRIES IN gt_bkpf
      WHERE belnr   = gt_bkpf-belnr AND gjahr = gt_bkpf-gjahr "AND lifnr IN s_lifnr
*     AND koart IN ( 'K','S','D' )  AND  bschl IN ( '31','40','11' ) AND ktosl IN ( 'EGK' ,' ' ,'AGD' ) .
       AND koart IN ( 'K','S', 'A' )  AND (s_cond) AND gsber IN s_gsber."AND ktosl IN ( 'EGK' ,' '  ) . ",'21','22','50' "bschl IN ( '31','40' )
  ENDIF.

  IF gt_bseg  IS NOT INITIAL.
    SELECT
      lifnr
      land1
      name1
      name2
      name3
      name4
      regio
      ven_class
      stcd3
      j_1ipanref
      FROM lfa1 INTO TABLE  gt_lfa1
*     FOR ALL ENTRIES IN gt_bseg
      WHERE  lifnr IN s_lifnr.

    SELECT
      ktopl
      saknr
      txt20
      FROM skat INTO TABLE it_skat FOR ALL ENTRIES IN gt_bseg
      WHERE ktopl = gt_bseg-bukrs AND saknr = gt_bseg-hkont.
  ENDIF.

  DATA(indic) = 'S'.

  IF gt_bseg IS NOT INITIAL.
    SELECT
      bukrs
      belnr
      gjahr
      buzei
      mwskz
      hwbas
      fwbas
      hwste
      fwste
      ktosl
      kschl
      kbetr
      txgrp
      shkzg
      FROM bset INTO TABLE gt_bset FOR ALL ENTRIES IN gt_bseg
      WHERE belnr  = gt_bseg-belnr AND gjahr = gt_bseg-gjahr ."AND shkzg = indic .
  ENDIF.

  SELECT
    ktopl
    saknr
    txt20
    FROM skat INTO TABLE it_skat FOR ALL ENTRIES IN gt_bseg
    WHERE ktopl = gt_bseg-bukrs AND saknr = gt_bseg-hkont.

  IF gt_bseg IS NOT INITIAL.
    SELECT
      lifnr
      land1
      name1
      name2
      name3
      name4
      regio
      ven_class
      stcd3
      j_1ipanref
      FROM lfa1 INTO TABLE  gt_lfa1
      FOR ALL ENTRIES IN gt_bseg WHERE  lifnr = gt_bseg-lifnr.

    SELECT
      kunnr
      land1
      name1
      name2
      name3
      name4
      regio
      stcd3
      j_1ipanref
      FROM kna1  INTO TABLE  gt_kna1
      FOR ALL ENTRIES IN gt_bseg WHERE kunnr = gt_bseg-kunnr.

    SELECT
      vbeln
      posnr
      matnr
      matwa
      pmatn
      kwmeng
      vrkme
      FROM vbap INTO TABLE gt_vbap
      FOR ALL ENTRIES IN gt_bseg
      WHERE vbeln = gt_bseg-vbel2  AND posnr = gt_bseg-posn2.

    SELECT * FROM t604n INTO TABLE gt_t604n FOR ALL ENTRIES IN
     gt_bseg WHERE steuc  = gt_bseg-hsn_sac AND spras = 'EN' .

    IF  gt_vbap IS NOT INITIAL.
      SELECT
        matnr
        spras
        maktx
        maktg
        FROM makt INTO TABLE gt_makt
        FOR ALL ENTRIES IN gt_vbap
        WHERE matnr = gt_vbap-matnr AND spras = 'EN'.
    ENDIF.
  ENDIF.
  CLEAR: s_cond,s_cond1.
ENDFORM.

FORM mov_fin4 .

  LOOP AT gt_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg>).

    IF <ls_bseg>-sgtxt IS NOT INITIAL.
      DATA(lv_sgtxt) = <ls_bseg>-sgtxt.
    ENDIF.

    IF <ls_bseg>-sgtxt IS INITIAL.
      <ls_bseg>-sgtxt = lv_sgtxt.
    ENDIF.

*    CLEAR lv_sgtxt.

  ENDLOOP.

*  delete gt_bseg WHERE koart = 'K'.

  BREAK ppadhy.
  DATA(s_bschl) = '40' .

  LOOP AT  gt_bkpf   INTO  gw_bkpf.

    n = n + 1.
    gw_fin-slno  =  n .
    gw_fin-blart = gw_bkpf-blart .

    LOOP AT gt_bseg  INTO gw_bseg WHERE belnr =  gw_bkpf-belnr AND gjahr = gw_bkpf-gjahr ." AND ktosl = ' '." AND bschl = s_bschl.

      CLEAR:wa_with_item,wa_t059zt.
      SELECT SINGLE
              bukrs
              belnr
              gjahr
              buzei
              witht
              wt_withcd
              qsatz
              wt_qbshb
              FROM with_item INTO wa_with_item
              WHERE bukrs = gw_bkpf-bukrs AND  belnr = gw_bkpf-belnr AND gjahr = gw_bkpf-gjahr
              AND witht IN ('W1','W2','W3','W4','W5','W6','W7','98','99').

      READ TABLE gt_rbkp INTO gw_rbkp WITH KEY belnr = gw_bkpf-belnr gjahr = gw_bkpf-gjahr.
      IF sy-subrc = 0.
        gw_fin-bldat = gw_rbkp-bldat.
      ENDIF.

      SELECT SINGLE gtext FROM tgsbt INTO gw_fin-gtext WHERE gsber = gw_bseg-gsber AND spras = sy-langu.

      SELECT SINGLE bezei FROM t005u
        INTO gw_fin-bezei1 WHERE bland =  gw_rbkp-regio AND spras = 'EN'.


      DATA(s_bschl1) = '31' .


      READ TABLE gt_bseg INTO DATA(gw_bseg1) WITH KEY belnr = gw_bseg-belnr gjahr = gw_bseg-gjahr bschl = s_bschl1 TRANSPORTING lifnr .

      gw_fin-budat     =  gw_bseg-h_budat .
      gw_fin-lifnr     =  gw_bseg-lifnr = gw_bseg1-lifnr .
      gw_fin-belnr     =  gw_bseg-belnr.
      gw_fin-bldat     =  gw_bseg-h_bldat.
      gw_fin-zplcsply  =  gw_fin-bezei1."'Karnataka'.
      gw_fin-menge     =   gw_bseg-menge .
*      gw_fin-wrbtr1    =  gw_rseg-wrbtr.
      gw_fin-werks     =   gw_bseg-werks .
      gw_fin-waers     =  gw_bseg-h_waers.
      gw_fin-bupla     = gw_bseg-bupla .
      gw_fin-gsber     = gw_bseg-gsber .
      gw_fin-kostl     = gw_bseg-kostl .
      gw_fin-hkont     = gw_bseg-hkont .
      gw_fin-xblnr     =  gw_bkpf-xblnr.
      gw_fin-xblnr_alt =  gw_bkpf-xblnr_alt.
      gw_fin-fi_belnr  = gw_bkpf-belnr.
      gw_fin-ebelp     =  gw_bseg-posn2.
      gw_fin-ebeln     =  gw_bseg-vbel2.
      gw_fin-mwskz     =  gw_bseg-mwskz.
      gw_fin-sgtxt     =  gw_bseg-sgtxt.
      gw_fin-blart     = gw_bseg-h_blart.
      lv_btyp          = gw_bseg-mwskz.


      READ TABLE it_skat INTO wa_skat WITH KEY ktopl = gw_bseg-bukrs saknr = gw_bseg-hkont.
      IF sy-subrc = 0.
        gw_fin-txt20 = wa_skat-txt20.

      ENDIF.

      READ TABLE gt_vbap INTO gw_vbap WITH KEY
      vbeln = gw_bseg-vbel2  posnr = gw_bseg-posn2.
      IF sy-subrc EQ 0.
        IF gw_fin-menge IS INITIAL.
          gw_fin-menge = gw_vbap-kwmeng.
          gw_fin-bstme = gw_vbap-vrkme.
        ENDIF.
        IF  gw_fin-menge > 1.
          gw_fin-wrbtr   =   gw_bseg-wrbtr  /    gw_fin-menge.
        ENDIF.
        gw_fin-matnr     =  gw_vbap-matnr.


        SELECT SINGLE steuc FROM marc INTO gw_fin-hsn_sac WHERE matnr = gw_fin-matnr.
        READ TABLE gt_makt INTO gw_makt WITH KEY matnr = gw_vbap-matnr.
        IF sy-subrc EQ 0.
          gw_fin-maktx  =   gw_makt-maktx.
        ENDIF.
      ENDIF.

      SELECT SINGLE bezei FROM t005u
       INTO gw_fin-bezei WHERE land1 = gw_kna1-land1 AND bland =  gw_kna1-regio AND spras = 'EN'.
      SHIFT  gw_fin-kunnr LEFT DELETING LEADING '0'.


      CLEAR sy-subrc.


*      IF sy-subrc EQ 0.
      IF gw_bseg-bschl = '11'.

        LOOP AT  gt_bset INTO gw_bset
      WHERE belnr = gw_bseg-belnr AND txgrp = gw_bseg-txgrp AND "buzei = gw_bseg-buzei   AND
                gjahr = gw_bseg-gjahr.
          gw_fin-localhwbas   = gw_bset-hwbas .
          gw_fin-h2bascg      = gw_bset-hwbas .
*          gw_fin-wrbtr1   = gw_bset-fwbas.
          IF  gw_bset-kschl   = 'JICG'.
            gw_fin-cgstprc    = gw_bset-kbetr / 10.
            gw_fin-h2stecg    = gw_bset-hwste.
            gw_fin-wrbtr1   = gw_bset-fwbas.
          ELSEIF gw_bset-kschl = 'JISG'.
            gw_fin-sgstprc   = gw_bset-kbetr / 10.
            gw_fin-h2stesg   = gw_bset-hwste.
            gw_fin-h2bassg   = gw_bset-hwbas.
            gw_fin-wrbtr1   = gw_bset-fwbas.
          ELSEIF gw_bset-kschl = 'JIIG' ."OR  gw_bset-kschl = 'JOMD'.
            gw_fin-igstprc  = gw_bset-kbetr / 10 .
            gw_fin-h2steig  =  gw_bset-hwste.
            gw_fin-h2basig  =  gw_bset-hwbas.
            gw_fin-wrbtr1   = gw_bset-fwbas.
          ELSEIF gw_bset-kschl = 'JIUG' ."OR GW_BSET-KSCHL = 'JIMD'.
            gw_fin-utgstprc   = gw_bset-kbetr / 10.
            gw_fin-h2steutg =  gw_bset-hwste.
            gw_fin-h2bautg =  gw_bset-hwbas.
            gw_fin-wrbtr1   = gw_bset-fwbas.
          ELSE.
            IF gw_bset-shkzg = 'S'.
*              gw_fin-wrbtr1   = gw_bset-fwbas.
              gw_fin-wrbtr1   = gw_bseg-pswbt.
            ENDIF.
          ENDIF.
*          gw_fin-totinvc  = gw_fin-h2steig + gw_fin-h2stesg +  gw_fin-h2stecg  + gw_fin-h2steutg + gw_bset-hwbas ."gw_fin-h2bascg.
          gw_fin-taxtotl = gw_fin-h2steig + gw_fin-h2stesg +  gw_fin-h2stecg + gw_fin-h2steutg + gw_fin-h2stecc.
          CLEAR:gw_bset.
        ENDLOOP.
      ELSE.
        LOOP AT  gt_bset INTO gw_bset
      WHERE belnr = gw_bseg-belnr AND txgrp = gw_bseg-txgrp AND"buzei = gw_bseg-buzei   AND
                gjahr = gw_bseg-gjahr.
          gw_fin-localhwbas   = gw_bset-hwbas .
          gw_fin-h2bascg      = gw_bset-hwbas .
*          gw_fin-wrbtr1   = gw_bset-fwbas.
          IF  gw_bset-kschl   = 'JICG'.
            gw_fin-cgstprc    = gw_bset-kbetr / 10.
            gw_fin-h2stecg    = gw_bset-hwste.
            gw_fin-wrbtr1   = gw_bset-fwbas.
          ELSEIF gw_bset-kschl = 'JISG'.
            gw_fin-sgstprc   = gw_bset-kbetr / 10.
            gw_fin-h2stesg   = gw_bset-hwste.
            gw_fin-h2bassg   = gw_bset-hwbas.
            gw_fin-wrbtr1   = gw_bset-fwbas.
          ELSEIF gw_bset-kschl = 'JIIG'." OR  gw_bset-kschl = 'JOMD'.
            gw_fin-igstprc  = gw_bset-kbetr / 10 .
            gw_fin-h2steig  =  gw_bset-hwste.
            gw_fin-h2basig  =  gw_bset-hwbas.
            gw_fin-wrbtr1   = gw_bset-fwbas.
          ELSEIF gw_bset-kschl = 'JIUG' ."OR GW_BSET-KSCHL = 'JIMD'.
            gw_fin-utgstprc   = gw_bset-kbetr / 10.
            gw_fin-h2steutg =  gw_bset-hwste.
            gw_fin-h2bautg =  gw_bset-hwbas.
            gw_fin-wrbtr1   = gw_bset-fwbas.
          ELSE.
            IF gw_bset-shkzg = 'S'.
              gw_fin-wrbtr1   = gw_bset-fwbas.
            ENDIF.
          ENDIF.
*        gw_fin-totinvc  = gw_fin-h2steig + gw_fin-h2stesg +  gw_fin-h2stecg  + gw_bset-hwbas ."gw_fin-h2bascg.
          gw_fin-taxtotl = gw_fin-h2steig + gw_fin-h2stesg +  gw_fin-h2stecg + gw_fin-h2steutg + gw_fin-h2stecc.
*          lv_btyp = gw_bseg-mwskz.
          CLEAR:gw_bset.

        ENDLOOP.
        IF gw_fin-wrbtr1 IS INITIAL.    "aDDED BY IBR
          gw_fin-wrbtr1   = gw_bseg-wrbtr.
        ENDIF.
      ENDIF.

      READ TABLE  gt_bseg  INTO gw_bseg WITH KEY belnr =  gw_bkpf-belnr gjahr = gw_bkpf-gjahr ktosl = 'EGK' bschl = '31' .

      IF gw_fin-wrbtr1 IS INITIAL.
        gw_fin-wrbtr1   = gw_bseg-wrbtr.
      ENDIF.

      gw_fin-zplcsply = gw_bseg-plc_sup .
      IF gw_fin-lifnr IS NOT INITIAL.

        READ TABLE  gt_lfa1 INTO  gw_lfa1 WITH KEY lifnr =  gw_bseg-lifnr.
        IF sy-subrc EQ 0.
          gw_fin-lifnr  =  gw_lfa1-lifnr .
          gw_fin-name1  =   gw_lfa1-name1.
*****************************************************************************************
          CLEAR: wa_lfbw,wa_t059w, wa_t059zt.
          SELECT SINGLE * FROM lfbw INTO wa_lfbw WHERE lifnr = gw_fin-lifnr AND witht = wa_with_item-witht.
          gw_fin-wt_exnr   = wa_lfbw-wt_exnr.
          gw_fin-wt_exrt   = wa_lfbw-wt_exrt.
          gw_fin-wt_exdf   = wa_lfbw-wt_exdf.
          gw_fin-wt_exdt   = wa_lfbw-wt_exdt.

          SELECT SINGLE * FROM t059w INTO wa_t059w WHERE wt_wtexrs = wa_lfbw-wt_wtexrs AND spras = 'EN' AND land1 = 'IN'.
          gw_fin-wt_wtexrs = wa_t059w-text30.

          IF wa_with_item-witht CP 'W*'.
            SELECT SINGLE spras
                          land1
                          witht
                          wt_withcd
                          text40    FROM t059zt INTO wa_t059zt
                           WHERE spras = 'EN' AND land1 = 'IN'
                           AND witht = wa_with_item-witht
                           AND wt_withcd = wa_with_item-wt_withcd.

            gw_fin-tds_desc = wa_t059zt-text40.
            gw_fin-tds = wa_with_item-wt_qbshb.
            gw_fin-tds% = wa_with_item-qsatz.
            gw_fin-tdsc = wa_with_item-wt_withcd.
            gw_fin-tdst = wa_with_item-witht.
          ENDIF.



******************************************************************************************


          SELECT SINGLE bezei FROM t005u
                INTO gw_fin-bezei WHERE land1 = gw_lfa1-land1 AND bland =  gw_lfa1-regio AND spras = 'EN'.
          SHIFT  gw_fin-lifnr LEFT DELETING LEADING '0'.
          IF  gw_lfa1-stcd3 IS NOT INITIAL.
            gw_fin-stcd3  =  gw_lfa1-stcd3.
          ELSE.
            gw_fin-stcd3  =  gw_lfa1-j_1ipanref.
          ENDIF.
        ENDIF.
      ENDIF.

      gw_fin-exch_rate = gw_bkpf-kursf .
      gw_fin-conv_amt = gw_fin-exch_rate * gw_fin-totinvc .
      CLEAR: lv_btyp.
      lv_btyp = gw_fin-mwskz.

**      IF lv_btyp IN s_na OR lv_btyp IN s_ea OR lv_btyp IN s_ha  .
**        gw_fin-totinvc =   gw_fin-wrbtr1 .
**      ELSE .
      gw_fin-totinvc  = gw_fin-h2steig + gw_fin-h2stesg +  gw_fin-h2stecg  + gw_fin-h2steutg + gw_fin-wrbtr1 + gw_fin-h2stecc ."gw_fin-h2bascg.
**      ENDIF.
      IF gw_fin-waers <> 'INR' .
        gw_fin-conv_amt = gw_fin-totinvc * gw_fin-exch_rate .
      ELSE .
        gw_fin-conv_amt = gw_fin-totinvc  .
      ENDIF .

      READ TABLE gt_fin INTO DATA(sfin) WITH KEY belnr = gw_fin-belnr .
      IF sy-subrc IS INITIAL.
        CLEAR : gw_fin-tds% ,gw_fin-tds, gw_fin-tdsc , gw_fin-tdst , gw_fin-tds_desc .
      ENDIF.
      CLEAR sfin .

      IF gw_fin-belnr  IS NOT INITIAL.

        IF  gw_fin-mwskz = '30' OR gw_fin-mwskz = '3A' OR gw_fin-mwskz = '3B' OR gw_fin-mwskz = '3C' OR gw_fin-mwskz = '3D' OR gw_fin-mwskz = '3E'
            OR gw_fin-mwskz = '3F' OR gw_fin-mwskz = '3G' OR gw_fin-mwskz = '3H' OR gw_fin-mwskz = '3I' OR gw_fin-mwskz = '3J'  OR
            gw_fin-mwskz = '40' OR gw_fin-mwskz = '4A' OR gw_fin-mwskz = '4B' OR gw_fin-mwskz = '4C' OR gw_fin-mwskz = '4D' OR gw_fin-mwskz = '4E'
            OR gw_fin-mwskz = '4F' OR gw_fin-mwskz = '4G' OR gw_fin-mwskz = '4H' OR gw_fin-mwskz = '4I' OR gw_fin-mwskz = '4J'.
          gw_fin-zrev = 'YES' .
          gw_fin-totinvc = gw_fin-wrbtr1  .
*          gw_fin-totinvct =  gw_fin-totinvc +  gw_fin-tds.

        ELSE.
          gw_fin-zrev = 'NO' .
        ENDIF.

        gw_fin-totinvct =  gw_fin-totinvc +  gw_fin-tds.

        APPEND gw_fin TO gt_fin.
      ENDIF.

      CLEAR: gw_fin,lv_p.
      SORT gt_fin BY budat fi_belnr.


*      APPEND gw_fin TO gt_fin.
*      CLEAR: gw_fin,lv_p.
    ENDLOOP.
***    IF gw_fin-belnr  IS NOT INITIAL.
***      n = n + 1.
***      gw_fin-slno      =  n .
***      APPEND gw_fin TO gt_fin.
***    ENDIF.
***
***    CLEAR: gw_fin,lv_p.
  ENDLOOP.
BREAK PPADHY.
DELETE GT_FIN WHERE SLNO IS NOT INITIAL  ."MWSKZ = '**' ."OR IGSTPRC IS INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLY_DATA4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disply_data4 .
**  wa_fcat-col_pos              =  1.
*  wa_fcat-fieldname            = 'SLNO'.
*  wa_fcat-tabname              = 'GT_FIN'.
*  wa_fcat-seltext_l            = 'Sl No '.
**  wa_fcat-outputlen            =  6.
*  APPEND wa_fcat TO it_fcat.
*  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'LIFNR'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Vendor Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos              =  8.
  wa_fcat-fieldname            = 'NAME1'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Vendor Name'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos              =  10.
  wa_fcat-fieldname            = 'STCD3'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'GSTN No.'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'BLART'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Document Type'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'FI_BELNR'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'FI Document No.'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'BLDAT'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Invoice Date'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos              =  12.
  wa_fcat-fieldname            = 'XBLNR'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Reference'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  *  wa_fcat-col_pos              =  2.
  wa_fcat-fieldname            = 'BUDAT'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Invoice Posting Date'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  *  wa_fcat-col_pos              =  2.
  wa_fcat-fieldname            = 'SGTXT'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Description'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'GSBER'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Business Area Code'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'GTEXT'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Business Area Description'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'HKONT'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'GL Account'.
  WA_FCAT-datatype             = 'NUMC'.
  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'TXT20'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'GL Description'.
  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos              =  16.
  wa_fcat-fieldname            = 'MWSKZ'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Tax Code'.
*  wa_fcat-outputlen            =  6.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos              =  17.
  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'WRBTR1'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Taxable Value'."'Transaction Value/Acsessable Vaule'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  *  wa_fcat-col_pos             =  21.
  wa_fcat-fieldname            = 'CGSTPRC'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = '%'.
*  wa_fcat-outputlen            =  15.
  wa_fcat-just                 = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos              =  22.
  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'H2STECG'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'CGST'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos             =  23.
  wa_fcat-fieldname            = 'SGSTPRC'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = '%'.
*  wa_fcat-outputlen            =  15.
  wa_fcat-just                 = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.
*  wa_fcat-col_pos             = 24.
  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'H2STESG'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'SGST'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos             =  25.
  wa_fcat-fieldname            = 'IGSTPRC'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = '%'.
*  wa_fcat-outputlen            =  15.
  wa_fcat-just                 = 'C'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

*  wa_fcat-col_pos             =  26.
  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'H2STEIG'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'IGST'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-do_sum               = 'X'.
  wa_fcat-fieldname            = 'TOTINVC'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Total Value'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname            = 'KOSTL'.
  wa_fcat-tabname              = 'GT_FIN'.
  wa_fcat-seltext_l            = 'Cost Center'.
  wa_fcat-datatype             = 'NUMC'.
*  wa_fcat-outputlen            =  15.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
*     I_CALLBACK_TOP_OF_PAGE = 'FORM_TOP_OF_PAGE '
      is_layout          = wa_layout
      it_fieldcat        = it_fcat[]
      it_sort            = it_sort
      i_default          = 'X'
*     it_events          = it_events
      i_save             = 'A'
    TABLES
      t_outtab           = gt_fin
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
ENDFORM.
