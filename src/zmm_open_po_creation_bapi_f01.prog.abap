*&---------------------------------------------------------------------*
*& Include          ZMM_OPEN_PO_CREATION_BAPI_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
 FORM GET_FILENAME  CHANGING P_P_FILE.

   DATA: LI_FILETABLE    TYPE FILETABLE,
         LX_FILETABLE    TYPE FILE_TABLE,
         LV_RETURN_CODE  TYPE I,
         LV_WINDOW_TITLE TYPE STRING.
*   DATA : FNAME TYPE LOCALFILE,
*          ENAME TYPE CHAR4.

   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
     EXPORTING
       WINDOW_TITLE            = LV_WINDOW_TITLE
     CHANGING
       FILE_TABLE              = LI_FILETABLE
       RC                      = LV_RETURN_CODE
     EXCEPTIONS
       FILE_OPEN_DIALOG_FAILED = 1
       CNTL_ERROR              = 2
       ERROR_NO_GUI            = 3
       NOT_SUPPORTED_BY_GUI    = 4
       OTHERS                  = 5.

   LX_FILETABLE = LI_FILETABLE[ 1 ].
   P_P_FILE = LX_FILETABLE-FILENAME.

   SPLIT P_P_FILE AT '.' INTO FNAME ENAME.
   SET LOCALE LANGUAGE SY-LANGU.
   TRANSLATE ENAME TO UPPER CASE.

 ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FILE  text
*----------------------------------------------------------------------*
 FORM GET_DATA  CHANGING P_GT_FILE.
   DATA : I_TYPE    TYPE TRUXS_T_TEXT_DATA.
   DATA : LV_FILE TYPE RLGRAP-FILENAME.

   IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.
     REFRESH GT_FILE[].
     LV_FILE = P_FILE.
     CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
       EXPORTING
*        I_FIELD_SEPERATOR    =
*        I_LINE_HEADER        =
         I_TAB_RAW_DATA       = I_TYPE
         I_FILENAME           = LV_FILE
       TABLES
         I_TAB_CONVERTED_DATA = GT_FILE[]
       EXCEPTIONS
         CONVERSION_FAILED    = 1
         OTHERS               = 2.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
     BREAK CLIKHITHA.
     DELETE GT_FILE[] FROM 1 TO 2.
   ELSE.
     MESSAGE E398(00) WITH 'Invalid File Type'  .
   ENDIF.
   IF GT_FILE IS INITIAL.
     MESSAGE 'No records to upload' TYPE 'E'.
   ENDIF.
 ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FILE
*&---------------------------------------------------------------------*
 FORM PROCESS_DATA  USING    P_GT_FILE.

   DATA : IM_HEADER TYPE  TY_FILE."TY_FINAL.
   DATA : IM_HEADER_TT TYPE TABLE OF  ZPH_T_HDR,
          LV_ERNAME    TYPE ERNAM.
   DATA : LV_SIZE1 TYPE P DECIMALS 0 .
   DATA : A(13) TYPE C,
          B(13) TYPE C,
          C(13) TYPE C.

   DATA : LV_DOC TYPE ESART .
   DATA : LV_MWSK1 .
   DATA : HEADER  TYPE  BAPIMEPOHEADER,
          HEADERX TYPE  BAPIMEPOHEADERX.
   DATA : ITEM                TYPE TABLE OF BAPIMEPOITEM  WITH HEADER LINE,
          POSCHEDULE          TYPE TABLE OF BAPIMEPOSCHEDULE WITH HEADER LINE,
          POSCHEDULEX         TYPE TABLE OF BAPIMEPOSCHEDULX WITH HEADER LINE,
          ITEMX               TYPE TABLE OF BAPIMEPOITEMX  WITH HEADER LINE,
          WA_ITEMX            TYPE BAPIMEPOITEMX,
          IT_RETURN           TYPE TABLE OF BAPIRET2,
          IT_ERRORCAT         TYPE TABLE OF SLIS_T_FIELDCAT_ALV,
          WA_ERRORCAT         TYPE  SLIS_T_FIELDCAT_ALV,
          WA_RETURN           TYPE  BAPIRET2,
          POSERVICESTEXT      TYPE TABLE OF BAPIESLLTX,
          POTEXTITEM          TYPE TABLE OF BAPIMEPOTEXT,
          WA_POSERVICESTEXT   TYPE BAPIESLLTX,
          WA_POTEXTITEM       TYPE BAPIMEPOTEXT,
          IT_NO_PRICE_FROM_PO TYPE BAPIFLAG-BAPIFLAG,
          WA_NO_PRICE_FROM_PO TYPE BAPIFLAG-BAPIFLAG.

   DATA: WA_BAPIMEPOHEADER-PO_NUMBER TYPE  BAPIMEPOHEADER-PO_NUMBER.

   DATA : LV_ERROR(50)  TYPE C,
          LV_ERROR1(50) TYPE C.
   DATA : WA_PO_ITEM TYPE ZPH_T_ITEM,
          WA_ITEM    TYPE BAPIMEPOITEM,
          WA_THEADER TYPE THEAD.

   DATA : WA_LINES TYPE  TLINE,
          LINES    TYPE TABLE OF TLINE.

   DATA : LV_AMNT TYPE BAPICUREXT.
   DATA : IBAPICONDX TYPE TABLE OF BAPIMEPOCONDX WITH HEADER LINE.
   DATA : IBAPICOND TYPE TABLE OF BAPIMEPOCOND WITH HEADER LINE.


   DATA: BAPI_TE_POITEM  TYPE BAPI_TE_MEPOITEM,
         BAPI_TE_POITEMX TYPE BAPI_TE_MEPOITEMX.
   DATA : LV_FRM_SIZE TYPE ZSIZE_VAL-ZSIZE,
          WA_S_SIZE   TYPE ZSIZE_VAL-ZSIZE.
   DATA : LV_TO_SIZE TYPE ZSIZE_VAL-ZSIZE .
   DATA : POCOND     TYPE TABLE OF BAPIMEPOCOND WITH HEADER LINE,
          WA_POCOND  TYPE BAPIMEPOCOND,
          POCONDX    TYPE TABLE OF BAPIMEPOCONDX WITH HEADER LINE,
          WA_POCONDX TYPE  BAPIMEPOCONDX.
   DATA : IT_FIN    TYPE TABLE OF TY_FILE,
          IT_FINAL1 TYPE TABLE OF TY_FILE,
          WA_FINAL1 TYPE   TY_FILE,
          IT_FINAL2 TYPE TABLE OF TY_FILE,
          WA_FINAL2 TYPE   TY_FILE,
          IT_FINAL3 TYPE TABLE OF TY_FILE,
          WA_FINAL3 TYPE   TY_FILE.
   DATA : LV_TEBELN(40) TYPE C.
   DATA : LV_TEX(20) TYPE C.

   FIELD-SYMBOLS: <LS_FILE>    TYPE TY_FILE.
   FIELD-SYMBOLS: <LS_HDR>    TYPE TY_FILE.
*   FIELD-SYMBOLS:
   DATA(GT_HDR) = GT_FILE.
   DATA : WA_FINAL TYPE TY_FILE,
          IT_FINAL TYPE TABLE OF TY_FILE.

*****************   added (31-1-20)   ************************
*SELECT
*    VENDOR
*    PGROUP
*    PUR_GROUP
*    INDENT_NO
*    PDATE
*    SUP_SAL_NO
*    SUP_NAME
*    VENDOR_NAME
*    TRANSPORTER
*    VENDOR_LOCATION
*    DELIVERY_AT
*    LEAD_TIME
*    E_MSG
*    S_MSG
*  FROM ZPH_T_HDR INTO TABLE IT_HDdR
*          FOR ALL ENTRIES IN it_fin
*          WHERE PDATE = it_fin-PDATE.
***************************end  (31-1-20)  ****************


   SORT  GT_HDR BY INDENT_NO.
   DELETE ADJACENT DUPLICATES FROM GT_HDR COMPARING INDENT_NO.
   CHECK GT_HDR IS NOT INITIAL.

   CLEAR : SL_ITEM .
   SL_ITEM = '10'.
   SELECT EBELN
       ZINDENT
       FROM EKKO
       INTO TABLE IT_EKKO
       FOR ALL ENTRIES IN GT_HDR
       WHERE ZINDENT = GT_HDR-INDENT_NO.
*   loop at gt_file ASSIGNING FIELD-SYMBOL(<gs_file>).
   LOOP AT GT_HDR ASSIGNING <LS_HDR>.
     REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
*     READ TABLE gt_hdr ASSIGNING <ls_hdr> with key INDENT_NO = <gs_file>-INDENT_NO.
     READ TABLE IT_EKKO ASSIGNING FIELD-SYMBOL(<LS_EKKO>) WITH KEY ZINDENT = <LS_HDR>-INDENT_NO.
     IF SY-SUBRC = 0.
       APPEND VALUE #( INDENT = <LS_HDR>-INDENT_NO  TYPE = 'E' MESSAGE = 'PO is already Created with this Indent' ) TO GIT_DISPLAY.
       CONTINUE.
     ENDIF.
     WA_FINAL-INDENT_NO        =  <LS_HDR>-INDENT_NO .
     WA_FINAL-PDATE            =  <LS_HDR>-PDATE.
     WA_FINAL-SUP_SAL_NO       =  <LS_HDR>-SUP_SAL_NO.
     WA_FINAL-SUP_NAME         =  <LS_HDR>-SUP_NAME.

     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         INPUT  = <LS_HDR>-VENDOR
       IMPORTING
         OUTPUT = <LS_HDR>-VENDOR.
     WA_FINAL-VENDOR           =  <LS_HDR>-VENDOR   .
*     WA_FINAL-VENDOR_LOCATION  =  <LS_HDR>-VENDOR_LOCATION.
     WA_FINAL-DELIVERY_AT      = <LS_HDR>-DELIVERY_AT.
     WA_FINAL-LEAD_TIME        =  <LS_HDR>-LEAD_TIME .
     WA_FINAL-PUR_GROUP        =  <LS_HDR>-PUR_GROUP .
     APPEND WA_FINAL TO IT_FINAL.
     CLEAR : WA_FINAL .

     HEADER-PUR_GROUP =  <LS_HDR>-PUR_GROUP ."IM_HEADER-PUR_GROUP .
     HEADERX-PUR_GROUP = 'X'.
     HEADER-DOC_DATE  =  <LS_HDR>-PDATE.":SY-DATUM .
     HEADERX-DOC_DATE  = 'X'.
     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         INPUT  = <LS_HDR>-VENDOR
       IMPORTING
         OUTPUT = <LS_HDR>-VENDOR.
     HEADER-VENDOR = <LS_HDR>-VENDOR   ."IM_HEADER-VENDOR .
     HEADERX-VENDOR = 'X' .
*     READ TABLE IT_FINAL INTO WA_FINAL INDEX 1.
     WA_EXTENSIONIN-STRUCTURE  = 'BAPI_TE_MEPOHEADER'.
     BAPI_TE_PO-PO_NUMBER      = ' '.
     BAPI_TE_PO-ZINDENT          = <LS_HDR>-INDENT_NO .
     BAPI_TE_PO-USER_NAME          = <LS_HDR>-SUP_NAME   .
     WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_PO.
     APPEND WA_EXTENSIONIN TO EXTENSIONIN.

     WA_EXTENSIONIN-STRUCTURE  = 'BAPI_TE_MEPOHEADERX'.
     BAPI_TE_POX-PO_NUMBER     = ' '.
     BAPI_TE_POX-ZINDENT  = 'X'.
     BAPI_TE_POX-USER_NAME  = 'X'.
     WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POX.
     APPEND WA_EXTENSIONIN TO EXTENSIONIN.
     CLEAR WA_EXTENSIONIN.

     REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[] .
     LOOP AT GT_FILE ASSIGNING <LS_FILE> WHERE INDENT_NO = <LS_HDR>-INDENT_NO.
       REFRESH :IT_FINAL3.
       IF SY-SUBRC = 0.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = <LS_FILE>-VENDOR
           IMPORTING
             OUTPUT = <LS_FILE>-VENDOR.
       ENDIF.
       WA_FINAL3-INDENT_NO     = <LS_FILE>-INDENT_NO .
       WA_FINAL3-CATEGORY_CODE     = <LS_FILE>-CATEGORY_CODE .
       WA_FINAL3-STYLE     = <LS_FILE>-STYLE.
       WA_FINAL3-FROM_SIZE     = <LS_FILE>-FROM_SIZE.
       WA_FINAL3-TO_SIZE     = <LS_FILE>-TO_SIZE.
       WA_FINAL3-COLOR     = <LS_FILE>-COLOR.
       WA_FINAL3-QUANTITY     = <LS_FILE>-QUANTITY.
       WA_FINAL3-PRICE     = <LS_FILE>-PRICE.
       WA_FINAL3-REMARKS   = <LS_FILE>-REMARKS.
       WA_FINAL3-ITEM   = <LS_FILE>-ITEM.

       APPEND WA_FINAL3 TO IT_FINAL3 .
       CLEAR : WA_FINAL3 .

*   endloop.

*     LOOP AT it_item ASSIGNING FIELD-SYMBOL(<LS_item>) WHERE INDENT_NO = <LS_HDR>-INDENT_NO.
       IT_FIN[] = IT_FINAL[] .
       READ  TABLE IT_FIN INTO IM_HEADER INDEX 1.
*       LOOP at it_fin INTO  IM_HEADER.
       IT_FINAL2[] = IT_FINAL[] .
       SELECT
         MARA~MATKL ,
         MARA~BRAND_ID FROM MARA INTO TABLE @DATA(IT_BRAND)
                  FOR ALL ENTRIES IN @IT_FINAL3
                  WHERE MATKL = @IT_FINAL3-CATEGORY_CODE AND BRAND_ID NE ' '.
       IF SY-SUBRC <> 0.
         APPEND VALUE #( INDENT = <LS_HDR>-INDENT_NO  TYPE = 'E' MESSAGE = 'Category Not available' ) TO GIT_DISPLAY.
         REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
         EXIT.
       ENDIF.
       IF  IT_FINAL3 IS NOT INITIAL.
         TYPES :
           BEGIN OF TY_CAT_SIZE,
             ITEM  TYPE EBELP,
             MATKL TYPE MARA-MATKL,
             SIZE  TYPE MARA-SIZE1,
           END OF TY_CAT_SIZE.
         DATA : LT_CAT_SIZE TYPE STANDARD TABLE OF TY_CAT_SIZE,
                R_RANGE     TYPE RANGE OF WRF_ATWRT.
         SELECT * FROM ZSIZE_VAL INTO TABLE @DATA(LT_SIZE).
         REFRESH : LT_CAT_SIZE, R_RANGE.
         LOOP AT IT_FINAL3 ASSIGNING FIELD-SYMBOL(<LS_FINAL3>).
           IF <LS_FINAL3>-FROM_SIZE IS NOT INITIAL.
             DATA(LV_ITEM) = SY-TABIX * 10.
             READ TABLE LT_SIZE WITH KEY ZSIZE = <LS_FINAL3>-FROM_SIZE TRANSPORTING NO FIELDS.
             DATA(LV_FROM) = SY-TABIX.
             READ TABLE LT_SIZE WITH KEY ZSIZE = <LS_FINAL3>-TO_SIZE TRANSPORTING NO FIELDS.
             DATA(LV_TO) = SY-TABIX.
             IF LV_TO IS NOT INITIAL .
               LOOP AT LT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>) FROM LV_FROM TO LV_TO.
                 APPEND VALUE #( SIGN  = 'I' OPTION = 'EQ' LOW = <LS_SIZE>-ZSIZE ) TO R_RANGE.
                 APPEND VALUE #( ITEM = LV_ITEM MATKL = <LS_FINAL3>-CATEGORY_CODE SIZE = <LS_SIZE>-ZSIZE ) TO LT_CAT_SIZE.
               ENDLOOP.
             ELSE.
               READ TABLE LT_SIZE ASSIGNING <LS_SIZE> INDEX LV_FROM.
               IF SY-SUBRC = 0.
                 APPEND VALUE #( SIGN  = 'I' OPTION = 'EQ' LOW = <LS_SIZE>-ZSIZE ) TO R_RANGE.
                 APPEND VALUE #( ITEM  = LV_ITEM MATKL = <LS_FINAL3>-CATEGORY_CODE SIZE = <LS_SIZE>-ZSIZE ) TO LT_CAT_SIZE.
               ENDIF.
             ENDIF.
           ELSE.
             APPEND VALUE #( SIGN  = 'I' OPTION = 'EQ' LOW = SPACE ) TO R_RANGE.
             APPEND VALUE #( ITEM = LV_ITEM MATKL = <LS_FINAL3>-CATEGORY_CODE SIZE = SPACE  ) TO LT_CAT_SIZE.
           ENDIF.
         ENDLOOP.
         SORT R_RANGE BY LOW.
         DELETE ADJACENT DUPLICATES FROM R_RANGE COMPARING LOW.
         SORT LT_CAT_SIZE BY ITEM MATKL SIZE.
         DELETE ADJACENT DUPLICATES FROM LT_CAT_SIZE COMPARING ITEM MATKL SIZE.
         BREAK SAMBURI.
         IF IT_BRAND IS  INITIAL .
           SELECT MATNR
                  MATKL
                  SIZE1
                  ZZPRICE_FRM
                  ZZPRICE_TO
                  MEINS
                  BSTME FROM MARA INTO TABLE IT_MARA
                 FOR ALL ENTRIES IN IT_FINAL3
                 WHERE MATKL = IT_FINAL3-CATEGORY_CODE
                 AND ZZPRICE_FRM  <= IT_FINAL3-PRICE  AND ZZPRICE_TO  >= IT_FINAL3-PRICE
                 AND SIZE1 IN R_RANGE
                 AND MSTAE = ' ' .

           IF SY-SUBRC <> 0.
             APPEND VALUE #( INDENT = <LS_HDR>-INDENT_NO  TYPE = 'E' MESSAGE = 'Category Not available' ) TO GIT_DISPLAY.
             REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
             EXIT.
           ENDIF.
         ELSE.
           BREAK CLIKHITHA.
           SELECT MATNR
                  MATKL
                  SIZE1
                  ZZPRICE_FRM
                  ZZPRICE_TO
                  MEINS
                  BSTME FROM MARA
                  INTO TABLE IT_MARA
                  FOR ALL ENTRIES IN IT_FINAL3
                  WHERE MATKL = IT_FINAL3-CATEGORY_CODE
             AND SIZE1 IN R_RANGE
                  AND   MARA~MSTAE = ' ' .

           IF SY-SUBRC <> 0.
             APPEND VALUE #( INDENT = <LS_HDR>-INDENT_NO  TYPE = 'E' MESSAGE = 'Category Not available' ) TO GIT_DISPLAY.
             REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
             EXIT.
           ENDIF.
         ENDIF.
*ENDIF.

         SELECT MATNR
                MATKL
                SIZE1
                ZZPRICE_FRM
                ZZPRICE_TO
                MEINS
                BSTME
            FROM MARA INTO TABLE IT_MARA
           FOR ALL ENTRIES IN IT_FINAL3
           WHERE MATKL = IT_FINAL3-CATEGORY_CODE
           AND SIZE1 IN R_RANGE AND MSTAE = ' '.

         IF SY-SUBRC <> 0.
           APPEND VALUE #( INDENT = <LS_HDR>-INDENT_NO  TYPE = 'E' MESSAGE = 'Category Not available' ) TO GIT_DISPLAY.
           REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
           EXIT.
         ENDIF.



       ENDIF .
       IF IT_FINAL3 IS NOT INITIAL .
         SELECT MARA~MATNR,
               MARA~MATKL,
               MARA~SIZE1,
               MARA~ZZPRICE_FRM,
               MARA~ZZPRICE_TO ,
               MARA~MEINS,
               MARA~BSTME
               INTO TABLE @DATA(LT_SET)
               FROM MARA AS MARA
               FOR ALL ENTRIES IN @IT_FINAL3
               WHERE MARA~MATKL = @IT_FINAL3-CATEGORY_CODE
                AND   MARA~MSTAE = ' ' .
         DELETE LT_SET WHERE MEINS <> C_SET .
       ENDIF .

       IF LT_SET IS NOT INITIAL .
         SELECT MAST~MATNR,
            MAST~WERKS,
            MAST~STLNR,
            MAST~STLAL,
            STPO~STLKN,
            STPO~IDNRK,
            STPO~POSNR,
            STPO~MENGE,
            STPO~MATKL,
            STPO~MEINS
            INTO TABLE @DATA(LT_COMP)
            FROM MAST AS MAST
            INNER JOIN STPO AS STPO ON STPO~STLTY = @C_M AND MAST~STLNR = STPO~STLNR
            FOR ALL ENTRIES IN @LT_SET
            WHERE MAST~MATNR = @LT_SET-MATNR.
       ENDIF.
       SELECT SINGLE
          LFA1~REGIO FROM LFA1 INTO  @DATA(LS_LFA1)
            WHERE LIFNR = @IM_HEADER-VENDOR.       " 0(10) added by likhitha

*         IF Lt_mara IS NOT INITIAL .
*           SELECT
*           A792~WKREG ,
*           A792~REGIO ,
*           A792~STEUC ,
*           A792~KNUMH ,
*           MARC~MATNR ,
*           T001W~WERKS
*            FROM MARC AS MARC
*            INNER JOIN A792 AS A792 ON MARC~STEUC  = A792~STEUC
*            INNER JOIN T001W AS T001W ON MARC~WERKS = T001W~WERKS
*            INTO TABLE @DATA(IT_HSN)
*            FOR ALL ENTRIES IN @LT_MARA
*            WHERE MARC~MATNR = @LT_MARA-MATNR
*            AND A792~REGIO   = @LS_LFA1
*            AND T001W~WERKS = @IM_HEADER-VENDOR_LOCATION.
*         ENDIF .

       IF IT_MARA IS NOT INITIAL .
         SELECT
         A792~WKREG ,
         A792~REGIO ,
         A792~STEUC ,
         A792~KNUMH ,
         MARC~MATNR ,
         T001W~WERKS
          FROM MARC AS MARC
          INNER JOIN A792 AS A792 ON MARC~STEUC  = A792~STEUC
          INNER JOIN T001W AS T001W ON MARC~WERKS = T001W~WERKS
          INTO TABLE @DATA(IT_HSN)
           FOR ALL ENTRIES IN @IT_MARA
          WHERE MARC~MATNR = @IT_MARA-MATNR
          AND A792~REGIO   = @LS_LFA1
*          AND T001W~WERKS = @IM_HEADER-VENDOR_LOCATION.
           AND T001W~WERKS = @IM_HEADER-DELIVERY_AT.        " ADDED (4-2-20)
       ENDIF .

       IF LT_COMP IS NOT INITIAL.
         SELECT
        A792~WKREG ,
        A792~REGIO ,
        A792~STEUC ,
        A792~KNUMH ,
        MARC~MATNR ,
        T001W~WERKS
         FROM MARC AS MARC
         INNER JOIN A792 AS A792 ON MARC~STEUC  = A792~STEUC
         INNER JOIN T001W AS T001W ON MARC~WERKS = T001W~WERKS
         INTO TABLE @DATA(IT_HSN_S)
         FOR ALL ENTRIES IN @LT_COMP
         WHERE MARC~MATNR = @LT_COMP-IDNRK
         AND A792~REGIO   = @LS_LFA1
*         AND T001W~WERKS = @IM_HEADER-VENDOR_LOCATION.
           AND T001W~WERKS = @IM_HEADER-DELIVERY_AT.   " ADDED (4-2-20)
       ENDIF.
       BREAK CLIKHITHA.
       IF IT_HSN IS NOT INITIAL .
         SELECT
           KONP~KNUMH ,
           KONP~MWSK1 FROM KONP INTO TABLE @DATA(IT_KONP)
                      FOR ALL ENTRIES IN @IT_HSN
                      WHERE KNUMH = @IT_HSN-KNUMH .
       ENDIF .

       IF IT_HSN_S IS NOT INITIAL .
         SELECT
           KONP~KNUMH,
           KONP~MWSK1 FROM KONP INTO TABLE @DATA(IT_KONP_S)
                      FOR ALL ENTRIES IN @IT_HSN_S
                      WHERE KNUMH = @IT_HSN_S-KNUMH .
       ENDIF .

       IF IM_HEADER-VENDOR IS NOT INITIAL .
         SELECT SINGLE
          LFA1~ADRNR FROM LFA1 INTO @DATA(P_ADRNR)
                     WHERE LIFNR = @IM_HEADER-VENDOR .

       ENDIF .

       IF P_ADRNR IS NOT INITIAL .
         SELECT SINGLE
           ADRC~ADDRNUMBER ,
           ADRC~CITY1 FROM ADRC INTO @DATA(WA_CITY)
                   WHERE ADDRNUMBER = @P_ADRNR .
       ENDIF .

       IF WA_CITY-CITY1 = 'CHENNAI'.

         LV_DOC = 'ZLOP' .

       ELSE .

         LV_DOC = 'ZOSP'.

       ENDIF.

       HEADER-COMP_CODE = '1000' .
       HEADERX-COMP_CODE = 'X'.
       HEADER-CREAT_DATE = SY-DATUM .
       HEADERX-CREAT_DATE = 'X' .

       DATA: LV_LIFNR TYPE LFA1-LIFNR.
       DATA: LV_LIFNR1 TYPE LFA1-LIFNR.
       DATA: LV_ZZTEMP_VENDOR TYPE LFA1-ZZTEMP_VENDOR.

       SELECT SINGLE
              LIFNR
        FROM LFA1 INTO LV_LIFNR
         WHERE LIFNR = IM_HEADER-VENDOR.
       IF LV_LIFNR IS INITIAL.

         SELECT SINGLE LIFNR ZZTEMP_VENDOR FROM LFA1 INTO ( LV_LIFNR1 , LV_ZZTEMP_VENDOR ) WHERE ZZTEMP_VENDOR = IM_HEADER-VENDOR.
         HEADER-VENDOR = LV_LIFNR1.
       ELSE.
         IF SY-SUBRC = 0.
           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
             EXPORTING
               INPUT  = IM_HEADER-VENDOR
             IMPORTING
               OUTPUT = IM_HEADER-VENDOR.
         ENDIF.
         HEADER-VENDOR = IM_HEADER-VENDOR .                     " commented
*          HEADER-VENDOR = wa_vendor-lifnr.
       ENDIF.

       HEADERX-VENDOR = 'X' .
       HEADER-DOC_TYPE = LV_DOC .
       HEADERX-DOC_TYPE = 'X' .
       HEADER-LANGU = SY-LANGU .
       HEADER-LANGU = 'X' .
       HEADER-PURCH_ORG = '1000'.
       HEADERX-PURCH_ORG = 'X'.
       HEADER-PUR_GROUP =  IM_HEADER-PUR_GROUP .
       HEADERX-PUR_GROUP =  'X' .

*        IF <S_FINAL2> IS NOT INITIAL.
*          WA_NO_PRICE_FROM_PO = <S_FINAL2>-BAPIFLAG.
*          WA_NO_PRICE_FROM_PO = 'X'.
*        ENDIF.

*       READ TABLE IT_FINAL1 INTO WA_FINAL1 INDEX 1.                        " ADDED BY LIKHITHA
       WA_EXTENSIONIN-STRUCTURE  = 'BAPI_TE_MEPOHEADER'.
       BAPI_TE_PO-PO_NUMBER      = ' '.
       BAPI_TE_PO-ZINDENT          = <LS_HDR>-INDENT_NO .
       BAPI_TE_PO-USER_NAME          = <LS_HDR>-SUP_NAME.         " ADDED BY LIKHITHA
       WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_PO.
       APPEND WA_EXTENSIONIN TO EXTENSIONIN.

       WA_EXTENSIONIN-STRUCTURE  = 'BAPI_TE_MEPOHEADERX'.
       BAPI_TE_POX-PO_NUMBER     = ' '.
       BAPI_TE_POX-ZINDENT  = 'X'.
       BAPI_TE_POX-USER_NAME  = 'X'.                    " ADDED BY LIKHITHA
       WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POX.
       APPEND WA_EXTENSIONIN TO EXTENSIONIN.
       CLEAR WA_EXTENSIONIN.

       BREAK BREDDY .
       DATA LV_LINE TYPE EBELP .
       DATA : LV_TEXT1     TYPE ZTEXT,
              LV_TEXT2     TYPE ZP_REMARKS, "ZREMARK,                        " ADDED BY LIKHITHA
              LV_PRICE(11) TYPE C.
       REFRESH : IT_RETURN .
*   endloop.
       LOOP AT IT_FINAL3 ASSIGNING FIELD-SYMBOL(<LS_FIN>).
         LV_PRICE = <LS_FIN>-PRICE .
         CONDENSE LV_PRICE .
         DATA(LV_INDEX) = SY-TABIX.
*                                       DATA(LT_COUNT) = LT_MARA.
         DATA(LT_COUNT) = IT_MARA.
         DELETE LT_COUNT WHERE MATKL <> <LS_FIN>-CATEGORY_CODE.

         READ TABLE IT_BRAND ASSIGNING FIELD-SYMBOL(<LS_BRAND>) WITH KEY MATKL = <LS_FIN>-CATEGORY_CODE .
         IF SY-SUBRC NE 0.
           DELETE LT_COUNT WHERE ZZPRICE_FRM > <LS_FIN>-PRICE.
           DELETE LT_COUNT WHERE ZZPRICE_TO < <LS_FIN>-PRICE.
         ENDIF.
         CLEAR : LV_COUNT.
         IF <LS_FIN>-FROM_SIZE IS NOT INITIAL.
           IF <LS_FIN>-FROM_SIZE <> C_SET .
             LOOP AT LT_COUNT ASSIGNING FIELD-SYMBOL(<LS_MARA>) WHERE MATKL = <LS_FIN>-CATEGORY_CODE.
               READ TABLE LT_CAT_SIZE ASSIGNING FIELD-SYMBOL(<LS_CA_SIZE>) WITH KEY MATKL = <LS_FIN>-CATEGORY_CODE SIZE = <LS_MARA>-SIZE1 ITEM = <LS_FIN>-ITEM.
               IF SY-SUBRC = 0.
                 CHECK IT_BRAND IS INITIAL.
                 IF <LS_MARA>-ZZPRICE_FRM LE <LS_FIN>-PRICE AND <LS_MARA>-ZZPRICE_TO GE <LS_FIN>-PRICE.
                 ELSE.
                   <LS_MARA>-MATKL = 'XXX'.
                 ENDIF.
               ELSE.
                 <LS_MARA>-MATKL = 'XXX'.
               ENDIF.
             ENDLOOP.
           ENDIF.
         ENDIF.
         DELETE LT_COUNT WHERE MATKL = 'XXX'.
         DESCRIBE TABLE LT_COUNT LINES LV_COUNT.

         IF LT_COUNT IS INITIAL.

*           MESSAGE 'No material found' TYPE 'E' .
           WA_RETURN-TYPE = 'E'.
         ENDIF.
         IF <LS_FIN>-FROM_SIZE = C_SET .
           SORT LT_SET BY MATKL MATNR .
           LOOP AT LT_SET ASSIGNING FIELD-SYMBOL(<LS_MARP>) WHERE MATKL = <LS_FIN>-CATEGORY_CODE.

             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
               EXPORTING
                 INPUT  = <LS_MARP>-MATNR
               IMPORTING
                 OUTPUT = <LS_MARP>-MATNR.

             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
               EXPORTING
                 INPUT  = WA_ITEM-PO_ITEM
               IMPORTING
                 OUTPUT = WA_ITEM-PO_ITEM.
             WA_ITEM-PO_ITEM = WA_ITEMX-PO_ITEM =  SL_ITEM.
             SORT LT_COMP BY MATNR STLNR STLKN IDNRK POSNR .
             LOOP AT LT_COMP ASSIGNING FIELD-SYMBOL(<LS_COMP>) WHERE MATNR = <LS_MARP>-MATNR.

               READ TABLE IT_HSN_S ASSIGNING FIELD-SYMBOL(<LS_HSN_S>) WITH KEY MATNR = <LS_COMP>-IDNRK .
               IF SY-SUBRC = 0.
                 CLEAR :  LV_MWSK1 .
                 READ TABLE IT_KONP_S ASSIGNING FIELD-SYMBOL(<LT_KONP_S>) WITH KEY KNUMH = <LS_HSN_S>-KNUMH .
                 IF SY-SUBRC = 0.
                   WA_ITEM-TAX_CODE = <LT_KONP_S>-MWSK1.
                   WA_ITEMX-TAX_CODE = 'X'.
                   LV_MWSK1 = <LT_KONP_S>-MWSK1.
                 ENDIF.
               ENDIF.

               DATA(LT_COMP_T) = LT_COMP.
               DELETE LT_COMP_T WHERE MATNR <> <LS_MARP>-MATNR.
               DESCRIBE TABLE LT_COMP_T LINES DATA(LV_LINESC).
               WA_ITEM-PO_ITEM = WA_ITEMX-PO_ITEM =  SL_ITEM.
               SHIFT <LS_MARP>-MATNR LEFT DELETING LEADING '0'.
               WA_ITEM-MATERIAL_LONG      = <LS_COMP>-IDNRK.
               WA_ITEMX-MATERIAL_LONG  = C_X.
               WA_ITEM-QUANTITY      =  <LS_FIN>-QUANTITY / LV_LINESC .
               C = WA_ITEM-QUANTITY .
               CONDENSE C .
               SPLIT C AT '.' INTO A B .

               WA_ITEM-QUANTITY = A .
               WA_ITEMX-QUANTITY         =  C_X .
*               WA_ITEM-PLANT         =   IM_HEADER-VENDOR_LOCATION.
               WA_ITEM-PLANT = IM_HEADER-DELIVERY_AT.    "ADDED (4-2-20)
               WA_ITEMX-PLANT         =   C_X .
               WA_ITEM-STGE_LOC = 'FG01' .
               WA_ITEMX-STGE_LOC = 'X' .
               WA_ITEM-NET_PRICE     = <LS_FIN>-PRICE .
               WA_ITEMX-NET_PRICE = 'X'.
               WA_ITEM-IR_IND = 'X'.
               WA_ITEMX-IR_IND = 'X'.
               WA_ITEM-GR_BASEDIV = 'X'.
               WA_ITEMX-GR_BASEDIV = 'X'.

               WA_POTEXTITEM-PO_ITEM = SL_ITEM.
               WA_POTEXTITEM-TEXT_ID = 'F03'.
               WA_POTEXTITEM-TEXT_FORM = '*'.
               WA_POTEXTITEM-TEXT_LINE = <LS_FIN>-REMARKS.
               APPEND WA_POTEXTITEM TO POTEXTITEM.

               WA_POTEXTITEM-PO_ITEM = SL_ITEM.
               WA_POTEXTITEM-TEXT_ID = 'F08'.
               WA_POTEXTITEM-TEXT_FORM = '*'.
               WA_POTEXTITEM-TEXT_LINE = <LS_FIN>-COLOR.
               APPEND WA_POTEXTITEM TO POTEXTITEM.

               WA_POTEXTITEM-PO_ITEM = SL_ITEM.
               WA_POTEXTITEM-TEXT_ID = 'F07'.
               WA_POTEXTITEM-TEXT_FORM = '*'.
               WA_POTEXTITEM-TEXT_LINE = <LS_FIN>-STYLE.
               APPEND WA_POTEXTITEM TO POTEXTITEM.
               MOVE <LS_FIN>-REMARKS TO LV_TEXT2.              " added by likhitha
               CONCATENATE <LS_FIN>-ITEM <LS_FIN>-CATEGORY_CODE <LS_FIN>-STYLE  <LS_FIN>-FROM_SIZE <LS_FIN>-TO_SIZE  <LS_FIN>-COLOR LV_PRICE  INTO LV_TEXT1 .

               CLEAR :BAPI_TE_POITEM ,BAPI_TE_POITEMX.
               WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEM'.
               BAPI_TE_POITEM-PO_ITEM  = SL_ITEM.
               BAPI_TE_POITEM-ZZTEXT100  = LV_TEXT1.
               BAPI_TE_POITEM-ZZREMARKS  = <LS_FIN>-REMARKS.              " ADDED BY LIKHITHA
               WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEM.
               APPEND WA_EXTENSIONIN TO EXTENSIONIN.
               CLEAR : WA_EXTENSIONIN.
               WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEMX'.
               BAPI_TE_POITEMX-PO_ITEM = SL_ITEM.
               BAPI_TE_POITEMX-ZZTEXT100 = C_X.
               BAPI_TE_POITEMX-ZZREMARKS = C_X.                    " ADDED BY LIKHITHA
               WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEMX.
               APPEND WA_EXTENSIONIN TO EXTENSIONIN.
               CLEAR WA_EXTENSIONIN.

*                                             CLEAR : LV_TEXT .
               WA_ITEM-PLAN_DEL = IM_HEADER-LEAD_TIME.
               WA_ITEMX-PLAN_DEL = 'X'.

               WA_ITEM-OVER_DLV_TOL  = '10'.           ""tolerance
               WA_ITEMX-OVER_DLV_TOL  = 'X'.           ""tolerance

               APPEND WA_ITEM TO ITEM[].
               APPEND WA_ITEMX TO ITEMX[].
               WA_POCOND-COND_TYPE = 'PBXX' .
               WA_POCOND-COND_VALUE = <LS_FIN>-PRICE  / 10.
               WA_POCOND-ITM_NUMBER = WA_ITEM-PO_ITEM  .
               WA_POCOND-CHANGE_ID = 'U' .
               WA_POCONDX-COND_TYPE = 'X' .
               WA_POCONDX-COND_VALUE = 'X' .
               WA_POCONDX-ITM_NUMBER = 'X' .
               WA_POCONDX-CHANGE_ID = 'X' .

               APPEND WA_POCOND TO POCOND[] .
               APPEND WA_POCONDX TO POCONDX[] .
               CLEAR : WA_ITEM,WA_ITEMX ,WA_POCOND,WA_POCONDX ,A , B ,C.

               SL_ITEM =  SL_ITEM + 10 .
*               endloop.
             ENDLOOP.
           ENDLOOP.
         ELSE .
           CLEAR : LV_MWSK1 .
           SORT LT_COUNT BY MATKL MATNR .
           DATA(LT_SIZE1) = LT_COUNT[].
           SORT LT_SIZE1 BY MATKL MATNR.
           DELETE ADJACENT DUPLICATES FROM LT_SIZE1 COMPARING MATKL MATNR.
           DESCRIBE TABLE LT_SIZE1 LINES DATA(LV_SIZE) .
***         End of Changes By Suri : 20.12.2019
           LOOP AT LT_COUNT ASSIGNING <LS_MARP> WHERE MATKL = <LS_FIN>-CATEGORY_CODE.
             WA_ITEM-PO_ITEM = WA_ITEMX-PO_ITEM =  SL_ITEM.
             READ TABLE IT_HSN ASSIGNING FIELD-SYMBOL(<LS_HSNB>) WITH KEY MATNR = <LS_MARP>-MATNR .
             IF SY-SUBRC = 0.
               READ TABLE IT_KONP ASSIGNING FIELD-SYMBOL(<LS_KONPB>) WITH KEY KNUMH = <LS_HSNB>-KNUMH .
               IF SY-SUBRC = 0.

                 WA_ITEM-TAX_CODE = <LS_KONPB>-MWSK1.
                 LV_MWSK1 = <LS_KONPB>-MWSK1 .
                 WA_ITEMX-TAX_CODE = 'X'.
               ENDIF.
             ENDIF.

             WA_ITEM-MATERIAL_LONG = <LS_MARP>-MATNR .
             WA_ITEMX-MATERIAL_LONG  = C_X.
             WA_ITEM-PO_UNIT       = <LS_MARP>-MEINS.
             WA_ITEM-QUANTITY       =  <LS_FIN>-QUANTITY / LV_SIZE .
             C = WA_ITEM-QUANTITY .
             CONDENSE C .
             SPLIT C AT '.' INTO A B .
             WA_ITEM-QUANTITY = A .
             WA_ITEMX-QUANTITY         =  C_X .
*             WA_ITEM-PLANT         =   IM_HEADER-VENDOR_LOCATION.
             WA_ITEM-PLANT         =   IM_HEADER-DELIVERY_AT.     " ADDED (4-1-20)
             WA_ITEMX-PLANT         =   C_X .
             WA_ITEM-STGE_LOC = 'FG01' .
             WA_ITEMX-STGE_LOC = 'X' .
             WA_ITEM-NET_PRICE     = <LS_FIN>-PRICE .
             WA_ITEMX-NET_PRICE = 'X'.
             WA_ITEM-IR_IND = 'X'.
             WA_ITEMX-IR_IND = 'X'.
             WA_ITEM-GR_BASEDIV = 'X'.
             WA_ITEMX-GR_BASEDIV = 'X'.

             WA_POTEXTITEM-PO_ITEM = SL_ITEM.
             WA_POTEXTITEM-TEXT_ID = 'F03'.
             WA_POTEXTITEM-TEXT_FORM = '*'.
             WA_POTEXTITEM-TEXT_LINE = <LS_FIN>-REMARKS.
             APPEND WA_POTEXTITEM TO POTEXTITEM.

             WA_POTEXTITEM-PO_ITEM = SL_ITEM.
             WA_POTEXTITEM-TEXT_ID = 'F08'.
             WA_POTEXTITEM-TEXT_FORM = '*'.
             WA_POTEXTITEM-TEXT_LINE = <LS_FIN>-COLOR.
             APPEND WA_POTEXTITEM TO POTEXTITEM.

             WA_POTEXTITEM-PO_ITEM = SL_ITEM.
             WA_POTEXTITEM-TEXT_ID = 'F07'.
             WA_POTEXTITEM-TEXT_FORM = '*'.
             WA_POTEXTITEM-TEXT_LINE = <LS_FIN>-STYLE.
             APPEND WA_POTEXTITEM TO POTEXTITEM.

             CONCATENATE <LS_FIN>-ITEM <LS_FIN>-CATEGORY_CODE <LS_FIN>-STYLE  <LS_FIN>-FROM_SIZE <LS_FIN>-TO_SIZE  <LS_FIN>-COLOR LV_PRICE  INTO LV_TEXT1 .

             WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEM'.
             BAPI_TE_POITEM-PO_ITEM  = SL_ITEM.
             BAPI_TE_POITEM-ZZTEXT100  = LV_TEXT1.
             BAPI_TE_POITEM-ZZREMARKS  = <LS_FIN>-REMARKS.                  " added by likhitha
             BAPI_TE_POITEM-ZZCOLOR    = <LS_FIN>-COLOR.                    " Added by likhitha
             BAPI_TE_POITEM-ZZSTYLE    = <LS_FIN>-STYLE.                    " ADDED BY LIKHITHA
             WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEM.

             APPEND WA_EXTENSIONIN TO EXTENSIONIN.
             CLEAR : WA_EXTENSIONIN.

             WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEMX'.
             BAPI_TE_POITEMX-PO_ITEM = SL_ITEM.
             BAPI_TE_POITEMX-ZZTEXT100 = C_X.
             BAPI_TE_POITEMX-ZZREMARKS = C_X.                         " ADDED BY LIKHHITHA TO UBDATE IN EKPO
             BAPI_TE_POITEMX-ZZCOLOR  = C_X.                         " added by likhitha
             BAPI_TE_POITEMX-ZZSTYLE = C_X.                            " added by likhitha
             WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEMX.
             APPEND WA_EXTENSIONIN TO EXTENSIONIN.
             CLEAR WA_EXTENSIONIN.

*                                           CLEAR : LV_TEXT .
             WA_ITEM-PLAN_DEL = IM_HEADER-LEAD_TIME.
             WA_ITEMX-PLAN_DEL = 'X'.

             WA_ITEM-OVER_DLV_TOL  = '10'.           ""tolerance
             WA_ITEMX-OVER_DLV_TOL  = 'X'.           ""tolerance

             APPEND WA_ITEM TO ITEM[].
             APPEND WA_ITEMX TO ITEMX[].
             WA_POCOND-COND_TYPE = 'PBXX' .
             WA_POCOND-COND_VALUE = <LS_FIN>-PRICE  / 10.
             WA_POCOND-ITM_NUMBER = WA_ITEM-PO_ITEM  .
             WA_POCOND-CHANGE_ID = 'U' .
             WA_POCONDX-COND_TYPE = 'X' .
             WA_POCONDX-COND_VALUE = 'X' .
             WA_POCONDX-ITM_NUMBER = 'X' .
             WA_POCONDX-CHANGE_ID = 'X' .
             APPEND WA_POCOND TO POCOND[] .
             APPEND WA_POCONDX TO POCONDX[] .
             CLEAR : WA_ITEM,WA_ITEMX ,WA_POCOND,WA_POCONDX ,A , B ,C.
             SL_ITEM =  SL_ITEM + 10 .
*             endloop.   " addedddddddddd
           ENDLOOP .
         ENDIF .
       ENDLOOP.
*       ENDLOOP.

       DATA(IT_TAX) = ITEM[] .
     ENDLOOP.

     READ TABLE IT_TAX  WITH KEY TAX_CODE = SPACE TRANSPORTING NO FIELDS.
*       IF   SY-SUBRC = 0 .
     IF   SY-SUBRC <> 0 ."AND FLAG NE 'X'.      " commented by likhitha
       CALL FUNCTION 'BAPI_PO_CREATE1'
         EXPORTING
           POHEADER         = HEADER
           POHEADERX        = HEADERX
*          NO_PRICE_FROM_PO = WA_NO_PRICE_FROM_PO                  " added by likhitha
         IMPORTING
           EXPPURCHASEORDER = LV_EBELN
         TABLES
           RETURN           = IT_RETURN[]
           POITEM           = ITEM[]
           POITEMX          = ITEMX[]
           POCOND           = POCOND[]
           POCONDX          = POCONDX[]
           EXTENSIONIN      = EXTENSIONIN[]
           POTEXTITEM       = POTEXTITEM[].
*         endloop.
*       ELSE.
     ELSE.
       APPEND VALUE #( INDENT = <LS_HDR>-INDENT_NO  TYPE = 'E' MESSAGE = 'Po tax is not maintained' ) TO GIT_DISPLAY.
       REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
       CONTINUE.
     ENDIF.

     LOOP AT  IT_RETURN INTO WA_RETURN.
       IF WA_RETURN-TYPE = 'S' .
         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
           EXPORTING
             WAIT = 'X'.
         GWA_DISPLAY-INDENT = <LS_HDR>-INDENT_NO.
         GWA_DISPLAY-PO_NUM = LV_EBELN.
         GWA_DISPLAY-TYPE = WA_RETURN-TYPE.
         GWA_DISPLAY-MESSAGE = WA_RETURN-MESSAGE.
         APPEND GWA_DISPLAY TO GIT_DISPLAY.
         CLEAR GWA_DISPLAY.
         REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
*      else.
       ELSEIF WA_RETURN-TYPE = 'E' .
*            GWA_DISPLAY-SNO = <ls_fin>-SNO.
         GWA_DISPLAY-INDENT = <LS_HDR>-INDENT_NO.
         GWA_DISPLAY-PO_NUM = LV_EBELN."WA_POTEXTITEM-PO_NUMBER."WA_BAPIMEPOHEADER-PO_NUMBER.
         GWA_DISPLAY-TYPE = WA_RETURN-TYPE.
         GWA_DISPLAY-MESSAGE = WA_RETURN-MESSAGE.
         APPEND GWA_DISPLAY TO GIT_DISPLAY.
         CLEAR GWA_DISPLAY.

         CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
         REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
       ENDIF.
     ENDLOOP.
*     endif.
     REFRESH  : IT_RETURN[] ,ITEM[] ,ITEMX[] , POCOND[] ,  POCONDX[] ,  EXTENSIONIN[], POTEXTITEM[].
   ENDLOOP.

 ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CATLOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
 FORM FIELD_CATLOG ."CHANGING FP_I_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
   BREAK CLIKHITHA.
***   PERFORM CREATE_FIELDCAT USING:
***            '01' '01' 'INDENT'        'GIT_DISPLAY' 'L' 'INDENT',
***           '01' '02' 'PO_NUM'   'GIT_DISPLAY' 'L' 'PO_NUM',
***           '01' '03' 'TYPE'      'GIT_DISPLAY' 'L' 'TYPE',
***           '01' '04' 'MESSAGE'   'GIT_DISPLAY' 'L' 'MESSAGE'.
   WA_FCAT-FIELDNAME            = 'INDENT'.
   WA_FCAT-TABNAME              = 'GIT_DISPLAY'.
   WA_FCAT-SELTEXT_M            = 'INDENT'.
   WA_FCAT-OUTPUTLEN            = 30.
*  WA_FCAT-JUST                 = 'C'.
   APPEND WA_FCAT TO LT_FIELDCAT.
   CLEAR WA_FCAT.

   WA_FCAT-FIELDNAME            = 'PO_NUM'.
   WA_FCAT-TABNAME              = 'GIT_DISPLAY'.
   WA_FCAT-SELTEXT_M            = 'PO NUMBER'.
   WA_FCAT-OUTPUTLEN            = 20.
*  WA_FCAT-JUST                 = 'C'.
   APPEND WA_FCAT TO LT_FIELDCAT.
   CLEAR WA_FCAT.

   WA_FCAT-FIELDNAME            = 'TYPE'.
   WA_FCAT-TABNAME              = 'GIT_DISPLAY'.
   WA_FCAT-SELTEXT_M            = 'TYPE'.
   WA_FCAT-OUTPUTLEN            = 10.
*  WA_FCAT-JUST                 = 'C'.
   APPEND WA_FCAT TO LT_FIELDCAT.
   CLEAR WA_FCAT.

   WA_FCAT-FIELDNAME            = 'MESSAGE'.
   WA_FCAT-TABNAME              = 'GIT_DISPLAY'.
   WA_FCAT-SELTEXT_M            = 'MESSAGE'.
   WA_FCAT-OUTPUTLEN            = 50.
*  WA_FCAT-JUST                 = 'C'.
   APPEND WA_FCAT TO LT_FIELDCAT.
   CLEAR WA_FCAT.


 ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
 FORM CREATE_FIELDCAT  USING   FP_ROWPOS    TYPE SYCUROW
                             FP_COLPOS    TYPE SYCUCOL
                             FP_FLDNAM    TYPE FIELDNAME
                             FP_TABNAM    TYPE TABNAME
                             FP_JUSTIF    TYPE CHAR1
                             FP_SELTEXT   TYPE DD03P-SCRTEXT_L..

*   DATA : WA_FCAT     TYPE SLIS_FIELDCAT_ALV,
*          LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
   WA_FCAT-ROW_POS        =  FP_ROWPOS.     "Row
   WA_FCAT-COL_POS        =  FP_COLPOS.     "Column
   WA_FCAT-FIELDNAME      =  FP_FLDNAM.     "Field Name
   WA_FCAT-TABNAME        =  FP_TABNAM.     "Internal Table Name
   WA_FCAT-JUST           =  FP_JUSTIF.     "Screen Justified
   WA_FCAT-SELTEXT_L      =  FP_SELTEXT.    "Field Text

   APPEND WA_FCAT TO LT_FIELDCAT.

   CLEAR WA_FCAT.

 ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
 FORM DISPLAY_OUTPUT .
   BREAK CLIKHITHA.
   DATA: L_REPID            TYPE SYREPID,
         I_CALLBACK_PROGRAM TYPE SY-REPID.
   IF GIT_DISPLAY IS NOT INITIAL.
*    WA_LAYOUT-ZEBRA = 'X'.
*    WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
     CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
*        I_INTERFACE_CHECK  = ' '
*        I_BYPASSING_BUFFER = ' '
*        I_BUFFER_ACTIVE    = ' '
         I_CALLBACK_PROGRAM = I_CALLBACK_PROGRAM
*        I_CALLBACK_PF_STATUS_SET          = ' '
*        I_CALLBACK_USER_COMMAND           = ' '
*        I_CALLBACK_TOP_OF_PAGE            = ' '
*        I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*        I_CALLBACK_HTML_END_OF_LIST       = ' '
*        I_STRUCTURE_NAME   =
*        I_BACKGROUND_ID    = ' '
*        I_GRID_TITLE       =
*        I_GRID_SETTINGS    =
         IS_LAYOUT          = LS_LAYOUT
         IT_FIELDCAT        = LT_FIELDCAT
*        IT_EXCLUDING       =
*        IT_SPECIAL_GROUPS  =
*        IT_SORT            =
*        IT_FILTER          =
*        IS_SEL_HIDE        =
*        I_DEFAULT          = 'X'
         I_SAVE             = 'X'
*        IS_VARIANT         =
*        IT_EVENTS          =
*        IT_EVENT_EXIT      =
*        IS_PRINT           =
*        IS_REPREP_ID       =
*        I_SCREEN_START_COLUMN             = 0
*        I_SCREEN_START_LINE               = 0
*        I_SCREEN_END_COLUMN               = 0
*        I_SCREEN_END_LINE  = 0
*        I_HTML_HEIGHT_TOP  = 0
*        I_HTML_HEIGHT_END  = 0
*        IT_ALV_GRAPHICS    =
*        IT_HYPERLINK       =
*        IT_ADD_FIELDCAT    =
*        IT_EXCEPT_QINFO    =
*        IR_SALV_FULLSCREEN_ADAPTER        =
*        O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*        E_EXIT_CAUSED_BY_CALLER           =
*        ES_EXIT_CAUSED_BY_USER            =
       TABLES
         T_OUTTAB           = GIT_DISPLAY
       EXCEPTIONS
         PROGRAM_ERROR      = 1
         OTHERS             = 2.
     IF SY-SUBRC <> 0.
* Implement suitable error handling here
     ENDIF.
   ENDIF.
 ENDFORM.
