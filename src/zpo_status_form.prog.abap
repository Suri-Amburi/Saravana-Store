*&---------------------------------------------------------------------*
*& Include          ZPO_STATUS_FORM
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

  SELECT
    ebeln
    ebelp
    etenr
    eindt
    lpein
    uzeit
    FROM eket INTO TABLE it_eket
    WHERE eindt GE sy-datum. "FOR ALL ENTRIES IN IT_EKKO WHERE EBELN = IT_EKKO-EBELN.

  IF it_eket IS NOT INITIAL.
    SELECT ebeln
           bukrs
           bsart
           statu
           aedat
           lifnr
           spras
           ekgrp
           FROM ekko INTO TABLE it_ekko FOR ALL ENTRIES IN it_eket WHERE ekgrp IN s_ekgrp AND aedat IN s_aedat "NE '001' AND EKGRP NE '002' AND EKGRP NE  '003'
           AND bsart IN (  'ZLOP' , 'ZOSP', 'ZVLO', 'ZVOS' ) AND ebeln = it_eket-ebeln.
  ENDIF.
*BREAK mpatil.
  IF it_ekko IS NOT INITIAL.

    SELECT ebeln
           ebelp
           statu
           aedat
           matnr
           bukrs
           werks
           menge
           FROM ekpo INTO TABLE it_ekpo FOR ALL ENTRIES IN it_ekko WHERE ebeln = it_ekko-ebeln.

    SELECT ekgrp eknam FROM t024 INTO TABLE it_t024 FOR ALL ENTRIES IN it_ekko WHERE ekgrp LIKE 'P%' AND ekgrp = it_ekko-ekgrp.

    SELECT lifnr
           name1
           ort01
           pstlz
           erdat
           FROM lfa1 INTO TABLE it_lfa1 FOR ALL ENTRIES IN it_ekko WHERE lifnr = it_ekko-lifnr.
*                                                               AND EBELP = IT_EKPO-EBELP.

    SELECT ebeln
           ebelp
           matnr
           menge
           menge_p
           FROM zinw_t_item INTO TABLE it_zinw_t_item FOR ALL ENTRIES IN it_ekko WHERE ebeln = it_ekko-ebeln.

  ENDIF.

  LOOP AT it_ekko INTO wa_ekko .
    wa_final-ebeln = wa_ekko-ebeln .
    wa_final-bukrs = wa_ekko-bukrs .
    wa_final-bsart = wa_ekko-bsart .
    wa_final-statu = wa_ekko-statu .
    wa_final-aedat = wa_ekko-aedat .
    wa_final-lifnr = wa_ekko-lifnr .
    wa_final-spras = wa_ekko-spras .
    wa_final-ekgrp = wa_ekko-ekgrp .

    LOOP AT it_ekpo INTO wa_ekpo WHERE ebeln = wa_ekko-ebeln.

*IF SY-SUBRC = 0.
*WA_FINAL-EBELN = WA_EKPO-EBELN .
*WA_FINAL-EBELP = WA_EKPO-EBELP .
      wa_final-statu = wa_ekpo-statu .
      wa_final-aedat = wa_ekpo-aedat .
      wa_final-matnr = wa_ekpo-matnr .
      wa_final-bukrs = wa_ekpo-bukrs .
      wa_final-werks = wa_ekpo-werks .
      wa_final-menge =  wa_final-menge + wa_ekpo-menge .
*ENDIF.
    ENDLOOP.
    READ TABLE it_t024 INTO wa_t024 WITH KEY ekgrp = wa_ekko-ekgrp.
    IF sy-subrc = 0.
*WA_FINAL-EKGRP = WA_T024-EKGRP.
      wa_final-eknam = wa_t024-eknam.
    ENDIF.

    READ TABLE it_lfa1 INTO wa_lfa1 WITH KEY lifnr = wa_ekko-lifnr.
    IF sy-subrc = 0.
*WA_FINAL-LIFNR = WA_LFA1-LIFNR .
      wa_final-name1 = wa_lfa1-name1 .
      wa_final-ort01 = wa_lfa1-ort01 .
      wa_final-pstlz = wa_lfa1-pstlz .
      wa_final-erdat = wa_lfa1-erdat .
    ENDIF.

    READ TABLE it_eket INTO wa_eket WITH KEY ebeln = wa_ekko-ebeln.

    IF sy-subrc = 0 .
*WA_FINAL-EBELN = WA_EKET-EBELN .
      wa_final-ebelp = wa_eket-ebelp .
      wa_final-etenr = wa_eket-etenr .
      wa_final-eindt = wa_eket-eindt .
      wa_final-lpein = wa_eket-lpein .
      wa_final-uzeit = wa_eket-uzeit .
    ENDIF.
*ENDIF.
    READ TABLE it_zinw_t_item INTO wa_zinw_t_item WITH KEY ebeln = wa_ekko-ebeln.
*                                                           EBELP = WA_EKKO-EBELP.
    IF sy-subrc = 0.
*WA_FINAL-EBELN   = WA_ZINW_T_ITEM-EBELN   .
      wa_final-ebelp   = wa_zinw_t_item-ebelp   .
      wa_final-matnr   = wa_zinw_t_item-matnr   .
      wa_final-menge   = wa_zinw_t_item-menge   .
      wa_final-menge_p = wa_zinw_t_item-menge_p .
    ENDIF.

    lv_bq = wa_final-menge - wa_final-menge_p.
    wa_final-lv_bq = lv_bq.

    APPEND wa_final TO it_final.
    CLEAR wa_final.

  ENDLOOP.
  SORT it_final BY eindt aedat ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELD_CAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM field_cat .

  wa_fcat-col_pos = 1.
  wa_fcat-outputlen   = 10.
  wa_fcat-fieldname = 'AEDAT'.
  wa_fcat-seltext_m = 'PO Date'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos = 2.
  wa_fcat-outputlen   = 30.
  wa_fcat-fieldname = 'NAME1'.
  wa_fcat-seltext_m = 'Vendor Name'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos = 3.
  wa_fcat-outputlen   = 12.
  wa_fcat-fieldname = 'EBELN'.
  wa_fcat-seltext_m = 'PO No'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos = 4.
  wa_fcat-outputlen   = 15.
  wa_fcat-fieldname = 'WERKS'.
  wa_fcat-seltext_m = 'Delivery Location'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos = 5.
  wa_fcat-outputlen   = 18.
  wa_fcat-fieldname = 'EKNAM'.
  wa_fcat-seltext_m = 'Group'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos = 6.
  wa_fcat-outputlen   = 15.
  wa_fcat-fieldname = 'MENGE'.
  wa_fcat-do_sum = 'X'.
  wa_fcat-seltext_m = 'Order Quantity'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos = 7.
  wa_fcat-outputlen   = 15.
  wa_fcat-fieldname = 'MENGE_P'.
  wa_fcat-do_sum = 'X'.
  wa_fcat-seltext_m = 'Dispatch Quantity'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-col_pos = 8.
  wa_fcat-outputlen   = 15.
  wa_fcat-fieldname = 'LV_BQ'.
  wa_fcat-do_sum = 'X'.
  wa_fcat-seltext_m = 'Balance Quantity'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-col_pos = 9.
  wa_fcat-outputlen   = 10.
  wa_fcat-fieldname = 'EINDT'.
  wa_fcat-seltext_m = 'PO Valid Date'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout     = wa_layout
      it_fieldcat   = it_fcat[]
    TABLES
      t_outtab      = it_final
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
