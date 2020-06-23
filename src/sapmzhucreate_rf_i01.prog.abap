*&---------------------------------------------------------------------*
*& Include          SAPMZHUCREATE_RF_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  ok_code1 = sy-ucomm.
  CASE ok_code1.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'CLOSE'.
      CHECK it_final IS NOT INITIAL.
      PERFORM close.
    WHEN ' '.
      PERFORM enter.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_chain INPUT.

IF lv_werks IS  INITIAL.
            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = ' MAINTAIN '.
            gw_mess-mess2 = ' PALNT IN '.
            gw_mess-mess3 = ' USERID !!!! '.
            CLEAR lv_charg.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.
ENDIF.

IF lv_charg IS NOT INITIAL.
  DATA(LEN) = STRLEN( LV_CHARG ).
 IF LEN = '10'.
  SELECT SINGLE matnr FROM mchb INTO lv_matnr WHERE charg = lv_charg.
*    IF lv_matnr IS NOT INITIAL.
       wa_final-matnr  = lv_matnr.
       wa_final-charg  = lv_charg.
       wa_final-menge  = 1.
       APPEND wa_final TO it_final.
       CLEAR: lv_charg, lv_matnr.
    ELSEIF LEN NE '10'.                      " lv_matnr IS INITIAL.
     SELECT SINGLE s4_batch FROM zb1_s4_map INTO lv_sbatch WHERE b1_batch = lv_charg.
     SELECT SINGLE matnr    FROM mchb       INTO lv_matnr WHERE charg = lv_sbatch.
       IF lv_sbatch IS NOT INITIAL.
         wa_final-matnr  = lv_matnr.
         wa_final-charg  = lv_charg.
         wa_final-menge  = 1.
         APPEND wa_final TO it_final.
         CLEAR: lv_charg, lv_sbatch, lv_matnr .
       ELSE.
        SELECT SINGLE matnr FROM mara INTO lv_matnr WHERE ean11 = lv_charg.
         IF lv_matnr IS NOT INITIAL.
           wa_final-matnr  = lv_matnr.
*           wa_final-charg  = lv_charg.
           wa_final-menge  = 1.
           APPEND wa_final TO it_final.
           CLEAR: lv_charg, lv_matnr.
         ELSE.
            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = ' BATCH '.
            gw_mess-mess2 = ' NOT '.
            gw_mess-mess3 = ' EXIST !!!! '.
            CLEAR lv_charg.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.
         ENDIF.
      ENDIF.
  ENDIF.
  CLEAR LEN.
  DESCRIBE TABLE it_final LINES lv_count .

ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9999  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9999 INPUT.
ok_code2 = sy-ucomm.
  CASE ok_code2.
    WHEN 'BACK' OR 'CLOSE' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE TO SCREEN '1000'.
    WHEN 'OK'.
      IF gw_mess-err = 'E'.
        SET SCREEN 0.
        CALL SCREEN '1000'.
        EXIT.
      ELSE.

       PERFORM global_variables.
      DATA(lv_hu) = lv_exidv.
      SUBMIT zmm_tray_sticker1 AND RETURN WITH p_hu = lv_hu.

        SET SCREEN 0.
        CALL SCREEN '1000'.
        EXIT.
      ENDIF.

  ENDCASE.

ENDMODULE.
