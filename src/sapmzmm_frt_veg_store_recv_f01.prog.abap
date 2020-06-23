*&---------------------------------------------------------------------*
*& Include          SAPMZMM_FRT_VEG_STORE_RECV_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_MATLIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_matlist .

  DATA: ls_matlist TYPE ty_matlist.
  CONSTANTS : c_zwsi(4) VALUE 'ZWSI'.
  IF gv_scan IS NOT INITIAL.

    IF gv_rstore IS INITIAL.
      MESSAGE 'Please select your store first' TYPE 'I'.
      CLEAR: gv_scan.
    ELSE.
      SPLIT gv_scan AT '-' INTO gv_mblnr gv_mjahr.

      SELECT mblnr, mjahr, matnr, werks, lgort,dmbtr,menge,meins,umwrk,umlgo FROM mseg INTO TABLE @DATA(gt_mseg) WHERE mblnr = @gv_mblnr AND mjahr = @gv_mjahr AND werks = @gv_rstore.
      IF sy-subrc NE 0 AND gt_mseg IS INITIAL.
        MESSAGE 'Invalid scan ' TYPE 'I'.
        CLEAR: gv_scan.
      ELSE.
        SELECT mblnr, mjahr, bldat, budat, usnam FROM mkpf INTO TABLE @DATA(gt_mkpf) WHERE mblnr = @gv_mblnr AND mjahr = @gv_mjahr.
        SELECT matnr, maktx FROM makt INTO TABLE @DATA(gt_makt) FOR ALL ENTRIES IN @gt_mseg WHERE matnr = @gt_mseg-matnr.
        REFRESH: gt_matlist.

*** Start of Changes By Suri : 15.02.2020
        IF gt_mseg IS  NOT INITIAL.
*** Material Margin
          SELECT a515~matnr , konp~kbetr FROM konp
                 INNER JOIN a515 AS a515 ON konp~knumh = a515~knumh INTO TABLE @DATA(lt_konp_matnr)
                 FOR ALL ENTRIES IN @gt_mseg
                 WHERE a515~matnr = @gt_mseg-matnr
                 AND a515~kschl = @c_zwsi AND datab LE @sy-datum AND datbi GE @sy-datum AND loevm_ko = @space.
        ENDIF.
*** End of Changes By Suri : 15.02.2020

        LOOP AT gt_mseg INTO DATA(ls_mseg).

          ls_matlist-mblnr   = ls_mseg-mblnr.
          ls_matlist-mjahr  = ls_mseg-mjahr.
          READ TABLE gt_mkpf INTO DATA(ls_mkpf) WITH KEY mblnr = ls_mseg-mblnr  mjahr = ls_mseg-mjahr.
          ls_matlist-bldat   = ls_mkpf-bldat.
          ls_matlist-budat    = ls_mkpf-budat.
          ls_matlist-matnr   = ls_mseg-matnr.
          READ TABLE gt_makt INTO DATA(ls_makt) WITH KEY matnr = ls_mseg-matnr.
          ls_matlist-maktx   = ls_makt-maktx.
          ls_matlist-swerks  = ls_mseg-umwrk.
          ls_matlist-slgort  = ls_mseg-umlgo.
          ls_matlist-rwerks = ls_mseg-werks.
          ls_matlist-rlgort  = ls_mseg-lgort.
          ls_matlist-menge = ls_mseg-menge.
          ls_matlist-uom = ls_mseg-meins.
*** Start of Changes By Suri : 15.02.2020
*          ls_matlist-dmbtr = ls_mseg-dmbtr.
          READ TABLE lt_konp_matnr ASSIGNING FIELD-SYMBOL(<ls_konp>) WITH KEY matnr = ls_mseg-matnr.
          IF sy-subrc = 0.
            ls_matlist-dmbtr = <ls_konp>-kbetr.
          ENDIF.
*** End of Changes By Suri : 15.02.2020
*          LS_MATLIST-UPDPRICE = LS_MSEG-
          APPEND ls_matlist TO gt_matlist.
          CLEAR: ls_matlist.
        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM goods_movement .
  DATA : lw_goodsmvt_header TYPE bapi2017_gm_head_01,
         lv_goodsmvt_code   TYPE bapi2017_gm_code,
         li_goodsmvt_item   TYPE TABLE OF bapi2017_gm_item_create,
         lw_goodsmvt_item   TYPE bapi2017_gm_item_create,
         li_return          TYPE TABLE OF bapiret2,
         lw_return          TYPE bapiret2,
         lv_matdoc          TYPE bapi2017_gm_head_ret-mat_doc,
         lv_matdocumentyear TYPE bapi2017_gm_head_ret-doc_year.

  lw_goodsmvt_header-pstng_date = '20200229'.
  lw_goodsmvt_header-doc_date   = sy-datum.

  lv_goodsmvt_code              = '04'.
  LOOP AT gt_matlist INTO DATA(wa_item).
    lw_goodsmvt_item-material       = wa_item-matnr.  " |{ wa_item-matnr ALPHA = IN }|.
    lw_goodsmvt_item-plant          = wa_item-rwerks.
    lw_goodsmvt_item-stge_loc       = wa_item-rlgort.
    lw_goodsmvt_item-move_type      = '305'.
    lw_goodsmvt_item-entry_qnt      = wa_item-menge.
    lw_goodsmvt_item-entry_uom      = wa_item-uom.
    lw_goodsmvt_item-move_mat       = wa_item-matnr.  " |{ wa_item-matnr ALPHA = IN }|.
    lw_goodsmvt_item-move_plant     = wa_item-swerks.
    lw_goodsmvt_item-move_stloc     = wa_item-slgort.
    lw_goodsmvt_item-mvt_ind        = ' '.

    APPEND lw_goodsmvt_item TO li_goodsmvt_item.
  ENDLOOP.


  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = lw_goodsmvt_header
      goodsmvt_code    = lv_goodsmvt_code
*     TESTRUN          = ' '
*     GOODSMVT_REF_EWM =
    IMPORTING
*     GOODSMVT_HEADRET =
      materialdocument = lv_matdoc
      matdocumentyear  = lv_matdocumentyear
    TABLES
      goodsmvt_item    = li_goodsmvt_item
*     GOODSMVT_SERIALNUMBER         =
      return           = li_return
*     GOODSMVT_SERV_PART_DATA       =
*     EXTENSIONIN      =
    .

  IF lv_matdoc IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

*    PERFORM update_condition.

    MESSAGE lv_matdoc && 'Goods recieved successful ' TYPE 'S'.
  ENDIF.
ENDFORM.
