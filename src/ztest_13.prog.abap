*&---------------------------------------------------------------------*
*& Report ZTEST_13
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_13.

TYPES : BEGIN OF TY_FINAL,
          MATNR    TYPE MATNR,
          CHARG    TYPE CHARG_D,
          WERKS    TYPE WERKS_D,
          CLABS    TYPE LABST,
          B1_BATCH TYPE CHAR40,
          QTY      TYPE ZQUAN,
        END OF TY_FINAL.

DATA : IT_FINAL TYPE STANDARD TABLE OF TY_FINAL.
*       WA_FINA1 TYPE TY_FINAL.

SELECT MATNR,
       WERKS,
       CHARG,
       CLABS
       FROM MCHB INTO TABLE @DATA(LT_MCHB) WHERE CLABS > 0.

SELECT MATNR,
       PLANT,
       QUANTITY,
       B1_BATCH,
       BATCH
       FROM ZB1_STOCK INTO TABLE @DATA(LT_ZB1) WHERE MOVE_TYPE  = '561'.

SORT  LT_ZB1 BY MATNR PLANT BATCH.
SORT  LT_MCHB BY MATNR WERKS CHARG.

LOOP AT  LT_ZB1 INTO DATA(LS_ZB1).
  READ TABLE LT_MCHB INTO DATA(LS_MCHB) WITH KEY MATNR  = LS_ZB1-MATNR WERKS  = LS_ZB1-PLANT CHARG  = LS_ZB1-BATCH.
  IF SY-SUBRC <> 0.
    APPEND VALUE #( MATNR = LS_ZB1-MATNR
                    WERKS = LS_ZB1-PLANT
                    CHARG = LS_ZB1-BATCH
                    CLABS  = LS_MCHB-CLABS
                    B1_BATCH  = LS_ZB1-B1_BATCH
                    QTY    = LS_ZB1-QUANTITY  ) TO IT_FINAL.

  ENDIF.
ENDLOOP.
BREAK mumair.
CL_DEMO_OUTPUT=>DISPLAY(
  EXPORTING
    DATA =    IT_FINAL              " Text or Data
*    name =
).



**
**SORT lt_mchb[] by matnr charg.
**DELETE ADJACENT DUPLICATES FROM lt_mchb[] COMPARING matnr charg.

*BREAK mumair.
*  LOOP AT lt_mchb INTO DATA(ls_mchb).
*
*  wa_fina1-matnr  = ls_mchb-matnr.
*  wa_fina1-clabs  = ls_mchb-clabs.
*  wa_fina1-charg  = ls_mchb-charg.
*
*  READ TABLE lt_zb1 INTO DATA(ls_zb1) WITH KEY batch = ls_mchb-charg matnr  = ls_mchb-matnr plant = ls_mchb-werks.
*  IF sy-subrc <> 0.
*
*    wa_fina1-qty  = ls_zb1-quantity.
*
*  ENDIF.
*
*  APPEND wa_fina1 TO it_final.
*  clear wa_fina1.
*exclude
*  ENDLOOP.
