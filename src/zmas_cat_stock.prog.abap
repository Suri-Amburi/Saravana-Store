*&---------------------------------------------------------------------*
*& Report ZMAS_CAT_STOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmas_cat_stock.
TABLES: mseg, vbrp.

INCLUDE: zmas_cat_stock_top,        "*---->>> ( Global Declaration ) mumair <<< 17.09.2019 12:48:51
         zmas_cat_stock_sel,        "Selection Screen
         zmas_cat_stock_sub,        "Sub Routine
         zmas_cat_stock_form.       "Form Sub-routine data
