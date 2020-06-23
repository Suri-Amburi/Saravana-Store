*&---------------------------------------------------------------------*
*& Include          SAPMZMM_STO_RF_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FILL_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_screen .
  CASE gv_cnt.
    WHEN '1'.
      gv_sn1 = gv_cnt.
      gv_batch1 = gv_batch.
      gv_qty1 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '2'.
      gv_sn2 = gv_cnt.
      gv_batch2 = gv_batch.
      gv_qty2 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '3'.
      gv_sn3 = gv_cnt.
      gv_batch3 = gv_batch.
      gv_qty3 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '4'.
      gv_sn4 = gv_cnt.
      gv_batch4 = gv_batch.
      gv_qty4 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '5'.
      gv_sn5 = gv_cnt.
      gv_batch5 = gv_batch.
      gv_qty5 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '6'.
      gv_sn6 = gv_cnt.
      gv_batch6 = gv_batch.
      gv_qty6 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '7'.
      gv_sn7 = gv_cnt.
      gv_batch7 = gv_batch.
      gv_qty7 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '8'.
      gv_sn8 = gv_cnt.
      gv_batch8 = gv_batch.
      gv_qty8 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '9'.
      gv_sn9 = gv_cnt.
      gv_batch9 = gv_batch.
      gv_qty9 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '10'.
      gv_sn10 = gv_cnt.
      gv_batch10 = gv_batch.
      gv_qty10 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '11'.
      gv_sn11 = gv_cnt.
      gv_batch11 = gv_batch.
      gv_qty11 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '12'.
      gv_sn12 = gv_cnt.
      gv_batch12 = gv_batch.
      gv_qty12 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '13'.
      gv_sn13 = gv_cnt.
      gv_batch13 = gv_batch.
      gv_qty13 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '14'.
      gv_sn14 = gv_cnt.
      gv_batch14 = gv_batch.
      gv_qty14 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
    WHEN '15'.
      gv_sn1 = gv_cnt.
      gv_batch15 = gv_batch.
      gv_qty15 = gv_qty.
      gs_list-batch = gv_batch.
      gs_list-qty = gv_qty.
      APPEND gs_list TO gt_list.
      CLEAR: gv_batch, gv_qty, gs_list.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATLIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_matlist  .
  BREAK samburi.
  IF gt_list IS NOT INITIAL.
    "a~user_s
    SELECT a~matnr a~plant d~lgort AS stge_loc b~meins AS uom
      a~b1_batch a~s4_batch AS batch  b~matkl c~wgbez FROM zb1_s4_map AS a
      INNER JOIN mara AS b ON a~matnr = b~matnr
      INNER JOIN mard AS d ON ( d~matnr = a~matnr AND d~lgort = 'FG01' )
      INNER JOIN t023t AS c ON b~matkl = c~matkl
      INTO TABLE gt_b1batch
      FOR ALL ENTRIES IN gt_list
      WHERE b1_batch = gt_list-batch AND plant = gv_fwhs .

    IF sy-subrc IS NOT INITIAL .
      "a~user_s
****      SELECT a~matnr a~werks a~lgort AS stge_loc b~meins AS uom
****        a~charg AS b1_batch a~charg AS batch b~matkl c~wgbez FROM mchb AS a
****        INNER JOIN mara AS b ON a~matnr = b~matnr
****        INNER JOIN t023t AS c ON b~matkl = c~matkl
****        INTO TABLE gt_b1batch
****        FOR ALL ENTRIES IN gt_list
****        WHERE a~charg = gt_list-batch AND a~werks = gv_fwhs AND a~lgort = 'FG01' .
    ENDIF.

    IF gv_batch1 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO DATA(ls_b1batch) WITH KEY b1_batch = gv_batch1.
      gv_catg1 = ls_b1batch-wgbez.
      gv_sbatch1 = ls_b1batch-batch.
      gv_item1 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch2 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch2.
      gv_catg2 = ls_b1batch-wgbez.
      gv_sbatch2 = ls_b1batch-batch.
      gv_item2 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch3 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch3.
      gv_catg3 = ls_b1batch-wgbez.
      gv_sbatch3 = ls_b1batch-batch.
      gv_item3 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch4 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch4.
      gv_catg4 = ls_b1batch-wgbez.
      gv_sbatch4 = ls_b1batch-batch.
      gv_item4 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch5 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch5.
      gv_catg5 = ls_b1batch-wgbez.
      gv_sbatch5 = ls_b1batch-batch.
      gv_item5 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch6 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch6.
      gv_catg6 = ls_b1batch-wgbez.
      gv_sbatch6 = ls_b1batch-batch.
      gv_item6 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch7 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch7.
      gv_catg7 = ls_b1batch-wgbez.
      gv_sbatch7 = ls_b1batch-batch.
      gv_item7 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch8 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch8.
      gv_catg8 = ls_b1batch-wgbez.
      gv_sbatch8 = ls_b1batch-batch.
      gv_item8 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch9 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch9.
      gv_catg9 = ls_b1batch-wgbez.
      gv_sbatch9 = ls_b1batch-batch.
      gv_item9 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch10 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch10.
      gv_catg10 = ls_b1batch-wgbez.
      gv_sbatch10 = ls_b1batch-batch.
      gv_item10 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch11 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch11.
      gv_catg11 = ls_b1batch-wgbez.
      gv_sbatch11 = ls_b1batch-batch.
      gv_item11 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch12 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch12.
      gv_catg12 = ls_b1batch-wgbez.
      gv_sbatch12 = ls_b1batch-batch.
      gv_item12 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch13 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch13.
      gv_catg13 = ls_b1batch-wgbez.
      gv_sbatch13 = ls_b1batch-batch.
      gv_item13 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch14 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch14.
      gv_catg14 = ls_b1batch-wgbez.
      gv_sbatch14 = ls_b1batch-batch.
      gv_item14 = ls_b1batch-matnr.
    ENDIF.
    IF gv_batch15 IS NOT INITIAL.
      READ TABLE gt_b1batch INTO ls_b1batch WITH KEY b1_batch = gv_batch15.
      gv_catg15 = ls_b1batch-wgbez.
      gv_sbatch15 = ls_b1batch-batch.
      gv_item15 = ls_b1batch-matnr.
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

  DATA: ls_poheader  TYPE bapimepoheader,
        ls_poheaderx TYPE bapimepoheaderx,
        ls_poitem    TYPE bapimepoitem,
        ls_poitemx   TYPE bapimepoitemx,
        ls_sto_items TYPE bapidlvreftosto,

        lv_ebeln     TYPE ebeln,
        lv_vbeln     TYPE vbeln_vl,
        lv_line      TYPE i VALUE '10',
        lv_msg(50)   TYPE c,

        lt_poitem    TYPE TABLE OF bapimepoitem,
        lt_poitemx   TYPE TABLE OF bapimepoitemx,
        lt_return    TYPE TABLE OF bapiret2,
        lt_sto_items TYPE TABLE OF bapidlvreftosto.

  ls_poheader-comp_code = '1000'.
  ls_poheader-doc_type = 'ZUB'.
  ls_poheader-purch_org = '9000'.
  ls_poheader-pur_group = 'P01'.
  ls_poheader-currency = 'INR'.
  ls_poheader-suppl_plnt = gv_fwhs.

  ls_poheaderx-comp_code = 'X'.
  ls_poheaderx-doc_type = 'X'.
  ls_poheaderx-purch_org = 'X'.
  ls_poheaderx-pur_group = 'X'.
  ls_poheaderx-currency = 'X'.
  ls_poheaderx-suppl_plnt = 'X'.

  LOOP AT gt_b1batch INTO DATA(ls_batch).
    lv_line = lv_line + 1.
    ls_poitem-po_item = lv_line.
    ls_poitem-material = ls_batch-matnr.
    ls_poitem-plant = gv_tstore.
    ls_poitem-stge_loc = ls_batch-stge_loc.
    READ TABLE gt_list INTO DATA(ls_list) WITH KEY batch = ls_batch-b1_batch.
    ls_poitem-quantity = ls_list-qty.
    ls_poitem-po_unit = ls_batch-uom.
    ls_poitem-po_unit_iso = ls_batch-uom.
    ls_poitem-gi_based_gr = 'X'.

    ls_poitemx-po_item = lv_line.
    ls_poitemx-po_itemx = 'X'.
    ls_poitemx-material = 'X'.
    ls_poitemx-plant = 'X'.
    ls_poitemx-stge_loc = 'X'.
    ls_poitemx-quantity = 'X'.
    ls_poitemx-po_unit = 'X'.
    ls_poitemx-po_unit_iso = 'X'.
    ls_poitemx-gi_based_gr = 'X'.
    APPEND ls_poitem TO lt_poitem.
    APPEND ls_poitemx TO lt_poitemx.
    CLEAR:ls_poitem,ls_poitemx,ls_batch.
  ENDLOOP.


  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      poheader         = ls_poheader
      poheaderx        = ls_poheaderx
    IMPORTING
      exppurchaseorder = lv_ebeln
    TABLES
      return           = lt_return
      poitem           = lt_poitem
      poitemx          = lt_poitemx.


  IF lv_ebeln IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    ls_sto_items-ref_doc =  lv_ebeln.
    APPEND ls_sto_items TO lt_sto_items.

    CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_STO'
      EXPORTING
        ship_point        = gv_fwhs
*       DUE_DATE          =
*       DEBUG_FLG         =
*       NO_DEQUEUE        = ' '
      IMPORTING
        delivery          = lv_vbeln
*       NUM_DELIVERIES    =
      TABLES
        stock_trans_items = lt_sto_items.

    IF lv_vbeln IS NOT INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      lv_msg = 'Delivery  ' && lv_vbeln && '  created' .
      MESSAGE lv_msg TYPE 'S'.

      PERFORM refresh_screen.
    ENDIF.
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
  CLEAR: gv_fwhs, gv_tstore,
        ok_9001,
        gv_batch,
        gv_qty,
        gv_cnt,
        gs_list,

        gv_sn1         ,
        gv_sn2         ,
        gv_sn3         ,
        gv_sn4         ,
        gv_sn5         ,
        gv_sn6         ,
        gv_sn7         ,
        gv_sn8         ,
        gv_sn9         ,
        gv_sn10     ,
        gv_sn11     ,
        gv_sn12     ,
        gv_sn13     ,
        gv_sn14     ,
        gv_sn15     ,

        gv_batch1  ,
        gv_batch2  ,
        gv_batch3  ,
        gv_batch4  ,
        gv_batch5  ,
        gv_batch6  ,
        gv_batch7  ,
        gv_batch8  ,
        gv_batch9  ,
        gv_batch10 ,
        gv_batch11 ,
        gv_batch12 ,
        gv_batch13 ,
        gv_batch14 ,
        gv_batch15 ,

        gv_qty1    ,
        gv_qty2    ,
        gv_qty3    ,
        gv_qty4    ,
        gv_qty5    ,
        gv_qty6    ,
        gv_qty7    ,
        gv_qty8    ,
        gv_qty9    ,
        gv_qty10,
        gv_qty11,
        gv_qty12,
        gv_qty13,
        gv_qty14,
        gv_qty15,

        gv_catg1,
        gv_catg2,
        gv_catg3,
        gv_catg4,
        gv_catg5,
        gv_catg6,
        gv_catg7,
        gv_catg8,
        gv_catg9,
        gv_catg10,
        gv_catg11,
        gv_catg12,
        gv_catg13,
        gv_catg14,
        gv_catg15,

        gv_sbatch1,
        gv_sbatch2,
        gv_sbatch3,
        gv_sbatch4,
        gv_sbatch5,
        gv_sbatch6,
        gv_sbatch7,
        gv_sbatch8,
        gv_sbatch9,
        gv_sbatch10,
        gv_sbatch11,
        gv_sbatch12,
        gv_sbatch13,
        gv_sbatch14,
        gv_sbatch15,

        gv_item1, gv_item2,gv_item3,
        gv_item4,gv_item5,        gv_item6,        gv_item7,        gv_item8,        gv_item9,        gv_item10,        gv_item11,
        gv_item12,
        gv_item13,
        gv_item14,
        gv_item15.

  REFRESH : gt_list, gt_b1batch.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_screen .
  CLEAR: gv_tstore,
        ok_9001,
        gv_batch,
        gv_qty,
        gv_cnt,
        gs_list,

        gv_sn1         ,
        gv_sn2         ,
        gv_sn3         ,
        gv_sn4         ,
        gv_sn5         ,
        gv_sn6         ,
        gv_sn7         ,
        gv_sn8         ,
        gv_sn9         ,
        gv_sn10     ,
        gv_sn11     ,
        gv_sn12     ,
        gv_sn13     ,
        gv_sn14     ,
        gv_sn15     ,

        gv_batch1  ,
        gv_batch2  ,
        gv_batch3  ,
        gv_batch4  ,
        gv_batch5  ,
        gv_batch6  ,
        gv_batch7  ,
        gv_batch8  ,
        gv_batch9  ,
        gv_batch10 ,
        gv_batch11 ,
        gv_batch12 ,
        gv_batch13 ,
        gv_batch14 ,
        gv_batch15 ,

        gv_qty1    ,
        gv_qty2    ,
        gv_qty3    ,
        gv_qty4    ,
        gv_qty5    ,
        gv_qty6    ,
        gv_qty7    ,
        gv_qty8    ,
        gv_qty9    ,
        gv_qty10,
        gv_qty11,
        gv_qty12,
        gv_qty13,
        gv_qty14,
        gv_qty15,

        gv_catg1,
        gv_catg2,
        gv_catg3,
        gv_catg4,
        gv_catg5,
        gv_catg6,
        gv_catg7,
        gv_catg8,
        gv_catg9,
        gv_catg10,
        gv_catg11,
        gv_catg12,
        gv_catg13,
        gv_catg14,
        gv_catg15,

        gv_sbatch1,
        gv_sbatch2,
        gv_sbatch3,
        gv_sbatch4,
        gv_sbatch5,
        gv_sbatch6,
        gv_sbatch7,
        gv_sbatch8,
        gv_sbatch9,
        gv_sbatch10,
        gv_sbatch11,
        gv_sbatch12,
        gv_sbatch13,
        gv_sbatch14,
        gv_sbatch15,

        gv_item1, gv_item2,gv_item3,
        gv_item4,gv_item5,        gv_item6,        gv_item7,        gv_item8,        gv_item9,        gv_item10,        gv_item11,
        gv_item12,
        gv_item13,
        gv_item14,
        gv_item15.

  REFRESH : gt_list, gt_b1batch.

ENDFORM.
