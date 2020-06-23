*&---------------------------------------------------------------------*
*& Include          ZFI_TDS_MAIN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZFI_TDS_MAIN
*&---------------------------------------------------------------------*
INITIALIZATION.
  gv_totdocs = gv_faultdocs = 0.
  gs_layout-info_fieldname = gc_lcolor.


START-OF-SELECTION.

  PERFORM authority_check USING      p_bukrs .
  PERFORM ewt_active      USING      p_bukrs .
  IF s_lifnr IS  NOT INITIAL OR p_pan EQ gc_x OR p_exemp = gc_x.
    PERFORM fill_vendor_withdata.
  ELSEIF s_kunnr IS NOT INITIAL.
    PERFORM fill_customer_withdata.
  ENDIF.
  PERFORM fill_prov_util_doc. "Note 2045607
  PERFORM select_basic_data    USING startdate
                                     enddate.
  PERFORM populate_final_data.

END-OF-SELECTION.
  PERFORM build_fieldcatalog.
  PERFORM display_alv_report.

TOP-OF-PAGE.
