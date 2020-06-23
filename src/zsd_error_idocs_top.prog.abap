*&---------------------------------------------------------------------*
*& Include          ZSD_ERROR_IDOCS_TOP
*&---------------------------------------------------------------------*

  TYPES:
    BEGIN OF ty_final,
      matnr       TYPE mchb-matnr,
      maktx       TYPE maktx,
      werks       TYPE mchb-werks,
      charg       TYPE mchb-charg,
      idoc_qty    TYPE menge_d,
      uom         TYPE meins,
      ava_qty     TYPE menge_d,
      b1_batch    TYPE zb1_btch,
      pur_price   TYPE dmbtr_cs,
      tot_price   TYPE dmbtr_cs,
      docnum      TYPE edid4-docnum,
      segnum      TYPE edid4-segnum,
      batch_man   TYPE xchpf,
      status(1),
      remarks(25),
      color       TYPE lvc_t_scol,
    END OF ty_final,

    BEGIN OF ty_idoc_seg,
      docnum TYPE edidc-docnum,
      rcvprn TYPE edidc-rcvprn,
      status TYPE edidc-status,
      credat TYPE edidc-credat,
      segnam TYPE edid4-segnam,
      segnum TYPE edid4-segnum,
      sdata  TYPE edid4-sdata,
    END OF ty_idoc_seg,

    BEGIN OF ty_data_foldoc,
      idoc        TYPE edidc-docnum,
      segnum      TYPE edidd-segnum,
      segnum_end  TYPE edidd-segnum,
***   Upload key
      uploadkey   TYPE wpusa_uploadkey,
***   Index to keep follow-on documents in the order they were written
      index       TYPE sy-tabix,
***   Object type of follow-on document
      objtype     TYPE objectconn-objecttype,
***   Key of follow-on document
      key         TYPE wpusa_doc_key,
***   Flag if the current record is the external document:
      extdoc_flag TYPE wpusa_extdoc_flag,
***   Level of follow-on document in case of an hierarchical structure
      level(2)    TYPE n,
***   Attributes of follow-on document. Field can be used freely.
      attr(10),
***   Data TYPE WPUSA_T_FOLDOC,
    END OF ty_data_foldoc,

    BEGIN OF ty_invoice_hdr,
      idoc    TYPE edidc-docnum,
      invoice TYPE vbeln_vf,
    END OF ty_invoice_hdr,

    BEGIN OF ty_invoice_item,
      vbeln TYPE vbeln_vf,
      posnr TYPE posnr,
    END OF ty_invoice_item.

  DATA:
    gt_final        TYPE STANDARD TABLE OF ty_final,
    gt_data         TYPE STANDARD TABLE OF ty_final,
    gt_idoc_seg     TYPE STANDARD TABLE OF ty_idoc_seg,
    gt_data_foldoc  TYPE STANDARD TABLE OF ty_data_foldoc,
    gt_invoice_hdr  TYPE STANDARD TABLE OF ty_invoice_hdr,
    gt_invoice_item TYPE STANDARD TABLE OF ty_invoice_item.

  DATA :
     gv_ccrdat TYPE edi_ccrdat,
     gv_docnum type edi_docnum.

  CONSTANTS :
    c_x(1)     VALUE 'X',
    c_0(1)     VALUE '0',
    c_1(1)     VALUE '1',
    c_space(1) VALUE space.

*** Class
*** Definition is later
  CLASS lcl_handle_events DEFINITION DEFERRED.
*** object for handling the events of cl_salv_table
  DATA: gr_events TYPE REF TO lcl_handle_events.

  CLASS lcl_handle_events DEFINITION.
    PUBLIC SECTION.
      METHODS:
        on_double_click FOR EVENT double_click OF cl_salv_events_table
          IMPORTING row column.
  ENDCLASS.

*** implement the events for handling the events of cl_salv_table
  CLASS lcl_handle_events IMPLEMENTATION.

    METHOD on_double_click.
      PERFORM display_idocs USING row column.
    ENDMETHOD.                    "on_double_click

  ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
