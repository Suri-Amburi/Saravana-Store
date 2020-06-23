*&---------------------------------------------------------------------*
*& Report ZTEST_14
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_14.


NEW zcl_data3( )->gt_data3(
  IMPORTING
    et_data = DATA(lo_data3)
).
BREAK MUMAIR.
IF sy-subrc = 0.

  cl_demo_output=>display(
    EXPORTING
      data =    lo_data3              " Text or Data
*      name =
  ).

ENDIF.
