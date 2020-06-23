*&---------------------------------------------------------------------*
*& Include          ZFI_CASH_PAYMENT_F50_FRM
*&---------------------------------------------------------------------*

FORM GET_DATA .
  SELECT COMP_CODE
          CAJO_NUMBER
          FISC_YEAR
          POSTING_NUMBER
          BP_NAME
          POSTING_DATE
          D_POSTING_NUMB
     FROM TCJ_DOCUMENTS
     INTO TABLE GT_TCJ_DOCUMENTS
     WHERE COMP_CODE = P_BUKRS
       AND FISC_YEAR = P_GJAHR
       AND POSTING_NUMBER IN S_BELNR.

  IF GT_TCJ_DOCUMENTS IS NOT INITIAL.
    READ TABLE GT_TCJ_DOCUMENTS INTO WA_TCJ_DOCUMENTS INDEX 1.

    CONCATENATE WA_TCJ_DOCUMENTS-POSTING_NUMBER WA_TCJ_DOCUMENTS-CAJO_NUMBER WA_TCJ_DOCUMENTS-COMP_CODE INTO V_STR.

    SELECT BUKRS
           BELNR
           GJAHR
           BUZEI
           SHKZG
           HKONT
           DMBTR
           SGTXT
           AWKEY
           WERKS
           GSBER
           FROM BSEG
           INTO TABLE GT_BSEG
*           FOR ALL ENTRIES IN gt_tcj_documents
           WHERE AWKEY = V_STR " belnr = gt_tcj_documents-posting_number
*           AND shkzg = 'S'
           AND BUKRS = P_BUKRS
           AND GJAHR = P_GJAHR
           AND SHKZG = 'S'.

    SELECT BUKRS
          BELNR
          GJAHR
          BUDAT
          BKTXT
          WAERS
          AWKEY
          XBLNR FROM BKPF INTO TABLE GT_BKPF
*                 FOR ALL ENTRIES IN gt_bseg" gt_tcj_documents
                          WHERE AWKEY = V_STR ."belnr = gt_tcj_documents-posting_number.

  ENDIF.

  IF GT_BSEG IS NOT INITIAL.

    SORT GT_BSEG BY BUKRS BELNR GJAHR.

    READ TABLE GT_BSEG INTO WA_BSEG INDEX 1.

    SELECT SAKNR
           SPRAS
           TXT20
           TXT50
           FROM SKAT
           INTO TABLE GT_SKAT FOR ALL ENTRIES IN GT_BSEG WHERE
           SAKNR = GT_BSEG-HKONT AND SPRAS = 'EN' AND KTOPL = P_BUKRS.

*    SELECT SINGLE   bukrs
*                    werks
*                   j_1iexcd
*                    j_1ipanno
*                    FROM j_1imocomp INTO  wa_j_1imocomp
*                     WHERE werks = wa_bseg-werks .

    SELECT * FROM T001Z INTO TABLE IT_T001Z WHERE BUKRS = WA_BSEG-BUKRS
                                                   AND PARTY IN ('CIN', 'J_1I02').
    READ TABLE IT_T001Z INTO WA_T001Z WITH KEY PARTY = 'CIN'.
    IF SY-SUBRC EQ 0.
      WA_HEADER-CIN        = WA_T001Z-PAVAL.
    ENDIF.

    READ TABLE IT_T001Z INTO WA_T001Z WITH KEY PARTY = 'J_1I02'.
    IF SY-SUBRC EQ 0.
      WA_HEADER-PAN        = WA_T001Z-PAVAL.
    ENDIF.


    SELECT SINGLE * FROM TCJ_CJ_NAMES INTO WA_TCJ_CJ_NAMES WHERE LANGU = 'EN'
                                                             AND COMP_CODE = WA_BSEG-BUKRS
                                                             AND CAJO_NUMBER =  WA_TCJ_DOCUMENTS-CAJO_NUMBER.

    SELECT WERKS
           GSBER FROM T134G
           INTO TABLE GT_T134G FOR ALL ENTRIES IN GT_BSEG WHERE GSBER = GT_BSEG-GSBER.
    READ TABLE GT_T134G INTO WA_T134G INDEX 1.

*  ENDIF.
*

    IF WA_T134G IS NOT INITIAL.

      SELECT SINGLE WERKS
             ADRNR FROM T001W
             INTO WA_T001W
             WHERE WERKS = WA_T134G-WERKS.

    ENDIF.

*    SELECT SINGLE bukrs
*                  adrnr FROM t001 INTO  wa_t001
*           WHERE  bukrs = wa_bseg-bukrs.

  ENDIF.

  IF WA_T001W IS NOT INITIAL.

    SELECT SINGLE
      ADDRNUMBER
      NAME1
      STREET
      STR_SUPPL1
      STR_SUPPL2
      STR_SUPPL3
      CITY1
      POST_CODE1
      TEL_NUMBER
      FAX_NUMBER
      COUNTRY
      HOUSE_NUM1
      FLOOR
      BUILDING
      LOCATION
      CITY2
      TIME_ZONE
      REGION
      FROM ADRC INTO  WA_ADRC
      WHERE ADDRNUMBER =  WA_T001W-ADRNR.

  ENDIF.

  IF WA_ADRC IS NOT INITIAL.

    SELECT SINGLE SPRAS
                  LAND1
                  BLAND
                   BEZEI FROM T005U INTO WA_T005U
                         WHERE SPRAS = 'E' AND BLAND = WA_ADRC-REGION
                                           AND LAND1 = WA_ADRC-COUNTRY.


    SELECT  SINGLE ADDRNUMBER
                   SMTP_ADDR  FROM ADR6 INTO WA_ADR6
                              WHERE ADDRNUMBER = WA_ADRC-ADDRNUMBER.



        WA_HEADER-NAME1      = WA_ADRC-NAME1.
        WA_HEADER-STREET     = WA_ADRC-STREET.
        WA_HEADER-STR_SUPPL1 = WA_ADRC-STR_SUPPL1.
        WA_HEADER-STR_SUPPL2 = WA_ADRC-STR_SUPPL2.
        WA_HEADER-STR_SUPPL3 = WA_ADRC-STR_SUPPL3.
        WA_HEADER-CITY1      = WA_ADRC-CITY1.
        WA_HEADER-POST_CODE1 = WA_ADRC-POST_CODE1.
        WA_HEADER-TEL_NUMBER = WA_ADRC-TEL_NUMBER.
        WA_HEADER-FAX_NUMBER = WA_ADRC-FAX_NUMBER.
        WA_HEADER-HOUSE_NUM1 = WA_ADRC-HOUSE_NUM1.
        WA_HEADER-FLOOR      = WA_ADRC-FLOOR.
        WA_HEADER-BUILDING   = WA_ADRC-BUILDING.
        WA_HEADER-LOCATION   = WA_ADRC-LOCATION.
        WA_HEADER-CITY2      = WA_ADRC-CITY2.
        WA_HEADER-TIME_ZONE  = WA_ADRC-TIME_ZONE.

    CONCATENATE WA_TCJ_DOCUMENTS-CAJO_NUMBER WA_TCJ_CJ_NAMES-CAJO_NAME INTO V_STR1 SEPARATED BY '-'.
*    v_str = wa_tcj_documents-cajo_number.


  ENDIF.
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

  LOOP AT GT_TCJ_DOCUMENTS INTO WA_TCJ_DOCUMENTS.

    LOOP AT GT_BSEG INTO WA_BSEG." WHERE awkey = v_str."belnr = wa_tcj_documents-posting_number.
      WA_ITEM-POSTING_DATE = WA_TCJ_DOCUMENTS-POSTING_DATE.
      WA_ITEM-D_POSTING_NUMB = WA_TCJ_DOCUMENTS-D_POSTING_NUMB.
      WA_ITEM-BELNR          = WA_TCJ_DOCUMENTS-POSTING_NUMBER."wa_bseg-belnr.
      WA_ITEM-HKONT = WA_BSEG-HKONT.
      WA_ITEM-DMBTR = WA_BSEG-DMBTR.
      WA_ITEM-SGTXT = WA_BSEG-SGTXT.

      READ TABLE GT_BKPF INTO WA_BKPF WITH KEY BELNR =  WA_BSEG-BELNR.     "wa_tcj_documents-posting_number.

      GV_CUR = WA_BKPF-WAERS.
      IF SY-SUBRC = 0.
        WA_ITEM-XBLNR = WA_BKPF-XBLNR.
        LV_XBLNR =  WA_BKPF-XBLNR.
      ENDIF.
      READ TABLE GT_SKAT INTO WA_SKAT WITH KEY SAKNR = WA_BSEG-HKONT.
      IF SY-SUBRC EQ 0.
        WA_ITEM-TXT50 = WA_SKAT-TXT50.
      ENDIF.

      WA_HEADER-STATE = WA_T005U-BEZEI.
      WA_HEADER-EMAIL = WA_ADR6-SMTP_ADDR.



      APPEND WA_ITEM TO GT_ITEM.
      CLEAR:WA_ITEM,WA_BSEG.",wa_tcj_documents.

    ENDLOOP.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = 'ZFI_CASH_PAYMENT_F50'
      IMPORTING
        FM_NAME            = LV_FM_NAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.

    CALL FUNCTION LV_FM_NAME "'/1BCDWB/SF00000078'
      EXPORTING
*       ARCHIVE_INDEX    =
*       ARCHIVE_INDEX_TAB          =
*       ARCHIVE_PARAMETERS         =
*       CONTROL_PARAMETERS         =
*       MAIL_APPL_OBJ    =
*       MAIL_RECIPIENT   =
*       MAIL_SENDER      =
*       OUTPUT_OPTIONS   =
        WA_HEADER        = WA_HEADER
        LV_XBLNR         = LV_XBLNR
        USER_SETTINGS    = 'X'
        NAME             = WA_TCJ_DOCUMENTS-BP_NAME
        GV_CUR           = GV_CUR
        V_STR            = V_STR
        V_STR1           = V_STR1
*     IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO  =
*       JOB_OUTPUT_OPTIONS         =
      TABLES
        GT_ITEM          = GT_ITEM
      EXCEPTIONS
        FORMATTING_ERROR = 1
        INTERNAL_ERROR   = 2
        SEND_ERROR       = 3
        USER_CANCELED    = 4
        OTHERS           = 5.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDLOOP.

ENDFORM.
