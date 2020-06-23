*&---------------------------------------------------------------------*
*& Include          ZSD_PICK_LIST_015_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_LIKP,
         VBELN TYPE VBELN_VL,                ""Delivery
         VSTEL TYPE VSTEL,                   ""Shipping Point/Receiving Point
         KODAT TYPE KODAT,                   ""Picking Date
         KUNNR TYPE KUNWE,                   ""Ship-to party
         BLDAT TYPE BLDAT,                   ""Document Date in Document
       END OF TY_LIKP.

TYPES: BEGIN OF TY_TVST,
         VSTEL TYPE VSTEL,                   ""Shipping Point/Receiving Point
         ADRNR TYPE ADRNR,                   ""Address
       END OF TY_TVST.

TYPES: BEGIN OF TY_ADRC,
         ADDRNUMBER TYPE AD_ADDRNUM,         ""Address Number
         NAME1      TYPE AD_NAME1,           ""Name 1
         CITY1      TYPE AD_CITY1,           ""City
         POST_CODE1 TYPE AD_PSTCD1,          ""City postal code
         STREET     TYPE AD_STREET,          ""Street
         STR_SUPPL1 TYPE AD_STRSPP1,         ""Street 2
         STR_SUPPL2 TYPE AD_STRSPP2,         ""Street 3
       END OF TY_ADRC.

TYPES: BEGIN OF TY_KNA1,
         KUNNR TYPE KUNNR,                  ""Customer Number
         ADRNR TYPE ADRNR,                  ""Address
         LAND1 TYPE	LAND1_GP,               ""Country Key
       END OF TY_KNA1.

TYPES: BEGIN OF TY_T005T,
         SPRAS TYPE SPRAS,                  ""Language Key
         LAND1 TYPE LAND1,                  ""Country Key
         LANDX TYPE LANDX,                  ""Country Name
       END OF TY_T005T.

TYPES: BEGIN OF TY_LIPS,
         VBELN        TYPE VBELN_VL,       ""Delivery
         POSNR        TYPE POSNR_VL,       ""Delivery Item
         MATNR        TYPE MATNR,          ""Material Number
         LGORT        TYPE LGORT_D,        ""Storage location
         LFIMG        TYPE LFIMG,          ""Actual quantity delivered (in sales units)
         VRKME        TYPE VRKME,          ""Sales unit
         VGBEL        TYPE VGBEL,          ""Document number of the reference document
         WRF_CHARSTC2 TYPE WRF_CHARSTC2,   ""Characteristic Value 2
       END OF TY_LIPS.

TYPES: BEGIN OF TY_VBAK,
         VBELN TYPE VBELN_VA,              ""Sales Document
*       MATNR TYPE MATNR,                 ""Material Number
         BSTNK TYPE BSTNK,                 ""Customer Reference
       END OF TY_VBAK.

TYPES: BEGIN OF TY_MARA,
         MATNR       TYPE MATNR,           ""Material Number
         MATKL       TYPE MATKL,           ""Material Group
         SATNR       TYPE SATNR,           ""Cross-Plant Configurable Material
         COLOR_ATINN TYPE WRF_COLOR_ATINN, ""Internal Charactieristic Number for Color Characteristics
         COLOR       TYPE WRF_COLOR,       ""Characteristic Value for Colors of Variants
         SIZE1       TYPE WRF_SIZE1,       ""Characteristic Value for Main Sizes of Variants
       END OF TY_MARA.

TYPES: BEGIN OF TY_WRF_CHARVALT,
         ATINN TYPE ATINN,                 ""Internal characteristic
         ATWRT TYPE WRF_ATWRT,             ""Characteristic Value (Seasonal Procurement)
         SPRAS TYPE SPRAS,                 ""Language Key
         ATWTB TYPE ATWTB,                 ""Characteristic value description
       END OF TY_WRF_CHARVALT.

TYPES: BEGIN OF TY_T006,
         MSEHI   TYPE MSEHI,               ""Unit of Measurement
         FAMUNIT TYPE FAMUNIT,             ""Unit of measurement family
       END OF TY_T006.

TYPES: BEGIN OF TY_VBFA,
         RUUID TYPE SD_DOC_REL_UUID,       ""SD Unique Document Relationship Identification
         VBELV TYPE VBELN_VON,             ""Preceding sales and distribution document
         POSNV TYPE POSNR_VON,             ""Preceding Item of an SD Document
         VBELN TYPE VBELN_NACH,            ""Subsequent Sales and Distribution Document
       END OF TY_VBFA.

DATA: XVBELN TYPE VBELN_VL.

DATA: IT_LIKP         TYPE TABLE OF TY_LIKP,
      WA_LIKP         TYPE TY_LIKP,
      IT_LIPS         TYPE TABLE OF TY_LIPS,
      WA_LIPS         TYPE TY_LIPS,
      IT_VBFA         TYPE TABLE OF TY_VBFA,
      WA_VBFA         TYPE TY_VBFA,
      IT_TVST         TYPE TABLE OF TY_TVST,
      WA_TVST         TYPE TY_TVST,
      IT_KNA1         TYPE TABLE OF TY_KNA1,
      WA_KNA1         TYPE TY_KNA1,
      IT_T005T        TYPE TABLE OF TY_T005T,
      WA_T005T        TYPE TY_T005T,
      IT_T005T1       TYPE TABLE OF TY_T005T,
      WA_T005T1       TYPE TY_T005T,
      IT_ADRC         TYPE TABLE OF TY_ADRC,
      WA_ADRC         TYPE TY_ADRC,
      IT_ADRC1        TYPE TABLE OF TY_ADRC,
      WA_ADRC1        TYPE TY_ADRC,
      IT_VBAK         TYPE TABLE OF TY_VBAK,
      WA_VBAK         TYPE TY_VBAK,
      IT_MARA         TYPE TABLE OF TY_MARA,
      WA_MARA         TYPE TY_MARA,
      IT_T006         TYPE TABLE OF TY_T006,
      WA_T006         TYPE TY_T006,
      IT_WRF_CHARVALT TYPE TABLE OF TY_WRF_CHARVALT,
      WA_WRF_CHARVALT TYPE TY_WRF_CHARVALT,
      IT_FINAL        TYPE TABLE OF ZFINAL_PICK,
      WA_FINAL        TYPE ZFINAL_PICK,
      WA_HEADER       TYPE ZHEADER_PICK.
DATA : LV_CNT TYPE I VALUE 0.


DATA: FMNAME      TYPE RS38L_FNAM,
      LV_TOTAL(5) TYPE C,
      IT_LINES    TYPE TABLE OF TLINE,
      WA_LINES    TYPE TLINE,
      IT_O_WGH01  TYPE TABLE OF WGH01,
      WA_O_WGH01  TYPE WGH01,
      LV_1(10)    TYPE C,
      LV_2(10)    TYPE C,
      LV_3(10)    TYPE C,
      LV_VBELN    TYPE LIKP-VBELN.
