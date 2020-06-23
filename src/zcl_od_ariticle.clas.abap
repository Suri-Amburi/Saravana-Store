CLASS ZCL_OD_ARITICLE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*** STANDARD AMDP INTERFACE
    INTERFACES IF_AMDP_MARKER_HDB.
*** TYPES DECLARATION
*** ITEM DATA
    TYPES:
      BEGIN OF TY_KLAH_I,
        CLINT TYPE KLAH-CLINT,
        KLART TYPE KLAH-KLART,
        CLASS TYPE MARA-MATKL,
      END OF TY_KLAH_I,
      TT_KLAH_I TYPE STANDARD TABLE OF TY_KLAH_I,

      BEGIN OF TY_ARITICLE,
        MATNR           TYPE MARA-MATNR,
        MATKL           TYPE MARA-MATKL,
        SST_CODE        TYPE MARA-SATNR,
        PARENT          TYPE MARA-ZZARTICLE,
        PRICE_FROM      TYPE MARA-ZZPRICE_FRM,
        PRICE_TO        TYPE MARA-ZZPRICE_TO,
        SIZE1           TYPE MARA-SIZE1,
        BRAND_ID        TYPE MARA-BRAND_ID,
        Zzstyle         type mara-Zzstyle,
        MAKTX           TYPE MAKT-MAKTX,
        LIFNR           TYPE A502-LIFNR,
        kbetr           type konp-KBETR,
        NAME1           TYPE LFA1-NAME1,
        CITY            TYPE LFA1-ORT01,
        LAND1           TYPE LFA1-LAND1,
        ORT02           TYPE LFA1-ORT02,
        NAME2           TYPE LFA1-NAME2,
        PSTLZ           TYPE LFA1-PSTLZ,
        REGIO           TYPE LFA1-REGIO,
        STRAS           TYPE LFA1-STRAS,
        ADRNR           TYPE LFA1-ADRNR,
        ADDR2_STREET    TYPE LFA1-ADDR2_STREET,
        ADDR2_HOUSE_NUM TYPE LFA1-ADDR2_HOUSE_NUM,
        STCD3 type STCD3,
        WGBEZ TYPE WGBEZ,
      END OF TY_ARITICLE,
      TT_ARITICLE TYPE STANDARD TABLE OF TY_ARITICLE.

    CLASS-METHODS GET_ARITICLE_DETAILS
      IMPORTING
                VALUE(IT_KLAH_I)  TYPE TT_KLAH_I
*                VALUE(I_BRAND)    TYPE WRF_BRAND_ID
                VALUE(I_CITY)     TYPE ORT01_GP
      EXPORTING
                VALUE(T_ARITICLE) TYPE TT_ARITICLE
      RAISING   CX_AMDP_ERROR.

    CLASS-METHODS GET_ARITICLE_DETAILS_VENDOR
      IMPORTING
        VALUE(IT_KLAH_I)  TYPE TT_KLAH_I
*        VALUE(I_BRAND)    TYPE WRF_BRAND_ID
        VALUE(I_CITY)     TYPE ORT01_GP
        VALUE(I_VENDOR)   TYPE LIFNR
      EXPORTING
        VALUE(T_ARITICLE) TYPE TT_ARITICLE.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_OD_ARITICLE IMPLEMENTATION.


  METHOD GET_ARITICLE_DETAILS BY DATABASE PROCEDURE
                       FOR HDB
                       LANGUAGE SQLSCRIPT
                       OPTIONS READ-ONLY
                       USING  MARA LFA1 MAKT A502 T023T KONP.
    T_ARITICLE =  SELECT
                 mara.matnr,
                 mara.matkl,
                 mara.SATNR as sst_code,
                 mara.ZZARTICLE as PARENT,
                 mara.ZZPRICE_FRM as PRICE_FROM ,
                 mara.ZZPRICE_to as PRICE_to,
                 mara.SIZE1,
                 mara.BRAND_ID,
                 mara.Zzstyle,
                 makt.maktx,
                 a502.lifnr,
                 konp.kbetr,
                 lfa1.name1,
                 lfa1.ORT01 as city,
                 LFA1.LAND1,
                 LFA1.ORT02,
                 LFA1.NAME2,
                 LFA1.PSTLZ,
                 LFA1.REGIO,
                 LFA1.STRAS,
                 LFA1.ADRNR,
                 LFA1.ADDR2_STREET,
                 LFA1.ADDR2_HOUSE_NUM,
                 LFA1.STCD3,
                 T023T.WGBEZ
                  from mara as mara
                  inner join :IT_KLAH_I as IT_KLAH_I on mara.matkl = IT_KLAH_I.class
                  inner join a502 as a502 on a502.matnr = mara.matnr
                  inner join KONP as KONP on konp.KNUMH = A502.KNUMH
                  inner join lfa1 as lfa1 on lfa1.lifnr = a502.lifnr
                  inner join makt as makt on makt.matnr = mara.matnr
                  left  OUTER JOIN t023t as t023t on t023t.MATKL = mara.MATKL and t023t.SPRAS = 'E'
                  where lfa1.ort01 = i_city and KONP.LOEVM_KO != 'X'
                  and A502.DATAB <= CURRENT_DATE AND A502.DATBI >= CURRENT_DATE AND A502.KSCHL in ( 'PB00', 'ZMKP' );
  ENDMETHOD.

  METHOD GET_ARITICLE_DETAILS_VENDOR BY DATABASE PROCEDURE
                     FOR HDB
                     LANGUAGE SQLSCRIPT
                     OPTIONS READ-ONLY
                     USING  MARA LFA1 MAKT A502 T023T konp.
*  T_ARITICLE =  SELECT
*              mara.matnr,
*              mara.matkl,
*              mara.SATNR as sst_code,
*              mara.ZZARTICLE as PARENT,
*              mara.ZZPRICE_FRM as PRICE_FROM ,
*              mara.ZZPRICE_to as PRICE_to,
*              mara.SIZE1,
*              mara.BRAND_ID,
*              mara.Zzstyle,
*              makt.maktx,
*              a502.lifnr,
*              konp.kbetr,
*              lfa1.name1,
*              lfa1.ORT01 as city,
*              LFA1.LAND1,
*              LFA1.ORT02,
*              LFA1.NAME2,
*              LFA1.PSTLZ,
*              LFA1.REGIO,
*              LFA1.STRAS,
*              LFA1.ADRNR,
*              LFA1.ADDR2_STREET,
*              LFA1.ADDR2_HOUSE_NUM,
*              LFA1.STCD3,
*              T023T.WGBEZ
*              from mara as mara
*              inner join :IT_KLAH_I as IT_KLAH_I on mara.matkl = IT_KLAH_I.class
*              inner join a502 as a502 on a502.matnr = mara.matnr
*              inner join KONP as KONP on konp.KNUMH = A502.KNUMH
*              inner join lfa1 as lfa1 on lfa1.lifnr = a502.lifnr
*              inner join makt as makt on makt.matnr = mara.matnr
*              left  OUTER JOIN t023t as t023t on t023t.MATKL = mara.MATKL and t023t.SPRAS = 'E'
*             where lfa1.ort01 = i_city AND A502.lifnr = I_VENDOR and KONP.LOEVM_KO != 'X'
*              and A502.DATAB <= CURRENT_DATE AND A502.DATBI >= CURRENT_DATE;

              T_ARITICLE =  SELECT
                 mara.matnr,
                 mara.matkl,
                 mara.SATNR as sst_code,
                 mara.ZZARTICLE as PARENT,
                 mara.ZZPRICE_FRM as PRICE_FROM ,
                 mara.ZZPRICE_to as PRICE_to,
                 mara.SIZE1,
                 mara.BRAND_ID,
                 mara.Zzstyle,
                 makt.maktx,
                 a502.lifnr,
                 konp.kbetr,
                 lfa1.name1,
                 lfa1.ORT01 as city,
                 LFA1.LAND1,
                 LFA1.ORT02,
                 LFA1.NAME2,
                 LFA1.PSTLZ,
                 LFA1.REGIO,
                 LFA1.STRAS,
                 LFA1.ADRNR,
                 LFA1.ADDR2_STREET,
                 LFA1.ADDR2_HOUSE_NUM,
                 LFA1.STCD3,
                 T023T.WGBEZ
                  from mara as mara
                  inner join :IT_KLAH_I as IT_KLAH_I on mara.matkl = IT_KLAH_I.class
                  inner join a502 as a502 on a502.matnr = mara.matnr
                  inner join KONP as KONP on konp.KNUMH = A502.KNUMH
                  inner join lfa1 as lfa1 on lfa1.lifnr = a502.lifnr
                  LEFT OUTER join makt as makt on makt.matnr = mara.matnr
                  left  OUTER JOIN t023t as t023t on t023t.MATKL = mara.MATKL and t023t.SPRAS = 'E'
                  where lfa1.ort01 = i_city and lfa1.lifnr = i_vendor AND KONP.LOEVM_KO != 'X'
                  and A502.DATAB <= CURRENT_DATE AND A502.DATBI >= CURRENT_DATE and A502.KSCHL in ( 'PB00', 'ZMKP' );


  ENDMETHOD.
ENDCLASS.
