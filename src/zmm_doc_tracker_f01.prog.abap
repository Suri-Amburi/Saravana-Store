*&---------------------------------------------------------------------*
*& Include          ZMM_DOC_TRACKER_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA CHANGING GV_SUBRC.
***  Get Inward Header Data
*  CHECK GV_SUBRC IS INITIAL.
  SELECT
    ZINW_T_HDR~INWD_DOC,
    ZINW_T_HDR~LIFNR,
    ZINW_T_HDR~NAME1,
    ZINW_T_HDR~BILL_NUM,
    ZINW_T_HDR~STATUS,
    DD07T~DDTEXT
    INTO TABLE @DATA(LT_DATA)
    FROM ZINW_T_HDR AS ZINW_T_HDR
    INNER JOIN DD07T AS DD07T ON ZINW_T_HDR~STATUS = DD07T~DOMVALUE_L
    WHERE ZINW_T_HDR~LIFNR = @P_LIFNR AND ZINW_T_HDR~BILL_NUM IN @P_BILL AND DD07T~DOMNAME = @C_STATUS." AND DD07T~DDLANGUAGE = @SY-LANGU.

*  IF SY-SUBRC <> 0.
*    GV_SUBRC = 4.
*    MESSAGE S011(ZMSG_CLS) DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
*    EXIT.
*  ENDIF.

*** Fill Catlog
  DATA : LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
  REFRESH : LT_FIELDCAT.

  APPEND VALUE #( SELTEXT_L = 'Vendor'      FIELDNAME = 'LIFNR'     TABNAME = 'LT_DATA' OUTPUTLEN = 10 ) TO LT_FIELDCAT.
  APPEND VALUE #( SELTEXT_L = 'Vendor Name' FIELDNAME = 'NAME1'     TABNAME = 'LT_DATA' OUTPUTLEN = 40 ) TO LT_FIELDCAT.
  APPEND VALUE #( SELTEXT_L = 'Bill Num'    FIELDNAME = 'BILL_NUM'  TABNAME = 'LT_DATA' OUTPUTLEN = 10 ) TO LT_FIELDCAT.
  APPEND VALUE #( SELTEXT_L = 'Status'      FIELDNAME = 'DDTEXT'    TABNAME = 'LT_DATA' OUTPUTLEN = 30 ) TO LT_FIELDCAT.

*** Display Data
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IT_FIELDCAT   = LT_FIELDCAT            " Field catalog with field descriptions
    TABLES
      T_OUTTAB      = LT_DATA                " Table with data to be displayed
    EXCEPTIONS
      PROGRAM_ERROR = 1                      " Program errors
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_DATA CHANGING GV_SUBRC.
  BREAK BREDDY .
  IF P_LIFNR IS  INITIAL .  ""or P_BILL IS INITIAL.   ""commented by bhavani
    GV_SUBRC = 4.
    MESSAGE S006(ZMSG_CLS) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
