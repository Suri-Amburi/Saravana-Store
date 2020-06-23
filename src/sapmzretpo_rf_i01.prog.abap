*&---------------------------------------------------------------------*
*& Include          SAPMZRETPO_RF_I01
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
*&      Module  CHECK_LIFNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_lifnr INPUT.

IF lv_charg IS NOT INITIAL.
*  CLEAR wa_hdr.

  SELECT SINGLE b1_batch,s4_batch,b1_vendor,plant,amount,matnr FROM zb1_s4_map
                INTO @DATA(wa_bstck) WHERE b1_batch = @lv_charg AND plant = @wa_hdr-werks.

   IF wa_bstck IS NOT INITIAL.  """"FOR B1 BATCH
     SELECT SINGLE matnr,matkl FROM mara INTO @DATA(wa_mara) WHERE matnr = @wa_bstck-matnr.
     SELECT SINGLE klah~class,klah~clint,kssk~objek,klah1~class AS matkl INTO  @DATA(wa_data)
            FROM klah AS klah INNER JOIN kssk AS kssk ON ( kssk~clint EQ klah~clint )
            INNER JOIN klah AS klah1 ON ( kssk~objek EQ klah1~clint )
            WHERE klah~klart  = '026' AND
                  klah~wwskz  = '0' AND
                  klah1~class = @wa_mara-matkl.
     SELECT SINGLE ekgrp,eknam FROM t024 INTO @DATA(wa_t024) WHERE eknam = @wa_data-class.
     SELECT SINGLE matnr,bwkey,bwtar,verpr FROM mbew INTO @DATA(wa_mbew) WHERE bwkey = @wa_bstck-plant AND
                                                                               bwtar = @wa_bstck-s4_batch.

     wa_bstck-b1_vendor = |{ wa_bstck-b1_vendor ALPHA = IN }|.
     SELECT SINGLE name1,regio FROM lfa1 INTO @DATA(wa_lfa1) WHERE lifnr = @wa_bstck-b1_vendor.

     SELECT SINGLE a792~wkreg,a792~regio,a792~steuc,a792~knumh,marc~matnr,t001w~werks FROM marc AS marc
     INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
     INTO @DATA(wa_hsn) WHERE marc~matnr = @wa_bstck-matnr AND a792~regio = @wa_lfa1-regio
     AND t001w~werks = @wa_hdr-werks AND   a792~datab LE @sy-datum AND   a792~datbi GE @sy-datum.

     IF wa_hsn IS NOT INITIAL.
        SELECT SINGLE knumh,mwsk1 FROM konp INTO @DATA(wa_konp)
                      WHERE knumh = @wa_hsn-knumh .
     ENDIF.


******************VALIDATING FOR SAME VENDOR AND PURCHASE ORDER*************************************
    IF it_final IS NOT INITIAL.
      READ TABLE it_final  WITH KEY lifnr =  wa_bstck-b1_vendor TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
           CLEAR: gw_mess,wa_bstck,wa_mara,wa_data,wa_t024,wa_mbew, wa_lfa1,wa_hsn, wa_konp.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'VENDOR IS DIFFERENT' .
            gw_mess-mess2 = 'FROM EXISTING'.
            gw_mess-mess3 = 'BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.
        ENDIF.
       READ TABLE it_final  WITH KEY ekgrp =  wa_t024-ekgrp TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
           CLEAR: gw_mess,wa_bstck,wa_mara,wa_data,wa_t024,wa_mbew, wa_lfa1,wa_hsn, wa_konp.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'PURCHASE GROUP IS' .
            gw_mess-mess2 = 'DIFFERENT FROM'.
            gw_mess-mess3 = 'EXISTING BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.
        ENDIF.
   ENDIF.

     IF wa_mbew-verpr IS INITIAL.
           CLEAR: gw_mess,wa_bstck,wa_mara,wa_data,wa_t024,wa_mbew, wa_lfa1,wa_hsn, wa_konp.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'INSUFFICIENT' .
            gw_mess-mess2 = 'STOCK'.
*            gw_mess-mess3 = 'EXISTING BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.

     ENDIF.

     IF  wa_konp-mwsk1 IS INITIAL.
           CLEAR: gw_mess,wa_bstck,wa_mara,wa_data,wa_t024,wa_mbew, wa_lfa1,wa_hsn, wa_konp..
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'TAX CODE' .
            gw_mess-mess2 = 'NOT MAINTAINED'.
*            gw_mess-mess3 = 'EXISTING BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.

     ENDIF.
****************************************************************************************************
      wa_hdr-lifnr   = wa_bstck-b1_vendor.
      wa_hdr-name1   = wa_lfa1-name1.
      wa_hdr-lcharg  = lv_charg.
      wa_hdr-ekgrp   = wa_t024-ekgrp.

       SELECT SINGLE eknam FROM t024 INTO wa_hdr-eknam WHERE ekgrp = wa_hdr-ekgrp.

     wa_final-werks  = wa_bstck-plant.
     wa_final-charg  = wa_bstck-s4_batch.
     wa_final-lifnr  = wa_bstck-b1_vendor.
     wa_final-menge  = 1.
     wa_final-verpr  = wa_mbew-verpr.
     wa_final-ekgrp  = wa_t024-ekgrp.
     wa_final-matnr  = wa_bstck-matnr.
     wa_final-mwsk1  = wa_konp-mwsk1.

    APPEND wa_final TO it_final.
    CLEAR: wa_final, lv_charg.
    CLEAR: wa_bstck,wa_mara,wa_data,wa_t024,wa_mbew, wa_lfa1,wa_hsn, wa_konp.
    DESCRIBE TABLE it_final LINES lv_count.

  ELSE. """ FOR S4 BATCH
     SELECT SINGLE bwart,matnr,werks,charg,lifnr,ebeln FROM mseg INTO @DATA(wa_mseg)
           WHERE charg = @lv_charg AND bwart IN ( '101' , '107' ) AND charg NE ' ' AND werks = @wa_hdr-werks.

      IF wa_mseg IS NOT INITIAL.
         SELECT SINGLE ebeln,ekgrp FROM ekko INTO @DATA(wa_ekko) WHERE ebeln =  @wa_mseg-ebeln .
         SELECT SINGLE matnr,bwkey,bwtar,verpr FROM mbew INTO @DATA(wa_mbew1)
                 WHERE bwtar = @wa_mseg-charg AND   matnr = @wa_mseg-matnr AND   bwkey = @wa_mseg-werks.

     wa_mseg-lifnr = |{ wa_mseg-lifnr ALPHA = IN }|.
     SELECT SINGLE name1,regio FROM lfa1 INTO @DATA(wa_lfa11) WHERE lifnr = @wa_mseg-lifnr.

     SELECT SINGLE a792~wkreg,a792~regio,a792~steuc,a792~knumh,marc~matnr,t001w~werks FROM marc AS marc
     INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
     INTO @DATA(wa_hsn1) WHERE marc~matnr = @wa_mseg-matnr AND a792~regio = @wa_lfa11-regio
     AND t001w~werks = @wa_hdr-werks AND   a792~datab LE @sy-datum AND   a792~datbi GE @sy-datum.

     IF wa_hsn1 IS NOT INITIAL.
        SELECT SINGLE knumh,mwsk1 FROM konp INTO @DATA(wa_konp1)
                      WHERE knumh = @wa_hsn1-knumh .
     ENDIF.

******************VALIDATING FOR SAME VENDOR AND PURCHASE ORDER*************************************
    IF it_final IS NOT INITIAL.
      READ TABLE it_final  WITH KEY lifnr =  wa_mseg-lifnr TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
           CLEAR:gw_mess,wa_mseg, wa_mbew1,wa_ekko, wa_lfa11, wa_konp1, wa_hsn1..
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'VENDOR IS DIFFERENT' .
            gw_mess-mess2 = 'FROM EXISTING'.
            gw_mess-mess3 = 'BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.
        ENDIF.
       READ TABLE it_final  WITH KEY ekgrp =  wa_ekko-ekgrp TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
           CLEAR: gw_mess,wa_mseg, wa_mbew1,wa_ekko, wa_lfa11, wa_konp1, wa_hsn1.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'PURCHASE GROUP IS' .
            gw_mess-mess2 = 'DIFFERENT FROM'.
            gw_mess-mess3 = 'EXISTING BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.
        ENDIF.
   ENDIF.

    IF wa_mbew1-verpr IS INITIAL.
           CLEAR: gw_mess,wa_mseg, wa_mbew1,wa_ekko, wa_lfa11, wa_konp1, wa_hsn1.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'INSUFFICIENT' .
            gw_mess-mess2 = 'STOCK'.
*            gw_mess-mess3 = 'EXISTING BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.

    ENDIF.

    IF wa_konp1-mwsk1 IS INITIAL.
           CLEAR: gw_mess,wa_mseg, wa_mbew1,wa_ekko, wa_lfa11, wa_konp1, wa_hsn1.
            gw_mess-err   = 'E'.
            gw_mess-mess1 = 'TAX CODE' .
            gw_mess-mess2 = 'NOT MAINTAINED'.
*            gw_mess-mess3 = 'EXISTING BATCH'.
            SET SCREEN 0.
            CALL SCREEN '9000'.
            EXIT.

    ENDIF.


****************************************************************************************************

            wa_hdr-lifnr   = wa_mseg-lifnr.
            wa_hdr-name1   = wa_lfa11-name1.
            wa_hdr-lcharg  = lv_charg.
            wa_hdr-ekgrp   = wa_ekko-ekgrp.
       SELECT SINGLE eknam FROM t024 INTO wa_hdr-eknam WHERE ekgrp = wa_hdr-ekgrp.

           wa_final-werks  = wa_mseg-werks.
           wa_final-charg  = wa_mseg-charg.
           wa_final-lifnr  = wa_mseg-lifnr.
           wa_final-menge  = 1.
           wa_final-verpr  = wa_mbew1-verpr.
           wa_final-ekgrp  = wa_ekko-ekgrp.
           wa_final-matnr  = wa_mseg-matnr.
           wa_final-mwsk1  = wa_konp1-mwsk1.

          APPEND wa_final TO it_final.
          CLEAR: wa_final, lv_charg.
          CLEAR: wa_mseg, wa_mbew1,wa_ekko, wa_lfa11, wa_konp1, wa_hsn1.
          DESCRIBE TABLE it_final LINES lv_count.
      ENDIF.
 ENDIF.
ENDIF.




ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE ok_code2.
    WHEN 'BACK' OR 'CLOSE' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE TO SCREEN '1000'.
    WHEN 'OK'.
      IF gw_mess-err = 'E'.
        CLEAR lv_charg.
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
