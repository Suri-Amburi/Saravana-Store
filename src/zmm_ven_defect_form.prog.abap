*&--------------------------------------------------------------------*
*& Include          ZMM_VEN_DEFECT_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GETDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GETDATA .
  BREAK BREDDY .
  SELECT SINGLE CLINT
             KLART
             CLASS
             VONDT
             BISDT
             WWSKZ FROM KLAH INTO WA_KLAH
             WHERE WWSKZ = '0'
             AND KLART = '026'
             AND CLASS = GROUP_ID .

  IF WA_KLAH IS NOT INITIAL.
    SELECT OBJEK
           MAFID
           KLART
           CLINT
           ADZHL
           DATUB FROM KSSK INTO TABLE IT_KSSK
            WHERE CLINT = WA_KLAH-CLINT.
*  ELSE.
*
*    MESSAGE 'Invalid Hierarchy' TYPE 'E' DISPLAY LIKE 'I'.


  ENDIF.

  LOOP AT IT_KSSK INTO WA_KSSK .
    SHIFT WA_KSSK-OBJEK LEFT DELETING LEADING '0'.
    WA_KSSK1-OBJEK = WA_KSSK-OBJEK .
    APPEND WA_KSSK1 TO IT_KSSK1 .
    CLEAR WA_KSSK1 .
  ENDLOOP.
*  BREAK BREDDY.
  IF IT_KSSK1 IS NOT INITIAL .
    SELECT CLINT
           KLART
           CLASS
           VONDT
           BISDT
           WWSKZ FROM KLAH INTO TABLE IT_KLAH
           FOR ALL ENTRIES IN IT_KSSK1
           WHERE CLINT = IT_KSSK1-OBJEK
            AND WWSKZ = '1'.
  ENDIF.

*  CHECK IT_KLAH[] IS NOT INITIAL.
  IT_KLAH1[] = IT_KLAH[] .
  IF S_DATE IS INITIAL .
    S_DATE-LOW = SY-DATUM .
    S_DATE-OPTION = 'LT' .
    S_DATE-SIGN = 'I' .
    APPEND S_DATE .

  ENDIF.

*  IF P_EBELN IS NOT INITIAL . ""OR P_LIFNR IS NOT INITIAL.
  SELECT
     EKKO~EBELN ,
     EKKO~LIFNR ,
     EKKO~AEDAT ,
     EKPO~EBELP ,
     EKPO~MATNR ,
     EKPO~MENGE ,
     EKPO~NETWR ,
     EKPO~MATKL ,
     EKET~EINDT ,
     MAKT~MAKTX
*       ZINW_T_ITEM~NETWR_P
    INTO TABLE @IT_DATA
     FROM EKKO AS EKKO
     LEFT OUTER JOIN EKPO AS EKPO ON EKKO~EBELN = EKPO~EBELN
     LEFT OUTER JOIN EKET AS EKET ON EKPO~EBELN = EKET~EBELN AND EKPO~EBELP = EKET~EBELP
     LEFT OUTER JOIN MAKT AS MAKT ON EKPO~MATNR = MAKT~MATNR
*       INNER JOIN ZINW_T_ITEM AS ZINW_T_ITEM ON EKPO~EBELN = ZINW_T_ITEM~EBELN AND EKPO~EBELP = ZINW_T_ITEM~EBELP
     WHERE  EKKO~BSART IN ('ZLOP' , 'ZTAT' , 'ZOSP' )
     AND EKKO~EBELN IN @P_EBELN
*      AND EKKO~AEDAT IN @S_DATE
     AND EKKO~LIFNR IN @P_LIFNR
     AND EKET~EINDT IN @S_DATE .
  SORT IT_DATA BY  EBELN EBELP .
  IF IT_DATA IS NOT INITIAL.

    SELECT
     QR_CODE
     EBELN
     EBELP
     MATNR
     MENGE_P
     NETWR_P  FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM
              FOR ALL ENTRIES IN IT_DATA
              WHERE EBELN = IT_DATA-EBELN     ""'4600000248'  .
              AND   EBELP = IT_DATA-EBELP.

    SELECT LFA1~LIFNR ,
           LFA1~NAME1 ,
           LFA1~ORT01  FROM LFA1 INTO TABLE @DATA(IT_LFA1)
                       FOR ALL ENTRIES IN @IT_DATA
                       WHERE LIFNR = @IT_DATA-LIFNR .
  ENDIF.

  IF IT_ZINW_T_ITEM IS NOT INITIAL.

    SELECT ZINW_T_HDR~QR_CODE ,
           ZINW_T_HDR~ERDATE FROM ZINW_T_HDR INTO TABLE @DATA(IT_ZINW_T_HDR)
         FOR ALL ENTRIES IN @IT_ZINW_T_ITEM
         WHERE QR_CODE = @IT_ZINW_T_ITEM-QR_CODE .
  ENDIF.

  DATA: IT_CELLCOLOURS TYPE LVC_T_SCOL,
        WA_CELLCOLOR   TYPE LVC_S_SCOL.
  DATA: LD_INDEX  TYPE SY-TABIX.



  DATA(IT_DATA1) = IT_DATA[] .
  SORT IT_DATA1 BY EBELN .
  DELETE ADJACENT DUPLICATES FROM IT_DATA1 COMPARING EBELN .
*  DELETE IT_DATA WHERE EBELN <> '4600000248' .
*  DELETE IT_DATA1 WHERE EBELN <> '4600000248' .
*  DELETE IT_ZINW_T_ITEM WHERE EBELN <> '4600000248' .
  REFRESH : IT_FINAL .

  CLEAR : LV_MENGE , LV_MENGE1 .
  LOOP AT IT_DATA1 ASSIGNING FIELD-SYMBOL(<LS_DATA1>) .
    LD_INDEX = SY-TABIX .
    IF <LS_DATA1>-MATKL IS NOT INITIAL.
      CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
        EXPORTING
          MATKL       = <LS_DATA1>-MATKL
          SPRAS       = SY-LANGU
        TABLES
          O_WGH01     = IT_O_WGH01
        EXCEPTIONS
          NO_BASIS_MG = 1
          NO_MG_HIER  = 2
          OTHERS      = 3.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.
      READ TABLE IT_O_WGH01 INTO WA_O_WGH01 INDEX 1.
      IF SY-SUBRC = 0.
        WA_FINAL-GROUP = WA_O_WGH01-WWGHA .
        CLEAR WA_O_WGH01.
      ENDIF .
    ENDIF.

    LOOP AT IT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>) WHERE EBELN = <LS_DATA1>-EBELN.  ""'4600000248'
      WA_FINAL-EBELN = <LS_DATA>-EBELN.
      WA_FINAL-AEDAT = <LS_DATA>-AEDAT.
      WA_FINAL-EINDT = <LS_DATA>-EINDT.
      WA_FINAL-LIFNR = <LS_DATA>-LIFNR.
      WA_FINAL-MENGE = <LS_DATA>-MENGE + WA_FINAL-MENGE .
*      LV_MENGE = <LS_DATA>-MENGE + LV_MENGE .
      WA_FINAL-NETWR = <LS_DATA>-NETWR + WA_FINAL-NETWR.

      READ TABLE IT_LFA1 ASSIGNING FIELD-SYMBOL(<WA_LFA1>) WITH KEY LIFNR = <LS_DATA1>-LIFNR .

      IF SY-SUBRC = 0.
        WA_FINAL-NAME = <WA_LFA1>-NAME1 .
        WA_FINAL-CITY = <WA_LFA1>-ORT01 .
      ENDIF.

    ENDLOOP.

*      READ TABLE IT_ZINW_T_ITEM ASSIGNING FIELD-SYMBOL(<WA_ZINW_T_ITEM>) WITH KEY EBELN = <LS_DATA>-EBELN EBELP = <LS_DATA>-EBELP.
    LOOP AT IT_ZINW_T_ITEM ASSIGNING FIELD-SYMBOL(<WA_ZINW_T_ITEM>) WHERE EBELN = <LS_DATA1>-EBELN . "aND EBELP = <LS_DATA>-EBELP .
      READ TABLE IT_ZINW_T_HDR ASSIGNING FIELD-SYMBOL(<WA_ZINW_T_HDR>) WITH KEY QR_CODE = <WA_ZINW_T_ITEM>-QR_CODE .
      IF SY-SUBRC = 0 .
        IF <LS_DATA1>-EINDT GE <WA_ZINW_T_HDR>-ERDATE.
          WA_FINAL-MENGE_P = <WA_ZINW_T_ITEM>-MENGE_P + WA_FINAL-MENGE_P .
*          LV_MENGE1 = <WA_ZINW_T_ITEM>-MENGE_P + LV_MENGE1.
          WA_FINAL-NETWR_P = <WA_ZINW_T_ITEM>-NETWR_P + WA_FINAL-NETWR_P.

*          ELSE .
*
*            WA_FINAL-MENGE_P = <WA_ZINW_T_ITEM>-MENGE_P + WA_FINAL-MENGE_P .
*            WA_FINAL-NETWR_P = <WA_ZINW_T_ITEM>-NETWR_P + WA_FINAL-NETWR_P.

        ENDIF.
      ENDIF.
    ENDLOOP.
    WA_FINAL-MENGE_D = WA_FINAL-MENGE  - WA_FINAL-MENGE_P  .
    DATA(LV_PER) = ( WA_FINAL-MENGE_P / WA_FINAL-MENGE ) * 100 .
    DATA(LV_PER1) = ( WA_FINAL-MENGE_D /  WA_FINAL-MENGE ) * 100 .


*    BREAK BREDDY .
    IF LV_PER GE 50.

      WA_FINAL-GOOD = LV_PER .
*      WA_FINAL-GOOD = LV_PER .
      IF GOOD = 'X'.

        APPEND WA_FINAL TO IT_FINAL.
        CLEAR : WA_FINAL  .
      ENDIF.

    ELSEIF LV_PER < 50 .
      WA_FINAL-BAD = LV_PER .
      IF BAD = 'X'.
        APPEND WA_FINAL TO IT_FINAL.
        CLEAR : WA_FINAL .
      ENDIF.

    ENDIF.

*    IF LV_PER GE 50.
*      WA_FINAL-GOOD = LV_PER .
*      WA_FINAL-GOOD = LV_PER .
*      IF GOOD = 'X'.
*        APPEND WA_FINAL TO IT_FINAL.
*        CLEAR : WA_FINAL  .
*      ENDIF.
*
*    ELSEIF LV_PER < 50 .
*
*      WA_FINAL-BAD = LV_PER .
*      IF BAD = 'X'.
*        APPEND WA_FINAL TO IT_FINAL.
*        CLEAR : WA_FINAL .
*      ENDIF.

*  ENDIF.

*    IF .
*
*    ENDIF.
*    BREAK BREDDY .

*    BREAK-POINT .
    IF ALL = 'X'.

      WA_FINAL-GOOD = LV_PER .
      WA_FINAL-BAD = LV_PER1 .
*      IF WA_FINAL-GOOD > WA_FINAL-BAD.
      IF WA_FINAL-GOOD GE WA_FINAL-BAD.
        WA_FINAL-GB = 'GOOD' .
*        WA_CELLCOLOR-FNAME = 'GB'.
        WA_CELLCOLOR-FNAME = 'GOOD'.
        WA_CELLCOLOR-COLOR-COL = 5. "color code 1-7, if outside rage defaults to 7
        WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
        WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour



        APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
*        MODIFY IT_FINAL FROM WA_FINAL INDEX LD_INDEX TRANSPORTING CELLCOLORS.
        CLEAR WA_CELLCOLOR.
*        WA_FINAL-GB = 'GOOD' .
        WA_CELLCOLOR-FNAME = 'GB'.
*        WA_CELLCOLOR-FNAME = 'GOOD'.
        WA_CELLCOLOR-COLOR-COL = 5. "color code 1-7, if outside rage defaults to 7
        WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
        WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour



        APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
*        MODIFY IT_FINAL FROM WA_FINAL INDEX LD_INDEX TRANSPORTING CELLCOLORS.
        CLEAR WA_CELLCOLOR.
*        WA_CELLCOLOR-FNAME = 'BAD'.
*        WA_CELLCOLOR-COLOR-COL = 6. "color code 1-7, if outside rage defaults to 7
*        WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
*        WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour
*        APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
**        MODIFY IT_FINAL FROM WA_FINAL INDEX LD_INDEX TRANSPORTING CELLCOLORS.
*        CLEAR WA_CELLCOLOR.


      ELSEIF WA_FINAL-BAD > WA_FINAL-GOOD.

        WA_FINAL-GB = 'BAD' .
        WA_CELLCOLOR-FNAME = 'BAD'.
*        WA_CELLCOLOR-FNAME = 'GB'.
        WA_CELLCOLOR-COLOR-COL = 6. "color code 1-7, if outside rage defaults to 7
        WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
        WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour
        APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
*        MODIFY IT_FINAL FROM WA_FINAL INDEX LD_INDEX TRANSPORTING CELLCOLORS.
        CLEAR WA_CELLCOLOR.

*                WA_FINAL-GB = 'BAD' .
*        WA_CELLCOLOR-FNAME = 'BAD'.
        WA_CELLCOLOR-FNAME = 'GB'.
        WA_CELLCOLOR-COLOR-COL = 6. "color code 1-7, if outside rage defaults to 7
        WA_CELLCOLOR-COLOR-INT = '1'. "1 = Intensified on, 0 = Intensified off
        WA_CELLCOLOR-COLOR-INV = '0'. "1 = text colour, 0 = background colour
        APPEND WA_CELLCOLOR TO WA_FINAL-CELLCOLORS.
*        MODIFY IT_FINAL FROM WA_FINAL INDEX LD_INDEX TRANSPORTING CELLCOLORS.
        CLEAR WA_CELLCOLOR.

      ENDIF.
      APPEND WA_FINAL TO IT_FINAL.
      CLEAR : WA_FINAL .
    ENDIF.
    CLEAR  : WA_FINAL .
*    CLEAR WA_CELLCOLOR.
  ENDLOOP.

*  BREAK BREDDY .

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
  DATA : IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
         WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
         WVARI       TYPE DISVARIANT.
  TYPE-POOLS : SLIS.

  REFRESH : IT_FIELDCAT .
  DATA : WA_LAYOUT TYPE SLIS_LAYOUT_ALV .
  WA_LAYOUT-ZEBRA = 'X' .
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X' .
  WA_LAYOUT-COLTAB_FIELDNAME  = 'CELLCOLORS'.

  IF GOOD = 'X' OR BAD = 'X'.
    WA_FIELDCAT-FIELDNAME = 'EBELN'.
    WA_FIELDCAT-SELTEXT_M = 'PO Number'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'AEDAT'.
    WA_FIELDCAT-SELTEXT_M = 'PO Date'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'EINDT'.
    WA_FIELDCAT-SELTEXT_M = 'Lead Time Date'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'LIFNR'.
    WA_FIELDCAT-SELTEXT_M = 'Vendor'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'NAME'.
    WA_FIELDCAT-SELTEXT_M = 'Vendor Name'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'GROUP'.
    WA_FIELDCAT-SELTEXT_M = 'Group'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'MENGE'.
    WA_FIELDCAT-SELTEXT_M = 'Ordered Quantity'.
    WA_FIELDCAT-DO_SUM = 'X'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'NETWR'.
    WA_FIELDCAT-SELTEXT_M = 'Order Value'.
    WA_FIELDCAT-DO_SUM    = 'X' .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'MENGE_P'.
    WA_FIELDCAT-SELTEXT_M = 'Dispatch Qty'.
    WA_FIELDCAT-DO_SUM = 'X'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'NETWR_P'.
    WA_FIELDCAT-SELTEXT_M = 'Dispatch Value'.
    WA_FIELDCAT-DO_SUM    = 'X' .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'MENGE_D'.
    WA_FIELDCAT-SELTEXT_M = 'Defect Qty'.
    WA_FIELDCAT-DO_SUM = 'X'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

*  WA_FIELDCAT-FIELDNAME = 'GOOD'.
*  WA_FIELDCAT-SELTEXT_M = 'Good'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*  CLEAR : WA_FIELDCAT .
*
*  WA_FIELDCAT-FIELDNAME = 'BAD'.
*  WA_FIELDCAT-SELTEXT_M = 'Bad'.
*  APPEND WA_FIELDCAT TO IT_FIELDCAT.
*  CLEAR : WA_FIELDCAT .

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        I_CALLBACK_PROGRAM      = SY-REPID
        I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
        IS_LAYOUT               = WA_LAYOUT
        IT_FIELDCAT             = IT_FIELDCAT
        I_SAVE                  = 'U'
        IS_VARIANT              = WVARI
      TABLES
        T_OUTTAB                = IT_FINAL
      EXCEPTIONS
        PROGRAM_ERROR           = 1
        OTHERS                  = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

  ELSEIF ALL = 'X' .

    WA_FIELDCAT-FIELDNAME = 'EBELN'.
    WA_FIELDCAT-SELTEXT_M = 'PO Number'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'AEDAT'.
    WA_FIELDCAT-SELTEXT_M = 'PO Date'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'EINDT'.
    WA_FIELDCAT-SELTEXT_M = 'Lead Time Date'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'LIFNR'.
    WA_FIELDCAT-SELTEXT_M = 'Vendor'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'NAME'.
    WA_FIELDCAT-SELTEXT_M = 'Vendor Name'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'GROUP'.
    WA_FIELDCAT-SELTEXT_M = 'Group'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'MENGE'.
    WA_FIELDCAT-SELTEXT_M = 'Ordered Quantity'.
    WA_FIELDCAT-DO_SUM    = 'X' .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'NETWR'.
    WA_FIELDCAT-SELTEXT_M = 'Order Value'.
    WA_FIELDCAT-DO_SUM    = 'X' .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'MENGE_P'.
    WA_FIELDCAT-SELTEXT_M = 'Dispatch Qty'.
    WA_FIELDCAT-DO_SUM    = 'X' .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'NETWR_P'.
    WA_FIELDCAT-SELTEXT_M = 'Dispatch Value'.
    WA_FIELDCAT-DO_SUM    = 'X' .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'MENGE_D'.
    WA_FIELDCAT-SELTEXT_M = 'Defect Qty'.
    WA_FIELDCAT-DO_SUM    = 'X' .
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'GOOD'.
    WA_FIELDCAT-SELTEXT_M = 'Delivered in Percentage%'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .

    WA_FIELDCAT-FIELDNAME = 'BAD'.
    WA_FIELDCAT-SELTEXT_M = 'Undelivered in Percentage%'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    WA_FIELDCAT-FIELDNAME = 'GB'.
    WA_FIELDCAT-SELTEXT_M = 'GOOD/BAD'.
    APPEND WA_FIELDCAT TO IT_FIELDCAT.
    CLEAR : WA_FIELDCAT .


    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        I_CALLBACK_PROGRAM      = SY-REPID
        I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
        IS_LAYOUT               = WA_LAYOUT
        IT_FIELDCAT             = IT_FIELDCAT
        I_SAVE                  = 'U'
        IS_VARIANT              = WVARI
      TABLES
        T_OUTTAB                = IT_FINAL
      EXCEPTIONS
        PROGRAM_ERROR           = 1
        OTHERS                  = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF .
ENDFORM.
FORM USER_COMMAND USING  R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.
  REFRESH IT_FINAL1.
  CASE R_UCOMM.
    WHEN '&IC1'.
      PERFORM GET_PO_DATA USING RS_SELFIELD .
  ENDCASE.
ENDFORM.
FORM GET_PO_DATA  USING  RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA(IT_FINAL2) = IT_FINAL[] .
  READ TABLE IT_FINAL ASSIGNING FIELD-SYMBOL(<WA_FINAL>) INDEX RS_SELFIELD-TABINDEX.

  IF SY-SUBRC = 0 .
    DELETE IT_FINAL2 WHERE EBELN <> <WA_FINAL>-EBELN .
  ENDIF .
  CASE RS_SELFIELD-FIELDNAME.

    WHEN 'EBELN' OR 'MENGE' OR 'MENGE_P' OR 'MENGE_D' OR
         'NETWR_P' OR 'NETWR' OR 'AEDAT' OR 'EINDT' OR 'LIFNR' OR 'NAME' OR 'GROUP'.

      REFRESH : IT_FINAL1.
*      BREAK BREDDY .

      SELECT
         EBELN
         EBELP
         MATNR
         MENGE
         NETWR
         NETPR FROM EKPO INTO TABLE IT_EKPO
               FOR ALL ENTRIES IN IT_FINAL2
               WHERE EBELN = IT_FINAL2-EBELN .

      IF IT_EKPO IS NOT INITIAL .
        SELECT
          MATNR
          SPRAS
          MAKTX FROM MAKT INTO TABLE IT_MAKT
                FOR ALL ENTRIES IN IT_EKPO
                WHERE MATNR = IT_EKPO-MATNR .

        SELECT
          QR_CODE
          EBELN
          EBELP
          MATNR
          MENGE_P
          NETWR_P  FROM ZINW_T_ITEM INTO TABLE IT_ZINW_T_ITEM
                  FOR ALL ENTRIES IN IT_EKPO
                  WHERE EBELN = IT_EKPO-EBELN
                  AND   EBELP = IT_EKPO-EBELP .
      ENDIF .



      LOOP AT IT_EKPO INTO WA_EKPO.
        WA_FINAL1-MATNR = WA_EKPO-MATNR.
        WA_FINAL1-MENGE = WA_EKPO-MENGE .
        WA_FINAL1-NETWR = WA_EKPO-NETWR .
        WA_FINAL1-NETPR = WA_EKPO-NETPR .
        READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_EKPO-MATNR .
        IF SY-SUBRC = 0.
          WA_FINAL1-MAKTX = WA_MAKT-MAKTX.
        ENDIF.
*        READ TABLE IT_ZINW_T_ITEM INTO WA_ZINW_T_ITEM WITH KEY EBELN = WA_EKPO-EBELN  EBELP = WA_EKPO-EBELP.
        LOOP AT IT_ZINW_T_ITEM  INTO WA_ZINW_T_ITEM WHERE EBELN = WA_EKPO-EBELN AND  EBELP = WA_EKPO-EBELP.
          WA_FINAL1-MENGE_P = WA_ZINW_T_ITEM-MENGE_P +  WA_FINAL1-MENGE_P.
          WA_FINAL1-NETWR_P = WA_ZINW_T_ITEM-NETWR_P +  WA_FINAL1-NETWR_P .
        ENDLOOP.

*        IF SY-SUBRC = 0.
*          WA_FINAL1-MENGE_P = WA_ZINW_T_ITEM-MENGE_P +  WA_FINAL1-MENGE_P.
*          WA_FINAL1-NETWR_P = WA_ZINW_T_ITEM-NETWR_P +  WA_FINAL1-NETWR_P .
*        ENDIF.
        APPEND WA_FINAL1 TO IT_FINAL1 .
        CLEAR : WA_FINAL1.
      ENDLOOP.



      DATA: IT_FCAT1  TYPE SLIS_T_FIELDCAT_ALV,
            WA_FCAT1  TYPE SLIS_FIELDCAT_ALV,
            IT_EVENT1 TYPE SLIS_T_EVENT,
            WA_EVENT1 TYPE SLIS_ALV_EVENT.

      DATA WA_LAYOUT1 TYPE SLIS_LAYOUT_ALV.
      WA_LAYOUT1-COLWIDTH_OPTIMIZE = 'X'.
      WA_LAYOUT1-ZEBRA = 'X'.

      WA_FCAT1-FIELDNAME = 'MATNR'.
      WA_FCAT1-SELTEXT_M = 'Material'.
      APPEND  WA_FCAT1 TO IT_FCAT1.
      CLEAR : WA_FCAT1 .

      WA_FCAT1-FIELDNAME = 'MAKTX'.
      WA_FCAT1-SELTEXT_M = 'Material Description'.
      APPEND  WA_FCAT1 TO IT_FCAT1.
      CLEAR : WA_FCAT1 .


      WA_FCAT1-FIELDNAME = 'MENGE'.
      WA_FCAT1-SELTEXT_M = 'Ordered Quantity'.
      WA_FCAT1-DO_SUM    = 'X' ..
      APPEND  WA_FCAT1 TO IT_FCAT1.
      CLEAR : WA_FCAT1 .

      WA_FCAT1-FIELDNAME = 'NETPR'.
      WA_FCAT1-SELTEXT_M = 'Rate'.
      WA_FCAT1-DO_SUM    = 'X' ..
      APPEND  WA_FCAT1 TO IT_FCAT1.
      CLEAR : WA_FCAT1 .


      WA_FCAT1-FIELDNAME = 'NETWR'.
      WA_FCAT1-SELTEXT_M = 'Order Value'.
      WA_FCAT1-DO_SUM    = 'X' .
      APPEND  WA_FCAT1 TO IT_FCAT1.
      CLEAR : WA_FCAT1 .

      WA_FCAT1-FIELDNAME = 'MENGE_P'.
      WA_FCAT1-SELTEXT_M = 'Dispatch Qty'.
      WA_FCAT1-DO_SUM    = 'X' ..
      APPEND  WA_FCAT1 TO IT_FCAT1.
      CLEAR :WA_FCAT1 .

      WA_FCAT1-FIELDNAME = 'NETWR_P'.
      WA_FCAT1-SELTEXT_M = 'Dispatch Value'.
      WA_FCAT1-DO_SUM    = 'X' .
      APPEND  WA_FCAT1 TO IT_FCAT1.
      CLEAR :WA_FCAT1 .



      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          I_CALLBACK_PROGRAM = SY-REPID
          IS_LAYOUT          = WA_LAYOUT1
          IT_FIELDCAT        = IT_FCAT1
          I_DEFAULT          = 'X'              " Initial variant active/inactive logic
          I_SAVE             = 'A'
        TABLES
          T_OUTTAB           = IT_FINAL1
        EXCEPTIONS
          PROGRAM_ERROR      = 1
          OTHERS             = 2.
*          IF SY-SUBRC <> 0.
** Implement suitable error handling here
*          ENDIF.
  ENDCASE.
ENDFORM.
