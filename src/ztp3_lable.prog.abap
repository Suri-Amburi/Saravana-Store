*&---------------------------------------------------------------------*
*& Report ZTEST_LABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztp3_lable.
PARAMETERS :
  p_mblnr  TYPE  mblnr,
  p_tp3    TYPE  char1,
  p_mjahr  TYPE  mjahr,
  p_charg  TYPE  charg_d,
  p_prints TYPE zno_prints.

PERFORM tp3_print_stcker USING p_mblnr p_tp3 p_mjahr.
*&---------------------------------------------------------------------*
*& Form PRINT_STCKER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_MBLNR
*&      --> P_TP3
*&      --> P_MJAHR
*&---------------------------------------------------------------------*
FORM tp3_print_stcker USING p_mblnr p_tp3 p_mjahr.
  CALL FUNCTION 'ZLABLE_PRINT'
    EXPORTING
      i_mblnr       = p_mblnr        " Material Document Number
      i_tp3_sticker = p_tp3          " X for Print
      i_mjahr       = p_mjahr       " Material Document Year
      i_charg       = p_charg              " Batch Number
      i_prints      = p_prints.              " Number of Prints
ENDFORM.
