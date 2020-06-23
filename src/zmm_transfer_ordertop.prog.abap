*&---------------------------------------------------------------------*
*& Include ZMM_TRANSFER_ORDERTOP                    - Report ZMM_TRANSFER_ORDER
*&---------------------------------------------------------------------*
REPORT ZMM_TRANSFER_ORDER.
TYPES : BEGIN OF TY_MSEG,
          MBLNR TYPE MSEG-MBLNR,
          MJAHR TYPE MSEG-MJAHR,
          ZEILE TYPE MSEG-ZEILE,
          BWART TYPE MSEG-BWART,
          MATNR TYPE MSEG-MATNR,
          WERKS TYPE MSEG-WERKS,
          LGORT TYPE MSEG-LGORT,
          LIFNR TYPE MSEG-LIFNR,
          KUNNR TYPE MSEG-KUNNR,
          SHKZG TYPE mseg-SHKZG,
          CHARG TYPE MSEG-CHARG,
          MENGE TYPE MSEG-MENGE,
          MEINS TYPE mseg-MEINS,
          ERFMG TYPE MSEG-ERFMG,
          UMWRK TYPE MSEG-UMWRK,
          BUDAT_MKPF TYPE mseg-BUDAT_MKPF,       " Posting Date in the Document
          CPUTM_MKPF TYPE mseg-CPUTM_MKPF,       " Time of Entry
          USNAM_MKPF TYPE mseg-USNAM_MKPF,       " User Name
        END OF TY_MSEG,

        BEGIN OF TY_T001W,
          WERKS      TYPE T001W-WERKS,                            "Plant
          NAME1      TYPE T001W-NAME1,                              "Name
          STRAS      TYPE T001W-STRAS,                              "Street and House Number
          ORT01      TYPE T001W-ORT01,                              "City
          LAND1      TYPE T001W-LAND1,                              "Country Key
          ADRNR      TYPE T001W-ADRNR,
          J_1BBRANCH TYPE T001W-J_1BBRANCH,
        END OF TY_T001W,


        BEGIN OF TY_J_1BBRANCH,
          BUKRS  TYPE J_1BBRANCH-BUKRS,                                  "COMPANY CODE
          BRANCH TYPE J_1BBRANCH-BRANCH,
          GSTIN  TYPE J_1IGSTCD3,                             "GST NO
        END OF TY_J_1BBRANCH,

        BEGIN OF TY_ADRC,
          ADDRNUMBER TYPE  ADRC-ADDRNUMBER,
          NAME1      TYPE ADRC-NAME1,
          CITY1      TYPE ADRC-CITY1,
          STREET     TYPE ADRC-STREET,
          STR_SUPPL1 TYPE ADRC-STR_SUPPL1,
          STR_SUPPL2 TYPE ADRC-STR_SUPPL2,
          COUNTRY    TYPE ADRC-COUNTRY,
          LANGU      TYPE ADRC-LANGU,
          REGION     TYPE ADRC-REGION,
          POST_CODE1 TYPE ADRC-POST_CODE1,
        END OF TY_ADRC,

        BEGIN OF TY_MARA,
          MATNR TYPE MARA-MATNR,
          EAN11 TYPE MARA-EAN11,
        END OF TY_MARA,

        BEGIN OF TY_MAKT,
          MATNR TYPE MATNR,                                "Material Number
          SPRAS TYPE SPRAS,                                "Language Key
          MAKTX TYPE MAKTX,                                "Material description
        END OF TY_MAKT,

        BEGIN OF TY_LFA1,
          LIFNR TYPE LFA1-LIFNR,
          NAME1 TYPE LFA1-NAME1,
          END OF TY_LFA1.

DATA : IT_MSEG       TYPE TABLE OF TY_MSEG,
       WA_MSEG       TYPE TY_MSEG,

       IT_T001W      TYPE TABLE OF TY_T001W,
       WA_T001W      TYPE TY_T001W,

       IT_T001W2     TYPE TABLE OF TY_T001W,
       WA_T001W2     TYPE TY_T001W,

       IT_J_1BBRANCH TYPE TABLE OF TY_J_1BBRANCH,
       WA_J_1BBRANCH TYPE TY_J_1BBRANCH,

       IT_ADRC       TYPE TABLE OF TY_ADRC,
       WA_ADRC       TYPE TY_ADRC,

       IT_MARA       TYPE TABLE OF TY_MARA,
       WA_MARA       TYPE TY_MARA,

       IT_MAKT       TYPE TABLE OF TY_MAKT,
       WA_MAKT       TYPE TY_MAKT,

       IT_LFA1 TYPE TABLE OF TY_LFA1,
       WA_LFA1 TYPE TY_LFA1.


DATA : IT_HDR   TYPE TABLE OF ZTRANSFER_HDR,
       WA_HDR   TYPE ZTRANSFER_HDR,

       IT_ZMAIN TYPE TABLE OF ZTRANSFER_ITEM,
       WA_ZMAIN TYPE ZTRANSFER_ITEM,

       P_QR TYPE ZINW_T_HDR-QR_CODE,

       SL_NO(100) TYPE C.
       DATA : QR_CODE TYPE ZQR_CODE.

DATA : F_NAME TYPE RS38L_FNAM.

SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
*SELECT-OPTIONS : p_MBLNR FOR WA_MSEG-MBLNR." NO INTERVALS NO-EXTENSION.
  PARAMETERS : P_MBLNR TYPE MSEG-MBLNR,
               p_MJAHR TYPE mseg-MJAHR.

SELECTION-SCREEN END OF BLOCK A1.
