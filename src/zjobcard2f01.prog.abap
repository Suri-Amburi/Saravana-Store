*&---------------------------------------------------------------------*
*& Include          ZJOBCARD2F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form RETRIEVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RETRIEVE_DATA .
  SELECT EBELN
          BUKRS
          BSART
          AEDAT
          SPRAS
          LIFNR
          EKGRP
          BEDAT
          KNUMV
          APPROVER1
          FROM EKKO
          INTO TABLE IT_EKKO
          WHERE EBELN = P_EBELN." AND BSART = 'ZPRO' AND SPRAS = 'EN'.
  IF IT_EKKO IS NOT INITIAL.
    SELECT EBELN
           EBELP
           WERKS
           MATNR
           MWSKZ
           MENGE
           MEINS
           NETPR
           PEINH
           ZZSET_MATERIAL
           NETWR
           BUKRS
           RETPO FROM EKPO
           INTO TABLE IT_EKPO
           FOR ALL ENTRIES IN IT_EKKO
          WHERE EBELN = IT_EKKO-EBELN.
    SELECT LIFNR
           LAND1
           NAME1
           ORT01
           REGIO
           STRAS
           STCD3
           ADRNR
           FROM LFA1 INTO TABLE IT_LFA1
        FOR ALL ENTRIES IN IT_EKKO
          WHERE LIFNR = IT_EKKO-LIFNR.
  ENDIF.
  IF IT_EKPO IS NOT INITIAL.
    SELECT WERKS
           NAME1
           STRAS
           ORT01
           LAND1
           ADRNR
           FROM T001W INTO TABLE IT_T001W
           FOR ALL ENTRIES IN IT_EKPO
           WHERE WERKS = IT_EKPO-WERKS.

    SELECT MATNR
           EAN11
           MATKL FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_EKPO
           WHERE MATNR = IT_EKPO-MATNR.
    SELECT MATNR
           SPRAS
           MAKTX
           FROM MAKT INTO TABLE IT_MAKT
           FOR ALL ENTRIES IN IT_EKPO
           WHERE MATNR = IT_EKPO-MATNR.
      ENDIF.
  SELECT ADDRNUMBER
         NAME1
         CITY1
         STREET
         STR_SUPPL1
         STR_SUPPL2
         COUNTRY
         LANGU
         REGION
         POST_CODE1
         FROM ADRC
         INTO TABLE IT_ADRC
         FOR ALL ENTRIES IN IT_T001W
         WHERE ADDRNUMBER = IT_T001W-ADRNR.

  IF IT_EKKO IS NOT INITIAL .
    SELECT BUKRS
           ADRNR
           FROM T001
           INTO TABLE IT_T001
           FOR ALL ENTRIES IN IT_EKKO
           WHERE BUKRS = IT_EKKO-BUKRS.
*
    SELECT BUKRS
           GSTIN
           FROM J_1BBRANCH
           INTO TABLE IT_J_1BBRANCH
           FOR ALL ENTRIES IN IT_EKKO
           WHERE BUKRS = IT_EKKO-BUKRS.
*
    SELECT EKNAM
           EKGRP
           FROM T024
           INTO TABLE IT_T024
           FOR ALL ENTRIES IN IT_EKKO
           WHERE EKGRP = IT_EKKO-EKGRP.
  ENDIF.
  SELECT MBLNR
         MJAHR
         XAUTO
         MATNR
         MENGE
         EBELN
         EBELP
         BWART
         BUDAT_MKPF
         USNAM_MKPF
         FROM MSEG
         INTO TABLE IT_MSEG
        FOR ALL ENTRIES IN IT_EKPO
        WHERE EBELP = IT_EKPO-EBELP AND EBELN = IT_EKPO-EBELN AND BWART = '101' AND XAUTO = ' '.

  READ TABLE IT_EKKO INTO WA_EKKO INDEX 1.
  WA_HDR-EBELN = WA_EKKO-EBELN.
  WA_HDR-BEDAT = WA_EKKO-BEDAT.
  WA_HDR-APPROVER1 = WA_EKKO-APPROVER1.
  READ TABLE it_mseg INTO wa_mseg INDEX 1.
  wa_hdr-USNAM_MKPF = wa_mseg-USNAM_MKPF.
  READ TABLE IT_ADRC INTO WA_ADRC INDEX 1." WITH KEY ADDRNUMBER = WA_T001W-ADRNR.
  WA_HDR-ADDRNUMBER = WA_ADRC-ADDRNUMBER.
  WA_HDR-NAME1       = WA_ADRC-NAME1        .
  WA_HDR-CITY1       = WA_ADRC-CITY1        .
  WA_HDR-STREET      = WA_ADRC-STREET       .
  WA_HDR-STR_SUPPL1  = WA_ADRC-STR_SUPPL1   .
  WA_HDR-STR_SUPPL2  = WA_ADRC-STR_SUPPL2   .
  WA_HDR-COUNTRY     = WA_ADRC-COUNTRY      .
  WA_HDR-LANGU       = WA_ADRC-LANGU        .
  WA_HDR-REGION      = WA_ADRC-REGION       .
  WA_HDR-POST_CODE1  = WA_ADRC-POST_CODE1   .
  READ TABLE IT_LFA1 INTO WA_LFA1  INDEX 1.
  WA_HDR-V_LIFNR    =   WA_LFA1-LIFNR   .
  WA_HDR-V_LAND1    =   WA_LFA1-LAND1   .
  WA_HDR-V_NAME1    =   WA_LFA1-NAME1   .
  WA_HDR-V_ORT01    =   WA_LFA1-ORT01   .
  WA_HDR-V_REGIO    =   WA_LFA1-REGIO   .
  WA_HDR-V_STRAS    =   WA_LFA1-STRAS   .
  WA_HDR-V_STCD3    =   WA_LFA1-STCD3   .
  WA_HDR-V_ADRNR    =   WA_LFA1-ADRNR   .
  READ TABLE IT_J_1BBRANCH INTO WA_J_1BBRANCH INDEX 1.
  WA_HDR-GSTIN     =  WA_J_1BBRANCH-GSTIN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DATA .
  LOOP AT IT_EKPO INTO WA_EKPO.
    SL_NO = SL_NO + 1.
    WA_ZMAIN-SL_NO = SL_NO.
    WA_ZMAIN-MENGE = WA_EKPO-MENGE.
    WA_ZMAIN-MEINS = WA_EKPO-MEINS.

    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_EKPO-MATNR.
    IF SY-SUBRC = 0 .
      WA_ZMAIN-MATNR = WA_MARA-MATNR.
      WA_ZMAIN-MATKL = WA_MARA-MATKL.
      WA_ZMAIN-EAN11 = WA_MARA-EAN11.
    ENDIF.
    READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_EKPO-MATNR.
    IF SY-SUBRC = 0.
      WA_ZMAIN-MAKTX = WA_MAKT-MAKTX.
    ENDIF .

    LOOP AT IT_MSEG INTO WA_MSEG WHERE EBELN = WA_EKPO-EBELN AND EBELP = WA_EKPO-EBELP.
      IF SY-SUBRC = 0.
        WA_ZMAIN-R_QTY = WA_ZMAIN-R_QTY + WA_MSEG-MENGE.
      ENDIF.
    ENDLOOP.

    TOT_QTY = TOT_QTY + WA_EKPO-MENGE.
    WA_ZMAIN-TOT_QTY = TOT_QTY.

    APPEND WA_ZMAIN TO IT_ZMAIN .
    CLEAR : WA_ZMAIN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZJOB_CARD2'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = F_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
  QR_CODE = P_EBELN.
  CALL FUNCTION F_NAME
    EXPORTING
      WA_HDR           = WA_HDR
      QR_CODE          = QR_CODE
    TABLES
      IT_ITEM          = IT_ZMAIN
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      USER_CANCELED    = 4
      OTHERS           = 5.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
