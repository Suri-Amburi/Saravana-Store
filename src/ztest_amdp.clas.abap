CLASS ZTEST_AMDP DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES :
      BEGIN OF TY_EKKO,
        EBELN TYPE EBELN,
        BSART TYPE BSART,
        ERNAM TYPE ERNAM,
      END OF TY_EKKO,
      TT_EKKO TYPE STANDARD TABLE OF TY_EKKO,

      BEGIN OF TY_lfa1,
        class           type KLAH-CLASS,
        MATKL           TYPE MARA-MATKL,
        LIFNR           TYPE A502-LIFNR,
        LAND1           TYPE LFA1-LAND1,
        NAME1           TYPE LFA1-NAME1,
        NAME2           TYPE LFA1-NAME2,
        ORT01           TYPE LFA1-ORT01,
        ORT02           TYPE LFA1-ORT02,
        PSTLZ           TYPE LFA1-PSTLZ,
        REGIO           TYPE LFA1-REGIO,
        STRAS           TYPE LFA1-STRAS,
        ADRNR           TYPE LFA1-ADRNR,
        ADDR2_STREET    TYPE LFA1-ADDR2_STREET,
        ADDR2_HOUSE_NUM TYPE LFA1-ADDR2_HOUSE_NUM,
      END OF TY_lfa1,
      tt_lfa1 TYPE TABLE OF ty_lfa1.


*** STANDARD AMDP INTERFACE
    INTERFACES IF_AMDP_MARKER_HDB.

    CLASS-METHODS : GET_DATA
      IMPORTING
                VALUE(I_CLIENT)  TYPE SY-MANDT
                VALUE(I_FILTERS) TYPE STRING
      EXPORTING VALUE(T_EKKO)    TYPE TT_EKKO.

          CLASS-METHODS : GET_vendor
      IMPORTING
                VALUE(I_CLIENT)  TYPE SY-MANDT
                VALUE(IQ_lifnr) TYPE STRING
                VALUE(IQ_GROUP_ID) TYPE STRING
      EXPORTING VALUE(T_lfa1)    TYPE TT_lfa1.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZTEST_AMDP IMPLEMENTATION.
  METHOD : GET_DATA BY DATABASE PROCEDURE
                    FOR HDB
                    LANGUAGE SQLSCRIPT
                    OPTIONS READ-ONLY
                    USING EKKO .
* Filtration based on Selection screen input
    lt_DB = apply_filter ( EKKO, :I_FILTERS);
    t_ekko = select
                 ekko.ebeln,
                 ekko.BSART,
                 ekko.ERNAM
                 from :lt_DB as ekko;

  ENDMETHOD.

  method get_vendor by DATABASE PROCEDURE FOR HDB
                    LANGUAGE SQLSCRIPT
                    OPTIONS READ-ONLY
                    using klah kssk mara lfa1 a502.

       lt_klah = apply_filter ( klah, :iQ_GROUP_ID);
       lt_LFA1 = apply_filter ( LFA1, :iQ_Lifnr);

       t_lfa1 = SELECT DISTINCT
KLAH.CLASS,
KLAH1.CLASS AS MATKL,
LFA1.LIFNR ,
LFA1.LAND1,
LFA1.NAME1,
LFA1.NAME2,
LFA1.ORT01,
LFA1.ORT02,
LFA1.PSTLZ,
LFA1.REGIO,
LFA1.STRAS,
LFA1.ADRNR,
LFA1.ADDR2_STREET,
LFA1.ADDR2_HOUSE_NUM
FROM :lt_klah AS KLAH
INNER JOIN KSSK AS KSSK  ON KSSK.clint = KLAH.CLINT
INNER JOIN KLAH AS KLAH1 ON KSSK.OBJEK = KLAH1.CLINT
INNER JOIN MARA AS MARA  ON MARA.MATKL = KLAH1.CLASS
INNER JOIN A502 AS A502  ON A502.MATNR = MARA.MATNR
INNER JOIN :LT_LFA1 AS LFA1  ON LFA1.LIFNR = A502.LIFNR
WHERE KLAH.KLART = '026';
    endmethod.
ENDCLASS.
