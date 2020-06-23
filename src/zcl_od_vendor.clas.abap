CLASS ZCL_OD_VENDOR DEFINITION
  PUBLIC
    FINAL
      CREATE PUBLIC.

  PUBLIC SECTION.
*** STANDARD AMDP INTERFACE
    INTERFACES IF_AMDP_MARKER_HDB.
*** TYPES DECLARATION
*** Header Data
    TYPES:
      BEGIN OF TY_KLAH_H,
        CLINT TYPE KLAH-CLINT,
        KLART TYPE KLAH-KLART,
        CLASS TYPE KLAH-CLASS,
        OBJEK TYPE KSSK-OBJEK,
      END OF TY_KLAH_H,
      TT_KLAH_H TYPE STANDARD TABLE OF TY_KLAH_H,

*** Item Data
      BEGIN OF TY_KLAH_I,
        CLINT TYPE KLAH-CLINT,
        KLART TYPE KLAH-KLART,
        CLASS TYPE MARA-MATKL,
      END OF TY_KLAH_I,
      TT_KLAH_I TYPE STANDARD TABLE OF TY_KLAH_I,

      BEGIN OF TY_LFA1,
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
      END OF TY_LFA1,
      TT_LFA1 TYPE STANDARD TABLE OF TY_LFA1.
    DATA : LV_DATE TYPE DATE3.


*** Methods
    CLASS-METHODS  GET_CLASS_HEADER
      IMPORTING
                VALUE(I_CLASS)  TYPE KLASSE_D
      EXPORTING
                VALUE(T_KLAH_H) TYPE TT_KLAH_H
      RAISING   CX_AMDP_ERROR.

    CLASS-METHODS  GET_CLASS_ITEM
      IMPORTING
                VALUE(IT_KLAH_H) TYPE TT_KLAH_H
      EXPORTING
                VALUE(T_KLAH_I)  TYPE TT_KLAH_I
      RAISING   CX_AMDP_ERROR.

*    CLASS-METHODS  GET_VENDOR_DETAILS
*      IMPORTING
*                VALUE(IT_KLAH_I) TYPE TT_KLAH_I
*      EXPORTING
*                VALUE(T_LFA1)    TYPE TT_LFA1
*      RAISING   CX_AMDP_ERROR.

          CLASS-METHODS : GET_vendor
      IMPORTING
                VALUE(I_CLIENT)  TYPE SY-MANDT
                VALUE(IQ_lifnr) TYPE STRING
                VALUE(IQ_GROUP_ID) TYPE STRING
      EXPORTING VALUE(T_lfa1)    TYPE TT_lfa1.



  PROTECTED  SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_OD_VENDOR IMPLEMENTATION.

  METHOD GET_CLASS_HEADER BY DATABASE PROCEDURE
                       FOR HDB
                       LANGUAGE SQLSCRIPT
                       OPTIONS READ-ONLY
                       USING  KLAH KSSK.
*** Get Client IDs for Hyrachy
    T_KLAH_H = SELECT
                  KLAH.CLINT,
                  KLAH.KLART,
                  KLAH.CLASS,
                  KSSK.OBJEK
                  FROM KLAH AS KLAH
                  INNER JOIN KSSK AS KSSK ON KSSK.CLINT = KLAH.CLINT
                  WHERE KLAH.KLART = '026' AND KLAH.WWSKZ = '0' AND CLASS = i_class;
  ENDMETHOD.

  METHOD GET_CLASS_ITEM BY DATABASE PROCEDURE
                     FOR HDB
                     LANGUAGE SQLSCRIPT
                     OPTIONS READ-ONLY
                     USING  KLAH.
    T_KLAH_I = SELECT
                    KLAH.CLINT,
                    KLAH.KLART,
                    KLAH.CLASS
                    FROM KLAH AS KLAH
                    INNER join :IT_KLAH_H as IT_KLAH_H
                    on KLAH.MANDT = SESSION_CONTEXT('CLIENT') and
                    KLAH.clint = IT_KLAH_H.OBJEK WHERE KLAH.WWSKZ = '1';

  ENDMETHOD.


  METHOD GET_VENDOR BY DATABASE PROCEDURE FOR HDB
                  LANGUAGE SQLSCRIPT
                  OPTIONS READ-ONLY
                  USING KLAH KSSK MARA LFA1 A502.

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

*    T_LFA1 = SELECT
*                MARA.MATKL,
*                A502.LIFNR,
*                LFA1.LAND1,
*                LFA1.NAME1,
*                LFA1.NAME2,
*                LFA1.ORT01,
*                LFA1.ORT02,
*                LFA1.PSTLZ,
*                LFA1.REGIO,
*                LFA1.STRAS,
*                LFA1.ADRNR,
*                LFA1.ADDR2_STREET,
*                LFA1.ADDR2_HOUSE_NUM
*                FROM MARA AS MARA
*                INNER JOIN :IT_KLAH_I as IT_KLAH_I on
*                mara.MANDT = SESSION_CONTEXT('CLIENT') and
*                MARA.MATKL = IT_KLAH_I.CLASS
*                INNER JOIN A502 AS A502 ON A502.MATNR = MARA.MATNR
*                INNER JOIN LFA1 AS LFA1 ON LFA1.LIFNR = A502.LIFNR
*                WHERE A502.DATAB <= CURRENT_DATE AND A502.DATBI >= CURRENT_DATE;
  ENDMETHOD.
ENDCLASS.
