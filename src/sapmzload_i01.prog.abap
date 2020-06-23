*&---------------------------------------------------------------------*
*& Include          SAPMZLOAD_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  CASE ok_code1.
    WHEN 'BACK' OR 'EXIT' OR 'CLOSE'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM save.
    WHEN ' '.
      PERFORM enter.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXDIV_VALI_LOAD_UNLOAD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exdiv_vali_load_unload INPUT.

  DATA : w_vekp  TYPE ty_vekp,
         li_vekp TYPE ty_t_vekp,
         w_temp  TYPE ty_temp,
         w_temp1 TYPE ty_temp,
         lv_t    TYPE i.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gv_exidv
    IMPORTING
      output = gv_exidv.

  SELECT SINGLE venum
                exidv
                vhilm
                vpobjkey
                zzmblnr
                zzdate
                zztime
           FROM vekp
           INTO w_vekp
           WHERE exidv = gv_exidv
           AND zzmblnr = ' '.

  IF sy-subrc = 0.

    READ TABLE gi_temp INTO w_temp1 WITH KEY exidv = gv_exidv.
    IF sy-subrc = 0.
      CLEAR gw_mess.
      gw_mess-err   = 'E'.
      gw_mess-mess1 = ' Tray / Bundle '.
      gw_mess-mess2 = ' Already '.
      gw_mess-mess3 = ' Scanned !!!! '.

      SET SCREEN 0.
      CALL SCREEN '9999'.
      EXIT.
    ELSE.
      gv_x = 'X'.
      w_temp-venum = w_vekp-venum.
      w_temp-exidv = w_vekp-exidv.
      APPEND w_temp TO gi_temp.
      CLEAR w_temp.
****************************ADDED BY SKN******************************************
      SELECT vekp~exidv vekp~venum vepo~vepos vepo~charg vepo~vemng FROM vekp AS vekp INNER JOIN vepo AS vepo
      ON vekp~venum = vepo~venum INTO TABLE it_vepo FOR ALL ENTRIES IN gi_temp  WHERE exidv = gi_temp-exidv.
      DESCRIBE TABLE it_vepo LINES gv_total.

      SELECT SUM( vemng ) FROM vepo INTO gv_totqty WHERE venum = w_vekp-venum.
**********************************************************************************
    ENDIF.

    IF gi_vekp IS INITIAL.
      SELECT venum
             exidv
             vhilm
             vpobjkey
             zzmblnr
             zzdate
             zztime
        FROM vekp
        INTO TABLE gi_vekp
        WHERE vpobjkey = w_vekp-vpobjkey
          AND status <> '0060'.
      gv_vbeln = w_vekp-vpobjkey.

  IF gv_vbeln IS NOT INITIAL.
    SELECT SINGLE tknum FROM vttp INTO gv_ebeln WHERE vbeln = gv_vbeln.
    SELECT SINGLE signi FROM vttk INTO gv_veh   WHERE tknum = gv_ebeln.
  ENDIF.

      DESCRIBE TABLE gi_vekp LINES gv_tot.
    ENDIF.

    DESCRIBE TABLE gi_temp LINES gv_scn.
    gv_pen  = gv_tot - gv_scn.
*    CLEAR: gv_exidv.
  ELSE.

    CLEAR gw_mess.
    gw_mess-err   = 'E'.
    gw_mess-mess1 = 'Nothing To'.
    gw_mess-mess2 = '  Unload  '.
    CLEAR gv_exidv.
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
MODULE user_command_9999 INPUT.

  CASE ok_code2.
    WHEN 'BACK' OR 'CLOSE' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE TO SCREEN '9001'.
    WHEN 'OK'.
      IF gw_mess-err = 'E'.
        SET SCREEN 0.
        CALL SCREEN '9001'.
        EXIT.
      ELSE.
        PERFORM global_variables.
        SET SCREEN 0.
        CALL SCREEN '9001'.
        EXIT.
      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  BATCH_VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE batch_validate INPUT.
CLEAR wa_final.
*READ TABLE it_final INTO wa_final WITH KEY charg = gv_charg.
* IF sy-subrc <> 0.

IF it_vepo IS NOT INITIAL.
  IF gv_charg IS NOT INITIAL.
    READ TABLE it_vepo INTO DATA(wa_vepo) WITH KEY charg = gv_charg.
     IF sy-subrc = 0.
       MOVE wa_vepo TO wa_final.
       wa_final-menge = wa_final-menge + 1.
       APPEND wa_final TO it_final.
*       CLEAR gv_charg.
     ELSEIF sy-subrc <> 0.
       SELECT SINGLE s4_batch FROM zb1_s4_map INTO @DATA(lv_batch) WHERE b1_batch = @gv_charg.
       READ TABLE it_vepo INTO  wa_vepo WITH KEY charg = lv_batch.
        IF sy-subrc = 0.
         MOVE wa_vepo TO wa_final.
         wa_final-menge = wa_final-menge + 1.
         APPEND wa_final TO it_final.
*         CLEAR gv_charg.
         ELSE.
          CLEAR gw_mess.
          CLEAR gv_charg.
          gw_mess-err   = 'E'.
          gw_mess-mess1 = 'Batch is'.
          gw_mess-mess2 = 'not valid'.
          SET SCREEN 0.
          CALL SCREEN '9999'.
          EXIT.
        ENDIF.
     ENDIF.
  ENDIF.
ENDIF.


*     ELSE.
*      CLEAR gw_mess.
*      gw_mess-err   = 'E'.
*      gw_mess-mess1 = 'Batch already'.
*      gw_mess-mess2 = 'scanned'.
*      SET SCREEN 0.
*      CALL SCREEN '9999'.
*      EXIT.
*ENDIF.

**************for checking batch quantity*******************
 CLEAR: it_fin3, wa_fin3.
 DATA(it_final1) = it_final.
 SORT it_final1 BY charg.
 DELETE ADJACENT DUPLICATES FROM it_final1 COMPARING charg.
   LOOP AT it_final1 INTO DATA(wa_final1).
     LOOP AT it_final INTO DATA(wa_fin) WHERE charg = wa_final1-charg.
        wa_fin3-exidv = wa_fin-exidv.
        wa_fin3-charg = wa_fin-charg.
        wa_fin3-vemng = wa_fin-vemng.
        wa_fin3-venum = wa_fin-venum.
        wa_fin3-vepos = wa_fin-vepos.
        wa_fin3-menge =  wa_fin3-menge + wa_fin-menge.
     ENDLOOP.
       APPEND wa_fin3 TO it_fin3.
       CLEAR wa_fin3.
   ENDLOOP.

    CLEAR: it_final1, wa_final1, wa_fin, wa_final.

 READ TABLE it_fin3 ASSIGNING FIELD-SYMBOL(<wa>) WITH KEY charg = gv_charg.

    IF <wa>-menge > <wa>-vemng.
      <wa>-menge = <wa>-menge - 1.
   DESCRIBE TABLE it_final LINES DATA(tot).
    DELETE it_final INDEX tot.
    CLEAR tot.

     CLEAR gv_charg.
          CLEAR gw_mess.
          gw_mess-err   = 'E'.
          gw_mess-mess1 = 'Batch quantity'.
          gw_mess-mess2 = 'exceeded'.
          SET SCREEN 0.
          CALL SCREEN '9999'.
          EXIT.
    ELSE.
     CLEAR gv_charg.
    ENDIF.

****************************************************************************
DESCRIBE TABLE it_fin3 LINES gv_rem.
DESCRIBE TABLE it_final LINES gv_totno.


IF gv_rem > gv_total.
      CLEAR gw_mess.
      gw_mess-err   = 'E'.
      gw_mess-mess1 = 'Batch not belongs '.
      gw_mess-mess2 = 'to HU'.
      SET SCREEN 0.
      CALL SCREEN '9999'.

ENDIF.


ENDMODULE.
