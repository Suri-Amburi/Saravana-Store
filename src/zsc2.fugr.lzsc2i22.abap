*----------------------------------------------------------------------*
***INCLUDE LMGD2I22.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHECK_UOM_FOR_LOG_PRODUCT  INPUT
*&---------------------------------------------------------------------*
*       Additional Checks relevant in case of logistical Product handling.
*       The special handling is only needed in case a sales product or procurement product
*       is maintained (MM4x).
*----------------------------------------------------------------------*
MODULE check_uom_for_log_product INPUT.

  DATA:
        gr_consi_check TYPE REF TO cl_logistical_prod_consistency,
        lr_error       TYPE REF TO cx_logistical_prod_consistency,
        ls_msg         TYPE bal_s_msg.

* The following checks are only executed in case a sales product or a procurement product is processed
  CHECK mara-logistical_mat_category = if_struc_art_multi_lvl_const=>co_logistical_mat_category-procurement OR
        mara-logistical_mat_category = if_struc_art_multi_lvl_const=>co_logistical_mat_category-sales.

  TRY.
    IF gr_log_prod_consistency IS NOT BOUND.
    gr_log_prod_consistency = cl_logistical_prod_consistency=>get_instance( mara ).
  ENDIF.

  IF gr_log_prod_consistency IS BOUND.
      gr_log_prod_consistency->check_consistency_ui(
          EXPORTING
            iv_screen_to_be_check = sy-dynnr
            is_meinh_processed = smeinh                " Currently processed MEINH record
            it_existing_uom    = meinh[] ).            " Existing UOM
    ENDIF.
  CATCH cx_logistical_prod_consistency INTO lr_error.
        lr_error->conv_2_msgline(
          CHANGING
            xs_msg = ls_msg ).
*   In case of inconsistencies, stay in the same screen and raise a message as success to allow
*   the user to correct the data again.
        bildflag = abap_true.
        MESSAGE
          ID ls_msg-msgid
          TYPE ls_msg-msgty
          NUMBER ls_msg-msgno
          WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4.
    ENDTRY.


ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  CHECK_EAN_FOR_LOG_PRODUCT  INPUT
*&---------------------------------------------------------------------*
*       Additional Checks relevant in case of logistical Product handling.
*       This additional EAN Consi Check is only relevant if a sales product is processed
*       In a case of a procurement product it is still allowed to change teh EAN's
*----------------------------------------------------------------------*
MODULE check_ean_for_log_product INPUT.

  DATA: ls_current_mean TYPE mean.

* The following checks are only executed in case a sales product is processed
  CHECK mara-logistical_mat_category = if_struc_art_multi_lvl_const=>co_logistical_mat_category-sales.

* If the current processed MEINH is initial, no check can be performed
  CHECK smeinh-meinh IS NOT INITIAL.

  IF gr_log_prod_consistency IS NOT BOUND.
    gr_log_prod_consistency = cl_logistical_prod_consistency=>get_instance( mara ).
  ENDIF.

  IF gr_log_prod_consistency IS BOUND.
    TRY.
*       in structure mean the UoM is not filled, therefore
*       we have to take the current MEINH info from SMEINH
        ls_current_mean = mean.
        ls_current_mean-meinh = smeinh-meinh.
*       To be able to check the EAN consistency we need the MEAN and the MEAN_ME_TAB parameter, because in structure MEAN the
*       UoM is not filled at the time of processing
        gr_log_prod_consistency->check_consistency_ui(
          EXPORTING
            iv_screen_to_be_check = sy-dynnr
            is_mean_processed     = ls_current_mean       " Currently processed MEAN record (including MEINH)
            iv_ean_akt_zeile    = ean_akt_zeile         " Index of the current processed MEAN record in table MEAN_ME_TAB
            it_existing_ean     = mean_me_tab[]         " Existing EAN's
            it_existing_uom     = meinh[] ).            " Existing UoM's
      CATCH cx_logistical_prod_consistency into lr_error.
        lr_error->conv_2_msgline(
          CHANGING
            xs_msg = ls_msg ).
*       In case of inconsistencies, stay in the same screen and raise a message as success to allow
*       the user to correct the data again.
        bildflag = abap_true.
        MESSAGE
          ID ls_msg-msgid
          TYPE ls_msg-msgty
          NUMBER ls_msg-msgno
          WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4.
    ENDTRY.
  ENDIF.

ENDMODULE.
