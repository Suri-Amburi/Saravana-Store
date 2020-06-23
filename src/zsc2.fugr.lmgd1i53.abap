*------------------------------------------------------------------
*  Module MVKE-VMSTD.
*  Pruefung des Gültigkeitsdatums zum Vertriebsstatus
*------------------------------------------------------------------
MODULE mvke-vmstd.

  CHECK bildflag = space.
  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.

  CALL FUNCTION 'MVKE_VMSTD'
    EXPORTING
      lmvke_vmsta = lmvke-vmsta           "ch zu 4.0C
      lmvke_vmstd = lmvke-vmstd           "ch zu 4.0C
      wmvke_vmsta = mvke-vmsta
      wmvke_vmstd = mvke-vmstd.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHCK_UCOMM_FOR_REF_HANDL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE chck_mm_ucomm_for_ref_hdl INPUT.

  IF mvke IS NOT INITIAL.
    cl_im_sgt_md_ei_mat_od=>mvke_reference_od_rt( is_rmmg1 = rmmg1
                                                  is_mvke  = mvke
                                                  is_mara  = mara  ).
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SGT_SALES_STATUS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE sgt_mm_sales_status OUTPUT.
  PERFORM sgt_mm_handle_button.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SGT_HANDLE_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sgt_mm_handle_button .

  DATA :lv_catv       TYPE          sgt_catv     VALUE 'XXXXXXXXXXXXXXXX'.

  IF mara-sgt_csgr IS NOT INITIAL.
*  Check whether the structure fields are SDS relevant or not
    CALL FUNCTION 'SGTG_ELIMINATE_NON_RELEVANT'
      EXPORTING
        iv_csgr                     = mara-sgt_csgr
        iv_appl                     = 'S'
        iv_cfun                     = 'SDS'
      CHANGING
        cv_cat_value                = lv_catv
      EXCEPTIONS
        no_category_structure_found = 1
        no_relevance_info_found     = 2
        internal_error              = 3
        OTHERS                      = 4.
  ENDIF.

  IF lv_catv EQ space or mara-sgt_csgr IS INITIAL or mara-sgt_scope <> 1.
** No Stock segments found, button and icon are not shown
    LOOP AT SCREEN.
      IF screen-name = 'SALES_STATUS'.
        screen-active    = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
