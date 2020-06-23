*&---------------------------------------------------------------------*
*& Include          ZSALFORMD_TOP
*&---------------------------------------------------------------------*

TABLES: PA0001,PERNR.
TYPE-POOLS: SLIS.
TYPES: BEGIN OF TY_PA0001,
         PERNR TYPE PA0001-PERNR,
         PERSG TYPE PA0001-PERSG,
       END OF TY_PA0001.

TYPES: BEGIN OF TY_FINAL,
         SL        TYPE I,                   " Serial Number
         PERNR     TYPE PA0001-PERNR,
         PERSG     TYPE PA0001-PERSG,
         BLANK(10) TYPE C,
         PTEXT     TYPE T501T-PTEXT,
         COUNT     TYPE SY-TABIX,
       END OF TY_FINAL,

        BEGIN OF TY_T501T,
          PERSG TYPE T501T-PERSG,
          PTEXT TYPE T501T-PTEXT,
        END OF TY_T501T.

DATA: IT_PA0001 TYPE TABLE OF TY_PA0001,
      WA_PA0001 TYPE  TY_PA0001,
      IT_T501T  TYPE TABLE OF TY_T501T,
      WA_T501T  TYPE TY_T501T,
      WA_FINAL  TYPE TY_FINAL,
      IT_FINAL  TYPE TABLE OF TY_FINAL,
      WA_FCAT   TYPE SLIS_FIELDCAT_ALV,
      IT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
      WA_LAYOUT TYPE SLIS_LAYOUT_ALV,
      T_HEADER  TYPE SLIS_T_LISTHEADER,
      WA_HEADER TYPE SLIS_LISTHEADER,
      SL        TYPE I,
      BLANK(10) TYPE C,
      LV_DATE   TYPE  PA0001-BEGDA,
      COUNT     TYPE SY-TABIX,
      WA_ITEM   TYPE ZSAL_FORMP_STR,
      IT_ITEM   TYPE ZSAL_FORMP_STR_TT.
