*&---------------------------------------------------------------------*
*& Include          ZN_GSTR1_HSN_SUMMARY_SUB
*&---------------------------------------------------------------------*


FORM select_querry .
  SELECT
           vbeln
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
           belnr  FROM vbrk
           INTO TABLE it_vbrk
           WHERE  fkdat IN s_budat
*            AND FKART IN ('ZCMO', 'ZCRD', 'ZDMO', 'ZDOM', 'ZEXI', 'ZEXP', 'ZICS', 'ZSAP',
*                          'ZSBC', 'ZSN', 'ZSP', 'ZSRP', 'ZSTI', 'ZWST' )
           AND bukrs IN s_bukrs
*           AND fkart IN ('ZDOM','ZDCW', 'ZTRC', 'ZDMC', 'ZEXP', 'ZTRO', 'ZDEP', 'ZJWO', 'ZSAM', 'ZF8',  " COMMENTED ON (16.3.20)
*                          'ZRE', 'ZG2', 'ZL2', 'ZSP', 'ZSRI' )
****************    ADDED ON(16.3.2020)    **********************
          AND fkart = 'FP'
********************    END (16.3.2020)   ********************

            AND  fksto NE 'X'.

  DELETE it_vbrk WHERE belnr IS INITIAL.

  SORT it_vbrk[] BY vbeln fkdat.

  IF it_vbrk[]  IS NOT INITIAL.
    SELECT
            vbeln
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
            FROM vbrp INTO TABLE it_vbrp
           FOR ALL ENTRIES IN it_vbrk
           WHERE vbeln = it_vbrk-vbeln
           AND   werks IN s_werks .

    SORT it_vbrp[] BY vbeln posnr.

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
            AND  kschl IN ( 'ZINS', 'ZINO', 'ZFRM', 'ZFRT', 'ZCHA', 'ZRBT','JOSG','JOCG','JOIG','JOUG' , 'EXIG' , 'ZOPS' , 'ZOPM' , 'ZCES', 'ZTCS', 'DIFF' ).

    SORT it_konv[] BY knumv kposn.

    SELECT * FROM tvfkt INTO TABLE it_tvfkt
             FOR ALL ENTRIES IN it_vbrk
             WHERE fkart = it_vbrk-fkart
               AND spras = 'EN'.

    IF s_hsn IS INITIAL.
      SELECT matnr
             werks
             steuc FROM marc INTO TABLE it_marc
             FOR ALL ENTRIES IN it_vbrp
             WHERE matnr = it_vbrp-matnr AND werks = it_vbrp-werks.
    ENDIF.

    SELECT matnr
           maktx FROM makt INTO TABLE it_makt
           FOR ALL ENTRIES IN it_vbrp
           WHERE matnr = it_vbrp-matnr.

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

  DATA : lv_desc TYPE string .

  IF it_vbrp IS NOT INITIAL.
    IF s_hsn IS NOT INITIAL.
      SELECT matnr
             werks
             steuc FROM marc INTO TABLE it_marc
             FOR ALL ENTRIES IN it_vbrp
             WHERE matnr = it_vbrp-matnr AND steuc IN s_hsn.

      LOOP AT it_vbrp INTO wa_vbrp.
        READ TABLE it_marc INTO wa_marc WITH KEY matnr = wa_vbrp-matnr.
        IF sy-subrc <> 0.
          DELETE it_vbrp WHERE matnr = wa_vbrp-matnr.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  LOOP AT it_vbrp INTO wa_vbrp.
    CLEAR:wa_makt,wa_tvfkt,wa_vbrk.
*    WA_FIN-MATNR  = WA_VBRP-MATNR.   "CHANGES BY KRSIHNA 29.11.2017
*    WA_FIN-VBELN  = WA_VBRP-VBELN.
*    WA_FIN-POSNR  = WA_VBRP-POSNR.
    wa_fin-netwr  = wa_vbrp-netwr.
    wa_fin-fkimg  = wa_vbrp-fkimg.
    wa_fin-vrkme  = wa_vbrp-vrkme.
BREAK MUMAIR.
    READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = wa_vbrp-vbeln.
    IF sy-subrc = 0.
*      WA_FIN-FKDAT     =  WA_VBRK-FKDAT.    "CHANGES BY KRISHNA 29.11.2017
      wa_fin-blart     =  wa_vbrk-fkart.
      wa_fin-netwr = wa_vbrp-netwr * wa_vbrk-kurrf .
    ENDIF.
*    CASE wa_fin-blart.
*      WHEN 'ZG2' OR 'ZRE'.
*        wa_fin-blart = 'Credit Note'.
*
*      WHEN 'ZL2'.
*        wa_fin-blart = 'Debit Note'.
*      WHEN OTHERS.
*        wa_fin-blart = 'Invoice'.
*    ENDCASE.

    READ TABLE it_marc INTO wa_marc WITH KEY matnr = wa_vbrp-matnr.
    IF sy-subrc = 0.
      wa_fin-steuc  = wa_marc-steuc.                                         ""HSN/SAC
    ENDIF.


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

    wa_fin-maktx = lv_desc .

***************************************************************************************************

*BREAK-POINT.

    READ TABLE it_makt INTO wa_makt WITH KEY  matnr = wa_vbrp-matnr.
    IF sy-subrc = 0.
      IF  wa_fin-maktx IS INITIAL .
        wa_fin-maktx   = wa_makt-maktx.                                        ""Description of Goods / Service
      ENDIF .
    ENDIF.
      DATA : sl TYPE char5.
    LOOP AT it_konv INTO wa_konv  WHERE knumv = wa_vbrk-knumv
                                    AND kposn = wa_vbrp-posnr.
        sl = sl + 1.
        wa_fin-slno = sl.
      CASE wa_konv-kschl.
        WHEN 'JOSG'.
*          wa_fin-sgst  = wa_konv-kwert.
*          IF wa_fin-sgst IS NOT INITIAL .
            wa_fin-sgst = wa_fin-sgst + wa_konv-kwert * wa_vbrk-kurrf .
*          ENDIF .
        WHEN 'JOCG'.
*          wa_fin-cgst  = wa_konv-kwert.
*          IF wa_fin-cgst IS NOT INITIAL .
            wa_fin-cgst = wa_fin-cgst + wa_konv-kwert * wa_vbrk-kurrf .
*          ENDIF .
        WHEN 'JOIG'.
*          wa_fin-igst  = wa_konv-kwert.
*          IF wa_fin-igst IS NOT INITIAL .
            wa_fin-igst = wa_fin-igst + wa_konv-kwert * wa_vbrk-kurrf .
*          ENDIF .
*        WHEN 'JOUG'.
*          wa_fin-ugst  = wa_konv-kwert.
*          IF wa_fin-ugst IS NOT INITIAL .
*            wa_fin-ugst = wa_fin-ugst + wa_fin-ugst * wa_vbrk-kurrf .
*          ENDIF .
*        WHEN 'EXIG'.
*          wa_fin-igst  = wa_konv-kwert.
*          IF wa_fin-igst IS NOT INITIAL .
*            wa_fin-igst = wa_fin-ugst + wa_fin-igst * wa_vbrk-kurrf .
*          ENDIF .
        WHEN 'ZCES'.
          wa_fin-cess  =  wa_fin-cess + wa_konv-kwert  * wa_vbrk-kurrf.
*          wa_fin-cessp = wa_konv-kbetr .
        WHEN 'ZBAS'.
          basval   =  basval + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZDIS'.
          tdiscnt  =  tdiscnt + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZPAC'.
          packing1  = packing1 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZFRT'.
          fright1   = fright1 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZFRM'.
          fright2   =  fright2 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZINS'.
          insurns1  = insurns1 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZINO'.
          insurns2  = insurns2 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZOPS'.
          packing2  =  packing2 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZOPM'.
          packing2  = packing2 + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'ZTCS'.
          fright3   = fright3  + wa_konv-kwert * wa_vbrk-kurrf.
        WHEN 'DIFF'.
          othrs1    = othrs1 + wa_konv-kwert * wa_vbrk-kurrf.
      ENDCASE.
      CLEAR:wa_konv.
    ENDLOOP.

*    WA_FIN-TAXBLVAL =  SUBCON + SERVIC + INSURNS1 + INSURNS2 + FRIGHT1  + FRIGHT2 + FRIGHT3 + PACKING1 + PACKING2 + OTHRS1
*                       + OTHRS2 + OTHRS3 + OTHRS4 + OTHRS5 + TDISCNT + BASVAL + ZSTO.
*
*    WA_FIN-TOTINV   = WA_FIN-NETWR + WA_FIN-SGST + WA_FIN-CGST + WA_FIN-IGST + WA_FIN-UGST + WA_FIN-CESS .


*    wa_fin-taxblval = basval +  packing1 + tdiscnt.

    wa_fin-netwr =  wa_fin-netwr - ( fright3 + insurns1 + insurns2 + fright1 + fright2 + packing2 +  wa_fin-cess  + othrs1 ).
    wa_fin-other   =   fright1 + fright2 + fright3 + insurns1 + insurns2 + packing2 + othrs1.
    wa_fin-totinv   = wa_fin-netwr + wa_fin-sgst + wa_fin-cgst + wa_fin-igst  + wa_fin-other + wa_fin-cess .



    CLEAR:othrs1,othrs2,othrs3,othrs4,othrs5,packing1,packing2,fright1,fright2,fright3,insurns1,insurns2,
    insurns6,fright6,packing6,othrs6,taxblval2,totinv2,tdiscnt2,basval2,sgst2,cgst2,igst2,cess2,servic,subcon,tdiscnt,basval,lv_desc,lv_matnr.
    APPEND wa_fin TO  it_fin.
    CLEAR:wa_fin.
*    DELETE IT_FIN WHERE BELNR = ' '.
  ENDLOOP.
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

  lo_column = lo_cols->get_column( 'SLNO' ).
  lo_column->set_medium_text( 'Sl No' ).
  lo_column->set_short_text( 'Sl No' ).
  lo_column->set_long_text( 'Sl No' ).


**   Change the properties of the Columns KUNNR
*  lo_column = lo_cols->get_column( 'SLNO' ).
**        lo_column->set_long_text( 'B D' ).
*  lo_column->set_short_text('SL NO').
*  lo_column->set_medium_text( 'SL NO' ).
**      LO_COLUMN->SET_OUTPUT_LENGTH( 10 ).

  lo_column = lo_cols->get_column( 'STEUC' ).
  lo_column->set_medium_text( 'HSN Code' ).
  lo_column->set_short_text( 'HSN Code' ).
  lo_column->set_long_text( 'HSN Code' ).




*  LO_COLUMN = LO_COLS->GET_COLUMN( 'MATNR' ).     "CHANGES BY KRISHNA 29.11.2017
*  LO_COLUMN->SET_MEDIUM_TEXT( 'Material Code' ).
*
*  LO_COLUMN = LO_COLS->GET_COLUMN( 'VBELN' ).
*  LO_COLUMN->SET_MEDIUM_TEXT( 'Inv.No' ).
*
*  LO_COLUMN = LO_COLS->GET_COLUMN( 'POSNR' ).
*  LO_COLUMN->SET_MEDIUM_TEXT( 'Inv.Item.NO' ).
*
*  LO_COLUMN = LO_COLS->GET_COLUMN( 'FKDAT' ).
*  LO_COLUMN->SET_MEDIUM_TEXT( 'Inv.Date' ).

  lo_column = lo_cols->get_column( 'MAKTX' ).
  lo_column->set_long_text( 'Description of Goods / Service' ).

  lo_column = lo_cols->get_column( 'VRKME' ).
  lo_column->set_medium_text( 'UQC' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'FKIMG' ).
  lo_column->set_medium_text( 'Quantity' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'TOTINV' ).
  lo_column->set_medium_text( 'Total Value' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'OTHER' ).
  lo_column->set_medium_text( 'Other' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'NETWR' ).
  lo_column->set_long_text( '' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_medium_text( 'Taxable Value' ).

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
*
*  lo_column = lo_cols->get_column( 'UGST' ).
*  lo_column->set_medium_text( 'UGST Amount in INR' ).
*  lo_column->set_short_text( ' ' ).
*  lo_column->set_long_text( ' ' ).

  lo_column = lo_cols->get_column( 'CESS' ).
  lo_column->set_medium_text( 'Cess' ).
  lo_column->set_short_text( ' ' ).
  lo_column->set_long_text( ' ' ).

*  lo_column = lo_cols->get_column( 'D18' ).
*  lo_column->set_long_text( '' ).
*  lo_column->set_short_text( 'Flag' ).
*  lo_column->set_medium_text( ' ' ).

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
*&---------------------------------------------------------------------*
*&      Form  GET_GST_HSN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_gst_hsn .

  it_fin1[] = it_fin[].
  SORT it_fin1 BY steuc vrkme blart maktx.
  DELETE ADJACENT DUPLICATES FROM it_fin1 COMPARING steuc vrkme blart maktx.
  LOOP AT it_fin1 INTO wa_fin1.

    CLEAR:wa_fin1-sgst,wa_fin1-cgst,wa_fin1-igst,wa_fin1-cess,wa_fin1-fkimg,
          wa_fin1-totinv,wa_fin1-netwr, wa_fin1-other.  "wa_fin1-taxblval,

    wa_fin2 = wa_fin1.
    "wa_fin1-ugst

    LOOP AT it_fin INTO wa_fin WHERE "VBELN = WA_FIN1-VBELN
                                     steuc = wa_fin1-steuc
                                AND  blart = wa_fin1-blart
                                AND  vrkme = wa_fin1-vrkme
                                AND  maktx = wa_fin1-maktx.

      wa_fin2-sgst     = wa_fin2-sgst     + wa_fin-sgst.
      wa_fin2-cgst     = wa_fin2-cgst     + wa_fin-cgst.
      wa_fin2-igst     = wa_fin2-igst     + wa_fin-igst.
*      wa_fin2-ugst     = wa_fin2-ugst     + wa_fin-ugst.
      wa_fin2-cess     = wa_fin2-cess     + wa_fin-cess.
*      WA_FIN2-INSURNS  = WA_FIN2-INSURNS  + WA_FIN-INSURNS.
*      WA_FIN2-FRIGHT   = WA_FIN2-FRIGHT   + WA_FIN-FRIGHT.
*      WA_FIN2-PACKING  = WA_FIN2-PACKING  + WA_FIN-PACKING.
      wa_fin2-other    = wa_fin2-other    + wa_fin-other.
*      wa_fin2-taxblval = wa_fin2-taxblval + wa_fin-taxblval.
*      WA_FIN2-RATEU    = WA_FIN2-RATEU    + WA_FIN-RATEU.
      wa_fin2-totinv   = wa_fin2-totinv   + wa_fin-totinv.
*      WA_FIN2-BASVAL   = WA_FIN2-BASVAL   + WA_FIN-BASVAL.
*      WA_FIN2-TDISCNT  = WA_FIN2-TDISCNT  + WA_FIN-TDISCNT.
      wa_fin2-fkimg    = wa_fin2-fkimg    + wa_fin-fkimg.
      wa_fin2-netwr    = wa_fin2-netwr   + wa_fin-netwr.
    ENDLOOP.
    wa_fin2-slno   = sy-tabix.
    APPEND wa_fin2  TO it_fin2.
    CLEAR:wa_fin2,wa_fin.
  ENDLOOP.
  REFRESH it_fin[].
  it_fin[] = it_fin2[].



ENDFORM.                    "
