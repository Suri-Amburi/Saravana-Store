*&---------------------------------------------------------------------*
*& Include          ZVM_DELETE_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF T_DATATAB,
          KSCHL(04) ,
          LIFNR(10),
          MATNR(40) ,
        END OF T_DATATAB ,

        BEGIN OF GTY_DISPLAY,
          KSCHL(04) ,
          MATNR(40) ,
          MSGTYP(1),
          MESSAGE1  TYPE CAMSG,
          MESSAGE2  TYPE CAMSG,
        END OF GTY_DISPLAY,
        GTY_T_DISPLAY TYPE STANDARD TABLE OF GTY_DISPLAY.

DATA : IT_DATATAB  TYPE STANDARD TABLE OF T_DATATAB,
       IT_DATATAB1 TYPE STANDARD TABLE OF T_DATATAB,
       WA_DATATAB  TYPE T_DATATAB,
       WA_DATATAB1 TYPE T_DATATAB,
       GV_BDC_MODE TYPE CHAR1,
       CUPDATE     TYPE CHAR1,
       BDCDATA     LIKE BDCDATA    OCCURS 0 WITH HEADER LINE,
       MESSTAB     LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
       IT_RAW      TYPE TRUXS_T_TEXT_DATA,
       IT_LOG      TYPE GTY_T_DISPLAY,
       WA_LOG      TYPE GTY_DISPLAY,
       IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
       WA_LAYOUT   TYPE SLIS_LAYOUT_ALV,
       ENAME       TYPE CHAR4,
       LV_TAB(5)   TYPE C.
DATA: L_REPID TYPE SYREPID .
GV_BDC_MODE = 'N'.
