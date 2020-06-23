*&---------------------------------------------------------------------*
*& Report ZFI_VENDOR_AGING_NC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_VENDOR_AGING_NC.
INCLUDE zfi_vendor_aging_nc_top.
INCLUDE zfi_vendor_aging_nc_sel.
INCLUDE zfi_vendor_aging_nc_sub.

AT SELECTION-SCREEN ON s_lifnr.
  PERFORM validate_vendor.

AT SELECTION-SCREEN ON s_gjahr.
  PERFORM validate_gjahr.

AT SELECTION-SCREEN.
  PERFORM sub_validate_slab1.
* Validation Of Aging Slab
  PERFORM sub_validate_slab2.
* Validation Of Aging Slab
  PERFORM sub_validate_slab3.
* Validation Of Aging Slab
  PERFORM sub_validate_slab4.
* Validation Of Aging Slab
*  PERFORM SUB_VALIDATE_SLAB5.

START-OF-SELECTION.

  PERFORM fetch .

  IF r3 = 'X'.
    PERFORM display_detail.
  ELSEIF r4 = 'X'.
    PERFORM display.
  ENDIF.
