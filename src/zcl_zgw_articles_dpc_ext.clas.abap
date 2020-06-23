class ZCL_ZGW_ARTICLES_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_ARTICLES_DPC
  create public .

public section.
protected section.

  methods ARTICLE_TYPESET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_ARTICLES_DPC_EXT IMPLEMENTATION.


METHOD ARTICLE_TYPESET_GET_ENTITYSET.
  DATA :
    LV_ID     TYPE KLASSE_D,
    LV_CITY   TYPE ORT01_GP,
    LV_BRAND  TYPE WRF_BRAND_ID,
    LV_VENDOR TYPE LIFNR,
    LS_ENTITY TYPE ZGW_ARTICLES.

  CONSTANTS :
    C_PRICE(8)      VALUE 'Price',
    C_MATKL(8)      VALUE 'Matkl',
    C_BRNAD(8)      VALUE 'BrandId',
    C_CITY(4)       VALUE 'City',
    C_CLASS(5)      VALUE 'Class',
    C_VENDOR(5)     VALUE 'Lifnr',
    C_M(1)          VALUE 'M',
    C_X(1)          VALUE 'X',
    C_BRANDED(2)    VALUE 'EC',  " End Categery
    C_NONBRANDED(2) VALUE 'OC'.  " Open Categery

*  TYPES:
*    BEGIN OF TY_KLAH_H,
*      CLINT TYPE KLAH-CLINT,
*      KLART TYPE KLAH-KLART,
*      CLASS TYPE KLAH-CLASS,
*      OBJEK TYPE KSSK-OBJEK,
*    END OF TY_KLAH_H,
*
**** Item Data
*    BEGIN OF TY_KLAH_I,
*      CLINT TYPE KLAH-CLINT,
*      KLART TYPE KLAH-KLART,
*      CLASS TYPE MARA-MATKL,
*    END OF TY_KLAH_I,
*
*    BEGIN OF TY_ARITICLE,
*      MATNR           TYPE MARA-MATNR,
*      MATKL           TYPE MARA-MATKL,
*      SST_CODE        TYPE MARA-SATNR,
*      PARENT          TYPE MARA-ZZARTICLE,
*      PRICE_FROM      TYPE MARA-ZZPRICE_FRM,
*      PRICE_TO        TYPE MARA-ZZPRICE_TO,
*      SIZE1           TYPE MARA-SIZE1,
*      BRAND_ID        TYPE MARA-BRAND_ID,
*      ZZSTYLE         TYPE MARA-ZZSTYLE,
*      MAKTX           TYPE MAKT-MAKTX,
*      LIFNR           TYPE A502-LIFNR,
*      KBETR           TYPE KONP-KBETR,
*      NAME1           TYPE LFA1-NAME1,
*      CITY            TYPE LFA1-ORT01,
*      LAND1           TYPE LFA1-LAND1,
*      ORT02           TYPE LFA1-ORT02,
*      NAME2           TYPE LFA1-NAME2,
*      PSTLZ           TYPE LFA1-PSTLZ,
*      REGIO           TYPE LFA1-REGIO,
*      STRAS           TYPE LFA1-STRAS,
*      ADRNR           TYPE LFA1-ADRNR,
*      ADDR2_STREET    TYPE LFA1-ADDR2_STREET,
*      ADDR2_HOUSE_NUM TYPE LFA1-ADDR2_HOUSE_NUM,
*      STCD3           TYPE STCD3,
*      WGBEZ           TYPE WGBEZ,
*    END OF TY_ARITICLE.

*  DATA :
*    LT_KLAH_H   TYPE STANDARD TABLE OF TY_KLAH_H,
*    LT_KLAH_I   TYPE STANDARD TABLE OF TY_KLAH_I,
*    LT_ARTICLES TYPE STANDARD TABLE OF TY_ARITICLE.
*
*  FIELD-SYMBOLS :
*    <LS_KLAH_H>   TYPE TY_KLAH_H,
*    <LS_KLAH_I>   TYPE TY_KLAH_I,
*    <LS_ARTICLES> TYPE TY_ARITICLE.

  DATA :
    R_MATNR    TYPE RANGE OF MATNR,
    R_LIFNR    TYPE RANGE OF LIFNR,
    R_GROUP_ID TYPE RANGE OF KLAH-CLASS,
    R_PRICE    TYPE RANGE OF ZPRICE_FROM,
    R_CITY     TYPE RANGE OF ORT01,
    R_MATKL    TYPE RANGE OF MATKL.
*** Filters
*** Select Options
  CHECK IT_FILTER_SELECT_OPTIONS  IS NOT INITIAL.
  LOOP AT IT_FILTER_SELECT_OPTIONS ASSIGNING FIELD-SYMBOL(<LS_FILTER>). "PROPERTY = 'Class'.
    IF SY-SUBRC = 0.
      CASE <LS_FILTER>-PROPERTY.
        WHEN C_CLASS.
          READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING FIELD-SYMBOL(<LS_SEL_OPT>) INDEX 1.
          IF SY-SUBRC = 0.
            LV_ID = <LS_SEL_OPT>-LOW.
            APPEND VALUE #( LOW = <LS_SEL_OPT>-LOW SIGN = 'I' OPTION = 'EQ' ) TO R_GROUP_ID.
          ENDIF.
        WHEN C_BRNAD.
          READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING <LS_SEL_OPT> INDEX 1.
          IF SY-SUBRC = 0.
              LV_BRAND = <LS_SEL_OPT>-LOW.
          ENDIF.
        WHEN C_CITY.
          READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING <LS_SEL_OPT> INDEX 1.
          IF SY-SUBRC = 0.
            LV_CITY = <LS_SEL_OPT>-LOW.
            APPEND VALUE #( LOW = <LS_SEL_OPT>-LOW SIGN = 'I' OPTION = 'EQ' ) TO R_CITY.
          ENDIF.
        WHEN C_VENDOR.
          READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING <LS_SEL_OPT> INDEX 1.
          IF SY-SUBRC = 0.
            LV_VENDOR = <LS_SEL_OPT>-LOW.
            APPEND VALUE #( LOW = <LS_SEL_OPT>-LOW SIGN = 'I' OPTION = 'EQ' ) TO R_LIFNR.
          ENDIF.
        WHEN C_PRICE.
          READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING <LS_SEL_OPT> INDEX 1.
          IF SY-SUBRC = 0.
            APPEND VALUE #( LOW = <LS_SEL_OPT>-LOW SIGN = 'I' OPTION = 'EQ' ) TO R_PRICE.
          ENDIF.
        WHEN C_MATKL.
          READ TABLE <LS_FILTER>-SELECT_OPTIONS ASSIGNING <LS_SEL_OPT> INDEX 1.
          IF SY-SUBRC = 0.
            APPEND VALUE #( LOW = <LS_SEL_OPT>-LOW SIGN = 'I' OPTION = 'EQ' ) TO R_MATKL.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.

*  TRY.
*      ZCL_OD_VENDOR=>GET_CLASS_HEADER(
*        EXPORTING
*          I_CLASS  = LV_ID
*        IMPORTING
*          T_KLAH_H =  LT_KLAH_H ).
*    CATCH CX_AMDP_ERROR. " Exceptions when calling AMDP methods
*  ENDTRY.
*
*  IF LT_KLAH_H IS NOT INITIAL.
*    TRY.
*        ZCL_OD_VENDOR=>GET_CLASS_ITEM(
*          EXPORTING
*            IT_KLAH_H = LT_KLAH_H
*          IMPORTING
*            T_KLAH_I  = LT_KLAH_I ).
*      CATCH CX_AMDP_ERROR. " Exceptions when calling AMDP methods
*    ENDTRY.
*    IF LT_KLAH_I IS NOT INITIAL .
*      IF LV_VENDOR IS INITIAL.
*        TRY .
*            ZCL_OD_ARITICLE=>GET_ARITICLE_DETAILS(
*              EXPORTING
*                IT_KLAH_I  = LT_KLAH_I
**                I_BRAND    = LV_BRAND
*                I_CITY     = LV_CITY
*              IMPORTING
*                T_ARITICLE = LT_ARTICLES ).
*          CATCH CX_AMDP_ERROR. " Exceptions when calling AMDP methods
*        ENDTRY.
*      ELSE.
*        TRY .
*            ZCL_OD_ARITICLE=>GET_ARITICLE_DETAILS_VENDOR(
*              EXPORTING
*                IT_KLAH_I  = LT_KLAH_I
**                I_BRAND    = LV_BRAND
*                I_CITY     = LV_CITY
*                I_VENDOR   = LV_VENDOR
*              IMPORTING
*                T_ARITICLE = LT_ARTICLES ).
*          CATCH CX_AMDP_ERROR. " Exceptions when calling AMDP methods
*        ENDTRY.
*      ENDIF.

*** Filters
  TRY .
      DATA(Q_GROUP_ID) = CL_SHDB_SELTAB=>COMBINE_SELTABS( IT_NAMED_SELTABS = VALUE #( ( NAME = 'CLASS' DREF = REF #( R_GROUP_ID[] ) ) ) ).
      DATA(Q_LFA1) = CL_SHDB_SELTAB=>COMBINE_SELTABS( IT_NAMED_SELTABS = VALUE #( ( NAME = 'LIFNR' DREF = REF #( R_LIFNR[] ) )
                                                                                  ( NAME = 'ORT01' DREF = REF #( R_CITY[] ) ) ) ) .
      DATA(Q_MARA) = CL_SHDB_SELTAB=>COMBINE_SELTABS( IT_NAMED_SELTABS = VALUE #( ( NAME = 'MATNR' DREF = REF #( R_MATNR[] ) )
                                                                                  ( NAME = 'MATKL' DREF = REF #( R_MATKL[] ) ) ) ) .

    CATCH CX_SHDB_EXCEPTION.

  ENDTRY.

*** Get Articles
  TRY .
      ZCL_OD_ARITICLE_G=>GET_ARTICLES(
        EXPORTING
          IQ_MARA     = Q_MARA
          IQ_LFA1     = Q_LFA1
          IQ_GROUP_ID = Q_GROUP_ID
        IMPORTING
          T_ARTICLES  = DATA(LT_ARTICLES)
      ).
    CATCH CX_AMDP_ERROR.
  ENDTRY.

*** Check For Brnaded or Non Branded
  IF LV_BRAND = C_BRANDED.
    DELETE LT_ARTICLES WHERE BRAND_ID IS INITIAL.
  ELSEif LV_BRAND = C_NONBRANDED.
    DELETE LT_ARTICLES WHERE BRAND_ID IS NOT INITIAL.
  ENDIF.

  CHECK LT_ARTICLES IS NOT INITIAL.
*** For Set Material Size
*** GET BOM COMPONETS FOR SET MATERIAL
  SELECT  MAST~MATNR,
          MAST~WERKS,
          MAST~STLNR,
          MAST~STLAL,
          STPO~STLKN,
          STPO~IDNRK,
          STPO~POSNR,
          STPO~MENGE,
          STPO~MEINS,
          MARA~SIZE1
          INTO TABLE @DATA(IT_SIZE)
          FROM MAST AS MAST
          INNER JOIN STPO AS STPO ON STPO~STLTY = @C_M AND MAST~STLNR = STPO~STLNR
          INNER JOIN MARA AS MARA ON MARA~MATNR = STPO~IDNRK
          FOR ALL ENTRIES IN @LT_ARTICLES
          WHERE MAST~MATNR = @LT_ARTICLES-MATNR.

  IF LT_ARTICLES IS NOT INITIAL.
    LOOP AT LT_ARTICLES ASSIGNING FIELD-SYMBOL(<LS_ARTICLES>).
      MOVE-CORRESPONDING <LS_ARTICLES> TO LS_ENTITY.
      IF LS_ENTITY-PRICE_FROM IS INITIAL.
        LS_ENTITY-PRICE_FROM = <LS_ARTICLES>-KBETR.
        LS_ENTITY-PRICE_TO = <LS_ARTICLES>-KBETR.
      ENDIF.
***   Set Material Size
      READ TABLE IT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>) WITH KEY MATNR = <LS_ARTICLES>-MATNR.
      IF SY-SUBRC = 0.
        LOOP AT IT_SIZE ASSIGNING <LS_SIZE> WHERE STLNR = <LS_SIZE>-STLNR.
          IF  LS_ENTITY-SIZE1 IS INITIAL.
            LS_ENTITY-SIZE1 = <LS_SIZE>-SIZE1.
          ELSE.
            LS_ENTITY-SIZE1 = LS_ENTITY-SIZE1 && '-' && <LS_SIZE>-SIZE1.
          ENDIF.
          LS_ENTITY-SET_MAT_FLAG = C_X.
        ENDLOOP.
      ENDIF.
      APPEND LS_ENTITY TO ET_ENTITYSET.
      CLEAR : LS_ENTITY.
    ENDLOOP.
  ENDIF.
ENDMETHOD.
ENDCLASS.
