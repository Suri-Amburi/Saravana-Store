*&---------------------------------------------------------------------*
*& Include          ZMM_TRNS_DET_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

*****  SELECT
*****    ekko~ebeln,
*****    ekko~aedat,
*****    ekko~lifnr,
*****    zinw_t_hdr~name1,
*****    zinw_t_hdr~lr_no,
*****    zinw_t_hdr~lr_date,
*****    zinw_t_hdr~inwd_doc,
*****    zinw_t_hdr~service_po,
******    zinw_t_item~netwr_p,
**************    zinw_t_item~menge,
******    zinw_t_item~netpr_p,
*****    ekpo~ebelp,
*****    ekpo~matnr,
*****    ekpo~menge,
*****    ekpo~mwskz,
*****    ekpo~netpr,
*****    ekpo~netwr
*****    FROM ekko AS ekko
*****    LEFT OUTER JOIN zinw_t_hdr AS zinw_t_hdr ON zinw_t_hdr~service_po = ekko~ebeln
******    INNER JOIN  zinw_t_item AS zinw_t_item ON zinw_t_hdr~ebeln = zinw_t_item~ebeln AND zinw_t_hdr~QR_CODE = zinw_t_item~QR_CODE
*****    INNER JOIN ekpo AS ekpo ON ekpo~ebeln =  ekko~ebeln
*****    WHERE ekko~lifnr IN @s_ven AND ekko~bsart = 'ZTSR'
*****    INTO TABLE @DATA(it_item).

  DATA(lv_select) = cl_shdb_seltab=>combine_seltabs(
   it_named_seltabs = VALUE #( ( name = 'LIFNR' dref = REF #( s_ven[] ) )
                               )

                               iv_client_field = 'MANDT'
                                ) .

  ztra=>get_output_prd(
EXPORTING
*    lv_date       = s_date-high
lv_select     = lv_select
IMPORTING
et_final_data = it_item
).

  DELETE it_item WHERE service_po IS INITIAL.

  BREAK ppadhy.
**SORT IT_ITEM BY
*****  IF vendor IS NOT INITIAL .
*****    SELECT
*****      ebeln
*****      aedat
*****      lifnr
*****      FROM ekko INTO TABLE it_ekko
*****      WHERE lifnr = vendor AND bsart = 'ZTSR'.
*****  ELSE.
*****    SELECT
*****      ebeln
*****      aedat
*****      lifnr
*****      FROM ekko INTO TABLE it_ekko
*****      WHERE bsart = 'ZTSR' .
*****  ENDIF.
*****
*****  IF it_ekko IS NOT INITIAL .
*****    SELECT
*****      ebeln
*****      lifnr
*****      name1
*****      lr_no
*****      lr_date
*****      inwd_doc
*****      service_po
*****      FROM zinw_t_hdr INTO TABLE it_zinw_t_hdr
*****      FOR ALL ENTRIES IN it_ekko
*****      WHERE service_po = it_ekko-ebeln .
*****  ENDIF.
*****
*****  IF it_zinw_t_hdr IS NOT INITIAL.
*****
*****    SELECT
*****      ebeln
*****      ebelp
*****      netwr_p
*****      menge
*****      netpr_p
*****      FROM zinw_t_item INTO TABLE it_zinw_t_item
*****      FOR ALL ENTRIES IN it_zinw_t_hdr
*****      WHERE ebeln =  it_zinw_t_hdr-ebeln .
*****
*****    SELECT
*****      ebeln
*****      ebelp
*****      matnr
*****      menge
*****      mwskz
*****      netpr
*****      netwr
*****      FROM ekpo INTO TABLE it_ekpo
*****      FOR ALL ENTRIES IN it_zinw_t_hdr
*****      WHERE ebeln =  it_zinw_t_hdr-service_po .
*****  ENDIF.
*****
*****  IF it_ekko IS NOT INITIAL.
*****    SELECT
*****      lfa1~lifnr ,
*****      lfa1~name1 FROM lfa1 INTO TABLE @DATA(it_lfa1)
*****                FOR ALL ENTRIES IN @it_ekko
*****                WHERE lifnr = @it_ekko-lifnr.
*****
*****  ENDIF.

  DATA : slno(3) TYPE i .

  LOOP AT it_item INTO DATA(wa_item) WHERE service_po <> ' ' .
    slno = slno + 1 .
    wa_final-sl_no    = slno  .
    wa_final-lr_no    = wa_item-lr_no .
    wa_final-lr_date  = wa_item-lr_date .
    wa_final-inwd_doc = wa_item-inwd_doc .

    wa_final-aedat  = wa_item-aedat .
    wa_final-lifnr  = wa_item-lifnr  .


    wa_final-name1  = wa_item-name1 .

    IF wa_item-mwskz IS NOT INITIAL.
      wa_final-ebeln = wa_item-ebeln .
      wa_final-netpr = wa_item-netpr .
      DATA : lv_po_val TYPE netwr.
      CLEAR lv_po_val.
      CALL METHOD zcl_po_item_tax=>get_po_item_tax
        EXPORTING
          i_ebeln     = wa_item-ebeln                 " Purchasing Document Number
          i_ebelp     = wa_item-ebelp                 " Item Number of Purchasing Document
          i_quantity  = wa_item-menge                 " Quantity
        IMPORTING
*         E_TAX       = GS_FINAL1-TAX                " Tax Amount in Document Currency
          e_total_val = lv_po_val.
      wa_final-netpr =  lv_po_val.
*    ENDLOOP.
    ELSE.
      wa_final-netpr = wa_item-netpr .
    ENDIF.
    APPEND wa_final TO it_final.
    CLEAR : wa_final.
  ENDLOOP .


**  LOOP AT it_zinw_t_hdr INTO wa_zinw_t_hdr WHERE service_po <> ' ' .
**    slno = slno + 1 .
**    wa_final-sl_no = slno  .
**    wa_final-lr_no  = wa_zinw_t_hdr-lr_no .
**    wa_final-lr_date  = wa_zinw_t_hdr-lr_date .
**    wa_final-inwd_doc  = wa_zinw_t_hdr-inwd_doc .
**    READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<wa_ekko>) WITH KEY  ebeln = wa_zinw_t_hdr-service_po .
**    IF sy-subrc = 0.
**      wa_final-aedat = <wa_ekko>-aedat .
**      wa_final-lifnr  = <wa_ekko>-lifnr  .
**    ENDIF.
**    READ TABLE it_lfa1 ASSIGNING FIELD-SYMBOL(<wa_lfa1>) WITH KEY lifnr = <wa_ekko>-lifnr .
**    IF sy-subrc  = 0.
**      wa_final-name1  = <wa_lfa1>-name1 .
**    ENDIF.
***    LOOP AT IT_EKPO INTO WA_EKPO WHERE EBELN = WA_ZINW_T_HDR-SERVICE_PO .
**    READ TABLE it_ekpo INTO wa_ekpo WITH KEY ebeln = wa_zinw_t_hdr-service_po.
**    IF wa_ekpo-mwskz IS NOT INITIAL.
**      wa_final-ebeln = wa_ekpo-ebeln .
**      wa_final-netpr = wa_ekpo-netpr .
**      DATA : lv_po_val TYPE netwr.
**      CLEAR lv_po_val.
**      CALL METHOD zcl_po_item_tax=>get_po_item_tax
**        EXPORTING
**          i_ebeln     = wa_ekpo-ebeln                 " Purchasing Document Number
**          i_ebelp     = wa_ekpo-ebelp                 " Item Number of Purchasing Document
**          i_quantity  = wa_ekpo-menge                 " Quantity
**        IMPORTING
***         E_TAX       = GS_FINAL1-TAX                " Tax Amount in Document Currency
**          e_total_val = lv_po_val.
**      wa_final-netpr =  lv_po_val.
***    ENDLOOP.
**    ELSE.
**      wa_final-netpr = wa_ekpo-netpr .
**    ENDIF.
**    APPEND wa_final TO it_final.
**    CLEAR : wa_final.
**  ENDLOOP .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .


  DATA : wa_layout   TYPE slis_layout_alv.


  DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
        wa_fieldcat TYPE slis_fieldcat_alv.

  DATA: it_sort TYPE slis_t_sortinfo_alv,
        wa_sort TYPE slis_sortinfo_alv.

  wa_fieldcat-fieldname = 'SL_NO'.
  wa_fieldcat-seltext_l =  'Serial No'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-seltext_l = 'Transporter code'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_l = 'Transporter name'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'LR_NO'.
  wa_fieldcat-seltext_l = 'LR No'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'LR_date'.
  wa_fieldcat-seltext_l = 'LR date'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'INWD_DOC'.
  wa_fieldcat-seltext_l = 'Inward Number'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'EBELN'.
  wa_fieldcat-seltext_l = 'Service Po No'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_fieldcat-fieldname = 'AEDAT'.
  wa_fieldcat-seltext_l = 'Service Po Date'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .


  wa_fieldcat-fieldname = 'NETPR'.
  wa_fieldcat-seltext_l = 'Amount'.
  wa_fieldcat-do_sum = 'X' .
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR   wa_fieldcat  .

  wa_layout-zebra = 'X'.
  wa_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active    = ' '
      i_callback_program = ' '
      is_layout          = wa_layout
      it_fieldcat        = it_fieldcat
      it_sort            = it_sort
*     IT_FILTER          =
*     IS_SEL_HIDE        =
      i_default          = 'X'
      i_save             = 'A'
    TABLES
      t_outtab           = it_final
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
