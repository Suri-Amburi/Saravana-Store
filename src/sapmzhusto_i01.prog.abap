*&---------------------------------------------------------------------*
*& Include          SAPMZHUSTO_I01
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
    WHEN 'SAVE'.
      PERFORM save.
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
IF wa_hdr-werks IS  INITIAL.
            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = ' MAINTAIN '.
            gw_mess-mess2 = ' PALNT IN '.
            gw_mess-mess3 = ' USERID !!!! '.
            CLEAR wa_hdr-exidv.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.
ENDIF.

IF wa_hdr-exidv IS NOT INITIAL.
   wa_hdr-exidv =  |{ wa_hdr-exidv ALPHA = IN }| .
    SELECT SINGLE venum FROM vekp INTO @DATA(lv_venum) WHERE exidv = @wa_hdr-exidv.
  IF lv_venum IS NOT INITIAL.
    READ TABLE it_final INTO DATA(wa_final) WITH KEY venum = lv_venum.
     IF sy-subrc = 0.
            CLEAR gw_mess.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = ' HU '.
            gw_mess-mess2 = ' ALREADY '.
            gw_mess-mess3 = ' SCANNED!!!! '.
            CLEAR wa_hdr-exidv.
            SET SCREEN 0.
            CALL SCREEN '9999'.
            EXIT.
     ELSE.
       SELECT venum vemng matnr charg werks lgort FROM vepo INTO TABLE it_fin WHERE venum = lv_venum.
       SELECT venum,exidv FROM vekp INTO TABLE @DATA(it_vekp) FOR ALL ENTRIES IN @it_fin WHERE venum = @it_fin-venum.
        LOOP AT it_fin ASSIGNING FIELD-SYMBOL(<fin>).
          READ TABLE it_vekp ASSIGNING FIELD-SYMBOL(<vekp>) WITH KEY venum = <fin>-venum.
           IF sy-subrc = 0.
            <fin>-exidv = <vekp>-exidv.
          ENDIF.
        ENDLOOP.
     ENDIF.
  ENDIF.
ENDIF.

APPEND LINES OF it_fin TO it_final.
CLEAR: it_fin,lv_venum,wa_hdr-exidv.

DATA(it_count) = it_final.
SORT it_count BY venum.
DELETE ADJACENT DUPLICATES FROM it_count COMPARING venum.
DESCRIBE TABLE it_count LINES wa_hdr-count.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9999  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9999 INPUT.
 ok_code2 = sy-ucomm.
  CASE ok_code2.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE TO SCREEN '1000'.
    WHEN 'OK'.
      IF gw_mess-err = 'E'.
        SET SCREEN 0.
        CALL SCREEN '1000'.
        EXIT.
      ELSE.
        PERFORM global_variables.
        SET SCREEN 0.
        CALL SCREEN '1000'.
        EXIT.
      ENDIF.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GLOBAL_VARIABLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM global_variables .

REFRESH: it_final, it_final1, it_fin.
CLEAR:wa_hdr , gw_mess.
CLEAR:  header, header_no_pp,headerx,item,item, it_return,it_return1,lw_return,it_pocond,wa_pocond ,
it_pocondx ,wa_pocondx  ,lv_ebeln,ls_sto_items ,lt_sto_items ,xsto_hdr_vbeln, wa_vbkok , lt_vbpok ,
wa_vbpok , lt_prott , lt_verko , wa_verko , lt_verpo , wa_verpo ,lt_lips_m,ls_error , lt_hu, wa_hu ,
created_hu,lt_lips ,wa_lips ,  lt_prot .
ENDFORM.
