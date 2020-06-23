*&---------------------------------------------------------------------*
*& Include          ZSAPMP_FI_CFO_DIARY_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.


*   refresh it_final1.
  OK_CODE = SY-UCOMM.
  CASE OK_CODE.

    WHEN 'DISP'.
*      BREAK-POINT.
*     if  date = lv_date7.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      PERFORM FINAL_DATA.
*      ELSEIF lv_date7 = WA_HEADER-date6.
*      CLEAR:IT_FINAL1.
*      PERFORM FINAL_DATA.
*ENDIF.

*IF date = lv_date7.
   WHEN 'BT1'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      perform date1_data.

    WHEN 'BT2'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      perform date2_data.

    WHEN 'BT3'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      perform date3_data.

    WHEN 'BT4'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      perform date4_data.

    WHEN 'BT5'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      perform date5_data.

    WHEN 'BT6'.
       REFRESH:IT_FINAL1.
       CLEAR:IT_FINAL1.
       perform date6_data.


*ENDIF.

    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.


CLEAR ok_code.
*   refresh it_final1.

ENDMODULE.
