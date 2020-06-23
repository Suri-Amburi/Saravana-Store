*&---------------------------------------------------------------------*
*& Include          ZMAS_CAT_STOCK_FORM
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

  SELECT mblnr
         mjahr
         bwart
         matnr
         budat_mkpf
         werks
         FROM mseg INTO TABLE it_mseg WHERE budat_mkpf IN s_budat AND bwart IN ('251', '252')
              AND werks IN ('SSTN', 'SSPU', 'SSCP', 'SSPO' ).
  IF it_mseg IS NOT INITIAL.
    SELECT matnr
           erdat
           matkl
           werks
           fkimg
           netwr
           FROM vbrp INTO TABLE it_vbrp FOR ALL ENTRIES IN it_mseg WHERE matnr = it_mseg-matnr AND erdat = it_mseg-budat_mkpf." AND FKIMG <> 0.

    SELECT matnr
           matkl
           FROM mara INTO TABLE it_mara FOR ALL ENTRIES IN it_mseg WHERE matnr = it_mseg-matnr ."AND MATKL = IT_VBRP-MATKL.

    SELECT werks
           name1
           bwkey
           kunnr
           lifnr
           FROM t001w INTO TABLE it_t001w FOR ALL ENTRIES IN it_mseg WHERE werks = it_mseg-werks.
  ENDIF.

*  LOOP AT it_mseg INTO wa_mseg .
  LOOP AT it_vbrp INTO wa_vbrp.

    READ TABLE it_mseg INTO wa_mseg WITH KEY matnr = wa_vbrp-matnr  budat_mkpf = wa_vbrp-erdat.

    READ TABLE it_mara INTO wa_mara WITH KEY matnr = wa_mseg-matnr.
    IF sy-subrc = 0.
      wa_item-matkl =  wa_mara-matkl .    "Category No.
    ENDIF.

    CASE wa_vbrp-werks.
      WHEN 'SSTN'.   "T. Nagar
        wa_item-matkl =  wa_mara-matkl .    "Category No.
        wa_item-lbkum =  wa_vbrp-fkimg .    " Qty
        wa_item-value =  wa_vbrp-netwr .    "Value

      WHEN 'SSPU'.    "PURUSAIWALAM
        wa_item-matkl  =  wa_mara-matkl .
        wa_item-lbkum1 =  wa_vbrp-fkimg .
        wa_item-value1 =  wa_vbrp-netwr .

      WHEN 'SSCP'.    "CHROMPET
        wa_item-matkl  =   wa_mara-matkl .
        wa_item-lbkum2 =   wa_vbrp-fkimg .
        wa_item-value2 =   wa_vbrp-netwr .

      WHEN 'SSPO'.    "PORUR
        wa_item-matkl  =  wa_mara-matkl .
        wa_item-lbkum3 =  wa_vbrp-fkimg .
        wa_item-value3 =  wa_vbrp-netwr .
    ENDCASE.
    wa_item-lbkum4 = wa_item-lbkum + wa_item-lbkum1 + wa_item-lbkum2 + wa_item-lbkum3.
    wa_item-value4 = wa_item-value + wa_item-value1 + wa_item-value2 + wa_item-value3.
    wa_item-matnr = wa_mseg-matnr.
    APPEND wa_item TO it_item.
    CLEAR wa_item.

  ENDLOOP.
  LOOP AT it_item INTO wa_item.
    wa_item2-matnr  = wa_item-matnr  .
    wa_item2-matkl  = wa_item-matkl  .
    wa_item2-lbkum  = wa_item-lbkum  .
    wa_item2-value  = wa_item-value  .
    wa_item2-lbkum1 = wa_item-lbkum1 .
    wa_item2-value1 = wa_item-value1 .
    wa_item2-lbkum2 = wa_item-lbkum2 .
    wa_item2-value2 = wa_item-value2 .
    wa_item2-lbkum3 = wa_item-lbkum3 .
    wa_item2-value3 = wa_item-value3 .
    wa_item2-lbkum4 = wa_item-lbkum4 .
    wa_item2-value4 = wa_item-value4 .
    COLLECT wa_item2 INTO it_item2.
    CLEAR : wa_item2, wa_item.
  ENDLOOP.
*BREAK mumair.
  SORT it_item2 BY matkl.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  DATA: fm_name     TYPE rs38l_fnam.
  DATA: t_ssfcompop TYPE ssfcompop.
  DATA: t_control   TYPE ssfctrlop.


  t_control-getotf = 'X'.
  t_control-no_dialog = 'X'.
  t_ssfcompop-tdnoprev = 'X'.


  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZMASTER_CAT_SALES_FORM'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  CALL FUNCTION fm_name "'/1BCDWB/SF00000035'
    TABLES
      it_item          = it_item2
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
      OTHERS           = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
