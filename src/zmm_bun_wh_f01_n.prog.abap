*&---------------------------------------------------------------------*
*& Include          ZMM_BUN_TRANSIT_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA.
  DATA :
    R_DATE   TYPE RANGE OF CDATE,
    LT_TOTAL TYPE STANDARD TABLE OF TY_TOTAL.
  FIELD-SYMBOLS :
    <LS_TOTAL>  TYPE TY_TOTAL,
    <LS_FINAL1> TYPE TY_FINAL1.

  IF P_S IS NOT INITIAL.
*    DATA(LV_DATE) =  SY-DATUM - 15.
    APPEND VALUE #( LOW = SY-DATUM - 15 SIGN = 'I' OPTION = 'LT' ) TO R_DATE.
  ELSE.
    APPEND VALUE #( LOW = SY-DATUM - 15 HIGH = SY-DATUM SIGN = 'I' OPTION = 'BT' ) TO R_DATE.
  ENDIF.

  SELECT
       ZINW_T_HDR~QR_CODE,
       ZINW_T_HDR~INWD_DOC,
       ZINW_T_HDR~LIFNR,
       ZINW_T_HDR~NAME1,
       ZINW_T_HDR~BILL_NUM,
       ZINW_T_HDR~BILL_DATE,
       ZINW_T_HDR~TRNS,
       LFA1~NAME1 AS TRNS_NAME,
       ZINW_T_HDR~LR_NO,
       ZINW_T_HDR~LR_DATE,
       ZINW_T_HDR~ACT_NO_BUD,
       ZINW_T_HDR~PUR_TOTAL,
       ZINW_T_HDR~ERDATE,
       ZINW_T_ITEM~EBELN,
       ZINW_T_ITEM~EBELP,
       ZINW_T_ITEM~MENGE_P,
       ZINW_T_ITEM~NETPR_P,
       ZINW_T_ITEM~NETWR_P,
       ZINW_T_ITEM~MATNR,
       ZINW_T_ITEM~MAKTX,
       ZINW_T_ITEM~MATKL,
       T023T~WGBEZ
       FROM ZINW_T_HDR AS ZINW_T_HDR
       INNER JOIN ZINW_T_STATUS AS ZINW_T_STATUS ON ZINW_T_STATUS~QR_CODE = ZINW_T_HDR~QR_CODE
                  AND ZINW_T_STATUS~STATUS_FIELD = @C_QR_CODE AND ZINW_T_STATUS~STATUS_VALUE = @C_QR02
       INNER JOIN ZINW_T_ITEM AS ZINW_T_ITEM ON ZINW_T_ITEM~QR_CODE = ZINW_T_HDR~QR_CODE
       INNER JOIN LFA1 AS LFA1 ON LFA1~LIFNR = ZINW_T_HDR~TRNS
       INNER JOIN T023T AS T023T ON T023T~MATKL = ZINW_T_ITEM~MATKL
       INTO TABLE @GT_ITEM
       WHERE ZINW_T_HDR~STATUS = @C_STATUS AND ZINW_T_HDR~LIFNR IN @S_LIFNR AND
             ZINW_T_STATUS~CREATED_DATE IN @R_DATE.

  IF GT_ITEM IS NOT INITIAL.
*** GET MARCHNDISE CAT BY MATERIAL GROUP
    DATA : R_MATKL TYPE RANGE OF KLASSE_D.
    REFRESH :R_MATKL.
    LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<GS_ITEM>).
      APPEND VALUE #( LOW = <GS_ITEM>-MATKL SIGN = 'I' OPTION = 'EQ' ) TO R_MATKL.
    ENDLOOP.

    SORT R_MATKL BY LOW.
    DELETE ADJACENT DUPLICATES FROM R_MATKL COMPARING LOW.
*** Get Clent ID from Material Group
    SELECT
      KSSK~CLINT
      KLAH~KLART
      KLAH~CLASS
      KSSK~OBJEK
      INTO TABLE GT_KLAH_H
      FROM KLAH AS KLAH
      INNER JOIN KSSK AS KSSK  ON KSSK~OBJEK = KLAH~CLINT
      WHERE KLAH~CLASS IN R_MATKL.

    IF GT_KLAH_H IS NOT INITIAL.
*** Get Marchandise Cat from Clent ID
      SELECT
      KLAH~CLINT,
      KLAH~KLART,
      KLAH~CLASS
      INTO TABLE @GT_KLAH_I
      FROM KLAH AS KLAH
      FOR ALL ENTRIES IN @GT_KLAH_H WHERE KLAH~CLINT = @GT_KLAH_H-CLINT.
    ENDIF.

  ENDIF.


*********************added by bhavani********

  IF GT_KLAH_I IS NOT INITIAL .
    SELECT
        KLAH~CLINT,
        KLAH~KLART,
        KLAH~CLASS FROM KLAH  INTO TABLE @DATA(GT_KLAH)
*        FOR ALL ENTRIES IN @GT_KLAH_I
*        WHERE CLINT NE  @GT_KLAH_I-CLINT
        WHERE KLART = '026'
        AND WWSKZ = '0'.
  ENDIF .
**********ended by bhavani**************

  CLEAR   : GS_FINAL1.
  REFRESH : GT_FINAL1.
  BREAK BREDDY .
***  Screen 1 Final table
*** PREPARING FINAL TABLE
  SORT GT_KLAH_H BY CLINT.
  SORT GT_KLAH_I BY CLINT.
  SORT GT_ITEM BY MATKL.
  DATA : LV_COUNT TYPE I VALUE 0.
  DATA(LT_ITEM) = GT_ITEM.
  SORT LT_ITEM BY QR_CODE.
  DELETE ADJACENT DUPLICATES FROM LT_ITEM COMPARING QR_CODE.
  LOOP AT GT_KLAH_I ASSIGNING <GS_KLAH_I>.
*******ADDED BY BHAVANI*********
    DELETE GT_KLAH WHERE CLINT = <GS_KLAH_I>-CLINT .
    LV_COUNT =  LV_COUNT + 1 .
*******ENDED BY BHAVANI***********
    GS_FINAL1-SNO = LV_COUNT.
    GS_FINAL1-GRP = <GS_KLAH_I>-CLASS.
    READ TABLE GT_KLAH_H WITH KEY CLINT = <GS_KLAH_I>-CLINT TRANSPORTING NO FIELDS.
    LOOP AT GT_KLAH_H ASSIGNING <GS_KLAH_H> FROM SY-TABIX.
      IF <GS_KLAH_H>-CLINT <> <GS_KLAH_I>-CLINT.
        EXIT.
      ENDIF.
      READ TABLE GT_ITEM WITH KEY MATKL = <GS_KLAH_H>-CLASS TRANSPORTING NO FIELDS.
      LOOP AT GT_ITEM ASSIGNING <GS_ITEM> FROM SY-TABIX.
        IF <GS_ITEM>-MATKL <> <GS_KLAH_H>-CLASS.
          EXIT.
        ENDIF.
        ADD <GS_ITEM>-MENGE_P TO GS_FINAL1-MENGE.
        <GS_ITEM>-GRP = GS_FINAL1-GRP.
        APPEND VALUE #( GRP = GS_FINAL1-GRP QR_CODE = <GS_ITEM>-QR_CODE PUR_TOTAL = <GS_ITEM>-PUR_TOTAL ACT_NO_BUD = <GS_ITEM>-ACT_NO_BUD ) TO LT_TOTAL.
      ENDLOOP.
    ENDLOOP.
    APPEND  GS_FINAL1 TO GT_FINAL1.
    CLEAR : GS_FINAL1.
*    LV_COUNT = LV_COUNT + 1.
  ENDLOOP.

*** For Adding Header Totals
  SORT LT_TOTAL BY GRP QR_CODE.
  DELETE ADJACENT DUPLICATES FROM LT_TOTAL COMPARING QR_CODE GRP.
  SORT LT_TOTAL BY GRP.
  LOOP AT GT_FINAL1 ASSIGNING <LS_FINAL1>.
    READ TABLE LT_TOTAL WITH KEY GRP = <LS_FINAL1>-GRP TRANSPORTING NO FIELDS.
    LOOP AT LT_TOTAL ASSIGNING <LS_TOTAL> FROM SY-TABIX.
      IF <LS_FINAL1>-GRP <> <LS_TOTAL>-GRP.
        EXIT.
      ENDIF.
      ADD <LS_TOTAL>-PUR_TOTAL TO <LS_FINAL1>-PUR_TOTAL.
      ADD <LS_TOTAL>-ACT_NO_BUD TO <LS_FINAL1>-ACT_NO_BUD.
    ENDLOOP.
  ENDLOOP.

***********added by bhavani*******************
  LOOP AT GT_KLAH ASSIGNING FIELD-SYMBOL(<GS_KLAH>).
    LV_COUNT = LV_COUNT + 1 .
    GS_FINAL1-SNO = LV_COUNT .
    GS_FINAL1-GRP = <GS_KLAH>-CLASS .
    APPEND GS_FINAL1 TO GT_FINAL1 .
    CLEAR : GS_FINAL1 .
  ENDLOOP.
********ended by bhavani*****************

ENDFORM.

FORM DISPLAY_DATA_SCR1.
*** FIELD CATLOG
  DATA:
    LS_LAYOUT   TYPE SLIS_LAYOUT_ALV,
    LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
    GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
    WVARI       TYPE DISVARIANT,
    LT_SORT     TYPE SLIS_T_SORTINFO_ALV.

  WVARI-REPORT    = SY-REPID.
  WVARI-USERNAME  = SY-UNAME.

  LS_LAYOUT-ZEBRA       = ABAP_TRUE.
  LS_LAYOUT-COLWIDTH_OPTIMIZE  = ABAP_TRUE.

*** Field Catlog
  REFRESH LT_FIELDCAT.
  GS_FIELDCAT-FIELDNAME      = 'SNO'.
  GS_FIELDCAT-SELTEXT_L      = 'SNO'.
  GS_FIELDCAT-DDIC_OUTPUTLEN = 4.
  GS_FIELDCAT-LZERO          = 'X'.
  GS_FIELDCAT-NO_ZERO        = 'X'.
  GS_FIELDCAT-REF_TABNAME    = 'LT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'GRP'.
  GS_FIELDCAT-SELTEXT_L      = 'Group'.
  GS_FIELDCAT-REF_TABNAME    = 'LT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'MENGE'.
  GS_FIELDCAT-SELTEXT_L      = 'Quantity'.
  GS_FIELDCAT-DO_SUM         = 'X'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'ACT_NO_BUD'.
  GS_FIELDCAT-SELTEXT_L      = 'Num of Bundles'.
  GS_FIELDCAT-DO_SUM         = 'X'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'PUR_TOTAL'.
  GS_FIELDCAT-SELTEXT_L      = 'Purchase Value W/O Tax'.
  GS_FIELDCAT-DO_SUM         = 'X'.
  GS_FIELDCAT-OUTPUTLEN     = 25.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

**** Dispalying ALV Report
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = SY-REPID         " Name of the calling program
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND_SCR1'            " EXIT routine for command handling
      IS_LAYOUT               = LS_LAYOUT        " List layout specifications
      IT_FIELDCAT             = LT_FIELDCAT      " Field catalog with field descriptions
      I_DEFAULT               = 'X'              " Initial variant active/inactive logic
      I_SAVE                  = 'A'              " Variants can be saved
    TABLES
      T_OUTTAB                = GT_FINAL1                 " Table with data to be displayed
    EXCEPTIONS
      PROGRAM_ERROR           = 1                " Program errors
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

FORM USER_COMMAND_SCR1 USING  R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.
  FIELD-SYMBOLS : <LS_FINAL1> LIKE LINE OF GT_FINAL1.
*** Read Data on Double Click
  READ TABLE GT_FINAL1 ASSIGNING <LS_FINAL1> INDEX RS_SELFIELD-TABINDEX.
  IF SY-SUBRC = 0.
    PERFORM CALL_SCREEN2 USING <LS_FINAL1>-GRP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_FINAL1>
*&---------------------------------------------------------------------*
FORM CALL_SCREEN2 USING P_GRP.




  BREAK BREDDY .
  DATA : ST_DATE TYPE P .

  DATA(LT_ITEM_GRP) = GT_ITEM.
  DELETE LT_ITEM_GRP WHERE GRP <> P_GRP.
  DATA(LT_ITEM_QR)  = LT_ITEM_GRP.
  SORT LT_ITEM_QR BY QR_CODE.
  DELETE ADJACENT DUPLICATES FROM LT_ITEM_QR COMPARING QR_CODE.
  REFRESH :GT_FINAL2.
  LOOP AT LT_ITEM_QR ASSIGNING FIELD-SYMBOL(<LS_ITEM_QR>).



********ADDED BY BHAVANI*********
    CALL FUNCTION '/SDF/CMO_DATETIME_DIFFERENCE'
      EXPORTING
        DATE1            = <LS_ITEM_QR>-ERDATE
*       TIME1            =
        DATE2            = SY-DATUM
*       TIME2            =
      IMPORTING
        DATEDIFF         = <LS_ITEM_QR>-STALE_DT
*       TIMEDIFF         =
*       EARLIEST         =
      EXCEPTIONS
        INVALID_DATETIME = 1
        OTHERS           = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
*  ENDIF.
*GS_FINAL2-STALE_DT = ST_DATE .
**********ENDED BY BHAVANI**************************
    GS_FINAL2  = <LS_ITEM_QR>.
    CLEAR :GS_FINAL2-MENGE_P.
    LOOP AT LT_ITEM_GRP ASSIGNING <GS_ITEM> WHERE QR_CODE = <LS_ITEM_QR>-QR_CODE.
      ADD <GS_ITEM>-MENGE_P TO GS_FINAL2-MENGE_P.
    ENDLOOP.
    APPEND  GS_FINAL2 TO GT_FINAL2.
    CLEAR : GS_FINAL2.
  ENDLOOP.



  SELECT
   ZQR_MAIL~QR_CODE,
   ZQR_MAIL~INWD_DOC
 FROM ZQR_MAIL INTO TABLE @DATA(T_FINAL)
                FOR ALL ENTRIES IN  @GT_FINAL2
                WHERE QR_CODE = @GT_FINAL2-QR_CODE .

  BREAK BREDDY .
  IF SY-SUBRC = 0 .
    LOOP AT GT_FINAL2 ASSIGNING FIELD-SYMBOL(<LS_FINAL_2>).
      READ TABLE T_FINAL WITH KEY QR_CODE = <LS_FINAL_2>-QR_CODE TRANSPORTING NO FIELDS.
      IF SY-SUBRC = 0.
        <LS_FINAL_2>-SEL = 'X'.
      ENDIF.
    ENDLOOP.
  ENDIF.


  IF GT_FINAL2 IS NOT INITIAL.
*** FIELD CATLOG
    DATA:
      LS_LAYOUT   TYPE SLIS_LAYOUT_ALV,
      LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      WVARI       TYPE DISVARIANT,
      LT_SORT     TYPE SLIS_T_SORTINFO_ALV.

    WVARI-REPORT    = SY-REPID.
    WVARI-USERNAME  = SY-UNAME.

    LS_LAYOUT-ZEBRA       = ABAP_TRUE.
    LS_LAYOUT-COLWIDTH_OPTIMIZE  = ABAP_TRUE.
*** Field Catlog
    GS_FIELDCAT-FIELDNAME      = 'BILL_NUM'.
    GS_FIELDCAT-SELTEXT_L      = 'Bill num'.
    GS_FIELDCAT-REF_TABNAME    = 'GT_FINAL2'.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'BILL_DATE'.
    GS_FIELDCAT-SELTEXT_L      = 'Bill Date'.
    GS_FIELDCAT-REF_TABNAME    = 'GT_FINAL2'.
    GS_FIELDCAT-LZERO          = 'X'.
    GS_FIELDCAT-INTTYPE        = 'DATS'.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'LIFNR'.
    GS_FIELDCAT-SELTEXT_L      = 'Vendor'.
    GS_FIELDCAT-REF_TABNAME    = 'GT_FINAL2'.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'NAME1'.
    GS_FIELDCAT-SELTEXT_L      = 'Vendor Name'.
    GS_FIELDCAT-REF_TABNAME    = 'GT_FINAL2'.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'MENGE_P'.
    GS_FIELDCAT-SELTEXT_L      = 'Quantity'.
    GS_FIELDCAT-DO_SUM         = 'X' .

    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'PUR_TOTAL'.
    GS_FIELDCAT-SELTEXT_L      = 'Purchase Value W/O Tax'.
    GS_FIELDCAT-DO_SUM         = 'X' .
    GS_FIELDCAT-OUTPUTLEN     = 25.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'ACT_NO_BUD'.
    GS_FIELDCAT-SELTEXT_L      = 'Num of Bundles'.
    GS_FIELDCAT-DO_SUM         = 'X' .
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'LR_NO'.
    GS_FIELDCAT-SELTEXT_L      = 'LR Number'.
    GS_FIELDCAT-REF_TABNAME    = 'GT_FINAL2'.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'TRNS_NAME'.
    GS_FIELDCAT-SELTEXT_L      = 'Transporter'.
    GS_FIELDCAT-REF_TABNAME    = 'GT_FINAL2'.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

    GS_FIELDCAT-FIELDNAME      = 'EBELN'.
    GS_FIELDCAT-SELTEXT_L      = 'PO No'.
    GS_FIELDCAT-REF_TABNAME    = 'GT_FINAL2'.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

***********added by bhavani********
    IF P_S = 'X' .
      GS_FIELDCAT-FIELDNAME      = 'STALE_DT'.
      GS_FIELDCAT-SELTEXT_L      = 'No of Stale Days'.
      GS_FIELDCAT-REF_TABNAME    = 'GT_FINAL2'.
      APPEND GS_FIELDCAT TO LT_FIELDCAT.
      CLEAR GS_FIELDCAT.
    ENDIF .
    GS_FIELDCAT-FIELDNAME = 'SEL'.
    GS_FIELDCAT-SELTEXT_L = 'Selection'.
    GS_FIELDCAT-CHECKBOX = 'X'.
    GS_FIELDCAT-EDIT = 'X'.
    GS_FIELDCAT-TABNAME = 'GT_FINAL2'.
    APPEND GS_FIELDCAT TO LT_FIELDCAT.
    CLEAR GS_FIELDCAT.

***********end by bhavani***********

**** Dispalying ALV Report
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        I_CALLBACK_PROGRAM       = SY-REPID         " Name of the calling program
        I_CALLBACK_USER_COMMAND  = 'USER_COMMAND_SCR2'            " EXIT routine for command handling
        I_CALLBACK_PF_STATUS_SET = 'GUI_STAT'
        IS_LAYOUT                = LS_LAYOUT        " List layout specifications
        IT_FIELDCAT              = LT_FIELDCAT      " Field catalog with field descriptions
        I_DEFAULT                = 'X'              " Initial variant active/inactive logic
        I_SAVE                   = 'A'              " Variants can be saved
      TABLES
        T_OUTTAB                 = GT_FINAL2                 " Table with data to be displayed
      EXCEPTIONS
        PROGRAM_ERROR            = 1                " Program errors
        OTHERS                   = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
ENDFORM.
FORM GUI_STAT USING RT_EXTAB TYPE SLIS_T_EXTAB .

  SET PF-STATUS 'STANDARD' EXCLUDING RT_EXTAB .
  SET TITLEBAR TEXT-001 .

ENDFORM.
FORM USER_COMMAND_SCR2 USING  R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.

*********ADDED BY BHAVANI************
  DATA  : FMNAME TYPE RS38L_FNAM.
  DATA : ET_FINAL TYPE TABLE OF  ZTRANS_S .
  DATA : OK_9002 TYPE SY-UCOMM,
         BACK    TYPE SYUCOMM    VALUE 'BACK1',
         MAIL    TYPE SYUCOMM    VALUE 'MAIL',
         CANCEL  TYPE SYUCOMM  VALUE 'CANCEL1'.
  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA : SEND_REQUEST            TYPE REF TO CL_BCS,
         V_SEND_REQUEST          TYPE REF TO CL_SAPUSER_BCS,
         DOCUMENT                TYPE REF TO CL_DOCUMENT_BCS,
         RECIPIENT               TYPE REF TO IF_RECIPIENT_BCS,
         I_SENDER                TYPE REF TO IF_SENDER_BCS,
         BCS_EXCEPTION           TYPE REF TO CX_BCS,
         MAIN_TEXT               TYPE BCSY_TEXT,
         MAIN_TEXT1              TYPE BCSY_TEXT,
         LS_MAIN_TEXT            LIKE LINE OF MAIN_TEXT,
         LS_MAIN_TEXT1           LIKE LINE OF MAIN_TEXT,
         LS_TEXT                 TYPE SO_TEXT255,
         LS_TEXT1                TYPE SO_TEXT255,
         LS_TEXT2                TYPE SO_TEXT255,
         LS_TEXT3                TYPE SO_TEXT255,
         LS_TEXT4                TYPE SO_TEXT255,
         LS_TEXT5                TYPE SO_TEXT255,
         BINARY_CONTENT          TYPE SOLIX_TAB,
         SIZE                    TYPE SO_OBJ_LEN,
         SENT_TO_ALL             TYPE OS_BOOLEAN,
         SUBJECT                 TYPE SOOD-OBJDES,
         I_SUB                   TYPE SO_OBJ_DES,
         U,
*           FMNAME                  TYPE RS38L_FNAM,
         LS_OUTPUTOP             TYPE SSFCOMPOP,
         LT_PDF_DATA             TYPE SOLIX_TAB,
         LT_PDF_DATA1            TYPE SOLIX_TAB,
         LT_PDF_DATA2            TYPE SOLIX_TAB,
         LT_PDF_DATA3            TYPE SOLIX_TAB,
         LT_PDF_DATA4            TYPE SOLIX_TAB,
         LT_MAIL_BODY            TYPE SOLI_TAB,
         LT_OBJTEXT              TYPE TABLE OF SOLISTI1,
         LT_OBJPACK              TYPE TABLE OF SOPCKLSTI1,
         LT_LINES                TYPE TABLE OF TLINE,
         LT_LINES1               TYPE TABLE OF TLINE,
         LT_LINES2               TYPE TABLE OF TLINE,
         LT_LINES3               TYPE TABLE OF TLINE,
         LT_LINES4               TYPE TABLE OF TLINE,
         LT_RECORD               TYPE TABLE OF SOLISTI1,
         LT_OTF                  TYPE TSFOTF,
         LT_OTF1                 TYPE TSFOTF,
         LT_OTF2                 TYPE TSFOTF,
         LT_OTF3                 TYPE TSFOTF,
         LT_OTF4                 TYPE TSFOTF,
         LT_MAIL_SENDER          TYPE BAPIADSMTP_T,
         LT_MAIL_RECIPIENT       TYPE BAPIADSMTP_T,
         LS_CTRLOP               TYPE SSFCTRLOP,
         IS_CONTROL_PARAMETERS   TYPE SSFCTRLOP,
         IS_OUTPUT_OPTIONS       TYPE SSFCOMPOP,
         LS_DOCUMENT_OUTPUT_INFO TYPE SSFCRESPD,
         LS_JOB_OUTPUT_INFO      TYPE SSFCRESCL,
         LS_JOB_OUTPUT_OPTIONS   TYPE SSFCRESOP,
         LV_OTF                  TYPE XSTRING,
         LV_OTF1                 TYPE XSTRING,
         LV_OTF2                 TYPE XSTRING,
         LV_OTF3                 TYPE XSTRING,
         LV_OTF4                 TYPE XSTRING,
         LS_BIN_FILESIZE         TYPE SOOD-OBJLEN,
         LS_BIN_FILESIZE1        TYPE SOOD-OBJLEN,
         LS_BIN_FILESIZE2        TYPE SOOD-OBJLEN,
         LS_BIN_FILESIZE3        TYPE SOOD-OBJLEN,
         LS_BIN_FILESIZE4        TYPE SOOD-OBJLEN,
*           WA_ITOB                 TYPE ITOB,
         LV_DOC_SUBJECT          TYPE SOOD-OBJDES,
         LV_DOC_SUBJECT1         TYPE SOOD-OBJDES,
         LV_DOC_SUBJECT2         TYPE SOOD-OBJDES,
         LV_DOC_SUBJECT3         TYPE SOOD-OBJDES,
         LV_DOC_SUBJECT4         TYPE SOOD-OBJDES,
         LT_RECLIST              TYPE BCSY_SMTPA,
         LS_RECLIST              TYPE  AD_SMTPADR,
*           LS_SMAIL                TYPE ZSALES_EMAIL,
         I_ADDRESS_STRING        TYPE ADR6-SMTP_ADDR,
         ES_MSG(100)             TYPE C.
  BREAK BREDDY .
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
    IMPORTING
      E_GRID = REF_GRID.

  IF REF_GRID IS NOT INITIAL.
    CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).
  ENDIF.

*READ TABLE gt_final2 ASSIGNING FIELD-SYMBOL(<fs_fin2>) INDEX 1.
  SELECT
      ZQR_MAIL~QR_CODE ,
      ZQR_MAIL~INWD_DOC
 FROM ZQR_MAIL INTO TABLE @DATA(T_FINAL)
                   FOR ALL ENTRIES IN  @GT_FINAL2
                   WHERE QR_CODE = @GT_FINAL2-QR_CODE .
  BREAK BREDDY.

  CASE R_UCOMM .
    WHEN BACK OR CANCEL .
      LEAVE TO SCREEN 0.
    WHEN MAIL.
      REFRESH : IT_MFIN , GT_QR_MAIL.
      LOOP AT GT_FINAL2 ASSIGNING FIELD-SYMBOL(<L_CHECK>) WHERE SEL = 'X'.

        READ TABLE T_FINAL ASSIGNING FIELD-SYMBOL(<L_FINAL>) WITH KEY QR_CODE = <L_CHECK>-QR_CODE .
*        IF <L_FINAL> IS  ASSIGNED .
        IF SY-SUBRC <> 0 .
          GS_QR_MAIL-QR_CODE = <L_CHECK>-QR_CODE .
          GS_QR_MAIL-INWD_DOC = <L_CHECK>-INWD_DOC .
          GS_QR_MAIL-CREATED_BY = SY-UNAME .
          GS_QR_MAIL-CREATED_DATE = SY-DATUM .

*          WA_MFIN-QR_CODE = <L_CHECK>-QR_CODE .
          WA_MFIN-BILL_DATE = <L_CHECK>-BILL_DATE .
          WA_MFIN-BILL_NUM = <L_CHECK>-BILL_NUM .
*          WA_MFIN-LR_DATE = <L_CHECK>-LR_DATE .
*          WA_MFIN-INWD_DOC = <L_CHECK>-INWD_DOC .
          WA_MFIN-LIFNR = <L_CHECK>-LIFNR.
          WA_MFIN-NAME1 = <L_CHECK>-NAME1.
*          WA_MFIN-MENGE_P = <L_CHECK>-MENGE_P.
*          WA_MFIN-PUR_TOTAL = <L_CHECK>-PUR_TOTAL.
          WA_MFIN-ACT_NO_BUD = <L_CHECK>-ACT_NO_BUD.
          WA_MFIN-LR_NO = <L_CHECK>-LR_NO.
          WA_MFIN-TRNS_NAME = <L_CHECK>-TRNS_NAME.
*          WA_MFIN-TRNS = <L_CHECK>-TRNS.
*          WA_MFIN-EBELN = <L_CHECK>-EBELN.
          WA_MFIN-GRP = <L_CHECK>-GRP.
          APPEND WA_MFIN TO IT_MFIN.
          CLEAR :WA_MFIN.

*          IF <L_CHECK>-SEL = 'X'.
*
*          ENDIF.
          APPEND GS_QR_MAIL TO GT_QR_MAIL .
          CLEAR : GS_QR_MAIL .

        ENDIF.

*        ENDIF.

      ENDLOOP.
      LV_HED = 'Bundles In Warehouse'  .

      IF  GT_QR_MAIL IS NOT INITIAL .


        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            FORMNAME           = 'ZMM_BUN_TRANSIT_F'
          IMPORTING
            FM_NAME            = FMNAME
          EXCEPTIONS
            NO_FORM            = 1
            NO_FUNCTION_MODULE = 2
            OTHERS             = 3.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.
        CLEAR :
              LS_DOCUMENT_OUTPUT_INFO,
              LS_JOB_OUTPUT_INFO,
              LS_JOB_OUTPUT_OPTIONS.

        LS_CTRLOP-GETOTF = ABAP_TRUE.
        LS_CTRLOP-NO_DIALOG = 'X'.
        LS_CTRLOP-LANGU = SY-LANGU.

        LS_OUTPUTOP = IS_OUTPUT_OPTIONS.
        LS_OUTPUTOP-TDNOPREV = ABAP_TRUE.
        LS_OUTPUTOP-TDDEST  = 'LP01'.

        CALL FUNCTION FMNAME
          EXPORTING
            CONTROL_PARAMETERS   = LS_CTRLOP
            OUTPUT_OPTIONS       = LS_OUTPUTOP
            LV_HED               = LV_HED
            LV_HED1              = LV_HED1
            LV_HED2              = LV_HED2
          IMPORTING
            DOCUMENT_OUTPUT_INFO = LS_DOCUMENT_OUTPUT_INFO
            JOB_OUTPUT_INFO      = LS_JOB_OUTPUT_INFO
            JOB_OUTPUT_OPTIONS   = LS_JOB_OUTPUT_OPTIONS
          TABLES
            IT_MFIN              = IT_MFIN
          EXCEPTIONS
            FORMATTING_ERROR     = 1
            INTERNAL_ERROR       = 2
            SEND_ERROR           = 3
            USER_CANCELED        = 4
            OTHERS               = 5.
        IF SY-SUBRC <> 0.
**           Implement suitable error handling here
*        ENDIF.
        ELSE .
*IF PRINT_PRIEVIEW IS INITIAL.
          LT_OTF = LS_JOB_OUTPUT_INFO-OTFDATA.

*      BREAK-POINT.
          CALL FUNCTION 'CONVERT_OTF'
            EXPORTING
              FORMAT                = 'PDF'
              MAX_LINEWIDTH         = 132
            IMPORTING
              BIN_FILESIZE          = LS_BIN_FILESIZE
              BIN_FILE              = LV_OTF
            TABLES
              OTF                   = LT_OTF[]
              LINES                 = LT_LINES[]
            EXCEPTIONS
              ERR_MAX_LINEWIDTH     = 1
              ERR_FORMAT            = 2
              ERR_CONV_NOT_POSSIBLE = 3
              ERR_BAD_OTF           = 4.

*      ENDIF.

          CALL METHOD CL_DOCUMENT_BCS=>XSTRING_TO_SOLIX
            EXPORTING
              IP_XSTRING = LV_OTF
            RECEIVING
              RT_SOLIX   = LT_PDF_DATA[].


          TRY.
              REFRESH MAIN_TEXT.
*-------- create persistent send request ------------------------
              SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).
              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT = 'To,'.
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT = '<BR>'.
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT = 'All Concerned' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT = '<BR>' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT = 'Sub: Details of the bundle in the Warehouse'.
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT = '<BR>' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.



              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT =  '<BR>' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.


              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT = 'Please find the attached file .'.
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.


              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT =  '<BR>' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT =  'Note: 1. This is auto generated e-mailfrom SAP system.' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT =  '<BR>' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT =  'Clarifications contact TSG/MKTG.dept.' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT =  '<BR>' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.

              CLEAR LS_MAIN_TEXT.
              LS_MAIN_TEXT =  '2. Please do not reply to this email.For any queries or clarifications:Email to:sdp.asher@gmail.com' .
              APPEND LS_MAIN_TEXT TO MAIN_TEXT.


            CATCH CX_BCS INTO BCS_EXCEPTION.
              MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
          ENDTRY.
          CLEAR :  LV_DOC_SUBJECT.
          CONCATENATE 'Bundles In Warehouse' '.pdf' INTO LV_DOC_SUBJECT.
          TRY .
              DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                  I_TYPE    = 'HTM'
                  I_TEXT    = MAIN_TEXT
                  I_SUBJECT = LV_DOC_SUBJECT ).
            CATCH CX_DOCUMENT_BCS .
          ENDTRY.

          TRY.
              DOCUMENT->ADD_ATTACHMENT( I_ATTACHMENT_TYPE = 'BIN'
                                          I_ATTACHMENT_SUBJECT = LV_DOC_SUBJECT
                                          I_ATT_CONTENT_HEX = LT_PDF_DATA ).

            CATCH CX_DOCUMENT_BCS.
          ENDTRY.


          TRY.
*-------- create persistent send request ------------------------
              SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).
*     add document object to send request
              SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).
              V_SEND_REQUEST = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).

              CALL METHOD SEND_REQUEST->SET_SENDER
                EXPORTING
                  I_SENDER = V_SEND_REQUEST.

              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'bhabani.reddy@zietatech.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
              CLEAR I_ADDRESS_STRING.
*
              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sdp.asher@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
              CLEAR I_ADDRESS_STRING.
*
*
              RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'praveenkumar1105@gmail.com' )."( I_ADDRESS_STRING ).    ""dummyposap@gmail.com
              SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
              CLEAR I_ADDRESS_STRING.




*     ---------- SEND DOCUMENT ---------------------------------------
              SENT_TO_ALL = SEND_REQUEST->SEND( I_WITH_ERROR_SCREEN = 'X' ).

              COMMIT WORK.

              IF SENT_TO_ALL IS INITIAL.
                MESSAGE I500(SBCOMS).
              ELSE.
*        MESSAGE s022(so).
                ES_MSG = 'Email triggered successfully' ."TYPE 'S'.
              ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
            CATCH CX_BCS INTO BCS_EXCEPTION.
              MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
          ENDTRY.


          IF ES_MSG IS NOT INITIAL .
            MESSAGE 'Mail is send' TYPE 'I' .
          ENDIF .
*    ENDIF .


*    IF  GT_QR_MAIL  IS NOT INITIAL.
          MODIFY ZQR_MAIL FROM  TABLE GT_QR_MAIL .
        ENDIF.
      ENDIF.

  ENDCASE.


  CASE   R_UCOMM .
    WHEN '&IC1'.
      FIELD-SYMBOLS : <LS_FINAL2> LIKE LINE OF GT_FINAL2.
*** Read Data on Double Click
      READ TABLE GT_FINAL2 ASSIGNING <LS_FINAL2> INDEX RS_SELFIELD-TABINDEX.
      IF SY-SUBRC = 0.
        PERFORM CALL_SCREEN3 USING <LS_FINAL2>-QR_CODE.
      ENDIF.
  ENDCASE .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_FINAL1>_QR_CODE
*&---------------------------------------------------------------------*
FORM CALL_SCREEN3 USING P_QR_CODE.
  CLEAR : GS_FINAL3.
  REFRESH : GT_FINAL3.
  GT_FINAL3 = GT_ITEM.
  DELETE GT_FINAL3 WHERE QR_CODE <> P_QR_CODE.
  READ TABLE GT_FINAL3 INTO GS_FINAL3 INDEX 1.
  CALL SCREEN 9003.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLEAR_DATA.
  REFRESH : GT_FINAL3.
  CLEAR : GS_FINAL3.
ENDFORM.

FORM DISPLAY_DATA_SCR3 .

  CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYO
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE  " Excluded Toolbar Standard Functions
    CHANGING
      IT_OUTTAB                     = GT_FINAL3
      IT_FIELDCATALOG               = GT_FIELDCAT
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

FORM PREPARE_FCAT.
***  Displaying date in ALV Grid
  IF GT_FIELDCAT IS INITIAL.
*** Group Code
    GS_FIELDCAT-FIELDNAME   = 'MATKL'.
    GS_FIELDCAT-REPTEXT     = 'Category Code'.
    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
    CLEAR GS_FIELDCAT.
*** Group Des
    GS_FIELDCAT-FIELDNAME   = 'WGBEZ'.
    GS_FIELDCAT-REPTEXT     = 'Category Des'.
    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
    CLEAR GS_FIELDCAT.

*** Product Description
    GS_FIELDCAT-FIELDNAME   = 'MAKTX'.
    GS_FIELDCAT-REPTEXT     = 'Product Description'.
    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
    CLEAR GS_FIELDCAT.

*** Quantity
    GS_FIELDCAT-FIELDNAME   = 'MENGE_P'.
    GS_FIELDCAT-REPTEXT     = 'Quantity'.
    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    GS_FIELDCAT-NO_ZERO     = 'X'.
    GS_FIELDCAT-DO_SUM      = 'X'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
    CLEAR GS_FIELDCAT.

*** Rate
    GS_FIELDCAT-FIELDNAME   = 'NETPR_P'.
    GS_FIELDCAT-REPTEXT     = 'Rate per Piece'.
    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    GS_FIELDCAT-NO_ZERO     = 'X'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
    CLEAR GS_FIELDCAT.

*** Quantity
    GS_FIELDCAT-FIELDNAME   = 'NETWR_P'.
    GS_FIELDCAT-REPTEXT     = 'Purchase Value W/O Tax'.
    GS_FIELDCAT-COL_OPT     = 'X'.
    GS_FIELDCAT-TXT_FIELD   = 'X'.
    GS_FIELDCAT-NO_ZERO     = 'X'.
    GS_FIELDCAT-DO_SUM      = 'X'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
    CLEAR GS_FIELDCAT.
  ENDIF.
ENDFORM.


FORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_FIND_MORE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SUM.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_AVERAGE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
ENDFORM.
