*&---------------------------------------------------------------------*
*& Include          SAPMZRETPO_RF_2_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
 CASE sy-ucomm.
   WHEN 'BACK'.
     LEAVE PROGRAM.
   WHEN 'CANCEL'.
     LEAVE PROGRAM.
   WHEN 'EXIT'.
     LEAVE PROGRAM.
   WHEN 'REFRESH'.
     CLEAR: it_final , lv_ebeln , lv_werks, it_final, lv_debit_note, gv_mblnr_n.
     CALL METHOD grid->refresh_table_display.
   WHEN 'UPDATE'.
     REFRESH it_log.
     PERFORM update_po.
   WHEN 'POST'.
     REFRESH it_log.
     PERFORM bal_validation.
     PERFORM grn.
   WHEN 'PRINT'.
     PERFORM print_form.
   WHEN 'DELETE'.
     PERFORM delete_line.
   WHEN OTHERS.
 ENDCASE.
    IF it_log IS NOT INITIAL.
      PERFORM messages.
    ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_chain INPUT.

IF lv_ebeln IS NOT INITIAL AND it_final IS  INITIAL.

  SELECT ekko~lifnr,
         lfa1~name1,
         ekko~knumv,
         ekpo~ebelp,
         ekpo~matnr,
         makt~maktx,
         eket~charg ,
         ekpo~menge,
         ekpo~mwskz      FROM ekko AS ekko INNER JOIN ekpo AS ekpo ON ekko~ebeln = ekpo~ebeln
                         INNER JOIN eket AS eket ON eket~ebeln = ekpo~ebeln AND eket~ebelp = ekpo~ebelp
                         INNER JOIN makt AS makt ON ekpo~matnr = makt~matnr
                         INNER JOIN lfa1 AS lfa1 ON ekko~lifnr = lfa1~lifnr
                         INTO TABLE @DATA(it_data) WHERE ekko~ebeln = @lv_ebeln
                         AND makt~spras = @sy-langu AND ekpo~loekz = ' '.

      READ TABLE it_data INTO DATA(wa_data) INDEX 1.
      SELECT kposn,kschl,knumv,kbetr,kwert FROM prcd_elements INTO TABLE @DATA(it_prcd) WHERE knumv = @wa_data-knumv
                                                                            AND   kschl IN ( 'ZDS1' , 'PBXX' ).
    CLEAR wa_data.
    SORT it_data BY ebelp.
    IF it_data IS NOT INITIAL.
      LOOP AT it_data INTO wa_data.
        wa_final-ebelp = wa_data-ebelp.
        wa_final-matnr = wa_data-matnr.
        wa_final-maktx = wa_data-maktx.
        wa_final-lifnr = wa_data-lifnr.
        wa_final-name1 = wa_data-name1.
        wa_final-charg = wa_data-charg.
        wa_final-menge = wa_data-menge.
*      READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY kposn = wa_final-ebelp kschl = 'ZDS1'.
      READ TABLE it_prcd INTO DATA(wa_fs) WITH KEY kposn = wa_final-ebelp kschl = 'ZDS1'.
        wa_final-disc = wa_fs-kbetr   * -1.
*      READ TABLE it_prcd ASSIGNING FIELD-SYMBOL(<fs1>) WITH KEY kposn = wa_final-ebelp kschl = 'PBXX'.
      READ TABLE it_prcd INTO DATA(wa_fs1) WITH KEY kposn = wa_final-ebelp kschl = 'PBXX'.
        wa_final-verpr = wa_fs1-kwert * -1.
        DATA(lv_val) = ( wa_final-verpr * 5 ) / 100.
        wa_final-verpr_f = wa_final-verpr - lv_val.
        CLEAR lv_val.
       IF wa_data-mwskz IS NOT INITIAL.
          SELECT SUM( kbetr )  INTO  wa_final-taxper FROM konp AS konp INNER JOIN a003 AS a003 ON a003~knumh = konp~knumh
              WHERE  a003~mwskz = wa_data-mwskz.
          IF  wa_final-taxper IS NOT INITIAL.
            wa_final-taxper =  wa_final-taxper / 10.
          ENDIF.
       ENDIF.

******************************FOR SELLING PRICE AND MRP**********************************************************
    IF wa_final-charg IS NOT INITIAL.
      SELECT SINGLE b1_batch FROM zb1_s4_map INTO @DATA(lv_batch) WHERE s4_batch = @wa_final-charg.
        IF sy-subrc = 0.
          wa_final-charg = lv_batch.
          SELECT SINGLE amount FROM zb1_s_price INTO wa_final-selp WHERE b1_batch = lv_batch.
        ELSE.
          SELECT SINGLE knumh FROM a511 INTO @DATA(lv_knumh) WHERE charg = @wa_final-charg  AND kschl = 'ZKP0'
                                                             AND   matnr = @wa_final-matnr AND datbi GE @sy-datum.
          SELECT SINGLE kbetr FROM konp INTO wa_final-selp  WHERE knumh = lv_knumh.
          SELECT SINGLE knumh FROM a515 INTO @DATA(lv_knumh1) WHERE  kschl = 'ZMRP'
                                                           AND   matnr = @wa_final-matnr AND datbi GE @sy-datum.
          SELECT SINGLE kbetr FROM konp INTO wa_final-mrp  WHERE knumh = lv_knumh1.

        ENDIF.
    ENDIF.
*********************************************************************************************************
      APPEND wa_final TO it_final.
      CLEAR: wa_final, wa_data, lv_batch, lv_knumh, lv_knumh1, wa_fs, wa_fs1.
      ENDLOOP.
    ENDIF.

   CALL METHOD grid->refresh_table_display.

ENDIF.

ENDMODULE.
