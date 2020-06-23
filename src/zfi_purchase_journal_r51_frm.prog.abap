*&---------------------------------------------------------------------*
*& Include          ZFI_PURCHASE_JOURNAL_R51_FRM
*&---------------------------------------------------------------------*


FORM GET_JOURNAL_DATA .
break SAMBURI.
SELECT
  BUKRS
  BELNR
  GJAHR
  BUDAT
  BLART
  XBLNR
  WAERS
  FROM BKPF INTO TABLE GT_BKPF
  WHERE BELNR IN S_BELNR
    AND BUKRS = P_BUKRS
    AND GJAHR = P_GJAHR
    AND ( BLART = 'SA' OR BLART = 'AB' ).

  IF GT_BKPF IS INITIAL.
    MESSAGE 'No Data Exists' TYPE 'E' DISPLAY LIKE 'E'.
  ENDIF.

IF GT_BKPF IS NOT INITIAL.

SORT GT_BKPF BY BUKRS BELNR GJAHR.

SELECT
  BUKRS
  BELNR
  GJAHR
  BUZEI
  SHKZG
  LIFNR
  KUNNR
  SGTXT
  ANLN1
  HKONT
  WRBTR
  WERKS
  GSBER
  FROM BSEG INTO TABLE GT_BSEG
  FOR ALL ENTRIES IN GT_BKPF
  WHERE BELNR = GT_BKPF-BELNR
  AND   BUKRS = GT_BKPF-BUKRS
  AND   GJAHR = GT_BKPF-GJAHR.
sort gt_bseg by BUZEI.                     " ADDED ON (18-4-20)

SELECT
  BUKRS
  BELNR
  GJAHR
  BUZEI
  SHKZG
  LIFNR
  KUNNR
  SGTXT
  ANLN1
  HKONT
  WRBTR
  WERKS
  GSBER
  FROM BSEG INTO TABLE GT_BSEG1
  FOR ALL ENTRIES IN GT_BKPF
  WHERE BELNR = GT_BKPF-BELNR
  AND   BUKRS = GT_BKPF-BUKRS
  AND   GJAHR = GT_BKPF-GJAHR.

SELECT BUKRS ADRNR FROM T001 INTO TABLE GT_T001 FOR ALL ENTRIES IN GT_BKPF WHERE BUKRS = GT_BKPF-BUKRS.

SELECT
  WERKS
  SPART
  GSBER
  FROM T134G INTO CORRESPONDING FIELDS OF TABLE GT_T134G
  FOR ALL ENTRIES IN GT_BSEG
  wHERE GSBER = GT_BSEG-GSBER.

SELECT
  WERKS
  ADRNR
  FROM T001W INTO TABLE GT_T001W
  FOR ALL ENTRIES IN GT_T134G
  WHERE WERKS = GT_T134G-WERKS.

IF NOT GT_T001W IS INITIAL.

SELECT
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
  FROM ADRC INTO TABLE GT_ADRC
  FOR ALL ENTRIES IN GT_T001W
  WHERE ADDRNUMBER = GT_T001W-ADRNR.

SELECT ADDRNUMBER SMTP_ADDR FROM ADR6 INTO TABLE GT_ADR6 FOR ALL ENTRIES IN GT_ADRC WHERE ADDRNUMBER = GT_ADRC-ADDRNUMBER.

SELECT BUKRS PARTY PAVAL FROM T001Z INTO TABLE GT_T001Z FOR ALL ENTRIES IN GT_T001 WHERE BUKRS = GT_T001-BUKRS AND PARTY = 'CIN'.

SELECT BUKRS PARTY PAVAL FROM T001Z INTO TABLE GT1_T001Z FOR ALL ENTRIES IN GT_T001 WHERE BUKRS = GT_T001-BUKRS AND PARTY = 'J_1I02'.
ENDIF.

SELECT
  SPRAS
  LAND1
  LANDX
  FROM T005T INTO TABLE GT_T005T
  FOR ALL ENTRIES IN GT_ADRC
  WHERE LAND1 = GT_ADRC-COUNTRY
  AND SPRAS = 'EN'.
  ENDIF.

IF GT_BSEG IS NOT INITIAL.

SELECT
  SPRAS
  SAKNR
  KTOPL
  TXT50
  FROM SKAT INTO TABLE GT_SKAT
  FOR ALL ENTRIES IN GT_BSEG
  WHERE SPRAS = 'EN'
  AND   SAKNR = GT_BSEG-HKONT.

ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JOURNAL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_JOURNAL_DATA .

  DATA:CONTROL TYPE SSFCTRLOP.

  CONTROL-NO_OPEN  = 'X'.
  CONTROL-PREVIEW  = 'X'.
  CONTROL-NO_CLOSE = 'X'.

  CALL FUNCTION 'SSF_OPEN'
    EXPORTING
*     ARCHIVE_PARAMETERS =
      USER_SETTINGS      = 'X'
*     MAIL_SENDER        =
*     MAIL_RECIPIENT     =
*     MAIL_APPL_OBJ      =
*     OUTPUT_OPTIONS     =
      CONTROL_PARAMETERS = CONTROL
*   IMPORTING
*     JOB_OUTPUT_OPTIONS =
    EXCEPTIONS
      FORMATTING_ERROR   = 1
      INTERNAL_ERROR     = 2
      SEND_ERROR         = 3
      USER_CANCELED      = 4
      OTHERS             = 5.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZFI_PURCHASE_JOURNAL_F51'
    IMPORTING
      FM_NAME            = LV_FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  LOOP AT GT_BKPF INTO WA_BKPF.

    CLEAR WA_HEADER.
    REFRESH GT_ITEM.

    WA_HEADER-BELNR = WA_BKPF-BELNR.
    WA_HEADER-BUDAT = WA_BKPF-BUDAT.
    WA_HEADER-XBLNR = WA_BKPF-XBLNR.
    WA_HEADER-WAERS = WA_BKPF-WAERS.

    READ TABLE GT_T001Z INTO WA_T001Z WITH KEY BUKRS = WA_BKPF-BUKRS.
    IF SY-SUBRC = 0.
      WA_HEADER-PAVAL  = WA_T001Z-PAVAL.
    ENDIF.

    READ TABLE GT1_T001Z INTO WA1_T001Z WITH KEY BUKRS = WA_BKPF-BUKRS.
    IF SY-SUBRC = 0.
      WA_HEADER-PAVAL1  = WA1_T001Z-PAVAL.
    ENDIF.

    READ TABLE GT_T005T INTO WA_T005T WITH KEY LAND1 = WA_ADRC-COUNTRY.
    IF SY-SUBRC = 0.
      WA_HEADER-LANDX = WA_T005T-LANDX.
    ENDIF.
  BREAK CLIKHITHA.
    LOOP AT GT_BSEG INTO WA_BSEG WHERE BELNR =  WA_BKPF-BELNR.
*      WA_BSEG1 = WA_BSEG.

      IF WA_BSEG-LIFNR IS NOT INITIAL.
        IF  WA_BSEG-SHKZG = 'H'.
          WA_ITEM-SHKZG = 'Cr'.
          WA_ITEM-CREDIT = WA_ITEM-CREDIT +  WA_BSEG-WRBTR.
          WA_HEADER-SGTXT = WA_BSEG-SGTXT.
          READ TABLE GT_LFA1 INTO WA_LFA1 WITH KEY LIFNR = WA_BSEG-LIFNR.
          IF SY-SUBRC = 0.
            WA_ITEM-TXT50   = WA_LFA1-NAME1.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                INPUT  = WA_LFA1-LIFNR
              IMPORTING
                OUTPUT = WA_LFA1-LIFNR.
            WA_ITEM-BELNR = WA_LFA1-LIFNR.
          ENDIF.
        ENDIF.

      ELSE.

        IF  WA_BSEG-SHKZG = 'S'.
          WA_ITEM-SHKZG = 'Dr'.
          WA_ITEM-DEBIT = WA_ITEM-DEBIT +  WA_BSEG-WRBTR.
          WA_HEADER-SGTXT = WA_BSEG-SGTXT.
          IF WA_HEADER-SGTXT IS INITIAL .
       READ TABLE GT_BSEG1 INTO WA_BSEG1 INDEX 1.    "*
       WA_HEADER-SGTXT = WA_BSEG1-SGTXT.
            ENDIF.
        ELSE.
          WA_ITEM-SHKZG = 'Cr'.
          WA_ITEM-CREDIT = WA_ITEM-CREDIT + WA_BSEG-WRBTR.
        ENDIF.

        READ TABLE GT_SKAT INTO WA_SKAT WITH KEY SPRAS = 'EN'
                                                 SAKNR = WA_BSEG-HKONT
                                                  KTOPL = '1000'.
        IF SY-SUBRC EQ 0.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = WA_BSEG-HKONT
            IMPORTING
              OUTPUT = WA_BSEG-HKONT.

          WA_ITEM-TXT50 = WA_SKAT-TXT50.
          WA_ITEM-BELNR = WA_BSEG-HKONT.
*          CONCATENATE wa_bseg-hkont wa_skat-txt50 INTO wa_item-txt50 SEPARATED BY '-'.
        ENDIF.
      ENDIF.

      CLEAR : WA_T134G, WA_T001W.
      READ TABLE GT_T134G INTO WA_T134G WITH KEY GSBER = WA_BSEG-GSBER.

      READ TABLE GT_T001W INTO WA_T001W WITH KEY WERKS = WA_T134G-WERKS.
      IF SY-SUBRC = 0.
        WA_HEADER-ADRNR = WA_T001W-ADRNR.
      ENDIF.

      READ TABLE GT_ADRC INTO WA_ADRC WITH KEY ADDRNUMBER = WA_T001W-ADRNR.
      IF SY-SUBRC = 0.
        WA_HEADER-NAME       = WA_ADRC-NAME1.
        WA_HEADER-STREET     = WA_ADRC-STREET.
        WA_HEADER-STR_SUPPL1 = WA_ADRC-STR_SUPPL1.
        WA_HEADER-STR_SUPPL2 = WA_ADRC-STR_SUPPL2.
        WA_HEADER-STR_SUPPL3 = WA_ADRC-STR_SUPPL3.
        WA_HEADER-CITY1      = WA_ADRC-CITY1.
        WA_HEADER-POST_CODE1 = WA_ADRC-POST_CODE1.
        WA_HEADER-TEL_NUMBER = WA_ADRC-TEL_NUMBER.
        WA_HEADER-FAX_NUMBER = WA_ADRC-FAX_NUMBER.
        WA_HEADER-FLOOR      = WA_ADRC-FLOOR.
        WA_HEADER-BUILDING   = WA_ADRC-BUILDING.
        WA_HEADER-LOCATION   = WA_ADRC-LOCATION.
        WA_HEADER-CITY2      = WA_ADRC-CITY2.
        WA_HEADER-TIME_ZONE  = WA_ADRC-TIME_ZONE.
*      wa_header-TIME_ZONE  = wa_adrc-TIME_ZONE.
      ENDIF.

      READ TABLE GT_ADR6 INTO WA_ADR6 WITH KEY ADDRNUMBER = WA_ADRC-ADDRNUMBER.
      IF SY-SUBRC = 0.
        WA_HEADER-SMTP_ADDR = WA_ADR6-SMTP_ADDR.
      ENDIF.

      APPEND WA_ITEM TO GT_ITEM.
      CLEAR WA_ITEM.

    ENDLOOP.
    SORT GT_ITEM BY SHKZG.

    CALL FUNCTION LV_FM_NAME
      EXPORTING
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
        CONTROL_PARAMETERS = CONTROL
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
*       OUTPUT_OPTIONS     =
        USER_SETTINGS      = 'X'
        WA_HEADER          = WA_HEADER
*      IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO    =
*       JOB_OUTPUT_OPTIONS =
      TABLES
        GT_ITEM            = GT_ITEM
      EXCEPTIONS
        FORMATTING_ERROR   = 1
        INTERNAL_ERROR     = 2
        SEND_ERROR         = 3
        USER_CANCELED      = 4
        OTHERS             = 5.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDLOOP.
  CALL FUNCTION 'SSF_CLOSE'.

ENDFORM.