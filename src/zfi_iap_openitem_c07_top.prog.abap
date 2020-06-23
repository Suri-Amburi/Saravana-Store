*&---------------------------------------------------------------------*
*& Include          ZFI_IAP_OPENITEM_C07_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_exceltab,
          bldat  TYPE char30,   "Document Date
          blart  TYPE char22,   "Document Type
          bukrs  TYPE BUKRS,    "char20,   "Company Code
          budat  TYPE char30,   "Postng date
*          monat  TYPE char20,   "urrency
          waers  TYPE char20,    "Currency
          kursf  TYPE char10,    "Exc.rate
          xblnr  TYPE char36,     "ref doc
          bktxt  TYPE char25,     "Header text

          newbs  TYPE char30,    "Posting key
          lifnr  TYPE LIFNR,      "char80,    "Vendor Num
          wrbtr  TYPE char45,    "Amount in doc currency
          bupla  TYPE char30,    "bussiness place
          secco  TYPE char30,    "Section code
*          zfbdt  TYPE char40,
*          skfbt  TYPE char20,
          zterm  TYPE char20,    "Payment terms
*          zlspr  TYPE char40,
          gsber  TYPE char30,    "Bussines area
*          zterm  TYPE char30,
*          zfbdt  TYPE char30,
          zuonr  TYPE char80,    "Assignment number
          sgtxt  TYPE char100,   "Item text
*          prctr  TYPE char36,

          newbs1 TYPE char22,    "Postin key
          newko  TYPE char50,    "Gl Account
          wrbtr1 TYPE char45,    "Amount indoc currency
          bupla1 TYPE char30,    "business place
          zuonr1 TYPE char80,    "Assignment
          gsber1 TYPE char30,    "Bussiness area
          VALUT  TYPE CHAR10,     "VALUE DATE
          sgtxt1 TYPE char100,   "Item text
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

DATA: w_bdcdata TYPE bdcdata,
      i_bdcdata TYPE STANDARD TABLE OF bdcdata.

DATA: lv_n      TYPE char1 VALUE 'N',
      lv_a      TYPE char1 VALUE 'A',
      i_bdcmess LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
