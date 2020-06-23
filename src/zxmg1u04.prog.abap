*&---------------------------------------------------------------------*
*& Include          ZXMG1U04
*& TC      : Suri Amburi
*& FC      : Chetan P
*& Perpous : Custom numbering for varients
*& Date    : 10.01.2019
*&---------------------------------------------------------------------*

CHECK CONFIG_MATNR IS NOT INITIAL AND VARIANT_MATNR IS INITIAL.
  DATA(LV_MATNR) = CONFIG_MATNR.
  DATA : LV_COUNT TYPE SY-TABIX VALUE 1.
  SHIFT LV_MATNR LEFT DELETING LEADING '0'.
  CLEAR : SY-TABIX.
  LOOP AT VARIANTVALUATION ASSIGNING FIELD-SYMBOL(<LS_VARIANTVALUATION>) WHERE CUOBJ = VARIANTVALUATIONHEAD-CUOBJ.
    IF LV_COUNT = 1.
      VARIANT_MATNR = |{ LV_MATNR }-{ <LS_VARIANTVALUATION>-ATWRT }|.
    ELSE.
      CHECK <LS_VARIANTVALUATION>-ATWRT is NOT INITIAL and <LS_VARIANTVALUATION>-ATWRT <> '*' .
      VARIANT_MATNR = |{ VARIANT_MATNR }-{ <LS_VARIANTVALUATION>-ATWRT }|.
    ENDIF.
    LV_COUNT = LV_COUNT + 1.
  ENDLOOP.
