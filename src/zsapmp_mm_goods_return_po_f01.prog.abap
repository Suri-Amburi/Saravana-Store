*&---------------------------------------------------------------------*
*& Include          ZSAPMP_MM_GOODS_RETURN_PO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHECK_LIFNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_lifnr INPUT.
  IF it_final IS NOT INITIAL .
    IF lv_batch IS NOT INITIAL.
      REFRESH it_bstck.
      SELECT
            b1_batch
            s4_batch
            b1_vendor
            plant
            amount
            matnr
            FROM   zb1_s4_map
            INTO TABLE it_bstck
            WHERE b1_batch = lv_batch
            AND   plant    = lv_werks.

      IF it_bstck IS NOT INITIAL.
        REFRESH it_mar2.
        SELECT matnr
               matkl
           FROM mara
           INTO TABLE it_mar2
           FOR ALL ENTRIES IN it_bstck
           WHERE matnr = it_bstck-matnr.

        SELECT klah~class,
               klah~clint,
               kssk~objek,
               klah1~class AS matkl
        INTO TABLE @DATA(it_data)
        FROM klah AS klah INNER JOIN kssk AS kssk ON ( kssk~clint EQ klah~clint )
                   INNER JOIN klah AS klah1 ON ( kssk~objek EQ klah1~clint )
        FOR ALL ENTRIES IN @it_mar2
        WHERE klah~klart = '026' AND
              klah~wwskz = '0' AND
              klah1~class EQ @it_mar2-matkl.

        IF it_data IS NOT INITIAL.
          SELECT t024~ekgrp,
                 t024~eknam
          FROM t024
          INTO TABLE @DATA(it_t024)
          FOR ALL ENTRIES IN @it_data
          WHERE t024~eknam EQ @it_data-class.
        ENDIF.


        READ TABLE it_bstck ASSIGNING FIELD-SYMBOL(<ls_lif2>) INDEX 1 .
        IF sy-subrc = 0.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <ls_lif2>-b1_vendor
            IMPORTING
              output = <ls_lif2>-b1_vendor.

          READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_lifn>) WITH KEY lifnr =  <ls_lif2>-b1_vendor.
          IF sy-subrc NE 0 AND sy-ucomm <> 'REF'.
            MESSAGE 'Vendor is different for this Batch' TYPE  'E' .
          ENDIF.
        ENDIF.

        READ TABLE it_mar2 ASSIGNING FIELD-SYMBOL(<mar>) INDEX 1.
        READ TABLE it_data ASSIGNING FIELD-SYMBOL(<data>) WITH KEY matkl = <mar>-matkl .
        READ TABLE it_t024 ASSIGNING FIELD-SYMBOL(<to24>) WITH KEY eknam = <data>-class .
        IF sy-subrc = 0.
          READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_grp>) WITH KEY ekgrp = <to24>-ekgrp.
          IF sy-subrc NE 0 AND sy-ucomm <> 'REF'.
            MESSAGE 'Purchase Group is different for this Batch' TYPE  'E' .
          ENDIF.
        ENDIF.


*******************************************************************************
*******************************************************************************

      ELSEIF it_bstck IS INITIAL.
        SELECT
      bwart
      matnr
      werks
      charg
      lifnr
      ebeln FROM mseg INTO TABLE it_lif
            WHERE charg = lv_batch
            AND bwart IN ( '101' , '107' )
            AND charg NE ' '
            AND werks = lv_werks.

        IF it_lif IS NOT INITIAL.
          SELECT  ekko~ebeln,
                  ekko~ekgrp FROM ekko INTO TABLE @DATA(it_ekko1)
                   FOR ALL ENTRIES IN @it_lif
                   WHERE ebeln =  @it_lif-ebeln .
        ENDIF.
        READ TABLE it_lif ASSIGNING FIELD-SYMBOL(<ls_lif1>) INDEX 1 .
        IF sy-subrc = 0.
          READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_lif>) WITH KEY lifnr =  <ls_lif1>-lifnr.
          IF sy-subrc NE 0 AND sy-ucomm <> 'REF'.
            MESSAGE 'Vendor is different for this Batch' TYPE  'E' .
          ENDIF.
        ENDIF.
        IF it_ekko1 IS NOT INITIAL.
          READ TABLE it_ekko1 ASSIGNING FIELD-SYMBOL(<ls_ekko1>) WITH KEY ebeln = <ls_lif1>-ebeln .
          IF sy-subrc = 0.
            READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_grpn>) WITH KEY ekgrp =  <ls_ekko1>-ekgrp.
            IF sy-subrc NE 0 AND sy-ucomm <> 'REF'.
              MESSAGE 'Purchase Group is different for this Batch' TYPE  'E' .
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

**************************************************************************************************************

* IF rd2 IS NOT INITIAL.
*
*
*
*ENDIF.

    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: lv_mwsk1 TYPE konp-mwsk1.

  IF lv_batch IS NOT INITIAL.
    IF  rad1 IS NOT INITIAL.

      SELECT b1_batch
             s4_batch
             b1_vendor
             plant
             amount
*             quantity
             matnr
        FROM zb1_s4_map
        INTO TABLE it_bstck
        WHERE b1_batch = lv_batch
        AND   plant    = lv_werks.


      IF it_bstck IS NOT INITIAL.
        REFRESH it_mar2.
        SELECT matnr
            matkl
        FROM mara
        INTO TABLE it_mar2
        FOR ALL ENTRIES IN it_bstck
        WHERE matnr = it_bstck-matnr.

        SELECT klah~class,
               klah~clint,
               kssk~objek,
               klah1~class AS matkl
        INTO TABLE @DATA(it_data)
        FROM klah AS klah INNER JOIN kssk AS kssk ON ( kssk~clint EQ klah~clint )
                   INNER JOIN klah AS klah1 ON ( kssk~objek EQ klah1~clint )
        FOR ALL ENTRIES IN @it_mar2
        WHERE klah~klart = '026' AND
              klah~wwskz = '0' AND
              klah1~class EQ @it_mar2-matkl.

        IF it_data IS NOT INITIAL.
          SELECT t024~ekgrp,
                 t024~eknam
          FROM t024
          INTO TABLE @DATA(it_t024)
          FOR ALL ENTRIES IN @it_data
          WHERE t024~eknam EQ @it_data-class.
        ENDIF.


        LOOP AT it_bstck ASSIGNING FIELD-SYMBOL(<fs>).
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <fs>-b1_vendor
            IMPORTING
              output = <fs>-b1_vendor.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

        ENDLOOP.


        SELECT lfa1~lifnr ,
               lfa1~name1 FROM lfa1 INTO TABLE @DATA(it_lfa12)
                         FOR ALL ENTRIES IN @it_bstck
                         WHERE lifnr = @it_bstck-b1_vendor .

        SELECT matnr
               bwkey
               bwtar
               verpr
        FROM mbew
        INTO TABLE it_mbew1
        FOR ALL ENTRIES IN it_bstck
        WHERE "MATNR EQ IT_BSTCK-MATNR AND
              bwkey EQ it_bstck-plant AND
              bwtar EQ it_bstck-s4_batch.

      ENDIF.
***************************************************

      IF it_bstck IS INITIAL.

        SELECT
          bwart
          matnr
          werks
          charg
          lifnr
          ebeln FROM mseg INTO TABLE it_mseg
                WHERE charg = lv_batch
                AND bwart IN ( '101' , '107' )
                AND charg NE ' '
                AND werks = lv_werks.

      ENDIF.
**********************************************************

      IF it_mseg IS NOT INITIAL.
        SELECT
         ekko~ebeln,
         ekko~ekgrp FROM ekko INTO TABLE @DATA(it_ekko)
               FOR ALL ENTRIES IN @it_mseg
               WHERE ebeln =  @it_mseg-ebeln .

        SELECT
           matnr
           bwkey
           bwtar
           verpr FROM mbew INTO TABLE it_mbew
                 FOR ALL ENTRIES IN it_mseg
                 WHERE bwtar = it_mseg-charg
                 AND   matnr = it_mseg-matnr
                 AND   bwkey = it_mseg-werks.
        SELECT
          lfa1~lifnr ,
          lfa1~name1 FROM lfa1 INTO TABLE @DATA(it_lfa1)
                     FOR ALL ENTRIES IN @it_mseg
                     WHERE lifnr = @it_mseg-lifnr .

      ENDIF.


      IF it_bstck IS INITIAL.        " added by krithika for b1_stock batches scanning

        READ TABLE it_mseg INTO wa_mseg INDEX 1.
*     IF WA_MSEG IS NOT INITIAL.
        wa_final-matnr = wa_mseg-matnr .
        wa_final-lifnr = wa_mseg-lifnr .
        wa_final-werks = wa_mseg-werks.

        wa_final-charg = lv_batch.
        wa_final-charg1 = lv_batch.
        IF wa_mseg IS NOT INITIAL.
          SELECT SINGLE knumh FROM a511 INTO @DATA(lv_knumh) WHERE charg = @lv_batch  AND kschl = 'ZKP0'
                                                             AND   matnr = @wa_final-matnr AND datbi GE @sy-datum.

          SELECT SINGLE kbetr FROM konp INTO wa_final-selp  WHERE knumh = lv_knumh.

          SELECT SINGLE knumh FROM a515 INTO @DATA(lv_knumh1) WHERE  kschl = 'ZMRP'
                                                           AND   matnr = @wa_final-matnr AND datbi GE @sy-datum.
          SELECT SINGLE kbetr FROM konp INTO wa_final-mrp  WHERE knumh = lv_knumh1.
        ENDIF.
        wa_final-tax_per = ' '.
        wa_final-tax_val = ' '.
        READ TABLE it_lfa1 ASSIGNING FIELD-SYMBOL(<ls_lfa1>) WITH KEY lifnr = wa_mseg-lifnr .
        IF sy-subrc = 0.

          wa_final-name1 = <ls_lfa1>-name1 .

        ENDIF.
        READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<ls_ekko>) WITH KEY ebeln = wa_mseg-ebeln .
        IF sy-subrc = 0.
          wa_final-ekgrp = <ls_ekko>-ekgrp.
        ENDIF.

        READ TABLE it_mbew INTO wa_mbew WITH KEY bwtar = wa_mseg-charg .
        IF sy-subrc = 0.
          wa_final-verpr =  wa_mbew-verpr .
        ENDIF.

**********************************************************************

        SELECT SINGLE regio FROM lfa1 INTO  @DATA(ls_lregio)
                           WHERE lifnr = @wa_mseg-lifnr.

        SELECT SINGLE regio FROM t001w INTO @DATA(ls_wregio) WHERE werks = @lv_werks.

        CLEAR lv_mwsk1.
        SELECT SINGLE konp~mwsk1 INTO lv_mwsk1
            FROM konp AS konp INNER JOIN a792 AS a792 ON a792~knumh = konp~knumh
                              INNER JOIN marc AS marc ON marc~steuc = a792~steuc
                              WHERE marc~matnr = wa_final-matnr
                              AND   marc~werks = wa_final-werks
                              AND   a792~datab LE sy-datum
                              AND   a792~datbi GE sy-datum
                              AND   a792~regio = ls_lregio
                              AND   a792~wkreg = ls_wregio
                              AND   konp~loevm_ko = ' '.

        IF lv_mwsk1 IS NOT INITIAL.
          SELECT SUM( kbetr ) AS e_taxp INTO  wa_final-tax_per FROM konp AS konp INNER JOIN a003 AS a003 ON a003~knumh = konp~knumh
              WHERE  a003~mwskz = lv_mwsk1.
          IF  wa_final-tax_per IS NOT INITIAL.
            wa_final-tax_per =  wa_final-tax_per / 10.
          ENDIF.

        ENDIF.

        READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_final>) WITH KEY charg = lv_batch.

        IF sy-subrc = 0.
          wa_final-quantity = <ls_final>-quantity + 1.
          wa_final-value = wa_final-quantity * wa_mbew-verpr  .
          wa_final-dvalue = wa_final-quantity * wa_mbew-verpr  .
          wa_final-seltot = wa_final-quantity * wa_final-selp.
          MODIFY TABLE it_final FROM wa_final TRANSPORTING quantity value dvalue seltot.
        ELSE .
          wa_final-quantity = 1.
          wa_final-value = wa_final-quantity * wa_mbew-verpr  .
          wa_final-dvalue = wa_final-quantity * wa_mbew-verpr  .
          wa_final-seltot = wa_final-quantity * wa_final-selp.
          IF wa_final-value IS INITIAL AND sy-ucomm <> 'REF'.
            MESSAGE 'Deficit Of Stock' TYPE 'S' DISPLAY LIKE 'E'.
            EXIT.
          ENDIF.

          APPEND wa_final TO it_final .
          CLEAR : wa_final .
        ENDIF.

*****************************************************************************
      ELSE.

        READ TABLE it_bstck INTO wa_bstck INDEX 1. " WITH KEY batch = wa_mseg-charg.
        IF sy-subrc EQ 0.
          wa_final-matnr = wa_bstck-matnr .
          wa_final-lifnr = wa_bstck-b1_vendor .
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_final-lifnr
            IMPORTING
              output = wa_final-lifnr.

          wa_final-werks = wa_bstck-plant.
          wa_final-charg = wa_bstck-s4_batch.
          wa_final-charg1 = lv_batch.
          wa_final-tax_val = ' '.

          SELECT SINGLE amount FROM zb1_s_price INTO wa_final-selp WHERE b1_batch = lv_batch.

          READ TABLE it_lfa12 ASSIGNING FIELD-SYMBOL(<ls_lfa2>) WITH KEY lifnr = wa_bstck-b1_vendor .
          IF sy-subrc = 0.
            wa_final-name1 = <ls_lfa2>-name1 .
          ENDIF.
*      READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<ls_ekko1>) WITH KEY ebeln = wa_mseg-ebeln .
*      IF sy-subrc = 0.
*        wa_final-ekgrp = <ls_ekko1>-ekgrp.
*      ENDIF.

          READ TABLE it_mar2 ASSIGNING FIELD-SYMBOL(<mar>) INDEX 1.
          READ TABLE it_data ASSIGNING FIELD-SYMBOL(<data>) WITH KEY matkl = <mar>-matkl .
          READ TABLE it_t024 ASSIGNING FIELD-SYMBOL(<t024>) WITH KEY eknam = <data>-class .
          IF sy-subrc = 0.
            wa_final-ekgrp = <t024>-ekgrp.
          ENDIF.

          READ TABLE it_mbew1 INTO wa_mbew1 WITH KEY bwtar = wa_bstck-s4_batch .
          IF sy-subrc = 0.
            wa_final-verpr =  wa_mbew1-verpr .
          ENDIF.

**********************************************************************
          SELECT SINGLE regio FROM lfa1 INTO  @DATA(ls_lregio1)
                             WHERE lifnr = @wa_bstck-b1_vendor.

          SELECT SINGLE regio FROM t001w INTO @DATA(ls_wregio1) WHERE werks = @lv_werks.


          CLEAR lv_mwsk1.
          SELECT SINGLE konp~mwsk1 INTO lv_mwsk1
              FROM konp AS konp INNER JOIN a792 AS a792 ON a792~knumh = konp~knumh
                                INNER JOIN marc AS marc ON marc~steuc = a792~steuc
                                WHERE marc~matnr = wa_final-matnr
                                AND   a792~datab LE sy-datum
                                AND   a792~datbi GE sy-datum
                                AND   a792~regio = ls_lregio1
                                AND   a792~wkreg = ls_wregio1
                                AND   konp~loevm_ko = ' '.

          IF lv_mwsk1 IS NOT INITIAL.
            SELECT SUM( kbetr ) AS e_taxp INTO  wa_final-tax_per FROM konp AS konp INNER JOIN a003 AS a003 ON a003~knumh = konp~knumh
                WHERE  a003~mwskz = lv_mwsk1.
            IF  wa_final-tax_per IS NOT INITIAL.
              wa_final-tax_per =  wa_final-tax_per / 10.
            ENDIF.

          ENDIF.
          READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_final1>) WITH KEY charg =  wa_bstck-s4_batch." wa_mseg-charg.
          IF sy-subrc = 0.
            wa_final-quantity = <ls_final1>-quantity + 1.
            wa_final-value = wa_final-quantity * wa_final-verpr ." wa_mbew-verpr  .
            wa_final-dvalue = wa_final-quantity * wa_final-verpr ." wa_mbew-verpr  .
            wa_final-seltot = wa_final-quantity * wa_final-selp.
            MODIFY TABLE it_final FROM wa_final TRANSPORTING quantity value dvalue seltot .
          ELSE .
            wa_final-quantity = 1.
            wa_final-value = wa_final-quantity * wa_mbew1-verpr  .
            wa_final-dvalue = wa_final-quantity * wa_mbew1-verpr  .
            wa_final-seltot = wa_final-quantity * wa_final-selp.

            IF wa_final-value IS INITIAL AND sy-ucomm <> 'REF'..
              MESSAGE 'Deficit Of Stock' TYPE 'S' DISPLAY LIKE 'E'.
              EXIT.
            ENDIF.


            APPEND wa_final TO it_final .
            CLEAR : wa_final .
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
*****************************************************************************

********************************************************************************
*******************************************************************************

    IF rad2 IS NOT INITIAL.

      SELECT SINGLE matnr,ean11,matkl FROM mara INTO @DATA(wa_mara) WHERE ean11 = @lv_batch.

      SELECT SINGLE klah~class,klah~clint,kssk~objek,klah1~class AS matkl
        INTO  @DATA(wa_data)
        FROM klah AS klah INNER JOIN kssk AS kssk ON ( kssk~clint EQ klah~clint )
                   INNER JOIN klah AS klah1 ON ( kssk~objek EQ klah1~clint )
                   WHERE klah~klart = '026' AND
                   klah~wwskz = '0' AND
                   klah1~class EQ @wa_mara-matkl.

      IF wa_mara IS NOT INITIAL.
        SELECT SINGLE t024~ekgrp,t024~eknam FROM t024 INTO  @DATA(wa_t024)
             WHERE t024~eknam EQ @wa_data-class.
      ENDIF.


      SELECT SINGLE knumh FROM a502 INTO @DATA(lv_knumhpurch) WHERE lifnr = @lv_lifnr AND kschl = 'PB00'
                                                         AND   matnr = @wa_mara-matnr AND datbi GE @sy-datum.
      SELECT SINGLE kbetr FROM konp INTO @DATA(lv_kbetrpurch)  WHERE knumh = @lv_knumhpurch.

      SELECT SINGLE knumh FROM a515 INTO @DATA(lv_knumhmrp) WHERE  kschl = 'ZMRP'
                                                       AND  matnr = @wa_mara-matnr AND datbi GE @sy-datum.
      SELECT SINGLE kbetr FROM konp INTO @DATA(lv_kbetrmrp)  WHERE knumh = @lv_knumhmrp.

      SELECT SINGLE knumh FROM a406 INTO @DATA(lv_knumhsell) WHERE  kschl = 'ZEAN'
                                                       AND  matnr = @wa_mara-matnr AND werks = @lv_werks
                                                       AND datbi GE @sy-datum.
      SELECT SINGLE kbetr FROM konp INTO @DATA(lv_kbetrsell)  WHERE knumh = @lv_knumhmrp.

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

      IF lv_mwsk1 IS NOT INITIAL.
        SELECT SUM( kbetr ) AS e_taxp INTO @DATA(lv_tax_per) FROM konp AS konp INNER JOIN a003 AS a003 ON a003~knumh = konp~knumh
            WHERE  a003~mwskz = @lv_mwsk1.
        IF  lv_tax_per IS NOT INITIAL.
          lv_tax_per  =  lv_tax_per / 10.
        ENDIF.

      ENDIF.



      wa_final-charg1    = lv_batch.
      wa_final-matnr     = wa_mara-matnr.
      wa_final-quantity  = '1'.
      wa_final-verpr     = lv_kbetrpurch.
      wa_final-tax_per   = lv_tax_per.
      wa_final-dvalue    = lv_kbetrpurch.
      wa_final-value     = lv_kbetrpurch.
      wa_final-mrp       = lv_kbetrmrp.
      wa_final-selp      = lv_kbetrsell.
      wa_final-seltot    =  wa_final-quantity * wa_final-selp.
      wa_final-ekgrp     = wa_t024-ekgrp.
      wa_final-werks     = lv_werks.
      wa_final-lifnr     = lv_lifnr.
      wa_final-name1     = lv_name1.

      READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_skn>) WITH KEY charg1 =  lv_batch." wa_mseg-charg.
      IF sy-subrc = 0.
        wa_final-quantity = <ls_skn>-quantity + 1.
        wa_final-value = wa_final-quantity * wa_final-verpr ." wa_mbew-verpr  .
        wa_final-dvalue = wa_final-quantity * wa_final-verpr ." wa_mbew-verpr  .
        wa_final-seltot = wa_final-quantity * wa_final-selp.
        MODIFY TABLE it_final FROM wa_final TRANSPORTING quantity value dvalue seltot .
      ELSE .
        APPEND wa_final TO it_final.
        CLEAR wa_final.
      ENDIF.

    ENDIF.

  ENDIF.

  CLEAR : lv_batch , wa_mbew, it_mbew,wa_mseg , it_mseg.

  IF grid IS BOUND.
    CALL METHOD grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.

  IF container IS INITIAL.
    PERFORM setup_alv.
  ENDIF.
  PERFORM fill_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SETUP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM setup_alv .

  CREATE OBJECT container
    EXPORTING
      container_name = 'CONTAINER'.
  CREATE OBJECT grid
    EXPORTING
      i_parent = container.

  CALL METHOD grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  CREATE OBJECT g_verifier.
  SET HANDLER g_verifier->update FOR grid.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_grid .

  REFRESH lt_fieldcat.
  DATA: wa_fc  TYPE  lvc_s_fcat.

  wa_fc-col_pos   = '1'.
  wa_fc-fieldname = 'CHARG1'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Batch'.
  wa_fc-outputlen = 15.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '2'.
  wa_fc-fieldname = 'MATNR'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Material Code'.
  wa_fc-outputlen = 18.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  IF rad2 IS  INITIAL.

    wa_fc-col_pos   = '3'.
    wa_fc-fieldname = 'LIFNR'.
    wa_fc-tabname   = 'IT_FINAL'.
    wa_fc-scrtext_l = 'Vendor'.
    APPEND wa_fc TO lt_fieldcat.
    CLEAR wa_fc.


    wa_fc-col_pos   = '4'.
    wa_fc-fieldname = 'NAME1'.
    wa_fc-tabname   = 'IT_FINAL'.
    wa_fc-scrtext_l = 'Vendor Name'.
    wa_fc-outputlen = 20.
    APPEND wa_fc TO lt_fieldcat.
    CLEAR wa_fc.

  ENDIF.

*  wa_fc-col_pos   = '4'.
*  wa_fc-fieldname = 'WERKS'.
*  wa_fc-tabname   = 'IT_FINAL'.
*  wa_fc-scrtext_l = 'Plant'.
*  APPEND wa_fc TO lt_fieldcat.
*  CLEAR wa_fc.

  wa_fc-col_pos   = '5'.
  wa_fc-fieldname = 'QUANTITY'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Quantity'.
  wa_fc-do_sum    = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


  wa_fc-col_pos   = '6'.
  wa_fc-fieldname = 'VERPR'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Purchase Price'.
*  wa_fc-ref_table = 'MBEW'.
*  wa_fc-ref_field = 'VERPR'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  DESCRIBE TABLE it_final LINES DATA(lv_lines).
  READ TABLE it_final INTO DATA(wa_fin) INDEX lv_lines.
  SELECT SINGLE matkl FROM mara INTO @DATA(lv_matkl) WHERE matnr = @wa_fin-matnr.
  IF lv_matkl+0(2) = 'B1'.
    wa_fc-edit      = 'X'.
  ENDIF.

  wa_fc-col_pos   = '7'.
  wa_fc-fieldname = 'DISC'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Discount'.
*  wa_fc-edit      = 'X'.
  wa_fc-ref_table = 'KONP'.
  wa_fc-ref_field = 'KBETR'.
  wa_fc-outputlen = '08'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '9'.
  wa_fc-fieldname = 'TAX_PER'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Tax %'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.


  wa_fc-col_pos   = '10'.
*  wa_fc-fieldname = 'VALUE'.
  wa_fc-fieldname = 'DVALUE'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Purchase Value'.
  wa_fc-do_sum    = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '11'.
*  wa_fc-fieldname = 'VALUE'.
  wa_fc-fieldname = 'MRP'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'MRP'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '12'.
*  wa_fc-fieldname = 'VALUE'.
  wa_fc-fieldname = 'SELP'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Selling Price'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.

  wa_fc-col_pos   = '13'.
*  wa_fc-fieldname = 'VALUE'.
  wa_fc-fieldname = 'SELTOT'.
  wa_fc-tabname   = 'IT_FINAL'.
  wa_fc-scrtext_l = 'Selling Total'.
  wa_fc-do_sum    = 'X'.
  APPEND wa_fc TO lt_fieldcat.
  CLEAR wa_fc.




  PERFORM exclude_tb_functions CHANGING lt_exclude.

  CALL METHOD grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified " Event ID
    EXCEPTIONS
      error      = 1                " Error
      OTHERS     = 2.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding          = lt_exclude
      is_layout                     = lw_layo
    CHANGING
      it_outtab                     = it_final[] "it_item[]
      it_fieldcatalog               = lt_fieldcat
*     IT_SORT                       = IT_SORT[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_tb_functions  CHANGING lt_exclude TYPE ui_functions.

  DATA ls_exclude TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO lt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
*  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find_more.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_average.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO lt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
*  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO lt_exclude.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_RPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_rpo .
  DATA : lv_poitem TYPE ebelp.
  DATA:
    header       LIKE bapimepoheader,
    header_no_pp TYPE bapiflag,
    headerx      LIKE bapimepoheaderx,
    item         TYPE TABLE OF bapimepoitem  WITH HEADER LINE,
    itemx        TYPE TABLE OF bapimepoitemx  WITH HEADER LINE,
    it_return    TYPE TABLE OF bapiret2,
    lw_return    TYPE bapiret2,
    it_pocond    TYPE TABLE OF bapimepocond,
    wa_pocond    TYPE  bapimepocond,
    it_pocondx   TYPE TABLE OF bapimepocondx,
    wa_pocondx   TYPE bapimepocondx.

  DATA : lv_tebeln(40) TYPE c.
  DATA : lv_tex(20) TYPE c.

  DATA : wa_header TYPE thead.

  READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_retpo>) INDEX 1 .

  SELECT SINGLE
   lfa1~adrnr FROM lfa1 INTO @DATA(p_adrnr)
              WHERE lifnr = @<ls_retpo>-lifnr .

  SELECT SINGLE
    adrc~addrnumber ,
    adrc~city1 FROM adrc INTO @DATA(wa_city)
               WHERE addrnumber = @p_adrnr .

  SELECT
    mseg~matnr,
    mseg~ebeln FROM mseg INTO TABLE @DATA(it_rmseg)
               FOR ALL ENTRIES IN @it_final
               WHERE matnr = @it_final-matnr
               AND   charg = @it_final-charg
              AND  bwart IN ('101' , '107') .


  IF it_rmseg IS NOT INITIAL.

    SELECT
      ekko~ebeln,
      ekko~ekgrp FROM ekko INTO TABLE @DATA(it_rekko)
                 FOR ALL ENTRIES IN @it_rmseg
                 WHERE ebeln =  @it_rmseg-ebeln .

  ENDIF.
*** added by krithika for b1_stock batches
  IF it_rekko IS INITIAL AND it_bstck IS NOT INITIAL.
    SELECT matnr
           matkl
    FROM mara
    INTO TABLE it_mara1
    FOR ALL ENTRIES IN it_final
    WHERE matnr = it_final-matnr.

    SELECT klah~class,
           klah~clint,
           kssk~objek,
           klah1~class AS matkl
    INTO TABLE @DATA(it_data)
    FROM klah AS klah INNER JOIN kssk AS kssk ON ( kssk~clint EQ klah~clint )
               INNER JOIN klah AS klah1 ON ( kssk~objek EQ klah1~clint )
    FOR ALL ENTRIES IN @it_mara1
    WHERE klah~klart = '026' AND
          klah~wwskz = '0' AND
  " KLAH~CLASS IN S_GRP AND
          klah1~class EQ @it_mara1-matkl.

    IF it_data IS NOT INITIAL.
      SELECT t024~ekgrp,
             t024~eknam
      FROM t024
      INTO TABLE @DATA(it_t024)
      FOR ALL ENTRIES IN @it_data
      WHERE t024~eknam EQ @it_data-class.
    ENDIF.
  ENDIF.
*** changes ended

  SELECT SINGLE
       lfa1~regio FROM lfa1 INTO  @DATA(ls_lfa1)
         WHERE lifnr = @<ls_retpo>-lifnr.


  SELECT
  a792~wkreg ,
  a792~regio ,
  a792~steuc ,
  a792~knumh ,
  marc~matnr ,
  t001w~werks
   FROM marc AS marc
   INNER JOIN a792 AS a792 ON marc~steuc  = a792~steuc
   INNER JOIN t001w AS t001w ON marc~werks = t001w~werks
   INTO TABLE @DATA(it_hsn)
   FOR ALL ENTRIES IN @it_final
   WHERE marc~matnr = @it_final-matnr
   AND a792~regio   = @ls_lfa1
   AND t001w~werks = @it_final-werks
   AND   a792~datab LE @sy-datum
   AND   a792~datbi GE @sy-datum
.



  IF it_hsn IS NOT INITIAL .
    SELECT
      konp~knumh ,
      konp~mwsk1 FROM konp INTO TABLE @DATA(it_konp)
                 FOR ALL ENTRIES IN @it_hsn
                 WHERE knumh = @it_hsn-knumh .
  ENDIF .

  IF it_final IS NOT INITIAL.
    SELECT
      mara~matnr,
      mara~meins
    FROM mara INTO TABLE @DATA(it_mara)
                 FOR ALL ENTRIES IN @it_final
                 WHERE matnr = @it_final-matnr.

  ENDIF.

  DATA : lv_doc TYPE esart .
  lv_doc = 'ZRET' .

  header_no_pp = 'X'.

  header-comp_code  = '1000'.
  header-creat_date = sy-datum .
  header-vendor     = <ls_retpo>-lifnr.
  header-doc_type   = lv_doc .
  header-langu      = sy-langu .
  header-currency = 'INR'.             " added by krithika
  header-purch_org = '1000'.
  READ TABLE it_rekko ASSIGNING FIELD-SYMBOL(<ls_rekko>) INDEX 1 .
  IF sy-subrc = 0 .
    header-pur_group = <ls_rekko>-ekgrp .
  ELSEIF it_t024 IS NOT INITIAL.
    READ TABLE it_t024 ASSIGNING FIELD-SYMBOL(<ls_t024>) INDEX 1.
    header-pur_group = <ls_t024>-ekgrp.
  ELSEIF rad2 IS NOT INITIAL.
    header-pur_group = <ls_retpo>-ekgrp.
  ENDIF.
*** changes ended

  headerx-comp_code = 'X'.
  headerx-creat_date = 'X'.
  headerx-vendor = 'X'.
  headerx-doc_type = 'X' .
  headerx-langu = 'X' .
  headerx-purch_org = 'X' .
  headerx-pur_group = 'X' .
  headerx-currency = 'X'.              " added by krithika

  REFRESH item.
  REFRESH itemx.

  LOOP AT it_final ASSIGNING FIELD-SYMBOL(<ls_item>).

    lv_poitem = lv_poitem + 10.

    item-po_item = itemx-po_item = lv_poitem .
    READ TABLE it_hsn ASSIGNING FIELD-SYMBOL(<ls_hsn1>) WITH KEY matnr = <ls_item>-matnr .
    IF sy-subrc = 0.
      READ TABLE it_konp ASSIGNING FIELD-SYMBOL(<ls_konp1>) WITH KEY knumh = <ls_hsn1>-knumh .
      IF sy-subrc = 0.

        item-tax_code = <ls_konp1>-mwsk1.
*            WA_ITEMX-TAX_CODE = 'X'.

      ENDIF.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_item>-matnr
      IMPORTING
        output = <ls_item>-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = item-po_item
      IMPORTING
        output = item-po_item.

    DATA(mat_len) = strlen( <ls_item>-matnr ) .
    IF mat_len > 18.
      item-material_long = <ls_item>-matnr.
      itemx-material_long    = 'X'.
    ELSE.
      item-material = <ls_item>-matnr.
      itemx-material    = 'X'.
    ENDIF.


*    item-material  = <ls_item>-matnr.
    item-plant     = <ls_item>-werks.
    item-quantity  = <ls_item>-quantity.
    item-net_price = <ls_item>-verpr.
    item-batch     = <ls_item>-charg.
    item-stge_loc  = 'FG01'.
    item-ret_item  = 'X'.

    READ TABLE it_mara ASSIGNING FIELD-SYMBOL(<ls_mara>) WITH KEY matnr = <ls_item>-matnr .
    IF sy-subrc = 0.
      item-po_unit  = <ls_mara>-meins .
    ENDIF.

*    itemx-material    = 'X'.
    itemx-plant       = 'X'.
    itemx-quantity    = 'X'.
    itemx-po_unit     = 'X'.
    itemx-net_price   = 'X'.
    itemx-batch       = 'X'.
    itemx-stge_loc    = 'X'.
    itemx-ret_item    = 'X'.
    itemx-tax_code    = 'X'.
*    ITEMX-PRICE_UNIT = 'X'.
    APPEND item.
    APPEND itemx .



    wa_pocond-itm_number = item-po_item.
    wa_pocond-cond_type  = 'PBXX'.
*       wa_pocond-cond_unit = <ls_item>-meins.
    wa_pocond-calctypcon = 'C' .
    wa_pocond-cond_value = <ls_item>-verpr / 10.
    wa_pocond-change_id  = 'U'.
    APPEND wa_pocond TO it_pocond.
    CLEAR wa_pocond.

    wa_pocondx-itm_number = item-po_item.
    wa_pocondx-itm_numberx = 'X'.
    wa_pocondx-cond_type  = 'X'.
    wa_pocondx-cond_value = 'X'.
    wa_pocondx-calctypcon = 'X'.
*      wa_pocondx-cond_unit  = c_x.
    wa_pocondx-change_id  = 'X'.
    APPEND wa_pocondx TO it_pocondx.
    CLEAR wa_pocondx.



    wa_pocond-itm_number = item-po_item.
    wa_pocond-cond_type  = 'ZDS1'.
*       wa_pocond-cond_unit =  '%'.
    wa_pocond-calctypcon = 'A' .
    wa_pocond-cond_value = <ls_item>-disc * -1.
    wa_pocond-change_id  = 'U'.
    APPEND wa_pocond TO it_pocond.
    CLEAR wa_pocond.

    wa_pocondx-itm_number = item-po_item.
    wa_pocondx-itm_numberx = 'X'.
    wa_pocondx-cond_type   = 'X'.
    wa_pocondx-cond_value  = 'X'.
    wa_pocondx-calctypcon  = 'X'.
*      wa_pocondx-cond_unit  = c_x.
    wa_pocondx-change_id   = 'X'.
    APPEND wa_pocondx TO it_pocondx.
    CLEAR wa_pocondx.

****************************************************************************************
    CLEAR : itemx , item.

  ENDLOOP.
  IF it_konp IS INITIAL .
    MESSAGE 'There is No Tax Code' TYPE 'E'  .
  ELSE .
** Return PO Creation

    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = header
        poheaderx        = headerx
        no_price_from_po = 'X'
      IMPORTING
        exppurchaseorder = lv_ebeln
      TABLES
        return           = it_return[]
        poitem           = item
        poitemx          = itemx
        pocond           = it_pocond
        pocondx          = it_pocondx.


*******ADDED BY SKN*********

    READ TABLE it_return[] ASSIGNING FIELD-SYMBOL(<ret>) WITH KEY type = 'E'.
    IF  sy-subrc <> '0'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      PERFORM goods_return .
    ELSE .
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      LOOP AT it_return INTO lw_return WHERE type = 'E'.

        APPEND VALUE #( type  = lw_return-type
                        id    = lw_return-id
                        txtnr = lw_return-number
                        msgv1 = lw_return-message_v1
                        msgv2 = lw_return-message_v2 ) TO it_log.

      ENDLOOP.
*      PERFORM delete_po.

    ENDIF.

  ENDIF.

*  PERFORM goods_return .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_RETURN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM goods_return .
  DATA : lv_tex1(30) TYPE c.
  DATA : lv_mblnr(40) TYPE c.
*** BAPI Structure Declaration
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lw_return1      TYPE bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    ls_status       TYPE zinw_t_status.
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.
*  BREAK BREDDY .
  SELECT * FROM ekpo INTO TABLE @DATA(lt_ekpo) WHERE ebeln = @lv_ebeln.
  SELECT DISTINCT ebeln,ebelp,charg FROM eket INTO TABLE @DATA(it_ekbe) FOR ALL ENTRIES IN
                  @lt_ekpo WHERE ebeln = @lt_ekpo-ebeln AND ebelp = @lt_ekpo-ebelp AND charg <> ' '.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = sy-datum. "'20200301'.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.

*** Looping the PO details.
  LOOP AT lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_grn>).
*** FILL THE BAPI ITEM STRUCTURE DETAILS
    DATA(mat_len1) = strlen( <ls_grn>-matnr ) .
    IF mat_len1 > 18.
      ls_gmvt_item-material_long = <ls_grn>-matnr.
    ELSE.
      ls_gmvt_item-material = <ls_grn>-matnr.
    ENDIF.

*    ls_gmvt_item-material  = <ls_grn>-matnr.
    ls_gmvt_item-move_type = '101'.
    ls_gmvt_item-po_number =  <ls_grn>-ebeln.
    ls_gmvt_item-po_item   = <ls_grn>-ebelp.
    ls_gmvt_item-entry_qnt = <ls_grn>-menge.
    ls_gmvt_item-entry_uom = <ls_grn>-meins.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-mvt_ind   = 'B'.
    ls_gmvt_item-move_reas = '02'.
    ls_gmvt_item-plant     = lv_werks.
    ls_gmvt_item-stge_loc  = 'FG01'.
*    READ TABLE it_final ASSIGNING FIELD-SYMBOL(<ls_item_t>) WITH KEY  matnr = <ls_grn>-matnr
*                                                                      quantity = <ls_grn>-menge .
    READ TABLE it_ekbe INTO DATA(wa_ekbe) WITH KEY ebeln = <ls_grn>-ebeln ebelp = <ls_grn>-ebelp.
    IF sy-subrc = 0.
      ls_gmvt_item-batch     = wa_ekbe-charg.
      ls_gmvt_item-val_type  = wa_ekbe-charg.
    ENDIF.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.

  ENDLOOP .

*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = '01'
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

**************************************************************************
  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
  IF sy-subrc <> 0 .
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    gv_mblnr_n = ls_gmvt_headret-mat_doc.


    PERFORM debit_note .  ">>>>>>>>>>.....

    MESSAGE 'SAVED SUCCESSFULLY' TYPE 'S'.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    LOOP AT lt_bapiret INTO lw_return1 WHERE type = 'E'.
      APPEND VALUE #( type  = lw_return1-type
                      id    = lw_return1-id
                      txtnr = lw_return1-number
                      msgv1 = lw_return1-message_v1
                      msgv2 = lw_return1-message_v2 ) TO it_log.

    ENDLOOP.
    PERFORM delete_po.
    CLEAR lv_ebeln.

  ENDIF.

*  PERFORM debit_note .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEBIT_NOTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM debit_note .
  DATA :
         lv_tex2(30)       TYPE c.
  DATA :
    headerdata              TYPE bapi_incinv_create_header,
    fiscalyear              TYPE bapi_incinv_fld-fisc_year,
    ls_itemdata             TYPE bapi_incinv_create_item,
    ls_taxdata              TYPE bapi_incinv_create_tax,
    ls_vendoritemsplitdata  TYPE bapi_incinv_create_vendorsplit,
    itemdata                TYPE STANDARD TABLE OF bapi_incinv_create_item,
    itemvendoritemsplitdata TYPE STANDARD TABLE OF bapi_incinv_create_vendorsplit,
    itemtaxdata             TYPE STANDARD TABLE OF bapi_incinv_create_tax,
    return                  TYPE STANDARD TABLE OF bapiret2,
    lw_return2              TYPE  bapiret2,
    lv_tax_amount           TYPE p DECIMALS 2 , " netpr,
    lv_tax_amount1          TYPE bapi_rmwwr , " netpr,
    ls_status               TYPE zinw_t_status.
  DATA : invoicedocnumber    TYPE bapi_incinv_fld-inv_doc_no,
         invoicedocnumber_dn TYPE bapi_incinv_fld-inv_doc_no.
  DATA : lv_ebelp TYPE ebelp .
*** Header Data

  IF lv_ebeln IS NOT INITIAL.
    CLEAR   : headerdata.
    REFRESH : itemdata.
    SELECT ekko~ebeln,
           ekko~bukrs,
           ekko~waers,
           ekpo~ebelp,
           ekpo~mwskz,
           ekpo~menge,
           ekpo~meins,
           ekpo~netwr,
           ekpo~brtwr,
           ekpo~werks,              " Added by Suri : 31.03.2020
           matdoc~mblnr,
           matdoc~mjahr,
           matdoc~zeile,
           matdoc~gsber,
           a003~knumh,
           a003~kschl,
           konp~kbetr
           INTO TABLE @DATA(lt_debit)
           FROM ekko AS ekko
           INNER JOIN ekpo AS ekpo ON ekpo~ebeln = ekko~ebeln
           INNER JOIN matdoc AS matdoc ON matdoc~ebeln =  ekpo~ebeln AND matdoc~ebelp = ekpo~ebelp
           LEFT  OUTER JOIN a003 AS a003 ON a003~mwskz =  ekpo~mwskz AND a003~kschl IN ( 'JIIG' , 'JICG' , 'JISG'  )
           LEFT  OUTER JOIN konp AS konp ON konp~knumh =  a003~knumh
           WHERE ekko~ebeln = @lv_ebeln AND konp~loevm_ko = @space.

    CHECK lt_debit IS NOT INITIAL.
    SORT lt_debit BY mblnr zeile.
    DELETE ADJACENT DUPLICATES FROM lt_debit COMPARING ebeln ebelp.
    headerdata-doc_date     = sy-datum.
    headerdata-pstng_date   = sy-datum. "'20200301'.
    headerdata-bline_date   = sy-datum.
    headerdata-calc_tax_ind = 'X'.
    headerdata-ref_doc_no   = lv_ebeln.
    headerdata-secco = headerdata-business_place = '1000'.
*** Item Data
*** Start of changes Added by Suri : 31.03.2020
    DATA(lv_werks) = lt_debit[ 1 ]-werks.
    SELECT SINGLE gsber FROM t134g INTO headerdata-bus_area WHERE werks = lv_werks.
*** End of changes by Suri : 31.03.2020
    LOOP AT lt_debit ASSIGNING FIELD-SYMBOL(<ls_debit>).
      ls_itemdata-invoice_doc_item  = sy-tabix.
      ls_itemdata-po_number         = <ls_debit>-ebeln.
      ls_itemdata-po_item           = <ls_debit>-ebelp.
      ls_itemdata-ref_doc           = <ls_debit>-mblnr.
      ls_itemdata-ref_doc_year      = <ls_debit>-mjahr.
      ls_itemdata-ref_doc_it        = <ls_debit>-zeile.
      ls_itemdata-tax_code          = <ls_debit>-mwskz.
*      ls_itemdata-item_amount       = <ls_debit>-brtwr.
      ls_itemdata-item_amount       = <ls_debit>-netwr.
      ls_itemdata-quantity          = <ls_debit>-menge.
      ls_itemdata-po_unit           = <ls_debit>-meins.
      ls_itemdata-tax_code          = <ls_debit>-mwskz.
      headerdata-comp_code          = <ls_debit>-bukrs.
      headerdata-currency           = <ls_debit>-waers.


      APPEND ls_itemdata TO itemdata.
      CLEAR : ls_itemdata.
    ENDLOOP.
** Header Amount Calculation
    DATA: lv_tabix TYPE sy-tabix.
    DATA: lv_item_amount TYPE bapiwrbtr. " bapi_rmwwr..
    DATA(lt_tax_code) = itemdata.
    SORT : lt_tax_code , itemdata BY tax_code.
    DELETE ADJACENT DUPLICATES FROM lt_tax_code COMPARING tax_code.

    LOOP AT lt_tax_code ASSIGNING FIELD-SYMBOL(<ls_tax_code>).
      READ TABLE itemdata ASSIGNING FIELD-SYMBOL(<ls_item>) WITH KEY tax_code = <ls_tax_code>-tax_code.
      IF sy-subrc = 0.
        lv_tabix = sy-tabix.
        CLEAR : lv_item_amount.
        LOOP AT itemdata ASSIGNING <ls_item> FROM lv_tabix.
          IF <ls_item>-tax_code <> <ls_tax_code>-tax_code.
            EXIT.
          ELSE.
            ADD <ls_item>-item_amount TO lv_item_amount.
          ENDIF.
        ENDLOOP.
*** TAX CALCULATION
        READ TABLE lt_debit ASSIGNING <ls_debit> WITH KEY mwskz = <ls_tax_code>-tax_code.
        IF sy-subrc = 0.
          IF <ls_debit>-kschl = 'JIIG'.
            lv_tax_amount = lv_item_amount + ( ( lv_item_amount * <ls_debit>-kbetr ) / 1000 ) .
          ELSEIF <ls_debit>-kschl = 'JISG' OR <ls_debit>-kschl = 'JICG' .
            lv_tax_amount =   ( lv_item_amount * <ls_debit>-kbetr ) / 1000  .
            lv_tax_amount = lv_item_amount + lv_tax_amount + lv_tax_amount.
          ENDIF.
        ENDIF.

        headerdata-gross_amount = headerdata-gross_amount + lv_tax_amount.
      ENDIF.
    ENDLOOP.

    SORT itemdata BY invoice_doc_item..

    IF grid IS BOUND.
      CALL METHOD grid->refresh_table_display
        EXPORTING
          is_stable = ls_stable   " With Stable Rows/Columns
*         i_soft_refresh =     " Without Sort, Filter, etc.
        EXCEPTIONS
          finished  = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
      ENDIF.
    ENDIF.
*** Create Debit Note
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata       = headerdata                  " Header Data in Incoming Invoice (Create)
      IMPORTING
        invoicedocnumber = invoicedocnumber_dn            " Document Number of an Invoice Document
        fiscalyear       = fiscalyear                  " Fiscal Year
      TABLES
        itemdata         = itemdata                    " Item Data in Incoming Invoice
        return           = return.                 " Return Messages
*          vendoritemsplitdata = itemvendoritemsplitdata
*          taxdata             = itemtaxdata.
    READ TABLE return ASSIGNING FIELD-SYMBOL(<ls_return>) WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      lv_debit_note = invoicedocnumber_dn.
      lv_tex2 = 'Created Successfully' ..
      IF invoicedocnumber_dn IS NOT INITIAL .
        MESSAGE lv_tex2 TYPE  'S' .
      ENDIF.

*              IF lv_ebeln IS NOT INITIAL.
*                 CALL FUNCTION 'ZFM_PURCHASE_FORM1'
*                  EXPORTING
*                    lv_ebeln               = lv_ebeln
*                    vendor_return_po        = 'X' .
*              ENDIF.

    ELSE.
      LOOP AT return INTO lw_return2 WHERE type = 'E'.

        APPEND VALUE #( type  = lw_return2-type
                        id    = lw_return2-id
                        txtnr = lw_return2-number
                        msgv1 = lw_return2-message_v1
                        msgv2 = lw_return2-message_v2 ) TO it_log.

      ENDLOOP.

      PERFORM reverse_101.
      PERFORM delete_po.
      CLEAR: lv_ebeln, gv_mblnr_n  .

    ENDIF.
  ENDIF .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REVERSE_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reverse_101 .

  DATA: li_return1 TYPE STANDARD TABLE OF bapiret2.

  REFRESH li_return1.
  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = gv_mblnr_n
      matdocumentyear     = sy-datum+0(4)
      goodsmvt_pstng_date = sy-datum "'20200229' "
      goodsmvt_pr_uname   = sy-uname
    TABLES
      return              = li_return1.
  IF li_return1 IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_po .

  DATA: wa_purchaseorder TYPE bapimepoheader-po_number,
        it_poitem        TYPE STANDARD TABLE OF bapimepoitem,
        wa_poitem        TYPE bapimepoitem,
        it_poitemx       TYPE STANDARD TABLE OF bapimepoitemx,
        wa_poitemx       TYPE bapimepoitemx,
        it_return        TYPE TABLE OF bapiret2.


  IF lv_ebeln IS NOT INITIAL.

    wa_purchaseorder = lv_ebeln.

    SELECT ebeln,ebelp FROM ekpo INTO TABLE @DATA(it_po) WHERE ebeln = @lv_ebeln.

    LOOP AT it_po ASSIGNING FIELD-SYMBOL(<po>).

      wa_poitem-po_item     = <po>-ebelp.
      wa_poitem-delete_ind  = 'X'.

      wa_poitemx-po_item     = <po>-ebelp.
      wa_poitemx-po_itemx    = 'X'.
      wa_poitemx-delete_ind  = 'X'.

      APPEND wa_poitem TO it_poitem.
      APPEND wa_poitemx TO it_poitemx.

      CLEAR: wa_poitem,wa_poitemx.

    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = wa_purchaseorder
      TABLES
        return        = it_return
        poitem        = it_poitem
        poitemx       = it_poitemx.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM messages .
  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXCEPTIONS
      log_not_active       = 1
      wrong_identification = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.


  LOOP AT it_log ASSIGNING FIELD-SYMBOL(<log>).
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb = <log>-id
*       EXCEPTION_IF_NOT_ACTIVE       = 'X'
        msgty = <log>-type
        msgv1 = <log>-msgv1
        msgv2 = <log>-msgv2
        txtnr = <log>-txtnr.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDLOOP.
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      a_message         = 1
      e_message         = 2
      w_message         = 3
      i_message         = 4
      s_message         = 5
      deactivated_by_md = 6
      OTHERS            = 7.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXCEPTIONS
      inconsistent_range = 1
      no_messages        = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAL_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bal_validation .
  DATA: lv_tot TYPE dmbtr.

  SELECT SINGLE name,low FROM tvarvc INTO @DATA(wa_tvarvc) WHERE name = 'ZVENDOR_BAL_CHECK'.

  IF wa_tvarvc-low = 'X'.
    READ TABLE it_final INTO DATA(wa_fin) INDEX 1.
    SELECT SUM( dmbtr ) AS dmbtr_d FROM bsik INTO @DATA(lv_dmbtr_d) WHERE lifnr = @wa_fin-lifnr
                                                                  AND   shkzg = 'S'.
    SELECT SUM( dmbtr ) AS dmbtr_c FROM bsik INTO @DATA(lv_dmbtr_c) WHERE lifnr = @wa_fin-lifnr
                                                                  AND   shkzg = 'H'.

    DATA(total) = lv_dmbtr_c - lv_dmbtr_d.

    LOOP AT it_final INTO wa_fin.
      lv_tot = lv_tot + wa_fin-dvalue.
    ENDLOOP.

    IF lv_tot > total.
      MESSAGE 'Insufficient Vendor Balance.' TYPE 'E'.
    ENDIF.


  ENDIF.
ENDFORM.
