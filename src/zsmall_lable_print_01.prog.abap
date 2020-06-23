*&---------------------------------------------------------------------*
*& Report ZSMALL_LABLE_PRINT_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsmall_lable_print_01.

PARAMETERS :
  p_charg  TYPE charg_d,
  p_no_prt TYPE int4.

*** For Inistant Print Option
SUBMIT zsmall_lable_print WITH p_charg = p_charg WITH p_no_prt = p_no_prt AND RETURN.
