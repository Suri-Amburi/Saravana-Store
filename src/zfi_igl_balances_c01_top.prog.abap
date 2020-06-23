*&---------------------------------------------------------------------*
*& Include          ZFI_IGL_BALANCES_C01_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_exceltab,
          desc     TYPE char30,    "Description
          bldat    TYPE char30,    "Document Date
          budat    TYPE char30,    "Posting Date
          blart    TYPE char20,    "Document Type
          bukrs    TYPE char20,    "Company Code
          waers    TYPE char20,    "Currency
          kursf    TYPE char10,    "Exchange Rate
          xblnr    TYPE char36,    "Ref Document Number
          bktxt    TYPE char50,    "Document Header text
          newbs    TYPE char30,    "posting Key for next line item
          newko    TYPE char50,    "General Ledger Account
          wrbtr    TYPE char35,    "Amount in Doc Currency
          gsber    TYPE GSBER,     "Bussiness Area
          werks    TYPE char20,    "Plant
          kostl    TYPE char20,    "Cost Center
          aufnr    TYPE char30,    "Order Number
          prctr    TYPE char20,    "profit center
          zuonr    TYPE char27,    "Assignment number
          valdate  TYPE char20,    "value date
          sgtxt    TYPE SGTXT,     "Item text
          newbs2   TYPE char30,    "Postingkey for thenext line item
          newko2   TYPE char50,    "GL account
          wrbtr2   TYPE char35,    "Amount in doc currency
          gsber2    TYPE GSBER,     "Bussiness Area
          werks2   TYPE char20,    "Plant
          kostl2   TYPE char20,    "cost center
*          aufnr2 TYPE char30,
          prctr2   TYPE char20,    "Profit center
          zuonr2   TYPE char27,    "assignment number
          valdate2 TYPE char20,    "value date
          sgtxt2   TYPE SGTXT,     "Item text2
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

TYPES : ty_t_item TYPE STANDARD TABLE OF bapiacgl08,
        ty_t_curr TYPE STANDARD TABLE OF bapiaccr08,
        ty_t_msg  TYPE STANDARD TABLE OF bapiret2.

DATA : wa_exceltab TYPE ty_exceltab,
       i_exceltab  TYPE ty_t_exceltab.

DATA : fname TYPE localfile,
       ename TYPE char4.

DATA : wa_header      TYPE bapiache08,
       wa_item        TYPE bapiacgl08,
       wa_curr        TYPE bapiaccr08,
       wa_errmsg      TYPE ty_errmsg,
       wa_msg         TYPE bapiret2,
       i_curr         TYPE ty_t_curr,
       i_item         TYPE ty_t_item,
       i_errmsg       TYPE ty_t_errmsg,
       i_msgt         TYPE ty_t_msg,
       i_fieldcatalog TYPE slis_t_fieldcat_alv.
