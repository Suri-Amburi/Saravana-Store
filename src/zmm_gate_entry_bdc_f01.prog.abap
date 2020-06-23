*&---------------------------------------------------------------------*
*& Form BDC_DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  DATA : I_TYPE  TYPE TRUXS_T_TEXT_DATA,
         LV_FILE TYPE RLGRAP-FILENAME.

  IF ENAME EQ 'XLSX' OR ENAME EQ 'XLS'.

    REFRESH GT_FILE[].
    LV_FILE = P_FILE.

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        I_TAB_RAW_DATA       = I_TYPE
        I_FILENAME           = LV_FILE
      TABLES
        I_TAB_CONVERTED_DATA = GT_FILE[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.
*      T_FILE = GT_FILE[].

    DELETE GT_FILE[] FROM 1 TO 2.
  ELSE.
    MESSAGE E069(ZMSG_CLS).
    EXIT.
  ENDIF.

  IF GT_FILE IS INITIAL.
    MESSAGE E070(ZMSG_CLS).
  ENDIF.
ENDFORM.
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

  P_FILE = LI_FILETABLE[ 1 ]-FILENAME.
  SPLIT P_FILE AT '.' INTO FNAME ENAME.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE ENAME TO UPPER CASE.
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
  DATA:
    LV_ITEM(5)      VALUE  '00010',
    LV_PACK_NO(10)  VALUE  '0000000001',
    LV_EXT_LINE(10) VALUE  '0000000010',
    LV_SERIAL_NO(2) VALUE  '01',
    LS_STATUS       TYPE ZINW_T_STATUS,
    LT_WGH01        TYPE TABLE OF WGH01.

  REFRESH : POSRVACCESSVALUES, ITEM, ITEMX, RETURN,POSERVICES,POACCOUNT,POACCOUNTX , GIT_DISPLAY.
  CLEAR : HEADER, HEADERX, LS_POSERVICES, LS_POSRVACCESSVALUES, LS_POACCOUNT  ,LS_POACCOUNTX.
  BREAK CLIKHITHA.
*  IF GL_HDR-LR_NO IS INITIAL.    " ADDED (29-1-20)
  SELECT QR_CODE,
         INWD_DOC,
         EBELN,
         LIFNR,
         NAME1,
         STATUS,
         BILL_NUM,
         TRNS,
         LR_NO,
         ACT_NO_BUD,
         BK_STATION,
         SMALL_BUNDLE,
         BIG_BUNDLE,
         FRT_NO,
         FRT_AMT  FROM ZINW_T_HDR "INTO @DATA(GS_ZINW_T_HDR) WHERE TRNS = IT_FILE-TRANSPORTER_CODE.
         INTO TABLE @DATA(GT_HDR_T)
         FOR ALL ENTRIES IN @GT_FILE
         WHERE TRNS =  @GT_FILE-TRANSPORTER_CODE AND LR_NO = @GT_FILE-LR_NO .".AND SMALL_BUNDLE = @GT_FILE-SMALL_BUNDLES.
*  IF GL_HDR-LR_NO IS INITIAL.   " added (29-1-20)

    LOOP AT GT_FILE ASSIGNING FIELD-SYMBOL(<GG_FILE>).
*       ********************ADDED  ********************
      READ TABLE  GT_HDR_T INTO GL_HDR WITH KEY TRNS = <GG_FILE>-TRANSPORTER_CODE LR_NO = <GG_FILE>-LR_NO.
*****************      added (3-2-20)   ******************************
      if SY-SUBRC = 0.
         APPEND VALUE #( LR_NO = GL_HDR-LR_NO  TRANSPORTER_CODE = GL_HDR-TRNS TYPE = 'E' MESSAGE = 'PO is already Created with this LR NUM and Transporter' )  TO GIT_DISPLAY.
         CONTINUE.
         ENDIF.
********************        end(3-2-20)     *********************
*    IF GL_HDR-LR_NO IS INITIAL.   " added (29-1-20)

      GS_HDR-QR_CODE          =  GL_HDR-QR_CODE      .
      GS_HDR-INWD_DOC         =  GL_HDR-INWD_DOC     .
      GS_HDR-EBELN            =  GL_HDR-EBELN        .
      GS_HDR-LIFNR            =  GL_HDR-LIFNR        .
      GS_HDR-NAME1            =  GL_HDR-NAME1        .
      GS_HDR-STATUS           =  GL_HDR-STATUS       .
      GS_HDR-BILL_NUM         =  GL_HDR-BILL_NUM     .
      GS_HDR-TRNS             =  GL_HDR-TRNS         .
      GS_HDR-LR_NO            =  GL_HDR-LR_NO        .
      GS_HDR-ACT_NO_BUD       =  GL_HDR-ACT_NO_BUD   .
      GS_HDR-BK_STATION       =  GL_HDR-BK_STATION   .
      GS_HDR-SMALL_BUNDLE     =  <GG_FILE>-SMALL_BUNDLES .
      GS_HDR-BIG_BUNDLE       =  <GG_FILE>-BIG_BUNDLES .
      GS_HDR-FRT_NO           =  GL_HDR-FRT_NO       .
      GS_HDR-FRT_AMT          =  GL_HDR-FRT_AMT      .
      IF GL_HDR-ACT_NO_BUD <> ( GS_HDR-SMALL_BUNDLE + GS_HDR-BIG_BUNDLE ).
        MESSAGE E031(ZMSG_CLS).
        EXIT.
      ELSE.
***  'NB'
        DATA : LV_SRVPOS TYPE A729-SRVPOS.
        SELECT * FROM TVARVC INTO TABLE @DATA(LT_ACT) WHERE NAME IN ( 'ZZSMALL_BUNDLE', 'ZZBIG_BUNDLE' ).
        SELECT SINGLE BUKRS, EKORG, EKGRP FROM EKKO INTO @DATA(LS_ORG) WHERE EBELN = @GS_HDR-EBELN.  " ADDED
        SELECT SINGLE * FROM EKPO INTO @DATA(LS_EKPO) WHERE EBELN = @GS_HDR-EBELN.   " ADDED
*** Vandor City
        SELECT SINGLE ORT01 FROM LFA1 INTO @DATA(LV_CITY) WHERE LIFNR  = @GS_HDR-LIFNR.
*** Transporter Price based on City
        SELECT A729~LIFNR
           A729~SRVPOS
           A729~USERF1_TXT
           A729~KNUMH
           KONP~KBETR
           INTO TABLE GT_PRICE
           FROM A729 AS A729
           INNER JOIN KONP AS KONP ON KONP~KNUMH = A729~KNUMH
          WHERE A729~LIFNR = GS_HDR-TRNS AND USERF1_TXT = LV_CITY
           AND A729~KSCHL = 'PRS' AND DATAB LE SY-DATUM AND DATBI GE SY-DATUM.
        BREAK CLIKHITHA.
        IF SY-SUBRC <> 0.
          MESSAGE E037(ZMSG_CLS) WITH GS_HDR-TRNS LV_CITY.       " ADDED <GS_HDR>
        ENDIF.
*** Material Hierarchy
        CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
          EXPORTING
            MATKL       = LS_EKPO-MATKL
            SPRAS       = SY-LANGU
          TABLES
            O_WGH01     = LT_WGH01
          EXCEPTIONS
            NO_BASIS_MG = 1
            NO_MG_HIER  = 2
            OTHERS      = 3.
        IF SY-SUBRC <> 0.
          MESSAGE E036(ZMSG_CLS) WITH LS_EKPO-MATKL. " Hierarchy is not maintained' TYPE 'E'.
        ENDIF.
        READ TABLE LT_WGH01 ASSIGNING FIELD-SYMBOL(<LS_WGH01>) INDEX 1.
        IF SY-SUBRC = 0.
          SELECT SINGLE * FROM ZGL_ACC_T INTO @DATA(LS_GL) WHERE WERKS = @LS_EKPO-WERKS AND WWGHA = @<LS_WGH01>-WWGHA.
          IF SY-SUBRC <> 0.
            MESSAGE E035(ZMSG_CLS) WITH LS_EKPO-WERKS <LS_WGH01>-WWGHB.
          ENDIF.
        ENDIF.
****  Header Details
        HEADER-COMP_CODE    = LS_ORG-BUKRS.
        HEADER-DOC_TYPE     = C_DOC.
        HEADER-VENDOR       = GS_HDR-TRNS.
        HEADER-PURCH_ORG    = LS_ORG-EKORG.
        HEADER-PUR_GROUP    = LS_ORG-EKGRP.
        HEADER-CURRENCY     = 'INR'.

        HEADERX-COMP_CODE   = C_X.
        HEADERX-VENDOR      = C_X.
        HEADERX-DOC_TYPE    = C_X.
        HEADERX-PURCH_ORG   = C_X.
        HEADERX-PUR_GROUP   = C_X.
        HEADERX-CURRENCY    = C_X.
*
        REFRESH ITEM.
        REFRESH ITEMX.
***  For Small Bundle
        IF GS_HDR-SMALL_BUNDLE IS NOT INITIAL AND GS_HDR-BIG_BUNDLE IS NOT INITIAL.
          READ TABLE LT_ACT ASSIGNING FIELD-SYMBOL(<LS_ACT>) WITH KEY NAME = 'ZZSMALL_BUNDLE'.
          IF SY-SUBRC = 0 .
*** Main Item Data
            ITEM-PO_ITEM        = LV_ITEM.
            ITEM-SHORT_TEXT     = 'Service PO'.
            ITEM-PLANT          = LS_EKPO-WERKS.
            ITEM-TAX_CODE       = '1C'.
            ITEM-MATL_GROUP     = LS_EKPO-MATKL.
            ITEM-ITEM_CAT       = C_9.
            ITEM-ACCTASSCAT     = C_K.
            ITEM-PERIOD_IND_EXPIRATION_DATE = C_D.
            ITEM-PCKG_NO        = LV_PACK_NO.
*** Main Item Data Update Flags
            ITEMX-PO_ITEM        = LV_ITEM.
            ITEMX-PO_ITEMX       = C_X.
            ITEMX-SHORT_TEXT     = C_X.
            ITEMX-PLANT          = C_X.
            ITEMX-TAX_CODE       = C_X.
            ITEMX-MATL_GROUP     = C_X.
            ITEMX-ITEM_CAT       = C_X.
            ITEMX-ACCTASSCAT     = C_X.
            ITEMX-ACCTASSCAT     = C_X.
            ITEMX-PERIOD_IND_EXPIRATION_DATE     = C_X.
            ITEMX-PCKG_NO        = C_X.
            APPEND ITEM.
            APPEND ITEMX .
            CLEAR : ITEMX , ITEM.
*** Account Assignment Data
            LS_POACCOUNT-PO_ITEM     = LV_ITEM.
            LS_POACCOUNT-SERIAL_NO   = LV_SERIAL_NO.
            LS_POACCOUNT-GL_ACCOUNT  = LS_GL-GL_ACCOUNT.
            LS_POACCOUNT-COSTCENTER  = LS_GL-COSTCENTER.
*** Account Assignment Data Update Flags
            LS_POACCOUNTX-PO_ITEM    = LV_ITEM.
            LS_POACCOUNTX-PO_ITEMX   = C_X.
            LS_POACCOUNTX-SERIAL_NO  = C_X.
            LS_POACCOUNTX-GL_ACCOUNT = C_X.
            LS_POACCOUNTX-COSTCENTER = C_X.
            APPEND LS_POACCOUNT TO POACCOUNT.
            APPEND LS_POACCOUNTX TO POACCOUNTX.
            CLEAR : LS_POACCOUNT, LS_POACCOUNTX.
*** Serices
***   Line Item 1
            LS_POSERVICES-PCKG_NO    = LV_PACK_NO.
            LS_POSERVICES-LINE_NO    = LV_PACK_NO.
            LS_POSERVICES-OUTL_IND   = C_X.
            LS_POSERVICES-SUBPCKG_NO = LV_PACK_NO + 1.
            APPEND LS_POSERVICES TO POSERVICES.
            CLEAR : LS_POSERVICES.

***   Line Item 2
            CLEAR : LV_SRVPOS.
            LV_SRVPOS =  <LS_ACT>-LOW.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT  = LV_SRVPOS
              IMPORTING
                OUTPUT = LV_SRVPOS.
            READ TABLE GT_PRICE ASSIGNING FIELD-SYMBOL(<LS_PRICE>) WITH KEY SRVPOS = LV_SRVPOS LIFNR = GS_HDR-TRNS.
            IF SY-SUBRC = 0.
              LS_POSERVICES-PCKG_NO    = LV_PACK_NO + 1.
              LS_POSERVICES-LINE_NO    = LV_PACK_NO + 1.
              LS_POSERVICES-EXT_LINE   = LV_EXT_LINE.
              LS_POSERVICES-SERVICE    = <LS_PRICE>-SRVPOS.
              LS_POSERVICES-QUANTITY   = GS_HDR-SMALL_BUNDLE.
              LS_POSERVICES-BASE_UOM   = 'AU'.
              LS_POSERVICES-GR_PRICE   = <LS_PRICE>-KBETR.
              LS_POSERVICES-SHORT_TEXT = 'SMALL BUNDLE'.
              APPEND LS_POSERVICES TO POSERVICES.
              CLEAR : LS_POSERVICES.

*** Services Values
              LS_POSRVACCESSVALUES-PCKG_NO    = LV_PACK_NO + 1.
              LS_POSRVACCESSVALUES-LINE_NO    = LV_PACK_NO + 1.
              LS_POSRVACCESSVALUES-SERNO_LINE = LV_SERIAL_NO.
              LS_POSRVACCESSVALUES-PERCENTAGE = '100'.
              LS_POSRVACCESSVALUES-SERIAL_NO  = LV_SERIAL_NO.
              APPEND LS_POSRVACCESSVALUES TO POSRVACCESSVALUES.
              CLEAR : LS_POSRVACCESSVALUES.
            ELSE.
              MESSAGE E044(ZMSG_CLS) WITH GS_HDR-TRNS LV_CITY LV_SRVPOS.
            ENDIF.
          ENDIF.

          READ TABLE LT_ACT ASSIGNING <LS_ACT> WITH KEY NAME = 'ZZBIG_BUNDLE'.
          IF SY-SUBRC = 0 .
            LV_SRVPOS =  <LS_ACT>-LOW.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT  = LV_SRVPOS
              IMPORTING
                OUTPUT = LV_SRVPOS.
            READ TABLE GT_PRICE ASSIGNING <LS_PRICE> WITH KEY SRVPOS = LV_SRVPOS LIFNR = GS_HDR-TRNS.
            IF SY-SUBRC = 0.
***   Line Item 3
              LS_POSERVICES-PCKG_NO    = LV_PACK_NO + 1.
              LS_POSERVICES-LINE_NO    = LV_PACK_NO + 2.
              LS_POSERVICES-EXT_LINE   = LV_EXT_LINE + 10.
              LS_POSERVICES-SERVICE    = <LS_PRICE>-SRVPOS.
              LS_POSERVICES-QUANTITY   = GS_HDR-BIG_BUNDLE.
              LS_POSERVICES-BASE_UOM   = 'AU'.
              LS_POSERVICES-GR_PRICE   = <LS_PRICE>-KBETR.
              LS_POSERVICES-SHORT_TEXT = 'BIG BUNDLE'.
              APPEND LS_POSERVICES TO POSERVICES.
              CLEAR : LS_POSERVICES.

*** SERVICES VALUES
              LS_POSRVACCESSVALUES-PCKG_NO    = LV_PACK_NO + 1.
              LS_POSRVACCESSVALUES-LINE_NO    = LV_PACK_NO + 2.
              LS_POSRVACCESSVALUES-SERNO_LINE = LV_SERIAL_NO.
              LS_POSRVACCESSVALUES-PERCENTAGE = '100'.
              LS_POSRVACCESSVALUES-SERIAL_NO  = LV_SERIAL_NO.
              APPEND LS_POSRVACCESSVALUES TO POSRVACCESSVALUES.
              CLEAR : LS_POSRVACCESSVALUES.
            ELSE.
              MESSAGE E044(ZMSG_CLS) WITH GS_HDR-TRNS LV_CITY LV_SRVPOS.
            ENDIF.
          ENDIF.
        ELSEIF GS_HDR-SMALL_BUNDLE IS NOT INITIAL.
          READ TABLE LT_ACT ASSIGNING <LS_ACT> WITH KEY NAME = 'ZZSMALL_BUNDLE'.
          IF SY-SUBRC = 0 .
*** Main Item Data
            ITEM-PO_ITEM        = LV_ITEM.
            ITEM-SHORT_TEXT     = 'Service PO'.
            ITEM-PLANT          = LS_EKPO-WERKS.
            ITEM-TAX_CODE       = '1C'.
            ITEM-MATL_GROUP     = LS_EKPO-MATKL.
            ITEM-ITEM_CAT       = C_9.
            ITEM-ACCTASSCAT     = C_K.
            ITEM-PERIOD_IND_EXPIRATION_DATE = C_D.
            ITEM-PCKG_NO        = LV_PACK_NO.

*** Main Item Data Update Flags
            ITEMX-PO_ITEM        = LV_ITEM.
            ITEMX-PO_ITEMX       = C_X.
            ITEMX-SHORT_TEXT     = C_X.
            ITEMX-PLANT          = C_X.
            ITEMX-TAX_CODE       = C_X.
            ITEMX-MATL_GROUP     = C_X.
            ITEMX-ITEM_CAT       = C_X.
            ITEMX-ACCTASSCAT     = C_X.
            ITEMX-ACCTASSCAT     = C_X.
            ITEMX-PERIOD_IND_EXPIRATION_DATE     = C_X.
            ITEMX-PCKG_NO        = C_X.
            APPEND ITEM.
            APPEND ITEMX .
            CLEAR : ITEMX , ITEM.

*** Account Assignment Data
            LS_POACCOUNT-PO_ITEM     = LV_ITEM.
            LS_POACCOUNT-SERIAL_NO   = LV_SERIAL_NO.
            LS_POACCOUNT-GL_ACCOUNT  = LS_GL-GL_ACCOUNT.
            LS_POACCOUNT-COSTCENTER  = LS_GL-COSTCENTER.

*** Account Assignment Data Update Flags
            LS_POACCOUNTX-PO_ITEM    = LV_ITEM.
            LS_POACCOUNTX-PO_ITEMX   = C_X.
            LS_POACCOUNTX-SERIAL_NO  = C_X.
            LS_POACCOUNTX-GL_ACCOUNT = C_X.
            LS_POACCOUNTX-COSTCENTER = C_X.
            APPEND LS_POACCOUNT TO POACCOUNT.
            APPEND LS_POACCOUNTX TO POACCOUNTX.
            CLEAR : LS_POACCOUNT, LS_POACCOUNTX.

*** Serices
***   Line Item 1
            LS_POSERVICES-PCKG_NO    = LV_PACK_NO.
            LS_POSERVICES-LINE_NO    = LV_PACK_NO.
            LS_POSERVICES-OUTL_IND   = C_X.
            LS_POSERVICES-SUBPCKG_NO = LV_PACK_NO + 1.
            APPEND LS_POSERVICES TO POSERVICES.
            CLEAR : LS_POSERVICES.
***   Line Item 2
            CLEAR : LV_SRVPOS.
            LV_SRVPOS =  <LS_ACT>-LOW.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT  = LV_SRVPOS
              IMPORTING
                OUTPUT = LV_SRVPOS.
            READ TABLE GT_PRICE ASSIGNING <LS_PRICE> WITH KEY SRVPOS = LV_SRVPOS LIFNR = GS_HDR-TRNS.
            IF SY-SUBRC = 0.
              LS_POSERVICES-PCKG_NO    = LV_PACK_NO + 1.
              LS_POSERVICES-LINE_NO    = LV_PACK_NO + 1.
              LS_POSERVICES-EXT_LINE   = LV_EXT_LINE.
              LS_POSERVICES-SERVICE    = <LS_PRICE>-SRVPOS.
              LS_POSERVICES-QUANTITY   = GS_HDR-SMALL_BUNDLE.
              LS_POSERVICES-BASE_UOM   = 'AU'.
              LS_POSERVICES-GR_PRICE   = <LS_PRICE>-KBETR.
              LS_POSERVICES-SHORT_TEXT = 'SMALL BUNDLE'.
              APPEND LS_POSERVICES TO POSERVICES.
              CLEAR : LS_POSERVICES.

*** Services Values
              LS_POSRVACCESSVALUES-PCKG_NO    = LV_PACK_NO + 1.
              LS_POSRVACCESSVALUES-LINE_NO    = LV_PACK_NO + 1.
              LS_POSRVACCESSVALUES-SERNO_LINE = LV_SERIAL_NO.
              LS_POSRVACCESSVALUES-PERCENTAGE = '100'.
              LS_POSRVACCESSVALUES-SERIAL_NO  = LV_SERIAL_NO.
              APPEND LS_POSRVACCESSVALUES TO POSRVACCESSVALUES.
              CLEAR : LS_POSRVACCESSVALUES.
            ELSE.
              MESSAGE E044(ZMSG_CLS) WITH GS_HDR-TRNS LV_CITY LV_SRVPOS.
            ENDIF.
          ENDIF.
        ELSEIF GS_HDR-BIG_BUNDLE IS NOT INITIAL.
          READ TABLE LT_ACT ASSIGNING <LS_ACT> WITH KEY NAME = 'ZZBIG_BUNDLE'.
          IF SY-SUBRC = 0 .
*** Main Item Data
            ITEM-PO_ITEM        = LV_ITEM.
            ITEM-SHORT_TEXT     = 'Service PO'.
            ITEM-PLANT          = LS_EKPO-WERKS.
            ITEM-TAX_CODE       = '1C'.
            ITEM-MATL_GROUP     = LS_EKPO-MATKL.
            ITEM-ITEM_CAT       = C_9.
            ITEM-ACCTASSCAT     = C_K.
            ITEM-PERIOD_IND_EXPIRATION_DATE = C_D.
            ITEM-PCKG_NO        = LV_PACK_NO.
*** Main Item Data Update Flags
            ITEMX-PO_ITEM        = LV_ITEM.
            ITEMX-PO_ITEMX       = C_X.
            ITEMX-SHORT_TEXT     = C_X.
            ITEMX-PLANT          = C_X.
            ITEMX-TAX_CODE       = C_X.
            ITEMX-MATL_GROUP     = C_X.
            ITEMX-ITEM_CAT       = C_X.
            ITEMX-ACCTASSCAT     = C_X.
            ITEMX-ACCTASSCAT     = C_X.
            ITEMX-PERIOD_IND_EXPIRATION_DATE     = C_X.
            ITEMX-PCKG_NO        = C_X.
            APPEND ITEM.
            APPEND ITEMX .
            CLEAR : ITEMX , ITEM.
*** Account Assignment Data
            LS_POACCOUNT-PO_ITEM     = LV_ITEM.
            LS_POACCOUNT-SERIAL_NO   = LV_SERIAL_NO.
            LS_POACCOUNT-GL_ACCOUNT  = LS_GL-GL_ACCOUNT.
            LS_POACCOUNT-COSTCENTER  = LS_GL-COSTCENTER.
*** Account Assignment Data Update Flags
            LS_POACCOUNTX-PO_ITEM    = LV_ITEM.
            LS_POACCOUNTX-PO_ITEMX   = C_X.
            LS_POACCOUNTX-SERIAL_NO  = C_X.
            LS_POACCOUNTX-GL_ACCOUNT = C_X.
            LS_POACCOUNTX-COSTCENTER = C_X.
            APPEND LS_POACCOUNT TO POACCOUNT.
            APPEND LS_POACCOUNTX TO POACCOUNTX.
            CLEAR : LS_POACCOUNT, LS_POACCOUNTX.
*** Serices
***   Line Item 1
            LS_POSERVICES-PCKG_NO    = LV_PACK_NO.
            LS_POSERVICES-LINE_NO    = LV_PACK_NO.
            LS_POSERVICES-OUTL_IND   = C_X.
            LS_POSERVICES-SUBPCKG_NO = LV_PACK_NO + 1.
            APPEND LS_POSERVICES TO POSERVICES.
            CLEAR : LS_POSERVICES.
***   Line Item 2
            CLEAR : LV_SRVPOS.
            LV_SRVPOS =  <LS_ACT>-LOW.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT  = LV_SRVPOS
              IMPORTING
                OUTPUT = LV_SRVPOS.
            READ TABLE GT_PRICE ASSIGNING <LS_PRICE> WITH KEY SRVPOS = LV_SRVPOS LIFNR = GS_HDR-TRNS.
            IF SY-SUBRC = 0.
              LS_POSERVICES-PCKG_NO    = LV_PACK_NO + 1.
              LS_POSERVICES-LINE_NO    = LV_PACK_NO + 1.
              LS_POSERVICES-EXT_LINE   = LV_EXT_LINE.
              LS_POSERVICES-SERVICE    = <LS_PRICE>-SRVPOS.
              LS_POSERVICES-QUANTITY   = GS_HDR-BIG_BUNDLE.
              LS_POSERVICES-BASE_UOM   = 'AU'.
              LS_POSERVICES-GR_PRICE   = <LS_PRICE>-KBETR.
              LS_POSERVICES-SHORT_TEXT = 'BIG BUNDLE'.
              APPEND LS_POSERVICES TO POSERVICES.
              CLEAR : LS_POSERVICES.
*** Services Values
              LS_POSRVACCESSVALUES-PCKG_NO    = LV_PACK_NO + 1.
              LS_POSRVACCESSVALUES-LINE_NO    = LV_PACK_NO + 1.
              LS_POSRVACCESSVALUES-SERNO_LINE = LV_SERIAL_NO.
              LS_POSRVACCESSVALUES-PERCENTAGE = '100'.
              LS_POSRVACCESSVALUES-SERIAL_NO  = LV_SERIAL_NO.
              APPEND LS_POSRVACCESSVALUES TO POSRVACCESSVALUES.
              CLEAR : LS_POSRVACCESSVALUES.
            ELSE.
              MESSAGE E044(ZMSG_CLS) WITH GS_HDR-TRNS LV_CITY LV_SRVPOS.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.       "aaa

   IF  GL_HDR-EBELN IS INITIAL .
**************************    end   *******************************
** PO Creation
      CALL FUNCTION 'BAPI_PO_CREATE1'
        EXPORTING
          POHEADER          = HEADER                 " Header Data
          POHEADERX         = HEADERX                " Header Data (Change Parameter)
        IMPORTING
          EXPPURCHASEORDER  = GV_EBELN               " Purchasing Document Number
        TABLES
          RETURN            = RETURN                 " Return Parameter
          POITEM            = ITEM                   " Item Data
          POITEMX           = ITEMX                  " Item Data (Change Parameter)
          POACCOUNT         = POACCOUNT              " Account Assignment Fields
          POACCOUNTX        = POACCOUNTX             " Account Assignment Fields (Change Parameter)
          POSERVICES        = POSERVICES             " External Services: Service Lines
          POSRVACCESSVALUES = POSRVACCESSVALUES.     " External Services: Account Assignment Distribution for Service Lines
*   LOOP AT RETURN INTO WA_RETURN .
      READ TABLE RETURN ASSIGNING FIELD-SYMBOL(<LS_RET>) WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.
        BREAK CLIKHITHA.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = C_X.
        GS_INWD_HDR-SMALL_BUNDLE  = GS_HDR-SMALL_BUNDLE.
        GS_INWD_HDR-BIG_BUNDLE    = GS_HDR-BIG_BUNDLE.
        GS_INWD_HDR-FRT_NO        = GS_HDR-FRT_NO.
        GS_INWD_HDR-FRT_AMT       = GS_HDR-FRT_AMT.
        GS_INWD_HDR-STATUS        = C_02.
        GS_HDR-STATUS           = C_02.
        GS_INWD_HDR-SERVICE_PO    = GV_EBELN.

*** Status Update
        LS_STATUS-INWD_DOC        = GS_INWD_HDR-INWD_DOC.
        LS_STATUS-QR_CODE         = GS_INWD_HDR-QR_CODE.
        LS_STATUS-STATUS_FIELD    = C_QR_CODE.
        LS_STATUS-STATUS_VALUE    = C_QR02.
        LS_STATUS-CREATED_BY      = SY-UNAME.
        LS_STATUS-CREATED_DATE    = SY-DATUM.
        LS_STATUS-CREATED_TIME    = SY-UZEIT.
        LS_STATUS-DESCRIPTION     = 'Gate In'.
        GV_MOD = C_D.
        MODIFY ZINW_T_STATUS FROM LS_STATUS.
        MODIFY ZINW_T_HDR FROM GS_INWD_HDR.
*    LOOP AT RETURN INTO WA_RETURN .

        LOOP AT  RETURN INTO WA_RETURN.
*LOOP at return ASSIGNING FIELD-SYMBOL(<WA_RETURN>).
          IF WA_RETURN-TYPE = 'S' .
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.
*                  IMPORTING
*                    RETURN        =
            .
            IF WA_RETURN-TYPE = 'S' .
              GWA_DISPLAY-LR_NO             = GS_HDR-LR_NO.
              GWA_DISPLAY-TRANSPORTER_CODE  = GS_HDR-TRNS.
              GWA_DISPLAY-SMALL_BUNDLES     = GS_HDR-SMALL_BUNDLE.
              GWA_DISPLAY-BIG_BUNDLES       = GS_HDR-BIG_BUNDLE.
              GWA_DISPLAY-TYPE              = WA_RETURN-TYPE.
              GWA_DISPLAY-MESSAGE           = WA_RETURN-MESSAGE.
              GWA_DISPLAY-PO_NUMBER         = GV_EBELN.
              APPEND GWA_DISPLAY TO GIT_DISPLAY.
              CLEAR GWA_DISPLAY.

            ELSEIF WA_RETURN-TYPE = 'E' .
              GWA_DISPLAY-LR_NO             = GS_HDR-LR_NO.
              GWA_DISPLAY-TRANSPORTER_CODE  = GS_HDR-TRNS.
              GWA_DISPLAY-SMALL_BUNDLES     = GS_HDR-SMALL_BUNDLE.
              GWA_DISPLAY-BIG_BUNDLES       = GS_HDR-BIG_BUNDLE.
              GWA_DISPLAY-TYPE              = WA_RETURN-TYPE.
              GWA_DISPLAY-MESSAGE           = WA_RETURN-MESSAGE.
              GWA_DISPLAY-PO_NUMBER         = GV_EBELN.
              APPEND GWA_DISPLAY TO GIT_DISPLAY.
              CLEAR GWA_DISPLAY.

            ELSE.
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
              MESSAGE ID <LS_RET>-ID TYPE <LS_RET>-TYPE NUMBER <LS_RET>-NUMBER WITH <LS_RET>-MESSAGE_V1 <LS_RET>-MESSAGE_V2
              <LS_RET>-MESSAGE_V3 <LS_RET>-MESSAGE_V4.
            ENDIF.
          ENDIF.
*          endif.
      ENDLOOP.
*      ENDIF.
*      ***********************ADDED (29-1-20)  ***************************
*ELSE.
*  MESSAGE 'Purchase Order for this LR NO  is already exist' TYPE 'I'.
*  WA_RETURN-TYPE = 'E' .
  ENDIF.
****************************     END,  ***************************
    ENDIF..
  ENDLOOP.
*CLEAR gt_file.
  DATA:
    LT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
    LS_LAYOUT TYPE SLIS_LAYOUT_ALV.
* Field Cat log
  APPEND VALUE #( FIELDNAME = 'LR_NO'   TABNAME = 'GIT_DISPLAY' SELTEXT_M = 'LRNO'           OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'TRANSPORTER_CODE'  TABNAME = 'GIT_DISPLAY' SELTEXT_M = 'TRANSPORTER_CODE' OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'SMALL_BUNDLES'  TABNAME = 'GIT_DISPLAY' SELTEXT_M = 'SMALL_BUNDLES' OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'BIG_BUNDLES'  TABNAME = 'GIT_DISPLAY' SELTEXT_M = 'BIG_BUNDLES' OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'TYPE' TABNAME = 'GIT_DISPLAY' SELTEXT_M = 'Message Type'   OUTPUTLEN = 20 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'MESSAGE'    TABNAME = 'GIT_DISPLAY' SELTEXT_M = 'Message'        OUTPUTLEN = 50 ) TO LT_FCAT.
  APPEND VALUE #( FIELDNAME = 'PO_NUMBER'    TABNAME = 'GIT_DISPLAY' SELTEXT_M = 'PO NUMBER'        OUTPUTLEN = 15 ) TO LT_FCAT.

**** Display Final Table
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = LS_LAYOUT
      IT_FIELDCAT        = LT_FCAT
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = GIT_DISPLAY "GT_FILE
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

ENDFORM.
