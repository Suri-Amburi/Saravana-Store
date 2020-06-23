*&---------------------------------------------------------------------*
*& Report ZREAD_TEXT
*&---------------------------------------------------------------------*
*& TC      : Suri
*& Purpose : Alternative Method to avoid Achive read text insted of READ_TEXT function module
*&---------------------------------------------------------------------*
REPORT ZREAD_TEXT.

TYPES: BEGIN OF TY_STXL,
         TDNAME TYPE STXL-TDNAME,
         CLUSTR TYPE STXL-CLUSTR,
         CLUSTD TYPE STXL-CLUSTD,
         TDID   TYPE STXL-TDID,
       END OF TY_STXL.
* compressed text data without text name
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
  R_OBJ TYPE RANGE OF TDOBNAME.

FIELD-SYMBOLS:
  <LS_LINE> TYPE TLINE,
  <LS_STXL> TYPE TY_STXL.

TYPES : BEGIN OF TY_EKPO,
          EBELN TYPE EKPO-EBELN,
          EBELP TYPE EKPO-EBELP,
          OBJ   TYPE TDOBNAME,
        END OF TY_EKPO.
DATA: LT_EKPO1 TYPE STANDARD TABLE OF TY_EKPO.
DATA :LT_EKPO TYPE TABLE OF EKPO.

SELECT EBELN,
       EBELP
       FROM EKPO INTO TABLE @LT_EKPO1 UP TO 10 ROWS WHERE CREATIONDATE = '20190918'.

LOOP AT LT_EKPO1 ASSIGNING FIELD-SYMBOL(<LS_EKPO>).
  APPEND VALUE #( LOW = <LS_EKPO>-EBELN && <LS_EKPO>-EBELP OPTION = 'EQ' SIGN = 'I' ) TO R_OBJ.
ENDLOOP.

SELECT TDNAME TDOBJECT TDID
   FROM STXH
   INTO CORRESPONDING FIELDS OF TABLE LT_STXH
   WHERE TDOBJECT = 'EKPO' AND TDNAME IN R_OBJ.

*AND THEN
*** select compressed text lines in blocks of 3000 (adjustable)
SELECT TDNAME
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
BREAK samburi.
LOOP AT LT_STXL ASSIGNING <LS_STXL>.
*** Decompress texts
  CLEAR: LT_STXL_RAW[], LT_TLINE[].
  Ls_STXL_RAW-CLUSTR = <LS_STXL>-CLUSTR.
  ls_STXL_RAW-CLUSTD = <LS_STXL>-CLUSTD.
  ls_STXL_RAW-TDID   = <LS_STXL>-TDID .
  APPEND ls_STXL_RAW TO LT_STXL_RAW.
  IMPORT TLINE = LT_TLINE FROM INTERNAL TABLE LT_STXL_RAW.
ENDLOOP.
FREE LT_STXL.
