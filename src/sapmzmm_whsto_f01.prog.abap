*&---------------------------------------------------------------------*
*& Include          SAPMZMM_WHSTO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SCONTAINER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM scontainer .
  IF scont IS INITIAL.
    REFRESH: xfcat, xsort.
    IF lt_fcat[] IS INITIAL.
      PERFORM prepare_fcatlog .
    ENDIF.

    ls_layo-zebra       = 'X'.
**    ls_layo-stylefname = 'STYLE'.
**    ls_layo-cwidth_opt  = 'X'.
    ls_layo-no_toolbar  = space.
    ls_layo-grid_title  = title.
    ls_layo-sel_mode    = sel_mode.
    x-report = sy-repid .

***    PERFORM exclude_toolbar .
    IF lt_toolbar_excluding IS INITIAL.
***      lt_toolbar_excluding = VALUE #( ( cl_gui_alv_grid=>mc_fc_excl_all ) ).
      lt_toolbar_excluding =  VALUE #(   ( cl_gui_alv_grid=>mc_fc_loc_insert_row    )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste         )
                          ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy          )
                          ( cl_gui_alv_grid=>mc_fc_loc_copy_row      )
                          ( cl_gui_alv_grid=>mc_fc_loc_cut           )
                          ( cl_gui_alv_grid=>mc_fc_loc_undo          )
                          ( cl_gui_alv_grid=>mc_fc_loc_append_row    )
                          ( cl_gui_alv_grid=>mc_fc_print             )
                          ( cl_gui_alv_grid=>mc_fc_loc_move_row      )
                          ( cl_gui_alv_grid=>mc_fc_find_more         )
                          ( cl_gui_alv_grid=>mc_fc_sum               )
                          ( cl_gui_alv_grid=>mc_fc_average           )
                          ( cl_gui_alv_grid=>mc_fc_maximum           )
                          ( cl_gui_alv_grid=>mc_fc_minimum           )
                          ( cl_gui_alv_grid=>mc_fc_detail           )
                         ).
    ENDIF.
    CREATE OBJECT scont EXPORTING container_name = cont.
    CREATE OBJECT sgrid EXPORTING i_parent = scont.
***    PERFORM grid_input USING 1 .
    PERFORM register_events .
    CALL METHOD sgrid->set_table_for_first_display
      EXPORTING
        is_layout            = ls_layo
***        i_structure_name = 'ZMIRO01'
        is_variant           = x
        i_save               = 'A'
        i_default            = 'X'
        it_toolbar_excluding = lt_toolbar_excluding[]
      CHANGING
        it_outtab            = xsto_itm[]
        it_fieldcatalog      = lt_fcat[]
*       it_sort              = xsort[]
*       IT_FILTER            = XFILT[]
      .
*Create object of the event class and setting handler for double click
***    CREATE OBJECT seventr.
***    SET HANDLER seventr->handle_hotspot_click FOR sgrid.
  ELSE.
    DATA ls_stable TYPE lvc_s_stbl.

    ls_stable-row = abap_true.
    ls_stable-col = abap_true.
    CALL METHOD sgrid->refresh_table_display
      EXPORTING
        is_stable = ls_stable   " With Stable Rows/Columns
*       i_soft_refresh =     " Without Sort, Filter, etc.
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_FCATLOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_fcatlog .
  DATA: wa_fc  TYPE  lvc_s_fcat.
  DATA : sno TYPE int4 .
  DATA: lo_struct_descr TYPE REF TO cl_abap_structdescr,
        lv_abs_name     TYPE dd02l-tabname,
        lv_pos          TYPE i VALUE 0.

  IF fieldcat[] IS INITIAL.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
*       I_BUFFER_ACTIVE        =
        i_structure_name       = 'ZSTO_ITM'
*       I_CLIENT_NEVER_DISPLAY = 'X'
*       I_BYPASSING_BUFFER     =
*       I_INTERNAL_TABNAME     =
      CHANGING
        ct_fieldcat            = lt_fcat[]
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
*    implement suitable error handling here
    ENDIF.

***    DELETE fieldcat WHERE fieldname = 'STATUS' .
    DELETE fieldcat WHERE fieldname = 'MANDT' .
  ENDIF.
  CLEAR lv_pos .
  CLEAR ls_fcat.
  LOOP AT lt_fcat INTO ls_fcat.
    CASE ls_fcat-fieldname.
      WHEN 'MATNR'.
        ls_fcat-outputlen = 14.
      WHEN 'MAKTX'.
        ls_fcat-outputlen = 25.
      WHEN 'MATKL'.
        ls_fcat-scrtext_l = ls_fcat-scrtext_m = ls_fcat-scrtext_s = 'Categ.Code'.
      WHEN 'B1_CHARG'.
        ls_fcat-scrtext_l = ls_fcat-scrtext_m = ls_fcat-scrtext_s = 'B1 Batch'.
        ls_fcat-outputlen = 16.
      WHEN 'S4_CHARG'.
        ls_fcat-scrtext_l = ls_fcat-scrtext_m = ls_fcat-scrtext_s = 'S4 Batch'.
      WHEN 'MENGE'.
        ls_fcat-edit = abap_true.
        ls_fcat-outputlen = 10.
      WHEN 'VERPR'.
        ls_fcat-scrtext_l = ls_fcat-scrtext_m = ls_fcat-scrtext_s = 'Purch.Price'.
      WHEN OTHERS.
    ENDCASE.
    MODIFY lt_fcat FROM ls_fcat INDEX sy-tabix TRANSPORTING scrtext_l scrtext_m scrtext_s outputlen edit.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form REGISTER_EVENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_events .
****  FREE g_event_receiver .
****  CREATE OBJECT g_event_receiver.
****  SET HANDLER g_event_receiver->handle_on_f4 FOR sgrid.
****  SET HANDLER g_event_receiver->handle_data_changed FOR sgrid.
********  SET HANDLER g_event_receiver->handle_double_click FOR sgrid. "commented by sjena on 22.12.2018 23:31:20
********  SET HANDLER g_event_receiver->handle_hotspot_click FOR sgrid.
****  SET HANDLER g_event_receiver->handle_user_command FOR sgrid .
****  " Set
****
****
*****--> Commented_as_added_buttons_separately_for_User_friendly_inputs -> sjena <- 18.05.2019 13:23:19
*****CREATE alv event handler
****  CREATE OBJECT c_alv_toolbar
****    EXPORTING
****      io_alv_grid = sgrid.
***** Register event handler
********  SET HANDLER c_alv_toolbar->on_toolbar FOR sgrid.


*  registering the EDIT Event

  CALL METHOD sgrid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.                                 " IF SY-SUBRC NE 0
ENDFORM.
*&---------------------------------------------------------------------*
*& Form STO_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- SSUBRC
*&---------------------------------------------------------------------*
FORM sto_create  CHANGING ssubrc TYPE sy-subrc
                          xsto_hdr_ebeln TYPE ebeln
                          xsto_hdr_vbeln TYPE vbeln_vl.
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
  ls_poheader-suppl_plnt = xsto_hdr-swerks.

  ls_poheaderx-comp_code = 'X'.
  ls_poheaderx-doc_type = 'X'.
  ls_poheaderx-purch_org = 'X'.
  ls_poheaderx-pur_group = 'X'.
  ls_poheaderx-currency = 'X'.
  ls_poheaderx-suppl_plnt = 'X'.

  LOOP AT xsto_itm.
    lv_line = lv_line + 1.
    ls_poitem-po_item = lv_line.
    ls_poitem-material = xsto_itm-matnr.
    ls_poitem-plant = xsto_hdr-rwerks.
    ls_poitem-stge_loc = 'FG01'.
    ls_poitem-batch = xsto_itm-s4_charg.
****    READ TABLE gt_list INTO DATA(xsto_itm) WITH KEY batch = xsto_itm-b1_batch.
    ls_poitem-quantity = xsto_itm-menge.
    ls_poitem-po_unit = xsto_itm-meins.
    ls_poitem-po_unit_iso = xsto_itm-meins.
    ls_poitem-gi_based_gr = 'X'.

    ls_poitemx-po_item = lv_line.
    ls_poitemx-po_itemx = 'X'.
    ls_poitemx-material = 'X'.
    ls_poitemx-plant = 'X'.
    ls_poitemx-stge_loc = 'X'.
    ls_poitemx-batch = 'X'.
    ls_poitemx-quantity = 'X'.
    ls_poitemx-po_unit = 'X'.
    ls_poitemx-po_unit_iso = 'X'.
    ls_poitemx-gi_based_gr = 'X'.
    APPEND ls_poitem TO lt_poitem.
    APPEND ls_poitemx TO lt_poitemx.
    CLEAR:ls_poitem,ls_poitemx,xsto_itm.
  ENDLOOP.


  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      poheader         = ls_poheader
      poheaderx        = ls_poheaderx
    IMPORTING
      exppurchaseorder = xsto_hdr_ebeln
    TABLES
      return           = lt_return
      poitem           = lt_poitem
      poitemx          = lt_poitemx.


  IF xsto_hdr_ebeln IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    ls_sto_items-ref_doc =  xsto_hdr_ebeln.
    APPEND ls_sto_items TO lt_sto_items.

    CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_STO'
      EXPORTING
        ship_point        = xsto_hdr-swerks
*       DUE_DATE          =
*       DEBUG_FLG         =
*       NO_DEQUEUE        = ' '
      IMPORTING
        delivery          = xsto_hdr_vbeln
*       NUM_DELIVERIES    =
      TABLES
        stock_trans_items = lt_sto_items.

    IF xsto_hdr_vbeln IS NOT INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      lv_msg = 'Delivery  ' && xsto_hdr_vbeln && space && '  created' .
      MESSAGE lv_msg TYPE 'S'.
    ELSE.
      ssubrc = 4.
***      PERFORM refresh_screen.
    ENDIF.
  ELSE.
    ssubrc = 4.
  ENDIF.
ENDFORM.
