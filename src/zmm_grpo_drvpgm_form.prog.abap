**&---------------------------------------------------------------------*
**& Include          ZMM_GRPO_DRVPGM_FORM
**&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**& Form SELECT
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**& Include          ZMM_GRPO_DRVPGM_TOP
**&---------------------------------------------------------------------*
*
*
*FORM SELECT .
*
*
*  DATA: LV_QR_CODE TYPE ZINW_T_ITEM-QR_CODE .
*  IF LV_QR_CODE IS NOT INITIAL .
*    SELECT SINGLE EBELN
*           LIFNR
*           QR_CODE
*           TRNS
*           LR_NO
*           NO_BUD
*           GRPO_NO
*           GRPO_DATE
*           DUE_DATE
*       FROM ZINW_T_HDR INTO WA_ZINW_T_HDR
*               WHERE QR_CODE = LV_QR_CODE .
*
*  ENDIF.
*
*
*  IF IT_ZINW_T_HDR IS NOT INITIAL .
*
*    SELECT QR_CODE
*           EBELN
*           EBELP
*           SNO
*           MATNR
*           LGORT
*           WERKS
*           MENGE_P
*           MEINS
*           MAKTX
*           NETPR_P
*           NETWR_P
*        FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM
*          FOR ALL ENTRIES IN IT_ZINW_T_HDR
*           WHERE QR_CODE = IT_ZINW_T_HDR-QR_CODE.
*
*
*
*
*
*  ENDIF.
*
*  READ TABLE IT_ZINW_T_ITEM INTO WA_ZINW_T_ITEM INDEX 1 .
*  IF WA_ZINW_T_HDR IS NOT INITIAL.
*    SELECT SINGLE LIFNR
*                  LAND1
*                  NAME1
*                  STRAS
*                  ORT01
*                  STCD3
*                  REGIO FROM LFA1 INTO WA_LFA1
*                  WHERE LIFNR = WA_ZINW_T_HDR-LIFNR.
*  ENDIF.
*  IF WA_ZINW_T_ITEM  IS NOT INITIAL .
*    SELECT SINGLE  WERKS
*                   NAME1
*                   STRAS
*                   ORT01
*                   LAND1  FROM T001W INTO WA_T001W
*                   WHERE WERKS = WA_ZINW_T_ITEM-WERKS.
*
*    SELECT MATNR
*           SPRAS
*           MAKTX FROM MAKT INTO TABLE IT_MAKT
*           FOR ALL ENTRIES IN IT_ZINW_T_ITEM
*           WHERE MATNR = IT_ZINW_T_ITEM-MATNR.     "#EC CI_NO_TRANSFORM
*
*    ENDif.
*  IF WA_LFA1 IS NOT INITIAL .
*    SELECT SINGLE SPRAS
*                  LAND1
*                  BLAND
*                  BEZEI FROM T005U INTO WA_T005U
*                  WHERE SPRAS = 'EN'
*                  AND  LAND1 = WA_LFA1-LAND1
*                  AND BLAND = WA_LFA1-REGIO.
*
*
*  ENDIF.
*
*  IF IT_ZINW_T_ITEM IS NOT INITIAL.
*    select  EBELN
*            KNUMV from ekko into TABLE it_ekko
*            FOR ALL ENTRIES IN  IT_ZINW_T_ITEM
*            WHERE EBELN = IT_ZINW_T_ITEM-EBELN .
*
*
*  ENDIF.
*
*  IF IT_EKKO IS NOT INITIAL.
*    SELECT KNUMV
*           KPOSN
*           STUNR
*           ZAEHK
*           KSCHL
*           KBETR FROM KONV INTO TABLE IT_KONV
*           FOR ALL ENTRIES IN IT_EKKO
*           WHERE KNUMV = IT_EKKO-KNUMV.            "#EC CI_NO_TRANSFORM
*
*
*  ENDIF.
*
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form READ
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM READ .
*  DATA: LV_SLNO TYPE I,
*        LV1     TYPE STRING,
*        LV2     TYPE STRING,
*        LV3     TYPE STRING.
*
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form CALL_FUNC
*  WA_HEADER-V_LAND1 = WA_LFA1-LAND1 .
*  WA_HEADER-V_NAME1 = WA_LFA1-NAME1 .
*  WA_HEADER-V_STRAS = WA_LFA1-STRAS .
*  WA_HEADER-V_ORT01 = WA_LFA1-ORT01 .
*  WA_HEADER-V_STCD3 = WA_LFA1-STCD3 .
*  WA_HEADER-V_REGIO = WA_T005U-BEZEI.
*  WA_HEADER-NAME1 = WA_T001W-NAME1 .
*  WA_HEADER-STRAS = WA_T001W-STRAS .
*  WA_HEADER-ORT01 = WA_T001W-ORT01 .
*  WA_HEADER-LAND1 = WA_T001W-LAND1 .
*  WA_HEADER-EBELN = WA_MSEG-EBELN .
*  WA_HEADER-LIFNR = WA_MSEG-LIFNR .
*
*  LOOP AT IT_ZINW_T_ITEM INTO WA_ZINW_T_ITEM.
*
**    WA_HEADER-BLDAT = WA_MKPF-BLDAT.  "" dt
*    WA_FINAL-SLNO = LV_SLNO .
*    LV_SLNO = LV_SLNO + 1.
*    LV1 = WA_ZINW_T_ITEM-MENGE_P .
*    SPLIT LV1 AT '.' INTO LV3 LV2.
*    WA_FINAL-MENGE = LV3.
*
*    WA_FINAL-NETWR = WA_ZINW_T_ITEM-NETWR_P .
*    WA_FINAL-NETPR =  WA_ZINW_T_ITEM-NETPR_P.
*
*
*    READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_MSEG-MATNR .
*    IF SY-SUBRC = 0.
*      WA_FINAL-MAKTX = WA_MAKT-MAKTX .
*    ENDIF.
*
*
*
*    APPEND WA_FINAL TO IT_FINAL.
*    CLEAR WA_FINAL.
*  ENDLOOP.
*
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM CALL_FUNC .
*
*  DATA FMNAME TYPE RS38L_FNAM.
*
*  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*    EXPORTING
*      FORMNAME           = 'ZMM_GRPO_FORM'
**     VARIANT            = ' '
**     DIRECT_CALL        = ' '
*    IMPORTING
*      FM_NAME            = FMNAME
*    EXCEPTIONS
*      NO_FORM            = 1
*      NO_FUNCTION_MODULE = 2
*      OTHERS             = 3.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*  CALL FUNCTION FMNAME
*    EXPORTING
*      WA_HEADER = WA_HEADER
*    TABLES
*      IT_FINAL  = IT_FINAL.
*
*
*ENDFORM.
