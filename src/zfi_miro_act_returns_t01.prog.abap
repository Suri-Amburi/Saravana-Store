*&---------------------------------------------------------------------*
*& Include          ZFI_MIRO_T01
*&---------------------------------------------------------------------*

DATA :
  GS_HDR              TYPE ZINW_T_HDR,
  GV_SUBRC            TYPE SY-SUBRC,
  INVOICEDOCNUMBER    TYPE BAPI_INCINV_FLD-INV_DOC_NO,
  INVOICEDOCNUMBER_DN TYPE BAPI_INCINV_FLD-INV_DOC_NO,
  GV_RETURN_PO        TYPE EBELN,
  GT_TAX_CODE         TYPE TABLE OF A003,
  GT_KONP             TYPE TABLE OF KONP.

CONSTANTS :
  C_X(1)       VALUE 'X',
  C_01(2)      VALUE '01',
  C_02(2)      VALUE '02',
  C_03(2)      VALUE '03',
  C_04(2)      VALUE '04',
  C_05(2)      VALUE '05',
  C_06(2)      VALUE '06',
  C_07(2)      VALUE '07',
  C_1000(4)    VALUE '1000',
  C_MDOC(4)    VALUE 'MDOC',
  C_QR_CODE(7) VALUE 'QR_CODE',
  C_SE_CODE(3) VALUE 'SOE',
  C_QR06(6)    VALUE 'QR06',
  C_SE02(4)    VALUE 'SE02',
  C_SE04(4)    VALUE 'SE04'.
