*&---------------------------------------------------------------------*
*& Report ZVEND_DOWN_PAYMENT_D
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZVEND_DOWN_PAYMENT_D.

TABLES: BKPF,BSEG,ADRC,T001,LFA1.

SELECTION-SCREEN BEGIN OF BLOCK B WITH FRAME TITLE TEXT-000.
SELECT-OPTIONS: S_BELNR FOR BSEG-BELNR NO-EXTENSION NO INTERVALS OBLIGATORY,
                S_BUKRS FOR BSEG-BUKRS NO-EXTENSION NO INTERVALS OBLIGATORY,
                S_GJAHR FOR BSEG-GJAHR NO-EXTENSION NO INTERVALS OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B.
TYPES: BEGIN OF TY_BKPF,
       BELNR TYPE BELNR_D,
       BUKRS TYPE BUKRS,
       GJAHR TYPE GJAHR,
       BLDAT TYPE BLDAT,
       CPUTM TYPE CPUTM,
       BKTXT TYPE BKTXT,
       END OF TY_BKPF,

       BEGIN OF TY_BSEG,
       BELNR TYPE BELNR_D,
       BUKRS TYPE BUKRS,
       GJAHR TYPE GJAHR,
       KOART TYPE KOART,
       WRBTR TYPE WRBTR,
       ZFBDT TYPE DZFBDT,
       LIFNR TYPE LIFNR,
       SGTXT TYPE SGTXT,
       STCEG TYPE STCEG,
       END OF TY_BSEG,

       BEGIN OF TY_ADRC,
       ADDRNUMBER TYPE AD_ADDRNUM,
       NAME1      TYPE AD_NAME1,
       HOUSE_NUM1 TYPE AD_HSNM1,
       STREET     TYPE AD_STREET,
       STR_SUPPL1 TYPE AD_STRSPP1,
       STR_SUPPL2 TYPE AD_STRSPP2,
       CITY1      TYPE AD_CITY1,
       CITY2      TYPE AD_CITY2,
       COUNTRY    TYPE LAND1,
       POST_CODE1 TYPE AD_PSTCD1,
       TEL_NUMBER TYPE AD_TLNMBR1,
       END OF TY_ADRC,

       BEGIN OF TY_LFA1,
       LIFNR TYPE LIFNR,
       LAND1 TYPE LAND1_GP,
       NAME1 TYPE NAME1_GP,
       ORT01 TYPE ORT01_GP,
       ORT02 TYPE ORT02_GP,
       PSTLZ TYPE PSTLZ,
       STRAS TYPE STRAS,
       ADRNR TYPE ADRNR,
       WERKS TYPE WERKS_EXT,
       END OF TY_LFA1,

       BEGIN OF TY_T001,
       BUKRS TYPE BUKRS ,
       BUTXT TYPE BUTXT ,
       LAND1 TYPE LAND1 ,
       ORT01 TYPE ORT01 ,
       ADRNR TYPE ADRNR ,
       END OF TY_T001.



*       BEGIN OF TY_T001W,
*       WERKS TYPE WERKS_D,
*       NAME1 TYPE NAME1,
*       STRAS TYPE STRAS,
*       PSTLZ TYPE PSTLZ,
*       ORT01 TYPE ORT01,
*       LAND1 TYPE LAND1,
*       ADRNR TYPE ADRNR,
*       END OF TY_T001W.

DATA: IT_BKPF TYPE TABLE OF TY_BKPF,
      IT_BSEG TYPE TABLE OF TY_BSEG,
      IT_ADRC TYPE TABLE OF TY_ADRC,
      IT_ADRC1 TYPE TABLE OF TY_ADRC,
      IT_LFA1 TYPE TABLE OF TY_LFA1,
*      IT_T001W TYPE TABLE OF TY_T001W,
      IT_T001 TYPE TABLE OF TY_T001,
      WA_BKPF TYPE TY_BKPF,
      WA_BSEG TYPE TY_BSEG,
      WA_ADRC TYPE TY_ADRC,
      WA_ADRC1 TYPE TY_ADRC,
      WA_LFA1 TYPE TY_LFA1,
*      WA_T001W TYPE TY_T001W,
      WA_T001 TYPE TY_T001,
      IT_HEADER TYPE TABLE OF ZVDP_HDR,
      WA_HEADER TYPE ZVDP_HDR,
      IT_ITEM TYPE TABLE OF ZVDP_ITM,
      WA_ITEM TYPE ZVDP_ITM,
      LV_TOT TYPE WRBTR,
      SLNO TYPE INT4,
      FNAM TYPE RS38L_FNAM.

SELECT BELNR
       BUKRS
       GJAHR
       BLDAT
       CPUTM
       BKTXT
       FROM BKPF INTO TABLE IT_BKPF WHERE BELNR IN S_BELNR
                                      AND BUKRS IN S_BUKRS
                                      AND GJAHR IN S_GJAHR.

IF IT_BKPF IS NOT INITIAL.
SELECT BELNR
       BUKRS
       GJAHR
       KOART
       WRBTR
       ZFBDT
       LIFNR
       SGTXT
       STCEG

       FROM BSEG INTO TABLE IT_BSEG FOR ALL ENTRIES IN IT_BKPF WHERE BELNR = IT_BKPF-BELNR
                                                                 AND BUKRS = IT_BKPF-BUKRS
                                                                 AND GJAHR = IT_BKPF-GJAHR
                                                                 AND KOART = 'K'.
ENDIF.
IF IT_BSEG IS NOT INITIAL.
SELECT LIFNR
       LAND1
       NAME1
       ORT01
       ORT02
       PSTLZ
       STRAS
       ADRNR
       WERKS
       FROM LFA1 INTO TABLE IT_LFA1 FOR ALL ENTRIES IN IT_BSEG WHERE LIFNR = IT_BSEG-LIFNR.

SELECT BUKRS
       BUTXT
       LAND1
       ORT01
       ADRNR
       FROM T001 INTO TABLE IT_T001 FOR ALL ENTRIES IN IT_BSEG WHERE BUKRS = IT_BSEG-BUKRS.

ENDIF.
IF IT_LFA1 IS  NOT INITIAL.
SELECT ADDRNUMBER
       NAME1
       HOUSE_NUM1
       STREET
       STR_SUPPL1
       STR_SUPPL2
       CITY1
       CITY2
       COUNTRY
       POST_CODE1
       TEL_NUMBER
       FROM ADRC INTO TABLE IT_ADRC FOR ALL ENTRIES IN IT_LFA1 WHERE ADDRNUMBER = IT_LFA1-ADRNR.

* SELECT WERKS
*        NAME1
*        STRAS
*        PSTLZ
*        ORT01
*        LAND1
*        ADRNR
*        FROM T001W INTO TABLE IT_T001W FOR ALL ENTRIES IN IT_LFA1 WHERE WERKS = IT_LFA1-WERKS.
 ENDIF.

 IF IT_T001 IS NOT INITIAL.
 SELECT ADDRNUMBER
        NAME1
        HOUSE_NUM1
        STREET
        STR_SUPPL1
        STR_SUPPL2
        CITY1
        CITY2
        COUNTRY
        POST_CODE1
        TEL_NUMBER
        FROM ADRC INTO TABLE IT_ADRC1 FOR ALL ENTRIES IN IT_T001 WHERE ADDRNUMBER = IT_T001-ADRNR.
 ENDIF.

 LOOP AT IT_BSEG INTO WA_BSEG.
 SLNO = SLNO + 1.
 WA_ITEM-SLNO = SLNO.
 WA_ITEM-BELNR = WA_BSEG-BELNR.
 WA_ITEM-BUKRS = WA_BSEG-BUKRS.
 WA_ITEM-GJAHR = WA_BSEG-GJAHR.
 WA_ITEM-KOART = WA_BSEG-KOART.
 WA_ITEM-WRBTR = WA_BSEG-WRBTR.
 WA_ITEM-ZFBDT = WA_BSEG-ZFBDT.
 WA_ITEM-LIFNR = WA_BSEG-LIFNR.
 WA_ITEM-SGTXT = WA_BSEG-SGTXT.
 WA_ITEM-STCEG = WA_BSEG-STCEG.

 READ TABLE IT_BKPF INTO WA_BKPF WITH KEY BELNR = WA_BSEG-BELNR
                                          BUKRS = WA_BSEG-BUKRS
                                          GJAHR = WA_BSEG-GJAHR.
 IF SY-SUBRC = 0.
 WA_HEADER-BLDAT = WA_BKPF-BLDAT .
 WA_HEADER-CPUTM = WA_BKPF-CPUTM .
 WA_ITEM-BKTXT = WA_BKPF-BKTXT .
 ENDIF.

 READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_BSEG-LIFNR.
 IF SY-SUBRC = 0.
 WA_HEADER-LIFNR = WA_LFA1-LIFNR.
 WA_HEADER-LAND1 = WA_LFA1-LAND1.
 WA_HEADER-NAME1 = WA_LFA1-NAME1.
 WA_HEADER-ORT01 = WA_LFA1-ORT01.
 WA_HEADER-ORT02 = WA_LFA1-ORT02.
 WA_HEADER-PSTLZ = WA_LFA1-PSTLZ.
 WA_HEADER-STRAS = WA_LFA1-STRAS.
 WA_HEADER-ADRNR = WA_LFA1-ADRNR.
 WA_HEADER-WERKS = WA_LFA1-WERKS.
 ENDIF.

READ TABLE IT_T001 INTO WA_T001 WITH KEY BUKRS = WA_BSEG-BUKRS.
IF SY-SUBRC = 0.
 WA_ITEM-BUTXT = WA_T001-BUTXT .
 WA_ITEM-LAND1 = WA_T001-LAND1 .
 WA_ITEM-ORT01 = WA_T001-ORT01 .
 WA_ITEM-ADRNR = WA_T001-ADRNR .
 ENDIF.


 READ TABLE IT_ADRC INTO WA_ADRC WITH KEY ADDRNUMBER = WA_LFA1-ADRNR.
 IF SY-SUBRC = 0.
 WA_HEADER-VNAME1      = WA_ADRC-NAME1       .
 WA_HEADER-VHOUSE_NUM1 = WA_ADRC-HOUSE_NUM1  .
 WA_HEADER-VSTREET     = WA_ADRC-STREET      .
 WA_HEADER-VSTR_SUPPL1  = WA_ADRC-STR_SUPPL1.
 WA_HEADER-VSTR_SUPPL2  = WA_ADRC-STR_SUPPL2.
 WA_HEADER-VCITY1      = WA_ADRC-CITY1       .
 WA_HEADER-VCITY2      = WA_ADRC-CITY2       .
 WA_HEADER-VCOUNTRY    = WA_ADRC-COUNTRY     .
 WA_HEADER-VPOST_CODE1 = WA_ADRC-POST_CODE1  .
 WA_HEADER-VTEL_NUMBER = WA_ADRC-TEL_NUMBER  .
 ENDIF.

*READ TABLE IT_T001W INTO WA_T001W WITH KEY WERKS = WA_LFA1-WERKS.
*IF SY-SUBRC = 0.
* WA_ITEM-WERKS = WA_T001W-WERKS .
* WA_ITEM-NAME1 = WA_T001W-NAME1 .
* WA_ITEM-STRAS = WA_T001W-STRAS .
* WA_ITEM-PSTLZ = WA_T001W-PSTLZ .
* WA_ITEM-ORT01 = WA_T001W-ORT01 .
* WA_ITEM-LAND1 = WA_T001W-LAND1 .
* WA_ITEM-ADRNR = WA_T001W-ADRNR .
*ENDIF.

 READ TABLE IT_ADRC1 INTO WA_ADRC1 WITH KEY ADDRNUMBER = WA_T001-ADRNR.
 IF SY-SUBRC = 0.
 WA_ITEM-PNAME1      = WA_ADRC1-NAME1       .
 WA_ITEM-PHOUSE_NUM1 = WA_ADRC1-HOUSE_NUM1  .
 WA_ITEM-PSTREET     = WA_ADRC1-STREET      .
 WA_ITEM-PSTR_SUPPL1 = WA_ADRC1-STR_SUPPL1   .
 WA_ITEM-PSTR_SUPPL2 = WA_ADRC1-STR_SUPPL2   .
 WA_ITEM-PCITY1      = WA_ADRC1-CITY1       .
 WA_ITEM-PCITY2      = WA_ADRC1-CITY2       .
 WA_ITEM-PCOUNTRY    = WA_ADRC1-COUNTRY     .
 WA_ITEM-PPOST_CODE1 = WA_ADRC1-POST_CODE1  .
 WA_ITEM-PTEL_NUMBER = WA_ADRC1-TEL_NUMBER  .
 ENDIF.

LV_TOT = LV_TOT + WA_ITEM-WRBTR.
WA_ITEM-LV_TOT = LV_TOT.

 APPEND WA_ITEM TO IT_ITEM.
 CLEAR WA_ITEM.
 ENDLOOP.

 CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
   EXPORTING
     FORMNAME                 = 'ZVEND_DOWN_PAYMENT'
*    VARIANT                  = ' '
*    DIRECT_CALL              = ' '
  IMPORTING
    FM_NAME                  = FNAM
  EXCEPTIONS
    NO_FORM                  = 1
    NO_FUNCTION_MODULE       = 2
    OTHERS                   = 3
           .
 IF SY-SUBRC <> 0.
* Implement suitable error handling here
 ENDIF.





 CALL FUNCTION FNAM
   EXPORTING
*    ARCHIVE_INDEX              =
*    ARCHIVE_INDEX_TAB          =
*    ARCHIVE_PARAMETERS         =
*    CONTROL_PARAMETERS         =
*    MAIL_APPL_OBJ              =
*    MAIL_RECIPIENT             =
*    MAIL_SENDER                =
*    OUTPUT_OPTIONS             =
*    USER_SETTINGS              = 'X'
     WA_HEADER                  = WA_HEADER
*  IMPORTING
*    DOCUMENT_OUTPUT_INFO       =
*    JOB_OUTPUT_INFO            =
*    JOB_OUTPUT_OPTIONS         =
   TABLES
     IT_ITEM                    = IT_ITEM
  EXCEPTIONS
    FORMATTING_ERROR           = 1
    INTERNAL_ERROR             = 2
    SEND_ERROR                 = 3
    USER_CANCELED              = 4
    OTHERS                     = 5
           .
 IF SY-SUBRC <> 0.
* Implement suitable error handling here
 ENDIF.
