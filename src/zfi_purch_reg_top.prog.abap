*&---------------------------------------------------------------------*
*& Include          ZFI_PURCH_REG_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

TABLES: ekko,
        mkpf,
        rbkp,
        lfa1,
        rseg.                                               "N1774892
*--> Type_declaration ->
TYPES : BEGIN OF ty_ekbe ,
          ebeln    TYPE ebeln,            "Purchasing Document Number
          ebelp    TYPE ebelp,            "Item Number of Purchasing Document
          zekkn    TYPE dzekkn,           "Sequential Number of Account Assignment
          vgabe    TYPE vgabe,            "Transaction/event type, purchase order history
          gjahr    TYPE mjahr,            "Material Document Year
          belnr    TYPE mblnr,            "Number of Material Document
          buzei    TYPE mblpo,            "Item in Material Document
          bewtp	   TYPE bewtp,            "Purchase Order History Category
          bwart	   TYPE bwart,            "Movement type (inventory management)
          budat	   TYPE budat,            "Posting Date in the Document
          bldat	   TYPE bldat,            "Doc Date in the Document
          menge	   TYPE menge_d,          "Quantity
          bpmng	   TYPE menge_bpr,        "Quantity in purchase order price unit
          dmbtr	   TYPE dmbtr,            "Amount in local currency
          wrbtr	   TYPE wrbtr,            "Amount in document currency
          waers	   TYPE waers,
          arewr	   TYPE arewr,            "
          wesbs	   TYPE wesbs,            "
          bpwes	   TYPE bpwes,            "
          shkzg	   TYPE shkzg,            "
          bwtar	   TYPE bwtar_d,          "
          elikz	   TYPE elikz,            "
          xblnr	   TYPE xblnr1,
          lfgja	   TYPE lfbja,
          lfbnr	   TYPE lfbnr,
          lfpos	   TYPE lfpos,
          reewr    TYPE reewr,            "Invoice Local Crncy
          refwr    TYPE refwr,            "Invoice Document Crncy
          matnr	   TYPE matnr,
          werks	   TYPE werks_d,
          knumv	   TYPE knumv,
          mwskz	   TYPE mwskz,
          bamng	   TYPE menge_d,
          charg	   TYPE charg_d,
          srvpos   TYPE srvpos,
          packno   TYPE packno_ekbe,
          introw   TYPE introw_ekbe,
          wkurs	   TYPE wkurs,
          vbeln_st TYPE	vbeln_vl,
          vbelp_st TYPE posnr_vl,
        END OF ty_ekbe ,

*--> Histiry_document_delivery_costs_incase_of_import ->
        BEGIN OF ty_ekbz,
          ebeln TYPE ebeln   ,         "Purchasing Document Number
          ebelp TYPE ebelp   ,         "Item Number of Purchasing Document
          stunr TYPE stunr   ,         "Step Number
          zaehk TYPE dzaehk  ,         "Condition Counter
          vgabe TYPE vgabe   ,         "Transaction/event type, purchase order history
          gjahr TYPE gjahr   ,         "Fiscal Year
          belnr TYPE belnr_d ,         "Accounting Document Number
          buzei TYPE mblpo   ,         "Item in Material Document
          bewtp TYPE bewtp,
          budat TYPE budat,
          menge TYPE menge_d,
          dmbtr TYPE dmbtr,
          wrbtr TYPE wrbtr,
          waers TYPE waers,
          kschl TYPE kschl,
          shkzg TYPE shkzg,
          xblnr TYPE xblnr1,
          frbnr TYPE frbnr1,
          lifnr TYPE lifnr,
          reewr TYPE reewr,
          refwr TYPE refwr,
          bwtar TYPE bwtar_d,
          wkurs TYPE wkurs,
        END OF ty_ekbz ,

        BEGIN OF ty_lfa1,
          lifnr      TYPE lfa1-lifnr,
          name1      TYPE lfa1-name1,
          name2      TYPE lfa1-name2,
          name3      TYPE lfa1-name3,
          name4      TYPE lfa1-name4,
          ort01      TYPE lfa1-ort01,
          regio      TYPE lfa1-regio,
          land1      TYPE lfa1-land1,
          ven_class	 TYPE  j_1igtakld,
          stcd3	     TYPE stcd3,
          j_1ipanref TYPE lfa1-j_1ipanref,
****          j_1ipanref TYPE j_1ipanref,
****          j_1iexcd   TYPE lfa1-j_1iexcd,
****          j_1iexrn   TYPE lfa1-j_1iexrn,
****          j_1iexrg   TYPE lfa1-j_1iexrg,
****          j_1iexdi   TYPE lfa1-j_1iexdi,
****          j_1iexco   TYPE lfa1-j_1iexco,
****          j_1icstno  TYPE lfa1-j_1icstno,
****          j_1ilstno  TYPE lfa1-j_1ilstno,
****          j_1ipanno  TYPE lfa1-j_1ipanno,
****          j_1iexcive TYPE lfa1-j_1iexcive,
****          j_1issist  TYPE lfa1-j_1issist,
****          j_1ivtyp   TYPE lfa1-j_1ivtyp,
****          j_1ivencre TYPE lfa1-j_1ivencre,
        END OF ty_lfa1 ,
*--> Material_document_invoice_details_RBKP Header
        BEGIN OF ty_rbkp,
          belnr   TYPE re_belnr,
          bukrs   TYPE rbkp-bukrs,
          gjahr	  TYPE gjahr,
          budat   TYPE budat,
          rmwwr	  TYPE rmwwr,
          beznk	  TYPE beznk,
          wmwst1  TYPE fwstev,
          mwskz1  TYPE mwskz_mrm1,
          stcd3   TYPE stcd3,
          bldat   TYPE bldat,
          lifnr   TYPE lifre,
          waers	  TYPE waers,
          xblnr	  TYPE xblnr1,
          rbstat  TYPE rbstat,
          stblg   TYPE stblg,
          regio   TYPE regio,
          landl   TYPE land1,
          plc_sup TYPE j_1ig_region,
          knumve  TYPE knumv,
          gsber   TYPE gsber,
          sgtxt   TYPE sgtxt,
          kursf   TYPE kursf,
        END OF ty_rbkp,

*--> Material_document_invoice_details_RSEG Item ->
        BEGIN OF ty_rseg,
          belnr	      TYPE belnr_d,
          gjahr	      TYPE gjahr,
          buzei	      TYPE rblgp,
          ebeln	      TYPE ebeln,
          ebelp	      TYPE ebelp,
          zekkn       TYPE dzekkn,
          bukrs       TYPE bukrs,
          matnr	      TYPE matnr,
          hsn_sac	    TYPE j_1ig_hsn_sac,
          mwskz       TYPE 	mwskz,
          wrbtr       TYPE  wrbtr,
          menge	      TYPE menge_d,
          meins       TYPE meins,
          werks       TYPE werks_d,
          pstyp       TYPE  rseg-pstyp,
          knttp       TYPE rseg-knttp,
          bstme	      TYPE bstme,
          kschl       TYPE kschl,
          sgtxt       TYPE sgtxt,
          shkzg       TYPE shkzg,
          introw      TYPE introw,
          packno      TYPE packno,
          lfbnr       TYPE lfbnr,
          lfgja	      TYPE lfgja,
          lfpos	      TYPE lfpos,
          customs_val TYPE rseg-customs_val,
          licno       TYPE rseg-licno,
          zeile       TYPE rseg-zeile,
          zaehk       TYPE rseg-zaehk,
          bnkan       TYPE rseg-bnkan,
        END OF ty_rseg,

*--> PO Header_details ->
        BEGIN OF ty_ekko,
          ebeln	TYPE ebeln,
          bsart	TYPE esart,
          bedat TYPE ebdat,
          bstyp TYPE ebstyp,
          ekorg TYPE ekorg,
          ekgrp TYPE ekgrp,
          lifnr TYPE lifnr,
          knumv TYPE knumv,
        END OF ty_ekko,
*--> PO_Item_details ->
        BEGIN OF ty_ekpo,
          ebeln  TYPE ebeln,
          ebelp  TYPE ebelp,
          werks  TYPE werks_d,
          txz01  TYPE txz01,
          packno TYPE packno,
          menge  TYPE menge_d,
          navnw  TYPE navnw,
          matnr  TYPE matnr,
          meins  TYPE ekpo-meins,
          mwskz  TYPE ekpo-mwskz,
        END OF ty_ekpo ,

*--> Finance Accounting_document_ ->
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
*--> Condition_tables ->
        BEGIN OF ty_konp,
          knumh TYPE knumh,
          kopos TYPE kopos,
          mwsk1 TYPE  mwskz,
          kschl TYPE kschl,
          kbetr	TYPE kbetr_kond,
        END OF ty_konp,
*--> FI_Item_table_BSEG ->
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
          mwskz   TYPE mwskz,
          ktosl   TYPE bseg-ktosl,
          plc_sup TYPE regio,
          bupla   TYPE bupla,
          gsber   TYPE gsber,
          kostl   TYPE kostl,
          pswbt   TYPE pswbt,
          hkont   TYPE hkont,
        END OF ty_bseg,
*--> FI_header_data_for_documents ->
        BEGIN OF ty_bkpf,
          bukrs	    TYPE bukrs,
          belnr	    TYPE belnr_d,
          gjahr	    TYPE gjahr,
          xblnr	    TYPE xblnr1,
          xblnr_alt TYPE 	xblnr_alt,
          kursf     TYPE kursf,
*        awkey      TYPE awkey,
          awref_rev TYPE awref_rev,
        END OF ty_bkpf,
*--> Billing_header ->
        BEGIN OF ty_vbrk,
          vbeln TYPE vbeln_vf,    ""Billing Document
          fkart TYPE fkart,       "Billing Type
          fkdat TYPE fkdat,       ""date
          regio TYPE regio,       ""region
          kunrg TYPE kunrg,       ""Payer
          kunag TYPE kunag,       ""Sold-to party
          knumv TYPE knumv,       ""dondition no
          xblnr TYPE xblnr_v1,
        END OF ty_vbrk,
*--> Billing_item ->
        BEGIN OF ty_vbrp,
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
        END OF ty_vbrp,
*--> HSN_code_details ->
        BEGIN OF ty_marc,
          matnr TYPE matnr,
          steuc TYPE  steuc,
          werks TYPE werks_d,
        END OF ty_marc,

*--> Sales_document_flow ->
        BEGIN OF ty_vbfa,
          vbelv	  TYPE vbeln_von,
          vbeln	  TYPE vbeln_nach,
          vbtyp_v	TYPE vbtypl_v,
        END OF ty_vbfa,
*--> Sales_partner_details ->
        BEGIN OF ty_vbpa,
          vbeln	TYPE vbeln_va,
          adrnr	TYPE adrnr,
          kunnr	TYPE kunnr,
          parvw TYPE parvw,
        END OF ty_vbpa,
*--> Country_of_vendor/Customer ->
        BEGIN OF ty_t005u,
          spras TYPE spras,
          land1	TYPE land1,
          bland	TYPE regio,
          bezei	TYPE bezei20,
        END OF ty_t005u,
*--> HSN_Descrption ->
        BEGIN OF ty_t604n,
          steuc TYPE steuc,
          text1	TYPE bezei60,
        END OF ty_t604n,
*--> Material_documents_item-details ->
        BEGIN OF ty_mseg,
          mblnr      TYPE mseg-mblnr,
          mjahr      TYPE mseg-mjahr,
          zeile      TYPE mseg-zeile,
          ebeln      TYPE mseg-ebeln,
          ebelp      TYPE mseg-ebelp,
          budat_mkpf TYPE mseg-budat_mkpf,

        END OF ty_mseg,

*--> Material_price_table ->
        BEGIN OF ty_mbew,
          matnr TYPE matnr,
          bwkey TYPE bwkey,
          verpr TYPE verpr,
          zplp1 TYPE dzplp1,
          zplp2	TYPE dzplp2,
          zplp3	TYPE dzplp3,
          vprsv TYPE vprsv,
          stprs TYPE stprs,
        END OF ty_mbew,
*--> Asset_procurement_Amounts ->
        BEGIN OF ty_j_1iassval,
          j_1imatnr  TYPE matnr,
          j_1ivalass TYPE j_1ivalass,
          j_1iwaers  TYPE j_1iwaers,
        END OF ty_j_1iassval,

*--> Terms_details_in_sales ->
        BEGIN OF ty_vbkd,
          vbeln TYPE  vbeln,
          posnr	TYPE posnr,
          bstkd	TYPE bstkd,
          bstdk	TYPE bstdk,
        END OF ty_vbkd,
*--> Service_line_item_details ->
        BEGIN OF ty_esll ,
          packno        TYPE packno,
          introw        TYPE numzeile,
          extrow        TYPE extrow,
          srvpos        TYPE  asnum,
          ktext1        TYPE sh_text1,
          sub_packno    TYPE packno,
          menge         TYPE menge_d,
          act_menge     TYPE menge_d,
          meins         TYPE meins,
          brtwr         TYPE sbrtwr,
          netwr         TYPE snetwr,
          matkl	        TYPE matkl_srv,
          tbtwr	        TYPE sbrtwr,
          act_wert      TYPE act_wert,
          navnw	        TYPE navnw_srv,
          baswr	        TYPE baswr,
          kknumv        TYPE  knumv,
          userf1_num    TYPE userf1_num,
          belnr         TYPE catsbelnr, "
          taxtariffcode TYPE steuc,
        END OF ty_esll ,
*--> Withholding_Tax_amount_details_for_service ->
        BEGIN OF ty_with_item,
          bukrs     TYPE bukrs,
          belnr     TYPE belnr_d,
          gjahr     TYPE gjahr,
          buzei     TYPE buzei,
          witht     TYPE witht,
          wt_withcd TYPE with_item-wt_withcd,
          qsatz     TYPE with_item-qsatz,
          wt_qbshb  TYPE with_item-wt_qbshb,
        END OF ty_with_item,

*--> Tax_amount_for_invoice ->
        BEGIN OF ty_rbtx,
          belnr TYPE re_belnr,
          gjahr TYPE gjahr,
          mwskz TYPE mwskz_mrm,
          wmwst TYPE fwstev    ,  " Tax Amount in Document Currency with +/- Sign
          fwbas TYPE fwbas_bses,   "Tax base amount in document currency
          hwste TYPE hwste     ,   "Tax Amount in Local Currency
          hwbas TYPE hwbas_bses,   "Tax Base Amount in Local Currency
          txjcd TYPE txjcd     ,   "Tax Jurisdiction
          txjdp TYPE txjcd_deep,   "Tax Jurisdiction Code - Jurisdiction for Lowest Level Tax
          kschl TYPE kschl     ,   "Condition type
          taxps TYPE taxps     ,   "Document item number refering to tax document.
        END OF ty_rbtx ,

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
        END OF ty_bset.


TYPES : BEGIN OF ty_skat,  "*---->>> ( GL DESC )
          ktopl TYPE ktopl,
          saknr TYPE saknr,
          txt20 TYPE txt20_skat,
        END OF ty_skat.

DATA: wa_vbrk TYPE ty_vbrk,
      it_vbrk TYPE TABLE OF ty_vbrk,
      wa_vbrp TYPE ty_vbrp,
      it_vbkd TYPE TABLE OF ty_vbkd,
      wa_vbkd TYPE ty_vbkd,
      it_vbrp TYPE TABLE OF ty_vbrp.

*--> Global_data_declaration ->
DATA : gt_ekbe      TYPE TABLE OF ty_ekbe WITH HEADER LINE,
       gt_ekbz      TYPE TABLE OF ty_ekbz WITH HEADER LINE,
       gt_rbtx      TYPE TABLE OF ty_rbtx WITH HEADER LINE,
       gt_lfa1      TYPE TABLE OF ty_lfa1 WITH HEADER LINE,
       gt_t005t     TYPE TABLE OF t005t WITH HEADER LINE,
       gt_lfbw      TYPE TABLE OF lfbw WITH HEADER LINE,
       gt_rbkp      TYPE TABLE OF ty_rbkp WITH HEADER LINE,
       gt_rseg      TYPE TABLE OF ty_rseg WITH HEADER LINE,
*       gt_material  TYPE TABLE OF makt WITH HEADER LINE,
       gt_material  TYPE TABLE OF v_mara_makt WITH HEADER LINE,
       gt_with_item TYPE TABLE OF ty_with_item WITH HEADER LINE,
       gt_esll      TYPE TABLE OF ty_esll WITH HEADER LINE,
       gt_ekko      TYPE TABLE OF ty_ekko WITH HEADER LINE,
       gt_ekpo      TYPE TABLE OF ty_ekpo WITH HEADER LINE,
       gt_mseg      TYPE TABLE OF ty_mseg WITH HEADER LINE,
       gt_bkpf      TYPE TABLE OF ty_bkpf WITH HEADER LINE,
       gt_bseg      TYPE TABLE OF ty_bseg WITH HEADER LINE,
       gt_mbew      TYPE TABLE OF ty_mbew WITH HEADER LINE,
       gt_vbrk      TYPE TABLE OF ty_vbrk WITH HEADER LINE,
       gt_vbrp      TYPE TABLE OF ty_vbrp WITH HEADER LINE,
       gt_marc      TYPE TABLE OF ty_marc WITH HEADER LINE,
       gt_t604n     TYPE TABLE OF ty_t604n WITH HEADER LINE,
       gt_t005u     TYPE TABLE OF t005u WITH HEADER LINE,
       gt_a003      TYPE TABLE OF a003 WITH HEADER LINE,
       gt_konp      TYPE TABLE OF ty_konp WITH HEADER LINE,
       gt_t059w     TYPE TABLE OF t059w WITH HEADER LINE,
       gt_t059zt    TYPE TABLE OF t059zt WITH HEADER LINE,
       gt_essr      TYPE TABLE OF essr WITH HEADER LINE.

DATA : it_skat TYPE STANDARD TABLE OF ty_skat,
       wa_skat TYPE ty_skat,
       gt_bset TYPE TABLE OF ty_bset,
       gw_bset TYPE ty_bset.


DATA : lv_budat TYPE budat,
       lv_ebeln TYPE ebeln,
       lv_belnr TYPE belnr_d,
       lv_gjahr TYPE gjahr,
       lv_bukrs TYPE bukrs,
       lv_gsber TYPE bseg-gsber,
       lv_werks TYPE werks_d.

*--> Final_table_type ->

TYPES : BEGIN OF ty_final,
          slno        TYPE int8,
          budat       TYPE budat,
          werks       TYPE werks_d,
          bsart       TYPE esart,
          ebeln       TYPE ebeln,
          ebelp       TYPE ebelp,
          lifnr       TYPE lifnr,
          supl_name   TYPE name1,
          supl_cntry  TYPE buzei,
          supl_regio  TYPE regio,
          stcd3       TYPE stcd3,
          mr_belnr    TYPE belnr_d,
          fi_belnr    TYPE belnr_d,
          gjahr       TYPE gjahr,
          gsber       TYPE gsber,
          invoice     TYPE vbeln,
          supl_invdt  TYPE budat,
          matnr       TYPE matnr_d,
          mtart       TYPE mtart,
          matkl       TYPE matkl,
          maktx       TYPE maktx,
          mwskz       TYPE mwskz,
          steuc       TYPE steuc,
          menge       TYPE menge_d,
          rate        TYPE dmbtr,  "Rate
          grs_value   TYPE hwbas_bses,  "Gross_value
          waers       TYPE waers,
          meins       TYPE meins,  "UOM
          base_amt    TYPE fwbas_bses, "Base_amt
          tax_amt     TYPE hwste,
          cgstp       TYPE p DECIMALS 2 , "CGST Percnt.
          cgst        TYPE hwste, "CGST
          sgstp       TYPE p DECIMALS 2 , "SGST Percnt.
          sgst        TYPE hwste, "CGST
          igstp       TYPE p DECIMALS 2 , "IGST Percnt.
          igst        TYPE hwste, "CGST
          ugstp       TYPE p DECIMALS 2 , "UGST Percnt.
          ugst        TYPE hwste, "CGST
          tot_taxamt  TYPE hwste,
          tot_inv     TYPE dmbtr,  "Total_invoice_amt
          tds_amt     TYPE wertv8, "Witholding_amt
          tot_inv_tds TYPE dmbtr, "Total_invoice_including_tds
          tds_type    TYPE witht, "TDS Type
          tds_code    TYPE wt_withcd, "TDS_CODE
          tds_desc    TYPE char40,   "TDS_Desc
          wt_exnr     TYPE wt_exnr,     "Exm. No
          wt_exrt     TYPE wt_exrt,     "Rate
          wt_exdf     TYPE wt_exdf,     "Exm. From
          wt_exdt     TYPE wt_exdt,    "Exm. to
          wt_wtexrs   TYPE text30,
        END OF ty_final .


DATA : gt_final     TYPE TABLE OF zspurch_reg , "ty_final,
       gt_final01   TYPE TABLE OF zspurch_reg , "ty_final,
       gw_final     TYPE  zspurch_reg, "ty_final,
       it_with_item TYPE TABLE OF ty_with_item,
       wa_with_item TYPE ty_with_item.
DATA :       lv_awkey   TYPE awkey.

DATA : lr_alv TYPE REF TO cl_salv_table,
       it_raw TYPE truxs_t_text_data.

DATA: lo_cols TYPE REF TO cl_salv_columns_table.
DATA: lo_events TYPE REF TO cl_salv_events_table.
DATA: lr_functions TYPE REF TO cl_salv_functions.
DATA: lo_h_label TYPE REF TO cl_salv_form_label,
      lo_h_flow  TYPE REF TO cl_salv_form_layout_flow,
      lo_header  TYPE REF TO cl_salv_form_layout_grid,
      lr_layout  TYPE REF TO salv_s_layout.


** Declaration for Global Display Settings
DATA : gr_display TYPE REF TO cl_salv_display_settings,
       lv_title   TYPE lvc_title.

** declaration for ALV Columns
DATA : gr_columns    TYPE REF TO cl_salv_columns_table,
       gr_column     TYPE REF TO cl_salv_column,
       lt_column_ref TYPE salv_t_column_ref,
       ls_column_ref TYPE salv_s_column_ref.

** Declaration for Aggregate Function Settings
DATA : gr_aggr    TYPE REF TO cl_salv_aggregations.

** Declaration for Sort Function Settings
DATA : gr_sort    TYPE REF TO cl_salv_sorts.

** Declaration for Table Selection settings
DATA : gr_select  TYPE REF TO cl_salv_selections.

** Declaration for Top of List settings
DATA : gr_content TYPE REF TO cl_salv_form_element.

DATA: lo_layout TYPE REF TO cl_salv_layout,
*            lf_variant TYPE slis_vari,
      ls_key    TYPE salv_s_layout_key.


TYPES : BEGIN OF ty_t161 ,
          bstyp TYPE t161-bstyp,
          bsart TYPE t161-bsart,
          bsakz TYPE t161-bsakz,
          numki TYPE t161-numki,
          numke TYPE t161-numke,
          brefn TYPE t161-brefn,
        END OF ty_t161.

DATA : st161  TYPE TABLE OF ty_t161 WITH HEADER LINE,
       st161t TYPE TABLE OF t161t WITH HEADER LINE,
       slifnr TYPE lifnr.

CONSTANTS  : syes(3) TYPE c VALUE 'Yes',
             sno(2)  TYPE c VALUE 'No'.

TYPES : BEGIN OF ty_inw_hdr,
          invoice    TYPE zinw_t_hdr-invoice,
          bill_num   TYPE zinw_t_hdr-bill_num,
          debit_note TYPE zinw_t_hdr-debit_note,
        END OF ty_inw_hdr.
FIELD-SYMBOLS : <ls_inw_hdr> TYPE ty_inw_hdr.
FIELD-SYMBOLS : <ls_inw_hdr1> TYPE ty_inw_hdr.
