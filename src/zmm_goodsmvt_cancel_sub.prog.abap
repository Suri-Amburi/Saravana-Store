*&---------------------------------------------------------------------*
*& Include          ZMM_GOODSMVT_CANCEL_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FETCH_MAT_DOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FETCH_MAT_DOC .

  DATA: IT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
        WA_RETURN TYPE  BAPIRET2,
        WA_LOG    TYPE TY_LOG.

  SELECT MBLNR,
         MJAHR,
         BUDAT
        FROM MKPF
        INTO TABLE @DATA(IT_MKPF)
        WHERE  MBLNR IN @SO_MBLNR AND BUDAT IN @SO_BUDAT.
  LOOP AT IT_MKPF INTO DATA(WA_MKPF).
*    wait UP TO 1 SECONDS.
    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = WA_MKPF-MBLNR
        MATDOCUMENTYEAR     = WA_MKPF-MJAHR
        GOODSMVT_PSTNG_DATE = WA_MKPF-BUDAT
      TABLES
        RETURN              = IT_RETURN.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    READ TABLE IT_RETURN INTO WA_RETURN WITH KEY TYPE  = 'E'.
    IF SY-SUBRC = 0.
      WA_LOG-MBLNR = WA_MKPF-MBLNR.
      WA_LOG-MJAHR = WA_MKPF-MJAHR.
      WA_LOG-TEXT = WA_RETURN-MESSAGE.
      APPEND WA_LOG TO IT_LOG.
      CLEAR WA_LOG.
    ELSE.
      WA_LOG-MBLNR = WA_MKPF-MBLNR.
      WA_LOG-MJAHR = WA_MKPF-MJAHR.
      WA_LOG-TEXT = 'Reversed Successfully'.
      APPEND WA_LOG TO IT_LOG.
      CLEAR WA_LOG.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM LAYOUT .

  CLEAR : WA_LAYOUT.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-ZEBRA = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_FIELDCAT .

  REFRESH IT_FCAT.

  PERFORM FIELDCAT USING '1'  'MBLNR' ' Material Document ' 'IT_LOG' CHANGING IT_FCAT.
  PERFORM FIELDCAT USING '1'  'MJAHR' ' Year ' 'IT_LOG' CHANGING IT_FCAT.
  PERFORM FIELDCAT USING '1'  'TEXT' ' Message'    'IT_LOG' CHANGING IT_FCAT.
*  PERFORM fieldcat USING '1'  'SO'   ' Sales Order '  'GI_LOG' CHANGING it_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      <-- IT_FCAT
*&---------------------------------------------------------------------*
FORM FIELDCAT  USING LF_COL  TYPE SYCUROW
                     LF_FIELDNAME    TYPE SLIS_FIELDNAME
                     LF_NAME TYPE SCRTEXT_L
                     LF_TABNAME        TYPE SLIS_TABNAME
*                     lf_lzero TYPE c
               CHANGING   IT_FCAT TYPE SLIS_T_FIELDCAT_ALV.

****  wa_fcat-col_pos  = lf_col.
  WA_FCAT-FIELDNAME = LF_FIELDNAME.
  WA_FCAT-SELTEXT_L = LF_NAME.
  WA_FCAT-TABNAME    = LF_TABNAME .
*  WA_FCAT-lzero = lf_lzero .

  APPEND WA_FCAT TO IT_FCAT.
  CLEAR WA_FCAT.

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

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = IT_FCAT
    TABLES
      T_OUTTAB           = IT_LOG
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
