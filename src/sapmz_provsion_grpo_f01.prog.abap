*&---------------------------------------------------------------------*
*& Include          SAPMZ_FV_PROCESS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PREPARE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_fcat.
  CHECK gt_fieldcat IS INITIAL.
*** Layout
  gs_layo-frontend   = c_x.
  gs_layo-zebra      = c_x.
*** Field Catlog
  gt_fieldcat = VALUE #(
                         ( fieldname = 'EBELP'    tabname   = 'GT_ITEM'     scrtext_l   = 'Item' outputlen = '10'  )
                         ( fieldname = 'MATNR'    tabname   = 'GT_ITEM'     scrtext_l   = 'Product' outputlen = '10'  )
                         ( fieldname = 'MAKTX'    tabname   = 'GT_ITEM'     scrtext_l   = 'Product Des' outputlen = '20' )
                         ( fieldname = 'MENGE'    tabname   = 'GT_ITEM'     scrtext_l   = 'Atc.Quantity' outputlen = '10'
                           ref_field = 'MENGE'    ref_table = 'ZINW_T_ITEM' decimals    = '0' decimals_o = '0' )
                         ( fieldname = 'MENGE_R'  tabname   = 'GT_ITEM'     scrtext_l   = 'Rec.Quantity' outputlen = '10'
                            edit = c_x )
                         ( fieldname = 'MEINS'    tabname   = 'GT_ITEM'     scrtext_l   = 'UOM' outputlen = '10' )
                         ( fieldname = 'PUR_AMT'  tabname   = 'GT_ITEM'     scrtext_l   = 'Pur Price' outputlen = '10'  )
                         ( fieldname = 'NETPR_S'  tabname   = 'GT_ITEM'     scrtext_l   = 'Selling Price' outputlen = '10'  )
                        ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

*** Creating Object Ref
  IF gr_container IS NOT BOUND.
    CREATE OBJECT gr_container  EXPORTING container_name = 'MYCONTAINER'.
    CREATE OBJECT gr_grid EXPORTING i_parent = gr_container.
  ENDIF.

*** Create Object for event_receiver.
  IF gr_event IS NOT BOUND.
    CREATE OBJECT gr_event.
  ENDIF.

  IF gt_exclude IS INITIAL.
    PERFORM exclude_tb_functions CHANGING gt_exclude.
  ENDIF.

  IF gr_grid IS BOUND.
*** Displaying Table
    CALL METHOD gr_grid->set_table_for_first_display
      EXPORTING
        is_layout                     = gs_layo
        it_toolbar_excluding          = gt_exclude
      CHANGING
        it_outtab                     = gt_item
        it_fieldcatalog               = gt_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    IF sy-subrc <> 0.
    ENDIF.
**  Registering the EDIT Event
    CALL METHOD gr_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
    SET HANDLER gr_event->handle_data_changed FOR gr_grid.
  ENDIF.
ENDFORM.


FORM exclude_tb_functions  CHANGING gt_exclude TYPE ui_functions.

*  GT_EXCLUDE = VALUE #(   ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW    )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW    )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE         )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY          )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW      )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT           )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO          )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW    )
*                          ( CL_GUI_ALV_GRID=>MC_FC_PRINT             )
*                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW      )
*                          ( CL_GUI_ALV_GRID=>MC_FC_FIND_MORE         )
*                          ( CL_GUI_ALV_GRID=>MC_FC_SUM               )
*                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
*                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
*                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
*                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
*                          ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE           )
*                         ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear.
  CLEAR : ok_9001 , gv_subrc , gv_diff.
  REFRESH  : gt_item, gt_mseg.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form POST_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM post_data.
  PERFORM goods_movement_101_543 CHANGING gv_subrc.
  CHECK gv_subrc = 0.
*  PERFORM condition_record_upload CHANGING gv_subrc.
  CHECK gv_subrc = 0 AND gv_diff IS NOT INITIAL.
  PERFORM goods_movement_542 CHANGING gv_subrc.
  CHECK gv_subrc = 0.
  PERFORM goods_movement_201 CHANGING gv_subrc.
*  CHECK GV_SUBRC = 0.
*  PERFORM PRINT_STICKER CHANGING GV_SUBRC.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT_101_543
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM goods_movement_101_543 CHANGING gv_subrc.
*** BAPI Structure Declaration
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id,
    lv_diff(1).
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.
  gv_subrc = 0.
  CHECK gs_hdr-mblnr_101 IS INITIAL.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 3.
  lv_line_id = '000001'.
*** Looping the PO details.
  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
    IF <ls_item>-menge_r <> <ls_item>-menge.
      gv_diff = c_x.
    ENDIF.
    CHECK <ls_item>-menge_r > 0.
*** FILL THE BAPI ITEM STRUCTURE DETAILS - 101 Movement Type
    READ TABLE gt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
    CHECK sy-subrc = 0.
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-matnr.
    ls_gmvt_item-move_type = c_101.
    ls_gmvt_item-plant     = <ls_mseg>-werks.
    ls_gmvt_item-po_number = <ls_mseg>-ebeln.
    ls_gmvt_item-po_item   = <ls_mseg>-ebelp.
    ls_gmvt_item-entry_qnt = ls_gmvt_item-po_pr_qnt = <ls_item>-menge_r.
    ls_gmvt_item-entry_uom = ls_gmvt_item-entry_uom_iso = ls_gmvt_item-orderpr_un = ls_gmvt_item-orderpr_un_iso = <ls_mseg>-meins.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-mvt_ind   = c_mvt_ind_b.

    ls_gmvt_item-vendor    = <ls_mseg>-lifnr.
    ls_gmvt_item-stge_loc  = 'FG01'.
    ls_gmvt_item-line_id   = lv_line_id.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.

*** FILL THE BAPI ITEM STRUCTURE DETAILS - 543 Movement Type
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-m_matnr.
    ls_gmvt_item-move_type = c_543.
    ls_gmvt_item-plant     = <ls_mseg>-werks.
    ls_gmvt_item-po_number = <ls_mseg>-ebeln.
    ls_gmvt_item-po_item   = <ls_mseg>-ebelp.
    ls_gmvt_item-entry_qnt = <ls_mseg>-m_menge.

    ls_gmvt_item-entry_qnt = ( <ls_item>-menge_r  ) * ( <ls_mseg>-m_menge / <ls_item>-menge ).
    ls_gmvt_item-entry_uom = <ls_mseg>-m_meins.
    ls_gmvt_item-entry_uom_iso = 'KGM' .
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-batch     = ls_gmvt_item-val_type = <ls_mseg>-charg.

    ls_gmvt_item-vendor   = <ls_mseg>-lifnr.
    ls_gmvt_item-spec_stock = 'O'.
    ls_gmvt_item-line_id = lv_line_id.
    ls_gmvt_item-parent_id = lv_line_id - 1 .

    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.
  ENDLOOP.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = c_mvt_01
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = c_e.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.
    gs_hdr-mblnr_101 = ls_gmvt_headret-mat_doc.
*    MESSAGE 'Successfully Posted' TYPE 'S'.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    gv_subrc = 4.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONDITION_RECORD_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM condition_record_upload CHANGING gv_subrc.

  DATA: lv_ctumode(1) VALUE 'N',
        lv_cupdate(1) VALUE 'S'.
  REFRESH : messtab, bdcdata.
  CHECK gs_hdr-mblnr_101 IS NOT INITIAL AND gs_hdr-cond_rec IS INITIAL.
  DATA(lv_date) = sy-datum+6(2) && '.' && sy-datum+4(2) && '.' && sy-datum+0(4) .

  SELECT mseg~matnr , mseg~charg, mseg~menge, mseg~meins, mseg~ebeln, mseg~ebelp ,mara~ean11
         INTO TABLE @DATA(lt_mseg)
         FROM mseg AS mseg
         INNER JOIN mara AS mara ON mara~matnr = mseg~matnr
         WHERE mblnr = @gs_hdr-mblnr_101 AND bwart = @c_101.
  LOOP AT gt_item ASSIGNING <gs_item>.
    READ TABLE lt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>) WITH KEY matnr = <gs_item>-matnr ebeln = <gs_item>-ebeln ebelp = <gs_item>-ebelp.
    IF sy-subrc = 0.
      REFRESH : messtab, bdcdata.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
      PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
      PERFORM bdc_field       USING 'RV13A-KSCHL'
                                    'ZKP0'.
      PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM bdc_field       USING 'RV130-SELKZ(04)' 'X'.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '1516'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'KOMG-MATNR(01)'
                                    <ls_mseg>-matnr.
      PERFORM bdc_field       USING 'KOMG-EAN11(01)'
                                    <ls_mseg>-ean11.
      PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                    <gs_item>-netpr_s.
      PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                    'INR'.
      PERFORM bdc_field       USING 'KONP-KPEIN(01)'
                                    '    1'.
      PERFORM bdc_field       USING 'KONP-KMEIN(01)'
                                    <ls_mseg>-meins.
      PERFORM bdc_field       USING 'RV13A-DATAB(01)'
                                    lv_date.
      PERFORM bdc_field       USING 'RV13A-DATBI(01)'
                                    '31.12.9999'.
      PERFORM bdc_dynpro      USING 'SAPMV13A' '1516'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'KOMG-MATNR(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.

      CALL TRANSACTION 'VK11'
          USING  bdcdata
          MODE   lv_ctumode
          UPDATE lv_cupdate
          MESSAGES INTO messtab.

      READ TABLE messtab ASSIGNING FIELD-SYMBOL(<ls_messtab>) WITH KEY msgtyp = 'E'.
      IF sy-subrc <> 0.
        READ TABLE messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S' msgid = 'VK' msgnr = '023'.
        IF sy-subrc = 0.
          gv_subrc = 0.
          gs_hdr-cond_rec = c_x.
        ELSE.
          gv_subrc = 4.
          CLEAR gs_hdr-cond_rec.
          MESSAGE 'Condition Recods Not Saved' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        gv_subrc = 4.
        CLEAR gs_hdr-cond_rec.
        MESSAGE ID <ls_messtab>-msgid TYPE <ls_messtab>-msgtyp NUMBER <ls_messtab>-msgnr WITH <ls_messtab>-msgv1 <ls_messtab>-msgv2 <ls_messtab>-msgv3 <ls_messtab>-msgv4.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.
  REFRESH : gt_item.
  SELECT DISTINCT
    ekpo~ebeln,
    ekpo~ebelp,
    ekpo~matnr,
    ekpo~txz01,
    ekpo~menge,
    ekpo~meins,
    mseg~charg,
    mseg~lifnr,
    mseg~werks,
    mseg~matnr AS m_matnr,
    makt~maktx,
    mseg~menge AS m_menge,
    mseg~meins AS m_meins,
    konp~kbetr
    INTO TABLE @gt_mseg
    FROM ekpo AS ekpo
    INNER JOIN mseg AS mseg ON mseg~ebeln = ekpo~ebeln AND mseg~ebelp = ekpo~ebelp AND mseg~bwart = '541' AND mseg~xauto = @space
    INNER JOIN makt AS makt ON mseg~matnr = makt~matnr
    INNER JOIN a502 AS a502 ON  a502~kschl = 'ZMKP' AND a502~matnr = mseg~matnr AND a502~datab LE @sy-datum AND a502~datbi GE @sy-datum AND a502~lifnr = mseg~lifnr
    INNER JOIN konp AS konp ON konp~knumh = a502~knumh AND konp~loevm_ko = @space
    WHERE mseg~ebeln = @gs_hdr-ebeln.
  IF sy-subrc = 0.
    SELECT
     ekpo~ebeln,
     ekpo~ebelp,
     ekpo~netpr,
     ekpo~matnr,
     mseg~charg,
     mseg~werks
     INTO TABLE @DATA(gt_ekpo)
     FROM ekpo AS ekpo
     INNER JOIN mseg AS mseg ON mseg~ebeln = ekpo~ebeln AND mseg~ebelp = ekpo~ebelp AND mseg~bwart = '101'
     FOR ALL ENTRIES IN @gt_mseg
     WHERE mseg~charg = @gt_mseg-charg.

    LOOP AT gt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>).
      AT FIRST.
        gs_hdr-werks = <ls_mseg>-werks.
      ENDAT.
      APPEND INITIAL LINE TO gt_item ASSIGNING <gs_item>.
      <gs_item>-ebeln   = <ls_mseg>-ebeln.
      <gs_item>-ebelp   = <ls_mseg>-ebelp.
      <gs_item>-matnr   = <ls_mseg>-matnr.
      <gs_item>-maktx   = <ls_mseg>-txz01.
      <gs_item>-menge   = <ls_mseg>-menge.
      <gs_item>-meins   = <ls_mseg>-meins.


      READ TABLE gt_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpo>) WITH KEY matnr = <ls_mseg>-m_matnr charg = <ls_mseg>-charg.
      IF sy-subrc = 0.
        <gs_item>-pur_amt = <ls_ekpo>-netpr.
        DATA(lv_margin) = ( ( <ls_ekpo>-netpr * ( <ls_mseg>-m_menge / <ls_mseg>-menge ) ) * <ls_mseg>-kbetr ) / 1000.
*        data(lv_marin) = ( ( <ls_ekpo>-netpr * ( <ls_mseg>-m_menge / <ls_mseg>-menge ) ) * <ls_mseg>-kbetr ) / 100.
        <gs_item>-netpr_s = ( ( <ls_ekpo>-netpr * ( <ls_mseg>-m_menge / <ls_mseg>-menge ) ) ) + lv_margin .
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE 'Invalid Doc' TYPE 'E'.
  ENDIF.
ENDFORM.

FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.

FORM bdc_field USING fnam fval.
  IF fval IS NOT INITIAL.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    SHIFT bdcdata-fval LEFT DELETING LEADING space.
    APPEND bdcdata.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT_542
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM goods_movement_542  CHANGING gv_subrc.
*** BAPI STRUCTURE DECLARATION
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id,
    lv_diff(1).
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

  CHECK gs_hdr-mblnr_542 IS INITIAL.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 2.
  lv_line_id = '000001'.
*** Looping the PO details.
  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
    CHECK <ls_item>-menge_r <> <ls_item>-menge.
*** FILL THE BAPI ITEM STRUCTURE DETAILS - 542 Movement Type
    READ TABLE gt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
    CHECK sy-subrc = 0.
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-m_matnr.
    ls_gmvt_item-move_type = c_542.
    ls_gmvt_item-plant     = <ls_mseg>-werks.
    ls_gmvt_item-vendor     = <ls_mseg>-lifnr.
    ls_gmvt_item-batch     = ls_gmvt_item-val_type  = ls_gmvt_item-move_batch = ls_gmvt_item-move_val_type = <ls_mseg>-charg.
    ls_gmvt_item-entry_qnt = ls_gmvt_item-po_pr_qnt = ( <ls_item>-menge - <ls_item>-menge_r  ) * ( <ls_mseg>-m_menge / <ls_item>-menge ).
    ls_gmvt_item-entry_uom = ls_gmvt_item-entry_uom_iso = <ls_mseg>-m_meins.
    ls_gmvt_item-entry_uom_iso = 'KGM'.
    ls_gmvt_item-prod_date = sy-datum.
    ls_gmvt_item-vendor    = <ls_mseg>-lifnr.
    ls_gmvt_item-stge_loc  = 'FG01'.
    ls_gmvt_item-line_id   = lv_line_id.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.
  ENDLOOP.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = c_mvt_04
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = c_e.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.
    gs_hdr-mblnr_542 = ls_gmvt_headret-mat_doc.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    gv_subrc = 4.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT_202
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_SUBRC
*&---------------------------------------------------------------------*
FORM goods_movement_201  CHANGING gv_subrc.
*** BAPI STRUCTURE DECLARATION
  DATA:
    ls_gmvt_header  TYPE bapi2017_gm_head_01,
    ls_gmvt_item    TYPE bapi2017_gm_item_create,
    ls_gmvt_headret TYPE bapi2017_gm_head_ret,
    lt_bapiret      TYPE STANDARD TABLE OF bapiret2,
    lt_gmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lv_line_id      TYPE mb_line_id,
    lv_diff(1).
  FIELD-SYMBOLS :
    <ls_bapiret> TYPE bapiret2.

  CHECK gs_hdr-mblnr_201 IS INITIAL.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = sy-datum.
  ls_gmvt_header-doc_date   = sy-datum.
  ls_gmvt_header-pr_uname   = sy-uname.
  ls_gmvt_header-ver_gr_gi_slip   = 1.
  lv_line_id = '000001'.

*** Looping the PO details.
  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
    CHECK <ls_item>-menge_r <> <ls_item>-menge.
*** FILL THE BAPI ITEM STRUCTURE DETAILS - 542 Movement Type
    READ TABLE gt_mseg ASSIGNING FIELD-SYMBOL(<ls_mseg>) WITH KEY ebeln = <ls_item>-ebeln ebelp = <ls_item>-ebelp.
    CHECK sy-subrc = 0.
    ls_gmvt_item-material  = ls_gmvt_item-material_long = <ls_mseg>-m_matnr.
    ls_gmvt_item-move_type = c_201.
    ls_gmvt_item-plant     = <ls_mseg>-werks.
    ls_gmvt_item-batch     = ls_gmvt_item-val_type   = <ls_mseg>-charg.
    ls_gmvt_item-entry_qnt = ( <ls_item>-menge - <ls_item>-menge_r ) * ( <ls_mseg>-m_menge / <ls_item>-menge ).
    ls_gmvt_item-entry_uom = <ls_mseg>-m_meins.
    ls_gmvt_item-entry_uom_iso = 'KGM'.
    ls_gmvt_item-stge_loc      = 'FG01'.
    ls_gmvt_item-gl_account    = '0000620100'.
    ls_gmvt_item-costcenter    = '0009100000'.
    ls_gmvt_item-line_id   = lv_line_id.
    APPEND ls_gmvt_item TO lt_gmvt_item.
    CLEAR ls_gmvt_item.
    lv_line_id = lv_line_id + 1.
  ENDLOOP.
*** Call the BAPI FM for GR posting
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gmvt_header
      goodsmvt_code    = c_mvt_03
    IMPORTING
      goodsmvt_headret = ls_gmvt_headret
    TABLES
      goodsmvt_item    = lt_gmvt_item
      return           = lt_bapiret.

  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = c_e.
  IF sy-subrc <> 0 .
*** For commit the changes use BAPI_TRANSACTION_COMMIT FM.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.
    gs_hdr-mblnr_201 = ls_gmvt_headret-mat_doc.
    MESSAGE 'Successfully Posted' TYPE 'S'.
  ELSE.
*** Roll Back if any error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    gv_subrc = 4.
    MESSAGE ID <ls_ret>-id TYPE <ls_ret>-type NUMBER <ls_ret>-number WITH <ls_ret>-message_v1 <ls_ret>-message_v2
    <ls_ret>-message_v3 <ls_ret>-message_v4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_all .
  CLEAR    : ok_9001 , gv_subrc , gv_diff , gs_hdr.
  REFRESH  : gt_item, gt_mseg.
ENDFORM.
