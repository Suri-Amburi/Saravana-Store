*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_EXPORTS_TOP
*&---------------------------------------------------------------------*



TABLES:bkpf,vbrk,marc,vbrp.

TYPES:BEGIN OF ty_bkpf,
        bukrs     TYPE bukrs,
        belnr     TYPE belnr_d,
        gjahr     TYPE gjahr,
        blart     TYPE blart,
        budat     TYPE budat,
        xblnr     TYPE xblnr1,
        xblnr_alt TYPE xblnr_alt,
        awkey     TYPE awkey,
      END OF ty_bkpf.

TYPES:BEGIN OF ty_bseg,
        bukrs   TYPE bukrs,
        belnr   TYPE belnr_d,
        gjahr   TYPE gjahr,
        buzei   TYPE buzei,
        bschl   TYPE bschl,
        shkzg   TYPE shkzg,
        dmbtr   TYPE dmbtr,
        hwbas   TYPE hwbas,
        txgrp   TYPE txgrp,
        ktosl   TYPE ktosl,
        vbeln   TYPE vbeln_vf,
        hkont   TYPE hkont,
        kunnr   TYPE kunnr,
        bupla   TYPE bupla,
        hsn_sac TYPE j_1ig_hsn_sac,
        rebzg   TYPE rebzg,
        wrbtr   TYPE wrbtr,
      END OF ty_bseg.

TYPES:BEGIN OF ty_kna1,
        kunnr TYPE kunnr,
        name1	TYPE name1_gp,
        name2	TYPE name2_gp,
        stcd3 TYPE stcd3,
        adrnr TYPE adrnr,
        regio TYPE regio,
      END OF ty_kna1.

TYPES:BEGIN OF ty_konv,
        knumv TYPE  knumv,
        kposn	TYPE kposn,
        kschl	TYPE kscha,
        knumh	TYPE knumh,
        kopos	TYPE kopos_long,
        kwert	TYPE vfprc_element_value,
        kbetr	TYPE vfprc_element_value,
      END OF ty_konv.


TYPES:BEGIN OF ty_marc,
        matnr TYPE matnr,
        werks TYPE werks_d,
        steuc TYPE  steuc,
      END OF ty_marc,

      BEGIN OF ty_t604n,
        spras TYPE spras,
        land1 TYPE land1,
        steuc TYPE steuc,
        text1 TYPE bezei60,
      END OF ty_t604n.

TYPES:BEGIN OF ty_makt,
        matnr TYPE matnr,
        maktx TYPE maktx,
      END OF ty_makt.

TYPES:BEGIN OF ty_adrc,
        addrnumber TYPE  ad_addrnum,
        extension1 TYPE ad_extens1,
        tel_number TYPE char30,
      END OF ty_adrc.

TYPES:BEGIN OF ty_adr6,
        addrnumber TYPE ad_addrnum,
        smtp_addr  TYPE ad_smtpadr,
      END OF ty_adr6.

TYPES:BEGIN OF ty_vbrk,
        vbeln TYPE vbeln_vf,    ""Billing Document
        fkart TYPE fkart,       "Billing Type
        vkorg TYPE vkorg,
        vtweg TYPE vtweg,
        knumv TYPE knumv,       ""dondition no
        fkdat TYPE fkdat,       ""date
        land1 TYPE lland,
        regio TYPE regio,       ""region
        kunrg TYPE kunrg,       ""Payer
        kunag TYPE kunag,       ""Sold-to party
        spart TYPE spart,
        xblnr TYPE xblnr_v1,
        exnum TYPE exnum,
        gjahr TYPE gjahr,
        waerk TYPE vbrk-waerk,
        kurrf TYPE vbrk-kurrf,
        belnr TYPE belnr_d,
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
        aubel      TYPE vbeln_va,
      END OF ty_vbrp.

TYPES:BEGIN OF ty_eikp,
        exnum TYPE exnum,
        aland TYPE hland,
        ladel TYPE ladel,
      END OF  ty_eikp.

TYPES:BEGIN OF ty_fin,
        slno     TYPE int4,
        blart    TYPE fkart,
        matnr    TYPE matnr,    "Material
        maktx    TYPE string,
        maktx1   TYPE maktx,
        steuc    TYPE steuc,
        invn     TYPE vbrk-xblnr, "added by akankshya "Invoice No
        vbeln    TYPE vbeln_vf, "Billing Document
        fkdat    TYPE fkdat,    "Billing Date
        belnr    TYPE belnr_d, "*---->>> ( DOC NO ) mumair <<< 07.11.2019 13:32:05
        posnr    TYPE posnr_vf, "Billing Item
        fkimg    TYPE fkimg,
        vrkme    TYPE vrkme,
*        NETWR    TYPE VBRP-NETWR,
        taxblval TYPE kbetr,
        igstp    TYPE kbetr,
        igst     TYPE kbetr,
*        ABLAD    TYPE VBPA-ABLAD,
        cgstp    TYPE kwert,
        cgst     TYPE kbetr,
        sgstp    TYPE kwert,
        sgst     TYPE kbetr,
*        UGST     TYPE KBETR,
*        cessp    TYPE kwert,
        cess     TYPE kbetr,
        other    TYPE kbetr,
*---->>> ( ADDED ) mumair <<< 18.11.2019 15:54:18
*        TCS   TYPE KBETR,
*        TCSP  TYPE KBETR,
*        INO   TYPE KBETR,
*        INOP  TYPE KBETR,
*        FRT   TYPE KBETR,
*        FRTP  TYPE KBETR,
*        OPS   TYPE KBETR,
*        OPSP  TYPE KBETR,
*        DIFF  TYPE KBETR,
*        DIS   TYPE KBETR,
*        CESSP  TYPE KBETR,
*---->>> ( END OF ADDED ) mumair <<< 18.11.2019 15:54:46

*        UGSTP    TYPE KWERT,

        d18      TYPE c,
        totinv   TYPE kbetr,
        pcode    TYPE string,
        sbill    TYPE string,
        sdate    TYPE string,
        EXTYPE   TYPE CHAR10,

      END OF ty_fin.

TYPES: BEGIN OF ty_vbfa,
         vbelv TYPE vbeln_von,
         vbeln TYPE vbeln_nach,
       END OF ty_vbfa.

TYPES:BEGIN OF ty_vbpa,
        vbeln	TYPE vbeln_va,
        adrnr	TYPE adrnr,
        kunnr	TYPE kunnr,
        parvw TYPE parvw,
      END OF ty_vbpa.

TYPES:BEGIN OF ty_mseg,
        mblnr TYPE mblnr,
        lifnr	TYPE lifnr,
        matnr TYPE matnr,
      END OF ty_mseg.

TYPES:BEGIN OF ty_lfa1,
        lifnr TYPE lifnr,
        land1	TYPE land1_gp,
        name1	TYPE name1_gp,
        name2	TYPE name2_gp,
        stcd3 TYPE stcd3,
        regio TYPE regio,
        telf1 TYPE telf1,
      END OF ty_lfa1.

TYPES : BEGIN OF ts_vbak,
          vbeln TYPE vbak-vbeln,
          audat TYPE vbak-audat,
          bstnk TYPE vbak-bstnk,
          bstdk TYPE vbak-bstdk,
        END OF ts_vbak .

TYPES: BEGIN OF ts_vbpa,
         vbeln TYPE vbpa-vbeln,
         posnr TYPE vbpa-posnr,
         parvw TYPE vbpa-parvw,
         adrnr TYPE vbpa-adrnr,
         ablad TYPE vbpa-ablad,
       END OF ts_vbpa.

DATA:wa_vbrk  TYPE ty_vbrk,
     it_vbrk  TYPE TABLE OF ty_vbrk,
     wa_vbrp  TYPE ty_vbrp,
     it_vbrp  TYPE TABLE OF ty_vbrp,
     wa_kna1  TYPE ty_kna1,
     it_kna1  TYPE TABLE OF ty_kna1,
     wa_marc  TYPE ty_marc,
     it_marc  TYPE TABLE OF ty_marc,
     it_makt  TYPE TABLE OF ty_makt,
     wa_makt  TYPE ty_makt,
     it_vbpa  TYPE TABLE OF ty_vbpa,
     wa_vbpa  TYPE ty_vbpa,
     it_vbfa  TYPE TABLE OF ty_vbfa,
     wa_vbfa  TYPE ty_vbfa,
     it_bkpf  TYPE TABLE OF ty_bkpf,
     wa_bkpf  TYPE ty_bkpf,
     it_bseg  TYPE TABLE OF ty_bseg,
     it_bseg1 TYPE TABLE OF ty_bseg,
     wa_bseg  TYPE ty_bseg,
     wa_bseg1 TYPE ty_bseg,
     it_konv  TYPE TABLE OF ty_konv,
     wa_konv  TYPE ty_konv,
     it_tvfkt TYPE TABLE OF tvfkt,
     wa_tvfkt TYPE tvfkt,
     it_adrc  TYPE TABLE OF ty_adrc,
     wa_adrc  TYPE  ty_adrc,
     it_adr6  TYPE TABLE OF ty_adr6,
     wa_adr6  TYPE  ty_adr6,
     it_eikp  TYPE  TABLE OF ty_eikp,
     wa_eikp  TYPE  ty_eikp,
     it_fin   TYPE TABLE OF ty_fin,
     it_fin1  TYPE TABLE OF ty_fin,
     it_fin2  TYPE TABLE OF ty_fin,
     it_vbpa1 TYPE TABLE OF ts_vbpa,
     wa_vbpa1 TYPE ts_vbpa,
     it_vbak  TYPE TABLE OF ts_vbak,
     wa_vbak  TYPE ts_vbak,
     wa_fin   TYPE  ty_fin,
     wa_fin1  TYPE  ty_fin,
     wa_fin2  TYPE  ty_fin,
     wa_regio TYPE  zregion_codes,
     it_mseg  TYPE TABLE OF ty_mseg,
     wa_mseg  TYPE ty_mseg,
     wa_lfa1  TYPE ty_lfa1,
     it_lfa1  TYPE TABLE OF ty_lfa1.



DATA:o_alv      TYPE REF TO cl_salv_table,   "Object of class cl-salv_table
     lv_msg     TYPE REF TO cx_salv_msg, "#EC NEEDED "Catching exceptions
     o_function TYPE REF TO cl_salv_functions_list, "For setting PF-Status
     lf_events  TYPE REF TO cl_salv_events_table.    "For handling double click event

DATA:c_alv TYPE REF TO cl_gui_alv_grid.

DATA:fright1  TYPE kbetr,
     fright2  TYPE kbetr,
     fright3  TYPE kbetr,
     insurns1 TYPE kbetr,
     insurns2 TYPE kbetr,
     packing1 TYPE kbetr,
     packing2 TYPE kbetr,
     othrs1   TYPE kbetr,
     othrs2   TYPE kbetr,
     othrs3   TYPE kbetr,
     othrs4   TYPE kbetr,
     othrs5   TYPE kbetr,
     servic   TYPE kbetr,
     subcon   TYPE kbetr,
     tdiscnt  TYPE kbetr,
     tdiscnt1  TYPE kbetr,
     tdiscnt2  TYPE kbetr,
     basval   TYPE kbetr,
     zsto     TYPE kbetr.

DATA:insurns6  TYPE char13,
     fright6   TYPE char13,
     packing6  TYPE char13,
     othrs6    TYPE char13,
     taxblval2 TYPE char13,
     totinv2   TYPE char13,
*     tdiscnt2  TYPE char13,S
     basval2   TYPE char13,
     sgst2     TYPE char13,
     cgst2     TYPE char13,
     igst2     TYPE char13,
     ugst2     TYPE char13,
     cess2     TYPE char13.


TYPES:BEGIN OF t_awkey,
        tawkey TYPE awkey,
      END OF t_awkey.

DATA:w_inval TYPE t_awkey,
     t_inval TYPE TABLE OF t_awkey.

DATA : tdobname TYPE tdobname,
       it_line  TYPE TABLE OF tline,
       wa_line  TYPE tline.
