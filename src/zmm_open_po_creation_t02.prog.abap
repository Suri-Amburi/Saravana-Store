*&---------------------------------------------------------------------*
*& Include          ZMM_OPEN_PO_CREATION_T02
*&---------------------------------------------------------------------*

TYPES :
  BEGIN OF TY_FILE,
    INDENT_NO(20),
    PDATE(10),
    VENDOR(10),
    SUP_SAL_NO(5),
    SUP_NAME(20),
    VENDOR_NAME(30),
    GROUP(18),
    TRANSPORTER(30),
    VENDOR_LOCATION(40),
    DELIVERY_AT(4),
    LEAD_TIME(3),
    PUR_GROUP(3),
    CATEGORY_CODE(9),
    MATNR(40),
    STYLE(15),
    FROM_SIZE(18),
    TO_SIZE(18),
    COLOR(15),
    QUANTITY(13),
    PRICE(11),
    REMARKS(15),
    STATUS(20),
  END OF TY_FILE,

  BEGIN OF TY_FINAL,
    INDENT     TYPE ZPH_HED-INDENT_NO,
    MSGTYP(1),
    MESSAGE(60),
  END OF TY_FINAL.

*** File Structure
DATA:
  GT_FILE TYPE STANDARD TABLE OF TY_FILE,
  FNAME   TYPE LOCALFILE,
  ENAME   TYPE CHAR4.

CONSTANTS :
  C_X(1) VALUE 'X',
  C_S(1) VALUE 'S',
  C_E(1) VALUE 'E'.
