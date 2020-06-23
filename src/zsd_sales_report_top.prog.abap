*&---------------------------------------------------------------------*
*& Include          ZSD_SALES_REPORT_TOP
*&---------------------------------------------------------------------*

TABLES : klah,kssk,mara,mseg,vbrp.
TYPE-POOLS : slis.

*DATA: LV_GROUP_ID TYPE KLAH-CLASS VALUE 'SAREE'. "'BOYSREDYMADE'.
*      LV_GROUP_ID TYPE KLAH-CLASS VALUE 'BOYSREDYMADE'.


TYPES : BEGIN OF ty_data,
          slno  TYPE int4,
          class TYPE klah-class,
          clint TYPE klah-clint,
          objek TYPE kssk-objek,
          matnr TYPE matnr,
          matkl TYPE matkl,
        END OF ty_data,

        BEGIN OF ty_mara,
          matnr TYPE matnr,
          matkl TYPE matkl,
        END OF ty_mara,

        BEGIN OF ty_mseg,
          mblnr      TYPE mblnr,
          mjahr      TYPE mjahr,
          zeile      TYPE mblpo,
          line_id    TYPE mb_line_id,
          budat_mkpf TYPE budat,

          matnr      TYPE matnr,
          bwart      TYPE bwart,                    "MOMENT TYPE
          werks      TYPE werks_d,                  "PLANT
          menge      TYPE menge_d,                  "QUANTITY
          dmbtr      TYPE dmbtr_cs,                  "LC AMOUNT
        END OF ty_mseg,

        BEGIN OF ty_vbrp,
          vbeln TYPE vbrp-vbeln,
          posnr TYPE vbrp-posnr,
          fkimg TYPE vbrp-fkimg,
          netwr TYPE netwr_fp,
          prsdt TYPE vbrp-prsdt,
          werks TYPE vbrp-werks,
          matnr TYPE vbrp-matnr,
          mwsbp TYPE vbrp-mwsbp,
        END OF ty_vbrp.

TYPES : BEGIN OF ty_final,
          slno        TYPE int4,
          class       TYPE klah-class,
          clint       TYPE klah-clint,
          menge       TYPE mseg-menge,
*          fkimg TYPE
*           fkimg TYPE vbrp-fkimg,
          dmbtr       TYPE mseg-dmbtr,
          fkimg       TYPE fkimg,
          netwr       TYPE netwr_fp,
          prsdt       TYPE prsdt,
          zeile       TYPE mseg-zeile,
          matnr       TYPE matnr,
          maktx       TYPE maktx,
          matkl       TYPE matkl,
          zzprice_frm TYPE zpr_frm,
          zzprice_to  TYPE zpr_to,
          mwsbp       TYPE vbrp-mwsbp,
          size1       TYPE mara-size1,
*          MWSBP1    TYPE VBRP-MWSBP,
          lvvar       TYPE vbrp-mwsbp,
          netwr_l     TYPE netwr_fp,
          mwsbp_l     TYPE vbrp-mwsbp,
          tot_price   TYPE netwr_fp,
*  werks TYPE vbrp-werks,
        END OF ty_final.

TYPES : BEGIN OF ty_klah ,
          clint TYPE clint,
          klart TYPE klassenart,
          class TYPE klasse_d,
          vondt TYPE vondat,
          bisdt TYPE bisdat,
          wwskz TYPE klah-wwskz,
        END OF ty_klah .

DATA : it_klah  TYPE TABLE OF ty_klah,
       wa_klah  TYPE ty_klah,
       it_klaha TYPE TABLE OF ty_klah,
       wa_klaha TYPE ty_klah.

DATA: it_mara   TYPE TABLE OF ty_mara,
      wa_mara   TYPE ty_mara,

      it_final  TYPE TABLE OF ty_final,
      wa_final  TYPE ty_final,
      it_final1 TYPE TABLE OF ty_final,
      wa_final1 TYPE ty_final,
      it_final2 TYPE TABLE OF ty_final,
      wa_final2 TYPE ty_final,
      it_vbrp1  TYPE TABLE OF ty_vbrp,
      wa_vbrp1  TYPE ty_vbrp,
      it_fin    TYPE TABLE OF ty_final,
      wa_fin    TYPE ty_final,
      slno      TYPE int4.
DATA:
  it_fcat TYPE slis_t_fieldcat_alv,
  wa_fcat TYPE slis_fieldcat_alv.

DATA: menge TYPE menge_d,
      fkimg TYPE fkimg,
      lvvar TYPE vbrp-mwsbp.
*  DATA: DMBTR TYPE MSEG-DMBTR.
DATA: netwr   TYPE netwr_fp,
      netwr_l TYPE netwr_fp,   " (20-3-20)

      netwr_t TYPE string.
DATA : mwsbp TYPE vbrp-mwsbp.

DATA : r_to   TYPE RANGE OF mara-zzprice_to WITH HEADER LINE,
       r_from TYPE RANGE OF mara-zzprice_frm WITH HEADER LINE,
       r_size TYPE RANGE OF mara-size1 WITH HEADER LINE.
