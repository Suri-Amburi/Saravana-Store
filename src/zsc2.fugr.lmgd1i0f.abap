*&---------------------------------------------------------------------*
*&      Module  MARA_WRKST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MARA_WRKST INPUT.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_WRKST'
       EXPORTING
            WMARA_MATNR = MARA-MATNR
            WMARA_WRKST = MARA-WRKST.
*         P_MESSAGE   = ' '

ENDMODULE.                             " MARA_WRKST  INPUT
*&---------------------------------------------------------------------*
*&      Module  MARA_MEDIUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MARA_MEDIUM INPUT.

* BAdI call replaces function module call to GHO_CHECK_MEDIUM

  IF 1 = 2.
*   UOM Interface w/ ERP
    MESSAGE s100(gho_msgs_intf).
  ENDIF.

  DATA: lr_gho_sap_appl_erp_intf TYPE REF TO gho_badi_sap_appl_erp_intf.

  TRY.
      " Get BADI Reference
      GET BADI lr_gho_sap_appl_erp_intf.

      " Call BADI method
      CALL BADI lr_gho_sap_appl_erp_intf->gho_check_medium
        EXPORTING
          iv_medium = mara-medium.
*       EXCEPTIONS
*         NOT_GHO_RELEVANT = 1
*         OTHERS           = 2.
    CATCH cx_badi_not_implemented.
      " No exception raised
  ENDTRY.

ENDMODULE.                 " MARA_MEDIUM  INPUT
