*&---------------------------------------------------------------------*
*& Include          ZMM_PRICE_CHANGE_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF TY_MARA ,
          MATNR          TYPE MATNR,
          MATKL          TYPE MATKL,
          ZZPO_ORDER_TXT TYPE ZPO_ORDER_TXT,
        END OF TY_MARA .



data : it_mara TYPE TABLE OF ty_mara .
