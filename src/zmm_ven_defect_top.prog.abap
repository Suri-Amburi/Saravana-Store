*&---------------------------------------------------------------------*
*& Include          ZMM_VEN_DEFECT_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF TY_EKKO,
          EBELN TYPE EBELN,
          BSART TYPE ESART,
          AEDAT TYPE ERDAT,
          LIFNR TYPE ELIFN,
        END OF TY_EKKO .

TYPES : BEGIN OF TY_EKPO ,
          EBELN TYPE EBELN,
          EBELP TYPE EBELP,
          MATNR TYPE MATNR,
          MENGE TYPE BSTMG,
          NETWR TYPE BWERT,
          NETPR TYPE BPREI,
        END OF TY_EKPO .

TYPES : BEGIN OF TY_EKET ,
          EBELN TYPE EBELN,
          EBELP TYPE EBELP,
          EINDT TYPE EINDT,
        END OF TY_EKET .

TYPES : BEGIN OF TY_MAKT ,
          MATNR TYPE MATNR,
          SPRAS TYPE SPRAS,
          MAKTX TYPE MAKTX,
        END OF TY_MAKT .

TYPES : BEGIN OF TY_ZINW_T_ITEM ,
          QR_CODE TYPE ZQR_CODE,
          EBELN   TYPE EBELN,
          EBELP   TYPE EBELP,
          MATNR   TYPE MATNR,
          MENGE_P TYPE ZMENGE_P,
          NETWR_P TYPE ZBPREI_PT,

        END OF  TY_ZINW_T_ITEM .



TYPES : BEGIN OF TY_DATA ,
          EBELN TYPE EKKO-EBELN,
          LIFNR TYPE EKKO-LIFNR,
          AEDAT TYPE EKKO-AEDAT,
          EBELP TYPE EKPO-EBELP,
          MATNR TYPE EKPO-MATNR,
          MENGE TYPE EKPO-MENGE,
          NETWR TYPE EKPO-NETWR,
          MATKL TYPE EKPO-MATKL,
          EINDT TYPE EKET-EINDT,
          MAKTX TYPE MAKTX,
*          NETWR_P TYPE ZBPREI_PT,
        END OF TY_DATA .

TYPES : BEGIN OF TY_FINAL ,
          EBELN      TYPE EKKO-EBELN,
          AEDAT      TYPE EKKO-AEDAT,
          LIFNR      TYPE EKKO-LIFNR,
          EINDT      TYPE EKET-EINDT,
          MENGE      TYPE EKPO-MENGE,
          NETWR      TYPE EKPO-NETWR,
          NETPR      TYPE EKPO-NETPR,
          MATKL      TYPE EKPO-MATKL,
          MENGE_P    TYPE BSTMG,
          NETWR_P    TYPE ZBPREI_PT,
          MENGE_D    TYPE BSTMG,
          NAME       TYPE LFA1-NAME1,
          CITY       TYPE LFA1-ORT01,
          MATNR      TYPE EKPO-MATNR,
          MAKTX      TYPE MAKT-MAKTX,
          GROUP      TYPE WWGHA,
          GOOD       TYPE BSTMG,
          BAD        TYPE BSTMG,
          GB(04)     TYPE C,
          CELLCOLORS TYPE LVC_T_SCOL,
        END OF TY_FINAL .

DATA : IT_EKKO        TYPE TABLE OF TY_EKKO,
       WA_EKKO        TYPE TY_EKKO,
       IT_EKPO        TYPE TABLE OF TY_EKPO,
       WA_EKPO        TYPE TY_EKPO,
       IT_EKET        TYPE TABLE OF TY_EKET,
       WA_EKET        TYPE TY_EKET,
       IT_MAKT        TYPE TABLE OF TY_MAKT,
       WA_MAKT        TYPE TY_MAKT,
       IT_ZINW_T_ITEM TYPE TABLE OF TY_ZINW_T_ITEM,
       WA_ZINW_T_ITEM TYPE TY_ZINW_T_ITEM,
       IT_DATA        TYPE TABLE OF TY_DATA,
       IT_FINAL       TYPE TABLE OF TY_FINAL,
       IT_FINAL1      TYPE TABLE OF TY_FINAL,
       WA_FINAL       TYPE  TY_FINAL,
       WA_FINAL1      TYPE  TY_FINAL.
DATA : LV_BUDAT       TYPE  ERDAT .
DATA : LV_MENGE TYPE BSTMG .
DATA : LV_MENGE1 TYPE BSTMG .

DATA: IT_O_WGH01 TYPE TABLE OF WGH01,
      WA_O_WGH01 TYPE WGH01.


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
DATA : IT_KLAH  TYPE TABLE OF TY_KLAH,
       WA_KLAH  TYPE TY_KLAH,
       IT_KLAH1 TYPE TABLE OF TY_KLAH1,
       WA_KLAH1 TYPE TY_KLAH1,
       IT_KSSK1 TYPE TABLE OF TY_KSSK1,
       WA_KSSK1 TYPE TY_KSSK1,
       IT_KSSK  TYPE TABLE OF TY_KSSK,
       WA_KSSK  TYPE TY_KSSK.
