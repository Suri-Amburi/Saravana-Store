*&---------------------------------------------------------------------*
*& Include          ZMM_GRPO_STORES_TOP
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
          OBJEK  TYPE CLINT,
          OBJEK1 TYPE KSSK-OBJEK,
        END OF TY_KSSK1 .

TYPES : BEGIN OF TY_MARA,
          MATNR TYPE MATNR,
          MATKL TYPE MATKL,
        END OF TY_MARA .

TYPES : BEGIN OF TY_ZINW_HDR ,
          QR_CODE	   TYPE ZQR_CODE,
          INWD_DOC   TYPE ZINWD_DOC,
          EBELN	     TYPE EBELN,
          LIFNR	     TYPE ELIFN,
          BILL_DATE	 TYPE ZBILL_DAT,
          ERDATE     TYPE ERDAT,
          ACT_NO_BUD TYPE ZNO_BUD,
        END OF TY_ZINW_HDR .

DATA : IT_KLAH    TYPE TABLE OF TY_KLAH,
       WA_KLAH    TYPE TY_KLAH,
       IT_KLAHA   TYPE TABLE OF TY_KLAH,
       WA_KLAHA   TYPE TY_KLAH,
       IT_KLAH1   TYPE TABLE OF TY_KLAH1,
       WA_KLAH1   TYPE TY_KLAH1,
       IT_KSSK1   TYPE TABLE OF TY_KSSK1,
       WA_KSSK1   TYPE TY_KSSK1,
       IT_KSSK    TYPE TABLE OF TY_KSSK,
       WA_KSSK    TYPE TY_KSSK,
       IT_MARA    TYPE TABLE OF TY_MARA,
       WA_MARA    TYPE TY_MARA,
       IT_INW_HDR TYPE TABLE OF TY_ZINW_HDR,
       WA_INW_HDR TYPE TY_ZINW_HDR.
*******************************Final Screen1****************************
TYPES : BEGIN OF TY_FINAL ,
          CATEGORY(20) TYPE C,
          WERKS        TYPE T001W-WERKS,
          GRPO_V       TYPE NETPR,
          GRPO_WT      TYPE NETPR,
          BUNDLE(10)   TYPE I,
          QTY          TYPE MENGE_D,
          LIFNR        TYPE LIFNR,
          NAME1        TYPE NAME1,
          GRPO         TYPE ZINWD_DOC,
          GRPO_N(5)    TYPE I,
          BLDAT        TYPE MKPF-BLDAT,
          MATNR        TYPE ZINW_T_ITEM-MATNR,
          QR_CODE      TYPE ZINW_T_ITEM-QR_CODE,
          GATE_ENTRY   TYPE ZINW_T_STATUS-CREATED_DATE,
        END OF TY_FINAL .

DATA : IT_FINAL TYPE TABLE OF TY_FINAL,
       WA_FINAL TYPE TY_FINAL.
DATA : IT_FINAL1 TYPE TABLE OF TY_FINAL,
       WA_FINAL1 TYPE TY_FINAL.
DATA : IT_FINAL2 TYPE TABLE OF TY_FINAL,
       IT_FINAL3 TYPE TABLE OF TY_FINAL,
       it_final4 TYPE TABLE OF ty_final,
       wa_final4 TYPE ty_final,
       IT_BUN    TYPE TABLE OF TY_FINAL,
       WA_FINAL2 TYPE TY_FINAL,
       WA_FINAL3 TYPE TY_FINAL.
*************************************************************************



DATA :  LV_WERKS TYPE WERKS_D.
DATA :  LV_DATE TYPE ERDAT .
