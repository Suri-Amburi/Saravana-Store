*&---------------------------------------------------------------------*
*& Include ZSAPMP_MM_PO_CREATE_TOP                  - Module Pool      ZSAPMP_MM_PO_CREATE
*&---------------------------------------------------------------------*
PROGRAM ZSAPMP_MM_PO_CREATE.

TYPES : BEGIN OF TY_EKKO,
          EBELN	TYPE EBELN , "Purchasing Document Number
          AEDAT TYPE 	ERDAT   , "Date on which the record was created
        END OF TY_EKKO.

TYPES : BEGIN OF TY_EKPO,
          EBELN TYPE EBELN , "  Purchasing Document Number
          EBELP TYPE EBELP, "Item Number of Purchasing Document
          AEDAT TYPE PAEDT  , "  Purchasing Document Item Change Date
          MENGE TYPE BSTMG, "  Purchase Order Quantity
          MEINS TYPE  BSTME , "Purchase Order Unit of Measure
        END OF TY_EKPO.

TYPES : BEGIN OF TY_LFA1,
          LIFNR TYPE LIFNR  , "ACCOUNT NUMBER OF VENDOR OR CREDITOR
          LAND1 TYPE LAND1_GP, "Country Key
          NAME1 TYPE NAME1_GP  , "  Name 1
          ADRNR TYPE ADRNR  , "Address
          STCD3 TYPE STCD3,
        END OF TY_LFA1.

TYPES : BEGIN OF TY_MARA,
          MATNR TYPE MATNR  , "  Material Number
          MATKL TYPE MATKL , "Material Group
          MEINS TYPE MEINS , "  Base Unit of Measure
        END OF TY_MARA.
*
TYPES: BEGIN OF TY_MARC,
         MATNR TYPE MATNR,
         WERKS TYPE WERKS_D,
         STEUC TYPE STEUC,
       END OF TY_MARC.




TYPES : BEGIN OF TY_MAKT,
          MATNR TYPE MATNR  , "Material Number
          SPRAS TYPE SPRAS  , "Language Key
          MAKTX TYPE MAKTX  , "Material description
        END OF TY_MAKT.

TYPES : BEGIN OF TY_A900,
          KAPPL  TYPE KAPPL , "  Application
          KSCHL	 TYPE KSCHA	, "Condition type
          WKREG	 TYPE WKREG	, "Region in which plant is located
          REGIO	 TYPE REGIO	, "Region (State, Province, County)
          TAXK1  TYPE TAXK1, "  Tax Classification 1 for Customer
          TAXM1	 TYPE TAXM1	, "Tax classification material
          STEUC	 TYPE STEUC	, "Control code for consumption taxes in foreign trade
          KFRST	 TYPE KFRST	, "Release status
          DATBI  TYPE KODATBI , "  Validity end date of the condition record
          DATAB  TYPE KODATAB , "  Validity start date of the condition record
          KBSTAT TYPE KBSTAT, " Processing status for conditions
          KNUMH  TYPE KNUMH , "  Condition record number
        END OF TY_A900.
TYPES : BEGIN OF TY_KONP,
          KNUMH TYPE KNUMH,
          KOPOS TYPE KOPOS,
          KBETR TYPE KBETR_KOND,
        END OF TY_KONP.

TYPES : BEGIN OF TY_ADRC,
          ADDRNUMBER TYPE AD_ADDRNUM,
          DATE_FROM	 TYPE AD_DATE_FR,
          NATION     TYPE AD_NATION,
          NAME1	     TYPE AD_NAME1,
          CITY1	     TYPE AD_CITY1,
          POST_CODE1 TYPE AD_PSTCD1,
          STREET     TYPE AD_STREET,
          COUNTRY	   TYPE LAND1,
          REGION     TYPE REGIO,
          STR_SUPPL1 TYPE AD_STRSPP1,
          STR_SUPPL2 TYPE AD_STRSPP2,
        END OF TY_ADRC .

TYPES : BEGIN OF TY_T001W,
          WERKS TYPE WERKS_D,
          ADRNR TYPE ADRNR,
          EKORG	TYPE EKORG,
        END OF TY_T001W.

TYPES : BEGIN OF ty_f4tab ,
          matnr type matnr,
          maktx type maktx,
          matkl type matkl,
        end   of ty_f4tab .

TYPES : BEGIN OF TY_T001K,
          BWKEY TYPE BWKEY,
          BUKRS TYPE BUKRS,
        END OF TY_T001K.

types : BEGIN OF ty_itab,
          matnr type mara-matnr,
          matkl type mara-matkl,
          maktx type makt-maktx,
        END OF ty_itab.



DATA : LV_% TYPE KBETR_KOND.
DATA : LV_LEAD TYPE DLYDY .
DATA : IT_EKKO   TYPE TABLE OF TY_EKKO,
       WA_EKKO   TYPE TY_EKKO,
       it_t001k type TABLE OF ty_t001k,
       wa_t001k type ty_t001k,
       wa_t026z type t026z ,
       IT_EKPO   TYPE TABLE OF TY_EKPO,
       WA_EKPO   TYPE TY_EKPO,
       IT_KONP   TYPE TABLE OF TY_KONP,
       WA_KONP   TYPE TY_KONP,
       IT_MARA   TYPE TABLE OF TY_MARA,
       IT_MARA1  TYPE TABLE OF TY_MARA,
       WA_MARA   TYPE TY_MARA,
       IT_MARC   TYPE TABLE OF TY_MARC,
       WA_MARC   TYPE TY_MARC,
       IT_ADRC   TYPE TABLE OF TY_ADRC,
       WA_ADRC   TYPE TY_ADRC,
       WA_ADRC1  TYPE TY_ADRC,
       it_itab TYPE TABLE OF ty_itab,
       it_itab1 TYPE TABLE OF ty_itab,
       wa_itab TYPE ty_itab,
       IT_MAKT   TYPE TABLE OF TY_MAKT,
       WA_MAKT   TYPE TY_MAKT,
       IT_ITEM   TYPE TABLE OF ZPO_ITEM,
       IT_ITEM1  TYPE TABLE OF ZPO_ITEM,
       WA_ITEM   TYPE ZPO_ITEM,
       WA_ITEM1  TYPE ZPO_ITEM,
       IT_LFA1   TYPE TABLE OF TY_LFA1,
       WA_LFA1   TYPE TY_LFA1,
       WA_HEADER TYPE ZPO_HEADER,
       WA_T001W  TYPE TY_T001W,
       IT_A900   TYPE TABLE OF TY_A900,
       WA_A900   TYPE TY_A900.

DATA : IT_WHG01 TYPE TABLE OF WGH01 WITH HEADER LINE.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC1' ITSELF
CONTROLS: TC1 TYPE TABLEVIEW USING SCREEN 9000.

*&SPWIZARD: LINES OF TABLECONTROL 'TC1'
DATA:     G_TC1_LINES  LIKE SY-LOOPC.

DATA:     OK_CODE LIKE SY-UCOMM.

DATA : HEADER  LIKE BAPIMEPOHEADER,
       HEADERX LIKE BAPIMEPOHEADERX.
*       vendor_addr like BAPIMEPOADDRVENDOR .

DATA : ITEM        TYPE TABLE OF BAPIMEPOITEM  WITH HEADER LINE,
       POSCHEDULE  TYPE TABLE OF BAPIMEPOSCHEDULE WITH HEADER LINE,
       POSCHEDULEX TYPE TABLE OF BAPIMEPOSCHEDULX WITH HEADER LINE,
       ITEMX       TYPE TABLE OF BAPIMEPOITEMX  WITH HEADER LINE,
       RETURN      TYPE TABLE OF BAPIRET2 ,
       WA_RETURN      TYPE  BAPIRET2 .

DATA : LV_EBELN TYPE EBELN .
data : lv_suc(100) type c .

DATA: NUM      TYPE I.
DATA: NUM1      TYPE I.

Data: it1_bapi_poheader  like BAPI_TE_MEPOHEADER,
         it1_bapi_poheaderx like BAPI_TE_MEPOHEADERX,
         it_extensionin type TABLE OF BAPIPAREX  ,
         wa_extensionin type BAPIPAREX  .

*Data: it1_bapi_poheader  like BAPI_TE_MEPOHEADER,
*         it1_bapi_poheaderx like BAPI_TE_MEPOHEADERX ,
*         it_extensionin type TABLE OF BAPIPAREX WITH HEADER LINE .
