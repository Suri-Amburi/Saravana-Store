*&---------------------------------------------------------------------*
*& Include          ZSD_SHIPMENT_PACKING_REP_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  SELECT
     VBELN
     WERKS FROM LIKP INTO TABLE IT_LIKP
     WHERE VBELN IN S_VBELN.  "nast-objky

    IF IT_LIKP IS NOT INITIAL.
      SELECT
        VBELN
        POSNR
        MATNR
        MATKL
        WERKS
        LFIMG
        ARKTX FROM LIPS INTO TABLE IT_LIPS
        FOR ALL ENTRIES IN IT_LIKP
        WHERE VBELN = IT_LIKP-VBELN.
    ENDIF.

    IF IT_LIPS IS NOT INITIAL.
*      SELECT
*        MATKL FROM T023 INTO TABLE IT_T023
*        FOR ALL ENTRIES IN IT_LIPS
*        WHERE MATKL = IT_LIPS-MATKL.
      SELECT
        MATNR
        MATKL FROM MARA INTO TABLE IT_MARA
        FOR ALL ENTRIES IN IT_LIPS
        WHERE MATNR = IT_LIPS-MATNR.

         SELECT
          VENUM
          VEPOS
          VBELN
          posnr FROM VEPO INTO TABLE IT_VEPO
          FOR ALL ENTRIES IN IT_LIPS
          WHERE VBELN = IT_LIPS-VBELN.
*          AND VENUM IN ('23' , '24').


    ENDIF.

   IF IT_VEPO IS NOT INITIAL.
      SELECT
        VENUM
        VHART FROM VEKP INTO TABLE IT_VEKP
        FOR ALL ENTRIES IN IT_VEPO
        WHERE VENUM = IT_VEPO-VENUM.
*        AND VENUM IN ('23' , '24').
    ENDIF.

   IF IT_VEKP IS NOT INITIAL.
      SELECT
        SPRAS
        TRATY
        VTEXT FROM TVTYT INTO TABLE IT_TVTYT
        FOR ALL ENTRIES IN IT_VEKP
        WHERE TRATY = IT_VEKP-VHART
        AND SPRAS = SY-LANGU.
     ENDIF.

*    IF IT_T023 IS NOT INITIAL.
*      SELECT
*        SPRAS
*        MATKL
*        WGBEZ FROM T023T INTO TABLE IT_T023T
*        FOR ALL ENTRIES IN IT_T023
*        WHERE MATKL = IT_T023-MATKL.
*    ENDIF.

    READ TABLE IT_LIKP INTO WA_LIKP INDEX 1.
    READ TABLE IT_LIPS INTO WA_LIPS INDEX 1.

    IF WA_LIPS IS NOT INITIAL.
      SELECT SINGLE
        WERKS
        NAME1
        LAND1
        REGIO
        ADRNR FROM T001W INTO WA_T001W
        WHERE WERKS = WA_LIPS-WERKS.
**
**
**        SELECT SINGLE
**          VENUM
**          VEPOS
**          VBELN FROM VEPO INTO WA_VEPO
**          FOR ALL ENTRIES IN IT_LIPS
**          WHERE VBELN = WA_LIPS-VBELN
**          AND   VENUM = '22'.

        SELECT SINGLE
          TKNUM
          TPNUM
          VBELN FROM VTTP INTO WA_VTTP
*          FOR ALL ENTRIES IN IT_LIPS
          WHERE VBELN = WA_LIPS-VBELN.

    ENDIF.

    IF WA_VTTP IS NOT INITIAL.
        SELECT SINGLE
          TKNUM
          SIGNI
          EXTI1
          EXTI2
          TPBEZ
          DTABF
          TEXT1
          TEXT2
          TEXT3 FROM VTTK INTO WA_VTTK
*          FOR ALL ENTRIES IN IT_VTTP
          WHERE TKNUM = WA_VTTP-TKNUM.
    ENDIF.


*    IF WA_VEPO IS NOT INITIAL.
*      SELECT SINGLE
*        VENUM
*        VHART FROM VEKP INTO WA_VEKP
*        FOR ALL ENTRIES IN IT_VEPO
*        WHERE VENUM = WA_VEPO-VENUM.
*    ENDIF.

*     IF WA_VEKP IS NOT INITIAL.
*      SELECT SINGLE
*        SPRAS
*        TRATY
*        VTEXT FROM TVTYT INTO WA_TVTYT
**        FOR ALL ENTRIES IN IT_VEKP
*        WHERE TRATY = WA_VEKP-VHART
*        AND SPRAS = SY-LANGU.
*     ENDIF.


    IF WA_LIKP IS NOT INITIAL.
      SELECT SINGLE
        WERKS
        NAME1
        LAND1
        REGIO
        ADRNR FROM T001W INTO WA_T001W_T
        WHERE WERKS = WA_LIKP-WERKS.
    ENDIF.

    IF WA_T001W_T IS NOT INITIAL.
      SELECT SINGLE
        BUKRS
        BRANCH
        GSTIN  FROM J_1BBRANCH INTO WA_J_1BBRANCH_T
        WHERE BRANCH = WA_T001W_T-J_1BBRANCH.

      SELECT SINGLE
        ADDRNUMBER
        NAME1
        CITY1
        POST_CODE1
        STREET
        HOUSE_NUM1
        STR_SUPPL1
        STR_SUPPL2
        STR_SUPPL3 FROM ADRC INTO WA_ADRC_T
        WHERE ADDRNUMBER = WA_T001W_T-ADRNR.
    ENDIF.

    IF WA_T001W IS NOT INITIAL.
      SELECT SINGLE
        BUKRS
        BRANCH
        GSTIN FROM J_1BBRANCH INTO WA_J_1BBRANCH
        WHERE BRANCH = WA_T001W-J_1BBRANCH.

      SELECT SINGLE
        ADDRNUMBER
        NAME1
        CITY1
        POST_CODE1
        STREET
        HOUSE_NUM1
        STR_SUPPL1
        STR_SUPPL2
        STR_SUPPL3 FROM ADRC INTO WA_ADRC
        WHERE ADDRNUMBER = WA_T001W-ADRNR.
    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOOP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM LOOP_DATA .

  LOOP AT it_lips INTO wa_lips.
    wa_final-ZSL_NO    = sy-tabix.
    WA_FINAL-SAP_DC_NO = WA_LIPS-POSNR.
    WA_FINAL-QUANTITY  = WA_LIPS-LFIMG.
    WA_FINAL-PRODUCT   = WA_LIPS-MATNR.
READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_LIPS-MATNR.

    CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
      EXPORTING
        MATKL             = WA_MARA-MATKL
       SPRAS              = SY-LANGU
      TABLES
        O_WGH01           = IT_WGH01
     EXCEPTIONS
       NO_BASIS_MG       = 1
       NO_MG_HIER        = 2
       OTHERS            = 3
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
    READ TABLE IT_WGH01 INTO WA_WGH01 INDEX 1.
    IF SY-SUBRC = 0.
      WA_FINAL-WWGHB = WA_WGH01-WWGHB.
    ENDIF.




*CLEAR: WA_T023, WA_T023T.
*READ TABLE IT_T023 INTO WA_T023 WITH KEY MATKL = WA_LIPS-MATKL.
*READ TABLE IT_T023T INTO WA_T023T WITH KEY MATKL = WA_T023T-MATKL.
*
*  IF SY-SUBRC = 0.
*    WA_FINAL-WGBEZ = WA_T023T-WGBEZ.
*  ENDIF.

  CLEAR:WA_VEPO, WA_VEKP,WA_TVTYT.
  READ TABLE IT_VEPO INTO WA_VEPO WITH KEY VBELN = WA_LIPS-VBELN POSNR = wa_lips-POSNR.
  READ TABLE IT_VEKP INTO WA_VEKP WITH KEY VENUM = WA_VEPO-VENUM.


  CASE WA_VEKP-VHART.
    WHEN '0004'.
    READ TABLE IT_TVTYT INTO WA_TVTYT WITH KEY TRATY = WA_VEKP-VHART SPRAS = SY-LANGU.
      WA_FINAL-TRAYS = WA_TVTYT-VTEXT.
       WA_FINAL-BUNDLES = 'Nill'.
      LV_TRAYS = LV_TRAYS + 1.
    WHEN '0005'.
    READ TABLE IT_TVTYT INTO WA_TVTYT WITH KEY TRATY = WA_VEKP-VHART SPRAS = SY-LANGU.
      WA_FINAL-BUNDLES = WA_TVTYT-VTEXT.
        WA_FINAL-TRAYS = 'Nill'.
      LV_BUNDLES = LV_BUNDLES + 1.
  ENDCASE.
  LV_TOTAL = LV_TRAYS +  LV_BUNDLES.

  APPEND WA_FINAL TO IT_FINAL.

  CLEAR: WA_FINAL.
  ENDLOOP.
  WA_HEADER-ADDRESS_TO      = WA_ADRC_T-ADDRNUMBER.
  WA_HEADER-NAME_TO         = WA_ADRC_T-NAME1.
  WA_HEADER-CITY_TO         = WA_ADRC_T-CITY1.
  WA_HEADER-POST_CODE_TO    = WA_ADRC_T-POST_CODE1.
  WA_HEADER-STREET_TO       = WA_ADRC_T-STREET.
  WA_HEADER-HOUSE_NUM_TO    = WA_ADRC_T-HOUSE_NUM1.
  WA_HEADER-GSTIN_TO        = WA_J_1BBRANCH_T-GSTIN.
  WA_HEADER-ADDRESS_FROM    = WA_ADRC-ADDRNUMBER.
  WA_HEADER-NAME_FROM       = WA_ADRC-NAME1.
  WA_HEADER-CITY_FROM       = WA_ADRC-CITY1.
  WA_HEADER-POST_CODE_FROM  = WA_ADRC-POST_CODE1.
  WA_HEADER-STREET_FROM     = WA_ADRC-STREET.
  WA_HEADER-HOUSE_NUM_FROM  = WA_ADRC-HOUSE_NUM1.
  WA_HEADER-GSTIN_FROM      = WA_J_1BBRANCH-GSTIN.
  WA_HEADER-DESP_DAT        = WA_VTTK-DTABF.
  WA_HEADER-GATE_NO         = WA_VTTK-TEXT3.
  WA_HEADER-LOT_NO          = WA_VTTK-TEXT1.
  WA_HEADER-TRANS_NAME      = WA_VTTK-TPBEZ.
  WA_HEADER-DR_NAME         = WA_VTTK-EXTI1.
  WA_HEADER-CON_NO          = WA_VTTK-EXTI2.
  WA_HEADER-VEH_NO          = WA_VTTK-SIGNI.
  WA_HEADER-SEAL_NO         = WA_VTTK-EXTI2.
  wa_header-NO_TRAYS        = LV_TRAYS.
  wa_header-NO_BUND         = LV_BUNDLES.
  wa_header-LV_TOTAL        = LV_TOTAL.
  wa_header-TOT_QTY         = WA_LIPS-LFIMG.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_FUNC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CAL_FUNC .

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    FORMNAME                 = 'ZSD_SHIPMENT_PACKING_LIST'
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
 IMPORTING
   FM_NAME                  = FM_NAME
 EXCEPTIONS
   NO_FORM                  = 1
   NO_FUNCTION_MODULE       = 2
   OTHERS                   = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION FM_NAME
    EXPORTING
      WA_HEADER        = WA_HEADER
      lv_trays         = lv_trays
      lv_bundles       = lv_bundles
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


ENDFORM.
