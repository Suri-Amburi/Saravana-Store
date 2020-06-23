*&---------------------------------------------------------------------*
*& Include          SAPMZRETPO_EAN_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
CASE ok_code1.
   WHEN 'BACK'.
     LEAVE PROGRAM.
   WHEN 'CANCEL'.
     LEAVE PROGRAM.
   WHEN 'EXIT'.
     LEAVE PROGRAM.
   WHEN 'CREATE'.
     PERFORM create_po.
   WHEN OTHERS.
 ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_chain INPUT.
 DATA: lv_mwsk1 TYPE konp-mwsk1.
IF lv_ean IS NOT INITIAL.

  SELECT SINGLE matnr,ean11,matkl FROM mara INTO @DATA(wa_mara) WHERE ean11 = @lv_ean.
  SELECT SINGLE klah~class,klah~clint,kssk~objek,klah1~class AS matkl INTO @DATA(wa_data)
  FROM klah AS klah INNER JOIN kssk AS kssk ON ( kssk~clint EQ klah~clint ) INNER JOIN klah AS klah1
  ON ( kssk~objek EQ klah1~clint )  WHERE klah~klart = '026' AND klah~wwskz = '0' AND  klah1~class EQ @wa_mara-matkl.
   IF wa_mara IS NOT INITIAL.
      SELECT SINGLE t024~ekgrp,t024~eknam FROM t024 INTO  @DATA(wa_t024) WHERE t024~eknam EQ @wa_data-class.
   ENDIF.
   IF it_final IS NOT INITIAL.
       READ TABLE it_final  WITH KEY ekgrp =  wa_t024-ekgrp TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
           CLEAR: gw_mess,wa_mara,wa_t024, wa_data.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'PURCHASE GROUP IS' .
            gw_mess-mess2 = 'DIFFERENT FROM'.
            gw_mess-mess3 = 'EXISTING BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.
        ENDIF.
   ENDIF.
      SELECT SINGLE knumh FROM a502 INTO @DATA(lv_knumhpurch) WHERE lifnr = @lv_lifnr AND kschl = 'PB00'
                                                         AND   matnr = @wa_mara-matnr AND datbi GE @sy-datum.
      SELECT SINGLE kbetr FROM konp INTO @DATA(lv_kbetrpurch)  WHERE knumh = @lv_knumhpurch.

      SELECT SINGLE regio FROM lfa1 INTO  @DATA(ls_lregio2)
                         WHERE lifnr = @lv_lifnr.
      SELECT SINGLE regio FROM t001w INTO @DATA(ls_wregio2) WHERE werks = @lv_werks.
      CLEAR lv_mwsk1.
      SELECT SINGLE konp~mwsk1 INTO lv_mwsk1
          FROM konp AS konp INNER JOIN a792 AS a792 ON a792~knumh = konp~knumh
                            INNER JOIN marc AS marc ON marc~steuc = a792~steuc
                            WHERE marc~matnr = wa_mara-matnr
                            AND   a792~datab LE sy-datum
                            AND   a792~datbi GE sy-datum
                            AND   a792~regio = ls_lregio2
                            AND   a792~wkreg = ls_wregio2
                            AND   konp~loevm_ko = ' '
                            AND   marc~werks = lv_werks.
*      IF lv_mwsk1 IS NOT INITIAL.
*        SELECT SUM( kbetr ) AS e_taxp INTO @DATA(lv_tax_per) FROM konp AS konp INNER JOIN a003 AS a003 ON a003~knumh = konp~knumh
*            WHERE  a003~mwskz = @lv_mwsk1.
*        IF  lv_tax_per IS NOT INITIAL.
*          lv_tax_per  =  lv_tax_per / 10.
*        ENDIF.
*      ENDIF.

        IF LV_MWSK1 IS NOT INITIAL.
            CLEAR: gw_mess,wa_mara,wa_data,wa_t024,ls_wregio2,ls_lregio2,lv_kbetrpurch,lv_knumhpurch.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'TAX CODE' .
            gw_mess-mess2 = 'NOT MAINTAINED'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.
        ENDIF.
     SELECT SINGLE name1 FROM lfa1 INTO lv_name1 WHERE lifnr = lv_lifnr.
     SELECT SINGLE maktx FROM makt INTO lv_maktx WHERE matnr = wa_mara-matnr AND spras = sy-langu.
     lv_ekgrp = wa_t024-ekgrp.

      wa_final-charg     = lv_ean.
      wa_final-matnr     = wa_mara-matnr.
      wa_final-menge     = '1'.
      wa_final-verpr     = lv_kbetrpurch.
      wa_final-mwsk1     = lv_mwsk1.
      wa_final-ekgrp     = wa_t024-ekgrp.
      wa_final-werks     = lv_werks.
      wa_final-lifnr     = lv_lifnr.

     APPEND wa_final TO it_final.
        lv_lean  = lv_ean.
        CLEAR: wa_final,lv_ean, wa_mara,lv_kbetrpurch,wa_t024,lv_knumhpurch, wa_data.
    DESCRIBE TABLE it_final LINES lv_count.
ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE ok_code2.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE TO SCREEN '1000'.
    WHEN 'OK'.
      IF gw_mess-err = 'E'.
        CLEAR lv_ean.
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
