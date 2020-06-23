*&---------------------------------------------------------------------*
*& Include          ZFI_CUSTOMER_DOWNPAYMENT_TOP
*&---------------------------------------------------------------------*


TYPES : BEGIN OF ty_exceltab,
          bldat  TYPE char30,       "DOCUMENT DATE
          blart  TYPE char22,        "DOCUMENT TYPE
          bukrs  TYPE char20,       "COMPANY CODE
          budat  TYPE char30,       "POSTING DATE
*          monat  TYPE char20,
          waers  TYPE char20,       "CURRENCY
          kursf  TYPE char10,       "EXCHANGE RATE
          xblnr  TYPE char36,       "REFERENCE DOC.NO
          bktxt  TYPE char80,       "HEADER TEXT

          newbs  TYPE char30,       "POSTING KEY
          kunnr  TYPE char80,       "CUSTOMER NO
          wrbtr  TYPE char45,       "AMOUNT IN DOCUMENT
          bupla  TYPE char30,
          secco  TYPE char30,
          gsber  TYPE char30,       "BUSSINESS AREA
*          zterm  TYPE char30,
          zfbdt  TYPE char30,
          zuonr  TYPE char80,       "ASSIGNMENT NO
          sgtxt  TYPE char100,      "ITEM TEXT
*          prctr  TYPE char36,

          newbs1 TYPE char22,        "POSTING KEY
          newko  TYPE char50,        "ACCOUNT
          wrbtr1 TYPE char45,        "AMOUNT
          bupla1 TYPE char30,        "BUSSINESS PLACE
          zuonr1 TYPE char80,        "ASSIGNMENT NO
          gsber1 TYPE char30,        "BUSSINESS AREA
          sgtxt1 TYPE char100,       "ITEM TEXT
        END OF ty_exceltab,
        ty_t_exceltab TYPE STANDARD TABLE OF ty_exceltab.

TYPES : BEGIN OF ty_errmsg,
          sno    TYPE i,
          msgtyp TYPE bapi_mtype,
          xblnr  TYPE xblnr,
          bktxt  TYPE bktxt,
          messg  TYPE bapi_msg,
          docnum TYPE string,
        END OF ty_errmsg,
        ty_t_errmsg TYPE STANDARD TABLE OF ty_errmsg.

TYPES : ty_t_msg  TYPE STANDARD TABLE OF bapiret2.

DATA : wa_exceltab TYPE ty_exceltab,
       i_exceltab  TYPE ty_t_exceltab.

DATA : fname TYPE localfile,
       ename TYPE char4.

DATA : wa_errmsg      TYPE ty_errmsg,
       wa_msg         TYPE bapiret2,
       i_errmsg       TYPE ty_t_errmsg,
       i_msgt         TYPE ty_t_msg,
       i_fieldcatalog TYPE slis_t_fieldcat_alv.
