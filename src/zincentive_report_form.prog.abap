*&---------------------------------------------------------------------*
*& Include          ZINCENTIVE_REPORT_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

DATA: lv_dayno TYPE hrvsched-daynr.

SELECT vbrk~vbeln
       vbrk~fkdat
       vbrp~werks
       vbrp~posnr
       vbrp~fkimg
       vbrp~charg
       vbrp~matnr
       vbrp~netwr
       mara~matkl
       mara~brand_id
       makt~maktx
                  INTO TABLE it_data FROM vbrk AS vbrk INNER JOIN vbrp AS vbrp ON vbrk~vbeln = vbrp~vbeln
                                                       INNER JOIN mara AS mara ON mara~matnr = vbrp~matnr
                                                       INNER JOIN makt AS makt ON makt~matnr = mara~matnr
                                                       WHERE vbrk~fkdat IN s_date AND makt~spras = sy-langu
                                                       AND vbrp~werks IN s_werks AND vbrk~fkart <> 'S1'.


  SELECT matnr,charg,lifnr FROM mseg INTO TABLE @DATA(it_mseg) FOR ALL ENTRIES IN @it_data WHERE matnr = @it_data-matnr
                                                                                           AND   charg = @it_data-charg
                                                                                           AND   bwart IN ( '101' , '107' ).


  SELECT klah~class,klah~clint,kssk~objek,klah1~class AS matkl INTO TABLE @DATA(it_class)
                                                             FROM klah AS klah INNER JOIN kssk AS kssk ON ( kssk~clint EQ klah~clint )
                                                             INNER JOIN klah AS klah1 ON ( kssk~objek EQ klah1~clint )
                                                             FOR ALL ENTRIES IN @it_data WHERE klah~klart = '026' AND klah~wwskz = '0'
                                                             AND klah1~class EQ @it_data-matkl.

  SELECT * FROM zincentive  INTO TABLE it_zince WHERE datef GE s_date-low AND datet LE s_date-high AND pernr IN s_pernr AND del_ind <> 'X'
                                                                          AND werks IN s_werks.



 LOOP AT it_data ASSIGNING FIELD-SYMBOL(<data>).

    wa_fin-vbeln    = <data>-vbeln.
    wa_fin-fkdat    = <data>-fkdat.
    wa_fin-werks    = <data>-werks.
    wa_fin-posnr    = <data>-posnr.
    wa_fin-fkimg    = <data>-fkimg.
    wa_fin-charg    = <data>-charg.
    wa_fin-matnr    = <data>-matnr.
    wa_fin-netwr    = <data>-netwr.
    wa_fin-matkl    = <data>-matkl.
    wa_fin-brand_id = <data>-brand_id.
    wa_fin-maktx    = <data>-maktx.

    READ TABLE it_mseg ASSIGNING FIELD-SYMBOL(<mseg>) WITH KEY matnr = wa_fin-matnr charg = wa_fin-charg.
      IF sy-subrc = 0.
        wa_fin-lifnr = <mseg>-lifnr.
      ENDIF.
    READ TABLE it_class ASSIGNING FIELD-SYMBOL(<class>) WITH KEY matkl = wa_fin-matkl.
      IF sy-subrc = 0.
        wa_fin-group = <class>-class.
      ENDIF.
      CLEAR lv_dayno.
 CALL FUNCTION 'RH_GET_DATE_DAYNAME'
   EXPORTING
     langu                     = sy-langu
     date                      = wa_fin-fkdat
  IMPORTING
    daynr                     = lv_dayno
  EXCEPTIONS
    no_langu                  = 1
    no_date                   = 2
    no_daytxt_for_langu       = 3
    invalid_date              = 4
    OTHERS                    = 5
           .
 IF sy-subrc <> 0.
* Implement suitable error handling here
 ENDIF.

 CASE lv_dayno.
   WHEN '1'.
     wa_fin-monday  = 'X'.
   WHEN '2'.
     wa_fin-tuesday = 'X'.
   WHEN '3'.
     wa_fin-wednesday = 'X'.
   WHEN '4'.
     wa_fin-thursday = 'X'.
   WHEN '5'.
     wa_fin-friday = 'X'.
   WHEN '6'.
     wa_fin-saturday = 'X'.
   WHEN '7'.
     wa_fin-sunday = 'X'.
   WHEN OTHERS.
 ENDCASE.


   APPEND wa_fin TO it_fin.
   CLEAR wa_fin.

 ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOOP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM loop_data.

 DATA(it_ccode)   = it_zince.
 DATA(it_sstcode) = it_zince.
 DATA(it_batch)   = it_zince.
 DATA(it_brand)   = it_zince.
 DATA(it_group)   = it_zince.
 DATA(it_vendor)  = it_zince.

SORT it_ccode BY matkl .
DELETE it_ccode WHERE matkl IS INITIAL.

SORT it_sstcode BY matnr .
DELETE it_sstcode WHERE matnr IS INITIAL.

SORT it_batch BY charg .
DELETE it_batch WHERE charg IS INITIAL.

SORT it_brand BY brand .
DELETE it_brand WHERE brand IS INITIAL.

SORT it_group BY group1 .
DELETE it_group WHERE group1 IS INITIAL.

SORT it_vendor BY lifnr .
DELETE it_vendor WHERE lifnr IS INITIAL.

  IF it_ccode IS NOT INITIAL.
    LOOP AT it_ccode ASSIGNING FIELD-SYMBOL(<ccode>).
      LOOP AT it_fin ASSIGNING FIELD-SYMBOL(<fin>) WHERE matkl = <ccode>-matkl.

      IF <ccode>-monday    = 'X' AND  <fin>-monday = 'X' OR <ccode>-tuesday = 'X' AND  <fin>-tuesday = 'X' OR
        <ccode>-wednesday = 'X' AND  <fin>-wednesday = 'X' OR <ccode>-thursday = 'X' AND  <fin>-thursday = 'X' OR
        <ccode>-friday = 'X' AND  <fin>-friday = 'X' OR  <ccode>-saturday = 'X' AND  <fin>-saturday = 'X'
         OR <ccode>-sunday = 'X' AND  <fin>-sunday = 'X'.


        wa_final-werks = <fin>-werks.wa_final-matkl = <fin>-matkl. wa_final-matnr = <fin>-matnr.wa_final-maktx = <fin>-maktx.
        wa_final-charg = <fin>-charg.wa_final-brand = <fin>-brand_id.wa_final-group1 = <fin>-group.wa_final-lifnr = <fin>-lifnr.
        wa_final-pernr = <ccode>-pernr.wa_final-name  = <ccode>-name. wa_final-tar_pc = <ccode>-tar_pc.wa_final-tar_val = <ccode>-tar_val.
        wa_final-fkimg = <fin>-fkimg. wa_final-netwr = <fin>-netwr. wa_final-ince_pc = <ccode>-ince_pc. wa_final-ince_val = <ccode>-ince_val.

        IF <ccode>-ince_pc IS NOT INITIAL.
          wa_final-incentive  = <fin>-fkimg * <ccode>-ince_pc.
        ELSEIF <ccode>-ince_val IS NOT INITIAL.
          wa_final-incentive = ( <fin>-netwr * <ccode>-ince_val ) / 100 .
        ENDIF.

        APPEND wa_final TO it_final.
        CLEAR wa_final.
       ENDIF.
      ENDLOOP.
   ENDLOOP.
  ENDIF.


  IF it_sstcode IS NOT INITIAL.
    LOOP AT it_sstcode ASSIGNING FIELD-SYMBOL(<sst>).
      LOOP AT it_fin ASSIGNING FIELD-SYMBOL(<fin1>) WHERE matnr = <sst>-matnr.


        IF <sst>-monday    = 'X' AND  <fin1>-monday = 'X' OR <sst>-tuesday = 'X' AND  <fin1>-tuesday = 'X' OR
        <sst>-wednesday = 'X' AND  <fin1>-wednesday = 'X' OR <sst>-thursday = 'X' AND  <fin1>-thursday = 'X' OR
        <sst>-friday = 'X' AND  <fin1>-friday = 'X' OR <sst>-saturday = 'X' AND <fin1>-saturday = 'X' OR <sst>-sunday = 'X' AND  <fin1>-sunday = 'X'.

        wa_final-werks = <fin1>-werks.wa_final-matkl = <fin1>-matkl. wa_final-matnr = <fin1>-matnr.wa_final-maktx = <fin1>-maktx.
        wa_final-charg = <fin1>-charg.wa_final-brand = <fin1>-brand_id.wa_final-group1 = <fin1>-group.wa_final-lifnr = <fin1>-lifnr.
        wa_final-pernr = <sst>-pernr. wa_final-name  = <sst>-name. wa_final-tar_pc = <sst>-tar_pc.wa_final-tar_val = <sst>-tar_val.
        wa_final-fkimg = <fin1>-fkimg. wa_final-netwr = <fin1>-netwr. wa_final-ince_pc = <sst>-ince_pc. wa_final-ince_val = <sst>-ince_val.

        IF <sst>-ince_pc IS NOT INITIAL.
          wa_final-incentive  = <fin1>-fkimg * <sst>-ince_pc.
        ELSEIF <sst>-ince_val IS NOT INITIAL.
          wa_final-incentive = ( <fin1>-netwr * <sst>-ince_val ) / 100 .
        ENDIF.

        APPEND wa_final TO it_final.
        CLEAR wa_final.
       ENDIF.
      ENDLOOP.
   ENDLOOP.
  ENDIF.

  IF it_batch IS NOT INITIAL.
    LOOP AT it_batch ASSIGNING FIELD-SYMBOL(<batch>).
      LOOP AT it_fin ASSIGNING FIELD-SYMBOL(<fin2>) WHERE charg = <batch>-charg.

      IF <batch>-monday    = 'X' AND  <fin2>-monday = 'X'    OR <batch>-tuesday = 'X'     AND  <fin2>-tuesday  = 'X' OR
         <batch>-wednesday = 'X' AND  <fin2>-wednesday = 'X' OR <batch>-thursday = 'X'    AND  <fin2>-thursday = 'X' OR
         <batch>-friday    = 'X' AND  <fin2>-friday = 'X' OR <batch>-saturday = 'X' AND <fin2>-saturday = 'X' OR <batch>-sunday = 'X' AND <fin2>-sunday = 'X'.

        wa_final-werks = <fin2>-werks.wa_final-matkl = <fin2>-matkl. wa_final-matnr = <fin2>-matnr.wa_final-maktx = <fin2>-maktx.
        wa_final-charg = <fin2>-charg.wa_final-brand = <fin2>-brand_id.wa_final-group1 = <fin2>-group.wa_final-lifnr = <fin2>-lifnr.
        wa_final-pernr = <batch>-pernr. wa_final-name  = <batch>-name. wa_final-tar_pc = <batch>-tar_pc.wa_final-tar_val = <batch>-tar_val.
        wa_final-fkimg = <fin2>-fkimg. wa_final-netwr = <fin2>-netwr. wa_final-ince_pc = <batch>-ince_pc. wa_final-ince_val = <batch>-ince_val.


        IF <batch>-ince_pc IS NOT INITIAL.
          wa_final-incentive  = <fin2>-fkimg * <batch>-ince_pc.
        ELSEIF <batch>-ince_val IS NOT INITIAL.
         wa_final-incentive = ( <fin2>-netwr * <batch>-ince_val ) / 100 .
        ENDIF.

        APPEND wa_final TO it_final.
        CLEAR wa_final.
     ENDIF.
     ENDLOOP.
   ENDLOOP.
  ENDIF.

  IF it_brand IS NOT INITIAL.
    LOOP AT it_brand ASSIGNING FIELD-SYMBOL(<brand>).
      LOOP AT it_fin ASSIGNING FIELD-SYMBOL(<fin3>) WHERE brand_id = <brand>-brand.

      IF <brand>-monday    = 'X' AND  <fin3>-monday = 'X'    OR <brand>-tuesday = 'X'     AND  <fin3>-tuesday  = 'X' OR
         <brand>-wednesday = 'X' AND  <fin3>-wednesday = 'X' OR <brand>-thursday = 'X'    AND  <fin3>-thursday = 'X' OR
         <brand>-friday    = 'X' AND  <fin3>-friday = 'X' OR <brand>-saturday  = 'X' AND <fin3>-saturday = 'X' OR
         <brand>-sunday    = 'X' AND  <fin3>-sunday = 'X'.

        wa_final-werks = <fin3>-werks.wa_final-matkl = <fin3>-matkl. wa_final-matnr = <fin3>-matnr.wa_final-maktx = <fin3>-maktx.
        wa_final-charg = <fin3>-charg.wa_final-brand = <fin3>-brand_id. wa_final-group1 = <fin3>-group.wa_final-lifnr = <fin3>-lifnr.
        wa_final-pernr = <brand>-pernr. wa_final-name  = <brand>-name. wa_final-tar_pc = <brand>-tar_pc.wa_final-tar_val = <brand>-tar_val.
        wa_final-fkimg = <fin3>-fkimg. wa_final-netwr = <fin3>-netwr. wa_final-ince_pc = <brand>-ince_pc. wa_final-ince_val = <brand>-ince_val.


        IF <brand>-ince_pc IS NOT INITIAL.
          wa_final-incentive  = <fin3>-fkimg * <brand>-ince_pc.
        ELSEIF <brand>-ince_val IS NOT INITIAL.
          wa_final-incentive = ( <fin3>-netwr * <brand>-ince_val ) / 100 .
        ENDIF.

        APPEND wa_final TO it_final.
        CLEAR wa_final.
      ENDIF.
      ENDLOOP.
   ENDLOOP.
  ENDIF.

  IF it_group IS NOT INITIAL.
    LOOP AT it_brand ASSIGNING FIELD-SYMBOL(<grp>).
      LOOP AT it_fin ASSIGNING FIELD-SYMBOL(<fin4>) WHERE group = <grp>-group1.

      IF <grp>-monday    = 'X' AND  <fin4>-monday = 'X'    OR <grp>-tuesday = 'X'     AND  <fin4>-tuesday  = 'X' OR
         <grp>-wednesday = 'X' AND  <fin4>-wednesday = 'X' OR <grp>-thursday = 'X'    AND  <fin4>-thursday = 'X' OR
         <grp>-friday    = 'X' AND  <fin4>-friday = 'X' OR <grp>-saturday  = 'X' AND  <fin4>-saturday = 'X' OR <grp>-sunday = 'X' AND <fin4>-sunday = 'X'.

*
        wa_final-werks = <fin4>-werks.wa_final-matkl = <fin4>-matkl. wa_final-matnr = <fin4>-matnr.wa_final-maktx = <fin4>-maktx.
        wa_final-charg = <fin4>-charg.wa_final-brand = <fin4>-brand_id.wa_final-group1 = <fin4>-group.wa_final-lifnr = <fin4>-lifnr.
        wa_final-pernr = <grp>-pernr. wa_final-name  = <grp>-name. wa_final-tar_pc = <grp>-tar_pc.wa_final-tar_val = <grp>-tar_val.
        wa_final-fkimg = <fin4>-fkimg. wa_final-netwr = <fin4>-netwr. wa_final-ince_pc = <grp>-ince_pc. wa_final-ince_val = <grp>-ince_val.
        IF <grp>-ince_pc IS NOT INITIAL.
          wa_final-incentive  = <fin4>-fkimg * <grp>-ince_pc.
        ELSEIF <grp>-ince_val IS NOT INITIAL.
          wa_final-incentive = ( <fin4>-netwr * <grp>-ince_val ) / 100 .
        ENDIF.

        APPEND wa_final TO it_final.
        CLEAR wa_final.
      ENDIF.
      ENDLOOP.
   ENDLOOP.
  ENDIF.

  IF it_vendor IS NOT INITIAL.
    LOOP AT it_vendor ASSIGNING FIELD-SYMBOL(<ven>).
      LOOP AT it_fin ASSIGNING FIELD-SYMBOL(<fin5>) WHERE lifnr = <ven>-lifnr.

      IF <ven>-monday    = 'X' AND  <fin5>-monday = 'X'    OR <ven>-tuesday = 'X'     AND  <fin5>-tuesday  = 'X' OR
         <ven>-wednesday = 'X' AND  <fin5>-wednesday = 'X' OR <ven>-thursday = 'X'    AND  <fin5>-thursday = 'X' OR
         <ven>-friday    = 'X' AND  <fin5>-friday = 'X' OR <ven>-saturday = 'X' AND <fin5>-saturday = 'X' OR
         <ven>-sunday    = 'X' AND  <fin5>-sunday = 'X'.

        wa_final-werks = <fin5>-werks.wa_final-matkl = <fin5>-matkl. wa_final-matnr = <fin5>-matnr.wa_final-maktx = <fin5>-maktx.
        wa_final-charg = <fin5>-charg.wa_final-brand = <fin5>-brand_id.wa_final-group1 = <fin5>-group.wa_final-lifnr = <fin5>-lifnr.
        wa_final-pernr = <ven>-pernr. wa_final-name  = <ven>-name. wa_final-tar_pc = <ven>-tar_pc.wa_final-tar_val = <ven>-tar_val.
        wa_final-fkimg = <fin5>-fkimg. wa_final-netwr = <fin5>-netwr. wa_final-ince_pc = <ven>-ince_pc. wa_final-ince_val = <ven>-ince_val.

        IF <ven>-ince_pc IS NOT INITIAL.
          wa_final-incentive  = <fin5>-fkimg * <ven>-ince_pc.
        ELSEIF <ven>-ince_val IS NOT INITIAL.
          wa_final-incentive = ( <fin5>-netwr * <ven>-ince_val ) / 100 .
        ENDIF.

        APPEND wa_final TO it_final.
        CLEAR wa_final.

       ENDIF.
      ENDLOOP.
   ENDLOOP.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .

  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-seltext_m = 'Plant'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MATKL'.
  wa_fieldcat-seltext_m = 'Category Code'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-seltext_m = 'Article'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MAKTX'.
  wa_fieldcat-seltext_m = 'Description'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'CHARG'.
  wa_fieldcat-seltext_m = 'Batch'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BRAND'.
  wa_fieldcat-seltext_m = 'Brand'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'GROUP1'.
  wa_fieldcat-seltext_m = 'Group'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-seltext_m = 'Vendor'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'PERNR'.
  wa_fieldcat-seltext_m = 'Employee'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME'.
  wa_fieldcat-seltext_m = 'Emp.Name'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'INCE_PC'.
  wa_fieldcat-seltext_m = 'Inc/Pc'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'INCE_VAL'.
  wa_fieldcat-seltext_m = 'Inc/Val'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'FKIMG'.
  wa_fieldcat-seltext_m = 'Billed Qty'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NETWR'.
  wa_fieldcat-seltext_m = 'Billed Value'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'INCENTIVE'.
  wa_fieldcat-seltext_m = 'Incentive'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = sy-repid
*      i_callback_html_top_of_page = 'TOP-OF-PAGE'
      it_fieldcat                 = it_fieldcat
      i_save                      = 'A'
    TABLES
      t_outtab                    = it_final
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.




ENDFORM.
