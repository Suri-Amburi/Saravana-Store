*&---------------------------------------------------------------------*
*& Report ZSMALL_LABLE_PRINT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsmall_lable_print.

CONSTANTS :
  c_x(1) VALUE 'X'.

PARAMETERS :
  p_charg  TYPE charg_d,
  p_no_prt TYPE int4.

DATA :
  form_name TYPE rs38l_fnam,
  ls_cparam TYPE ssfctrlop,
  ls_output TYPE ssfcompop.

***  Fetching Material Details
IF p_charg IS NOT INITIAL.
  SELECT matdoc~mblnr,
       matdoc~zeile,
       matdoc~mjahr,
       matdoc~matnr,
       matdoc~ebeln,
       matdoc~ebelp,
       matdoc~menge,
       matdoc~charg,
       matdoc~budat,
       zinw_t_hdr~qr_code,
       mara~zzlabel_desc,
       zinw_t_item~maktx,
       zinw_t_item~netpr_s,
       zinw_t_item~matkl
       INTO TABLE @DATA(lt_doc)
       FROM  matdoc AS matdoc
       INNER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~mblnr = matdoc~mblnr
       INNER JOIN zinw_t_item ON zinw_t_hdr~qr_code = zinw_t_item~qr_code AND zinw_t_item~ebeln = matdoc~ebeln AND zinw_t_item~ebelp = matdoc~ebelp
       INNER JOIN mara AS mara ON mara~matnr = zinw_t_item~matnr
       WHERE matdoc~charg = @p_charg.
  IF sy-subrc <> 0.
***  For Local Purchage
    SELECT matdoc~mblnr
           matdoc~zeile
           matdoc~mjahr
           matdoc~matnr
           matdoc~ebeln
           matdoc~ebelp
           matdoc~menge
           matdoc~charg
           matdoc~budat
           zinw_t_hdr~qr_code
           mara~zzlabel_desc
           zinw_t_item~maktx
           zinw_t_item~netpr_s
           zinw_t_item~matkl
           INTO TABLE lt_doc
           FROM  matdoc AS matdoc
           INNER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~mblnr_103 = matdoc~mblnr
           INNER JOIN zinw_t_item ON zinw_t_hdr~qr_code = zinw_t_item~qr_code AND zinw_t_item~ebeln = matdoc~ebeln AND zinw_t_item~ebelp = matdoc~ebelp
           INNER JOIN mara AS mara ON mara~matnr = zinw_t_item~matnr
           WHERE matdoc~charg = p_charg.
  ENDIF.
ENDIF.

IF lt_doc IS NOT INITIAL.
  DELETE lt_doc WHERE charg IS INITIAL.
  SORT lt_doc BY mblnr matnr.
  DELETE ADJACENT DUPLICATES FROM lt_doc COMPARING mblnr matnr zeile.
  CHECK lt_doc IS NOT INITIAL.
  ls_cparam-no_open = space.
  ls_cparam-no_close = c_x.
  ls_cparam-device = 'PRINTER'.
  ls_output-tdimmed = c_x.
  ls_output-tdnoprev = c_x.

***   Getting Dynamic FM
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZSMALL_LABLES'
    IMPORTING
      fm_name            = form_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
***  printing All multible prints
  CHECK lt_doc IS NOT INITIAL AND p_no_prt IS NOT INITIAL.
  READ TABLE lt_doc INTO DATA(ls_doc) WITH KEY charg = p_charg.
  CHECK sy-subrc = 0.
  DATA : lv_price TYPE int4.
  lv_price = ceil( ls_doc-netpr_s ).
  CALL FUNCTION form_name
    EXPORTING
      control_parameters = ls_cparam
      output_options     = ls_output
      user_settings      = 'X'
      i_batch            = ls_doc-charg
      i_no_prints        = p_no_prt
      i_price            = lv_price
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  REFRESH : lt_doc.
ELSE.
  MESSAGE 'Invalid Batch' TYPE 'S' DISPLAY LIKE 'E'.
ENDIF.
