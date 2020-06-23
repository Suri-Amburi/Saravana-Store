*&---------------------------------------------------------------------*
*& Report ZMMS_GRPO_PRICE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMMS_GRPO_PRICE.

*TYPES: BEGIN OF TY_FINAL,
*       QR_CODE   TYPE ZINW_T_HDR-QR_CODE,
*        LIFNR     TYPE ZINW_T_HDR-LIFNR,
*        NAME1     TYPE ZINW_T_HDR-NAME1,
*        BILL_NUM  TYPE ZINW_T_HDR-BILL_NUM,
*        BILL_DATE TYPE ZINW_T_HDR-BILL_DATE,
*        GRPO_NO   TYPE ZINW_T_HDR-GRPO_NO,
*        GRPO_DATE TYPE ZINW_T_HDR-GRPO_DATE,
*        MBLNR     TYPE ZINW_T_HDR-MBLNR,
*  CITY1      TYPE ADRC-CITY1,
*        CITY2      TYPE ADRC-CITY2,
*        POST_CODE1 TYPE ADRC-POST_CODE1,
*        STREET     TYPE ADRC-STREET,
*        COUNTY     TYPE ADRC-COUNTY,
*        WERKS   TYPE ZINW_T_ITEM-WERKS,
*        MAKTX   TYPE ZINW_T_ITEM-MAKTX,
*        MENGE   TYPE ZINW_T_ITEM-MENGE,
*        MEINS   TYPE ZINW_T_ITEM-MEINS,
*        NETPR_P TYPE ZINW_T_ITEM-NETPR_P,
*        NETWR_P TYPE ZINW_T_ITEM-NETWR_P,
*        MARGN   TYPE ZINW_T_ITEM-MARGN,
*        NETPR_S TYPE ZINW_T_ITEM-NETPR_S,
*        NETWR_S TYPE ZINW_T_ITEM-NETWR_S,
*        TAXNUM  TYPE DFKKBPTAXNUM-TAXNUM,
*        adrnr TYPE lfa1-adrnr,
*        ort01 TYPE lfa1-ort01,
*        pstlz TYPE lfa1-pstlz,
*END OF TY_FINAL.

TYPES: BEGIN OF TY_ZINW_T_HDR,
         QR_CODE   TYPE ZINW_T_HDR-QR_CODE,
         LIFNR     TYPE ZINW_T_HDR-LIFNR,
         NAME1     TYPE ZINW_T_HDR-NAME1,
         BILL_NUM  TYPE ZINW_T_HDR-BILL_NUM,
         BILL_DATE TYPE ZINW_T_HDR-BILL_DATE,
         GRPO_NO   TYPE ZINW_T_HDR-GRPO_NO,
         GRPO_DATE TYPE ZINW_T_HDR-GRPO_DATE,
         MBLNR     TYPE ZINW_T_HDR-MBLNR,
         QR_DATE TYPE zinw_T_hdr-QR_DATE,
       END OF TY_ZINW_T_HDR.

TYPES: BEGIN OF TY_ZINW_T_ITEM,
         QR_CODE TYPE ZINW_T_ITEM-QR_CODE,
         MATNR   TYPE ZINW_T_ITEM-MATNR,
         WERKS   TYPE ZINW_T_ITEM-WERKS,
         MAKTX   TYPE ZINW_T_ITEM-MAKTX,
         MENGE   TYPE ZINW_T_ITEM-MENGE,
         MEINS   TYPE ZINW_T_ITEM-MEINS,
         NETPR_P TYPE ZINW_T_ITEM-NETPR_P,
         NETWR_P TYPE ZINW_T_ITEM-NETWR_P,
         MARGN   TYPE ZINW_T_ITEM-MARGN,
         NETPR_S TYPE ZINW_T_ITEM-NETPR_S,
         NETWR_S TYPE ZINW_T_ITEM-NETWR_S,

       END OF TY_ZINW_T_ITEM.

TYPES: BEGIN OF TY_LFA1,
         LIFNR TYPE LFA1-LIFNR,
         land1 TYPE lfa1-land1,
         ort01 TYPE LFA1-ORT01,
         NAME1 TYPE LFA1-NAME1,
         stras TYPE lfa1-stras,
         PSTLZ TYPE LFA1-PSTLZ,
         ADRNR TYPE LFA1-ADRNR,
         stcd3 TYPE lfa1-stcd3,
       END OF TY_LFA1.
*
*TYPES: BEGIN OF TY_DFKKBPTAXNUM,
*         PARTNER TYPE DFKKBPTAXNUM-PARTNER,
*         TAXTYPE TYPE DFKKBPTAXNUM-TAXTYPE,
*         TAXNUM  TYPE DFKKBPTAXNUM-TAXNUM,
*       END OF TY_DFKKBPTAXNUM.

TYPES: BEGIN OF Ty_MSEG,
        MBLNR TYPE MSEG-MBLNR,
        matnr TYPE mseg-matnr,
        CHARG TYPE MSEG-CHARG,
        budat_mkpf TYPE mseg-budat_mkpf,
      END OF Ty_MSEG.

TYPES: BEGIN OF Ty_ADRC,
        ADDRNUMBER TYPE ADRC-ADDRNUMBER,
        HOUSE_NUM1 TYPE ADRC-HOUSE_NUM1,
        STR_SUPPL1 TYPE ADRC-STR_SUPPL1,
        STR_SUPPL2 TYPE ADRC-STR_SUPPL2,
        TIME_ZONE  TYPE ADRC-TIME_ZONE,
      END OF Ty_ADRC.





PARAMETERS: P_QRCODE TYPE ZINW_T_HDR-QR_CODE.
data  SNO     TYPE CHAR4.
DATA: IT_ITEM1 TYPE TABLE OF TY_ZINW_T_ITEM,
      WA_ITEM1 TYPE TY_ZINW_T_ITEM,
      IT_HDR1  TYPE TABLE OF TY_ZINW_T_HDR,
      WA_HDR1  TYPE TY_ZINW_T_HDR,
      IT_Mseg  TYPE TABLE OF TY_Mseg,
      WA_Mseg  TYPE TY_Mseg,
      IT_ADRC  TYPE TABLE OF TY_ADRC,
      WA_ADRC  TYPE TY_ADRC,
*      WA_MSEG  TYPE TY_MSEG,
      IT_LFA1  TYPE TABLE OF TY_LFA1,
      WA_LFA1  TYPE TY_LFA1.
*      IT_GST   TYPE TABLE OF TY_DFKKBPTAXNUM,
*      WA_GST   TYPE TY_DFKKBPTAXNUM.

DATA: "it_final TYPE TABLE OF ty_final,
  "wa_final TYPE ty_final,
  IT_ITEM TYPE TABLE OF ZITEM,
  WA_ITEM TYPE ZITEM,
  IT_HDR  TYPE TABLE OF ZHDR,
  WA_HDR  TYPE ZHDR.


DATA: V_FNAME TYPE RS38L_FNAM.

START-OF-SELECTION.
  PERFORM GET_DATA.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME = 'ZMMS_GRPO'
*     VARIANT  = ' '
*     DIRECT_CALL              = ' '
    IMPORTING
      FM_NAME  = V_FNAME
* EXCEPTIONS
*     NO_FORM  = 1
*     NO_FUNCTION_MODULE       = 2
*     OTHERS   = 3
    .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
 CALL FUNCTION V_FNAME       "'/1BCDWB/SF00000027'
   EXPORTING
     P_QRCODE                   = P_QRCODE
     WA_HDR                     = WA_HDR
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

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
* BREAK-POINT.
  SELECT  QR_CODE
          LIFNR
          NAME1
          BILL_NUM
          BILL_DATE
          GRPO_NO
          GRPO_DATE
          MBLNR
          QR_DATE      FROM ZINW_T_HDR INTO TABLE IT_HDR1 WHERE QR_CODE = P_QRCODE.

  IF IT_HDR1 IS NOT INITIAL .

    SELECT  QR_CODE
            MATNR
            WERKS
            MAKTX
            MENGE
            MEINS
            NETPR_P
            NETWR_P
            MARGN
            NETPR_S
            NETWR_S
             FROM ZINW_T_ITEM INTO TABLE IT_ITEM1 FOR ALL ENTRIES IN IT_HDR1 WHERE QR_CODE = IT_HDR1-QR_CODE.

    SELECT LIFNR land1
      ort01
      NAME1
      stras
      PSTLZ
      ADRNR
      stcd3 FROM LFA1 INTO TABLE IT_LFA1 FOR ALL ENTRIES IN IT_HDR1 WHERE LIFNR = IT_HDR1-LIFNR.


SELECT mblnr matnr charg budat_mkpf FROM mseg INTO TABLE it_mseg FOR ALL ENTRIES IN it_HDR1 WHERE mBLNr = it_HDR1-mBLNr.
  ENDIF.

  IF IT_LFA1 IS  NOT INITIAL.
    SELECT ADDRNUMBER
           HOUSE_NUM1
           STR_SUPPL1
           STR_SUPPL2
           TIME_ZONE
        FROM ADRC INTO TABLE IT_ADRC FOR ALL ENTRIES IN IT_LFA1 WHERE ADDRNUMBER = IT_LFA1-ADRNR.
*
*    SELECT  PARTNER
*            TAXTYPE
*            TAXNUM  FROM DFKKBPTAXNUM INTO TABLE IT_GST FOR ALL ENTRIES IN IT_LFA1 WHERE PARTNER = IT_LFA1-LIFNR.

  ENDIF.
*BREAK AIMRAN.
*if it_item1 is NOT INITIAL.

*SELECT mblnr matnr charg FROM mseg INTO TABLE it_mseg FOR ALL ENTRIES IN it_item1 WHERE matnr = it_item1-matnr.
*endif.

  LOOP AT  IT_ITEM1 INTO WA_ITEM1.
*
    WA_ITEM-QR_CODE   = WA_ITEM1-QR_CODE.
*          wa_final-MATNR   = wa_item1-matnr.
 SNO = SNO + 1.

    wa_item-sno = sno.
    WA_ITEM-WERKS   = WA_ITEM1-WERKS.
    WA_ITEM-MAKTX   = WA_ITEM1-MAKTX.
    WA_ITEM-MENGE   = WA_ITEM1-MENGE.
    WA_ITEM-MEINS   = WA_ITEM1-MEINS.
    WA_ITEM-NETPR_P   = WA_ITEM1-NETPR_P.
    WA_ITEM-NETWR_P   = WA_ITEM1-NETpR_P * WA_ITEM1-MENGE.
    WA_ITEM-MARGN   = WA_ITEM1-MARGN.
    WA_ITEM-NETPR_S   = WA_ITEM1-NETPR_S .
    WA_ITEM-NETWR_S   = WA_ITEM1-NETpR_S * WA_ITEM1-MENGE.

    READ TABLE IT_HDR1 INTO WA_HDR1 WITH KEY QR_CODE = WA_ITEM1-QR_CODE.

    IF SY-SUBRC = 0.
      WA_HDR-QR_CODE = WA_HDR1-QR_CODE.
*      WA_HDR-LIFNR      = WA_HDR1-LIFNR.
      WA_HDR-BILL_NUM   = WA_HDR1-BILL_NUM.
      WA_HDR-BILL_DATE   = WA_HDR1-BILL_DATE.
      WA_HDR-GRPO_NO   = WA_HDR1-GRPO_NO.
      WA_HDR-GRPO_DATE   = WA_HDR1-GRPO_DATE.
  wa_hdr-MBLNR   = wa_hdr1-mblnr.
 wa_hdr-QR_DATE = wa_hdr1-QR_DATE.

*  wa_final-LIFNR      = wa_hdr1-lifnr.
*    wa_final-MBLNR   = wa_hdr1-mblnr.
    ENDIF.

    READ TABLE IT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_HDR1-LIFNR.
    IF SY-SUBRC = 0.
*wa_final-adrnr = wa_lfa1-adrnr.
*wa_final-ort01 = wa_lfa1-ort01.

      WA_HDR-NAME1   = WA_LFA1-NAME1.
      WA_HDR-PSTLZ = WA_LFA1-PSTLZ.
      WA_HDR-ort01 = WA_LFA1-ort01.
      wa_hdr-land1 = wa_lfa1-land1.
      wa_hdr-stras = wa_lfa1-stras.
      wa_hdr-stcd3  = wa_lfa1-stcd3.
*           wa_hdr-CITY2  = wa_adrc-city2.
    ENDIF.
*
*  READ TABLE it_mseg INTO wa_mseg with KEY matnr = wa_item1-matnr.
*BREAK AIMRAN.
  READ TABLE it_mseg INTO wa_mseg with KEY mBLnr = wa_HDR1-MBLNR.
  if sy-subrc = 0.
    wa_item-charg = wa_mseg-charg.
    wa_hdr-budat_mkpf = wa_mseg-budat_mkpf.
    endif.
    READ TABLE IT_ADRC INTO WA_ADRC WITH KEY ADDRNUMBER = WA_LFA1-ADRNR.
    IF SY-SUBRC = 0.
      WA_HDR-TIME_ZONE = WA_ADRC-TIME_ZONE.
      WA_HDR-HOUSE_NUM1 = WA_ADRC-HOUSE_NUM1.
      WA_HDR-STR_SUPPL1 = WA_ADRC-STR_SUPPL1.
      WA_HDR-STR_SUPPL2 = WA_ADRC-STR_SUPPL2.

    ENDIF.

*    READ TABLE IT_GST INTO WA_GST WITH KEY PARTNER = WA_LFA1-LIFNR.
*
*    IF SY-SUBRC = 0.
*      WA_HDR-TAXNUM = WA_GST-TAXNUM.
*    ENDIF.
    APPEND: WA_ITEM TO IT_ITEM.
    CLEAR :WA_ITEM.




  ENDLOOP.

ENDFORM.
