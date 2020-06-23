*&---------------------------------------------------------------------*
*& Report ZMM_STOCK_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*


TYPES : BEGIN OF TY_MSEG,
          MBLNR TYPE MBLNR,
          MJAHR TYPE MJAHR,
          ZEILE TYPE MBLPO,
          BWART TYPE BWART,
          MATNR TYPE MATNR,
          WERKS TYPE WERKS_D,
          LIFNR TYPE ELIFN,
        END OF TY_MSEG .

TYPES : BEGIN OF TY_MARD ,
          MATNR TYPE MATNR,
          WERKS TYPE WERKS_D,
          LGORT TYPE LGORT_D,
          LFGJA TYPE MARD-LFGJA,
          LABST TYPE MARD-LABST,
        END OF TY_MARD .

TYPES : BEGIN OF TY_MBEW ,
          MATNR TYPE MATNR,
          BWKEY TYPE BWKEY,
          BWTAR TYPE BWTAR_D,
          VERPR TYPE VERPR,
          STPRS TYPE STPRS,
        END OF TY_MBEW .

TYPES : BEGIN OF TY_LFA1 ,
          LIFNR TYPE LIFNR,
          LAND1 TYPE LAND1_GP,
          NAME1 TYPE NAME1_GP,
        END OF TY_LFA1 .


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
          LIFNR TYPE LIFNR,
          WERKS TYPE WERKS_D,
          LABST TYPE LABST,
          VALUE TYPE NETPR,
        END OF TY_FINAL .
DATA : IT_FINAL TYPE TABLE OF TY_FINAL,
       WA_FINAL TYPE TY_FINAL.
DATA : IT_MSEG   TYPE  TABLE OF TY_MSEG,
       IT_MSEG_M TYPE  TABLE OF TY_MSEG,
       WA_MSEG   TYPE TY_MSEG,
       WA_MSEG_M TYPE TY_MSEG,
       IT_MSEG1  TYPE  TABLE OF TY_MSEG,
       WA_MSEG1  TYPE TY_MSEG,
       IT_MSEG2  TYPE  TABLE OF TY_MSEG,
       WA_MSEG2  TYPE TY_MSEG,
       IT_MARA   TYPE TABLE OF TY_MARA,
       WA_MARA   TYPE TY_MARA,
       IT_MBEW   TYPE TABLE OF TY_MBEW,
       WA_MBEW   TYPE TY_MBEW,
       IT_MARD   TYPE TABLE OF TY_MARD,
       WA_MARD   TYPE TY_MARD,
       IT_LFA1   TYPE TABLE OF TY_LFA1,
       WA_LFA1   TYPE TY_LFA1,
       IT_KLAH   TYPE TABLE OF TY_KLAH,
       WA_KLAH   TYPE TY_KLAH,
       IT_KLAH1  TYPE TABLE OF TY_KLAH1,
       WA_KLAH1  TYPE TY_KLAH1,
       IT_KSSK1  TYPE TABLE OF TY_KSSK1,
       WA_KSSK1  TYPE TY_KSSK1,
       IT_KSSK   TYPE TABLE OF TY_KSSK,
       WA_KSSK   TYPE TY_KSSK.
