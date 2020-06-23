*&---------------------------------------------------------------------*
*& Include          ZMM_GET_FVPRICE_REP_TOP
*&---------------------------------------------------------------------*
"Export File Type
TYPES : BEGIN OF ty_file,
          plu_code TYPE int4, "PLU_CODE
          bc01     TYPE matnr, "Barcode
          maktx    TYPE maktx, "Description
          price    TYPE netpr, "Price
          status   TYPE char1, "Status Indicator
        END OF ty_file.
TYPES : st_a515     TYPE STANDARD TABLE OF a515,
        stfv_prlist TYPE STANDARD TABLE OF ty_file.

DATA : "xa515      TYPE TABLE OF a515 WITH HEADER LINE,
       xfv_prlist TYPE TABLE OF ty_file WITH HEADER LINE.
