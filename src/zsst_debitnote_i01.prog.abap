*&---------------------------------------------------------------------*
*& Include          ZSST_DEBITNOTE_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.

  PERFORM GETDATA.
  PERFORM CHECK_VALID.
  PERFORM BACK_FUN.
  PERFORM TABLE_DATA.
  PERFORM GOODS_MOVEMENT.

ENDMODULE.