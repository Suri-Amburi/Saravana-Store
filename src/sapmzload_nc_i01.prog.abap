*&---------------------------------------------------------------------*
*& Include          SAPMZLOAD_NC_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.

  CASE OK_CODE1.
    WHEN 'BACK' OR 'EXIT' OR 'CLOSE'.
      LEAVE PROGRAM.
    WHEN 'SAVE'.
      PERFORM SAVE.
    WHEN ' '.
      PERFORM ENTER.

*  	WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXDIV_VALI_LOAD_UNLOAD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXDIV_VALI_LOAD_UNLOAD INPUT.

  DATA : W_VEKP  TYPE TY_VEKP,
         LI_VEKP TYPE TY_T_VEKP,
         W_TEMP  TYPE TY_TEMP,
         W_TEMP1 TYPE TY_TEMP,
         LV_T    TYPE I.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GV_EXIDV
    IMPORTING
      OUTPUT = GV_EXIDV.

  SELECT SINGLE VENUM
                EXIDV
                VHILM
                VPOBJKEY
                ZZMBLNR
                ZZDATE
                ZZTIME
           FROM VEKP
           INTO W_VEKP
           WHERE EXIDV = GV_EXIDV
           AND ZZMBLNR = ' '.

  IF SY-SUBRC = 0.

    READ TABLE GI_TEMP INTO W_TEMP1 WITH KEY EXIDV = GV_EXIDV.
    IF SY-SUBRC = 0.
      CLEAR GW_MESS.
      GW_MESS-ERR   = 'E'.
      GW_MESS-MESS1 = ' Tray / Bundle '.
      GW_MESS-MESS2 = ' Already '.
      GW_MESS-MESS3 = ' Scanned !!!! '.

      SET SCREEN 0.
      CALL SCREEN '9999'.
      EXIT.
    ELSE.
      W_TEMP-VENUM = W_VEKP-VENUM.
      W_TEMP-EXIDV = W_VEKP-EXIDV.
      APPEND W_TEMP TO GI_TEMP.
      CLEAR W_TEMP.
    ENDIF.

    IF GI_VEKP IS INITIAL.
      SELECT VENUM
             EXIDV
             VHILM
             VPOBJKEY
             ZZMBLNR
             ZZDATE
             ZZTIME
        FROM VEKP
        INTO TABLE GI_VEKP
        WHERE VPOBJKEY = W_VEKP-VPOBJKEY
          AND STATUS <> '0060'.
      GV_VBELN = W_VEKP-VPOBJKEY.

      DESCRIBE TABLE GI_VEKP LINES GV_TOT.
    ENDIF.

    DESCRIBE TABLE GI_TEMP LINES GV_SCN.
    GV_PEN  = GV_TOT - GV_SCN.
    CLEAR: GV_EXIDV.
  ELSE.

    CLEAR GW_MESS.
    GW_MESS-ERR   = 'E'.
    GW_MESS-MESS1 = 'Nothing To'.
    GW_MESS-MESS2 = '  Unload  '.

    SET SCREEN 0.
    CALL SCREEN '9999'.
    EXIT.

  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9999  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9999 INPUT.

  CASE OK_CODE2.
    WHEN 'BACK' OR 'CLOSE' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE TO SCREEN '9001'.
    WHEN 'OK'.
      IF GW_MESS-ERR = 'E'.
        SET SCREEN 0.
        CALL SCREEN '9001'.
        EXIT.
      ELSE.
        PERFORM GLOBAL_VARIABLES.
        SET SCREEN 0.
        CALL SCREEN '9001'.
        EXIT.
      ENDIF.

  ENDCASE.

ENDMODULE.
