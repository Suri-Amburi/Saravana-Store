*&---------------------------------------------------------------------*
*& Include          ZSD_ERROR_IDOCS_TOP
*&---------------------------------------------------------------------*

  TYPES:
    BEGIN OF ty_final,
      pos_date TYPE char10,
      docnum   TYPE edid4-docnum,
      segnum   TYPE edid4-segnum,
      werks    TYPE mchb-werks,
      matnr    TYPE mchb-matnr,
      charg    TYPE mchb-charg,
      idoc_qty TYPE vbrp-lmeng,
      message  TYPE natxt,
    END OF ty_final,

    BEGIN OF ty_idoc_seg,
      docnum TYPE edidc-docnum,
      rcvprn TYPE edidc-rcvprn,
      status TYPE edidc-status,
      credat TYPE edidc-credat,
      segnam TYPE edid4-segnam,
      segnum TYPE edid4-segnum,
      dtinth TYPE edid4-dtint2,
      sdatah TYPE edid4-sdata,
      dtint  TYPE edid4-dtint2,
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
    gt_data        TYPE STANDARD TABLE OF ty_final,
    gt_idoc_seg    TYPE STANDARD TABLE OF ty_idoc_seg,
    gt_data_foldoc TYPE STANDARD TABLE OF ty_data_foldoc.

  DATA :
    gv_ccrdat TYPE edi_ccrdat,
    gv_docnum TYPE edi_docnum.

  CONSTANTS :
    c_x(1)     VALUE 'X',
    c_0(1)     VALUE '0',
    c_1(1)     VALUE '1',
    c_e(1)     VALUE 'E',
    c_space(1) VALUE space.
