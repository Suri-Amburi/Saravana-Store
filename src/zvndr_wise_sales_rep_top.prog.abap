*&---------------------------------------------------------------------*
*& Include          ZVNDR_WISE_SALES_REP_TOP
*& Functional Responsible- Narendra Reddy
*& Technical Responsible- Umair
*&---------------------------------------------------------------------*
TABLES: klah, kssk, mseg , vbrp , a502 , MCH1.

TYPES: BEGIN OF ty_mseg,
         mblnr      TYPE mblnr,
         mjahr      TYPE mjahr,
         bwart      TYPE bwart,
         matnr      TYPE matnr,
         budat_mkpf TYPE budat,
         werks      TYPE werks_d,
         menge      TYPE menge_d,
         CHARG      TYPE CHARG_D,
       END OF ty_mseg.

TYPES: BEGIN OF ty_vbrp,
         matnr TYPE matnr,
         erdat TYPE erdat,
         matkl TYPE matkl,      "Category No.
         werks TYPE werks_d,
         fkimg TYPE vbrp-fkimg,      "Qty
         netwr TYPE netwr_fp,   "Value
         prsdt TYPE prsdt,       " posting date
         CHARG TYPE CHARG_D,
       END OF ty_vbrp.

TYPES: BEGIN OF ty_t001w,
         werks TYPE werks_d,
         name1 TYPE name1,
         bwkey TYPE bwkey,
         kunnr TYPE kunnr_wk,
         lifnr TYPE lifnr_wk,
       END OF ty_t001w.

TYPES: BEGIN OF ty_mara,
         matnr TYPE matnr,
         matkl TYPE matkl,
       END OF ty_mara.

TYPES: BEGIN OF TY_MCH1,
       MATNR TYPE MATNR,
       CHARG TYPE CHARG_D,
       LIFNR TYPE ELIFN,
       END OF TY_MCH1.

TYPES: BEGIN OF ty_a502,
         matnr TYPE matnr,
         lifnr TYPE elifn,  "Vendor Code
         kschl TYPE kschl,
         knumh TYPE knumh,
       END OF ty_a502.

TYPES: BEGIN OF ty_konp,
         kschl    TYPE kscha,
         loevm_ko TYPE loevm_ko,
         lifnr    TYPE lifnr,
         knumh    TYPE knumh,
       END OF ty_konp.
*
TYPES: BEGIN OF ty_klah,
       CLINT TYPE CLINT,
       KLART TYPE KLASSENART,"Class No.
       CLASS TYPE KLASSE_D, "Class Group
       VONDT TYPE VONDAT,
       BISDT TYPE BISDAT,
       WWSKZ TYPE KLAH-WWSKZ,
       END OF ty_klah.

TYPES: BEGIN OF ty_kssk,
         objek TYPE cuobn,
         klart TYPE klassenart,
         clint TYPE clint,
       END OF ty_kssk.

TYPES: BEGIN OF ty_data,
         class TYPE klah-class,
         klagr TYPE klah-klagr,
         wwskz TYPE klah-wwskz,
         objek TYPE kssk-objek,
         klart TYPE kssk-klart,
         clint TYPE klah-clint,
         matkl TYPE mara-matkl,
       END OF ty_data.


DATA : it_mseg  TYPE STANDARD TABLE OF ty_mseg,
       wa_mseg  TYPE ty_mseg,
*       it_vbrp  TYPE STANDARD TABLE OF ty_vbrp,
*       wa_vbrp  TYPE ty_vbrp,
       it_t001w TYPE STANDARD TABLE OF ty_t001w,
       wa_t001w TYPE ty_t001w,
       it_a502  TYPE STANDARD TABLE OF ty_a502,
       it_MCH1  TYPE STANDARD TABLE OF ty_MCH1,
       wa_a502  TYPE ty_a502,
       wa_MCH1  TYPE ty_MCH1,
       it_konp  TYPE STANDARD TABLE OF ty_konp,
       wa_konp  TYPE ty_konp,
       it_mara  TYPE STANDARD TABLE OF ty_mara,
       wa_mara  TYPE ty_mara,
       it_klah  TYPE STANDARD TABLE OF ty_klah,
       wa_klah  TYPE ty_klah,
       it_kssk  TYPE STANDARD TABLE OF ty_kssk,
       wa_kssk  TYPE ty_kssk,
       it_item  TYPE  TABLE OF zvndr_item,
       it_item1 TYPE  TABLE OF zvndr_item,
       it_item2 TYPE  TABLE OF zvndr_item,
       wa_item  TYPE zvndr_item,
       wa_item1 TYPE zvndr_item,
       wa_item2 TYPE zvndr_item.

DATA : lt_data TYPE TABLE OF ty_data,
       ls_data TYPE ty_data.
DATA : slno TYPE int4.
DATA : lv_group_id TYPE klah-class VALUE 'SAREE'. "*---->>> ( Data dec for Material Hierarchy ) mumair <<< 25.09.2019 11:43:22



DATA: lv_val TYPE netwr_fp,
      lv_qty TYPE fkimg.
