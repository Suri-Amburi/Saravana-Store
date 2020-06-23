CLASS ZCL_OD_ARTICLE_SS DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*** STANDARD AMDP INTERFACE
    INTERFACES IF_AMDP_MARKER_HDB.
*** TYPES DECLARATION
    TYPES :BEGIN OF TY_ARITICLE,
             MATNR      TYPE MARA-MATNR,
             MATKL      TYPE MARA-MATKL,
             SST_CODE   TYPE MARA-SATNR,
             PARENT     TYPE MARA-ZZARTICLE,
             PRICE_FROM TYPE MARA-ZZPRICE_FRM,
             PRICE_TO   TYPE MARA-ZZPRICE_TO,
             SIZE1      TYPE MARA-SIZE1,
             BRAND_ID   TYPE MARA-BRAND_ID,
             MAKTX      TYPE MAKT-MAKTX,
             LIFNR      TYPE LFA1-LIFNR,
             kbetr      TYPE konp-kbetr,
           END OF TY_ARITICLE,
           TT_ARITICLE TYPE STANDARD TABLE OF TY_ARITICLE.

    CLASS-METHODS GET_ARITICLE_DETAILS_SET_SIZE
             IMPORTING
                VALUE(I_MATKL) TYPE MATKL
                VALUE(I_LIFNR) TYPE LIFNR
             EXPORTING
                VALUE(T_ARITICLE) TYPE TT_ARITICLE
             RAISING   CX_AMDP_ERROR.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_OD_ARTICLE_SS IMPLEMENTATION.

  METHOD GET_ARITICLE_DETAILS_SET_SIZE BY DATABASE PROCEDURE
                                          FOR HDB
                                          LANGUAGE SQLSCRIPT
                                          OPTIONS READ-ONLY
                                          USING  MARA MAKT A502 KONP.
    T_ARITICLE =  SELECT
                   mara.matnr,
                   mara.matkl,
                   mara.SATNR as sst_code,
                   mara.ZZARTICLE as PARENT,
                   mara.ZZPRICE_FRM as PRICE_FROM ,
                   mara.ZZPRICE_to as PRICE_to,
                   mara.SIZE1,
                   mara.BRAND_ID,
                   makt.maktx,
                   a502.lifnr,
                   konp.kbetr
                   from mara as mara
                   inner join makt as makt on makt.matnr = mara.matnr
                   inner join a502 as a502 on a502.matnr = mara.matnr
                   inner join KONP as KONP on konp.KNUMH = A502.KNUMH
                   where mara.matkl = I_MATKL AND a502.lifnr = i_lifnr
                   and A502.DATAB <= CURRENT_DATE AND A502.DATBI >= CURRENT_DATE and KONP.LOEVM_KO != 'X'
                   AND A502.KSCHL in ( 'PB00', 'ZMKP' );
  ENDMETHOD.
ENDCLASS.
