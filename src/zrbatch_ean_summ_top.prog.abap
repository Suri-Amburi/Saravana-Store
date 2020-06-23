*&---------------------------------------------------------------------*
*& Include          ZRBATCH_EAN_SUMM_TOP
*&---------------------------------------------------------------------*
*TABLES : ZSCAN_BATCHES,MARA.
TYPE-POOLS : slis.
TYPES : BEGIN OF TY_ZSCAN_BATCHES,
          SNO        TYPE ZSL_NO,
          SCAN_BATCH TYPE ZSCAN_BATCH,
          PLANT      TYPE WERKS_D,
          CREATEDON  TYPE ERDAT,
        END OF TY_ZSCAN_BATCHES,

        BEGIN OF TY_PLANT,
          WERKS TYPE WERKS_D,
          END OF TY_PLANT,

        BEGIN OF TY_BATCHES,
          BATCH  TYPE CHARG_D,
          BATCH1 TYPE ZSCAN_BATCH,
          batch18 TYPE EAN11,
          PLANT      TYPE WERKS_D,
          CREATEDON  TYPE ERDAT,
          QTY        TYPE MENGE_D,
*          batch TYPE CHARG_D,
        END OF TY_BATCHES,

        BEGIN OF TY_MCHP,
          MATNR TYPE   MATNR,
          CHARG TYPE   CHARG_D,
          EBRID TYPE EBRID,
          WERKS TYPE WERKS_D,
        END OF TY_MCHP,

        BEGIN OF TY_MARA,
          MATNR TYPE MATNR,
          ERSDA TYPE   ERSDA,
          MTART TYPE MTART,
          MATKL TYPE MATKL,
          MEINS TYPE MEINS,
          EAN11 TYPE EAN11,
        END OF TY_MARA,

        BEGIN OF TY_T023T,
          SPRAS TYPE SPRAS,
          MATKL TYPE MATKL,
          WGBEZ TYPE WGBEZ,
        END OF TY_T023T,

        BEGIN OF TY_T023T_1 ,
          MATKL TYPE KLASSE_D,
        END OF TY_T023T_1,

        BEGIN OF TY_MAKT,
          MATNR TYPE MATNR,
          SPRAS TYPE SPRAS,
          MAKTX TYPE MAKTX,
        END OF TY_MAKT,

        BEGIN OF TY_T003T,
          SPRAS  TYPE SPRAS,
          BLART  TYPE BLART,
          LTEXTT TYPE LTEXT_003T,
        END OF TY_T003T,

        BEGIN OF TY_KLAH,
          CLINT TYPE KLAH-CLINT,
          KLART TYPE KLASSENART,
          CLASS TYPE KLASSE_D,
*           class TYPE matkl,
        END OF TY_KLAH,

*        BEGIN OF
        BEGIN OF TY_KLAH2,
          CLINT TYPE CLINT,
          KLART TYPE KLASSENART,
          CLASS TYPE KLASSE_D,
*           class TYPE matkl,
        END OF TY_KLAH2,


        BEGIN OF TY_KSSK,
          OBJEK TYPE CUOBN,
          MAFID TYPE KLMAF,
          KLART TYPE KLASSENART,
          CLINT TYPE CLINT,
        END OF TY_KSSK,

        BEGIN OF TY_KSSK1 ,
*          OBJEK  TYPE CLINT,
          OBJEK TYPE CUOBN,
*          OBJEK1 TYPE KSSK-OBJEK,
        END OF TY_KSSK1 ,

        BEGIN OF TY_A406,
          KAPPL TYPE KAPPL,
          KSCHL TYPE KSCHA,
          WERKS TYPE WERKS_D,
          MATNR TYPE MATNR,
          KNUMH TYPE KNUMH,
        END OF TY_A406,

        BEGIN OF TY_KONP,
          KNUMH TYPE KNUMH,
          KOPOS TYPE  KOPOS,
          KBETR TYPE KBETR_KOND,
        END OF TY_KONP,

        BEGIN OF TY_FINAL,
          BATCH TYPE ZSCAN_BATCH,
          SNO        TYPE ZSL_NO,
          MATERIAL TYPE MATNR,
          MAT_DESC TYPE MAKTX,
          CATEGORY TYPE WGBEZ,
          MATKL_L  TYPE KLASSE_D,
          OBJ_L TYPE CUOBN,
          GROUP TYPE KLASSE_D,
          UOM   TYPE MEINS,
          PRICE TYPE KBETR_KOND,
          QTY  TYPE MENGE_D,
          END OF TY_FINAL.


DATA : IT_ZSCAN_BATCHES TYPE TABLE OF TY_ZSCAN_BATCHES,
       WA_ZSCAN_BATCHES TYPE TY_ZSCAN_BATCHES,

       IT_PLANT TYPE TABLE OF TY_PLANT,
       WA_PLANT TYPE TY_PLANT,

       IT_BATCHES       TYPE TABLE OF TY_BATCHES,
       WA_BATCHES       TYPE TY_BATCHES,

       IT_MCHP          TYPE TABLE OF TY_MCHP,
       WA_MCHP          TYPE TY_MCHP,

       IT_MARA          TYPE TABLE OF TY_MARA,
       WA_MARA          TYPE TY_MARA,

       IT_MAKT          TYPE TABLE OF TY_MAKT,
       WA_MAKT          TYPE TY_MAKT,

       IT_T023T         TYPE TABLE OF TY_T023T,
       WA_T023T         TYPE TY_T023T,

       IT_T023T_1       TYPE  TABLE OF TY_T023T_1,
       WA_T023T_1       TYPE TY_T023T_1,

       IT_T023T_2       TYPE  TABLE OF TY_T023T_1,
       WA_T023T_2       TYPE TY_T023T_1,

       IT_T003T         TYPE TABLE OF TY_T003T,
       WA_T003T         TYPE TY_T003T,

       IT_A406          TYPE TABLE OF TY_A406,
       WA_A406          TYPE TY_A406,

       IT_KONP          TYPE TABLE OF TY_KONP,
       WA_KONP          TYPE TY_KONP,

       IT_KLAH          TYPE TABLE OF TY_KLAH,
       WA_KLAH          TYPE TY_KLAH,

       IT_KLAH2         TYPE TABLE OF TY_KLAH,
       WA_KLAH2         TYPE TY_KLAH,

       IT_KSSK          TYPE TABLE OF TY_KSSK,
       WA_KSSK          TYPE TY_KSSK,

       IT_KSSK1         TYPE TABLE OF TY_KSSK1,
       WA_KSSK1         TYPE  TY_KSSK1,

       IT_FINAL TYPE TABLE OF TY_FINAL,
       WA_FINAL TYPE TY_FINAL,

       IT_FINAL2 TYPE TABLE OF TY_FINAL,
       WA_FINAL2 TYPE TY_FINAL.



DATA : G_ID TYPE VRM_ID,
       IT_VALUES TYPE VRM_VALUES,
       WA_VALUES LIKE LINE OF IT_VALUES.




DATA GV_PLANT       TYPE WERKS_D.
DATA :  LV_DATE TYPE ERDAT .
