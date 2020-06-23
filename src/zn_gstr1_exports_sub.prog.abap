*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_EXPORTS_SUB
*&---------------------------------------------------------------------*

FORM select_querry .
  SELECT   vbeln
           fkart
           vkorg
           vtweg
           knumv
           fkdat
           land1
           regio
           kunrg
           kunag
           spart
           xblnr
           exnum
           gjahr
           waerk
           kurrf
           belnr
           FROM vbrk
           INTO TABLE it_vbrk
           WHERE  fkdat IN s_budat
           AND  bukrs IN s_bukrs
           AND kunag IN s_kunag
*           AND  FKART IN ( 'ZEXO','ZEXD','ZEXS' )
*           AND  fkart IN ( 'ZEXP' , 'ZSAM' )         " COMMENTED ON (16-03-20)
           AND FKART = 'FP'                           " ADDED ON (16-03-20)
           AND  fksto NE 'X'.

  SORT it_vbrk[] BY vbeln fkdat.
  DELETE it_vbrk WHERE belnr IS INITIAL.
  DELETE it_vbrk WHERE waerk = 'INR'.

  IF it_vbrk[] IS NOT INITIAL.
    SELECT vbeln
           netwr
           posnr
           matnr
           arktx
           werks
           fkimg
           vrkme
           spart
           vtweg_auft
           waerk
           aubel
           FROM vbrp INTO TABLE it_vbrp
           FOR ALL ENTRIES IN it_vbrk
           WHERE vbeln = it_vbrk-vbeln
           AND   werks IN s_werks.

    SORT it_vbrp[] BY vbeln posnr.
    DELETE it_vbrp WHERE fkimg IS INITIAL.

**    SELECT KNUMV
**           KPOSN
**           KSCHL
**           KBETR
**           KWERT
**           FROM KONV
**           INTO TABLE IT_KONV
**           FOR ALL ENTRIES IN IT_VBRK[]
**           WHERE KNUMV  = IT_VBRK-KNUMV
**           AND   KSCHL IN ('JOSG','JOCG','JOIG','ZACP','ZACA','ZCOM','ZYMM',
**                           'ZCMM','ZPFP','ZPNF','ZINA','ZINS','ZFRT','ZFRA','ZFRE','ZDCD','ZBP1','ZOSC','P101').
    SELECT knumv
           kposn
           kschl
           knumh
           kopos
           kwert
           kbetr FROM prcd_elements INTO TABLE it_konv
           FOR ALL ENTRIES IN it_vbrk
           WHERE knumv  = it_vbrk-knumv
*           AND   kschl IN ( 'ZCPO','ZPAC','ZPA%','ZINC','ZIN%','ZFCH','ZFC%','ZPRI',
*                            'JOSG','JOCG','JOIG','JOUG','EK02','VPRS','ZSPA' ).
            AND  kschl IN ( 'ZINP', 'ZINV', 'ZFRV', 'ZFRP', 'ZCHA', 'ZRBT','JOSG','JOCG','JOIG','JOUG' , 'EXIG' , 'ZCES' ,'ZTCS', 'ZINO', 'ZINS' ,'ZFRT',
                            'ZFRM', 'ZOPS', 'ZOPM', 'DIFF', 'ZDIS' ,'ZDIF' ,'ZDIP' , 'ZPAC', 'ZBAS' ) .

    SORT it_konv[] BY knumv kposn.

    SELECT * FROM tvfkt INTO TABLE it_tvfkt
             FOR ALL ENTRIES IN it_vbrk
             WHERE fkart = it_vbrk-fkart
               AND spras = 'EN'.

**    IF S_HSN IS INITIAL.
    SELECT matnr
           werks
           steuc FROM marc INTO TABLE it_marc
           FOR ALL ENTRIES IN it_vbrp
           WHERE matnr = it_vbrp-matnr AND werks = it_vbrp-werks.
*    ENDIF.

    SELECT matnr
           maktx FROM makt INTO TABLE it_makt
           FOR ALL ENTRIES IN it_vbrp
           WHERE matnr = it_vbrp-matnr.


*
*    SELECT      VBELN
*                AUDAT
*                BSTNK
*                BSTDK FROM VBAK INTO TABLE IT_VBAK FOR ALL ENTRIES IN IT_VBRP WHERE VBELN = IT_VBRP-AUBEL .
    SELECT vbeln
           posnr
           parvw
           adrnr
           ablad
            FROM vbpa INTO TABLE it_vbpa1 FOR ALL ENTRIES IN it_vbrp WHERE vbeln = it_vbrp-aubel AND ablad NE ' '  .

  ENDIF.
ENDFORM.                    " SELECT_QUERRY
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
  DATA : tdobname TYPE tdobname .
  DATA : it_line TYPE TABLE OF tline .
  DATA : wa_line TYPE tline .
  DATA : lv_desc TYPE string .

  DATA : n TYPE int4.
  LOOP AT it_vbrp INTO wa_vbrp.
    CLEAR:wa_makt,wa_tvfkt,wa_vbrk.
    n = n + 1.
    wa_fin-slno = n.
    wa_fin-matnr  = wa_vbrp-matnr.   "CHANGES BY KRSIHNA 29.11.2017
    wa_fin-vbeln  = wa_vbrp-vbeln.
    wa_fin-posnr  = wa_vbrp-posnr.
*    WA_FIN-NETWR  = WA_VBRP-NETWR.
    wa_fin-fkimg  = wa_vbrp-fkimg.
    wa_fin-vrkme  = wa_vbrp-vrkme.

*    READ TABLE IT_VBPA1 INTO WA_VBPA1 WITH KEY VBELN = WA_VBRP-AUBEL .
*    IF SY-SUBRC EQ 0 .
*      WA_FIN-ABLAD = WA_VBPA1-ABLAD .
*    ENDIF .
    READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = wa_vbrp-vbeln.
    IF sy-subrc = 0.
      wa_fin-fkdat     =  wa_vbrk-fkdat.    "CHANGES BY KRISHNA 29.11.2017
      wa_fin-blart     =  wa_vbrk-fkart.
      wa_fin-invn = wa_vbrk-xblnr .  "added by akankshya 20.03.2019
      wa_fin-belnr = wa_vbrk-belnr. "*---->>> ADDED BY  mumair <<< 07.11.2019 13:33:31
*      IF WA_FIN-NETWR IS NOT INITIAL .
*      WA_FIN-NETWR = WA_VBRP-NETWR  .
*      ENDIF .
    ENDIF.

    READ TABLE it_marc INTO wa_marc WITH KEY matnr = wa_vbrp-matnr.
    IF sy-subrc = 0.
      wa_fin-steuc  = wa_marc-steuc.                                         ""HSN/SAC
    ENDIF.
**************************************************************************
    tdobname = wa_vbrp-vbeln .

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = 'ZH13'
        language                = sy-langu
        name                    = tdobname
        object                  = 'VBBK'
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
* IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = it_line
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT it_line INTO wa_line WHERE tdline IS NOT INITIAL.
      CONCATENATE wa_fin-pcode wa_line-tdline INTO wa_fin-pcode SEPARATED BY ' ' .
      CLEAR : it_line,wa_line .
    ENDLOOP .


    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = 'ZH14'
        language                = sy-langu
        name                    = tdobname
        object                  = 'VBBK'
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
* IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = it_line
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT it_line INTO wa_line WHERE tdline IS NOT INITIAL.
      CONCATENATE wa_fin-sbill wa_line-tdline INTO wa_fin-sbill SEPARATED BY ' ' .
      CLEAR : it_line,wa_line .
    ENDLOOP .

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = 'ZH15'
        language                = sy-langu
        name                    = tdobname
        object                  = 'VBBK'
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
* IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = it_line
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT it_line INTO wa_line WHERE tdline IS NOT INITIAL.
      CONCATENATE wa_fin-sdate wa_line-tdline INTO wa_fin-sdate SEPARATED BY ' ' .
      CLEAR : it_line,wa_line .
    ENDLOOP .

*********************************************************************
    READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = wa_vbrp-vbeln.
    LOOP AT it_konv INTO wa_konv  WHERE knumv = wa_vbrk-knumv
                                    AND kposn = wa_vbrp-posnr.
      CASE wa_konv-kschl.
        WHEN 'JOSG'.
          wa_fin-sgst  = wa_konv-kwert.
          wa_fin-sgstp = wa_konv-kbetr .
          IF wa_fin-sgst IS NOT INITIAL .
            wa_fin-sgst = wa_fin-sgst * wa_vbrk-kurrf .
          ENDIF .
        WHEN 'JOCG'.
          wa_fin-cgst  = wa_konv-kwert.
          wa_fin-cgstp = wa_konv-kbetr .
          IF wa_fin-cgst IS NOT INITIAL .
            wa_fin-cgst = wa_fin-cgst * wa_vbrk-kurrf .
          ENDIF .
        WHEN 'JOIG'.
          wa_fin-igst  = wa_konv-kwert.
          wa_fin-igstp = wa_konv-kbetr .
          IF wa_fin-igst IS NOT INITIAL .
            wa_fin-igst = wa_fin-igst * wa_vbrk-kurrf .
          ENDIF .
*        WHEN 'JOUG'.
*          WA_FIN-UGST  = WA_KONV-KWERT.
*          WA_FIN-UGSTP = WA_KONV-KBETR .
*          IF WA_FIN-UGST IS NOT INITIAL .
*            WA_FIN-UGST = WA_FIN-UGST * WA_VBRK-KURRF .
*          ENDIF .
        WHEN 'EXIG'.
          wa_fin-igst  = wa_konv-kwert.
          wa_fin-igstp = wa_konv-kbetr .
          IF wa_fin-igst IS NOT INITIAL .
            wa_fin-igst = wa_fin-igst * wa_vbrk-kurrf .
          ENDIF .

        WHEN 'ZCES'.
          wa_fin-cess  = wa_konv-kwert  * wa_vbrk-kurrf.
        WHEN 'ZBAS'.
          basval   = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZDIS'.
          tdiscnt  = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZDIF'.
          tdiscnt1  = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZDIP'.
          tdiscnt2  = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZPAC'.
          packing1  = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZFRT'.
          fright1   = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZFRM'.
          fright2   = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZINS'.
          insurns1  = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZINO'.
          insurns2  = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZOPS'.
          packing2  = packing2 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZOPM'.
          packing2  = packing2 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZTCS'.
          fright3   = wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'DIFF'.
          othrs1    = wa_konv-kwert * wa_vbrk-kurrf.
      ENDCASE.
      CLEAR:wa_konv.
    ENDLOOP.

*********************************Purchase Text********************************************

    DATA: lv_matnr TYPE char18.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_vbrp-matnr
      IMPORTING
        output = lv_matnr.

    tdobname = lv_matnr.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = 'BEST'
        language                = 'E'
        name                    = tdobname
        object                  = 'MATERIAL'
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
*   IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = it_line
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT it_line INTO wa_line WHERE tdline IS NOT INITIAL.
      CONCATENATE lv_desc wa_line-tdline INTO lv_desc SEPARATED BY ' '  .
    ENDLOOP .
    CLEAR : it_line,wa_line .


    wa_fin-maktx =  lv_desc .

    READ TABLE it_makt INTO wa_makt WITH KEY  matnr = wa_vbrp-matnr.
    IF sy-subrc = 0.
      wa_fin-maktx1   = wa_makt-maktx.
      IF wa_fin-maktx IS INITIAL .
        wa_fin-maktx   = wa_makt-maktx.                                        ""Description of Goods / Service
      ENDIF .
    ENDIF.


********************************************************************************************

*    WA_FIN-TAXBLVAL =  SUBCON + SERVIC + INSURNS1 + INSURNS2 + FRIGHT1  + FRIGHT2 + FRIGHT3 + PACKING1 + PACKING2 + OTHRS1
*                       + OTHRS2 + OTHRS3 + OTHRS4 + OTHRS5 + TDISCNT + BASVAL + ZSTO.

    wa_fin-taxblval = ( basval +  packing1 + tdiscnt + tdiscnt1 + tdiscnt2 ).
    wa_fin-other   =   fright1 + fright2 + fright3 + insurns1 + insurns2 + packing2 + othrs1.

*    WA_FIN-TOTINV   = WA_FIN-NETWR + WA_FIN-SGST + WA_FIN-CGST + WA_FIN-IGST + WA_FIN-UGST + WA_FIN-CESS .

    wa_fin-totinv   = wa_fin-taxblval + wa_fin-sgst + wa_fin-cgst + wa_fin-igst  + wa_fin-other + wa_fin-cess .  "+ WA_FIN-UGST

    IF wa_fin-sgst IS NOT INITIAL OR wa_fin-cgst IS NOT INITIAL OR wa_fin-igst IS NOT INITIAL.
      wa_fin-extype = 'WPAY'.
    ELSE.
      wa_fin-extype = 'WOPAY'.
    ENDIF.



*    READ TABLE IT_VBRK INTO WA_VBRK WITH KEY VBELN = WA_VBRP-VBELN.
*    IF SY-SUBRC EQ 0 .
*      IF WA_FIN-TOTINV IS NOT INITIAL .
*        WA_FIN-TOTINV = WA_FIN-TOTINV * WA_VBRK-KURRF .
*      ENDIF .
*    ENDIF .
**    IF ( wa_vbrk-fkart eq 'ZOEX' OR wa_vbrk-fkart eq 'ZFEX' ) AND WA_VBRK-WAERK NE 'INR'.   "CHANGES BUY KRISHNA 05.12.2017
**      WA_FIN-TOTINV = WA_FIN-TOTINV * WA_VBRK-KURRF.
**    ENDIF.

    CLEAR:othrs1,othrs2,othrs3,othrs4,othrs5,packing1,packing2,fright1,fright2,fright3,insurns1,insurns2,
    insurns6,fright6,packing6,othrs6,taxblval2,totinv2,tdiscnt2,basval2,sgst2,cgst2,igst2,cess2,servic,subcon,tdiscnt,basval.
    APPEND wa_fin TO  it_fin.
    CLEAR:wa_fin,lv_desc.
  ENDLOOP.

*  DELETE it_fin WHERE fkimg IS INITIAL .
*  DELETE it_fin WHERE fkimg IS INITIAL .
*BREAK-POINT.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_data .

  " Calling FActory Method of the class, it will return the ALV object
  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = o_alv
        CHANGING
          t_table      = it_fin.

    CATCH cx_salv_msg INTO lv_msg.                      "#EC NO_HANDLER

  ENDTRY.

ENDFORM.                    " DISPLAY_DATA
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catalog .

*...Process individual columns
  DATA:lr_columns TYPE REF TO cl_salv_columns_table.
*...Get all the Columns
  DATA: lo_cols TYPE REF TO cl_salv_columns.
  lo_cols = o_alv->get_columns( ).

*   set the Column optimization
  lo_cols->set_optimize( 'X' ).
*
*...Process individual columns
  DATA: lo_column TYPE REF TO cl_salv_column.
**   Change the properties of the Columns KUNNR
*  lo_column = lo_cols->get_column( 'SLNO' ).
**        lo_column->set_long_text( 'B D' ).
*  lo_column->set_medium_text( 'Sr No' ).
**      LO_COLUMN->SET_OUTPUT_LENGTH( 10 ).

  lo_column = lo_cols->get_column( 'SLNO' ).
  lo_column->set_medium_text( 'Sl No' ).
  lo_column->set_short_text( 'Sl No' ).
  lo_column->set_long_text( 'Sl No' ).


  lo_column = lo_cols->get_column( 'BLART' ).
  lo_column->set_medium_text( 'Billing Type' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).


  lo_column = lo_cols->get_column( 'STEUC' ).
  lo_column->set_medium_text( 'HSN Code' ).
  lo_column->set_short_text( 'HSN Code' ).
  lo_column->set_long_text( 'HSN Code ' ).

  lo_column = lo_cols->get_column( 'MATNR' ).
  lo_column->set_medium_text( 'Material Code' ).




*  LO_COLUMN->SET_LONG_TEXT( ' ' ).

  lo_column = lo_cols->get_column( 'POSNR' ).
  lo_column->set_medium_text( 'Item' ).
**
  lo_column = lo_cols->get_column( 'VBELN' ).
  lo_column->set_medium_text( 'Bill Doc No' ).
  lo_column->set_short_text( 'Bill' ).



  lo_column = lo_cols->get_column( 'FKDAT' ).
  lo_column->set_medium_text( 'Bill Doc Date' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( 'Bill Doc Date ' ).

  lo_column = lo_cols->get_column( 'BELNR' ).
  lo_column->set_medium_text( 'Acc Doc No' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( 'Acc Doc No ' ).

  lo_column = lo_cols->get_column( 'OTHER' ).
  lo_column->set_medium_text( 'Other' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( 'Other' ).


  lo_column = lo_cols->get_column( 'MAKTX' ).
  lo_column->set_medium_text( 'Purchase Text' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).
  lo_column->set_visible(
      value = if_salv_c_bool_sap=>false
  ).


  lo_column = lo_cols->get_column( 'MAKTX1' ).
  lo_column->set_long_text( 'Description of Goods / Service' ).

*  LO_COLUMN = LO_COLS->GET_COLUMN( 'ABLAD' ).
*  LO_COLUMN->SET_MEDIUM_TEXT( 'Unloading Point' ).
*  LO_COLUMN->SET_SHORT_TEXT( ' ' ).
*  LO_COLUMN->SET_LONG_TEXT( ' ' ).

  lo_column = lo_cols->get_column( 'FKIMG' ).
  lo_column->set_medium_text( 'Quantity' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).


  lo_column = lo_cols->get_column( 'VRKME' ).
  lo_column->set_medium_text( 'UQC' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'TOTINV' ).
  lo_column->set_medium_text( 'Total Value' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'TAXBLVAL' ).
  lo_column->set_long_text( '' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_medium_text( 'Taxable Value' ).

  lo_column = lo_cols->get_column( 'EXTYPE' ).
  lo_column->set_long_text( '' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_medium_text( 'Export Type' ).

  lo_column = lo_cols->get_column( 'IGST' ).
  lo_column->set_medium_text( 'IGST' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'CGST' ).
  lo_column->set_medium_text( 'CGST' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'SGST' ).
  lo_column->set_medium_text( 'SGST' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

*  LO_COLUMN = LO_COLS->GET_COLUMN( 'UGST' ).
*  LO_COLUMN->SET_MEDIUM_TEXT( 'UGST Amount in INR' ).
*  LO_COLUMN->SET_SHORT_TEXT( ' ' ).
*  LO_COLUMN->SET_LONG_TEXT( ' ' ).

  lo_column = lo_cols->get_column( 'CESS' ).
  lo_column->set_medium_text( 'Cess' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

*  lo_column = lo_cols->get_column( 'D18' ).
*  lo_column->set_long_text( '' ).
*  lo_column->set_short_text( 'Flag' ).
*  lo_column->set_medium_text( ' ' ).
  lo_column = lo_cols->get_column( 'INVN' ).
  lo_column->set_medium_text( 'Reference' ).
  lo_column->set_short_text( 'Reference' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'IGSTP' ).
  lo_column->set_medium_text( '%' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'CGSTP' ).
  lo_column->set_medium_text( '%' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'SGSTP' ).
  lo_column->set_medium_text( '%' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

*  lo_column = lo_cols->get_column( 'CESSP' ).
*  lo_column->set_medium_text( 'CESS%' ).
*  lo_column->set_short_text( ' ' ).
*  lo_column->set_long_text( ' ' ).


  lo_column = lo_cols->get_column( 'SBILL' ).
  lo_column->set_medium_text( 'Shipping Bill No' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'SDATE' ).
  lo_column->set_medium_text( 'Shipping Bill Date' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'PCODE' ).
  lo_column->set_medium_text( 'Port Code' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  DATA: lo_layout  TYPE REF TO cl_salv_layout,
        lf_variant TYPE slis_vari,
        ls_key     TYPE salv_s_layout_key.

*   get layout object
  lo_layout = o_alv->get_layout( ).
*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
  ls_key-report = sy-repid.
  lo_layout->set_key( ls_key ).
*   2. Remove Save layout the restriction.
*    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
  lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

  "Double click event handling(Calling the method)
***  DATA: LO_EVENT_HANDLER TYPE REF TO LCL_HANDLE_EVENTS.
***  LF_EVENTS = O_ALV->GET_EVENT( ).
***  CREATE OBJECT LO_EVENT_HANDLER.
***  SET HANDLER LO_EVENT_HANDLER->ON_DOUBLE_CLICK FOR LF_EVENTS.

  "Setting Default PF-Status
  o_function = o_alv->get_functions( ).
  o_function->set_all( ).

  " Calling Display method
  CALL METHOD o_alv->display( ).
  "<<<<<<<<<<<<<<<<<<<<<<<endded>>>>>>>>>>>>>>>>>>>>>"""
*set initial Layout
**    lf_variant = 'DEFAULT'.
**    lo_layout->set_initial_layout( lf_variant ).
  """""""""


ENDFORM.                    " FIELD_CATALOG
