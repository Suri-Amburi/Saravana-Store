*---------------------------------------------------------------------*
*   MODULE DEST_VALUES    F4-Hilfe für Gefahrgutkennzeichenprofil     *
*---------------------------------------------------------------------*
MODULE dest_values.

  CONSTANTS: lc_mara_profl(10)  TYPE c VALUE 'MARA-PROFL'. " fieldname on dynpro

  DATA: mara_profl         LIKE mara-profl,
        l_badi_instance    TYPE REF TO if_ex_ehs_dg_001,
        l_instance_exist   TYPE eseboole,
        lv_f4_display_only TYPE eseboole, " true = display mode in F4-help
        lt_dynpfields      TYPE TABLE OF dynpread, " table of dynpro fields
        ls_dynpfield       LIKE LINE OF lt_dynpfields.

* General mode of transaction (display, change...)
  IF t130m-aktyp = aktypa OR t130m-aktyp = aktypz.
    display = cx_true. " display mode
  ELSE.
    display = cx_false. " change mode
  ENDIF.

* Read fields of dynpro to get input state of DG profl
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname                               = sy-repid
      dynumb                               = sy-dynnr
      request                              = 'A'
    TABLES
      dynpfields                           = lt_dynpfields.

* Read input state of DG profl
  READ TABLE lt_dynpfields INTO ls_dynpfield
      WITH KEY fieldname = lc_mara_profl
      TRANSPORTING fieldinp.

  IF ( display = cx_true ).
    lv_f4_display_only = cx_true. " always display only in display mode
  ELSEIF ( display = cx_false ).
    IF ( ls_dynpfield-fieldinp = cx_false ). " field is not ready for input
      lv_f4_display_only = cx_true.
    ELSE.
      lv_f4_display_only = cx_false.
    ENDIF.
  ENDIF.

* Get instance of BAdI
  CALL FUNCTION 'EHS002_BADI_EHS_DG_001_GET_OBJ'
    IMPORTING
      e_badi_object    = l_badi_instance
      e_instance_exist = l_instance_exist.

  IF l_instance_exist = cx_true.
*   F4-help using BAdI-method
    CALL METHOD l_badi_instance->valid_tdg41
      EXPORTING
        display   = lv_f4_display_only
        fieldname = 'PROFL'
        tabname   = 'TDG41'
      IMPORTING
        profl     = mara_profl.

    mara-profl = mara_profl.
  ELSE. " extension switch not active or no implementation available
*   F4-help using standard functionality
    CALL FUNCTION 'F4TOOL_CHECKTABLE_HELP'
      EXPORTING
        checktable       = 'TDG41'
        retfield         = 'PROFL'
        display          = lv_f4_display_only
      EXCEPTIONS
        tabl_not_exists  = 1
        field_not_exists = 2
        illegal_call     = 3
        OTHERS           = 4.
  ENDIF.
ENDMODULE.                    "DEST_VALUES
