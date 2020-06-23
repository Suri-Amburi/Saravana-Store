*&---------------------------------------------------------------------*
*& Include          ZSD_ERROR_IDOCS_F01
*&---------------------------------------------------------------------*

FORM get_data.

  FIELD-SYMBOLS :
    <ls_data>        TYPE ty_final,
    <ls_data_key>    TYPE ty_final,
    <ls_final>       TYPE ty_final,
    <ls_idoc_seg>    TYPE ty_idoc_seg,
    <ls_foldoc>      TYPE wpusa_foldoc,
    <ls_data_foldoc> TYPE ty_data_foldoc,
    <ls_invoice_hdr> TYPE ty_invoice_hdr.

  DATA :
    lt_foldoc   TYPE wpusa_t_foldoc,
    lv_exist(1).

  REFRESH : gt_data , gt_final , gt_idoc_seg, gt_invoice_hdr,gt_invoice_item .
  DATA(lv_select) = cl_shdb_seltab=>combine_seltabs(
                    it_named_seltabs = VALUE #( ( name = 'CREDAT' dref = REF #( s_date[] ) )
                                                ( name = 'DOCNUM'  dref = REF #( s_docnum[] ) )
                                               ) iv_client_field = 'MANDT' ).
*** Get All Unprocessed Idocs
  zcl_stock=>get_output_prd( EXPORTING lv_select = lv_select IMPORTING et_final_data = gt_idoc_seg  ).
*  gt_data =  VALUE #( FOR ls_data IN gt_idoc_seg
*                          ( docnum   = ls_data-docnum
*                            segnum   = ls_data-segnum
*                            matnr    = ls_data-sdata+121(40)
*                            werks    = ls_data-rcvprn
*                            idoc_qty = ls_data-sdata+45(35)
*                            uom      = ls_data-sdata+116(5)
*                            charg    = ls_data-sdata+29(15)
*                           ) ) .

  LOOP AT gt_idoc_seg ASSIGNING <ls_idoc_seg>.
    APPEND INITIAL LINE TO gt_data ASSIGNING <ls_data>.
    <ls_data>-docnum   = <ls_idoc_seg>-docnum.
    <ls_data>-segnum   = <ls_idoc_seg>-segnum.
    <ls_data>-matnr    = <ls_idoc_seg>-sdata+121(40).
    <ls_data>-werks    = <ls_idoc_seg>-rcvprn.
    IF <ls_idoc_seg>-sdata+44(1) = '-'.
      <ls_data>-idoc_qty = <ls_idoc_seg>-sdata+45(35) * -1.
    ELSE.
      <ls_data>-idoc_qty = <ls_idoc_seg>-sdata+45(35).
    ENDIF.
    <ls_data>-uom      = <ls_idoc_seg>-sdata+116(5).
    <ls_data>-charg    = <ls_idoc_seg>-sdata+29(15).
  ENDLOOP.

  DATA(gt_data_key) = gt_idoc_seg.
  REFRESH gt_idoc_seg.
  SORT gt_data_key BY docnum.
  DELETE ADJACENT DUPLICATES FROM gt_data_key COMPARING docnum.
*** Get Invoice Data From Idocs
  LOOP AT gt_data_key ASSIGNING <ls_idoc_seg>.
    CALL FUNCTION 'POS_SA_GET_DOCUMENT_STATUS'
      EXPORTING
        docnum   = <ls_idoc_seg>-docnum
        mestyp   = 'WPUBON'
      TABLES
        t_foldoc = lt_foldoc.
    IF sy-subrc <> 0.
    ENDIF.
    SORT lt_foldoc BY objtype.
    LOOP AT lt_foldoc ASSIGNING <ls_foldoc> WHERE objtype = 'VBRK'.
      APPEND INITIAL LINE TO gt_invoice_hdr ASSIGNING <ls_invoice_hdr>.
      <ls_invoice_hdr>-invoice = <ls_foldoc>-key.
      <ls_invoice_hdr>-idoc    = <ls_idoc_seg>-docnum.
    ENDLOOP.
    REFRESH lt_foldoc.
  ENDLOOP.
  REFRESH gt_data_key.
  IF gt_invoice_hdr IS NOT INITIAL.
*** Get Invoice Item
    SELECT vbeln
           posnr
           FROM vbrp
           INTO TABLE gt_invoice_item
           FOR ALL ENTRIES IN gt_invoice_hdr WHERE vbeln = gt_invoice_hdr-invoice.
  ENDIF.
  IF gt_data IS NOT INITIAL.
*** Get Stock
*** Non Batch Managed
    SELECT
       mard~matnr,
       mard~werks,
       mard~labst
       INTO TABLE @DATA(lt_stock_mard)
       FROM mard AS mard
       INNER JOIN mara AS mara ON mara~matnr = mard~matnr AND mara~xchpf <> @c_x
       FOR ALL ENTRIES IN @gt_data WHERE mard~matnr = @gt_data-matnr AND mard~werks = @gt_data-werks AND mard~labst > 0.

***  Batch Managed
    SELECT
       mchb~matnr,
       mchb~werks,
       mchb~charg,
       mchb~clabs
       INTO TABLE @DATA(lt_stock_mchb)
       FROM mchb AS mchb
       FOR ALL ENTRIES IN @gt_data WHERE mchb~matnr = @gt_data-matnr AND mchb~werks = @gt_data-werks AND mchb~charg = @gt_data-charg AND mchb~clabs > 0.
***  Batch Managed indicator
    SELECT
      mara~matnr,
      mara~xchpf,
      makt~maktx
      INTO TABLE @DATA(lt_mara)
      FROM mara
      INNER JOIN makt AS makt ON makt~matnr = mara~matnr AND spras = @sy-langu
      FOR ALL ENTRIES IN @gt_data WHERE mara~matnr = @gt_data-matnr.

*** Purchage Price ( Irrespective of Plant ) - For Batch Managed
    SELECT DISTINCT
     mbew~matnr,
     mbew~verpr,
     mbew~bwtar,
     zb1_s4_map~b1_batch
     INTO TABLE @DATA(lt_price_b)
     FROM mbew AS mbew
     LEFT JOIN  zb1_s4_map AS zb1_s4_map ON mbew~bwtar = zb1_s4_map~s4_batch
     FOR ALL ENTRIES IN @gt_data WHERE mbew~matnr = @gt_data-matnr AND bwtar = @gt_data-charg AND mbew~verpr > 0.

*** Purchage Price ( Irrespective of Plant ) - For Non Batch Managed
    SELECT DISTINCT
     mbew~matnr,
     mbew~verpr
     INTO TABLE @DATA(lt_price_nb)
     FROM mbew AS mbew
     FOR ALL ENTRIES IN @gt_data WHERE matnr = @gt_data-matnr AND mbew~bwtar = '' AND mbew~verpr > 0.
  ENDIF.
***  Final Table
  FIELD-SYMBOLS : <ls_stock_mard>   LIKE LINE OF lt_stock_mard,
                  <ls_stock_mchb>   LIKE LINE OF lt_stock_mchb,
                  <ls_invoice_item> LIKE LINE OF gt_invoice_item,
                  <ls_mara>         LIKE LINE OF lt_mara,
                  <ls_price_b>      LIKE LINE OF lt_price_b,
                  <ls_price_nb>     LIKE LINE OF lt_price_nb.
  SORT : gt_data BY matnr werks charg , lt_stock_mchb BY matnr werks charg , lt_stock_mard BY matnr werks , lt_mara BY matnr , lt_price_b BY bwtar , lt_price_nb BY matnr.
  DATA(lt_data_key) = gt_data.
  DELETE ADJACENT DUPLICATES FROM lt_data_key COMPARING matnr werks charg.
  DATA(lv_tabix) = 1.

  LOOP AT lt_data_key ASSIGNING <ls_data_key>.
    APPEND INITIAL LINE TO gt_final ASSIGNING <ls_final>.
    LOOP AT gt_data ASSIGNING <ls_data> FROM lv_tabix.
      DATA(lv_tabix_loop) = sy-tabix.
      CLEAR : lv_exist.

      IF <ls_data>-matnr = <ls_data_key>-matnr AND <ls_data>-charg = <ls_data_key>-charg AND <ls_data>-werks = <ls_data_key>-werks.
        LOOP AT gt_invoice_hdr ASSIGNING <ls_invoice_hdr> WHERE idoc = <ls_data>-docnum.
          READ TABLE gt_invoice_item ASSIGNING <ls_invoice_item> WITH KEY vbeln = <ls_invoice_hdr>-invoice posnr = <ls_data>-segnum.
          IF sy-subrc = 0.
            lv_exist = c_x.
            EXIT.
          ENDIF.
        ENDLOOP.
        CHECK lv_exist IS INITIAL.
        ADD <ls_data>-idoc_qty TO <ls_final>-idoc_qty.
      ELSE.
        lv_tabix = lv_tabix_loop.
        EXIT.
      ENDIF.
    ENDLOOP.
*** Batch Managed
    READ TABLE lt_mara ASSIGNING <ls_mara> WITH KEY matnr = <ls_data_key>-matnr BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <ls_final>-batch_man = <ls_mara>-xchpf.
      <ls_final>-maktx = <ls_mara>-maktx.
    ENDIF.
*** Stock
    READ TABLE lt_stock_mard ASSIGNING <ls_stock_mard> WITH KEY matnr = <ls_data_key>-matnr werks = <ls_data_key>-werks.
    IF sy-subrc IS INITIAL.
      <ls_final>-ava_qty   = <ls_stock_mard>-labst.
    ELSE.
      READ TABLE lt_stock_mchb ASSIGNING <ls_stock_mchb> WITH KEY matnr = <ls_data_key>-matnr charg = <ls_data_key>-charg werks = <ls_data_key>-werks.
      IF sy-subrc IS INITIAL.
        <ls_final>-ava_qty   = <ls_stock_mchb>-clabs.
      ENDIF.
    ENDIF.

*** Purchage price & B1 batch
    READ TABLE lt_price_b ASSIGNING <ls_price_b> WITH KEY bwtar = <ls_data_key>-charg BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <ls_final>-b1_batch = <ls_price_b>-b1_batch.
      <ls_final>-pur_price = <ls_price_b>-verpr.
      <ls_final>-tot_price = <ls_final>-pur_price * <ls_final>-idoc_qty.
    ELSE.
*** Purchage Price for Non Batch Managed
      READ TABLE lt_price_nb ASSIGNING <ls_price_nb> WITH KEY matnr = <ls_data_key>-matnr BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <ls_final>-pur_price = <ls_price_nb>-verpr.
        <ls_final>-tot_price = <ls_final>-pur_price * <ls_final>-idoc_qty.
      ENDIF.
    ENDIF.

    <ls_final>-matnr    = <ls_data_key>-matnr.
    <ls_final>-werks    = <ls_data_key>-werks.
    <ls_final>-uom      = <ls_data_key>-uom.
    <ls_final>-charg    = <ls_data_key>-charg.

    DATA: ls_color  TYPE lvc_s_scol.
    IF abs( <ls_final>-idoc_qty ) > <ls_final>-ava_qty.
      <ls_final>-remarks = 'Deficit Quantity'.
      <ls_final>-status = c_0.
      APPEND VALUE #( fname = 'REMARKS' color-col = '6' color-int = '1' color-inv = '0' ) TO <ls_final>-color.
    ELSE.
      <ls_final>-remarks = 'Re-Process The IDocs'.
      <ls_final>-status = c_1.
      APPEND VALUE #( fname = 'REMARKS' color-col = '5' color-int = '1' color-inv = '0' ) TO <ls_final>-color.
    ENDIF.
  ENDLOOP.

  REFRESH : lt_price_nb , lt_price_b , lt_stock_mchb , lt_stock_mard , lt_mara , lt_data_key.
*** Display Data
  DATA : lr_alv       TYPE REF TO cl_salv_table,
         lr_cols      TYPE REF TO cl_salv_columns,
         lr_col       TYPE REF TO cl_salv_column,
         lr_functions TYPE REF TO cl_salv_functions,
         lr_display   TYPE REF TO cl_salv_display_settings.

  DATA: lo_table   TYPE REF TO cl_salv_table,
        lo_columns TYPE REF TO cl_salv_columns_table,
        lo_column  TYPE REF TO cl_salv_column_list.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
        IMPORTING
        r_salv_table   = lr_alv                       " Basis Class Simple ALV Tables
        CHANGING
        t_table        = gt_final ).

***   Column optimization
      lr_cols = lr_alv->get_columns( ).
      lr_cols->set_optimize( c_x ).
      lr_display = lr_alv->get_display_settings( ).
      lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).
*** Store
      TRY.
          lr_col = lr_cols->get_column( 'PUR_PRICE' ).
          lr_col->set_long_text( 'Pur Price' ).
          lr_col->set_medium_text( 'Pur Price' ).
          lr_col->set_short_text('Pur Price').

          lr_col = lr_cols->get_column( 'TOT_PRICE' ).
          lr_col->set_long_text( 'Total Price' ).
          lr_col->set_medium_text( 'Total Price' ).
          lr_col->set_short_text('Tot Price').

          lr_col = lr_cols->get_column( 'AVA_QTY' ).
          lr_col->set_long_text( 'Available Qty' ).
          lr_col->set_medium_text( 'Available Qty' ).
          lr_col->set_short_text('Avail Qty').

          lr_col = lr_cols->get_column( 'IDOC_QTY' ).
          lr_col->set_long_text( 'IDoc Qty' ).
          lr_col->set_medium_text( 'IDoc Qty' ).
          lr_col->set_short_text('IDoc Qty').

          lr_col = lr_cols->get_column( 'REMARKS' ).
          lr_col->set_long_text( 'Remarks' ).
          lr_col->set_medium_text( 'Remarks' ).
          lr_col->set_short_text('Remarks').

          lr_col = lr_cols->get_column( 'DOCNUM' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'SEGNUM' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'BATCH_MAN' ).
          lr_col->set_long_text( 'Batch Managed' ).
          lr_col->set_medium_text( 'Batch Managed' ).

          lr_col = lr_cols->get_column( 'B1_BATCH' ).
          lr_col->set_long_text( 'B1 Batch ' ).
          lr_col->set_medium_text( 'B1 Batch' ).

          lr_col = lr_cols->get_column( 'STATUS' ).
          lr_col->set_long_text( 'Status' ).
          lr_col->set_medium_text( 'Status' ).

          lo_columns = lr_alv->get_columns( ).
          lo_columns->set_color_column( 'COLOR' ).
        CATCH cx_salv_not_found.
      ENDTRY.
    CATCH cx_salv_msg.
  ENDTRY .

***  register to the events of cl_salv_table
  DATA: lr_events TYPE REF TO cl_salv_events_table.
  lr_events = lr_alv->get_event( ).
  CREATE OBJECT gr_events.
*** register to the event DOUBLE_CLICK
  SET HANDLER gr_events->on_double_click FOR lr_events.
  lr_alv->display( ).
ENDFORM.

FORM display_idocs USING row column.

*** Display Data
  DATA : lr_alv        TYPE REF TO cl_salv_table,
         lr_cols       TYPE REF TO cl_salv_columns,
         lr_col        TYPE REF TO cl_salv_column,
         lr_functions  TYPE REF TO cl_salv_functions,
         lr_display    TYPE REF TO cl_salv_display_settings,
         lt_final_idoc TYPE STANDARD TABLE OF ty_final.

  FIELD-SYMBOLS :
    <ls_final>  TYPE ty_final,
    <ls_finals> TYPE ty_final.


  READ TABLE gt_final ASSIGNING <ls_final> INDEX row.
  CHECK sy-subrc IS INITIAL.

*  lt_final_idoc = VALUE #( FOR ls_data IN gt_data        WHERE ( matnr = <ls_final>-matnr AND charg = <ls_final>-charg AND werks = <ls_final>-werks )
*                           FOR ls_hdr  IN gt_invoice_hdr WHERE ( idoc <> ls_data-docnum )
*                            ( docnum   = ls_data-docnum
*                             matnr    = ls_data-matnr
*                             werks    = ls_data-werks
*                             idoc_qty = ls_data-idoc_qty
*                             uom      = ls_data-uom
*                             charg    = ls_data-charg ) ).
  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<ls_data>) WHERE matnr = <ls_final>-matnr AND charg = <ls_final>-charg AND werks = <ls_final>-werks.
    READ TABLE gt_invoice_hdr ASSIGNING FIELD-SYMBOL(<ls_invoice_hdr>) WITH KEY idoc = <ls_data>-docnum.
    IF sy-subrc IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_final_idoc ASSIGNING <ls_finals>.
      <ls_finals>-docnum   = <ls_data>-docnum.
      <ls_finals>-matnr    = <ls_data>-matnr.
      <ls_finals>-maktx    = <ls_final>-maktx.
      <ls_finals>-werks    = <ls_data>-werks.
      <ls_finals>-idoc_qty = <ls_data>-idoc_qty.
      <ls_finals>-uom      = <ls_data>-uom.
      <ls_finals>-charg    = <ls_data>-charg.
    ELSE.
      READ TABLE gt_invoice_item ASSIGNING FIELD-SYMBOL(<ls_invoice_item>) WITH KEY vbeln = <ls_invoice_hdr>-invoice posnr = <ls_data>-segnum.
      IF sy-subrc IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_final_idoc ASSIGNING <ls_finals>.
        <ls_finals>-docnum   = <ls_data>-docnum.
        <ls_finals>-matnr    = <ls_data>-matnr.
        <ls_finals>-maktx    = <ls_final>-maktx.
        <ls_finals>-werks    = <ls_data>-werks.
        <ls_finals>-idoc_qty = <ls_data>-idoc_qty.
        <ls_finals>-uom      = <ls_data>-uom.
        <ls_finals>-charg    = <ls_data>-charg.
      ENDIF.
    ENDIF.
  ENDLOOP.
  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display   = if_salv_c_bool_sap=>false    " ALV Displayed in List Mode
        IMPORTING
        r_salv_table   = lr_alv                       " Basis Class Simple ALV Tables
        CHANGING
        t_table        = lt_final_idoc ).

***   Column optimization
      lr_cols = lr_alv->get_columns( ).
      lr_cols->set_optimize( c_x ).
      lr_display = lr_alv->get_display_settings( ).
      lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lr_functions = lr_alv->get_functions( ) .
      lr_functions->set_all( abap_true ).
*** Store
      TRY.
          lr_col = lr_cols->get_column( 'IDOC_QTY' ).
          lr_col->set_long_text( 'IDoc Qty' ).
          lr_col->set_medium_text( 'IDoc Qty' ).
          lr_col->set_short_text('IDoc Qty').

          lr_col = lr_cols->get_column( 'AVA_QTY' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'REMARKS' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'BATCH_MAN' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'STATUS' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'SEGNUM' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'PUR_PRICE' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'TOT_PRICE' ).
          lr_col->set_technical( 'X' ).

          lr_col = lr_cols->get_column( 'B1_BATCH' ).
          lr_col->set_technical( 'X' ).

        CATCH cx_salv_not_found.
      ENDTRY.
    CATCH cx_salv_msg.
  ENDTRY .

***  register to the events of cl_salv_table
  DATA: lr_events TYPE REF TO cl_salv_events_table.
  lr_events = lr_alv->get_event( ).
  CREATE OBJECT gr_events.
*** register to the event DOUBLE_CLICK
  SET HANDLER gr_events->on_double_click FOR lr_events.
  lr_alv->display( ).
ENDFORM.
