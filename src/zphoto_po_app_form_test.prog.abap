*&---------------------------------------------------------------------*
*& Include          ZPHOTO_PO_APP_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HDR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM HDR_DATA .
*  PERFORM HDR_DATA .
  SELECT
    VENDOR
    PGROUP
    PUR_GROUP
    INDENT_NO
    PDATE
    SUP_SAL_NO
    SUP_NAME
    VENDOR_NAME
    TRANSPORTER
    VENDOR_LOCATION
    DELIVERY_AT
    LEAD_TIME
    E_MSG
    S_MSG  FROM ZPH_T_HDR INTO TABLE IT_HDR
          WHERE PDATE IN S_DATE .

  IF IT_HDR IS NOT INITIAL .
    SELECT
      EKKO~ZINDENT FROM EKKO INTO TABLE @DATA(IT_EKKO)
              FOR ALL ENTRIES IN @IT_HDR
             WHERE ZINDENT = @IT_HDR-INDENT_NO.

    SELECT
      ZPH_T_ITEM~E_MSG ,
      ZPH_T_ITEM~INDENT_NO ,
      ZPH_T_ITEM~S_MSG FROM ZPH_T_ITEM INTO TABLE @DATA(LT_MSGS)
                       FOR ALL ENTRIES IN @IT_HDR
                       WHERE INDENT_NO  = @IT_HDR-INDENT_NO .

  ENDIF .
  LOOP AT IT_HDR ASSIGNING FIELD-SYMBOL(<LS_HDR>).
    WA_FINAL-VENDOR               = <LS_HDR>-VENDOR .
    WA_FINAL-PGROUP               = <LS_HDR>-PGROUP .
    WA_FINAL-PUR_GROUP            = <LS_HDR>-PUR_GROUP .
    WA_FINAL-INDENT_NO            = <LS_HDR>-INDENT_NO .
    WA_FINAL-PDATE                = <LS_HDR>-PDATE .
    WA_FINAL-SUP_SAL_NO           = <LS_HDR>-SUP_SAL_NO .
    WA_FINAL-SUP_NAME             = <LS_HDR>-SUP_NAME .
    WA_FINAL-VENDOR_NAME          = <LS_HDR>-VENDOR_NAME .
    WA_FINAL-TRANSPORTER          = <LS_HDR>-TRANSPORTER .
    WA_FINAL-VENDOR_LOCATION      = <LS_HDR>-VENDOR_LOCATION .
    WA_FINAL-DELIVERY_AT          = <LS_HDR>-DELIVERY_AT .
    WA_FINAL-LEAD_TIME            = <LS_HDR>-LEAD_TIME .
    WA_FINAL-E_MSG                = <LS_HDR>-E_MSG .
    WA_FINAL-S_MSG                = <LS_HDR>-S_MSG .

    READ TABLE LT_MSGS ASSIGNING FIELD-SYMBOL(<LS_MSGS>) WITH KEY INDENT_NO = <LS_HDR>-INDENT_NO .

    IF SY-SUBRC = 0.
      IF WA_FINAL-E_MSG IS INITIAL .
        IF <LS_MSGS>-E_MSG IS NOT INITIAL .
          WA_FINAL-E_MSG  = 'Item data have Errors' .
        ENDIF .
      ENDIF .
      IF  WA_FINAL-E_MSG IS NOT INITIAL OR <LS_MSGS>-E_MSG IS NOT INITIAL .
        WA_CELLCOLOR-FNAME = 'E_MSG' .
        WA_CELLCOLOR-COLOR-COL = 6. "color code 1-7, if outside rage defaults to 7
        WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
        WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour
        APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
        CLEAR WA_CELLCOLOR.

      ELSEIF WA_FINAL-S_MSG IS NOT INITIAL .
        WA_CELLCOLOR-FNAME = 'S_MSG' .
        WA_CELLCOLOR-COLOR-COL = 5. "color code 1-7, if outside rage defaults to 7
        WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
        WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour
        APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
        CLEAR WA_CELLCOLOR.
      ENDIF.
    ENDIF.
    IF IT_FINAL IS INITIAL .

      READ TABLE IT_EKKO ASSIGNING FIELD-SYMBOL(<ES_EKKO>) WITH KEY ZINDENT = <LS_HDR>-INDENT_NO .
      IF SY-SUBRC NE 0 .
        APPEND WA_FINAL TO IT_FINAL.
      ENDIF .
      CLEAR : WA_FINAL .

    ELSE .

      READ TABLE IT_EKKO ASSIGNING FIELD-SYMBOL(<LS_EKKO>) WITH KEY ZINDENT = <LS_HDR>-INDENT_NO .
      IF SY-SUBRC NE 0 .
        APPEND WA_FINAL TO IT_FINAL.
      ENDIF .
      CLEAR : WA_FINAL .

    ENDIF .
  ENDLOOP.

  PERFORM DISPLAY .

ENDFORM .
FORM GUI_STAT USING RT_EXTAB TYPE SLIS_T_EXTAB .

*  SET PF-STATUS 'ZSTATUS' EXCLUDING RT_EXTAB .
*BREAK BREDDY .
  SET PF-STATUS 'ZSTANDARD' EXCLUDING RT_EXTAB .
***  SET TITLEBAR TEXT-001 .

ENDFORM.
FORM USER_COMMAND_SCR2 USING  R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.
*  BREAK BREDDY .

  IF LV_EBELN IS NOT INITIAL .
    SELECT
      EKKO~EBELN ,
    EKKO~ZINDENT FROM EKKO INTO TABLE @DATA(IT_EKKO1)
           WHERE EBELN = @LV_EBELN.
  ENDIF .


  CASE   R_UCOMM .
    WHEN '&IC1'.
      FIELD-SYMBOLS : <LS_FINAL> LIKE LINE OF IT_FINAL.
      READ TABLE IT_FINAL ASSIGNING <LS_FINAL> INDEX RS_SELFIELD-TABINDEX.
      IF SY-SUBRC = 0.
        PERFORM CALL_SCREEN2 USING  <LS_FINAL>-INDENT_NO  .
      ENDIF.
    WHEN 'REFRESH' .
*      BREAK BREDDY .
      REFRESH : IT_FINAL , IT_HDR  .

      SELECT
     VENDOR
     PGROUP
     PUR_GROUP
     INDENT_NO
     PDATE
     SUP_SAL_NO
     SUP_NAME
     VENDOR_NAME
     TRANSPORTER
     VENDOR_LOCATION
     DELIVERY_AT
     LEAD_TIME
     E_MSG
     S_MSG  FROM ZPH_T_HDR INTO TABLE IT_HDR
           WHERE PDATE IN S_DATE .

      IF IT_HDR IS NOT INITIAL .
        SELECT
          EKKO~ZINDENT FROM EKKO INTO TABLE @DATA(IT_EKKO)
                  FOR ALL ENTRIES IN @IT_HDR
                 WHERE ZINDENT = @IT_HDR-INDENT_NO.

        SELECT
          ZPH_T_ITEM~E_MSG ,
          ZPH_T_ITEM~INDENT_NO ,
          ZPH_T_ITEM~S_MSG FROM ZPH_T_ITEM INTO TABLE @DATA(LT_MSGS)
                           FOR ALL ENTRIES IN @IT_HDR
                           WHERE INDENT_NO  = @IT_HDR-INDENT_NO .

      ENDIF .
      LOOP AT IT_HDR ASSIGNING FIELD-SYMBOL(<LS_HDR>).
        WA_FINAL-VENDOR               = <LS_HDR>-VENDOR .
        WA_FINAL-PGROUP               = <LS_HDR>-PGROUP .
        WA_FINAL-PUR_GROUP            = <LS_HDR>-PUR_GROUP .
        WA_FINAL-INDENT_NO            = <LS_HDR>-INDENT_NO .
        WA_FINAL-PDATE                = <LS_HDR>-PDATE .
        WA_FINAL-SUP_SAL_NO           = <LS_HDR>-SUP_SAL_NO .
        WA_FINAL-SUP_NAME             = <LS_HDR>-SUP_NAME .
        WA_FINAL-VENDOR_NAME          = <LS_HDR>-VENDOR_NAME .
        WA_FINAL-TRANSPORTER          = <LS_HDR>-TRANSPORTER .
        WA_FINAL-VENDOR_LOCATION      = <LS_HDR>-VENDOR_LOCATION .
        WA_FINAL-DELIVERY_AT          = <LS_HDR>-DELIVERY_AT .
        WA_FINAL-LEAD_TIME            = <LS_HDR>-LEAD_TIME .
        WA_FINAL-E_MSG                = <LS_HDR>-E_MSG .
        WA_FINAL-S_MSG                = <LS_HDR>-S_MSG .


        READ TABLE LT_MSGS ASSIGNING FIELD-SYMBOL(<LS_MSGS>) WITH KEY INDENT_NO = <LS_HDR>-INDENT_NO .

        IF SY-SUBRC = 0.
          IF WA_FINAL-E_MSG IS INITIAL .
            IF <LS_MSGS>-E_MSG IS NOT INITIAL .
              WA_FINAL-E_MSG  = 'Item data have Errors' .
            ENDIF .
          ENDIF .
          IF  WA_FINAL-E_MSG IS NOT INITIAL OR <LS_MSGS>-E_MSG IS NOT INITIAL .
            WA_CELLCOLOR-FNAME = 'E_MSG' .
            WA_CELLCOLOR-COLOR-COL = 6. "color code 1-7, if outside rage defaults to 7
            WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
            WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour
            APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
            CLEAR WA_CELLCOLOR.

          ELSEIF WA_FINAL-S_MSG IS NOT INITIAL .
            WA_CELLCOLOR-FNAME = 'S_MSG' .
            WA_CELLCOLOR-COLOR-COL = 5. "color code 1-7, if outside rage defaults to 7
            WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
            WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour
            APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
            CLEAR WA_CELLCOLOR.
          ENDIF.
        ENDIF.
        IF IT_FINAL IS INITIAL .

          READ TABLE IT_EKKO ASSIGNING FIELD-SYMBOL(<ES_EKKO>) WITH KEY ZINDENT = <LS_HDR>-INDENT_NO .
          IF SY-SUBRC NE 0 .
            APPEND WA_FINAL TO IT_FINAL.
          ENDIF .
          CLEAR : WA_FINAL .

        ELSE .

          READ TABLE IT_EKKO ASSIGNING FIELD-SYMBOL(<LS_EKKO>) WITH KEY ZINDENT = <LS_HDR>-INDENT_NO .
          IF SY-SUBRC NE 0 .
            APPEND WA_FINAL TO IT_FINAL.
          ENDIF .
          CLEAR : WA_FINAL .

        ENDIF .
      ENDLOOP.

      PERFORM DISPLAY .
    WHEN 'BACK_B'OR 'EXIT_C' OR 'CANCEL_C'.
      PERFORM : CLEAR_DATA.
      LEAVE PROGRAM .
  ENDCASE .
ENDFORM .
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_FINAL>_VENDOR
*&---------------------------------------------------------------------*
FORM CALL_SCREEN2  USING    P_INDENT.
  CLEAR : LV_EBELN .
*  BREAK BREDDY .
  CLEAR : WA_FINAL1 .
  REFRESH : IT_FINAL1.
  IT_FINAL1 = IT_FINAL.
  DELETE IT_FINAL1 WHERE INDENT_NO <> P_INDENT .

  SELECT
    INDENT_NO
    VENDOR
    PGROUP
    ITEM
    CATEGORY_CODE
    STYLE
    FROM_SIZE
    TO_SIZE
    COLOR
    QUANTITY
    PRICE
    REMARKS
    E_MSG
    S_MSG
    ZTEXT100
    FROM ZPH_T_ITEM INTO TABLE IT_ITEM
          FOR ALL ENTRIES IN IT_FINAL1
          WHERE INDENT_NO = IT_FINAL1-INDENT_NO
          AND   PGROUP = IT_FINAL1-PGROUP .
*          AND   INDENT_NO NE ' '.

  SELECT
    MARA~MATNR FROM MARA INTO TABLE @DATA(IT_MARA)
               FOR ALL ENTRIES IN @IT_ITEM
               WHERE MATKL = @IT_ITEM-CATEGORY_CODE .

  LOOP AT IT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).

    WA_FINAL2-ITEM = SY-TABIX * 10.
    WA_FINAL2-VENDOR = <LS_ITEM>-VENDOR .
    WA_FINAL2-INDENT_NO = <LS_ITEM>-INDENT_NO .
    WA_FINAL2-PGROUP = <LS_ITEM>-PGROUP.
    WA_FINAL2-CATEGORY_CODE = <LS_ITEM>-CATEGORY_CODE.
    WA_FINAL2-STYLE = <LS_ITEM>-STYLE.
    WA_FINAL2-TO_SIZE = <LS_ITEM>-TO_SIZE.
    WA_FINAL2-FROM_SIZE = <LS_ITEM>-FROM_SIZE .
    WA_FINAL2-COLOR = <LS_ITEM>-COLOR.
    WA_FINAL2-QUANTITY = <LS_ITEM>-QUANTITY.
    WA_FINAL2-PRICE = <LS_ITEM>-PRICE.
    WA_FINAL2-REMARKS = <LS_ITEM>-REMARKS.
    WA_FINAL2-E_MSG = <LS_ITEM>-E_MSG.
    WA_FINAL2-S_MSG = <LS_ITEM>-S_MSG.
    WA_FINAL2-ZTEXT100 = <LS_ITEM>-ZTEXT100.
    LV_VENDOR = <LS_ITEM>-VENDOR.

    APPEND WA_FINAL2 TO IT_FINAL2 .
    CLEAR : WA_FINAL2 .
  ENDLOOP.
  CALL SCREEN 9000.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS 'ZGUI_9000'.
  SET TITLEBAR 'TITLE'.
  CLEAR :GV_SUBRC.

  IF CONTAINER IS NOT BOUND.
    CREATE OBJECT CONTAINER
      EXPORTING
        CONTAINER_NAME = 'MYCONTAINER'.
    CREATE OBJECT GRID
      EXPORTING
        I_PARENT = CONTAINER.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
    PERFORM PREPARE_FCAT.
    PERFORM DISPLAY_DATA_SCR3.
  ELSE.

    IF IT_FINAL1 IS NOT INITIAL.
      IF GRID IS BOUND.
        DATA: IS_STABLE TYPE LVC_S_STBL, LV_LINES TYPE INT2.
        IS_STABLE = 'XX'.
        IF GRID IS BOUND.
          CALL METHOD GRID->REFRESH_TABLE_DISPLAY
            EXPORTING
              IS_STABLE = IS_STABLE               " With Stable Rows/Columns
            EXCEPTIONS
              FINISHED  = 1                       " Display was Ended (by Export)
              OTHERS    = 2.
          IF SY-SUBRC <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.
*  BREAK BREDDY .



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
*  DATA(OK_CODE) = OK_9003.
*  CLEAR :OK_9003.

*  BREAK BREDDY.

  DATA : LV_INDENT TYPE ZINDENT .
  DATA :    C_SAVE   TYPE SYUCOMM  VALUE 'SAVE'.
  CLEAR: LV_INDENT .
  IF LV_EBELN IS NOT INITIAL .
    SELECT SINGLE
      EKKO~ZINDENT FROM EKKO INTO  LV_INDENT
                   WHERE EBELN = LV_EBELN .
  ENDIF .

  CASE OK_CODE.
    WHEN C_BACK OR C_CANCEL OR C_EXIT.
      PERFORM : CLEAR_DATA.
      DELETE IT_FINAL WHERE INDENT_NO = LV_INDENT .
      PERFORM DISPLAY .

      LEAVE TO SCREEN 0.
    WHEN C_SAVE.
      DATA : HEADER  LIKE BAPIMEPOHEADER,
             HEADERX LIKE BAPIMEPOHEADERX.
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
             WA_NO_PRICE_FROM_PO TYPE BAPIFLAG-BAPIFLAG.


      DATA : LV_TEBELN(40) TYPE C.
      DATA : LV_TEX(20) TYPE C.
      DATA : LV_ERROR(50)  TYPE C,
             LV_ERROR1(50) TYPE C.
      DATA : WA_PO_ITEM TYPE ZPH_T_ITEM,
             WA_ITEM    TYPE BAPIMEPOITEM,
             WA_THEADER TYPE THEAD,
*         IT_LFA1    TYPE TABLE OF TY_LFA1,
*         WA_LFA1    TYPE TY_LFA1,
             WA_T500W   TYPE T500W.
*         WA_T001W   TYPE TY_T001W,
*         IT_A792    TYPE TABLE OF TY_A792,
*         WA_A792    TYPE TY_A792.

      DATA : WA_LINES TYPE  TLINE,
             LINES    TYPE TABLE OF TLINE,
             LV_TEXT  TYPE TDOBNAME,
             LV_MATNR TYPE CHAR40.
      DATA : LV_AMNT TYPE BAPICUREXT.
      DATA : IBAPICONDX TYPE TABLE OF BAPIMEPOCONDX WITH HEADER LINE.
      DATA : IBAPICOND TYPE TABLE OF BAPIMEPOCOND WITH HEADER LINE.
      DATA : IM_HEADER TYPE  TY_FINAL.
      DATA : IM_HEADER_TT TYPE TABLE OF  ZPH_T_HDR,
*      DATA : LV_POITEM TYPE EBELP,
             LV_ERNAME    TYPE ERNAM.
      DATA : LV_SIZE1 TYPE P DECIMALS 0 .
      DATA : a(13) TYPE C,
             b(13) TYPE C,
             c(13) TYPE C.

      DATA : LV_DOC TYPE ESART .
      DATA : LV_MWSK1 .
      DATA:
        BAPI_TE_POITEM  TYPE BAPI_TE_MEPOITEM,
        BAPI_TE_POITEMX TYPE BAPI_TE_MEPOITEMX.
      DATA : LV_FRM_SIZE TYPE ZSIZE_VAL-ZSIZE,
             WA_S_SIZE   TYPE ZSIZE_VAL-ZSIZE.
      DATA : LV_TO_SIZE TYPE ZSIZE_VAL-ZSIZE .
      DATA : POCOND     TYPE TABLE OF BAPIMEPOCOND WITH HEADER LINE,
             WA_POCOND  TYPE BAPIMEPOCOND,
             POCONDX    TYPE TABLE OF BAPIMEPOCONDX WITH HEADER LINE,
             WA_POCONDX TYPE  BAPIMEPOCONDX.

      REFRESH: ITEM[] ,    ITEMX[] , POCOND[] ,POCONDX[] ,EXTENSIONIN[] , POTEXTITEM[].
*      BREAK BREDDY .
      IT_FIN[] = IT_FINAL1[] .
*      DELETE IT_FIN WHERE VENDOR = LV_INDENT .

      READ  TABLE IT_FIN INTO IM_HEADER INDEX 1.
      IT_FINAL3[] = IT_FINAL2[] .


*      BREAK BREDDY .
      CLEAR  : WA_EKKO .
      READ TABLE IT_FINAL2 ASSIGNING FIELD-SYMBOL(<S_FINAL2>) INDEX 1 .
      IF SY-SUBRC = 0 .
        SELECT SINGLE
          ZINDENT
*          USER_NAME
           FROM EKKO INTO WA_EKKO
                     WHERE   ZINDENT =  <S_FINAL2>-INDENT_NO .

      ENDIF .
*      IF LV_EBELN IS INITIAL .
      IF WA_EKKO-ZINDENT IS INITIAL.
        SELECT
          MARA~MATKL ,
          MARA~BRAND_ID FROM MARA INTO TABLE @DATA(IT_BRAND)
                   FOR ALL ENTRIES IN @IT_FINAL3
                   WHERE MATKL = @IT_FINAL3-CATEGORY_CODE AND BRAND_ID NE ' '.
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
          SORT  LT_SIZE BY ZITEM.
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
***   End of Changes By Suri : 25.11.2019
*break KKIRTI.
          IF IT_BRAND IS  INITIAL .
            SELECT MARA~MATNR,
                   MARA~MATKL,                   MARA~SIZE1,
                   MARA~ZZPRICE_FRM,
                   MARA~ZZPRICE_TO ,
                   MARA~MEINS,
                   MARA~BSTME
                   INTO TABLE @DATA(LT_MARA)
                   FROM MARA AS MARA
                   FOR ALL ENTRIES IN @IT_FINAL3
                   WHERE MARA~MATKL = @IT_FINAL3-CATEGORY_CODE
                   AND ZZPRICE_FRM <= @IT_FINAL3-PRICE     AND ZZPRICE_TO  >= @IT_FINAL3-PRICE
                  AND MARA~SIZE1 IN @R_RANGE
                  AND   MARA~MSTAE = ' ' .
          ELSE.
*** Test : SS
            SELECT MARA~MATNR,
                   MARA~MATKL,
                   MARA~SIZE1,
                   MARA~ZZPRICE_FRM,
                   MARA~ZZPRICE_TO ,
                   MARA~MEINS,
                   MARA~BSTME
                   INTO TABLE @LT_MARA
                   FROM MARA AS MARA
                   FOR ALL ENTRIES IN @IT_FINAL3
                   WHERE MARA~MATKL = @IT_FINAL3-CATEGORY_CODE
                   AND MARA~SIZE1 IN @R_RANGE
                   AND   MARA~MSTAE = ' ' .
***   END OF CHANGES BY SURI : 25.11.2019
*** Test : SS
          ENDIF .
        ENDIF .
*********only for set materials added by bhavani***************
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
********Ended by bhavani 28.11.2019***************************


**********************        ADDED ON (12-2-20)   ********************
**        SELECT zph_t_hdr~vendor,
**               mara~matnr,
**               ZPH_T_ITEM~category_codE
**               FROM MARA AS MARA
**               INNER JOIN ZPH_T_ITEM AS ZPH_T_ITEM ON MARA~MATKL = ZPH_T_ITEM~category_codE
**              INTO TABLE @DATA(IT_CATT)
**          FOR ALL ENTRIES IN
*
*IF IT_HDR-VENDOR IS NOT INITIAL  AND IT_ITEM-VENDOR IS NOT INITIAL.
*     SELECT KAPPL
*            KSCHL
*            LIFNR
*            MATNR
*            KFRST
*            KNUMH
*            FROM A502 INTO IT_A502
*            FOR ALL ENTRIES IN zph_t_ITEM
*            WHERE LIFNR = IT_ITEM-VENDOR.
*       ENDIF.
*
*********        END (12-2-20)  ********************


        SELECT SINGLE
           LFA1~REGIO FROM LFA1 INTO  @DATA(LS_LFA1)
             WHERE LIFNR = @IM_HEADER-VENDOR .

        IF LT_MARA IS NOT INITIAL .
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
           FOR ALL ENTRIES IN @LT_MARA
           WHERE MARC~MATNR = @LT_MARA-MATNR
           AND A792~REGIO   = @LS_LFA1
           AND T001W~WERKS = @IM_HEADER-DELIVERY_AT.
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
*           INNER JOIN STPO AS STPO ON MARC~MATNR = STPO~IDNRK
           INNER JOIN A792 AS A792 ON MARC~STEUC  = A792~STEUC
           INNER JOIN T001W AS T001W ON MARC~WERKS = T001W~WERKS
           INTO TABLE @DATA(IT_HSN_S)
           FOR ALL ENTRIES IN @LT_COMP
           WHERE MARC~MATNR = @LT_COMP-IDNRK
           AND A792~REGIO   = @LS_LFA1
           AND T001W~WERKS = @IM_HEADER-DELIVERY_AT.

        ENDIF.
        IF IT_HSN IS NOT INITIAL .
          SELECT
            KONP~KNUMH ,
            KONP~MWSK1 FROM KONP INTO TABLE @DATA(IT_KONP)
                       FOR ALL ENTRIES IN @IT_HSN
                       WHERE KNUMH = @IT_HSN-KNUMH .
        ENDIF .


        IF IT_HSN_S IS NOT INITIAL .
          SELECT
            KONP~KNUMH ,
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


        IF SY-SUBRC = 0.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = IM_HEADER-VENDOR
            IMPORTING
              OUTPUT = IM_HEADER-VENDOR.
        ENDIF.

        HEADER-COMP_CODE = '1000' .
        HEADERX-COMP_CODE = 'X'.
        IF IM_HEADER-PDATE IS NOT INITIAL.
          HEADER-DOC_DATE =  IM_HEADER-PDATE.
        ELSE.
          HEADER-DOC_DATE = SY-DATUM .
        ENDIF.
        HEADERX-DOC_DATE = 'X' .
        HEADER-CREAT_DATE = SY-DATUM .
        HEADERX-CREAT_DATE = 'X' .
        HEADER-VENDOR = IM_HEADER-VENDOR .
        HEADERX-VENDOR = 'X' .
        HEADER-DOC_TYPE = LV_DOC .
        HEADERX-DOC_TYPE = 'X' .
        HEADER-LANGU = SY-LANGU .
        HEADER-LANGU = 'X' .
        HEADER-PURCH_ORG = '1000'.
        HEADERX-PURCH_ORG = 'X'.
        HEADER-PUR_GROUP =  IM_HEADER-PUR_GROUP .
        HEADERX-PUR_GROUP =  'X' .

        READ TABLE IT_FINAL1 INTO WA_FINAL1 INDEX 1.                        " ADDED BY LIKHITHA
        WA_EXTENSIONIN-STRUCTURE  = 'BAPI_TE_MEPOHEADER'.
        BAPI_TE_PO-PO_NUMBER      = ' '.
        BAPI_TE_PO-ZINDENT          = <S_FINAL2>-INDENT_NO.
        BAPI_TE_PO-USER_NAME          = WA_FINAL1-SUP_NAME.         " ADDED BY LIKHITHA
        WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_PO.
        APPEND WA_EXTENSIONIN TO EXTENSIONIN.

        WA_EXTENSIONIN-STRUCTURE  = 'BAPI_TE_MEPOHEADERX'.
        BAPI_TE_POX-PO_NUMBER     = ' '.
        BAPI_TE_POX-ZINDENT  = 'X'.
        BAPI_TE_POX-USER_NAME  = 'X'.                    " ADDED BY LIKHITHA
        WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POX.
        APPEND WA_EXTENSIONIN TO EXTENSIONIN.
        CLEAR WA_EXTENSIONIN.

        DATA LV_LINE TYPE EBELP .
        DATA : LV_TEXT1     TYPE ZTEXT,
               LV_TEXT2     TYPE ZP_REMARKS, "ZREMARK,                        " ADDED BY LIKHITHA
               LV_PRICE(11) TYPE C.
        REFRESH : IT_RETURN .

        LOOP AT IT_FINAL3 ASSIGNING FIELD-SYMBOL(<LS_FIN>).

********Added by Bhavani********************
          LV_PRICE = <LS_FIN>-PRICE .
          CONDENSE LV_PRICE .
*******Ended By Bhavani*********************
          DATA(LV_INDEX) = SY-TABIX.
          DATA(LT_COUNT) = LT_MARA.
          DELETE LT_COUNT WHERE MATKL <> <LS_FIN>-CATEGORY_CODE.
          IF LT_COUNT IS INITIAL.
            DATA(LV_MSG) = 'No material found for Category ' && <LS_FIN>-CATEGORY_CODE .
            MESSAGE LV_MSG TYPE 'E'.
          ENDIF.
          READ TABLE IT_BRAND ASSIGNING FIELD-SYMBOL(<LS_BRAND>) WITH KEY MATKL = <LS_FIN>-CATEGORY_CODE .
          IF SY-SUBRC NE 0.
            DELETE LT_COUNT WHERE ZZPRICE_FRM > <LS_FIN>-PRICE.

            DELETE LT_COUNT WHERE ZZPRICE_TO < <LS_FIN>-PRICE.
            IF LT_COUNT IS INITIAL.
              LV_MSG = 'No material found for Category ' && <LS_FIN>-CATEGORY_CODE .
              MESSAGE LV_MSG TYPE 'E'.
            ENDIF.

          ENDIF.
***       Start of Chages by Suri : 25.11.2019
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
              DELETE LT_COUNT WHERE MATKL = 'XXX'.
              IF LT_COUNT IS INITIAL.
                LV_MSG = 'No material found for Category ' && <LS_FIN>-CATEGORY_CODE .
                MESSAGE LV_MSG TYPE 'E'.
              ENDIF.
              DESCRIBE TABLE LT_COUNT LINES LV_COUNT.
            ENDIF.
          ENDIF.
          IF <LS_FIN>-FROM_SIZE = C_SET .
            SORT LT_SET BY MATKL MATNR .
            LOOP AT LT_SET ASSIGNING FIELD-SYMBOL(<LS_MARP>) WHERE MATKL = <LS_FIN>-CATEGORY_CODE.

******START CHANGES BY BHAVANI 28.11.2019****

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

              WA_ITEM-PO_ITEM = WA_ITEMX-PO_ITEM =  SL_ITEM.                                        " added by likhitha
              SORT LT_COMP BY MATNR STLNR STLKN IDNRK POSNR .
              LOOP AT LT_COMP ASSIGNING FIELD-SYMBOL(<LS_COMP>) WHERE MATNR = <LS_MARP>-MATNR.

                READ TABLE IT_HSN_S ASSIGNING FIELD-SYMBOL(<LS_HSN_S>) WITH KEY MATNR = <LS_COMP>-IDNRK .
                IF SY-SUBRC = 0.
                  CLEAR :  LV_MWSK1 .
                  READ TABLE IT_KONP_S ASSIGNING FIELD-SYMBOL(<LS_KONP_S>) WITH KEY KNUMH = <LS_HSN_S>-KNUMH .
                  IF SY-SUBRC = 0.
                    WA_ITEM-TAX_CODE = <LS_KONP_S>-MWSK1.
                    WA_ITEMX-TAX_CODE = 'X'.
                    LV_MWSK1 = <LS_KONP_S>-MWSK1.
                  ENDIF.
                ENDIF.

                DATA(LT_COMP_T) = LT_COMP.
                DELETE LT_COMP_T WHERE MATNR <> <LS_MARP>-MATNR.
                IF LT_COMP_T IS INITIAL.
                  LV_MSG = 'No material found for Category ' && <LS_FIN>-CATEGORY_CODE .
                  MESSAGE LV_MSG TYPE 'E'.
                ENDIF.
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
                WA_ITEM-PLANT         =   IM_HEADER-DELIVERY_AT.
                WA_ITEMX-PLANT         =   C_X .
                WA_ITEM-STGE_LOC = 'FG01' .
                WA_ITEMX-STGE_LOC = 'X' .
                WA_ITEM-NET_PRICE     = <LS_FIN>-PRICE .
                WA_ITEMX-NET_PRICE = 'X'.
*            WA_ITEM-IR_IND        = C_X.
*            WA_ITEM-GR_BASEDIV    = C_X.
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
********ADDED BY BHAVANI 28.11.2019*********

                CLEAR :BAPI_TE_POITEM ,BAPI_TE_POITEMX.
                BREAK SAMBURI.
***       Item extenction fields
                WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEM'.
                BAPI_TE_POITEM-PO_ITEM  = SL_ITEM.
                BAPI_TE_POITEM-ZZTEXT100  = LV_TEXT1.
                BAPI_TE_POITEM-ZZREMARKS  = <LS_FIN>-REMARKS.              " ADDED BY LIKHITHA
                WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEM.
                APPEND WA_EXTENSIONIN TO EXTENSIONIN.
                CLEAR : WA_EXTENSIONIN.
***       Item extenction fields Updation Flags
                WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEMX'.
                BAPI_TE_POITEMX-PO_ITEM = SL_ITEM.
                BAPI_TE_POITEMX-ZZTEXT100 = C_X.
                BAPI_TE_POITEMX-ZZREMARKS = C_X.                    " ADDED BY LIKHITHA
                WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEMX.
                APPEND WA_EXTENSIONIN TO EXTENSIONIN.
                CLEAR WA_EXTENSIONIN.

                CLEAR : LV_TEXT .
********ended by bhavani 28.11.2019*********
                WA_ITEM-PLAN_DEL = IM_HEADER-LEAD_TIME.
                WA_ITEMX-PLAN_DEL = 'X'.

                WA_ITEM-OVER_DLV_TOL  = '10'.           ""tolerance
                WA_ITEMX-OVER_DLV_TOL  = 'X'.           ""tolerance

                APPEND WA_ITEM TO ITEM[].
                APPEND WA_ITEMX TO ITEMX[].
*          MODIFY PO_ITEM FROM   WA_ITEM TRANSPORTING LV_POITEM .
********************                COMMENTED ON (13-2-20)    ******************
*                WA_POCOND-COND_TYPE = 'PBXX' .
*                WA_POCOND-COND_VALUE = <LS_FIN>-PRICE  / 10.
*                WA_POCOND-ITM_NUMBER = WA_ITEM-PO_ITEM  .
*                WA_POCOND-CHANGE_ID = 'U' .
*                WA_POCONDX-COND_TYPE = 'X' .
*                WA_POCONDX-COND_VALUE = 'X' .
*                WA_POCONDX-ITM_NUMBER = 'X' .
*                WA_POCONDX-CHANGE_ID = 'X' .
*
*                APPEND WA_POCOND TO POCOND[] .
*                APPEND WA_POCONDX TO POCONDX[] .
***************   END (13-2-20)   *************************
                CLEAR : WA_ITEM,WA_ITEMX  ,A , B ,C.

                SL_ITEM =  SL_ITEM + 10 .

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
*          ENDIF.
              C = WA_ITEM-QUANTITY .
              CONDENSE C .
              SPLIT C AT '.' INTO A B .
              WA_ITEM-QUANTITY = A .
              WA_ITEMX-QUANTITY         =  C_X .
              WA_ITEM-PLANT         =   IM_HEADER-DELIVERY_AT.
              WA_ITEMX-PLANT         =   C_X .
              WA_ITEM-STGE_LOC = 'FG01' .
              WA_ITEMX-STGE_LOC = 'X' .
              WA_ITEM-NET_PRICE     = <LS_FIN>-PRICE .
              WA_ITEMX-NET_PRICE = 'X'.
*            WA_ITEM-IR_IND        = C_X.
*            WA_ITEM-GR_BASEDIV    = C_X.
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
***       Item extenction fields
              WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEM'.
              BAPI_TE_POITEM-PO_ITEM  = SL_ITEM.
              BAPI_TE_POITEM-ZZTEXT100  = LV_TEXT1.
              BAPI_TE_POITEM-ZZREMARKS  = <LS_FIN>-REMARKS.                  " added by likhitha
              BAPI_TE_POITEM-ZZCOLOR    = <LS_FIN>-COLOR.                    " Added by likhitha
              BAPI_TE_POITEM-ZZSTYLE    = <LS_FIN>-STYLE.                    " ADDED BY LIKHITHA
              WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEM.
              APPEND WA_EXTENSIONIN TO EXTENSIONIN.
              CLEAR : WA_EXTENSIONIN.
***       Item extenction fields Updation Flags
              WA_EXTENSIONIN-STRUCTURE = 'BAPI_TE_MEPOITEMX'.
              BAPI_TE_POITEMX-PO_ITEM = SL_ITEM.
              BAPI_TE_POITEMX-ZZTEXT100 = C_X.
              BAPI_TE_POITEMX-ZZREMARKS = C_X.                         " ADDED BY LIKHHITHA TO UBDATE IN EKPO
              BAPI_TE_POITEMX-ZZCOLOR  = C_X.                         " added by likhitha
              BAPI_TE_POITEMX-ZZSTYLE = C_X.                            " added by likhitha
              WA_EXTENSIONIN-VALUEPART1 = BAPI_TE_POITEMX.
*              BAPI_TE_POITEMX-ZZREMARKS = C_X.
*              WA_EXTENSIONIN-VALUEPART2 = BAPI_TE_POITEMX.
              APPEND WA_EXTENSIONIN TO EXTENSIONIN.
              CLEAR WA_EXTENSIONIN.
              CLEAR : LV_TEXT .


*              *        *********************        ADDED ON (12-2-20)   *******************
*DATA : LV_CON TYPE KNUMH.

*    IF it_hsn-matnr IS NOT INITIAL  AND IT_ITEM-VENDOR IS NOT INITIAL.
              IF IM_HEADER-VENDOR IS NOT INITIAL AND <LS_MARP>-MATNR IS NOT INITIAL.
                SELECT KAPPL
                       KSCHL
                       LIFNR
                       MATNR
                       KFRST
                       KNUMH
                       FROM A502
                       INTO TABLE IT_A502
                       FOR ALL ENTRIES IN IT_ITEM
                       WHERE LIFNR = IT_ITEM-VENDOR AND KSCHL = 'ZDS1'.
                READ TABLE IT_A502 INTO WA_A502 INDEX 1.
                LV_CON = WA_A502-KNUMH.
                IF IT_A502  IS NOT INITIAL.
                SELECT KNUMH
                     KOPOS
                     KBETR
                     FROM KONP INTO TABLE IT_KONP_1
                     FOR ALL ENTRIES IN IT_A502
                     WHERE KNUMH = IT_A502-KNUMH." AND KSCHL = 'ZDS1'.
              READ TABLE IT_KONP_1 INTO WA_KONP_1 INDEX 1.
               LV_DIS = WA_KONP_1-KBETR.
               ENDIF.
              ENDIF.
              IF IT_A502 IS INITIAL .
*              ELSEIF
*                IM_HEADER-VENDOR IS NOT INITIAL AND <LS_FIN>-CATEGORY_CODE IS NOT INITIAL.
                SELECT KAPPL
                       KSCHL
                       LIFNR
                       MATKL
                       KFRST
                       KNUMH  FROM A503
                       INTO TABLE IT_A503
                       FOR ALL ENTRIES IN IT_ITEM
                       WHERE LIFNR = IT_ITEM-VENDOR AND MATKL = IT_ITEM-CATEGORY_CODE AND KSCHL = 'ZDS1'.
*                READ TABLE IT_A503 INTO WA_A503 INDEX 1.
                LV_CON = WA_A503-KNUMH.
                   IF IT_A503 IS NOT INITIAL.
                 SELECT KNUMH
                     KOPOS
                     KBETR
                     FROM KONP INTO TABLE IT_KONP_2
                     FOR ALL ENTRIES IN IT_A503
                     WHERE KNUMH = IT_A503-KNUMH." AND KSCHL = 'ZDS1'.
              READ TABLE IT_KONP_2 INTO WA_KONP_2 INDEX 1.
              LV_DIS = WA_KONP_2-KBETR.
              ENDIF.
              ENDIF.


*              ELSEIF
              IF IT_A503 IS INITIAL .
*                IM_HEADER-VENDOR IS NOT INITIAL .
                SELECT KAPPL
                       KSCHL
                       EKORG
                       LIFNR
                       KNUMH
                       FROM A044
                       INTO TABLE IT_A044
                       FOR ALL ENTRIES IN IT_ITEM
                       WHERE LIFNR = IT_ITEM-VENDOR AND KSCHL = 'ZDS1'..
*
                READ TABLE IT_A044 INTO WA_A044 INDEX 1.
                LV_CON = WA_A044-KNUMH.
                 IF IT_A044 IS NOT INITIAL.
                 SELECT KNUMH
                     KOPOS
                     KBETR
                     FROM KONP INTO TABLE IT_KONP_3
                     FOR ALL ENTRIES IN IT_A044
                     WHERE KNUMH = IT_A044-KNUMH." AND KSCHL = 'ZDS1'.
              READ TABLE IT_KONP_3 INTO WA_KONP_3 INDEX 1.
              LV_DIS = WA_KONP_3-KBETR.
              ENDIF.
              ENDIF.

*              SELECT KNUMH
*                     KOPOS
*                     KBETR
*                     FROM KONP INTO TABLE IT_KONP_LI
*                     FOR ALL ENTRIES IN IT_A044
*                     WHERE KNUMH = IT_A044-KNUMH." AND KSCHL = 'ZDS1'.
*              READ TABLE IT_KONP_LI INTO WA_KONP_LI INDEX 1.


*
              WA_POCOND-COND_TYPE = 'ZDS1'.
              WA_POCOND-COND_VALUE = LV_DIS / 10."WA_KONP_1-KBETR / 10.
              WA_POCOND-ITM_NUMBER = WA_ITEM-PO_ITEM  .
              WA_POCOND-CHANGE_ID = 'I' .

              WA_POCONDX-COND_TYPE = 'X' .
              WA_POCONDX-COND_VALUE = 'X' .
              WA_POCONDX-ITM_NUMBER = 'X' .
              WA_POCONDX-CHANGE_ID = 'X' .

              APPEND WA_POCOND TO POCOND[] .
              APPEND WA_POCONDX TO POCONDX[] .

**
*              DATA : I_MATNR TYPE MATNR18  .
**
*              I_MATNR = <LS_MARP>-MATNR.
**
*              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*                EXPORTING
*                  INPUT  = I_MATNR
*                IMPORTING
*                  OUTPUT = <LS_MARP>-MATNR.
*              .
*              I_MATNR = <LS_MARP>-MATNR.
*              CALL METHOD ZCL_GST=>GET_GST_PER
*                EXPORTING
*                  I_MATNR = <LS_MARP>-MATNR " Material Number
*                  I_LIFNR = IM_HEADER-VENDOR " WA_lfa1-LIFNR   " Account Number of Vendor
*              IMPORTING
*                ET_TAX  =  IT_DIS  ." Tax Table type
**
**
*              LOOP AT IT_DIS INTO WA_DIS .
*          ibapicond-itm_number   = WA_ITEM-SL_NO.
*                IBAPICOND-COND_TYPE    = 'ZDS1'." WA_DIS-COND_TYPE .
*                IBAPICOND-COND_VALUE   = WA_KONP_LI-KBETR / 10." WA_DIS-TAX .
*                IBAPICOND-CHANGE_ID     = 'U' .
*
**          ibapicondx-itm_number  = WA_ITEM-SL_NO .
*                IBAPICONDX-COND_TYPE   = 'X'." WA_DIS-COND_TYPE .
*                IBAPICONDX-COND_VALUE  = 'X'.
*                IBAPICONDX-CHANGE_ID     = 'X' .
*                APPEND IBAPICOND .
*                APPEND IBAPICONDX.
*              ENDLOOP.
********        END (12-2-20)  ********************

********ended by bhavani 28.11.2019*********

              WA_ITEM-PLAN_DEL = IM_HEADER-LEAD_TIME.
              WA_ITEMX-PLAN_DEL = 'X'.


              WA_ITEM-OVER_DLV_TOL  = '10'.           ""tolerance
              WA_ITEMX-OVER_DLV_TOL  = 'X'.           ""tolerance
              APPEND WA_ITEM TO ITEM[].
              APPEND WA_ITEMX TO ITEMX[].
*          MODIFY PO_ITEM FROM   WA_ITEM TRANSPORTING LV_POITEM .


*
*              WA_POCOND-COND_TYPE = 'ZDS1'.
*              WA_POCOND-COND_VALUE = WA_KONP_LI-KBETR / 10.
*              WA_POCOND-ITM_NUMBER = WA_ITEM-PO_ITEM  .
*              WA_POCOND-CHANGE_ID = 'U' .
*              WA_POCONDX-COND_TYPE = 'X' .
*              WA_POCONDX-COND_VALUE = 'X' .
*              WA_POCONDX-ITM_NUMBER = 'X' .
*              WA_POCONDX-CHANGE_ID = 'X' .
*
*              APPEND WA_POCOND TO POCOND[] .
*              APPEND WA_POCONDX TO POCONDX[] .



*************              COMMENETED ON (13-2-20)    *****************
*              WA_POCOND-COND_TYPE = 'PBXX' .
*              WA_POCOND-COND_VALUE = <LS_FIN>-PRICE  / 10.
*              WA_POCOND-ITM_NUMBER = WA_ITEM-PO_ITEM  .
*              WA_POCOND-CHANGE_ID = 'U' .
*              WA_POCONDX-COND_TYPE = 'X' .
*              WA_POCONDX-COND_VALUE = 'X' .
*              WA_POCONDX-ITM_NUMBER = 'X' .
*              WA_POCONDX-CHANGE_ID = 'X' .
*
*              APPEND WA_POCOND TO POCOND[] .
*              APPEND WA_POCONDX TO POCONDX[] .
***************   END (13-2-20) *********************************
              CLEAR : WA_ITEM,WA_ITEMX ,WA_POCOND,WA_POCONDX ,A , B ,C.

              SL_ITEM =  SL_ITEM + 10 .
            ENDLOOP .
          ENDIF .
*        ENDIF .                                                      " added by likhitha
*          break breddy .
        ENDLOOP.
*        REFRESH IT_ERROR .
*        IF ITEM IS NOT INITIAL .
        CLEAR : SL_ITEM .
        SL_ITEM = '10'.
        DATA(IT_TAX) = ITEM[] .

        READ TABLE IT_TAX  WITH KEY TAX_CODE = SPACE TRANSPORTING NO FIELDS.
        IF   SY-SUBRC <> 0 ."AND FLAG NE 'X'.

          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              POHEADER         = HEADER
              POHEADERX        = HEADERX
*             POADDRVENDOR     =
*             TESTRUN          =
*             MEMORY_UNCOMPLETE            =
*             MEMORY_COMPLETE  =
*             POEXPIMPHEADER   =
*             POEXPIMPHEADERX  =
*             VERSIONS         =
*             NO_MESSAGING     =
*             NO_MESSAGE_REQ   =
*             NO_AUTHORITY     =
*             NO_PRICE_FROM_PO = 'X'
*             PARK_COMPLETE    =
*             PARK_UNCOMPLETE  =
            IMPORTING
              EXPPURCHASEORDER = LV_EBELN
*             EXPHEADER        =
*             EXPPOEXPIMPHEADER            =
            TABLES
              RETURN           = IT_RETURN[]
              POITEM           = ITEM[]
              POITEMX          = ITEMX[]
*             POADDRDELIVERY   =
*             POSCHEDULE       =
*             POSCHEDULEX      =
*             POACCOUNT        =
*             POACCOUNTPROFITSEGMENT       =
*             POACCOUNTX       =
*             POCONDHEADER     =
*             POCONDHEADERX    =
              POCOND           = POCOND[]
              POCONDX          = pocondx[]
*             POLIMITS         =
*             POCONTRACTLIMITS =
*             POSERVICES       =
*             POSRVACCESSVALUES            =
*             POSERVICESTEXT   = POSERVICESTEXT[]
              EXTENSIONIN      = EXTENSIONIN[]
*             EXTENSIONOUT     =
*             POEXPIMPITEM     =
*             POEXPIMPITEMX    =
*             POTEXTHEADER     =
              POTEXTITEM       = POTEXTITEM[]
*             ALLVERSIONS      =
*             POPARTNER        =
*             POCOMPONENTS     =
*             POCOMPONENTSX    =
*             POSHIPPING       =
*             POSHIPPINGX      =
*             POSHIPPINGEXP    =
*             SERIALNUMBER     =
*             SERIALNUMBERX    =
*             INVPLANHEADER    =
*             INVPLANHEADERX   =
*             INVPLANITEM      =
*             INVPLANITEMX     =
*             NFMETALLITMS     =
            .
*    ET_RETURN  = IT_RETURN.
*      EBELN = LV_EBELN.
*      BREAK BREDDY .
        ELSE.

          MESSAGE 'Po tax is not maintained ' TYPE 'E' .
        ENDIF .
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
        LV_TEX = 'Created Successfully' .
        CONCATENATE LV_EBELN LV_TEX  INTO LV_TEBELN SEPARATED BY SPACE.
        IF LV_EBELN IS NOT INITIAL .
          MESSAGE LV_TEBELN TYPE  'S' .

        ELSE.

          READ TABLE IT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY TYPE = 'E' ID = '06' NUMBER = '070' .
          IF SY-SUBRC = 0.
            LV_ERROR = 'Please check the quantity you have entered' .
            MESSAGE LV_ERROR TYPE 'E' .
          ENDIF.
        ENDIF.
*        BREAK BREDDY .
*** Start of Changes By Suri : 15.11.2019
*** Send Mail to Vendor
        IF LV_EBELN IS NOT INITIAL.
          CALL FUNCTION 'ZFM_PURCHASE_FORM1'
            EXPORTING
              LV_EBELN = LV_EBELN
              REG_PO   = 'X'.
*   RETURN_PO            =
*   TATKAL_PO            =
*   PRINT_PRIEVIEW       =
*   SERVICE_PO           =
*          .
******Added By Bhavani 27.11.2019***********************
        ELSEIF IT_RETURN IS NOT INITIAL AND LV_EBELN IS  INITIAL.
          CALL SCREEN 9001 STARTING AT 20 20 .
        ENDIF.
      ELSE.
        MESSAGE 'Purchase Order for this Indent Number is already exist' TYPE 'E'.
      ENDIF .
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING P_GT_EXCLUDE.
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
*&---------------------------------------------------------------------*
*& Form PREPARE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_FCAT .

  REFRESH GT_FIELDCAT.

  GS_FIELDCATS-FIELDNAME      = 'INDENT_NO'.
  GS_FIELDCATS-REPTEXT      = 'Indent No'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.




  GS_FIELDCATS-FIELDNAME      = 'VENDOR'.
  GS_FIELDCATS-REPTEXT      = 'Vendor'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'PGROUP'.
  GS_FIELDCATS-REPTEXT      = 'Group'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'CATEGORY_CODE'.
  GS_FIELDCATS-REPTEXT      = 'Category Code'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'STYLE'.
  GS_FIELDCATS-REPTEXT      = 'Style'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'FROM_SIZE'.
  GS_FIELDCATS-REPTEXT      = 'From Size'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'TO_SIZE'.
  GS_FIELDCATS-REPTEXT      = 'To Size'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'COLOR'.
  GS_FIELDCATS-REPTEXT      = 'Color'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'QUANTITY'.
  GS_FIELDCATS-REPTEXT      = 'Quantity'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'PRICE'.
  GS_FIELDCATS-REPTEXT      = 'Price'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'REMARKS'.
  GS_FIELDCATS-REPTEXT      = 'Remarks'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'E_MSG'.
  GS_FIELDCATS-REPTEXT      = 'Error Message'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

  GS_FIELDCATS-FIELDNAME      = 'S_MSG'.
  GS_FIELDCATS-REPTEXT      = 'Success Message'.
  GS_FIELDCATS-COL_OPT     = 'X'.
  GS_FIELDCATS-TXT_FIELD   = 'X'.
*  GS_FIELDCATS-REF_TABNAME    = 'IT_FINAL1'.
  APPEND GS_FIELDCATS TO GT_FIELDCAT.
  CLEAR GS_FIELDCATS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA_SCR3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA_SCR3 .

  CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYO
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE  " Excluded Toolbar Standard Functions
    CHANGING
      IT_OUTTAB                     = IT_FINAL2
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
*&---------------------------------------------------------------------*
*& Form CLEAR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLEAR_DATA .
  REFRESH : IT_FINAL2.
  CLEAR : WA_FINAL2.
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

  REFRESH LT_FIELDCAT.
  GS_FIELDCAT-FIELDNAME      = 'VENDOR'.
  GS_FIELDCAT-SELTEXT_L      = 'Vendor'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'VENDOR_NAME'.
  GS_FIELDCAT-SELTEXT_L      = 'Vendor Name'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'PGROUP'.
  GS_FIELDCAT-SELTEXT_L      = 'Group'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'PUR_GROUP'.
  GS_FIELDCAT-SELTEXT_L      = 'Purchase Group'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'INDENT_NO'.
  GS_FIELDCAT-SELTEXT_L      = 'Indent Number'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  GS_FIELDCAT-OUTPUTLEN      = '30' .
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'SUP_SAL_NO'.
  GS_FIELDCAT-SELTEXT_L      = 'Supervisor Salary Number'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'SUP_NAME'.
  GS_FIELDCAT-SELTEXT_L      = 'Supervisor Name'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'TRANSPORTER'.
  GS_FIELDCAT-SELTEXT_L      = 'Transporter'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'VENDOR_LOCATION'.
  GS_FIELDCAT-SELTEXT_L      = 'Vendor Location'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'DELIVERY_AT'.
  GS_FIELDCAT-SELTEXT_L      = 'Delivery At'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'LEAD_TIME '.
  GS_FIELDCAT-SELTEXT_L      = 'Lead Time'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'E_MSG'.
  GS_FIELDCAT-SELTEXT_L      = 'Error Message'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME      = 'S_MSG'.
  GS_FIELDCAT-SELTEXT_L      = 'Success Message'.
  GS_FIELDCAT-REF_TABNAME    = 'IT_FINAL'.
  APPEND GS_FIELDCAT TO LT_FIELDCAT.
  CLEAR GS_FIELDCAT.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID         " Name of the calling program
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND_SCR2'            " EXIT routine for command handling
      I_CALLBACK_PF_STATUS_SET = 'GUI_STAT'
      IS_LAYOUT                = WA_LAYOUT    " List layout specifications
*     I_CALLBACK_HTML_TOP_OF_PAGE = 'TOP_OF_PAGE'
      IT_FIELDCAT              = LT_FIELDCAT      " Field catalog with field descriptions
      I_DEFAULT                = 'X'              " I nitial variant active/inactive logic
      I_SAVE                   = 'A'              " Variants can be saved
    TABLES
      T_OUTTAB                 = IT_FINAL                 " Table with data to be displayed
    EXCEPTIONS
      PROGRAM_ERROR            = 1                " Program errors
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  SET PF-STATUS 'ZGUI_9001'.
  SET TITLEBAR 'TITLE1'.
  CLEAR :GV_SUBRC.

  IF GRID1 IS NOT INITIAL .
    CALL METHOD GRID1->FREE.
    CALL METHOD CONTAINER1->FREE.
    CLEAR: GRID1, CONTAINER1.
    REFRESH GT_ERRORCAT[] .
  ENDIF.

  IF CONTAINER1 IS NOT BOUND.
    CREATE OBJECT CONTAINER1
      EXPORTING
        CONTAINER_NAME = 'MYCONTAINER1'.
    CREATE OBJECT GRID1
      EXPORTING
        I_PARENT = CONTAINER1.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
    PERFORM PREPARE_FCAT1.
    PERFORM DISPLAY_DATA_SCR4.
  ELSE.
    IF IT_RETURN IS NOT INITIAL.
      IF GRID1 IS BOUND.
        DATA: IS_STABLE1 TYPE LVC_S_STBL, LV_LINES1 TYPE INT2.
        IS_STABLE = 'XX'.
        IF GRID1 IS BOUND.
          CALL METHOD GRID1->REFRESH_TABLE_DISPLAY
            EXPORTING
              IS_STABLE = IS_STABLE               " With Stable Rows/Columns
            EXCEPTIONS
              FINISHED  = 1                       " Display was Ended (by Export)
              OTHERS    = 2.
          IF SY-SUBRC <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form PREPARE_FCAT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREPARE_FCAT1 .
  BREAK BREDDY .
  IF IT_RETURN IS NOT INITIAL AND GT_ERRORCAT IS INITIAL.

    REFRESH : IT_ERROR .
    LOOP AT IT_RETURN ASSIGNING FIELD-SYMBOL(<LS_ERROR>).


*      WA_ERROR-FIELD      = <LS_ERROR>-FIELD .
*      WA_ERROR-ID         = <LS_ERROR>-ID .
*      WA_ERROR-LOG_MSG_NO = <LS_ERROR>-LOG_MSG_NO .
*      WA_ERROR-LOG_NO     = <LS_ERROR>-LOG_NO .
      WA_ERROR-MESSAGE    = <LS_ERROR>-MESSAGE .
*      WA_ERROR-MESSAGE_V1 = <LS_ERROR>-MESSAGE_V1 .
*      WA_ERROR-MESSAGE_V2 = <LS_ERROR>-MESSAGE_V2 .
*      WA_ERROR-MESSAGE_V3 = <LS_ERROR>-MESSAGE_V3 .
*      WA_ERROR-MESSAGE_V4 = <LS_ERROR>-MESSAGE_V4 .
*      WA_ERROR-NUMBER     = <LS_ERROR>-NUMBER .
*      WA_ERROR-PARAMETER  = <LS_ERROR>-PARAMETER .
*      WA_ERROR-ROW        = <LS_ERROR>-ROW .
*      WA_ERROR-SYSTEM     = <LS_ERROR>-SYSTEM .
      WA_ERROR-TYPE       = <LS_ERROR>-TYPE .

      APPEND WA_ERROR TO IT_ERROR .
      CLEAR : WA_ERROR .
    ENDLOOP.

  ENDIF.

  REFRESH GT_ERRORCAT.

*  GS_ERRORCAT-FIELDNAME      = 'FIELD'.
*  GS_ERRORCAT-REPTEXT      = 'Field'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*
*
*  GS_ERRORCAT-FIELDNAME      = 'ID'.
*  GS_ERRORCAT-REPTEXT      = 'Id'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*
*  GS_ERRORCAT-FIELDNAME      = 'LOG_MSG_NO'.
*  GS_ERRORCAT-REPTEXT      = 'Log Message Num'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'LOG_NO'.
*  GS_ERRORCAT-REPTEXT      = 'Log Num'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
  GS_ERRORCAT-FIELDNAME      = 'TYPE'.
  GS_ERRORCAT-REPTEXT      = 'Type'.
  GS_ERRORCAT-COL_OPT     = 'X'.
  GS_ERRORCAT-TXT_FIELD   = 'X'.
  APPEND GS_ERRORCAT TO GT_ERRORCAT.
  CLEAR GS_ERRORCAT.

  GS_ERRORCAT-FIELDNAME      = 'MESSAGE'.
  GS_ERRORCAT-REPTEXT      = 'Message'.
  GS_ERRORCAT-COL_OPT     = 'X'.
  GS_ERRORCAT-TXT_FIELD   = 'X'.
  APPEND GS_ERRORCAT TO GT_ERRORCAT.
  CLEAR GS_ERRORCAT.

*  GS_ERRORCAT-FIELDNAME      = 'MESSAGE_V2'.
*  GS_ERRORCAT-REPTEXT      = 'MESSAGE2'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'MESSAGE_V3'.
*  GS_ERRORCAT-REPTEXT      = 'MESSAGE3'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'MESSAGE_V4'.
*  GS_ERRORCAT-REPTEXT      = 'MESSAGE4'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'NUMBER'.
*  GS_ERRORCAT-REPTEXT      = 'Number'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'PARAMETER'.
*  GS_ERRORCAT-REPTEXT      = 'Parameter'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'ROW'.
*  GS_ERRORCAT-REPTEXT      = 'Row'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.
*
*  GS_ERRORCAT-FIELDNAME      = 'SYSTEM'.
*  GS_ERRORCAT-REPTEXT      = 'System'.
*  GS_ERRORCAT-COL_OPT     = 'X'.
*  GS_ERRORCAT-TXT_FIELD   = 'X'.
*  APPEND GS_ERRORCAT TO GT_ERRORCAT.
*  CLEAR GS_ERRORCAT.











ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA_SCR4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA_SCR4 .


  CALL METHOD GRID1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYO1
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE  " Excluded Toolbar Standard Functions
    CHANGING
      IT_OUTTAB                     = IT_ERROR
      IT_FIELDCATALOG               = GT_ERRORCAT
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
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.



  CASE OK_CODE.
    WHEN 'BACK_9001' OR 'EXIT_9001' OR 'CAN_9001'.
      LEAVE TO SCREEN 0.
  ENDCASE.

*  BREAK BREDDY .

ENDMODULE.
