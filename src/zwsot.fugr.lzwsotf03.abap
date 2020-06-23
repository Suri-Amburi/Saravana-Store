*----------------------------------------------------------------------*
***INCLUDE LWSOTF03 .
*----------------------------------------------------------------------*

FORM READ_ASORT_FOR_LOCNR USING    P_LOCNR LIKE WRSZ-LOCNR
                          CHANGING P_ASORT LIKE WRS1-ASORT.

  DATA: TMP_WRS1 LIKE WRS1.

  CALL FUNCTION 'ASSORTMENT_GET_ASORT_OF_USER'
       EXPORTING
*     VALID_PER_DATE = SY-DATUM
*     SELECT_INVALID_ASORT = ' '
      user           = p_locnr
      user_type      = 'B'
*     VKORG          = ' '
*     VTWEG          = ' '
       IMPORTING
            ASORT_DEFAULT        = TMP_WRS1
*    TABLES
*     ASSORTMENT_DATA      =
*     ASSORTMENT_CONNECTS  =
    exceptions
      no_asort_found = 1
      others         = 2.
  IF SY-SUBRC = 0.
    P_ASORT = TMP_WRS1-ASORT.
  ELSE.
    CLEAR P_ASORT.
  ENDIF.
ENDFORM.                               " READ_ASORT_FOR_LOCNR
*&---------------------------------------------------------------------*
*&      Form  badi_change_datab_wrsz
*&---------------------------------------------------------------------*
FORM badi_change_datab_wrsz using    p_asort type asort     " GB 983196
                            changing p_datab type datab.
*
* if badi-implementation is active and listing is processed by layout
* (wrs1-layvr is not initial), then determine lead time of presentation
* (from table twpa, field wrf_list_diff_ty) and subtract into p_datab
* (table wrsz, start date of presentation for assortment user)
*
  statics : sr_datab_badi  TYPE REF TO WRF_LISTING_DIFF,
            s_attempt_inst type char1.
*
  if s_attempt_inst is initial.
    s_attempt_inst = 'X'.
    TRY.
        GET   BADI sr_datab_badi.
        CATCH cx_badi_not_implemented.
        EXIT.
    ENDTRY.
  endif.
*
  if sr_datab_badi is not initial.
    CALL BADI sr_datab_badi->CHANGE_DATAB
      EXPORTING
        i_asort = p_asort
      changing
        x_datab = p_datab.
  endif.
*
ENDFORM.                    " badi_change_datab_wrsz        " GB 983196
*&---------------------------------------------------------------------*
*&      Form  BADI_MERGE_WRSZ_ENTRIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_WRSZ  text
*----------------------------------------------------------------------*
form badi_merge_wrsz_entries  changing ct_wrsz type wrf_wrsz_tty.

  statics : sr_datab_badi  type ref to wrf_listing_diff,
            s_attempt_inst type char1.
*
  if s_attempt_inst is initial.
    s_attempt_inst = 'X'.
    try.
        get badi sr_datab_badi.
      catch cx_badi_not_implemented.
        return.
    endtry.
  endif.
*
  if sr_datab_badi is not initial.
    call badi sr_datab_badi->merge_wrsz
      changing
        ct_wrsz = ct_wrsz.
  endif.
endform.                    " BADI_MERGE_WRSZ_ENTRIES
