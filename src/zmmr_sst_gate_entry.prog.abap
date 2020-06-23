*&---------------------------------------------------------------------*
*& Report ZMMR_SST_GATE_ENTRY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMMR_SST_GATE_ENTRY NO STANDARD PAGE HEADING.

TYPE-POOLS SLIS.
TABLES : ZINW_T_HDR.

*TYPES: BEGIN OF TY_FINAL,
*         EBELN      TYPE ZINW_T_HDR-EBELN,
*         LIFNR      TYPE ZINW_T_HDR-LIFNR,
*         QR_CODE    TYPE ZINW_T_HDR-QR_CODE,
*         ACT_NO_BUD TYPE ZINW_T_HDR-ACT_NO_BUD,
*         RCV_NO_BUD TYPE ZINW_T_HDR-RCV_NO_BUD,
*         QR_STATUS  TYPE ZINW_T_HDR-QR_STATUS,
*         RCV_TRNS   TYPE ZINW_T_HDR-RCV_TRNS,
*         RCV_LRN    TYPE ZINW_T_HDR-RCV_LRN,
*       END OF TY_FINAL.
TYPES: BEGIN OF TY_FINAL,
         QR_CODE    TYPE ZQR_CODE,
         INWD_DOC   TYPE ZINWD_DOC,
         EBELN      TYPE EBELN,
         LIFNR      TYPE ELIFN,
         ACT_NO_BUD TYPE ZNO_BUD,
         RCV_NO_BUD TYPE ZRCV_NOB,
         QR_STATUS  TYPE ZQR_CODE,
         RCV_TRNS   TYPE ZRCV_TRNS,
         RCV_LRN    TYPE ZRCV_LRN,
       END OF TY_FINAL.

*TYPES: BEGIN OF TY_ZINW_T_HDR,
*         EBELN      TYPE ZINW_T_HDR-EBELN,
*         LIFNR      TYPE ZINW_T_HDR-LIFNR,
*         QR_CODE    TYPE ZINW_T_HDR-QR_CODE,
*         BILL_NUM   TYPE ZINW_T_HDR-BILL_NUM,
*         TRNS       TYPE ZINW_T_HDR-TRNS,
*         LR_NO      TYPE ZINW_T_HDR-LR_NO,
*         ACT_NO_BUD TYPE ZINW_T_HDR-ACT_NO_BUD,
*         RCV_NO_BUD TYPE ZINW_T_HDR-RCV_NO_BUD,
*         QR_STATUS  TYPE ZINW_T_HDR-QR_STATUS,
*         RCV_TRNS   TYPE ZINW_T_HDR-RCV_TRNS,
*         RCV_LRN    TYPE ZINW_T_HDR-RCV_LRN,
*       END OF TY_ZINW_T_HDR.


TYPES: BEGIN OF TY_ZINW_T_HDR,
         EBELN      TYPE EBELN,
         LIFNR      TYPE ELIFN,
         QR_CODE    TYPE ZQR_CODE,
         INWD_DOC   TYPE ZINWD_DOC,
         BILL_NUM   TYPE ZBILL_NUM,
         TRNS       TYPE ZTRANS,
         LR_NO      TYPE ZLR,
         ACT_NO_BUD TYPE ZNO_BUD,
         RCV_NO_BUD TYPE ZRCV_NOB,
         QR_STATUS  TYPE ZQRCS,
         RCV_TRNS   TYPE ZRCV_TRNS,
         RCV_LRN    TYPE ZRCV_LRN,
       END OF TY_ZINW_T_HDR.


DATA: IT_HDR   TYPE TABLE OF TY_ZINW_T_HDR,
      WA_HDR   TYPE TY_ZINW_T_HDR,
      IT_FINAL TYPE TABLE OF TY_FINAL,
      WA_FINAL TYPE TY_FINAL.

DATA: IT_HDR1 TYPE TABLE OF ZINW_T_HDR,
      WA_HDR1 TYPE ZINW_T_HDR.

DATA : IT_FCAT  TYPE SLIS_T_FIELDCAT_ALV,
       WA_FCAT  TYPE SLIS_FIELDCAT_ALV,
       IT_EVENT TYPE SLIS_T_EVENT,
       WA_EVENT TYPE SLIS_ALV_EVENT.


*SELECT-OPTIONS: S_BILNO FOR ZINW_T_HDR-BILL_NUM OBLIGATORY NO-EXTENSION NO INTERVALS,
*                S_LRNO FOR ZINW_T_HDR-LR_NO OBLIGATORY NO-EXTENSION NO INTERVALS,
*                S_TRNS FOR ZINW_T_HDR-TRNS OBLIGATORY NO-EXTENSION NO INTERVALS.
START-OF-SELECTION.
  PARAMETERS : P_BILLNO TYPE ZBILL_NUM OBLIGATORY,
               P_LRNO   TYPE ZLR OBLIGATORY,
               P_TRNS   TYPE ZTRANS OBLIGATORY.


*AT SELECTION-SCREEN.
*  PERFORM CHECK_DATA.

*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM CHECK_DATA .
*  DATA: LV_BILNO TYPE ZINW_T_HDR-BILL_NUM,
*      LV_LRNO  TYPE ZINW_T_HDR-LR_NO,
*      LV_TRNS  TYPE ZINW_T_HDR-TRNS.
*
*  SELECT SINGLE BILL_NUMB
*                TRNS
*                LR_NO
*     INTO ( LV_BILNO, LV_LRNO, LV_TRNS )
*                      FROM ZINW_T_HDR
*                     WHERE BILL_NUM IN S_BILNO
*                     AND LR_NO IN S_LRNO
*                     AND TRNS IN S_TRNS.
*  IF SY-SUBRC <> 0.
*    MESSAGE 'enter valid data' TYPE 'E'.
*  ENDIF.
*ENDFORM.

START-OF-SELECTION.

  PERFORM GET_DATA.
  PERFORM POPULATE_TABLE.
  PERFORM PREPARE_FCAT.
  PERFORM GET_EVETNS.
  PERFORM DISP_DATA.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      INPUT         = P_TRNS
*   IMPORTING
*     OUTPUT        = P_TRNS
*            .
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_TRNS
    IMPORTING
      OUTPUT = P_TRNS.


  BREAK BREDDY.
  SELECT  EBELN
          LIFNR
          QR_CODE
          INWD_DOC
          BILL_NUM
          TRNS
          LR_NO
          ACT_NO_BUD
          RCV_NO_BUD
          QR_STATUS
          RCV_TRNS
          RCV_LRN
                      FROM ZINW_T_HDR
                      INTO TABLE IT_HDR
                      WHERE BILL_NUM = P_BILLNO
                      AND LR_NO = P_LRNO
                      AND TRNS = P_TRNS  ."AND QR_STATUS = '01'.

*READ TABLE IT_HDR INTO WA_HDR INDEX 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPULATE_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
**&---------------------------------------------------------------------*
FORM POPULATE_TABLE .
*  BREAK-POINT.
  SORT IT_HDR BY  EBELN.
  LOOP AT  IT_HDR INTO WA_HDR.

    WA_FINAL-EBELN        = WA_HDR-EBELN.
    WA_FINAL-LIFNR        = WA_HDR-LIFNR.
    WA_FINAL-QR_CODE      = WA_HDR-QR_CODE.
    WA_FINAL-INWD_DOC      = WA_HDR-INWD_DOC.
    WA_FINAL-ACT_NO_BUD   = WA_HDR-ACT_NO_BUD.
    WA_FINAL-RCV_NO_BUD   = WA_HDR-RCV_NO_BUD.
    WA_FINAL-QR_STATUS    = WA_HDR-QR_STATUS.
    WA_FINAL-RCV_TRNS     = WA_HDR-RCV_TRNS.
    WA_FINAL-RCV_LRN      = WA_HDR-RCV_LRN.

    APPEND WA_FINAL TO IT_FINAL.
    CLEAR WA_FINAL.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_FCAT .

  WA_FCAT-FIELDNAME = 'INWD_DOC'.
  WA_FCAT-SELTEXT_M = TEXT-001."''QR Code'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR  WA_FCAT.

  WA_FCAT-FIELDNAME = 'EBELN'.
  WA_FCAT-SELTEXT_M = TEXT-002."'PO'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR  WA_FCAT.

  WA_FCAT-FIELDNAME = 'LIFNR'.
  WA_FCAT-SELTEXT_M = TEXT-003 ."'Vendor'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR  WA_FCAT.

  WA_FCAT-FIELDNAME = 'ACT_NO_BUD'.
  WA_FCAT-SELTEXT_M = TEXT-004."'Actual No of Bundles'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR  WA_FCAT.

  WA_FCAT-FIELDNAME = 'QR_STATUS'.
  WA_FCAT-SELTEXT_M = TEXT-005. "'QR Code Status'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR  WA_FCAT.

  WA_FCAT-FIELDNAME = 'RCV_No_BUD'.
  WA_FCAT-SELTEXT_M = TEXT-006."'Received Bundles'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  WA_FCAT-EDIT = 'X'.
  WA_FCAT-REF_FIELDNAME = 'RCV_NO_BUD'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR  WA_FCAT.


  WA_FCAT-FIELDNAME = 'RCV_TRNS'.
  WA_FCAT-SELTEXT_M = TEXT-007."'Received Transporter'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  WA_FCAT-EDIT = 'X'.
  WA_FCAT-OUTPUTLEN = '40'.
  WA_FCAT-REF_FIELDNAME = 'RCV_TRNS'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR  WA_FCAT.


  WA_FCAT-FIELDNAME = 'RCV_LRN'.
  WA_FCAT-SELTEXT_M = TEXT-008."'Received LR No.'.
  WA_FCAT-TABNAME = 'IT_FINAL'.
  WA_FCAT-EDIT = 'X'.
  WA_FCAT-REF_FIELDNAME = 'RCV_LRN'.
  APPEND WA_FCAT TO IT_FCAT.
  CLEAR  WA_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EVETNS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EVETNS .
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
*   EXPORTING
*     I_LIST_TYPE           = 0
    IMPORTING
      ET_EVENTS = IT_EVENT
*   EXCEPTIONS
*     LIST_TYPE_WRONG       = 1
*     OTHERS    = 2
    .
  IF IT_EVENT IS NOT INITIAL .
    READ TABLE IT_EVENT  INTO WA_EVENT WITH KEY NAME = 'USER_COMMAND'.
    IF SY-SUBRC = 0.
      WA_EVENT-NAME = 'USER_COMMAND'.
      WA_EVENT-FORM = 'USER_COMMAND'.
      MODIFY IT_EVENT FROM WA_EVENT  INDEX SY-TABIX.
    ENDIF.


    READ TABLE IT_EVENT INTO WA_EVENT WITH KEY NAME = 'PF_STATUS_SET'.
    IF SY-SUBRC = 0.
      WA_EVENT-NAME = 'PF_STATUS_SET'.
      WA_EVENT-FORM = 'AI200'.
      MODIFY IT_EVENT FROM WA_EVENT INDEX SY-TABIX.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISP_DATA .
  DATA : WA_LAYOUT TYPE SLIS_LAYOUT_ALV.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-ZEBRA = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID  " Name of the calling program
      I_CALLBACK_PF_STATUS_SET = 'AI200'    " Set EXIT routine to status
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'    " EXIT routine for command handling
      IS_LAYOUT                = WA_LAYOUT   " List layout specifications
      IT_FIELDCAT              = IT_FCAT  " Field catalog with field descriptions
      IT_EVENTS                = IT_EVENT  " Table of events to perform
    TABLES
      T_OUTTAB                 = IT_FINAL. " Table with data to be displayed.

ENDFORM.

FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.
*BREAK-POINT.
  CASE R_UCOMM.
**    WHEN '&IC1'.
**    IF R_UCOMM = '&IC1'.
**      READ TABLE IT_FINAL INTO WA_FINAL INDEX RS_SELFIELD-TABINDEX.
**      CASE RS_SELFIELD-FIELDNAME.
*
    WHEN '&DATA_SAVE'.
*          DATA : IT_HDR1 TYPE TABLE OF TY_ZINW_T_HDR,
*                WA_HDR1 TYPE TY_ZINW_T_HDR.
*          DATA: WA_FINAL1 TYPE ZINW_T_HDR.
**     IF R_UCOMM = '&DATA_SAVE'.
*          LOOP AT IT_HDR1 INTO WA_HDR1.
*            CLEAR WA_HDR.
*            READ TABLE IT_HDR INTO WA_HDR INDEX SY-TABIX.
*    IF WA_HDR1 <> WA_HDR.
*
*    WA_FINAL1-EBELN        = WA_HDR1-EBELN.
*    WA_FINAL1-LIFNR        = WA_HDR1-LIFNR.
*    WA_FINAL1-QR_CODE      = WA_HDR1-QR_CODE.
*    WA_FINAL1-ACT_NO_BUD   = WA_HDR1-ACT_NO_BUD.
*    WA_FINAL1-RCV_NO_BUD   = WA_HDR1-RCV_NO_BUD.
*    WA_FINAL1-QR_STATUS    = WA_HDR1-QR_STATUS.
*                        MODIFY ZINW_T_HDR FROM WA_FINAL1-RCV_NO_BUD.
*                         IF SY-SUBRC = 0.
*               MESSAGE 'RECORD HAS BEEN SAVED' TYPE 'S'.
*          ENDIF.
*ENDIF.
*CLEAR: WA_FINAL1 , WA_HDR1.
*          ENDLOOP.
      DATA: WA_FINAL1 TYPE ZINW_T_HDR.




*      BREAK-POINT.

      LOOP AT IT_FINAL INTO WA_FINAL WHERE RCV_NO_BUD IS NOT INITIAL.
        UPDATE  ZINW_T_HDR SET
                          RCV_NO_BUD = WA_FINAL-RCV_NO_BUD
                          GATEIN_USER = SY-UNAME
                          GATEIN_DATE = SY-DATUM
                          GATEIN_TIME = SY-UZEIT
                          GATEIN_STATUS = '01'
                                 STATUS = '02'
                          RCV_TRNS    = WA_FINAL-RCV_TRNS
                          RCV_LRN     = WA_FINAL-RCV_LRN
                          WHERE EBELN = WA_FINAL-EBELN AND QR_CODE = WA_FINAL-QR_CODE.

        IF SY-SUBRC = 0.

          MESSAGE 'Data Uploaded Successfully' TYPE 'S'.
        ELSE.
        ENDIF.
      ENDLOOP.
** MESSAGE 'Trying to save data' TYPE 'S'.
**         PERFORM save_Data.
**      ENDCASE.
  ENDCASE.
ENDFORM.
*
FORM AI200 USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'AI200'.
ENDFORM.
