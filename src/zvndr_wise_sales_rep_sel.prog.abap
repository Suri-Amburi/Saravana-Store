*&---------------------------------------------------------------------*
*& Include          ZVNDR_WISE_SALES_REP_SEL
*&---------------------------------------------------------------------*

*DATA : lv_class TYPE klasse_d.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_budat FOR mseg-budat_mkpf,
                s_class FOR klah-class NO INTERVALS NO-EXTENSION OBLIGATORY.
*PARAMETERS      p_class TYPE klah-class.
SELECTION-SCREEN END OF BLOCK b1.


*---->>> ( F4 help ) mumair <<< 26.09.2019 15:26:53
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_class-low.
  SELECT klah~class,
         klah~clint,
         kssk~objek,
         klah1~class AS matkl INTO TABLE @DATA(gt_data)
         FROM klah AS klah INNER JOIN kssk AS kssk ON kssk~clint = klah~clint
         INNER JOIN klah AS klah1 ON kssk~objek = klah1~clint
         WHERE klah~klart = '026' AND klah~wwskz = '0'  AND klah~class IN @s_class.
*  BREAK MUMAIR .
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'CLASS'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'S_CLASS-LOW'
      value_org   = 'S'
    TABLES
      value_tab   = gt_data.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
