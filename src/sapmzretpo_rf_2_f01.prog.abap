*&---------------------------------------------------------------------*
*& Include          SAPMZRETPO_RF_2_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form ALV_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_grid .

CREATE OBJECT container
   EXPORTING
     container_name = 'CONTAINER'.

  CREATE OBJECT grid
    EXPORTING
      i_parent   = container.

  CALL METHOD grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error = 1
      OTHERS = 2.

PERFORM exclude_tb_function CHANGING it_exclude.
PERFORM fill_1grid1.
PERFORM fill_1grid2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- IT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_tb_function   CHANGING lt_exclude TYPE ui_functions.
 DATA ls_exclude TYPE ui_func.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
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
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO lt_exclude.
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

  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_filter.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_expcrdata.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_export.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_help.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_load_variant.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_mb_variant.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_maximum.
  APPEND ls_exclude TO lt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_minimum.
  APPEND ls_exclude TO lt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_1GRID1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_1grid1.
REFRESH lt_fieldcat.


 PERFORM fc USING:
                   '01'  'CHECK'     'IT_FINAL'  'Check'  'Check'  'Check'    'X' ' ' '02'  ' '  ' ' ' ' ' '
                   CHANGING lt_fieldcat,
                   '01'  'EBELP'     'IT_FINAL'  'Item'  'Item'  'Item'    ' ' ' ' '06'  ' '  ' ' ' ' ' '
                   CHANGING lt_fieldcat,
                   '02'  'MATNR'     'IT_FINAL'  'SST No'  'SST No'  'SST No'    '' '' '10'  ''  'MARA' 'MATNR' ''
                   CHANGING lt_fieldcat,
                   '03'  'MAKTX'     'IT_FINAL'   'Descrip'   'Description'    'Description'    '' '' '16'  ''  ''     ''      ''
                   CHANGING lt_fieldcat,
                   '04'  'LIFNR'     'IT_FINAL'   'Vendor'     'Vendor'      'Vendor'        '' '' '10'  ''  ''     ''      ''
                   CHANGING lt_fieldcat,
                   '04'  'NAME1'     'IT_FINAL'   'Name'      'Name'      'Name'        '' '' '15'  ' '  ''     ''      ''
                   CHANGING lt_fieldcat,
                   '05'  'CHARG'     'IT_FINAL'   'Batch'      'Batch'       'Batch'        '' '' '10'  ''  ''     ''      ''
                   CHANGING lt_fieldcat,
                   '06'  'MENGE'     'IT_FINAL'   'Qty'        'Qty'          'Qty'           '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat,
                   '07'  'VERPR_F'    'IT_FINAL'   'Pur.Price'  'Purch.Price'  'Purch.Price'  '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat,
                   '08'  'DISC'     'IT_FINAL'   'Discount'     'Discount'     'Discount'     'X'  '' '08'  '' 'MSEG' 'MENGE' ' '
                   CHANGING lt_fieldcat,
                   '09'  'TAXPER'   'IT_FINAL'   'Tax %'        'Tax %'        'Tax %'        '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat,
                   '10'  'MRP'      'IT_FINAL'   'MRP'        'MRP'          'MRP'            '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat,
                   '11'  'SELP'    'IT_FINAL'   'Sel.Price'  'Sel.Price'  'Sel.Price'  '' '' '08'  ''  'MSEG' 'MENGE' ''
                   CHANGING lt_fieldcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_1GRID2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_1grid2 .

lw_layo-frontend = 'X'.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      is_layout                     = lw_layo
      it_toolbar_excluding          = it_exclude
    CHANGING
      it_outtab                     = it_final
      it_fieldcatalog               = lt_fieldcat
*      IT_SORT                       = LT_SORT
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4 .

  IF sy-subrc <> 0.
*   IMPLEMENT SUITABLE ERROR HANDLING HERE
  ENDIF.

CALL METHOD grid->set_ready_for_input
  EXPORTING
  i_ready_for_input = 1.

 CALL METHOD grid->set_toolbar_interactive.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      <-- LT_FIELDCAT1
*&---------------------------------------------------------------------*
FORM fc USING fp_colpos    TYPE sycucol
              fp_fldnam    TYPE fieldname
              fp_tabnam    TYPE tabname
              scrtext_s    TYPE scrtext_s
              scrtext_m    TYPE scrtext_m
              scrtext_l    TYPE scrtext_l
              edit         TYPE c
              do_sum       TYPE c
              olen         TYPE char2
              f4h          TYPE ddf4avail
              reftab       TYPE lvc_rtname
              reffld       TYPE lvc_rfname
              drdn_hndl    TYPE int4
         CHANGING lt_fieldcat TYPE  lvc_t_fcat.

  DATA: wa_fcat  TYPE  lvc_s_fcat.
  wa_fcat-row_pos        = '1'.     "ROW
  wa_fcat-col_pos        = fp_colpos.     "COLUMN
  wa_fcat-fieldname      = fp_fldnam.     "FIELD NAME
  wa_fcat-tabname        = fp_tabnam.     "INTERNAL TABLE NAME
  wa_fcat-edit           = edit.
  wa_fcat-outputlen      = olen.
  wa_fcat-do_sum         = do_sum.
  wa_fcat-f4availabl     = f4h.
  wa_fcat-scrtext_s      = scrtext_s.
  wa_fcat-scrtext_m      = scrtext_m.
  wa_fcat-scrtext_l      = scrtext_l.
  wa_fcat-reptext        = scrtext_l.
  wa_fcat-just           = 'L'.
  wa_fcat-ref_table      = reftab.
  wa_fcat-ref_field      = reffld.
  wa_fcat-drdn_hndl      = drdn_hndl.


  IF fp_fldnam = 'CHECK'.
    wa_fcat-checkbox       = 'X'.     "CHECK BOX FOR COMPLETE BREAK DOWN
  ENDIF.

  APPEND wa_fcat TO lt_fieldcat.
  CLEAR wa_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_po .
  DATA:
    purchaseorder TYPE bapimepoheader-po_number,
    it_pocond     TYPE TABLE OF bapimepocond,
    wa_pocond     TYPE  bapimepocond,
    it_pocondx    TYPE TABLE OF bapimepocondx,
    wa_pocondx    TYPE bapimepocondx,
    it_return     TYPE TABLE OF bapiret2.

REFRESH: it_pocond, it_pocondx, it_return.
purchaseorder = lv_ebeln.

LOOP AT it_final ASSIGNING FIELD-SYMBOL(<fs>).
    wa_pocond-itm_number = <fs>-ebelp.
    wa_pocond-cond_type  = 'ZDS1'.
    wa_pocond-calctypcon = 'A' .
    wa_pocond-cond_value = <fs>-disc * -1.
    wa_pocond-change_id  = 'U'.
    APPEND wa_pocond TO it_pocond.
    CLEAR wa_pocond.

    wa_pocondx-itm_number = <fs>-ebelp.
    wa_pocondx-itm_numberx = 'X'.
    wa_pocondx-cond_type   = 'X'.
    wa_pocondx-cond_value  = 'X'.
    wa_pocondx-calctypcon  = 'X'.
    wa_pocondx-change_id   = 'X'.
    APPEND wa_pocondx TO it_pocondx.
    CLEAR wa_pocondx.
ENDLOOP.

CALL FUNCTION 'BAPI_PO_CHANGE'
  EXPORTING
    purchaseorder                = purchaseorder
 TABLES
   return                       = it_return
   pocond                       = it_pocond
   pocondx                      = it_pocondx.


READ TABLE it_return ASSIGNING FIELD-SYMBOL(<ret>) WITH KEY type = 'E'.
  IF sy-subrc <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
     EXPORTING
       wait          = 'X' .
    MESSAGE 'PO CHANGED' TYPE 'S'.
  ELSE.
   MESSAGE <ret>-message_v2 && <ret>-message TYPE <ret>-type .
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEBIT_NOTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grn .

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
  SELECT * FROM ekpo INTO TABLE @DATA(lt_ekpo) WHERE ebeln = @lv_ebeln AND loekz = ' '.
  SELECT DISTINCT ebeln,ebelp,charg FROM eket INTO TABLE @DATA(it_ekbe) FOR ALL ENTRIES IN
                  @lt_ekpo WHERE ebeln = @lt_ekpo-ebeln AND ebelp = @lt_ekpo-ebelp AND charg <> ' '.
*** FILL THE BAPI HEADER STRUCTURE DETAILS
  ls_gmvt_header-pstng_date = sy-datum.
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

**************************************************************************
  READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_ret>) WITH KEY type = 'E'.
  IF sy-subrc <> 0 .
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    gv_mblnr_n = ls_gmvt_headret-mat_doc.

   REFRESH: lt_ekpo, it_ekbe, lt_gmvt_item , lt_bapiret.
   CLEAR: ls_gmvt_header,ls_gmvt_header, wa_ekbe. " <ls_grn>.

    PERFORM debit_note .  ">>>>>>>>>>.....

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
 ENDIF.

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

  TYPES: BEGIN OF ty_mkpf1,
          mblnr TYPE mblnr,
          xblnr TYPE char20,
         END OF ty_mkpf1.
 DATA : it_mkpf1 TYPE TABLE OF ty_mkpf1.


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
           ekpo~werks,
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
           WHERE ekko~ebeln = @lv_ebeln AND konp~loevm_ko = @space AND ekpo~loekz = ' '.

***********************************************************************************************
  SELECT DISTINCT ebeln,ebelp,charg FROM eket INTO TABLE @DATA(it_eket)  WHERE ebeln = @lv_ebeln
                                                                         AND charg <> ' '.
  SELECT mblnr,charg FROM mseg INTO TABLE @DATA(it_mseg) FOR ALL ENTRIES IN @it_eket WHERE charg = @it_eket-charg
                                                                                     AND bwart IN ( '101' , '107' ).
  SELECT mblnr,xblnr FROM mkpf INTO TABLE @DATA(it_mkpf) FOR ALL ENTRIES IN @it_mseg WHERE mblnr = @it_mseg-mblnr.
   REFRESH it_mkpf1.
   it_mkpf1 =  it_mkpf.
  SELECT qr_code,bill_num FROM zinw_t_hdr INTO TABLE @DATA(it_hdr) FOR ALL ENTRIES IN @it_mkpf1
                                            WHERE qr_code = @it_mkpf1-xblnr.


************************************************************************************************
    CHECK lt_debit IS NOT INITIAL.
    SORT lt_debit BY mblnr zeile.
    DELETE ADJACENT DUPLICATES FROM lt_debit COMPARING ebeln ebelp.
  LOOP AT it_hdr INTO DATA(hdr).
    CONCATENATE hdr-bill_num headerdata-item_text INTO headerdata-item_text SEPARATED BY ','.
  ENDLOOP.
    headerdata-item_text    =
    headerdata-doc_date     = sy-datum.
    headerdata-pstng_date   = sy-datum.
    headerdata-bline_date   = sy-datum.
    headerdata-calc_tax_ind = 'X'.
    headerdata-ref_doc_no   = lv_ebeln.
    headerdata-secco = headerdata-business_place = '1000'.
    DATA(lv_werks) = lt_debit[ 1 ]-werks.
    SELECT SINGLE gsber FROM t134g INTO headerdata-bus_area WHERE werks = lv_werks.
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
      REFRESH: it_final, it_log , itemdata ,lt_debit, it_eket, it_mseg, it_mkpf1, it_mkpf, it_hdr.
      CLEAR: headerdata,invoicedocnumber_dn,fiscalyear, lv_ebeln .
      CALL METHOD grid->refresh_table_display.
    ELSE.
      LOOP AT return INTO lw_return2 WHERE type = 'E'.

        APPEND VALUE #( type  = lw_return2-type
                        id    = lw_return2-id
                        txtnr = lw_return2-number
                        msgv1 = lw_return2-message_v1
                        msgv2 = lw_return2-message_v2 ) TO it_log.
      ENDLOOP.
      PERFORM reverse_101.
      CLEAR: lv_ebeln, gv_mblnr_n.
      REFRESH: itemdata ,lt_debit, it_eket, it_mseg, it_mkpf1, it_mkpf, it_hdr.
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
      goodsmvt_pstng_date = '20200229' "sy-datum
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
*& Form PRINT_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_form .
    CALL FUNCTION 'ZFM_PURCHASE_FORM1'
      EXPORTING
        lv_ebeln               = lv_ebeln
       vendor_debit_note        = 'X'
       print_prieview           = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_line .
 DATA:  wa_pur            TYPE bapimepoheader-po_number,
        it_poitemn        TYPE STANDARD TABLE OF bapimepoitem,
        wa_poitemn        TYPE bapimepoitem,
        it_poitemnx       TYPE STANDARD TABLE OF bapimepoitemx,
        wa_poitemnx       TYPE bapimepoitemx,
        it_returnn        TYPE TABLE OF bapiret2.


  IF lv_ebeln IS NOT INITIAL.

    wa_pur = lv_ebeln.
CLEAR: wa_pur,it_poitemn, wa_poitemn , it_poitemnx ,it_returnn .
    LOOP AT it_final ASSIGNING FIELD-SYMBOL(<po>) WHERE check = 'X'.
      wa_poitemn-po_item     = <po>-ebelp.
      wa_poitemn-delete_ind  = 'X'.
      wa_poitemnx-po_item     = <po>-ebelp.
      wa_poitemnx-po_itemx    = 'X'.
      wa_poitemnx-delete_ind  = 'X'.

      APPEND wa_poitemn TO it_poitemn.
      APPEND wa_poitemnx TO it_poitemnx.

      CLEAR: wa_poitemn,wa_poitemnx.

    ENDLOOP.

  IF it_poitemn IS  INITIAL.
    MESSAGE 'No item has selected' TYPE 'E'.
  ENDIF.


    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = wa_pur
      TABLES
        return        = it_returnn
        poitem        = it_poitemn
        poitemx       = it_poitemnx.

  READ TABLE it_returnn ASSIGNING FIELD-SYMBOL(<ret>) WITH KEY type = 'E' .
    IF sy-subrc <> 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      MESSAGE 'Line item has deleted from PO' TYPE 'S'.
    ENDIF.


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
      lv_tot = lv_tot + wa_fin-verpr_f.
    ENDLOOP.

    IF lv_tot > total.
      MESSAGE 'Insufficient Vendor Balance.' TYPE 'E'.
    ENDIF.


  ENDIF.

   CLEAR total.
ENDFORM.
