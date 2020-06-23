CLASS ZMATERIAL_DISPLAY DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES IF_AMDP_MARKER_HDB .

types : BEGIN OF ty_a502 ,
        CATEGORY_ID type klah-class ,
        matnr type mara-matnr,
        matkl type mara-matkl,
        lifnr  type a502-lifnr,
        end of ty_a502 .

types : BEGIN OF ty_a503 ,
        CATEGORY_ID type klah-class ,
        kschl type A503-KSCHL ,
        lifnr type A503-LIFNR ,
        MATkl type A503-MATkl ,
        KFRST type A503-KFRST ,
        DATBI type A503-DATBI ,
        DATAB type A503-DATAB ,
        KNUMH type A503-KNUMH ,
        matnr type MARA-matnr ,
        satnr type MARA-SATNR ,
        prdha type MARA-PRDHA ,
        meins type MARA-MEINS ,
        ean11 type MARA-EAN11 ,
        brgew type MARA-BRGEW ,
        ntgew type MARA-NTGEW ,
        brand_id type MARA-BRAND_ID ,
        attyp type MARA-ATTYP ,
        laeda type MARA-LAEDA ,
        color type MARA-COLOR ,
        size1  type MARA-SIZE1 ,
        ZZPRICE_FRM type  MARA-ZZPRICE_FRM ,
        ZZPRICE_TO type MARA-ZZPRICE_TO ,
        ZZARTICLE type MARA-ZZARTICLE,
        ZZPO_ORDER_TXT type MARA-ZZPO_ORDER_TXT,
        MAKTX type MAKT-MAKTX ,
        KBETR type KONP-KBETR ,
        STLNR type MAST-STLNR ,
        WGBEZ60 type T023T-WGBEZ60 ,

        end of ty_a503 .

types : it_a503 type STANDARD TABLE OF ty_a503 ,
        it_a502 TYPE STANDARD TABLE OF ty_a502 .

CLASS-METHODS GET_OUTPUT_PRD
        IMPORTING
        VALUE(GROUP_ID)    TYPE wwgha
        VALUE(IM_DATE_FROM)  TYPE sy-datum
        VALUE(IM_DATE_TO) TYPE sy-datum
        EXPORTING
        VALUE(ET_a503) TYPE it_a503.

ENDCLASS.

 CLASS ZMATERIAL_DISPLAY IMPLEMENTATION.

 METHOD GET_OUTPUT_PRD BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY USING  a503 MARA klah kssk konp mast T023T makt.


      ET_a503 = select
                klah.class as CATEGORY_ID ,
                A503.KSCHL ,
                A503.LIFNR ,
                A503.MATkl ,
                A503.KFRST ,
                A503.DATBI ,
                A503.DATAB ,
                A503.KNUMH ,
                MARA.matnr ,
                MARA.SATNR ,
                MARA.PRDHA ,
                MARA.MEINS ,
                MARA.EAN11 ,
                MARA.BRGEW ,
                MARA.NTGEW ,
                MARA.BRAND_ID ,
                MARA.ATTYP ,
                MARA.LAEDA ,
                MARA.COLOR ,
                MARA.SIZE1 ,
                MARA.ZZPRICE_FRM ,
                MARA.ZZPRICE_TO ,
                MARA.ZZARTICLE,
                MARA.ZZPO_ORDER_TXT,
                MAKT.MAKTX ,
                KONP.KBETR ,
                MAST.STLNR ,
                T023T.WGBEZ60
                FROM KLAH AS KLAH
                INNER JOIN KSSK AS KSSK ON KSSK.CLINT = KLAH.CLINT
                INNER JOIN KLAH AS KLAH1 ON KLAH1.clint = kssk.OBJEK
                left outer join mara as mara on mara.matkl = klah1.class
                inner join a503 as a503 on a503.matkl = mara.matkl
                INNER join konp as konp on konp.knumh = a503.knumh
                left outer join mast as mast on mast.matnr = mara.matnr
                left outer join t023t as t023t on t023t.matkl = mara.matkl
                left outer join makt as makt on makt.matnr    = mara.matnr
                WHERE ( ( ERSDA BETWEEN IM_DATE_FROM AND IM_DATE_TO ) OR ( LAEDA BETWEEN IM_DATE_FROM AND IM_DATE_TO ) )
                and klah.class = GROUP_ID
                and klah.WWSKZ = '0'
                and klah.KLART = '026'
*and a503.lifnr in ( 'SC0000007' , 'SC0000012' , 'SC0000019')
*and a503.matkl = 'BR18'
                and konp.loevm_ko = ' ';





   ENDMETHOD .











ENDCLASS.
