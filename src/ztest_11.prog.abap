*&---------------------------------------------------------------------*
*& Report ZTEST_11
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_11.

CALL METHOD zcl_data=>gt_data
  IMPORTING
    et_data = DATA(lo_data).
  BREAK mumair.
IF sy-subrc = 0.

  cl_demo_output=>display(
    EXPORTING
      data =   lo_data               " Text or Data
*    name =
  ).

ENDIF.
