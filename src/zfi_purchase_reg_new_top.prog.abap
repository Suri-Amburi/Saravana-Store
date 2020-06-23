*&---------------------------------------------------------------------*
*& Include          ZFI_PURCHASE_REG_NEW_TOP
*&---------------------------------------------------------------------*

TABLES:rbkp,lfa1,vbrk,vbrp.

TYPES:BEGIN OF ty_rbkp,
        belnr   TYPE re_belnr,
        gjahr	  TYPE gjahr,
        budat   TYPE budat,
        stcd3   TYPE stcd3,
        bldat   TYPE bldat,
        lifnr   TYPE lifre,
        waers	  TYPE waers,
        xblnr	  TYPE xblnr1,
        rbstat  TYPE rbstat,
        stblg   TYPE stblg,
        mwskz1  TYPE mwskz_mrm1,
        regio   TYPE regio,
        plc_sup TYPE j_1ig_region,
        knumve  TYPE knumv,
        sgtxt   TYPE sgtxt,
      END OF ty_rbkp,

      BEGIN OF ty_lfa1,
        lifnr      TYPE   lifnr,
        land1      TYPE  land1_gp,
        name1      TYPE  name1_gp,
        name2      TYPE  name2_gp,
        name3      TYPE  name3_gp,
        name4      TYPE  name4_gp,
        regio      TYPE  regio,
        ven_class	 TYPE  j_1igtakld,
        stcd3	     TYPE stcd3,
        j_1ipanref TYPE j_1ipanref,
      END OF ty_lfa1,

      BEGIN OF ty_kna1,
        kunnr      TYPE  kunnr,
        land1      TYPE  land1_gp,
        name1      TYPE  name1_gp,
        name2      TYPE  name2_gp,
        name3      TYPE  name3_gp,
        name4      TYPE  name4_gp,
        regio      TYPE  regio,
        stcd3	     TYPE stcd3,
        j_1ipanref TYPE j_1ipanref,
      END OF ty_kna1,

      BEGIN OF ty_rseg,
        belnr	  TYPE belnr_d,
        gjahr	  TYPE gjahr,
        buzei	  TYPE rblgp,
        ebeln	  TYPE ebeln,
        ebelp	  TYPE ebelp,
        zekkn   TYPE dzekkn,
        matnr	  TYPE matnr,
        hsn_sac	TYPE j_1ig_hsn_sac,
        mwskz   TYPE 	mwskz,
        wrbtr   TYPE  wrbtr,
        menge	  TYPE menge_d,
        werks   TYPE werks_d,
        pstyp   TYPE  rseg-pstyp,
        knttp   TYPE rseg-knttp,
        bstme	  TYPE bstme,
*        wrbtr  TYPE wrbtr ,
        kschl   TYPE kschl,
        sgtxt   TYPE sgtxt,
        shkzg   TYPE shkzg,
        introw  TYPE introw,
        packno  TYPE packno,
        lfbnr   TYPE lfbnr,
        lfgja	  TYPE lfgja,
        lfpos	  TYPE lfpos,
      END OF ty_rseg,

      BEGIN OF ty_ekko,
        ebeln	TYPE ebeln,
        bsart	TYPE esart,
        knumv TYPE knumv,
      END OF ty_ekko,

      BEGIN OF ty_ekpo,
        ebeln  TYPE ebeln,
        ebelp  TYPE ebelp,
        txz01  TYPE txz01,
        packno TYPE packno,
        menge  TYPE menge_d,
        navnw  TYPE navnw,
      END OF ty_ekpo ,

      BEGIN OF ty_makt,
        matnr TYPE  matnr,
        spras	TYPE spras,
        maktx	TYPE maktx,
        maktg	TYPE maktg,
      END OF ty_makt,

      BEGIN OF ty_acdoca,
        belnr	  TYPE belnr_d,
        rbukrs  TYPE bukrs,
        gjahr	  TYPE gjahr,
        docln   TYPE acdoca-docln,
        awref	  TYPE awref,
        awitem  TYPE fins_awitem,
        awitgrp TYPE fins_awitgrp,
        ktosl	  TYPE ktosl,
        wsl	    TYPE fins_vwcur12,
        mwskz   TYPE mwskz,
      END  OF ty_acdoca,

      BEGIN OF ty_konp,
        mwsk1 TYPE  mwskz,
        kbetr	TYPE kbetr_kond,
      END OF ty_konp,


      BEGIN OF ty_bset,
        bukrs TYPE  bukrs,
        belnr	TYPE belnr_d,
        gjahr	TYPE gjahr,
        buzei TYPE buzei,
        mwskz TYPE mwskz,
        hwbas	TYPE hwbas_bses,
        fwbas	TYPE fwbas_bses,
        hwste	TYPE hwste,
        fwste TYPE  fwste,
        ktosl TYPE ktosl,
        kschl TYPE kschl,
        kbetr TYPE kbetr,
        txgrp	TYPE txgrp,
        shkzg	TYPE shkzg,
        h2ste TYPE h2ste,
      END OF ty_bset,


      BEGIN OF ty_bseg ,
        bukrs   TYPE bukrs,
        belnr	  TYPE belnr_d,
        gjahr	  TYPE gjahr,
        buzei	  TYPE buzei,
        bschl	  TYPE bschl,
        koart	  TYPE koart,
        umskz	  TYPE umskz,
        vbel2	  TYPE vbeln_va,
        posn2	  TYPE posnr_va,
        hsn_sac TYPE j_1ig_hsn_sac,
        lifnr	  TYPE lifnr,
        h_budat	TYPE budat,
        h_bldat TYPE bldat,
        menge   TYPE  menge_d,
        meins	  TYPE meins,
        wrbtr	  TYPE wrbtr,
        h_waers TYPE waers,
        h_blart	TYPE blart,
        werks	  TYPE werks_d,
        txgrp	  TYPE txgrp,
        kunnr   TYPE kunnr,
        hkont   TYPE hkont,
        mwskz   TYPE mwskz,
        ktosl   TYPE bseg-ktosl,
        plc_sup TYPE regio,
        bupla   TYPE bupla,
        gsber   TYPE gsber,
        kostl   TYPE kostl,
        pswbt   TYPE pswbt,
        anln1   TYPE anln1,
        anln2   TYPE anln2,
        qsskz   TYPE qsskz,
        buzid   TYPE buzid,
      END OF ty_bseg,

*      BEGIN OF ty_bseg1 ,
*        bukrs TYPE bukrs,
*        belnr  TYPE belnr_d,
*        gjahr  TYPE gjahr,
*        ebeln TYPE bseg-ebeln,
*
*      END OF ty_bseg1,

      BEGIN OF ty_vbap,
        vbeln  TYPE vbeln_va,
        posnr  TYPE posnr_va,
        matnr  TYPE matnr,
        matwa  TYPE matwa,
        pmatn  TYPE pmatn,
        kwmeng TYPE vbap-kwmeng,
        vrkme  TYPE vrkme,
      END OF ty_vbap,

      BEGIN OF ty_bkpf,
        bukrs	    TYPE bukrs,
        belnr	    TYPE belnr_d,
        gjahr	    TYPE gjahr,
        xblnr	    TYPE xblnr1,
        xblnr_alt TYPE 	xblnr_alt,
        kursf     TYPE kursf,
        blart     TYPE bkpf-blart,
        stblg     TYPE bkpf-stblg,
        budat     TYPE bkpf-budat,

*        awkey      TYPE awkey,
      END OF ty_bkpf,

      BEGIN OF ty_bkpf2,
        bukrs	TYPE bukrs,
        belnr	TYPE belnr_d,
        gjahr	TYPE gjahr,
        kursf TYPE kursf,
        awkey TYPE awkey,
      END OF ty_bkpf2,
      "SALES RETURN INVOICE>>>>>>>>>>>>.

      BEGIN OF ty_vbrk,
        vbeln TYPE vbeln_vf,    ""Billing Document
        fkart TYPE fkart,       "Billing Type
        fkdat TYPE fkdat,       ""date
        regio TYPE regio,       ""region
        kunrg TYPE kunrg,       ""Payer
        kunag TYPE kunag,       ""Sold-to party
        knumv TYPE knumv,       ""dondition no
        xblnr TYPE xblnr_v1,
      END OF ty_vbrk.

TYPES:BEGIN OF ty_vbrp,
        vbeln      TYPE vbeln_vf,    ""Billing Document
        netwr      TYPE netwr_fp,
        posnr      TYPE posnr_vf,
        matnr      TYPE	matnr,
        arktx      TYPE arktx,
        werks      TYPE werks_d,
        fkimg      TYPE fkimg,
        vrkme      TYPE vrkme,
        spart      TYPE spart,
        vtweg_auft TYPE vtweg_auft,
        waerk      TYPE waerk,
        mwskz      TYPE mwskz,
        meins	     TYPE meins,
        aubel	     TYPE vbeln_va,
        aupos	     TYPE posnr_va,
      END OF ty_vbrp.

TYPES:BEGIN OF ty_prcd,
        knumv TYPE  knumv,
        kposn	TYPE kposn,
        kschl	TYPE kscha,
        knumh	TYPE knumh,
        kopos	TYPE kopos_long,
        kwert	TYPE vfprc_element_value,
        kbetr TYPE  vfprc_element_value,
        mwsk1	TYPE mwskz,
        kinak	TYPE kinak,
      END OF ty_prcd.

TYPES:BEGIN OF ty_mara,
        matnr TYPE matnr,
        mtart TYPE mtart,
        matkl TYPE matkl,
      END OF ty_mara.

TYPES:BEGIN OF ty_marc,
        matnr TYPE matnr,
        steuc TYPE  steuc,
        werks TYPE werks_d,
      END OF ty_marc.


TYPES:BEGIN OF ty_vbfa,
        vbelv	  TYPE vbeln_von,
        vbeln	  TYPE vbeln_nach,
        vbtyp_v	TYPE vbtypl_v,
      END OF ty_vbfa.

TYPES:BEGIN OF ty_vbpa,
        vbeln	TYPE vbeln_va,
        adrnr	TYPE adrnr,
        kunnr	TYPE kunnr,
        parvw TYPE parvw,
      END OF ty_vbpa.

TYPES:BEGIN OF ty_t005u,
        spras TYPE spras,
        land1	TYPE land1,
        bland	TYPE regio,
        bezei	TYPE bezei20,
      END OF ty_t005u.

TYPES:BEGIN OF ty_t604n,
        steuc TYPE steuc,
        text1	TYPE bezei60,
      END OF ty_t604n.

TYPES:BEGIN OF ty_mseg,
        mblnr TYPE mblnr,
        lifnr	TYPE lifnr,
        matnr TYPE matnr,
      END OF ty_mseg.


TYPES:BEGIN OF ty_mbew,
        matnr TYPE matnr,
        bwkey TYPE bwkey,
        verpr TYPE verpr,
        zplp1 TYPE dzplp1,
        zplp2	TYPE dzplp2,
        zplp3	TYPE dzplp3,
        vprsv TYPE vprsv,
        stprs TYPE stprs,
      END OF ty_mbew.

TYPES:BEGIN OF ty_j_1iassval,
        j_1imatnr  TYPE matnr,
        j_1ivalass TYPE j_1ivalass,
        j_1iwaers  TYPE j_1iwaers,
      END OF ty_j_1iassval,


      BEGIN OF ty_vbkd,
        vbeln TYPE  vbeln,
        posnr	TYPE posnr,
        bstkd	TYPE bstkd,
        bstdk	TYPE bstdk,
      END OF ty_vbkd,

      BEGIN OF ty_esll ,
        packno     TYPE packno,
        introw     TYPE numzeile,
        extrow     TYPE extrow,
        srvpos     TYPE	asnum,
        ktext1     TYPE sh_text1,
        sub_packno TYPE packno,
        menge      TYPE menge_d,
        act_menge  TYPE menge_d,
        meins      TYPE meins,
        brtwr      TYPE sbrtwr,
        netwr      TYPE snetwr,
        matkl	     TYPE matkl_srv,
        tbtwr	     TYPE sbrtwr,
        act_wert   TYPE act_wert,
        navnw	     TYPE navnw_srv,
        baswr	     TYPE baswr,
        kknumv     TYPE	knumv,
        userf1_num TYPE userf1_num,
        belnr      TYPE catsbelnr, " Changes by ksanthosh on 30.01.2019
      END OF ty_esll ,

      BEGIN OF ty_with_item,
        bukrs     TYPE bukrs,
        belnr     TYPE belnr_d,
        gjahr     TYPE gjahr,
        buzei     TYPE buzei,
        witht     TYPE witht,
        wt_withcd TYPE with_item-wt_withcd,
        qsatz     TYPE with_item-qsatz,
        wt_qbshb  TYPE with_item-wt_qbshb,
        wt_wtexmn TYPE with_item-wt_wtexmn,
        wt_qszrt  TYPE with_item-wt_qszrt,
      END OF ty_with_item.


TYPES : BEGIN OF ty_skat,  "*---->>> ( GL DESC ) mumair <<< 11.11.2019 11:30:46
          ktopl TYPE ktopl,
          saknr TYPE saknr,
          txt20 TYPE txt20_skat,
        END OF ty_skat.

TYPES : BEGIN OF ty_lfbw,
          wt_exdf   TYPE lfbw-wt_exdf,
          wt_exdt   TYPE lfbw-wt_exdt,
          wt_wtexrs TYPE lfbw-wt_wtexrs,
        END OF ty_lfbw.


DATA : it_skat TYPE STANDARD TABLE OF ty_skat,
       wa_skat TYPE ty_skat.





DATA: wa_vbap      TYPE ty_vbap,
      it_vbap      TYPE TABLE OF ty_vbap,
      wa_vbrk      TYPE ty_vbrk,
      it_vbrk      TYPE TABLE OF ty_vbrk,
      wa_vbrp      TYPE ty_vbrp,
      it_vbkd      TYPE TABLE OF ty_vbkd,
      wa_vbkd      TYPE ty_vbkd,
      it_vbrp      TYPE TABLE OF ty_vbrp,
      wa_prcd      TYPE ty_prcd,
*      it_bseg1     TYPE TABLE OF ty_bseg1,
      wa_bkpf2     TYPE ty_bkpf2,
      w_prcdt1     TYPE prcd_elements,
      w_prcdt      TYPE prcd_elements,
      t_prcdt      TYPE TABLE OF prcd_elements,
      t_prcdt1     TYPE TABLE OF prcd_elements,
      it_prcd      TYPE TABLE OF ty_prcd,
      wa_kna12     TYPE ty_kna1,
      it_kna1      TYPE TABLE OF ty_kna1,
      wa_kna1      TYPE  ty_kna1,
      it_kna12     TYPE TABLE OF ty_kna1,
      wa_mara      TYPE ty_mara,
      it_mara      TYPE TABLE OF ty_mara,
      wa_marc      TYPE ty_marc,
      it_marc      TYPE TABLE OF ty_marc,
      wa_makt      TYPE ty_makt,
      it_makt      TYPE TABLE OF ty_makt,
      it_vbpa      TYPE TABLE OF ty_vbpa,
      it_vbpa1     TYPE TABLE OF ty_vbpa,
      wa_vbfa      TYPE ty_vbfa,
      it_vbfa      TYPE TABLE OF ty_vbfa,
      wa_vbpa      TYPE ty_vbpa,
      wa_vbpa1     TYPE ty_vbpa,
      gt_t005u     TYPE TABLE OF ty_t005u,
      gw_t005u     TYPE ty_t005u,
      it_with_item TYPE TABLE OF ty_with_item,
      wa_with_item TYPE ty_with_item,
      wa_t059w     TYPE t059w,
      it_t059w     TYPE TABLE OF t059w,
      wa_t059v     TYPE t059v,
      it_t059v     TYPE TABLE OF t059v,
      wa_lfbw      TYPE lfbw,
      it_lfbw      TYPE TABLE OF lfbw,
      it_t059zt    TYPE TABLE OF t059zt,
      gt_esll      TYPE TABLE OF ty_esll,
      gw_esll      TYPE ty_esll,
      gt_esll1     TYPE TABLE OF ty_esll,
      gt_esll2     TYPE TABLE OF ty_esll,
      gt_esll3     TYPE TABLE OF ty_esll,
      gw_esll1     TYPE ty_esll,
      gw_esll2     TYPE ty_esll,
      gw_esll3     TYPE ty_esll.
"END>>>>>>>>>>>>>>>>>>>>>>>
TYPES: BEGIN OF ty_fin,
         slno         TYPE i,
         budat        TYPE budat,
         lifnr        TYPE lifre,
         name1        TYPE  name1_gp,
         stcd3        TYPE stcd3,
         belnr        TYPE re_belnr,
         bldat        TYPE bldat,
         buzei        TYPE rblgp,
         buzei1       TYPE rblgp,
         matnr        TYPE matnr,
         maktx        TYPE maktx,
         hsn_sac      TYPE j_1ig_hsn_sac,
         zplcsply(20) TYPE c,
         disc         TYPE vfprc_element_value,
         base_amt     TYPE vfprc_element_value,
         freight      TYPE vfprc_element_value,
         ins_cost     TYPE vfprc_element_value,
         ant_dump     TYPE vfprc_element_value,
         bas_cust     TYPE vfprc_element_value,
         ocn_frght    TYPE vfprc_element_value,
         ocn_insrn    TYPE vfprc_element_value,
         agnc_chrgs   TYPE vfprc_element_value,
         others       TYPE vfprc_element_value,
         tax_amt      TYPE vfprc_element_value,
         h2stecg      TYPE h2ste,
*           H2STECG     TYPE    HWSTE,
         h2bascg      TYPE h2bas_bses,
         h2stesg      TYPE h2ste,
         h2bassg      TYPE h2bas_bses,
         h2steig      TYPE kbetr, "h2ste,
         h2basig      TYPE h2bas_bses,
         h2steutg     TYPE kbetr, "h2ste,
         h2bautg      TYPE h2bas_bses,
         zrev(4)      TYPE  c,
         wrbtr        TYPE  wrbtr,
         menge        TYPE menge_d,
         sgstprc(3)   TYPE c,
         cgstprc(3)   TYPE c,
         igstprc(3)   TYPE c,
         utgstprc(3)  TYPE c,
         bef_tds      TYPE vfprc_element_value, "h2ste,
         totinvc      TYPE vfprc_element_value, "h2ste,
         totinvct     TYPE vfprc_element_value, "h2ste,
         bsart        TYPE esart,
         waers        TYPE waers,
         xblnr        TYPE xblnr1,
         wrbtr1       TYPE wrbtr,
         bezei        TYPE bezei20,
         bezei1       TYPE bezei20,
         zsuply(15)   TYPE c,
         werks        TYPE werks_d,
         taxtotl      TYPE wrbtr,
         supply(20)   TYPE c,
         bstme        TYPE bstme,
         text1        TYPE bezei60,
         localhwbas   TYPE  wrbtr,
         ebeln        TYPE ebeln,
         ebelp        TYPE ebelp,
         mwskz        TYPE   mwskz,
         kunnr        TYPE  kunnr,
         hkont        TYPE hkont,
         splname      TYPE name1_gp,
         splystcd3    TYPE name1_gp,
         name1k       TYPE name1_gp,
         stcd3k       TYPE stcd3,
         xblnr_alt    TYPE  xblnr_alt,
         tdline       TYPE  tdline,
         exch_rate    TYPE kursf,
         conv_amt     TYPE vfprc_element_value,
         bupla        TYPE bupla,
         gsber        TYPE gsber,
         kostl        TYPE kostl,
         fi_belnr     TYPE belnr_d,
         sd_invc      TYPE vbeln,
         mtart        TYPE mtart,
         matkl        TYPE matkl,
         img_no       TYPE bseg-sgtxt,
         boldt        TYPE bkpf-bktxt,
         asgmt        TYPE bseg-zuonr,
         corigin      TYPE t005t-landx,
         toi          TYPE char40,
         cer          TYPE char40,
         lcost        TYPE wrbtr,
         itax         TYPE char10,
         service      TYPE packno,
         extrow       TYPE numc10,
         tds          TYPE with_item-wt_qbshb,
         tdst         TYPE witht,
         tdsc         TYPE with_item-wt_withcd,
         tds%         TYPE with_item-qsatz,
         tds_desc     TYPE text40,
         h2stecc      TYPE h2ste,
         wt_wtexmn    TYPE with_item-wt_wtexmn,
         wt_qszrt     TYPE with_item-wt_qszrt,
         wt_exnr      TYPE wt_exnr,
         wt_exrt      TYPE wt_exrt,
         wt_exdf      TYPE lfbw-wt_exdf,
         wt_exdt      TYPE lfbw-wt_exdt,
         wt_wtexrs    TYPE text30,
         menge_p      TYPE menge_d,
         mcod1        TYPE skat-mcod1,
         prc_dfgl     TYPE hkont,
         vat          TYPE navnw,
         vat%         TYPE h2ste,
         txgrp        TYPE rebzg,
         txt20        TYPE txt20_skat,
         stblg        TYPE bkpf-stblg,
         bschl        TYPE bschl,
         koart        TYPE koart,
         ktosl        TYPE ktosl,
         shkzg        TYPE bset-shkzg,
         blart        TYPE bkpf-blart,
         gtext        TYPE tgsbt-gtext,
       END OF ty_fin ,

       BEGIN OF ty_sfin,
         slno         TYPE i,
         budat        TYPE budat,
         lifnr        TYPE lifre,
         name1        TYPE  name1_gp,
         stcd3        TYPE stcd3,
         belnr        TYPE re_belnr,
         bldat        TYPE bldat,
         buzei(50)    TYPE c,
         matnr        TYPE matnr,
         maktx        TYPE maktx,
         vbeln        TYPE vbrk-vbeln,
         posnr        TYPE vbrp-posnr,
         ebeln        TYPE ebeln,
         ebelp        TYPE ebelp,
         mwskz        TYPE   mwskz,
         sgstprc(4)   TYPE c,
         cgstprc(4)   TYPE c,
         igstprc(4)   TYPE c,
         utgstprc(4)  TYPE c,
         zplcsply(20) TYPE c,
         h2stecg      TYPE h2ste,
         h2bascg      TYPE h2bas_bses,
         h2stesg      TYPE h2ste,
         h2bassg      TYPE h2bas_bses,
         h2steig      TYPE kbetr, "h2ste,
         h2basig      TYPE h2bas_bses,
         h2steutg     TYPE kbetr, "h2ste,
         h2basug      TYPE h2bas_bses,
         zrev(4)      TYPE  c,
         wrbtr        TYPE  wrbtr,
         wrbtr1       TYPE  wrbtr,
         menge        TYPE menge_d,
         taxtotl      TYPE wrbtr,
         totinvc      TYPE h2ste,
         totinvct     TYPE vfprc_element_value,
         kunnr        TYPE  kunnr,
         splname      TYPE name1_gp,
         splystcd3    TYPE name1_gp,
         name1k       TYPE name1_gp,
         stcd3k       TYPE stcd3,
         xblnr_alt    TYPE xblnr_alt,
         xblnr        TYPE xblnr1,
         waers        TYPE waers,
         bstme        TYPE bstme,
         hsn_sac      TYPE j_1ig_hsn_sac,
         bsart        TYPE esart,
         werks        TYPE werks_d,
         supply(20)   TYPE c,
         text1        TYPE bezei60,
         localhwbas   TYPE  wrbtr,
         hkont        TYPE bseg-hkont,
         txt20        TYPE txt20_skat,
       END OF ty_sfin.



*TYPES : BEGIN OF ty_skat,  "*---->>> ( gl text ) mumair <<< 31.10.2019 16:51:58
*        KTOPL TYPE KTOPL,
*        SAKNR TYPE SAKNR,
*        TXT20 TYPE TXT20_SKAT,
*        END OF ty_skat.

TYPES : BEGIN OF ty_t059zt ,
          spras	    TYPE spras,
          land1	    TYPE land1,
          witht	    TYPE witht,
          wt_withcd TYPE wt_withcd,
          text40    TYPE text40,
        END OF ty_t059zt.

**TYPES : BEGIN OF ty_rbkp,
**          belnr TYPE rbkp-belnr,
**          gjahr TYPE rbkp-gjahr,
**          bldat TYPE rbkp-bldat,
**        END OF ty_rbkp.

DATA : wa_t059zt TYPE ty_t059zt.
DATA : t_bseg TYPE bseg-qsskz.

DATA:l_budat1   TYPE budat,
     l_budat2   TYPE budat,
     lv_h2bascg TYPE  wrbtr,
     lv_awkey   TYPE awkey.


DATA: gt_rbkp    TYPE TABLE OF ty_rbkp,
      gw_rbkp    TYPE  ty_rbkp,
      gt_lfa1    TYPE TABLE OF ty_lfa1,
      gw_lfa1    TYPE  ty_lfa1,
      gt_rseg    TYPE TABLE OF ty_rseg,
      gw_rseg    TYPE ty_rseg,
      gw_rseg1   TYPE ty_rseg,
      gt_ekko    TYPE TABLE OF ty_ekko,
      gw_ekko    TYPE ty_ekko,
      gw_ekko1   TYPE ty_ekko,
      gt_ekpo    TYPE TABLE OF ty_ekpo,
      gw_ekpo    TYPE ty_ekpo,
      gt_essr    TYPE TABLE OF essr,
      gw_essr    TYPE essr,
      gt_ekbe    TYPE TABLE OF ekbe,
      gw_ekbe    TYPE ekbe,
      it_ekko    TYPE TABLE OF ty_ekko,
      wa_ekko    TYPE ty_ekko,
      gt_acdoca  TYPE TABLE OF ty_acdoca,
      gw_acdoca  TYPE ty_acdoca,
      gw_acdoca1 TYPE ty_acdoca,
      gt_konp    TYPE TABLE OF ty_konp,
      gw_konp    TYPE ty_konp,
      gt_fin     TYPE  TABLE OF ty_fin,
      lt_fin1    TYPE TABLE OF ty_fin,
      ls_fin     TYPE  ty_fin,
*      FT_FIN1     TYPE TABLE OF TY_FIN,
*      FT_FIN1 TYPE TY_FIN,
      gw_fin     TYPE ty_fin,
      gt_fin1    TYPE TABLE OF ty_fin,
      gw_fin1    TYPE ty_fin,
      gt_sfin    TYPE TABLE OF ty_sfin,
      gw_sfin    TYPE ty_sfin,
      gt_fin2    TYPE TABLE OF ty_fin,
      gw_fin2    TYPE ty_fin,
      gt_fin3    TYPE TABLE OF ty_fin,
      gt_bset    TYPE TABLE OF ty_bset,
      gw_bset    TYPE ty_bset,
      n          TYPE i,
      gt_makt    TYPE TABLE OF ty_makt,
      gw_makt    TYPE ty_makt,
      gt_bkpf    TYPE TABLE OF ty_bkpf,
      gw_bkpf    TYPE ty_bkpf,
      gt_bkpf1   TYPE TABLE OF ty_bkpf,
      gw_bkpf1   TYPE ty_bkpf,
      gt_t604n   TYPE TABLE OF t604n,
      gw_t604n   TYPE t604n,
      lv_p       TYPE c,
      lv_btyp    TYPE c LENGTH 2,
      lv_qty     TYPE menge_d.
DATA sv_bsart TYPE ekko-bsart.
DATA sv_ebeln TYPE rseg-ebeln.
DATA: it_fcat     TYPE slis_t_fieldcat_alv, "WITH HEADER LINE,
      wa_fcat     TYPE slis_fieldcat_alv,
      wa_layout   TYPE slis_layout_alv,
      lv_kbetr(5) TYPE c.

DATA: wa_events TYPE slis_alv_event,
      it_events TYPE slis_t_event,
      it_sort   TYPE slis_t_sortinfo_alv,
      wa_sort   TYPE slis_sortinfo_alv,
      gt_bseg   TYPE TABLE OF ty_bseg,
      lt_bseg   TYPE TABLE OF ty_bseg,
      ls_bseg   TYPE ty_bseg,
      gt_bseg2  TYPE TABLE OF ty_bseg,
      gt_bseg5  TYPE TABLE OF ty_bseg,
      gw_bseg   TYPE ty_bseg,
      gw_bseg2  TYPE ty_bseg,
      gw_bseg5  TYPE ty_bseg,
      gw_bseg1  TYPE ty_bseg,
      gt_vbap   TYPE TABLE OF ty_vbap,
      gw_vbap   TYPE ty_vbap,
      gt_kna1   TYPE TABLE OF ty_kna1,
      gw_kna1   TYPE ty_kna1.

DATA lv_cnt TYPE i.

DATA : s_refdoc TYPE bseg-xref3,
       s_cond   TYPE string.

DATA  : lv_pack  TYPE packno,
        inv_ref  TYPE rebzg,
        lv_pack1 TYPE esll-sub_packno.
DATA : it_lines TYPE TABLE OF tline, " OCCURS 0 WITH HEADER LINE.
       wa_lines TYPE tline,
       v_ebeln  TYPE thead-tdname.

TABLES : rseg .

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:s_werks FOR rseg-werks.
SELECT-OPTIONS:s_budat FOR rbkp-budat OBLIGATORY.
SELECT-OPTIONS:s_lifnr FOR lfa1-lifnr NO INTERVALS .
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

PARAMETERS :
* gstritm RADIOBUTTON GROUP rb1,
*             gstrhdr RADIOBUTTON GROUP rb1,           "
*             gsthsn  RADIOBUTTON GROUP rb1,           "
*             GSTADV  RADIOBUTTON GROUP RB1,
*             gstdir  RADIOBUTTON GROUP rb1,
  gst_cr  RADIOBUTTON GROUP rb1,
  gst_s   RADIOBUTTON GROUP rb1,
  gst_db  RADIOBUTTON GROUP rb1,
  gst_db1 RADIOBUTTON GROUP rb1.
*             gstsrt  RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b2.

*********************Added By Subhendu 27.03.2018***********************
DATA : lv_mskz TYPE mwskz .
SELECT-OPTIONS : s_na FOR lv_mskz NO-DISPLAY.
s_na-sign = 'I' .
s_na-option = 'BT' .
s_na-low = 'NA' .
s_na-high = 'NZ' .
APPEND s_na TO s_na .
SELECT-OPTIONS : s_ea FOR lv_mskz NO-DISPLAY.
s_ea-sign = 'I' .
s_ea-option = 'BT' .
s_ea-low = 'EA' .
s_ea-high = 'EZ' .
APPEND s_ea TO s_ea .
SELECT-OPTIONS : s_ha FOR lv_mskz NO-DISPLAY.
s_ha-sign = 'I' .
s_ha-option = 'BT' .
s_ha-low = 'HA' .
s_ha-high = 'HZ' .
APPEND s_ha TO s_ha .

***********************FOR ITAX & LCOST **********************
SELECT-OPTIONS : s_m FOR lv_mskz NO-DISPLAY.
s_m-sign = 'I' .
s_m-option = 'BT' .
s_m-low = 'MK' .
s_m-high = 'MT' .
APPEND s_m TO s_m.
SELECT-OPTIONS : s_n FOR lv_mskz NO-DISPLAY.
s_n-sign = 'I' .
s_n-option = 'BT' .
s_n-low = 'NK' .
s_n-high = 'NT' .
APPEND s_n TO s_n.
SELECT-OPTIONS : s_d FOR lv_mskz NO-DISPLAY.
s_d-sign = 'I' .
s_d-option = 'BT' .
s_d-low = 'DK' .
s_d-high = 'DT' .
APPEND s_d TO s_d.
SELECT-OPTIONS : s_e FOR lv_mskz NO-DISPLAY.
s_e-sign = 'I' .
s_e-option = 'BT' .
s_e-low = 'EK' .
s_e-high = 'ET' .
APPEND s_e TO s_e.
SELECT-OPTIONS : s_g FOR lv_mskz NO-DISPLAY.
s_g-sign = 'I' .
s_g-option = 'BT' .
s_g-low = 'GK' .
s_g-high = 'GT' .
APPEND s_g TO s_g.
SELECT-OPTIONS : s_h FOR lv_mskz NO-DISPLAY.
s_h-sign = 'I' .
s_h-option = 'BT' .
s_h-low = 'HK' .
s_h-high = 'HT' .
APPEND s_h TO s_h.

SELECT-OPTIONS : s_z FOR lv_mskz NO-DISPLAY.
s_z-sign = 'I' .
s_z-option = 'BT' .
s_z-low = 'ZA' .
s_z-high = 'ZZ' .
APPEND s_z TO s_z.
*********************END OF CHANGES BY SUBHENDU **************

wa_layout-zebra = 'X' .
wa_layout-colwidth_optimize = 'X' .
*  wa_layout-edit = 'X' .
wa_layout-no_vline = 'X' .
wa_layout-no_hline = 'X' .
wa_layout-no_hline = 'X' .
