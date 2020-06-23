*&---------------------------------------------------------------------*
*& Include          ZFI_IAP_OPENITEM_C05_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_exceltab,
          bldat  TYPE char30,
          blart  TYPE char22,
          bukrs  TYPE char20,
          budat  TYPE char30,
*          monat  TYPE char20,
          waers  TYPE char20,
          kursf  TYPE char10,
          xblnr  TYPE char36,
          bktxt  TYPE char80,

          newbs  TYPE char30,
          lifnr  TYPE char80,
          wrbtr  TYPE char45,
          bupla  TYPE char30,
          secco  TYPE char30,
*          zfbdt  TYPE char40,
*          skfbt  TYPE char20,
          zterm  TYPE char20,
*          zlspr  TYPE char40,
          gsber  TYPE char30,
*          zterm  TYPE char30,
*          zfbdt  TYPE char30,
          zuonr  TYPE char80,
          sgtxt  TYPE char100,
*          prctr  TYPE char36,

          newbs1 TYPE char22,
          newko  TYPE char50,
          wrbtr1 TYPE char45,
          bupla1 TYPE char30,
          zuonr1 TYPE char80,
          gsber1 TYPE char30,
          sgtxt1 TYPE char100,
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
