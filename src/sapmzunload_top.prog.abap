*&---------------------------------------------------------------------*
*& Include          SAPMZUNLOAD_TOP
*&---------------------------------------------------------------------*
PROGRAM SAPMZLOAD.

DATA : GV_SCANVAL TYPE EXIDV .

DATA: I_BDCDATA TYPE TABLE OF BDCDATA,
      W_BDCDATA TYPE BDCDATA,
      CTU_PARAM TYPE CTU_PARAMS.
DATA : GV_EXIDV TYPE EXIDV,
       GV_VBELN TYPE VBELN,
       GV_UNVEL TYPE UNVEL.

DATA: IT_MESSTAB TYPE TABLE OF BDCMSGCOLL,
      WA_MESSTAB TYPE BDCMSGCOLL,
*        wa_log TYPE zint_log,
      MESSTAB1   LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N',
      CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'A'.

CONSTANTS: AC                  VALUE 'C',
           AD                  VALUE 'D',
           AE                  VALUE 'E',
           AX                  VALUE 'X',

           AAOK                TYPE SYUCOMM VALUE 'AAOK',
           AANO                TYPE SYUCOMM VALUE 'AANO',

           BACK                TYPE SYUCOMM VALUE 'BACK',
           EXEC                TYPE SYUCOMM VALUE 'EXEC',
           FPAGE               TYPE SYUCOMM VALUE 'FPAGE',
           PPAGE               TYPE SYUCOMM VALUE 'PPAGE',
           NPAGE               TYPE SYUCOMM VALUE 'NPAGE',
           LPAGE               TYPE SYUCOMM VALUE 'LPAGE',

           SCREEN_NO_SHIPMENTS TYPE I VALUE 6.

DATA AUCOMM TYPE SYUCOMM.

TYPES: BEGIN OF SVTTK,
         TKNUM TYPE TKNUM,
         SIGNI TYPE SIGNI,
         STLAD type STLAD,
       END OF SVTTK.

TYPES: BEGIN OF SVTTP,
         TKNUM TYPE TKNUM,
         TPNUM TYPE  TPNUM,
         VBELN TYPE VBELN_VL,
       END OF SVTTP.

TYPES: BEGIN OF SLIKP,
         VBELN TYPE VBELN_VL,
         VSTEL TYPE VSTEL,
       END OF SLIKP.

TYPES : BEGIN OF TY_TKNUM,
          VBELN TYPE VBELN_VL,
          TKNUM TYPE TKNUM,
        END OF TY_TKNUM.



DATA: XVTTK    TYPE TABLE OF SVTTK WITH HEADER LINE,
      GT_VTTP  TYPE TABLE OF SVTTP WITH HEADER LINE,
      GT_LIKP  TYPE TABLE OF SLIKP WITH HEADER LINE,
      GT_TKNUM TYPE TABLE OF TY_TKNUM WITH HEADER LINE.

DATA: AMESAG(220),
      MESAG1      TYPE CHAR25,
      MESAG2      TYPE CHAR25,
      MESAG3      TYPE CHAR25,
      MESAG4      TYPE CHAR25,
      MESAG5      TYPE CHAR25,
      MESAG6      TYPE CHAR25,
      MESAG7      TYPE CHAR25,

      AICON       TYPE ICON-ID,
      MARK(1)     TYPE C.

DATA: SPR01, SPN01(31),
      SPR02, SPN02(31),
      SPR03, SPN03(31),
      SPR04, SPN04(31),
      SPR05, SPN05(31),
      SPR06, SPN06(31),
      SPR07, SPN07(31),
      SPR08, SPN08(31),
      SPR09, SPN09(31),
      SPR10, SPN10(31),
      SPR11, SPN11(31),
      SPR12, SPN12(31),
      SPR13, SPN13(31),
      SPR14, SPN14(31),
      SPR15, SPN15(31),
      SPR16, SPN16(31),
      SPR17, SPN17(31),
      SPR18, SPN18(31),
      SPR19, SPN19(31),
      SPR20, SPN20(31).

DATA: CURRP    TYPE I,
      LASTP    TYPE I,
      TOTAL    TYPE I,
      TEMPA(2) TYPE N.

DATA AFIELD TYPE CHAR20.

FIELD-SYMBOLS <AFS>.

DATA: ATKNUM  TYPE VTTK-TKNUM,
      AEXIDV  TYPE VEKP-EXIDV,
      ATPLST  TYPE VTTK-TPLST,
      SVSTEL  TYPE LIKP-VSTEL,
      SVSTEL2 TYPE LIKP-VSTEL,
      SVSTEL3 TYPE LIKP-VSTEL,
      ASUBRC  TYPE SYSUBRC,
      SSUBRC  TYPE SYSUBRC.

DATA: BEGIN OF XVTTP OCCURS 0,
        VBELN TYPE VTTP-VBELN,
      END OF XVTTP.

DATA: BEGIN OF XVEPO OCCURS 0,
        VENUM TYPE VEPO-VENUM,
        VEPOS TYPE VEPO-VEPOS,
        VBELN TYPE VEPO-VBELN,
        OBJNR TYPE HUSSTAT-OBJNR,
      END OF XVEPO.

DATA: BEGIN OF XVEKP OCCURS 0,
        VENUM  TYPE VEKP-VENUM,
        EXIDV  TYPE VEKP-EXIDV,
        EXIDV2 TYPE VEKP-EXIDV2,
        UEVEL  TYPE VEKP-UEVEL,
        PALLET TYPE VEKP-EXIDV,
      END OF XVEKP.

DATA: BEGIN OF XLHUS OCCURS 0,
        OBJNR TYPE HUSSTAT-OBJNR,
        STAT  TYPE HUSSTAT-STAT,
        INACT TYPE HUSSTAT-INACT,
      END OF XLHUS.

DATA: TOTALL_HUS TYPE I,
      LOADED_HUS TYPE I.

DATA: ADALEN TYPE SYDATUM,
      ADALBG TYPE SYDATUM.

DATA :GV_COUNT TYPE SY-TABIX,                  " Count for intial data fetch
      GV_FROM  TYPE SY-TABIX,                  " Count From
      GV_TO    TYPE SY-TABIX.                  " Count To

TYPES : BEGIN OF TY_SHIP,
          1SLNUM TYPE SY-TABIX,    " 1st Row Serial Number
          1TKNUM TYPE TKNUM,       " 1st Row Shipment Number
          1SIGNI TYPE SIGNI,       " 1st Row Container ID
          2SLNUM TYPE SY-TABIX,    " 2nd Row Serial Number
          2TKNUM TYPE TKNUM,       " 2nd Row Shipment Number
          2SIGNI TYPE SIGNI,       " 2nd Row Container ID
          3SLNUM TYPE SY-TABIX,    " 3rd Row Serial Number
          3TKNUM TYPE TKNUM,       " 3rd Row Shipment Number
          3SIGNI TYPE SIGNI,       " 3rd Row Container ID
          4SLNUM TYPE SY-TABIX,    " 4th Row Serial Number
          4TKNUM TYPE TKNUM,       " 4th Row Shipment Number
          4SIGNI TYPE SIGNI,       " 4th Row Container ID
          5SLNUM TYPE SY-TABIX,    " 5th Row Serial Number
          5TKNUM TYPE TKNUM,       " 5th Row Shipment Number
          5SIGNI TYPE SIGNI,       " 5th Row Container ID
          6SLNUM TYPE SY-TABIX,    " 6th Row Serial Number
          6TKNUM TYPE TKNUM,       " 6th Row Shipment Number
          6SIGNI TYPE SIGNI,       " 6th Row Container ID
          7SLNUM TYPE SY-TABIX,    " 7th Row Serial Number
          7TKNUM TYPE TKNUM,       " 7th Row Shipment Number
          7SIGNI TYPE SIGNI,       " 7th Row Container ID
        END OF TY_SHIP.
DATA : GS_SHIP         TYPE TY_SHIP .                 " Open Shipement List Fields
DATA : GV_SEL  TYPE CHAR3 ,                     " Line Selection Field
       GV_LINE TYPE SY-TABIX.                  " Lines

DATA : NOTIFY_BELL_SIGNAL(1) TYPE N .   " added by sjena on 270918
