*&---------------------------------------------------------------------*
*& Include          ZSAPMP_FI_CFO_DIARY_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.



  OK_CODE = SY-UCOMM.
  CASE OK_CODE.

    WHEN 'DISP'.
*      BREAK-POINT.
*     if  date = lv_date7.
      IF GRID IS BOUND.
        CALL METHOD GRID->REGISTER_EDIT_EVENT
          EXPORTING
            I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.  " Event ID
*     EXCEPTIONS
*       ERROR      = 1
*       OTHERS     = 2
        .
        IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      lv_temp = lv_date7 .
      PERFORM DATE1_DATA.
*      PERFORM FINAL_DATA.
*      ELSEIF lv_date7 = WA_HEADER-date6.
*      CLEAR:IT_FINAL1.
*      PERFORM FINAL_DATA.
*ENDIF.

*IF date = lv_date7.
    WHEN 'BT1'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      LV_TEMP = WA_HEADER-DATE1 .
      PERFORM DATE1_DATA.

    WHEN 'BT2'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
*      PERFORM DATE2_DATA.
      LV_TEMP = WA_HEADER-DATE2 .
      PERFORM DATE1_DATA.

    WHEN 'BT3'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      LV_TEMP = WA_HEADER-DATE3 .
      PERFORM DATE1_DATA.
*      PERFORM DATE3_DATA.

    WHEN 'BT4'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      LV_TEMP = WA_HEADER-DATE4 .
      PERFORM DATE1_DATA.
*      PERFORM DATE4_DATA.

    WHEN 'BT5'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      LV_TEMP = WA_HEADER-DATE5 .
      PERFORM DATE1_DATA.
*      PERFORM DATE5_DATA.

    WHEN 'BT6'.
      REFRESH:IT_FINAL1.
      CLEAR:IT_FINAL1.
      LV_TEMP = WA_HEADER-DATE6 .
      PERFORM DATE1_DATA.
*      PERFORM DATE6_DATA.


*ENDIF.

    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
  PERFORM DISPLAY.
  CLEAR OK_CODE.
*   refresh it_final1.

ENDMODULE.
