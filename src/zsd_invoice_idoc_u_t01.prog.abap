*&---------------------------------------------------------------------*
*& Include          ZSD_INVOICE_IDOC_U_T01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          ZSALES_MASS_UPLOAD_TOP
*&---------------------------------------------------------------------*

*** Type Declearations
TYPES :
  BEGIN OF ty_file,
    store(4),
    belegdatum(10),
    belegwaers(3),
    package_id(40),
    qualartnr(4),
    artnr(40),
    aktionsnr(10),
    vorzmenge(1),
    umsmenge(35),
    umswert(35),
    sales_uom(5),
    c_sign(1),
    c_taxcode(4),
    c_taxvalue(35),
    s_sign(1),
    s_taxcode(4),
    s_taxvalue(35),
  END OF ty_file,

  BEGIN OF ty_result,
    store(4),
    belegdatum(10),
    idoc           TYPE edi_docnum,
    message        TYPE etmessage,
  END OF ty_result.

*** Table Declearations
DATA :
  gt_file                 TYPE TABLE OF ty_file,
  gs_file                 TYPE ty_file,
  gt_result               TYPE TABLE OF ty_result,
  gt_idoc_contrl          TYPE TABLE OF edidc WITH HEADER LINE,
  gt_idoc_data            TYPE STANDARD TABLE OF edidd,
  gt_idoc_status          TYPE TABLE OF bdidocstat,
  gt_return_variables     TYPE TABLE OF bdwfretvar,
  gt_serialization_info   TYPE TABLE OF bdi_ser,
  gs_idoc_contrl          TYPE edidc,
  gs_control_record_db_in TYPE edidc,
  gs_status_record        TYPE edi_ds.

*** Data Declearations
DATA :
  gv_fname    TYPE localfile,  " File Name
  gv_ename(4),                 " Extenstion
  gv_a_file   TYPE string ,    " Application File Path
  gv_logsys   TYPE logsys,
  gv_seg      TYPE edid4-segnum.

*** Constants
CONSTANTS :
  c_x(1)       VALUE 'X',
  c_fail(6)    VALUE 'Fail',
  c_success(7) VALUE 'Success',
  c_job        TYPE tbtcjob-jobname    VALUE 'ZSALES_UPLOAD',
  c_false      TYPE boolean VALUE space.
