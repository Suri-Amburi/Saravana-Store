*&---------------------------------------------------------------------*
*& Include          ZHR_EMP_MASTER_TOP
*&---------------------------------------------------------------------*
TABLES: PA0000, PA0001, PA0002, PA0007, PA0009, PA0021, PA0006, PA0105, PA0185, PERNR.
TYPE-POOLS: SLIS.

TYPES: BEGIN OF TY_PA0000,
         PERNR TYPE PERSNO,
         BEGDA TYPE BEGDA,              "BEGIN DATE
       END OF TY_PA0000,

       BEGIN OF TY_PA0001,
         PERNR TYPE PERSNO,             "PERSONNE NO
         WERKS TYPE PERSA,              "POSTED AT (PERSONNEL AREA KEY
         PLANS TYPE PLANS,              "POSITION
         PERSG TYPE PERSG,              "EMPLOYEE GROUP KEY
         PERSK TYPE PERSK,              "EMPLOYEE SUB-GROUP KEY
         BTRTL TYPE	BTRTL,              "PERSONNEL SUB-AREA KEY
         SUBTY TYPE SUBTY,
       END OF TY_PA0001,

       BEGIN OF TY_PA0002,
         PERNR TYPE PERSNO,
         GESCH TYPE GESCH,              "GENDER
         GBDAT TYPE GBDAT,              "DATE OF BIRTH
         VNAMC TYPE VORNAMC,            "FIRST NAME
         NCHMC TYPE NACHNMC,            "LAST NAME
       END OF TY_PA0002,

       BEGIN OF TY_PA0006,
         PERNR TYPE PERSNO,             "PERSONNE NO
         ANSSA TYPE ANSSA,              "Address KEY
         SUBTY TYPE SUBTY,
         NAME2 TYPE PAD_CONAM,          "CARE OF
         STRAS TYPE PAD_STRAS,          "STREET & HOUSE NO
         LOCAT TYPE PAD_LOCAT,          "2ND ADDRESS lINE
         PSTLZ TYPE PSTLZ_HR,           "POSTAL CODE
         ORT01 TYPE PAD_ORT01,          "CITY
         ORT02 TYPE PAD_ORT02,          "DICTRICT
         LAND1 TYPE LAND1,              "COUNTRY KEY
       END OF TY_PA0006,

       BEGIN OF TY_PA0007,
         PERNR TYPE PERSNO,             "PERSONNE NO
         SCHKZ TYPE SCHKN,              "WORKING SHIFT
       END OF TY_PA0007,

       BEGIN OF TY_PA0009,
         PERNR TYPE PERSNO,             "PERSONNE NO
         BNKSA TYPE BNKSA,
         BANKL TYPE	BANKK,              "Bank Name
         BANKN TYPE BANKN,              "Bank Account No
       END OF TY_PA0009,

       BEGIN OF TY_PA0021,
         PERNR TYPE PERSNO,
         SUBTY TYPE SUBTY,
         FAVOR TYPE PAD_VORNA,          " FIRST NAME
         FANAM TYPE PAD_NACHN,          " LAST NAME
         FAMSA TYPE FAMSA,              "FATHERS NAME
       END OF TY_PA0021,

       BEGIN OF TY_PA0105,
         PERNR      TYPE PERSNO,        "PERSONNE NO
         SUBTY      TYPE SUBTY,
         USRTY      TYPE USRTY,         "DRIVING LOCENSE NO
         USRID      TYPE SYSID,         "CELL NO
         USRID_LONG TYPE COMM_ID_LONG,  "EMAIL ID
       END OF TY_PA0105,

       BEGIN OF TY_PA0185,
         PERNR TYPE PERSNO,
         SUBTY TYPE SUBTY,
         ICNUM TYPE PSG_IDNUM,          "IDENTITY NUMBER KEY
       END OF TY_PA0185,

       BEGIN OF TY_T501T,
         PERSG TYPE T501T-PERSG,
         PTEXT TYPE T501T-PTEXT,        "Employee Group
       END OF TY_T501T,

       BEGIN OF TY_T503T,
         PERSK TYPE T503T-PERSK,
         PTEXT TYPE T503T-PTEXT,        "Employee Subgroup
       END OF TY_T503T,

       BEGIN OF TY_T001P,
         BTRTL TYPE BTRTL_001P,         "Personnel Subarea
         BTEXT TYPE BTRTX,              "Personnel Subarea Text
       END OF TY_T001P,

       BEGIN OF TY_T500P,
         PERSA TYPE PERSA,              "PERSONNEL AREA KEY
         NAME1 TYPE PBTXT,              "PERSONNEL AREA/POSTED AT
       END OF TY_T500P,

       BEGIN OF TY_T005T,
         LAND1 TYPE LAND1,              "COUNTRY KEY
         SPRAS TYPE SPRAS,
         LANDX TYPE LANDX,              "COUNTRY NAME
       END OF TY_T005T.
*       BEGIN OF TY_T591S,
*         SUBTY  TYPE SUBTY_591A,
*         INFTY  TYPE INFTY,             "INFOTYPE
*         STEXT  TYPE SBTTX,             "PERMANENT/TEMPORARY ADDRESS
*         SPRSL  TYPE SPRAS,             "LANGUAGE
*       END OF TY_T591S.

TYPES: BEGIN OF TY_FINAL,
         SL               TYPE ZINT4,
         VNAMC            TYPE ZVORNAMC,
         NCHMC            TYPE ZNACHNMC,
         GENDER           TYPE ZVAL_TEXT,
         GBDAT            TYPE GBDAT,
         FATHER           TYPE ZCHAR30,
         STEXT            TYPE ZSBTTX,
         STEXT1           TYPE Z_SBTTX,
         USRID            TYPE ZSYSID,
         USRID_LONG       TYPE ZCOMM_ID_LONG,
         ICNUM1           TYPE PSG_IDNUM,
         ICNUM2           TYPE PSG_IDNUM,
         ICNUM3           TYPE PSG_IDNUM,
         ICNUM4           TYPE PSG_IDNUM,
         USRTY            TYPE USRTY,
         REFERRED_BY      TYPE Z_CHAR20,
         BEGDA            TYPE Z_BEGDA,
         PLANS            TYPE PLANS,
         PTEXT1           TYPE ZPKTXT,
         PTEXT            TYPE Z_PGTXT,
         BTEXT            TYPE ZBTRTX,
         NAME1            TYPE ZPBTXT,
         SCHKZ            TYPE ZSCHKN,
         BASICSALARY      TYPE ZWAERS,
         DA               TYPE ZWAERS1,
         HRA              TYPE ZWAERS2,
         SPECIALALLOWANCE TYPE ZWAERS3,
         GROSS            TYPE ZWAERS4,
         BANKL            TYPE BANKK,
         BANKN            TYPE BANKN,
         BNKSA            TYPE BNKSA,
       END OF TY_FINAL.

DATA:IT_PA0000 TYPE TABLE OF TY_PA0000,
     WA_PA0000 TYPE TY_PA0000,
     IT_PA0001 TYPE TABLE OF TY_PA0001,
     WA_PA0001 TYPE TY_PA0001,
     IT_PA0002 TYPE TABLE OF TY_PA0002,
     WA_PA0002 TYPE TY_PA0002,
     IT_PA0006 TYPE TABLE OF TY_PA0006,
     WA_PA0006 TYPE TY_PA0006,
     IT_PA0007 TYPE TABLE OF TY_PA0007,
     WA_PA0007 TYPE TY_PA0007,
     IT_PA0021 TYPE TABLE OF TY_PA0021,
     WA_PA0021 TYPE TY_PA0021,
     IT_PA0105 TYPE TABLE OF TY_PA0105,
     WA_PA0105 TYPE TY_PA0105,
     IT_PA0185 TYPE TABLE OF TY_PA0185,
     WA_PA0185 TYPE TY_PA0185,
     IT_PA0009 TYPE TABLE OF TY_PA0009,
     WA_PA0009 TYPE TY_PA0009,
     IT_T501T  TYPE TABLE OF TY_T501T,
     WA_T501T  TYPE TY_T501T,
     IT_T503T  TYPE TABLE OF TY_T503T,
     WA_T503T  TYPE TY_T503T,
*     IT_T591S  TYPE TABLE OF TY_T591S,
*     WA_T591S  TYPE TY_T591S,
     IT_T500P  TYPE TABLE OF TY_T500P,
     WA_T500P  TYPE TY_T500P,
     IT_T001P  TYPE TABLE OF TY_T001P,
     WA_T001P  TYPE TY_T001P,
     IT_T005T  TYPE TABLE OF TY_T005T,
     WA_T005T  TYPE TY_T005T,
     IT_FINAL  TYPE TABLE OF TY_FINAL,
     WA_FINAL  TYPE TY_FINAL,
     PAYROLL   TYPE PAY99_RESULT,
     IT_RT     TYPE TABLE OF PC207,
     WA_RT     TYPE PC207,
     IT_RGDIR  TYPE TABLE OF PC261,
     WA_RGDIR  TYPE PC261,
     SL        TYPE I VALUE '0',
     WA_TABA   TYPE DD07V,
     IT_TABA   TYPE STANDARD TABLE OF DD07V,
     IT_TABB   TYPE STANDARD TABLE OF DD07V,
     WA_FCAT   TYPE SLIS_FIELDCAT_ALV,
     IT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,
     WA_LAYOUT TYPE SLIS_LAYOUT_ALV.
