*&---------------------------------------------------------------------*
*& Include          ZMM_CATEGORY_AGE_TOP
*&---------------------------------------------------------------------*


TYPES : BEGIN OF TY_KLAH ,
          CLINT TYPE CLINT,
          KLART TYPE KLASSENART,
          CLASS TYPE KLASSE_D,
          VONDT TYPE VONDAT,
          BISDT TYPE BISDAT,
          WWSKZ TYPE KLAH-WWSKZ,
        END OF TY_KLAH .

TYPES : BEGIN OF TY_KLAH1 ,
          CLINT TYPE CLINT,
          KLART TYPE KLASSENART,
          CLASS TYPE MATKL,
          VONDT TYPE VONDAT,
          BISDT TYPE BISDAT,
          WWSKZ TYPE KLAH-WWSKZ,
        END OF TY_KLAH1 .

TYPES : BEGIN OF TY_KSSK ,
          OBJEK TYPE CUOBN,
          MAFID TYPE KLMAF,
          KLART TYPE KLASSENART,
          CLINT TYPE CLINT,
          ADZHL TYPE ADZHL,
          DATUB TYPE DATUB,
        END OF TY_KSSK .

TYPES : BEGIN OF TY_KSSK1 ,
          OBJEK TYPE CLINT,
*          MAFID type KLMAF,
*          KLART type KLASSENART,
*          CLINT type CLINT,
*          ADZHL type ADZHL,
*          DATUB type DATUB,
        END OF TY_KSSK1 .

TYPES : BEGIN OF TY_MARA,
          MATNR TYPE MATNR,
          MATKL TYPE MATKL,
        END OF TY_MARA .

TYPES : BEGIN OF TY_FINAL,
          SL_NO(5)  TYPE I,
          MONTH(10) TYPE C,
          QTY       TYPE LABST,
          AMOUNT    TYPE NETPR,
          BWTAR     TYPE BWTAR_D,
        END OF TY_FINAL.


TYPES : BEGIN OF TY_FINAL1 ,
          SL_NO(5) TYPE I,
          LIFNR    TYPE ELIFN,
          MATNR    TYPE MATNR,
          MAKTX    TYPE MAKTX,
          MATKL    TYPE MATKL,
          WGBEZ    TYPE WGBEZ,
          QTY      TYPE LABST,
          AMOUNT   TYPE NETPR,
          MONTH    TYPE  C,
          BWTAR    TYPE BWTAR_D,
          CHARG    TYPE CHARG_D,
          name1    type NAME1_GP ,
          ERSDA    TYPE ERSDA ,
        END OF TY_FINAL1 .

TYPES : BEGIN OF TY_T001W ,
          NAME1 TYPE NAME1,
        END OF TY_T001W .

TYPES : BEGIN OF TY_LFA1 ,
          LIFNR TYPE LIFNR,
          NAME1 TYPE NAME1_GP,
        END OF TY_LFA1 .
        types : BEGIN OF ty_mcha ,
          CHARG type CHARG_D,
          ERSDA type ERSDA,
          END OF ty_mcha .

DATA : IT_T001W TYPE TABLE OF TY_T001W,
       WA_T001W TYPE  TY_T001W,
       IT_LFA1  TYPE TABLE OF TY_LFA1,
       IT_mcha TYPE TABLE OF TY_mcha,
       WA_LFA1  TYPE TY_LFA1.
DATA : IT_KLAH   TYPE TABLE OF TY_KLAH,
       WA_KLAH   TYPE TY_KLAH,
       IT_KLAH1  TYPE TABLE OF TY_KLAH1,
       WA_KLAH1  TYPE TY_KLAH1,
       IT_KSSK1  TYPE TABLE OF TY_KSSK1,
       WA_KSSK1  TYPE TY_KSSK1,
       IT_KSSK   TYPE TABLE OF TY_KSSK,
       WA_KSSK   TYPE TY_KSSK,
       IT_MARA   TYPE TABLE OF TY_MARA,
       WA_MARA   TYPE TY_MARA,
       IT_FINAL  TYPE TABLE OF TY_FINAL,
       IT_FINAL1 TYPE TABLE OF TY_FINAL1,
       WA_FINAL1 TYPE TY_FINAL1,
       WA_FINAL  TYPE TY_FINAL.
DATA :  LV_WERKS TYPE WERKS_D.
DATA :  LV_KLASSE_D TYPE KLASSE_D.
