*&---------------------------------------------------------------------*
*& Include          ZINCENTIVE_REPORT_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_data,
        vbeln TYPE vbrk-vbeln,
        fkdat TYPE vbrk-fkdat,
        werks TYPE vbrp-werks,
        posnr TYPE vbrp-posnr,
        fkimg TYPE vbrp-fkimg,
        charg TYPE vbrp-charg,
        matnr TYPE vbrp-matnr,
        netwr TYPE vbrp-netwr,
        matkl TYPE klah-class,
     brand_id TYPE mara-brand_id,
        maktx TYPE makt-maktx,
      END OF ty_data.

TYPES: BEGIN OF ty_fin,
        vbeln     TYPE vbrk-vbeln,
        fkdat     TYPE vbrk-fkdat,
        werks     TYPE vbrp-werks,
        posnr     TYPE vbrp-posnr,
        fkimg     TYPE vbrp-fkimg,
        charg     TYPE vbrp-charg,
        matnr     TYPE vbrp-matnr,
        netwr     TYPE vbrp-netwr,
        matkl     TYPE klah-class,
     brand_id     TYPE mara-brand_id,
        maktx     TYPE makt-maktx,
        lifnr     TYPE mseg-lifnr,
        group     TYPE klah-class,
        monday    TYPE c,
        tuesday   TYPE c,
        wednesday TYPE c,
        thursday  TYPE c,
        friday    TYPE c,
        saturday  TYPE c,
        sunday    TYPE c,
      END OF ty_fin.

TYPES: BEGIN OF ty_final,
        werks     TYPE werks_d,
        matkl     TYPE matkl,
        matnr     TYPE matnr,
        maktx     TYPE maktx,
        charg     TYPE charg_d,
        brand     TYPE mara-brand_id,
        group1    TYPE klah-class,
        lifnr     TYPE lifnr,
        pernr     TYPE persno,
        name      TYPE smnam,
        tar_pc    TYPE menge_d,
        tar_val   TYPE menge_d,
        ince_pc   TYPE menge_d,
        ince_val  TYPE menge_d,
        incentive TYPE menge_d,
        fkimg     TYPE vbrp-fkimg,
        netwr     TYPE vbrp-netwr,
      END OF ty_final.



DATA: lv_werks  TYPE werks_d,
      lv_date   TYPE zincentive-datef,
      lv_pernr  TYPE persno.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

DATA: it_fin   TYPE TABLE OF ty_fin,
      wa_fin   TYPE ty_fin,
      it_data  TYPE TABLE OF ty_data,
      it_zince TYPE TABLE OF zincentive,
      it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final.
