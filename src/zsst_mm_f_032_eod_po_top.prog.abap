*&---------------------------------------------------------------------*
*& Include          ZSST_MM_F_032_EOD_PO_TOP
*&---------------------------------------------------------------------*

TABLES ekko.
DATA  : fm_name  TYPE rs38l_fnam .

TYPES : BEGIN OF ty_ekko,
          ebeln TYPE ekko-ebeln,
          aedat TYPE ekko-aedat,
          ekgrp TYPE ekko-ekgrp,
          lifnr TYPE ekko-lifnr,
          bsart TYPE ekko-bsart,
          ebelp TYPE ekpo-ebelp,
          retpo TYPE ekpo-retpo,
          netwr TYPE ekpo-netwr,
          menge TYPE ekpo-menge,
        END OF ty_ekko,

        BEGIN OF ty_ek,
          ebeln TYPE ekko-ebeln,
          aedat TYPE ekko-aedat,
          ekgrp TYPE ekko-ekgrp,
          lifnr TYPE ekko-lifnr,
          bsart TYPE ekko-bsart,
        END OF ty_ek,

        BEGIN OF ty_ekgrp,
          ekgrp TYPE ekko-ekgrp,
        END OF ty_ekgrp,

        BEGIN OF ty_ekpo,
          ebeln TYPE ekpo-ebeln,
          ebelp TYPE ekpo-ebelp,
          retpo TYPE ekpo-retpo,
          netwr TYPE ekpo-netwr,
          menge TYPE ekpo-menge,
        END OF ty_ekpo,

        BEGIN OF ty_t024,
          ekgrp TYPE t024-ekgrp,
          eknam TYPE t024-eknam,
        END OF ty_t024,

        BEGIN OF ty_lfa1,
          lifnr TYPE lfa1-lifnr,
          name1 TYPE lfa1-name1,
          ort01 TYPE lfa1-ort01,
        END OF ty_lfa1,

        BEGIN OF ty_slt,
          sr_no  TYPE int4,
          ven_no TYPE lfa1-lifnr,
          desc   TYPE lfa1-name1,
          loc    TYPE lfa1-ort01,
          ebeln  TYPE ekko-ebeln,
          menge  TYPE ekpo-menge,
          netwr  TYPE ekpo-netwr,
        END OF ty_slt,

        BEGIN OF ty_final,
          group  TYPE t024-eknam,
          no_po  TYPE int4,
          or_qty TYPE ekpo-menge,
          ntwr   TYPE ekpo-netwr,
        END OF ty_final.

TYPES: BEGIN OF ty_ekko1,
         ebeln TYPE ekko-ebeln,
         aedat TYPE ekko-aedat,
         ekgrp TYPE ekko-ekgrp,
         lifnr TYPE ekko-lifnr,
         bsart TYPE ekko-bsart,
         ebelp TYPE ekpo-ebelp,
         retpo TYPE ekpo-retpo,
         netwr TYPE ekpo-netwr,
         menge TYPE ekpo-menge,
         name1 TYPE lfa1-name1,
         ort01 TYPE lfa1-ort01,
       END OF ty_ekko1.

DATA  : sr_no    TYPE int4,
        count    TYPE int4,
        tot_qty  TYPE ekpo-menge,
        tot_po   TYPE int4,
        tot_ntwr TYPE ekpo-netwr,
        lv_lifnr TYPE ekko-lifnr,
        lv_field TYPE char20,
        gv_date  TYPE ekko-aedat.   " FOR SELECTION OPTION


DATA  : it_ekko   TYPE TABLE OF ty_ekko,
        it_ekpo   TYPE TABLE OF ty_ekpo,
        it_ek     TYPE TABLE OF ty_ek,
        it_ekgrp  TYPE TABLE OF ty_ekgrp,
        it_t024   TYPE TABLE OF ty_t024,
        it_slt    TYPE TABLE OF ty_slt,
        it_lfa1   TYPE TABLE OF ty_lfa1,
        it_table  TYPE REF   TO cl_salv_table,
        it_tab    TYPE REF   TO cl_salv_table,
        it_events TYPE REF   TO cl_salv_events_table,
        it_final  TYPE TABLE OF zsst_mm_f_032_stct.

DATA: it_ekko1 TYPE TABLE OF ty_ekko1,
      wa_ekko1 TYPE ty_ekko1.

DATA  : wa_ekko  TYPE ty_ekko,
        wa_ekpo  TYPE ty_ekpo,
        wa_ek    TYPE ty_ek,
        wa_ekgrp TYPE ty_ekgrp,
        wa_t024  TYPE ty_t024,
        wa_slt   TYPE ty_slt,
        wa_lfa1  TYPE ty_lfa1,
        wa_final TYPE zsst_mm_f_032_stct.

DATA : lr_columns   TYPE REF TO cl_salv_columns_table, "columns instance
       lr_col       TYPE REF TO cl_salv_column_table,  " column instance
       lo_functions TYPE REF TO cl_salv_functions_list.

DATA: lo_header  TYPE REF TO cl_salv_form_layout_grid,
      lo_h_label TYPE REF TO cl_salv_form_label,
      lo_h_flow  TYPE REF TO cl_salv_form_layout_flow.

DATA: lo_aggrs TYPE REF TO cl_salv_aggregations.
*      IT_TABL  LIKE TABLE.


CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.

    METHODS: on_link_click   FOR EVENT link_click OF
                cl_salv_events_table
      IMPORTING row column.

ENDCLASS.                    "lcl_handle_events DEFINITION
DATA: event_handler TYPE REF TO lcl_handle_events.
