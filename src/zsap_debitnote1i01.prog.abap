*&---------------------------------------------------------------------*
*& Include          ZSAP_DEBITNOTEI01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.

  PERFORM BACK_FUN.
  PERFORM GETDATA.
  PERFORM CHECK_VALID.
  PERFORM TABLE_DATA.
  PERFORM EXCLUDE_ICONS.
  PERFORM DISPLAYDATA.

ENDMODULE.
