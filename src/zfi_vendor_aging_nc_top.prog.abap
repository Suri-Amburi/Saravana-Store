*&---------------------------------------------------------------------*
*& Include          ZFI_VENDOR_AGING_NC_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZFI_VENDOR_AGING_NC_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.
TABLES: BSIK.
DATA : DAYS TYPE I.


TYPES : BEGIN OF TY_BSIK,
          BUKRS TYPE BUKRS,
          LIFNR	TYPE LIFNR,
          UMSKS	TYPE UMSKS,
          UMSKZ	TYPE UMSKZ,
          AUGDT TYPE AUGDT,
          AUGBL	TYPE AUGBL,
          ZUONR	TYPE DZUONR,
          GJAHR	TYPE GJAHR,
          BELNR	TYPE BELNR_D,
          BUZEI	TYPE BUZEI,
          BUDAT	TYPE BUDAT,
          BLDAT	TYPE BLDAT,
          BLART	TYPE BLART,
          SHKZG	TYPE SHKZG,
          DMBTR TYPE DMBTR,
*        EBELN TYPE EBELN,
          HKONT TYPE HKONT,
          ZFBDT TYPE DZFBDT,
          ZBD1T	TYPE I,
          ZBD2T	TYPE DZBD2T,
          ZBD3T	TYPE DZBD3T,
*        ZTERM TYPE DZTERM,
*        NETDT TYPE NETDT,
          XBLNR TYPE BSIK-XBLNR,
          ZTERM TYPE BSIK-ZTERM,
          GSBER TYPE BSIK-GSBER,
          SGTXT TYPE BSIK-SGTXT,
        END OF TY_BSIK,
        TY_T_BSIK TYPE STANDARD TABLE OF TY_BSIK,

        BEGIN OF TY_LFA1,
          LIFNR	TYPE LIFNR,
          NAME1	TYPE NAME1_GP,
          ORT01 TYPE LFA1-ORT01,
          REGIO TYPE LFA1-REGIO,
          LAND1 TYPE  LAND1_GP,                 "Country Key
        END OF TY_LFA1,
        TY_T_LFA1 TYPE STANDARD TABLE OF TY_LFA1,

        BEGIN OF TY_T005T,
          LAND1	  TYPE LAND1_GP,                         "Country Key
          SPRAS	  TYPE SPRAS,	                          "Language Key
          LANDX50 TYPE LANDX50,	                            "Country Name (Max. 50 Characters)
        END OF TY_T005T,
        TY_T_T005T TYPE STANDARD TABLE OF TY_T005T,

        BEGIN OF TY_LFB1,
          LIFNR	TYPE LIFNR,
          BUKRS TYPE LFB1-BUKRS,
          AKONT TYPE LFB1-AKONT,
        END OF TY_LFB1,
        TY_T_LFB1 TYPE STANDARD TABLE OF TY_LFB1,

        BEGIN OF TY_KNVV,
          KUNNR	TYPE KNVV-KUNNR,
          SPART TYPE KNVV-SPART, ""Division
          VKGRP TYPE KNVV-VKGRP, """"SALES GRP
          VKBUR TYPE KNVV-VKBUR, """"SALES OFF
          KDGRP TYPE KNVV-KDGRP, ""customer grp
        END OF TY_KNVV,
        TY_T_KNVV TYPE STANDARD TABLE OF TY_KNVV,
        ""begin of changes by naveen 22.02.2018
        BEGIN OF TY_KNVP,
          KUNNR	TYPE KNVP-KUNNR,
          PARVW TYPE KNVP-PARVW, ""Partner Function
          KUNN2 TYPE KNVP-KUNN2, """"Customer
        END OF TY_KNVP,
        TY_T_KNVP TYPE STANDARD TABLE OF TY_KNVP,

        BEGIN OF TY_VBRK,
          VBELN TYPE VBRK-VBELN,
          SPART TYPE VBRK-SPART,
          KDGRP TYPE VBRK-KDGRP,
        END OF TY_VBRK,
        TY_T_VBRK TYPE STANDARD TABLE OF TY_VBRK,
        ""begin of changes by naveen 22.02.2018
        BEGIN OF TY_EKKO,
          EBELN TYPE EBELN,
          BEDAT TYPE EBDAT,
        END OF TY_EKKO,
        TY_T_EKKO TYPE STANDARD TABLE OF TY_EKKO,

        BEGIN OF TY_BSEG ,
          BUKRS TYPE BUKRS,
          BELNR TYPE BELNR_D,
          GJAHR TYPE GJAHR,
          SHKZG TYPE BSEG-SHKZG,
          NETDT TYPE BSEG-NETDT,
          ZFBDT TYPE DZFBDT,
          KOART TYPE BSEG-KOART,
        END OF TY_BSEG,
        TY_T_BSEG TYPE STANDARD TABLE OF TY_BSEG,

        BEGIN OF TY_BSAK,
          BUKRS TYPE BUKRS,
          LIFNR	TYPE LIFNR,
          UMSKS	TYPE UMSKS,
          UMSKZ	TYPE UMSKZ,
          AUGDT TYPE AUGDT,
          AUGBL	TYPE AUGBL,
          ZUONR	TYPE DZUONR,
          GJAHR	TYPE GJAHR,
          BELNR	TYPE BELNR_D,
          BUZEI	TYPE BUZEI,
          BUDAT	TYPE BUDAT,
          BLDAT	TYPE BLDAT,
          BLART	TYPE BLART,
          SHKZG	TYPE SHKZG,
          DMBTR TYPE DMBTR,
*        EBELN TYPE EBELN,
          HKONT TYPE HKONT,
          ZFBDT TYPE DZFBDT,
          ZBD1T	TYPE I,
          ZBD2T	TYPE DZBD2T,
          ZBD3T	TYPE DZBD3T,
*        ZTERM TYPE DZTERM,
*        NETDT TYPE NETDT,
          XBLNR TYPE BSIK-XBLNR,
          ZTERM TYPE BSIK-ZTERM,
          GSBER TYPE BSIK-GSBER,
          SGTXT TYPE BSIK-SGTXT,
        END OF TY_BSAK,
        TY_T_BSAK TYPE STANDARD TABLE OF TY_BSAK,

        BEGIN OF TY_BKPF ,
          BUKRS TYPE BUKRS,
          BELNR TYPE BELNR_D,
          GJAHR TYPE GJAHR,
          AWKEY TYPE AWKEY,
        END OF TY_BKPF ,
        TY_T_BKPF TYPE STANDARD TABLE OF TY_BKPF,

        BEGIN OF TY_BKPF1,
          BUKRS	TYPE BUKRS,
          BELNR	TYPE BELNR_D,
          GJAHR	TYPE GJAHR,
          BLART	TYPE BLART,
          BLDAT	TYPE BLDAT,
          BUDAT	TYPE BUDAT,
        END OF TY_BKPF1,
        TY_T_BKPF1 TYPE STANDARD TABLE OF TY_BKPF1,

        BEGIN OF TY_RBKP,
          BELNR TYPE BELNR_D,
          GJAHR TYPE GJAHR,
          BLDAT TYPE BLDAT,
          BUKRS TYPE BUKRS,
          RMWWR TYPE RMWWR,
        END OF TY_RBKP,
        TY_T_RBKP TYPE STANDARD TABLE OF TY_RBKP,

*        BEGIN OF TY_T052,
*        ZTERM TYPE DZTERM,
*        ZTAG1 TYPE DZTAGE,
*          END OF TY_T052,
* TY_T_T052 TYPE STANDARD TABLE OF TY_T052,

        BEGIN OF TY_FINAL,
          LIFNR	   TYPE LIFNR,
          BUDAT	   TYPE BUDAT,
          BLDAT    TYPE BLDAT,
          DMBTR    TYPE DMBTR,
          XBLNR    TYPE BSIK-XBLNR,
          C_DMBTR  TYPE DMBTR,
          D_DMBTR  TYPE DMBTR,
          NETDT    TYPE BSEG-NETDT,
          NAME1	   TYPE NAME1_GP,
          ORT01    TYPE LFA1-ORT01,
          LANDX50  TYPE LANDX50,
          BEZEI    TYPE T005U-BEZEI,
          VKBUR    TYPE KNVV-VKBUR,
          VKGRP    TYPE KNVV-VKGRP,
          KDGRP    TYPE KNVV-KDGRP,
          SPART    TYPE KNVV-SPART,
          SGTXT    TYPE BSIK-SGTXT,
          NAME2    TYPE NAME1_GP, "regional manager
          NAME3    TYPE NAME1_GP, "sales employee
          AKONT    TYPE LFB1-AKONT, ""recon.account
          BELNR1   TYPE BELNR_D,
          BLDAT1   TYPE BLDAT,
          RMWWR    TYPE RMWWR,
          ZTERM    TYPE BSIK-ZTERM,
          GSBER    TYPE BSIK-GSBER,
          DEBIT1   TYPE DMBTR,
          DEBIT2   TYPE DMBTR,
          DEBIT3   TYPE DMBTR,
          DEBIT4   TYPE DMBTR,
          DEBIT5   TYPE DMBTR,
          DEBIT6   TYPE DMBTR, "changed on 4-dec-2016 by naveen
          DEBIT7   TYPE DMBTR, "changed on 4-dec-2016 by naveen
          ZBD1T    TYPE I,
          LV_NYD   TYPE DMBTR,
          DEBITBAL TYPE DMBTR,
          OVERDUE  TYPE DMBTR,
*         ZTAG1 TYPE T052-ZTAG1,
*         ZTERM TYPE T052-ZTERM,

        END OF TY_FINAL,
        TY_T_FINAL TYPE STANDARD TABLE OF TY_FINAL.

DATA: LV_NYD TYPE DMBTR.

DATA : I_BSIK   TYPE TY_T_BSIK, "internal table
       I_LFA1   TYPE TY_T_LFA1,
       I_LFB1   TYPE TY_T_LFB1,
       I_LFA1R  TYPE TY_T_LFA1,
       I_LFA1S  TYPE TY_T_LFA1,
       I_KNVV   TYPE TY_T_KNVV,
       I_KNVP   TYPE TY_T_KNVP,
       I_KNVP1  TYPE TY_T_KNVP,
       I_BSEG   TYPE TY_T_BSEG,
       W_BSEG   TYPE TY_BSEG,
       I_BSAK   TYPE TY_T_BSAK,
       I_EKKO   TYPE TY_T_EKKO,
       I_BKPF   TYPE TY_T_BKPF,
       I_BKPF1  TYPE TY_T_BKPF1,
       I_RBKP   TYPE TY_T_RBKP,
       I_VBRK   TYPE TY_T_VBRK,
       I_T005U  TYPE TABLE OF T005U,
       I_T005T  TYPE TY_T_T005T,
*       I_T052 TYPE TY_T_T052,
       I_FINAL  TYPE TY_T_FINAL,
       I_FINAL1 TYPE TY_T_FINAL,
       I_FINAL3 TYPE TY_T_FINAL,
       I_FINAL4 TYPE TY_T_FINAL.



DATA : W_BSIK   TYPE TY_BSIK, "workarea
       W_BSAK   TYPE TY_BSAK,
       W_LFA1   TYPE TY_LFA1,
       W_LFB1   TYPE TY_LFB1,
       W_LFA1R  TYPE TY_LFA1,
       W_LFA1S  TYPE TY_LFA1,
       W_KNVV   TYPE TY_KNVV,
       W_KNVP   TYPE TY_KNVP,
       W_KNVP1  TYPE TY_KNVP,
       W_EKKO   TYPE TY_EKKO,
       W_BKPF   TYPE TY_BKPF,
       W_BKPF1  TYPE TY_BKPF1,
       W_RBKP   TYPE TY_RBKP,
       W_VBRK   TYPE TY_VBRK,
       W_T005U  TYPE T005U,
       W_T005T  TYPE TY_T005T,
*       W_T052 TYPE TY_T052,
       W_FINAL  TYPE TY_FINAL,
       W_FINAL1 TYPE TY_FINAL,
       W_FINAL2 TYPE TY_FINAL,
       W_FINAL3 TYPE TY_FINAL,
       W_FINAL4 TYPE TY_FINAL.

*DATA: BEGIN OF ITAB OCCURS 0,
*      EBELN type EBELN,"purchase document no.
*      LIFNR type LIFNR,"Account Number of Vendor
*      ZUONR type  DZUONR,
*      UMSKZ type UMSKZ,
*      DMBTR type DMBTR,
*       NO TYPE I,
*       PARVW TYPE PARVW,
*       NAME1 TYPE NAME1_GP," VENDOR NAME
*       BELNR TYPE BELNR_D, "  Document Number
*       ZFBDt TYPE DZFBDT, " Due Date
*       ZBD1T type DZBD1T,
*       ZBD2T type DZBD2T,
*       ZBD3T type DZBD3T,
*       SHKZG type SHKZG,
*       BEDAT type EBDAT," Billing date
*       DMBTR1 type DMBTR,
*       DMBTR2 type DMBTR,
*       AUBEL LIKE VBRP-AUBEL,    "sales order no.
*       AEDAT type ERDAT,
*       OAFILENO LIKE TLINE-TDLINE,
*     OADATE LIKE TLINE-TDLINE,
*     BUDAT type BUDAT,
*     BLART type BLART,
*     REBZT type REBZT,
*     LTEXT LIKE T003T-LTEXT,
*     Start " BY nbs for ageing 27.04.2010
*     LESS30 TYPE DMBTR, " BY nbs
*     LESS60 TYPE DMBTR,
*     GREATER60 TYPE DMBTR,
*     GREATER180 TYPE dMBTR,
*     OUTSD TYPE BSEG-DMBTR,
*
*     end " BY nbs for ageing
*
*
*     END OF ITAB.
*
*DATA: ITAB_DZ LIKE ITAB OCCURS 0 WITH HEADER LINE.
*
*
*DATA: BEGIN OF ITAB_LD OCCURS 0,
*      LIFNR type LIFNR,"Account Number of Vendor
*      ZUONR type  DZUONR,
*      EBELN type EBELN,"purchase document no.
*      UMSKZ type UMSKZ,
*      DMBTR type DMBTR,"purchase document amount
*      NO TYPE I,
*      PARVW TYPE PARVW,
*     NAME1 TYPE NAME1_GP,   " customer name
*     BELNR TYPE BELNR_D,   " doc. no
*     ZFBDt TYPE DZFBDT,   " due date
*     ZBD1T type DZBD1T,
*       ZBD2T type DZBD2T,
*       ZBD3T type DZBD3T,
*     SHKZG type SHKZG,
*     BEDAT type EBDAT,   " invoice date
*      DMBTR1 type DMBTR,
*       DMBTR2 type DMBTR,
*     AUBEL LIKE VBRP-AUBEL,    "sales order no.
*     AEDAT type ERDAT,   "sales order date
*     OAFILENO LIKE TLINE-TDLINE,
*     OADATE LIKE TLINE-TDLINE,
*      BUDAT type BUDAT,
*     BLART type BLART,
*    REBZT type REBZT,
*     LTEXT LIKE T003T-LTEXT,
*  27.04.2010   Start " BY nbs for ageing 27.04.2010
*      LESS30 TYPE DMBTR, " BY nbs
*     LESS60 TYPE DMBTR,
*     GREATER60 TYPE DMBTR,
*     GREATER180 TYPE dMBTR,
*     OUTSD TYPE DMBTR,
*     End " BY nbs for ageing
*
*
*     END OF ITAB_LD.
*
*DATA: ITAB_LDZ LIKE ITAB_LD OCCURS 0 WITH HEADER LINE.
*
*
*
*DATA: LINES LIKE TLINE OCCURS 0 WITH HEADER LINE.
*DATA: NAME LIKE THEAD-TDNAME.
*
*DATA:VBELN1 LIKE VBRK-VBELN.
*DATA:DMBTR LIKE BSEG-DMBTR.
*
*DATA:DMBTR1 LIKE BSEG-DMBTR,
* SHKZG LIKE BSIK-SHKZG,
* KUNNR1 LIKE BSIK-KUNNR.
*
*
*
*DATA: BEGIN OF IT_BSak OCCURS 0,
*       BELNR LIKE BSak-BELNR,
*       END OF IT_BSak.
*
** ALV Declaration
*DATA : W_CAT TYPE SLIS_FIELDCAT_ALV,
*       I_CAT TYPE SLIS_T_FIELDCAT_ALV,
*       XLAYOUT TYPE SLIS_LAYOUT_ALV.
*
*XLAYOUT-ZEBRA = 'X'.
*XLAYOUT-INFO_FIELDNAME = 'LINE_COLOR'.


DATA : GV_EBELN TYPE EBELN,
       GV_BLDAT TYPE BLDAT,
       GV_LIFNR TYPE LIFNR,
       GV_BUDAT TYPE BUDAT,
       GV_BUKRS TYPE BUKRS,
       GV_GJAHR TYPE GJAHR.

DATA : GSI_FAEDE TYPE FAEDE,
       GSE_FAEDE TYPE FAEDE,
       GV_REPID  LIKE SY-REPID VALUE SY-REPID.

DATA : GS_ALV_LAYOUT TYPE SLIS_LAYOUT_ALV,
       I_FIELDCAT    TYPE SLIS_T_FIELDCAT_ALV,
       W_FIELDCAT    TYPE SLIS_FIELDCAT_ALV,
       I_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
       W_TOP_OF_PAGE TYPE SLIS_LISTHEADER.
DATA: GW_BDCDATA TYPE BDCDATA,
      GT_BDCDATA TYPE TABLE OF BDCDATA,
      GW_OPT     TYPE CTU_PARAMS.

CONSTANTS : C_KOART TYPE KOART VALUE 'K',
            C_CIND  TYPE  SHKZG VALUE 'H',
            C_DIND  TYPE SHKZG VALUE 'S'.
