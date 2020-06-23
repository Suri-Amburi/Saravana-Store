*&---------------------------------------------------------------------*
*& Include          ZFI_AS91_AB01_ABLDT_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF TY_EXCELTAB,
*          invnr(20),
          ANLKL(08),                           "Asset Class
          BUKRS(04),                           "Company Code
*          nassets(20),
          TXT50(70),                           "Asset Description
          TXA50(100),                          "Asset Description (long)
          ANLHTTXT(70),                        "Asset main no text
*          ktogr(20),
          INVNR1(20),                          "Inventory Number
          MENGE(20),                           "Quantity
          MEINS(20),                           "UOM
          GJAHR(04),                           "Fiscal Year
          AKTIV(20),                           "Captilised On
*          zujhr(20),
*          zuper(20),
          GSBER(20),                           "Bussiness Area
          KOSTL(20),                           "Cost Center
          WERKS(20),                           "Plant
*          lifnr(30),
          LIFNR          TYPE LIFNR,           "Vendor Code
          TYPBZ(40),                           "Type Name
          ULIFE(3),                            "Planned Useful Life in Years                                         "added by skn.
          ASSETTRTYP(03),                      "Assert type
          BLDAT(10),                           "Document date
          BUDAT(10),                           "Posting Date
          BZDAT(10),                           "Asset Value date
          ANBTR(40),                           "Amount

          ACQ_VALUE(40),                       "Acquired Value
          ORD_DEP(40),                         "Accumulated Description
          NAFAG(40),                           "For the period 1.4.2018 - 31.07.18 Ordinary Depreciation Posted
          ORD_DEP1(40),                         "Tax Accu. Dep.
        END OF TY_EXCELTAB,
        TY_T_EXCELTAB TYPE STANDARD TABLE OF TY_EXCELTAB.


DATA : WA_EXCELTAB TYPE TY_EXCELTAB,
       I_EXCELTAB  TYPE TY_T_EXCELTAB.

DATA : FNAME TYPE LOCALFILE,
       ENAME TYPE CHAR4.

TYPES : BEGIN OF TY_ERRMSG,
          SNO    TYPE I,
          MSGTYP TYPE BAPI_MTYPE,
          MESSG  TYPE BAPIRET2-MESSAGE,
          DOCNUM TYPE CHAR30,
        END OF TY_ERRMSG,
        TY_T_ERRMSG TYPE STANDARD TABLE OF TY_ERRMSG.

DATA: WA_ERRMSG      TYPE TY_ERRMSG,
      I_ERRMSG       TYPE TY_T_ERRMSG,
      I_FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV,

      GT_ANKB        TYPE TABLE OF ANKB,
      WA_ANKB        TYPE ANKB.
