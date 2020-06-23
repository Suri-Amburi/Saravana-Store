*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_GOODS_RETURN_PO_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.


  PERFORM GET_DATA .
  OK_CODE = SY-UCOMM .

  CASE OK_CODE.

    WHEN 'BACK'.
      LEAVE TO SCREEN 0 .
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0 .
    WHEN 'SAVE' .
      PERFORM CREATE_RPO .
    WHEN 'REF' .
      CALL TRANSACTION 'ZRETPO'.
  ENDCASE.
  CLEAR : OK_CODE , SY-UCOMM .
ENDMODULE.
