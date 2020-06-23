*&---------------------------------------------------------------------*
*& Report ZSD_DELIVERY_NOTE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSD_DELIVERY_NOTE.
**********************Type Declaration***************


TYPES: BEGIN OF TY_LIPS,
       VBELN TYPE VBELN_VL,   """"Delivery
       POSNR TYPE POSNR_VL,   """"Delivery Item
       MATNR TYPE MATNR,      """"Material Number
       LFIMG TYPE LFIMG,      """"Actual quantity delivered (in sales units)
       WERKS TYPE WERKS_D,    """"Plant
       MTART TYPE MTART,      "Material type
       ARKTX TYPE	ARKTX,
*       EANNR TYPE  EANNR,

       END OF TY_LIPS.

TYPES: BEGIN OF TY_LIKP,
       VBELN TYPE VBELN_VL,   """"Delivery
       WERKS TYPE EMPFW,      """"Receiving Plant for Deliveries
       KUNNR TYPE KUNWE,      """"Ship-to party
       BLDAT TYPE	BLDAT,
       KNUMV TYPE	KNUMV,
       END OF TY_LIKP.

TYPES: BEGIN OF TY_ADRC,
       ADDRNUMBER TYPE AD_ADDRNUM,   """""Address number
       DATE_FROM  TYPE AD_DATE_FR,   """""Valid-from date
       NATION     TYPE AD_NATION,    """""Version ID for International Addresses
       HOUSE_NUM1	TYPE AD_HSNM1,
       STREET	    TYPE AD_STREET,
       post_code1 TYPE AD_PSTCD1,
       END OF TY_ADRC.

TYPES: BEGIN OF ty_mara,
       matnr TYPE matnr,     "Material Number
       ean11 TYPE ean11,     "International Article Number
       END OF ty_mara.

TYPES: BEGIN OF ty_t001w,
       WERKS      TYPE  WERKS_D,     "Plant
       NAME1      TYPE  NAME1,       "Name
       STRAS      TYPE  STRAS,       "Street and House Number
       PSTLZ      TYPE  PSTLZ,       "Postal Code
       ORT01      TYPE  ORT01,       "City
       LAND1      TYPE  LAND1,       "Country Key
       REGIO      TYPE  REGIO,
       ADRNR      TYPE  ADRNR,
       KUNNR      TYPE KUNNR,
       END OF ty_t001w.

TYPES: BEGIN OF ty_kna1,
       KUNNR TYPE KUNNR,
       STCD3 TYPE	STCD3,
       END OF ty_kna1.

TYPES: BEGIN OF TY_prcd_elements,
       KNUMV TYPE	KNUMV,
       KPOSN TYPE	KPOSN,
       STUNR TYPE	STUNR,
       ZAEHK TYPE	VFPRC_COND_COUNT,
       KBETR TYPE	VFPRC_ELEMENT_AMOUNT,
       END OF TY_prcd_elements.



DATA: IT_LIPS TYPE TABLE OF TY_LIPS,
      WA_LIPS TYPE TY_LIPS,
      IT_LIKP TYPE TABLE OF TY_LIKP,
      WA_LIKP TYPE TY_LIKP,
      WA_t001w TYPE TY_t001w,
      WA_t001w_t TYPE TY_t001w,
      WA_ADRC TYPE TY_ADRC,
      WA_ADRC_t TYPE TY_ADRC,
      IT_MARA TYPE TABLE OF TY_MARA,
      WA_MARA TYPE TY_MARA,
      IT_prcd_elements TYPE TABLE OF TY_prcd_elements,
      WA_prcd_elements TYPE TY_prcd_elements,
*      IT_J_1BBRANCH TYPE TABLE OF TY_J_1BBRANCH,
      WA_KNA1 TYPE TY_KNA1,
      IT_FINAL  TYPE TABLE OF ZFINAL1,
      WA_FINAL  TYPE ZFINAL1,
      WA_HEADER TYPE ZHEADER.

data:
      lv_qty1(10) TYPE c,
      lv_qty(10) TYPE c,
      lv_line(10) TYPE c,
      lv_dec type p DECIMALS 2.
*      lv1(10) TYPE c,
*      lv2(10) TYPE c,
*      lv3(10) TYPE c.
*

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS: p_vbeln TYPE vbeln OBLIGATORY.


SELECTION-SCREEN: END OF BLOCK b1.


**********select query*********

select
  VBELN
  WERKS
  KUNNR
  BLDAT
  KNUMV FROM likp into TABLE it_likp
        WHERE vbeln = p_vbeln.

  read TABLE it_likp INTO wa_likp INDEX 1.

  if it_likp is NOT INITIAL.
    select
      VBELN
      POSNR
      MATNR
      LFIMG
      WERKS
      MTART
      ARKTX
      FROM lips INTO TABLE it_lips
            FOR ALL ENTRIES IN it_likp
            WHERE vbeln = it_likp-vbeln.
    endif.
       read TABLE it_lips INTO wa_lips INDEX 1.

   IF IT_LIPS IS NOT INITIAL.
     SELECT
       MATNR
       EAN11 FROM MARA INTO TABLE IT_MARA
             FOR ALL ENTRIES IN IT_LIPS
             WHERE MATNR = IT_LIPS-MATNR.

       ENDIF.


    if wa_likp is not INITIAL.
      select SINGLE
       WERKS
       NAME1
       STRAS
       PSTLZ
       ORT01
       LAND1
       REGIO
       ADRNR
       KUNNR      FROM t001w INTO wa_t001w_t
                  WHERE werks = wa_likp-werks.

   endif.

   if wa_lips is not INITIAL.
      select SINGLE
       WERKS
       NAME1
       STRAS
       PSTLZ
       ORT01
       LAND1
       REGIO
       ADRNR
       KUNNR     FROM t001w INTO wa_t001w
                  WHERE werks = wa_lips-werks.

   endif.

   if wa_t001w is NOT INITIAL.
    SELECT SINGLE

      KUNNR
      STCD3 FROM KNA1 INTO WA_KNA1
            WHERE KUNNR = WA_T001W-KUNNR.

      SELECT SINGLE
        ADDRNUMBER
        DATE_FROM
        NATION
        HOUSE_NUM1
        STREET     FROM adrc INTO wa_adrc
                   WHERE ADDRNUMBER = wa_t001w-adrnr.
  ENDIF.
clear wa_KNA1.
  if wa_t001w_t is NOT INITIAL.
    SELECT SINGLE
      KUNNR
      STCD3 FROM KNA1 INTO WA_KNA1
            WHERE KUNNR = WA_T001W_t-KUNNR.

      SELECT SINGLE
        ADDRNUMBER
        DATE_FROM
        NATION
        HOUSE_NUM1
        STREET
        post_code1  FROM adrc INTO wa_adrc_t
                   WHERE ADDRNUMBER = wa_t001w_t-adrnr.


  ENDIF.

  if it_likp is NOT INITIAL.
    SELECT
      KNUMV
      KPOSN
      STUNR
      ZAEHK
      KBETR FROM prcd_elements INTO TABLE it_prcd_elements
            FOR ALL ENTRIES IN it_likp
            WHERE knumv = it_likp-knumv.
  endif.

***********looping statement**************
  loop at it_lips INTO wa_lips.

    WA_FINAL-SL_no = SY-TABIX.
    wa_final-DESCRIPTION = wa_lips-arktx.
    lv_dec = wa_lips-lfimg.
    wa_final-quantity = lv_dec.

    clear lv_dec.

*     CLEAR: LV1, LV2, LV3.
*    LV1 = WA_lips-lfimg.
*    SPLIT LV1 AT '.' INTO LV2 LV3.
*    WA_FINAL-quantity = LV2.
    CONDENSE WA_FINAL-quantity.

    LV_QTY = LV_QTY + WA_FINAL-quantity.
    lv_dec = lv_qty.
    lv_qty1 = lv_dec.
    CONDENSE LV_QTY1.

    clear wa_likp.
    READ TABLE it_likp INTO wa_likp with KEY vbeln = wa_lips-vbeln.

    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_LIPS-MATNR.
    IF SY-SUBRC = 0.
    wa_final-barcode = wa_MARA-EAN11.
    ENDIF.

    READ TABLE it_prcd_elements INTO wa_prcd_elements with key knumv = wa_likp-knumv.
    if sy-subrc = 0.
    wa_final-selling_price = wa_prcd_elements-kbetr.
    endif.

    wa_final-line_total = wa_final-selling_price * wa_final-quantity.
    lv_line = lv_line + wa_final-line_total.

   append wa_final to it_final.
    ENDLOOP.

     WA_HEADER-DC_NO = WA_LIKP-VBELN.
     WA_HEADER-DATE  = WA_LIKP-BLDAT.
     WA_HEADER-PRINT_DATE = WA_LIKP-BLDAT.
     WA_HEADER-NAME_TO = wa_t001w_t-name1.
     WA_HEADER-STRAS_TO = wa_t001w_t-stras.
     WA_HEADER-CITY_TO =  wa_t001w_t-ort01.
     WA_HEADER-POSTAL_CODE_TO =  wa_t001w_t-pstlz.
     WA_HEADER-GSTIN_TO = wa_KNA1-STCD3.
     WA_HEADER-HOUSE_NUMBER_TO = wa_adrc_t-HOUSE_NUM1.
     WA_HEADER-STREET_TO = wa_adrc_t-STREET .
     WA_HEADER-POST_CODE1_TO = wa_adrc_t-post_code1.


     WA_HEADER-NAME_from = wa_t001w-name1.
     WA_HEADER-STRAS_from = wa_t001w-stras.
     WA_HEADER-CITY_from =  wa_t001w-ort01.
     WA_HEADER-POSTAL_CODE_from =  wa_t001w-pstlz.
     WA_HEADER-GSTIN_from = wa_KNA1-STCD3.
     WA_HEADER-HOUSE_NUMBER_from = wa_adrc-HOUSE_NUM1.
     WA_HEADER-STREET_from = wa_adrc-STREET .
     WA_HEADER-POST_CODE1_from = wa_adrc-post_code1.






DATA: FM_NAME TYPE  RS38L_FNAM.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZSD_DELIVERY_CHALLAN'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION FM_NAME
    EXPORTING
      WA_HEADER        = WA_HEADER
      LV_QTY1          = LV_QTY1
      LV_LINE          = LV_LINE
    TABLES
      IT_FINAL         = IT_FINAL
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      USER_CANCELED    = 4
      OTHERS           = 5.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
