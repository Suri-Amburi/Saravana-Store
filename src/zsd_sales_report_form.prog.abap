*&---------------------------------------------------------------------*
*& Include          ZSD_SALES_REPORT_FORM
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  IF s_class IS NOT INITIAL.
    SELECT
      clint
      klart
      class
      vondt
      bisdt
      wwskz
      FROM klah INTO TABLE it_klah
      WHERE wwskz = '0' AND class IN s_class AND klart = '026' .
  ENDIF.
  BREAK ppadhy.
  SELECT
    mseg~mblnr,
    mseg~mjahr,
    mseg~zeile,
    mseg~line_id,
    mseg~budat_mkpf,
    mseg~matnr,
    mseg~bwart,
    mseg~werks,
    mseg~menge,
    mseg~dmbtr,
    mara~matkl,
    mara~zzprice_frm,
    mara~zzprice_to,
    mara~size1,
    makt~maktx
*    vbrp~PRSDT,
*    vbrp~netwr
    FROM mseg INNER JOIN mara AS mara ON mara~matnr = mseg~matnr
    INNER JOIN makt AS makt ON mara~matnr = makt~matnr
*            INNER JOIN vbrp as vbrp on vbrp~matnr = mseg~matnr AND  vbrp~werks = mseg~werks AND vbrp~prsdt = mseg~BUDAT_MKPF

    WHERE budat_mkpf IN @s_budat
    AND werks IN @s_plant AND matkl IN @s_matkl  AND   zzprice_frm IN @s_from
    AND   zzprice_to   IN @r_to
    AND   size1 IN @s_size
    AND bwart IN ('251','252') INTO TABLE @DATA(it_mseg).
  DELETE ADJACENT DUPLICATES FROM it_mseg COMPARING mblnr.

*    SELECT
*           MSEG~MBLNR,
*           MSEG~MJAHR,
*           MSEG~ZEILE,
*           MSEG~BUDAT_MKPF,
*           MSEG~MATNR,
*           MSEG~BWART,
*           MSEG~WERKS,
*           MSEG~MENGE,
*           MSEG~DMBTR,
*           MARA~MATKL,
*          vbrp~PRSDT,
*           vbrp~netwr
**        vbrp~werks
*           FROM mseg as mseg
*          LEFT OUTER JOIN mara as mara on MARA~MATNR = MSEG~MATNR
*          LEFT OUTER JOIN vbrp as vbrp on vbrp~matnr = mseg~matnr AND vbrp~PRSDT = mseg~BUDAT_MKPF
**      INTO TABLE @data(it_mseg2)
*      WHERE BUDAT_MKPF IN @S_BUDAT
*      AND mseg~WERKS IN @S_PLANT
*  AND BWART IN ('251','252') INTO TABLE @DATA(IT_MSEG2).

*DElete ADJACENT DUPLICATES FROM it_mseg2 COMPARING mblnr.

  IF it_mseg IS NOT INITIAL AND s_budat IS NOT INITIAL.
    SELECT
    vbeln,
    posnr,
    fkimg,
    netwr,
    prsdt,
    werks,
    matnr,
    mwsbp                        " ADDED BY LIKHITHA
    FROM vbrp INTO TABLE @DATA(it_vbrp)
    FOR ALL ENTRIES IN @it_mseg
    WHERE werks = @it_mseg-werks AND prsdt = @it_mseg-budat_mkpf AND matnr = @it_mseg-matnr.
  ENDIF.

  IF it_mseg IS NOT INITIAL AND s_budat IS INITIAL.
    SELECT
    vbeln
    posnr
    fkimg
    netwr
    prsdt
    werks
    matnr
    mwsbp                        " ADDED BY LIKHITHA
    FROM vbrp INTO TABLE it_vbrp
    FOR ALL ENTRIES IN it_mseg
    WHERE matnr = it_mseg-matnr AND werks = it_mseg-werks .
  ENDIF.
*******************    ADDED ON (19-3-20)   ******************
*loop at it_vbrp INTO DATA(wa_vbrp2) WHERE matnr = MSEG-MATNR.
*      wa_fin-netwr = wa_fin-netwr + wa_vbrp2-netwr.
*      APPEND wa_fin TO it_fin.
*      clear : wa_fin.
*      endloop.

*LOOP AT IT_VBRP ASSIGNING FIELD-SYMBOL(<WA_ABC>) ." WHERE  MATNR = MSEG-MATNR.
*
* wa_vbrp1-NETWR      = <WA_ABC>-NETWR + wa_vbrp1-NETWR  .
* wa_vbrp1-MWSBP      = <WA_ABC>-MWSBp + wa_vbrp1-MWSBP.
* wa_vbrp1-matnr =  <WA_ABC>-matnr.
* wa_vbrp1-WERKS = <WA_ABC>-WERKS.
* wa_vbrp1-prsdt = <WA_ABC>-prsdt.
* APPEND : WA_vbrp1 TO IT_vbrp1.
* CLEAR : WA_vbrp1.
*  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM it_vbrp1 COMPARING matnr.
  SELECT  klah~class,
        klah~clint,
        kssk~objek,
        klah1~class AS matkl INTO TABLE @DATA(lt_data)
        FROM klah AS klah INNER JOIN kssk AS kssk ON kssk~clint = klah~clint
        INNER JOIN klah AS klah1 ON kssk~objek = klah1~clint
          WHERE klah~klart = '026' AND klah~class IN @s_class AND klah~wwskz = '0'.
  READ TABLE it_mseg ASSIGNING FIELD-SYMBOL(<wa_mseg>) INDEX 1.

  DATA :ls_data LIKE LINE OF lt_data.
*  data : SLNO(100)    TYPE C.
*******  ****************** added on (25.3..20)   *****************

  LOOP AT it_vbrp INTO DATA(wa_vbrp) ."WHERE WERKS = WA_MSEG-WERKS AND  MATNR = WA_MSEG-MATNR AND PRSDT = WA_MSEG-BUDAT_MKPF.
    slno = slno + 1.
    wa_final-slno = slno .
    IF sy-subrc = 0.
      wa_final-mwsbp = wa_final-mwsbp + wa_vbrp-mwsbp.
      wa_final-netwr = wa_final-netwr + wa_vbrp-netwr  .
      wa_final-fkimg = wa_final-fkimg + wa_vbrp-fkimg .
      wa_final-tot_price = wa_final-netwr  + wa_final-mwsbp.
    ENDIF.
    IF s_budat IS NOT INITIAL.
      READ TABLE it_mseg INTO DATA(wa_mseg) WITH KEY  werks = wa_vbrp-werks matnr = wa_vbrp-matnr budat_mkpf = wa_vbrp-prsdt.

      IF sy-subrc = 0.
*       WA_FINAL-MENGE       = WA_FINAL-MENGE + WA_MSEG-MENGE    .    " commenetd
        wa_final-matkl       = wa_mseg-matkl.
        wa_final-matnr       = wa_mseg-matnr.
        wa_final-maktx       = wa_mseg-maktx.
        wa_final-zzprice_frm = wa_mseg-zzprice_frm.
        wa_final-zzprice_to  = wa_mseg-zzprice_to .
        wa_final-size1       = wa_mseg-size1.
      ENDIF .
    ENDIF .
    IF s_budat IS INITIAL.
      READ TABLE it_mseg INTO wa_mseg WITH KEY  werks = wa_vbrp-werks matnr = wa_vbrp-matnr .

      IF sy-subrc = 0.
*       WA_FINAL-MENGE       = WA_FINAL-MENGE + WA_MSEG-MENGE    .    " commenetd
        wa_final-matkl       = wa_mseg-matkl.
        wa_final-matnr       = wa_mseg-matnr.
        wa_final-maktx       = wa_mseg-maktx.
        wa_final-zzprice_frm = wa_mseg-zzprice_frm.
        wa_final-zzprice_to  = wa_mseg-zzprice_to .
        wa_final-size1       = wa_mseg-size1.
      ENDIF .
    ENDIF .
    DELETE it_vbrp WHERE vbeln = wa_vbrp-vbeln AND posnr = wa_vbrp-posnr.
*********************  end (25.03.20)    ********************




*  LOOP AT IT_MSEG INTO DATA(WA_MSEG) ."WHERE matkl = wa_klah-class .                  "WHERE MATNR = WA_MARA-MATNR.
*    SLNO = SLNO + 1.
*    wa_final-slno = slno.
*    WA_FINAL-MENGE       = WA_FINAL-MENGE + WA_MSEG-MENGE    .    " commenetd
*    WA_FINAL-MATKL = WA_MSEG-MATKL.
*    WA_FINAL-MATNR    = WA_MSEG-MATNR.
*
**    loop at IT_VBRP INTO DATA(WA_VBRP) WHERE WERKS = WA_MSEG-WERKS AND  MATNR = WA_MSEG-MATNR AND PRSDT = WA_MSEG-BUDAT_MKPF.
*    READ TABLE IT_VBRP INTO DATA(WA_VBRP) WITH KEY  WERKS = WA_MSEG-WERKS
*                                                    MATNR = WA_MSEG-MATNR
*                                                   PRSDT = WA_MSEG-BUDAT_MKPF.
*    IF SY-SUBRC = 0.
*      WA_FINAL-MWSBP = WA_FINAL-MWSBP + WA_VBRP-MWSBP.
*      WA_FINAL-NETWR      = WA_FINAL-NETWR + WA_VBRP-NETWR  .
**      wa_final-NETWR = wa_vbrp2-netwr.
**      APPEND WA_FINAL TO IT_FINAL.
**    CLEAR : WA_FINAL   .
*    ENDIF.




*    endloop.
*    data : v_lines TYPE c.
*    DESCRIBE TABLE it_vbrp LINES v_lines.

*    loop at it_vbrp INTO DATA(wa_vbrp2) WHERE matnr = WA_MSEG-MATNR.
*      wa_fin-netwr = wa_fin-netwr + wa_vbrp2-netwr.
*      APPEND wa_fin TO it_fin.
*      clear : wa_fin.
*      endloop.

    READ TABLE lt_data INTO ls_data WITH KEY matkl = wa_mseg-matkl."               WITH KEY MATNR = WA_MSEG-MATNR .
    IF sy-subrc = 0.
      wa_final-class = ls_data-class.
    ENDIF.

    APPEND wa_final TO it_final.
    CLEAR : wa_final  , wa_mseg ,wa_vbrp.
  ENDLOOP.
  BREAK ppadhy.
  IF s_class IS NOT INITIAL.
    it_final1[] = it_final.                                             "IT_FINAL1[] = LT_DATA.
    SORT it_final1 BY class.
    DELETE ADJACENT DUPLICATES FROM it_final1 COMPARING class.
    LOOP AT it_klah INTO wa_klah.
      wa_final2-class = wa_klah-class.
*    WA_FINAL2-MENGE = wa_mseg-menge.
      slno = slno + 1.
      wa_final2-slno = slno .
      LOOP AT it_final1 INTO wa_final1 WHERE class = wa_klah-class.
*     LOOP AT IT_FINAL INTO WA_FINAL WHERE CLASS = WA_FINAL1-CLASS.
        LOOP AT it_final INTO wa_final WHERE class = wa_final1-class.

          wa_final2-matnr = wa_final-matnr.
          wa_final2-matkl = wa_final-matkl.
          wa_final2-maktx = wa_final-maktx.
          wa_final2-zzprice_frm = wa_final-zzprice_frm.
          wa_final2-zzprice_to  = wa_final-zzprice_to.
          menge = menge + wa_final-menge.
          fkimg = fkimg + wa_final-fkimg.
*        DMBTR = DMBTR + WA_FINAL-DMBTR.
          netwr = netwr + wa_final-netwr.
          mwsbp  = mwsbp + wa_final-mwsbp.
          lvvar =  wa_final-netwr + wa_final-mwsbp.
        ENDLOOP.
      ENDLOOP.
      wa_final2-menge = menge.
      wa_final2-fkimg = fkimg.
      wa_final2-netwr = netwr.
      wa_final2-mwsbp = mwsbp.".+ WA_FINAL2-NETWR .
      wa_final2-lvvar = lvvar.
      wa_final2-tot_price = wa_final2-netwr  + wa_final2-mwsbp.
      APPEND wa_final2 TO it_final2.
      CLEAR : menge , netwr , wa_final2 , mwsbp ,wa_final1,fkimg."DMBTR
    ENDLOOP.
  ELSE.
    it_final2[] = it_final.
  ENDIF.

  wa_fcat-fieldname = 'SLNO'.
  wa_fcat-seltext_m = 'Serial No'.
  APPEND wa_fcat TO it_fcat.
  CLEAR  wa_fcat.

  wa_fcat-fieldname = 'CLASS'.
  wa_fcat-seltext_m = 'Group'.
  APPEND wa_fcat TO it_fcat.
  CLEAR  wa_fcat.

  wa_fcat-fieldname = 'MATKL'.
  wa_fcat-seltext_m = 'Category Number'.
  APPEND  wa_fcat TO it_fcat.
  CLEAR : wa_fcat .

  wa_fcat-fieldname = 'MATNR'.
  wa_fcat-seltext_m = 'SST No'.
  APPEND wa_fcat TO it_fcat.
  CLEAR : wa_fcat .

  APPEND VALUE #( fieldname = 'MAKTX'       seltext_m = 'Description' ) TO  it_fcat.
  APPEND VALUE #( fieldname = 'ZZPRICE_FRM' seltext_m = 'From Price' )  TO  it_fcat.
  APPEND VALUE #( fieldname = 'ZZPRICE_TO'  seltext_m = 'To Price' )    TO  it_fcat.

  wa_fcat-fieldname = 'FKIMG'.
  wa_fcat-seltext_m = 'Quantity'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR  wa_fcat.

*  WA_FCAT-FIELDNAME = 'MENGE'.
*  WA_FCAT-SELTEXT_M = 'QUANTITY'.
*  WA_FCAT-DO_SUM = 'X'.
*  APPEND WA_FCAT TO IT_FCAT.
*  CLEAR  WA_FCAT.

  wa_fcat-fieldname = 'NETWR'.                 "'DMBTR'.
  wa_fcat-seltext_m = 'Price'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR  wa_fcat.

  wa_fcat-fieldname = 'MWSBP'.
*  WA_fcat-tabname   = 'IT_FINAL'.
  wa_fcat-seltext_m = 'Tax Amount'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR  wa_fcat.

  wa_fcat-fieldname = 'TOT_PRICE'.
  wa_fcat-seltext_m = 'Total Price'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR  wa_fcat.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
*     I_GRID_SETTINGS    =
*     IS_LAYOUT          =
      it_fieldcat        = it_fcat[]
      i_default          = 'X'
      i_save             = 'A'
*     IS_VARIANT         =
*     IT_EVENTS          = IT_EVENT
    TABLES
      t_outtab           = it_final2
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
