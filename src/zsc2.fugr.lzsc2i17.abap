*&---------------------------------------------------------------------*
*       Read some additional logistical product data and transfer the data
*       to the UI.
*&---------------------------------------------------------------------*
MODULE enhance_log_prod_data OUTPUT.

  DATA:
    lt_tab_a TYPE STANDARD TABLE OF dd07v,
    lt_tab_b TYPE STANDARD TABLE OF dd07v,
    ls_wmakt TYPE makt.

  FIELD-SYMBOLS: <ls_dom_value_desc> TYPE dd07v.

* Read Text for the the Domain Fix Value of DO_LOGISTICAL_MAT_CATEGORY
  CALL FUNCTION 'DD_DOFV_GET'
    EXPORTING
      langu         = sy-langu
      domain_name   = 'DO_LOGISTICAL_MAT_CATEGORY'
    TABLES
      dd07v_tab_a   = lt_tab_a
      dd07v_tab_n   = lt_tab_b
    EXCEPTIONS
      illegal_value = 1
      op_failure    = 2
      OTHERS        = 3.
  CHECK sy-subrc = 0.
* Read the text of the domain fix value of the logistical material category of the material
  READ TABLE lt_tab_a WITH KEY domvalue_l = mara-logistical_mat_category ASSIGNING <ls_dom_value_desc>.
  IF sy-subrc = 0.
    domtext =  <ls_dom_value_desc>-ddtext.
  ENDIF.

* Read Text of the sales material
  CALL FUNCTION 'MAKT_SINGLE_READ'
    EXPORTING
      matnr      = mara-sales_material
      spras      = sy-langu
    IMPORTING
      wmakt      = ls_wmakt
    EXCEPTIONS
      wrong_call = 1
      not_found  = 2
      OTHERS     = 3.
  CHECK sy-subrc = 0.
  sales_material_text = ls_wmakt-maktx.

ENDMODULE.
