FUNCTION ZGW_PO_ITEM_DETAILS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(EBELN) TYPE  EBELN
*"     VALUE(DAYS) TYPE  /ACCGO/E_DELIV_DAYS OPTIONAL
*"     VALUE(ERROR_FLAG) TYPE  CHAR1 OPTIONAL
*"  TABLES
*"      ET_ITEMS STRUCTURE  ZGW_PO_ITEMS
*"----------------------------------------------------------------------

*** Checking for PO Number
  DATA : LV_DATE_FROM TYPE ERDAT.
*** For item text read
  TYPES: BEGIN OF TY_STXL,
           TDNAME TYPE STXL-TDNAME,
           CLUSTR TYPE STXL-CLUSTR,
           CLUSTD TYPE STXL-CLUSTD,
           TDID   TYPE STXL-TDID,
         END OF TY_STXL.
*** Compressed text data without text name
  TYPES: BEGIN OF TY_STXL_RAW,
           CLUSTR TYPE STXL-CLUSTR,
           CLUSTD TYPE STXL-CLUSTD,
           TDID   TYPE STXL-TDID,
         END OF TY_STXL_RAW.

  DATA:
    LT_STXL     TYPE STANDARD TABLE OF TY_STXL,
    LT_STXL_RAW TYPE STANDARD TABLE OF TY_STXL_RAW,
    LS_STXL_RAW TYPE TY_STXL_RAW,
    LT_STXH     TYPE STANDARD TABLE OF STXH,
    LS_STXH     TYPE STXH,
    LT_TLINE    TYPE STANDARD TABLE OF TLINE,  " decompressed text
    R_OBJ       TYPE RANGE OF TDOBNAME.

  FIELD-SYMBOLS:
    <LS_LINE>  TYPE TLINE,
    <LS_STXL>  TYPE TY_STXL,
    <LS_STXH>  TYPE STXH,
    <LS_ITEMS> TYPE ZGW_PO_ITEMS.

  CONSTANTS :
    C_I(1)      VALUE 'I',      " Ranges - Sign
    C_OPTION(2) VALUE 'EQ',     " Ranges - Option
    C_F08(3)    VALUE 'F08',    " Text ID - Color
    C_F07(3)    VALUE 'F07',    " Text ID - Style
    C_F03(3)    VALUE 'F03'.    " Text ID - Material PO Text - Remarks


  CHECK       EBELN IS NOT INITIAL.
  IF ERROR_FLAG IS NOT INITIAL .
    SELECT  ZPO_STATUS~SNO,
            ZPO_STATUS~GROUP_ID,
            ZPO_STATUS~LIFNR,
            ZPO_STATUS~NAME1,
            ZPO_STATUS~AEDAT,
            ZPO_STATUS~ERROR_MSG,
            ZPO_STATUS~ERNAM,
            ZPO_STATUS~NETWR
            INTO TABLE @DATA(LT_ERRORS)
            FROM ZPO_STATUS WHERE SNO = @EBELN." AND AEDAT BETWEEN @LV_DATE_FROM AND @SY-DATUM.
    LOOP AT LT_ERRORS ASSIGNING FIELD-SYMBOL(<LS_ERROR>).
      APPEND VALUE #(
            EBELN      = <LS_ERROR>-SNO
            LIFNR      = <LS_ERROR>-LIFNR
            NAME1      = <LS_ERROR>-NAME1
            NETPR      = <LS_ERROR>-NETWR
            AEDAT      = <LS_ERROR>-AEDAT
            BAPI_MSG   = <LS_ERROR>-ERROR_MSG
            ERROR_FLAG = <LS_ERROR>-ERROR_MSG
            ERNAM      = <LS_ERROR>-ERNAM ) TO ET_ITEMS.
    ENDLOOP.
  ELSE.
    SELECT EKPO~EBELN,
           EKPO~EBELP,
           EKKO~LIFNR,
           EKKO~ERNAM,
           EKPO~NETPR,
           EKPO~NETWR,
           EKPO~AEDAT,
           EKPO~MENGE,
           EKPO~MEINS,
           EKPO~MATNR,
           MARA~ZZPO_ORDER_TXT AS TXZ01,
           LFA1~NAME1
           INTO TABLE @DATA(LT_SUCCESS)
           FROM EKPO AS EKPO
           INNER JOIN EKKO AS EKKO ON EKPO~EBELN = EKKO~EBELN
           INNER JOIN MARA AS MARA ON MARA~MATNR = EKPO~MATNR
           INNER JOIN LFA1 AS LFA1 ON LFA1~LIFNR = EKKO~LIFNR
           WHERE EKPO~EBELN = @EBELN .
    MOVE-CORRESPONDING LT_SUCCESS[] TO ET_ITEMS[].
    IF SY-SUBRC = 0.
      SORT ET_ITEMS BY EBELN EBELP.
*** Item text : Get Style , Color & Remarks
      LOOP AT ET_ITEMS ASSIGNING <LS_ITEMS>.
        APPEND VALUE #( LOW = <LS_ITEMS>-EBELN && <LS_ITEMS>-EBELP OPTION = 'EQ' SIGN = 'I' ) TO R_OBJ.
      ENDLOOP.
      SELECT TDNAME TDOBJECT TDID FROM STXH INTO CORRESPONDING FIELDS OF TABLE LT_STXH WHERE TDOBJECT = 'EKPO' AND TDNAME IN R_OBJ.
*** Select compressed text lines in blocks of 3000 (adjustable)
      IF LT_STXH IS NOT INITIAL.
        SELECT  TDNAME
                CLUSTR
                CLUSTD
                TDID
                INTO TABLE LT_STXL
                FROM STXL
                PACKAGE SIZE 3000
                FOR ALL ENTRIES IN LT_STXH
                WHERE RELID    = 'TX'          "standard text
                AND TDOBJECT = LT_STXH-TDOBJECT
                AND TDNAME   = LT_STXH-TDNAME
                AND TDID     = LT_STXH-TDID
                AND TDSPRAS  = SY-LANGU.
        ENDSELECT.
      ENDIF.
***
      CHECK LT_STXL IS NOT INITIAL.
      LOOP AT ET_ITEMS ASSIGNING <LS_ITEMS>.
        LOOP AT LT_STXH ASSIGNING <LS_STXH> WHERE TDNAME = <LS_ITEMS>-EBELN && <LS_ITEMS>-EBELP .
          IF SY-SUBRC = 0.
            LOOP AT LT_STXL ASSIGNING <LS_STXL> WHERE TDNAME = <LS_STXH>-TDNAME AND TDID = <LS_STXH>-TDID.
***        Decompress texts
              CLEAR: LT_STXL_RAW[], LT_TLINE[].
              APPEND VALUE #( CLUSTR = <LS_STXL>-CLUSTR CLUSTD = <LS_STXL>-CLUSTD TDID = <LS_STXL>-TDID ) TO LT_STXL_RAW.
              IMPORT TLINE = LT_TLINE FROM INTERNAL TABLE LT_STXL_RAW.
              IF LT_TLINE IS NOT INITIAL.
                CASE <LS_STXL>-TDID.
                  WHEN C_F03.
                    LOOP AT LT_TLINE ASSIGNING <LS_LINE>.
                      <LS_ITEMS>-REMARKS = <LS_ITEMS>-REMARKS && <LS_LINE>-TDLINE.
                    ENDLOOP.
                  WHEN C_F07.
                    LOOP AT LT_TLINE ASSIGNING <LS_LINE>.
                      <LS_ITEMS>-STYLE = <LS_ITEMS>-STYLE && <LS_LINE>-TDLINE.
                    ENDLOOP.
                  WHEN C_F08.
                    LOOP AT LT_TLINE ASSIGNING <LS_LINE>.
                      <LS_ITEMS>-COLOR = <LS_ITEMS>-COLOR && <LS_LINE>-TDLINE.
                    ENDLOOP.
                ENDCASE.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      FREE LT_STXL.
    ENDIF.

  ENDIF.
ENDFUNCTION.
