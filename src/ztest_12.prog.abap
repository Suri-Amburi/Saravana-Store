*&---------------------------------------------------------------------*
*& Report ZTEST_12
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_12.

CALL METHOD zcl_data2=>gt_data2
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
