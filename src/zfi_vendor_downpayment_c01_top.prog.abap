*&---------------------------------------------------------------------*
*& Include          ZFI_VENDOR_DOWNPAYMENT_C01_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF TY_EXCELTAB,
          BLDAT  TYPE CHAR30,
          BLART  TYPE CHAR22,
          BUKRS  TYPE CHAR20,
          BUDAT  TYPE CHAR30,
*          monat  TYPE char20,
          WAERS  TYPE CHAR20,
          KURSF  TYPE CHAR10,
          XBLNR  TYPE CHAR36,
          BKTXT  TYPE CHAR80,

          NEWBS  TYPE CHAR30,
          LIFNR  TYPE CHAR80,
          UMSKZ  TYPE CHAR01,
          WRBTR  TYPE CHAR45,
          BUPLA  TYPE CHAR30,
          SECCO  TYPE CHAR30,
          ZFBDT  TYPE CHAR40,
          ZLSPR  TYPE CHAR40,
          GSBER  TYPE CHAR30,
*          zterm  TYPE char30,
*          zfbdt  TYPE char30,
          ZUONR  TYPE CHAR80,
          SGTXT  TYPE CHAR100,
*          prctr  TYPE char36,

          NEWBS1 TYPE CHAR22,
          NEWKO  TYPE CHAR50,
          WRBTR1 TYPE CHAR45,
          BUPLA1 TYPE CHAR30,
          ZUONR1 TYPE CHAR80,
          GSBER1 TYPE CHAR30,
          SGTXT1 TYPE CHAR100,
        END OF TY_EXCELTAB,
        TY_T_EXCELTAB TYPE STANDARD TABLE OF TY_EXCELTAB.

TYPES : BEGIN OF TY_ERRMSG,
          SNO    TYPE I,
          MSGTYP TYPE BAPI_MTYPE,
          XBLNR  TYPE XBLNR,
          BKTXT  TYPE BKTXT,
          MESSG  TYPE BAPI_MSG,
          DOCNUM TYPE STRING,
        END OF TY_ERRMSG,
        TY_T_ERRMSG TYPE STANDARD TABLE OF TY_ERRMSG.

TYPES : TY_T_MSG  TYPE STANDARD TABLE OF BAPIRET2.

DATA : WA_EXCELTAB TYPE TY_EXCELTAB,
       I_EXCELTAB  TYPE TY_T_EXCELTAB.

DATA : FNAME TYPE LOCALFILE,
       ENAME TYPE CHAR4.

DATA : WA_ERRMSG      TYPE TY_ERRMSG,
       WA_MSG         TYPE BAPIRET2,
       I_ERRMSG       TYPE TY_T_ERRMSG,
       I_MSGT         TYPE TY_T_MSG,
       I_FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV.
