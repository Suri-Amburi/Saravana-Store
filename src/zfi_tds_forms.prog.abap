*&---------------------------------------------------------------------*
*& Include          ZFI_TDS_FORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           J_1I_MIS_FORMS
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FETCH_LAST_DAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_last_day USING    p_startdate  TYPE budat
                    CHANGING p_enddate    TYPE budat.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = p_startdate
    IMPORTING
      last_day_of_month = p_enddate.
ENDFORM.                    " FETCH_LAST_DAY

*&---------------------------------------------------------------------*
*&      Form  RESTRICT_PERIOD_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MNTH  text
*      -->P_P_QRTR  text
*----------------------------------------------------------------------*
FORM restrict_period_selection  USING    fp_mnth
                                         fp_qrtr.
  IF ( fp_mnth IS INITIAL
    AND fp_qrtr IS INITIAL )
    OR ( fp_mnth IS NOT INITIAL
    AND fp_qrtr IS NOT INITIAL ).
    MESSAGE TEXT-042 TYPE c_e.
  ENDIF.
ENDFORM.                    " RESTRICT_PERIOD_SELECTION
*&---------------------------------------------------------------------*
*&      Form  RESTRICT_PARTNER_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM restrict_partner_selection .
  IF ( s_lifnr IS INITIAL
    AND s_kunnr IS INITIAL )
    AND ( p_exemp IS INITIAL
    AND  p_pan IS INITIAL ).
    MESSAGE TEXT-043 TYPE c_w.
  ENDIF.
  IF  s_lifnr IS NOT INITIAL
 AND s_kunnr IS NOT INITIAL.
    MESSAGE TEXT-043 TYPE c_e.
  ENDIF.
ENDFORM.                    " RESTRICT_PARTNER_SELECTION
*&---------------------------------------------------------------------*
*&      Form  RESTRICT_VENDOR_OPTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_EXEMP  text
*      -->P_P_PAN  text
*----------------------------------------------------------------------*
FORM restrict_vendor_options  USING    fp_exemp
                                       fp_pan.
  IF s_kunnr IS NOT INITIAL.
    IF  ( fp_exemp EQ gc_x
      OR  fp_pan   EQ gc_x )
      OR  ( fp_exemp EQ gc_x
      AND fp_pan EQ gc_x ).
      MESSAGE TEXT-044 TYPE c_w.
    ENDIF.
  ENDIF.
ENDFORM.                    " RESTRICT_VENDOR_OPTIONS
*&---------------------------------------------------------------------*
*&      Form  HIDE_VENDOR_OPTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hide_vendor_options .
  IF s_lifnr[] IS INITIAL AND
    s_kunnr[] IS INITIAL AND
    p_exemp IS INITIAL AND
    p_pan IS INITIAL.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'S_LIFNR-LOW' OR
             'S_LIFNR-HIGH' OR
             'P_PAN' OR
             'S_KUNNR-LOW' OR
             'S_KUNNR-HIGH' OR
             'P_EXEMP'.
          screen-input = 1.
          screen-active = 1.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.
  IF p_exemp EQ gc_x.
    CLEAR s_lifnr.
    REFRESH s_lifnr.
    CLEAR s_kunnr.
    REFRESH s_kunnr.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'S_KUNNR-LOW' OR 'S_KUNNR-HIGH' OR 'S_LIFNR-LOW' OR 'S_LIFNR-HIGH' OR 'P_PAN'.
          screen-input = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ELSEIF  p_pan EQ gc_x.
    CLEAR s_lifnr.
    REFRESH s_lifnr.
    CLEAR s_kunnr.
    REFRESH s_kunnr.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'S_KUNNR-LOW' OR 'S_KUNNR-HIGH' OR 'S_LIFNR-LOW' OR 'S_LIFNR-HIGH' OR 'P_EXEMP'.
          screen-input = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ELSEIF  s_lifnr[] IS NOT INITIAL.
    CLEAR s_kunnr.
    REFRESH s_kunnr.
  ELSEIF s_kunnr[] IS NOT INITIAL.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'P_PAN' OR 'P_EXEMP' OR 'S_LIFNR-LOW' OR 'S_LIFNR-HIGH' .
          screen-input = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ELSEIF p_pan NE gc_x .
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'S_KUNNR-LOW' OR 'S_KUNNR-HIGH' OR 'S_LIFNR-LOW' OR 'S_LIFNR-HIGH' OR 'P_EXEMP'.
          screen-input = 1.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ELSEIF p_exemp NE gc_x.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'S_KUNNR-LOW' OR 'S_KUNNR-HIGH' OR 'S_LIFNR-LOW' OR 'S_LIFNR-HIGH' OR 'P_PAN'.
          screen-input = 1.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " HIDE_VENDOR_OPTIONS

*&      Form  GET_MONTH_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MNTH  text
*----------------------------------------------------------------------*
FORM get_month_list  CHANGING    fp_mnth.
  REFRESH: gt_month,
           gt_ret_mn.
  gs_month-mnth = c_apr.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_may.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_jun.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_jul.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_aug.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_sep.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_oct.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_nov.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_dec.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_jan.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_feb.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  gs_month-mnth = c_mar.
  APPEND gs_month TO gt_month.
  CLEAR gs_month.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MNTH'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'P_MNTH'
      value_org       = gc_s
    TABLES
      value_tab       = gt_month
      return_tab      = gt_ret_mn
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " GET_MONTH_LIST
*&---------------------------------------------------------------------*
*&      Form  GET_QUARTER_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_QRTR  text
*----------------------------------------------------------------------*
FORM get_quarter_list  USING    fp_qrtr.
  REFRESH: gt_quart,
           gt_ret_qt.
  gs_quart-qrtr = c_q1.
  APPEND gs_quart TO gt_quart.
  CLEAR gs_quart.
  gs_quart-qrtr = c_q2.
  APPEND gs_quart TO gt_quart.
  CLEAR gs_quart.
  gs_quart-qrtr = c_q3.
  APPEND gs_quart TO gt_quart.
  CLEAR gs_quart.
  gs_quart-qrtr = c_q4.
  APPEND gs_quart TO gt_quart.
  CLEAR gs_quart.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'QRTR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'P_QRTR'
      value_org       = gc_s
    TABLES
      value_tab       = gt_quart
      return_tab      = gt_ret_qt
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " GET_QUARTER_LIST

*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS    text
*----------------------------------------------------------------------*
FORM authority_check USING    p_bukrs.


  DATA:lt_seccode TYPE TABLE OF ty_seccode,                 "2051116
       ls_seccode TYPE ty_seccode.

  SELECT bukrs
         seccode FROM seccode INTO TABLE lt_seccode WHERE bukrs   = p_bukrs
                                                      AND seccode IN s_secco.
  LOOP AT lt_seccode INTO ls_seccode.

    AUTHORITY-CHECK OBJECT 'J_1IEWTMIS'
                    ID 'BUKRS' FIELD p_bukrs
                    ID 'BUPLA' FIELD ls_seccode-seccode
                    ID 'ACTVT' FIELD c_01.
    IF sy-subrc NE 0 .
*      MESSAGE E800 WITH SY-TCODE P_BUKRS LS_SECCODE-SECCODE.
      LEAVE PROGRAM .
    ENDIF .

  ENDLOOP.

ENDFORM.                    " AUTHORITY_CHECK

*&---------------------------------------------------------------------*
*&      Form  EWT_ACTIVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*----------------------------------------------------------------------*
FORM ewt_active USING    p_bukrs.

  CALL FUNCTION 'FI_CHECK_EXTENDED_WT'
    EXPORTING
      i_bukrs              = p_bukrs
    EXCEPTIONS
      component_not_active = 1
      not_found            = 2
      OTHERS               = 3.
  IF sy-subrc NE 0.
*    MESSAGE I714 WITH P_BUKRS  .
    STOP.
  ENDIF .

ENDFORM.                    " EWT_ACTIVE
*&---------------------------------------------------------------------*
*&      Form  FILL_VENDOR_WITHDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_vendor_withdata .
  gs_callback-ldbnode     = c_bsik.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_cbsik.
  APPEND gs_callback TO gt_callback.

  gs_callback-ldbnode     = c_bkpf.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_cbkpf.
  APPEND gs_callback TO gt_callback.

  gs_callback-ldbnode     = c_bseg.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_cbseg.
  APPEND gs_callback TO gt_callback.

  gs_callback-ldbnode     = c_with_item.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_cwith.
  APPEND gs_callback TO gt_callback.

  gs_callback-ldbnode     = c_lfa1.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_clfa1.
  APPEND gs_callback TO gt_callback.



  gs_seltab-kind = gc_s.
  gs_seltab-selname = c_kbukrs.
  gs_seltab-option = c_eq.
  gs_seltab-sign = c_i.
  gs_seltab-low = p_bukrs.
  APPEND gs_seltab TO gt_seltab.

  CLEAR gs_seltab.
  gs_seltab-kind = gc_s.
  gs_seltab-selname = c_kgjahr.
  gs_seltab-option = c_eq.
  gs_seltab-sign = c_i.
  gs_seltab-low = p_year.
  APPEND gs_seltab TO gt_seltab.

  CLEAR gs_seltab.
  gs_seltab-kind = gc_s.
  gs_seltab-selname = c_kbudat.
  gs_seltab-option = c_bt.
  gs_seltab-sign = c_i.
  gs_seltab-low = startdate.
  gs_seltab-high = enddate.
  APPEND gs_seltab TO gt_seltab.


  CLEAR gs_seltab.
  gs_seltab-kind = gc_s.
  gs_seltab-selname = c_klifnr.
  LOOP AT s_lifnr.
    MOVE-CORRESPONDING s_lifnr TO gs_seltab.
    APPEND gs_seltab TO gt_seltab.
  ENDLOOP.
*Note 1584640 for filling KD_APOPT to fetch data from BSAK
  CLEAR gs_seltab.
  gs_seltab-kind = 'P'.
  gs_seltab-selname = 'KD_APOPT'.
  gs_seltab-sign = c_i.
  gs_seltab-low = 'X'.
  gs_seltab-option  = 'EQ'.
  APPEND gs_seltab TO gt_seltab.

  gs_seltab-kind = 'P'.
  gs_seltab-selname = 'KD_NOOAP'.
  gs_seltab-sign = c_i.
  gs_seltab-low = 'X'.
  gs_seltab-option  = 'EQ'.
  APPEND gs_seltab TO gt_seltab.

  CLEAR gs_seltab.
  gs_seltab-kind = 'P'.
  gs_seltab-selname = 'KD_OPOPT'.
  gs_seltab-sign = c_i.
  gs_seltab-low = 'X'.
  gs_seltab-option  = 'EQ'.
  APPEND gs_seltab TO gt_seltab.



  CLEAR gs_seltab.
*End OF Note 1584640
  CALL FUNCTION 'LDB_PROCESS'
    EXPORTING
      ldbname                     = c_kdf
      variant                     = space
    TABLES
      callback                    = gt_callback
      selections                  = gt_seltab
    EXCEPTIONS
      ldb_not_reentrant           = 1
      ldb_incorrect               = 2
      ldb_already_running         = 3
      ldb_error                   = 4
      ldb_selections_error        = 5
      ldb_selections_not_accepted = 6
      variant_not_existent        = 7
      variant_obsolete            = 8
      variant_error               = 9
      free_selections_error       = 10
      callback_no_event           = 11
      callback_node_duplicate     = 12
      OTHERS                      = 13.

  IF sy-subrc <> 0.
    WRITE: TEXT-041, sy-subrc.                              "#EC NOTEXT
  ENDIF.
ENDFORM.                    " FILL_VENDOR_WITHDATA
*&---------------------------------------------------------------------*
*&      Form  FILL_CUSTOMER_WITHDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_customer_withdata .
  gs_callback-ldbnode     = c_bsid.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_cbsid.
  APPEND gs_callback TO gt_callback.

  gs_callback-ldbnode     = c_bkpf.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_cbkpf.
  APPEND gs_callback TO gt_callback.

  gs_callback-ldbnode     = c_bseg.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_cbseg.
  APPEND gs_callback TO gt_callback.

  gs_callback-ldbnode     = c_with_item.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_cwith.
  APPEND gs_callback TO gt_callback.

  gs_callback-ldbnode     = c_kna1.
  gs_callback-get         = gc_x.
  gs_callback-cb_prog     = sy-repid.
  gs_callback-cb_form     = c_ckna1.
  APPEND gs_callback TO gt_callback.

  gs_seltab-kind = gc_s.
  gs_seltab-selname = c_dbukrs.
  gs_seltab-option = c_eq.
  gs_seltab-sign = c_i.
  gs_seltab-low = p_bukrs.
  APPEND gs_seltab TO gt_seltab.

  CLEAR gs_seltab.
  gs_seltab-kind = gc_s.
  gs_seltab-selname = c_dgjahr.
  gs_seltab-option = c_eq.
  gs_seltab-sign = c_i.
  gs_seltab-low = p_year.
  APPEND gs_seltab TO gt_seltab.

  gs_seltab-kind = gc_s.
  gs_seltab-selname = c_dbudat.
  gs_seltab-option = c_bt.
  gs_seltab-sign = c_i.
  gs_seltab-low = startdate.
  gs_seltab-high = enddate.
  APPEND gs_seltab TO gt_seltab.


  CLEAR gs_seltab.
  gs_seltab-kind = gc_s.
  gs_seltab-selname = c_dkunnr.
  LOOP AT s_kunnr.
    MOVE-CORRESPONDING s_kunnr TO gs_seltab.
    APPEND gs_seltab TO gt_seltab.
  ENDLOOP.
*Note 1584640 for filling KD_APOPT to fetch data from BSAK
  CLEAR gs_seltab.
  gs_seltab-kind = 'P'.
  gs_seltab-selname = 'DD_APOPT'.                           "1608106
  gs_seltab-sign = c_i.
  gs_seltab-low = 'X'.
  gs_seltab-option  = 'EQ'.
  APPEND gs_seltab TO gt_seltab.

  gs_seltab-kind = 'P'.
  gs_seltab-selname = 'DD_NOOAP'.                           "1608106
  gs_seltab-sign = c_i.
  gs_seltab-low = 'X'.
  gs_seltab-option  = 'EQ'.
  APPEND gs_seltab TO gt_seltab.

  CLEAR gs_seltab.
  gs_seltab-kind = 'P'.
  gs_seltab-selname = 'DD_OPOPT'.                           "1608106
  gs_seltab-sign = c_i.
  gs_seltab-low = 'X'.
  gs_seltab-option  = 'EQ'.
  APPEND gs_seltab TO gt_seltab.

  CLEAR gs_seltab.
*End OF Note 1584640

  CALL FUNCTION 'LDB_PROCESS'
    EXPORTING
      ldbname                     = c_ddf
      variant                     = space
    TABLES
      callback                    = gt_callback
      selections                  = gt_seltab
    EXCEPTIONS
      ldb_not_reentrant           = 1
      ldb_incorrect               = 2
      ldb_already_running         = 3
      ldb_error                   = 4
      ldb_selections_error        = 5
      ldb_selections_not_accepted = 6
      variant_not_existent        = 7
      variant_obsolete            = 8
      variant_error               = 9
      free_selections_error       = 10
      callback_no_event           = 11
      callback_node_duplicate     = 12
      OTHERS                      = 13.

  IF sy-subrc <> 0.
    WRITE: TEXT-041, sy-subrc.                              "#EC NOTEXT
  ENDIF.
ENDFORM.                    " FILL_CUSTOMER_WITHDATA

*&---------------------------------------------------------------------*
*&      Form  callback_bsik
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM callback_bsik USING name  TYPE ldbn-ldbnode
                        wa    TYPE bsik
                        evt   TYPE c
                        check TYPE c.
  CLEAR gs_bsik.
  MOVE-CORRESPONDING wa TO gs_bsik.
  APPEND gs_bsik TO gt_bsik.

ENDFORM.                    "callback_bsik
*&---------------------------------------------------------------------*
*&      Form  callback_bsid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM callback_bsid USING name  TYPE ldbn-ldbnode
                        wa    TYPE bsid
                        evt   TYPE c
                        check TYPE c.
  CLEAR gs_bsid.
  MOVE-CORRESPONDING wa TO gs_bsid.
  APPEND gs_bsid TO gt_bsid.

ENDFORM.                    "callback_bsid

*-----------------Begin of Note 887656---------------------------------*
*&---------------------------------------------------------------------*
*&      Form  callback_bkpf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*    --->NAME       text
*    --->WA         text
*    --->EVT        text
*    --->CHECK      text
*----------------------------------------------------------------------*
FORM callback_bkpf USING name  TYPE ldbn-ldbnode
                          wa    TYPE bkpf
                          evt   TYPE c
                          check TYPE c.
  DATA: ls_rbkp TYPE rbkp.
  CLEAR gs_bkpf.
  IF wa-bukrs = p_bukrs
    AND wa-budat >= startdate
    AND wa-budat <= enddate.
*    AND wa-gjahr = p_year.
*    AND wa-gjahr = GV_PREVYR. "1695696 "1727552
    MOVE-CORRESPONDING wa TO gs_bkpf.

*begin of 2035236
    IF gs_bkpf-awtyp EQ 'RMRP'. " Check if FI DOCUMENT is created through MIRO (MM SIDE)
      SELECT SINGLE * FROM rbkp INTO CORRESPONDING FIELDS OF ls_rbkp
                               WHERE bukrs = wa-bukrs
                               AND belnr = wa-awkey+0(10)
                               AND gjahr = wa-gjahr.
    ENDIF.

    IF p_rev EQ ' '. "Reversal/Reversed should be reported if checked
      IF gs_bkpf-stblg IS INITIAL AND gs_bkpf-awtyp NE 'RMRP'.
        APPEND gs_bkpf TO gt_bkpf.
        gv_reversal = 0.
      ELSEIF ls_rbkp-stblg IS INITIAL AND gs_bkpf-awtyp EQ 'RMRP'.
        " IF stblg is not filled, document is not reversed and it will be reported
        APPEND gs_bkpf TO gt_bkpf.
        gv_reversal = 0.
      ELSE.
        gv_reversal = 1.
      ENDIF.
    ELSE.                                                   "2035236
      APPEND gs_bkpf TO gt_bkpf.
      gv_reversal = 0.
    ENDIF.
  ENDIF.
*  end of 2035236
ENDFORM.                    "callback_bkpf


*&---------------------------------------------------------------------*
*&      Form  callback_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*    --->NAME       text
*    --->WA         text
*    --->EVT        text
*    --->CHECK      text
*----------------------------------------------------------------------*
FORM callback_bseg USING name  TYPE ldbn-ldbnode
                          wa    TYPE bseg
                          evt   TYPE c
                          check TYPE c.

*  BREAK PPADHY.
  CLEAR gs_bseg.
  IF s_lifnr IS NOT INITIAL OR p_pan EQ gc_x OR p_exemp EQ gc_x.
    IF wa-bukrs = p_bukrs
       AND wa-secco IN s_secco          "Note 1847679
*            AND wa-gjahr = p_year
*      AND wa-gjahr = GV_PREVYR "1695696 "1727552
       AND wa-lifnr IN s_lifnr.
      MOVE-CORRESPONDING wa TO gs_bseg.
*Note 1584640
      SELECT bukrs belnr gjahr buzei koart shkzg qsskz ktosl secco gsber qsshb                                    "Note 2175802
           FROM bseg APPENDING CORRESPONDING FIELDS OF TABLE gt_bseg WHERE bukrs = gs_bseg-bukrs
                                                   AND belnr = gs_bseg-belnr
                                                   AND gjahr = gs_bseg-gjahr
                                                   ORDER BY PRIMARY KEY.
*      APPEND gs_bseg TO gt_bseg.
    ENDIF.
  ELSEIF s_kunnr IS NOT INITIAL.
    IF wa-bukrs = p_bukrs
    AND wa-secco IN s_secco                 "Note 1847679

*    AND wa-gjahr = p_year  "Note 2101433
    AND wa-kunnr IN s_kunnr.
      MOVE-CORRESPONDING wa TO gs_bseg.
*      APPEND gs_bseg TO gt_bseg.
*Note 1584640
      SELECT bukrs belnr gjahr buzei koart shkzg qsskz ktosl secco gsber  qsshb                                   "Note 2175802
           FROM bseg APPENDING CORRESPONDING FIELDS OF TABLE gt_bseg WHERE bukrs = gs_bseg-bukrs
                                                   AND belnr = gs_bseg-belnr
                                                   AND gjahr = gs_bseg-gjahr
                                                   ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.
ENDFORM.                    "callback_bseg

"""""""""""""""""""begin of changes
*&---------------------------------------------------------------------*
*&      Form  callback_lfa1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*    --->NAME       text
*    --->WA         text
*    --->EVT        text
*    --->CHECK      text
*----------------------------------------------------------------------*
FORM callback_lfa1 USING name  TYPE ldbn-ldbnode
                          wa    TYPE lfa1
                          evt   TYPE c
                          check TYPE c.
  CLEAR gs_lfa1.
  IF s_lifnr IS NOT INITIAL OR p_pan EQ gc_x OR p_exemp EQ gc_x.
    IF  wa-lifnr IN s_lifnr.
      MOVE-CORRESPONDING wa TO gs_lfa1.

      SELECT lifnr j_1ipanno FROM lfa1 INTO TABLE gt_lfa1 WHERE  lifnr = gs_lfa1-lifnr.
    ENDIF.
  ENDIF.
ENDFORM.                    "callback_LFA1


*&---------------------------------------------------------------------*
*&      Form  callback_kna1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*    --->NAME       text
*    --->WA         text
*    --->EVT        text
*    --->CHECK      text
*----------------------------------------------------------------------*
FORM callback_kna1 USING name  TYPE ldbn-ldbnode
                          wa    TYPE kna1
                          evt   TYPE c
                          check TYPE c.
  CLEAR gs_kna1.
  IF s_kunnr IS NOT INITIAL.
    IF wa-kunnr IN s_kunnr.
      MOVE-CORRESPONDING wa TO gs_kna1.

      SELECT kunnr j_1ipanno FROM kna1 INTO TABLE gt_kna1 WHERE  kunnr = gs_kna1-kunnr.
    ENDIF.
  ENDIF.
ENDFORM.                    "callback_KNA1

"""""""""""""""""""""""""end of changes
*&---------------------------------------------------------------------*
*&      Form  callback_with
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*    --->NAME       text
*    --->WA         text
*    --->EVT        text
*    --->CHECK      text
*----------------------------------------------------------------------*
FORM callback_with USING name  TYPE ldbn-ldbnode
                          wa    TYPE with_item
                          evt   TYPE c
                          check TYPE c.
  CLEAR gs_witem.
  IF wa-bukrs = p_bukrs
*    AND wa-gjahr = p_year
*    AND wa-gjahr = GV_PREVYR "1695696 "1727552
    AND gs_bseg-secco IN s_secco AND gv_reversal = 0. "Note 1584640/1615465
    MOVE-CORRESPONDING wa TO gs_witem.
    " Reading BSEG to check TDS line is there or not.For DPC document system will
    " update with_item with offsetting entry even though TDS not present for DPC.
    READ TABLE gt_bseg TRANSPORTING NO FIELDS WITH KEY belnr = wa-belnr
                                                       ktosl = 'WIT'.
    IF sy-subrc EQ 0.    "Note 2256460
      APPEND gs_witem TO gt_witem.
    ENDIF.
  ENDIF.
ENDFORM.                    "callback_with

*&      Form  SELECT_BASIC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_STARTDATE  text
*      -->P_ENDDATE  text
*----------------------------------------------------------------------*
FORM select_basic_data  USING    p_startdate  TYPE budat
                                 p_enddate    TYPE budat.

  DATA: lt_witem LIKE LINE OF gt_witem.  "note 1584640
  DATA: lt_t059z TYPE t059z.      "note 1584640

  IF gt_bseg[] IS  NOT INITIAL.

    IF gt_witem[] IS NOT INITIAL.
      IF p_intc EQ gc_x.
        DELETE gt_witem WHERE j_1iintchln EQ space
                        AND   j_1iintchdt EQ gc_chdate.
        DELETE gt_witem WHERE j_1iintchln EQ space
                        AND   j_1iintchdt EQ space.

      ENDIF.

      IF p_noch EQ gc_x.
        DELETE gt_witem WHERE j_1iintchln NE space
                        AND   j_1iintchdt NE gc_chdate.
        DELETE gt_witem WHERE j_1iintchln NE space
                        AND   j_1iintchdt NE space.
      ENDIF.
      IF p_cert EQ gc_x.
        DELETE gt_witem WHERE ctnumber    EQ space
                        AND   j_1icertdt  EQ gc_chdate.
        DELETE gt_witem WHERE ctnumber    EQ space
                        AND   j_1icertdt  EQ space.
      ENDIF.
      IF gt_witem[] IS NOT INITIAL.
        SELECT witht
               wt_withcd
               qscod
          FROM t059z
          INTO TABLE gt_t059z
          FOR ALL ENTRIES IN  gt_witem
          WHERE land1 = 'IN'
          AND   witht = gt_witem-witht
          AND   wt_withcd = gt_witem-wt_withcd
          AND   qscod IN s_qscod.
* Note 1584640 start
        LOOP AT gt_witem INTO lt_witem.
          READ TABLE gt_t059z INTO lt_t059z WITH KEY witht = lt_witem-witht
                                                 wt_withcd = lt_witem-wt_withcd.
          IF sy-subrc NE 0.
            DELETE  gt_witem WHERE witht = lt_witem-witht
                                    AND wt_withcd = lt_witem-wt_withcd.
          ELSE.
            lt_witem-qscod = lt_t059z-qscod.
            MODIFY gt_witem FROM lt_witem..
          ENDIF.
        ENDLOOP.
*End of note 1584640
        SELECT * FROM j_1iewtchln
          INTO TABLE gt_j_1iewtchln
          FOR ALL ENTRIES IN gt_witem
          WHERE bukrs = gt_witem-bukrs
          AND   j_1iintchln = gt_witem-j_1iintchln
          AND   j_1iintchdt = gt_witem-j_1iintchdt
          AND   j_1iextchln IS NOT NULL
          AND   j_1iextchdt NE gc_chdate.
      ENDIF.
      PERFORM determine_fiscal_year_for_ackn.
      CASE s_qscod.
        WHEN '194E' OR '195' OR '196A' OR '196B' OR '196C' OR '196D'.
          wa_form_type = '27Q'.
        WHEN '206C'.
          wa_form_type = '27E'.
        WHEN OTHERS.
          wa_form_type = '26Q'.
      ENDCASE.
      SELECT * FROM j_1iewt_ackn
        INTO TABLE gt_j_1iewt_ackn
        FOR ALL ENTRIES IN gt_bseg
        WHERE bukrs  = gt_bseg-bukrs
        AND   gjahr  = year
        AND   secco  = gt_bseg-secco
        AND   period = gv_period
        AND   form_type = wa_form_type.
      SORT gt_j_1iewt_ackn.
      DELETE ADJACENT DUPLICATES FROM gt_j_1iewt_ackn COMPARING ALL FIELDS.
    ENDIF.
  ENDIF.
  SELECT lifnr
         j_1ipanno
         FROM lfa1            "S4BP
         INTO TABLE gt_lfa1 ""gt_movend
     WHERE lifnr IN s_lifnr.

  SELECT kunnr
         j_1ipanno
         FROM kna1           "S4BP
         INTO TABLE gt_kna1 ""gt_movend
     WHERE lifnr IN s_kunnr.

ENDFORM.                    " SELECT_BASIC
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcatalog .
  DATA: lv_col TYPE i . "VALUE 0.
  lv_col = lv_col + 1.
  PERFORM build_struct USING c_belnr
                             'Document Number'            "TEXT-019
                             lv_col
                             gc_x
                             gc_x.

  lv_col = lv_col + 1.
  PERFORM build_struct USING c_xblnr
                             'Reference'            "TEXT-019
                             lv_col
                             gc_x
                             gc_x.

  lv_col = lv_col + 1.
  PERFORM build_struct USING  c_gsber
                              'Business Area'                             "TEXT-067
                              lv_col
                              space
                              space.

  lv_col = lv_col + 1.
  PERFORM build_struct USING  c_budat
                              'Posting Date'                          "TEXT-068
                              lv_col
                              space
                              space.

  lv_col = lv_col + 1.
  PERFORM build_struct USING  c_blart
                              'Document Type'                         "TEXT-069
                              lv_col
                              space
                              space.

  lv_col = lv_col + 1.
  PERFORM build_struct USING c_qscod
                             'Off Wtax Key'                               "TEXT-038
                             lv_col
                             space
                             space.

  lv_col = lv_col + 1.
  PERFORM build_struct USING c_secco
                             'Section Code'                           "TEXT-062   "Note 1847679
                             lv_col
                             space
                             space.
  lv_col = lv_col + 1.
  IF s_lifnr IS NOT INITIAL OR p_pan EQ gc_x OR p_exemp EQ gc_x.
    PERFORM build_struct USING  c_lifnr
*                                text-026 "1640173
                                ' '
                                lv_col
                                space
                                space.
    lv_col = lv_col + 1.
    PERFORM build_struct USING c_name
                               'Vendor Name '                  "TEXT-063   "Note 1847679
                               lv_col
                               space
                               space.

    lv_col = lv_col + 1.
    PERFORM build_struct USING c_qsrec
                               'Recipient type'                         "TEXT-064   "Note 1847679
                               lv_col
                               space
                               space.

    lv_col = lv_col + 1.
    PERFORM build_struct USING c_j_1ipanno
                               'PAN Number'                     "TEXT-066   "Note 1847679
                               lv_col
                               space
                               space.

  ELSEIF s_kunnr IS NOT INITIAL.

    PERFORM build_struct USING  c_kunnr
                                'Customer'               " TEXT-027
                                lv_col
                                space
                                space.
    lv_col = lv_col + 1.
    PERFORM build_struct USING  c_name
                                'Customer Name'                     "TEXT-065   "Note 1847679
                                lv_col
                                space
                                space.
    lv_col = lv_col + 1.
    PERFORM build_struct USING c_j_1ipanno
                               'PAN Number'                             "TEXT-066   "Note 1847679
                               lv_col
                               space
                               space.
  ENDIF.
  lv_col = lv_col + 1.
  PERFORM build_struct USING  c_witht
                              'Tax type'                            "TEXT-028
                              lv_col
                              space
                              space.
  lv_col = lv_col + 1.
  PERFORM build_struct USING  c_wt_withcd
                              'Tax code'                            "TEXT-029
                              lv_col
                              space
                              space.

  lv_col = lv_col + 1.
  PERFORM build_struct USING  c_qsatz
                              'Tax Rate'                                        "TEXT-040
                              lv_col
                              space
                              space.
  lv_col = lv_col + 1.
  PERFORM build_struct USING c_wt_qsshh
                             'Base Amount'                          "TEXT-030
                             lv_col
                             space
                             space.
  lv_col = lv_col + 1.
  PERFORM build_struct USING  c_wt_qbshh
                             'Tax Amount'                                 "TEXT-031
                             lv_col
                             space
                             space.
  lv_col = lv_col + 1.
  PERFORM build_struct USING  c_shkzg                                "Note 1596609
                              'Debit/Credit'                  "TEXT-061
                              lv_col
                              space
                              space.
  IF p_cert EQ gc_x.
    lv_col = lv_col + 1.
    PERFORM build_struct USING c_ackn_number
                               'Acknowledgement No.'                    "TEXT-024
                               lv_col
                               space
                               space.
  ENDIF.
  IF p_intc EQ gc_x OR p_cons EQ gc_x.
    lv_col = lv_col + 1.
    PERFORM build_struct USING  c_j_1iintchln
                                'Internal Challan No'                     "TEXT-032
                                lv_col
                                space
                                space.
    lv_col = lv_col + 1.
    PERFORM build_struct USING  c_j_1iintchdt
                                'Internal Challan Dt'                 "TEXT-033
                                lv_col
                                space
                                space.
  ENDIF.
  IF p_bnkc EQ gc_x OR p_cons EQ gc_x.
    lv_col = lv_col + 1.
    PERFORM build_struct USING  c_j_1iextchln
                                'External Challan No'                 "TEXT-034
                                lv_col
                                space
                                space.
    lv_col = lv_col + 1.
    PERFORM build_struct USING  c_j_1iextchdt
                                'External Challan Dt'                     "TEXT-035
                                lv_col
                                space
                                space.
  ENDIF.
  IF p_cert EQ gc_x OR p_cons EQ gc_x.
    lv_col = lv_col + 1.
    PERFORM build_struct USING c_ctnumber
                               'Certificate No'                         "TEXT-036
                               lv_col
                               space
                               space.
    lv_col = lv_col + 1.
    PERFORM build_struct USING  c_j_1icertdt
                                'Certificate Date'                    "TEXT-037
                                lv_col
                                space
                                space.
  ENDIF.



ENDFORM.                    " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_report .
  DESCRIBE TABLE gt_final LINES gv_totdocs.
  IF gv_totdocs EQ 0.
    MESSAGE i760(8i).
  ENDIF.
  gv_repid = sy-repid.
  gs_layout-zebra = gc_x.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = gv_repid
      i_callback_user_command = c_lselect
      i_callback_top_of_page  = c_top
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcatalog
      i_save                  = 'X'              "Note 1634559 For SELECT and SAVE layout in the ALV output.
    TABLES
      t_outtab                = gt_final.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*  call SCREEN 1000.
*  CALL SELECTION-SCREEN 1000.
*  LEAVE TO SCREEN 0.
ENDFORM.                    " DISPLAY_ALV_REPORT

*-------------------------------------------------------------------*
* Form  TOP-OF-PAGE                                                 *
*-------------------------------------------------------------------*
* ALV Report Header                                                 *
*-------------------------------------------------------------------*
FORM top-of-page.

  DATA: t_header         TYPE slis_t_listheader,
        lv_string(200),
        lv_totrecs(10),
        lv_startdate(10),
        lv_enddate(10),
        wa_header        TYPE slis_listheader.

  wa_header-typ  = gc_h.
  wa_header-info = TEXT-004.
  IF p_intc EQ gc_x.
    wa_header-info = TEXT-045.
  ELSEIF p_noch EQ gc_x.
    wa_header-info = TEXT-046.
  ELSEIF p_bnkc EQ gc_x.
    wa_header-info = TEXT-047.
  ELSEIF p_cert EQ gc_x.
    wa_header-info = TEXT-048.
  ENDIF.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.
  IF p_exemp = 'X'.
    lv_string = 'for 100% exempted documents'.
    wa_header-typ = gc_h.
    wa_header-info = lv_string.
    APPEND wa_header TO t_header.
    CLEAR: wa_header, lv_string.
  ENDIF.
  IF p_pan = 'X'.
    lv_string = 'for vendors without PAN'.
    wa_header-typ = gc_h.
    wa_header-info = lv_string.
    APPEND wa_header TO t_header.
    CLEAR: wa_header, lv_string.
  ENDIF.
  CONCATENATE startdate+6(2) c_dot
              startdate+4(2) c_dot
              startdate+0(4) INTO lv_startdate.
  CONCATENATE enddate+6(2) c_dot
              enddate+4(2) c_dot
              enddate+0(4) INTO lv_enddate.
  CONCATENATE TEXT-052 lv_startdate TEXT-053  lv_enddate
         INTO lv_string SEPARATED BY space.
  wa_header-typ = gc_s.
  wa_header-info = lv_string.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, lv_string.
  SELECT SINGLE butxt FROM t001
    INTO gv_coname
    WHERE bukrs = p_bukrs.
  CONCATENATE TEXT-054 p_bukrs TEXT-055 gv_coname
             INTO lv_string
             SEPARATED BY space.
  wa_header-typ = gc_s.
  wa_header-info = lv_string.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, lv_string.
  CONCATENATE TEXT-056 p_year   INTO lv_string.
  wa_header-typ = gc_s.
  wa_header-info = lv_string.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, lv_string.
*  SELECT SINGLE name FROM seccodet                  "Note 1847679
*    INTO gv_secname
*    WHERE spras = sy-langu
*    AND   bukrs = p_bukrs
*    AND   seccode = p_secco.
*  CONCATENATE text-057 p_secco text-055 gv_secname
*              INTO lv_string
*              SEPARATED BY space.
*  wa_header-typ = gc_s.
*  wa_header-info = lv_string.
*  APPEND wa_header TO t_header.
*  CLEAR: wa_header, lv_string.
  SELECT SINGLE tanno FROM j_1i_secco_cit
    INTO gv_tanno
    WHERE   bukrs   = p_bukrs
    AND     seccode IN s_secco.                      "Note 1847679
  CONCATENATE TEXT-058 gv_tanno
            INTO lv_string
            SEPARATED BY space.
  wa_header-typ = gc_s.
  wa_header-info = lv_string.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, lv_string.
  DESCRIBE TABLE gt_final LINES gv_totdocs.   "Note 1592267
  lv_totrecs = gv_totdocs.
  CONCATENATE TEXT-059 lv_totrecs
             INTO lv_string
             SEPARATED BY space.
  wa_header-typ = gc_s.
  wa_header-info = lv_string.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, lv_string, gv_totdocs, lv_totrecs.
  lv_totrecs = gv_faultdocs.
  CONCATENATE TEXT-060 lv_totrecs
             INTO lv_string
             SEPARATED BY space.
  wa_header-typ = gc_s.
  wa_header-info = lv_string.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, lv_string, gv_totdocs, lv_totrecs.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.
ENDFORM.                    "top-of-page
*&---------------------------------------------------------------------*
*&      Form  BUILD_STRUCT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0931   text
*      -->P_0932   text
*      -->P_1      text
*----------------------------------------------------------------------*
FORM build_struct  USING    p_fieldname  TYPE slis_fieldname
                            p_seltext    TYPE scrtext_m
                            p_colpos     TYPE sy-cucol
                            p_hotspot    TYPE c
                            p_key        TYPE c.
  gs_fieldcatalog-fieldname   = p_fieldname.
  gs_fieldcatalog-key         = p_key.
  gs_fieldcatalog-seltext_m   = p_seltext.
  gs_fieldcatalog-col_pos     = p_colpos.
  gs_fieldcatalog-hotspot     = p_hotspot.
  IF p_fieldname EQ 'LIFNR'.                                "1640173
    gs_fieldcatalog-ref_tabname = 'LFA1'.
  ENDIF.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.
  CLEAR  gs_fieldcatalog.
ENDFORM.                    " BUILD_STRUCT
*&---------------------------------------------------------------------*
*&      Form  POPULATE_FINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_final_data .

  BREAK ppadhy.
  SORT gt_bkpf  BY bukrs
                   belnr
                   gjahr.

  SORT gt_bseg BY bukrs
                  belnr
                  gjahr
                  buzei.

  SORT gt_witem BY bukrs
                    belnr
                    gjahr
                    j_1ibuzei.

  SORT gt_t059z BY witht
                   wt_withcd.

  SORT  gt_j_1iewtchln BY bukrs
                          belnr
                          gjahr
                          j_1iintchln
                          j_1iintchdt.

  SORT gt_j_1iewt_ackn BY bukrs
                          gjahr
                          secco
                          form_type
                          period.
  CLEAR gv_faultdocs.
  DELETE gt_witem WHERE ( j_1ibuzei IS INITIAL AND wt_qszrt IS INITIAL ) OR wt_stat NE ' '." Note 1584640 "Note 2074365
  LOOP AT gt_witem INTO gs_witem.
    READ TABLE gt_bkpf INTO gs_bkpf
              WITH KEY bukrs = gs_witem-bukrs
                       belnr = gs_witem-belnr
                       gjahr = gs_witem-gjahr
                       BINARY SEARCH.
    IF sy-subrc EQ 0.

      gs_final-xblnr = gs_bkpf-xblnr.

*      gv_prev_mon = gs_bkpf-budat+4(2).
*      SELECT SINGLE periv FROM t001
*        INTO gv_periv WHERE bukrs = gs_bkpf-bukrs.
*      SELECT SINGLE poper FROM t009b
*        INTO gv_prev_poper
*        WHERE periv = gv_periv
*        AND   bumon = gv_prev_mon .
*      CALL FUNCTION 'CKML_F_GET_NEXT_PERIOD'
*        EXPORTING
*          input_period = gv_prev_poper
*          input_year   = gs_bkpf-budat+0(4)
*          input_periv  = gv_periv
*        IMPORTING
*          next_period  = gv_next_poper
*          next_year    = gv_next_year.
**      IF sy-subrc EQ 0.
*        SELECT SINGLE bumon FROM t009b
*          INTO gv_next_mon
*          WHERE periv = gv_periv
*          AND   poper = gv_next_poper.
*        CONCATENATE gv_next_year gv_next_mon c_07
*        INTO gv_date.
*        gv_date_final = gv_date.
*      ENDIF.

      CALL FUNCTION 'MONTH_PLUS_DETERMINE'
        EXPORTING
          months  = 01
          olddate = gs_bkpf-budat
        IMPORTING
          newdate = gv_date_final.

      IF sy-subrc EQ 0.
        gv_date_final+6(2) = c_07.
      ENDIF.


    ENDIF.
    READ TABLE gt_bseg INTO gs_bseg
              WITH KEY bukrs = gs_witem-bukrs
                       belnr = gs_witem-belnr
                       gjahr = gs_witem-gjahr
                       buzei = gs_witem-j_1ibuzei
                       BINARY SEARCH.


    IF sy-subrc NE 0 OR gs_witem-witht NE gs_bseg-qsskz . " Note 1592267
      gv_faultdocs = gv_faultdocs.
      CLEAR gs_bseg.                                      " Note 1584640
    ENDIF.
    IF gs_witem-j_1iintchln IS INITIAL OR gs_witem-j_1iintchdt IS INITIAL. " Note 1584640
      IF sy-datum > gv_date_final.
        gs_final-line_color = c_color.
      ENDIF.
    ENDIF.

    IF s_kunnr[] IS INITIAL.
      SELECT SINGLE lifnr FROM
        bseg INTO gs_final-lifnr
              WHERE bukrs = gs_witem-bukrs
              AND   belnr = gs_witem-belnr
              AND   gjahr = gs_witem-gjahr
              AND   lifnr NE space
              AND   buzei = gs_witem-buzei.    "Note 1923587

      SELECT SINGLE qsrec FROM                          "Note 1847679
         lfbw INTO gs_final-qsrec
              WHERE  lifnr = gs_final-lifnr
               AND   bukrs = gs_witem-bukrs
               AND   witht = gs_witem-witht.           "Note 1989800


      SELECT SINGLE name1  j_1ipanno FROM
         lfa1 INTO ( gs_final-name , gs_final-j_1ipanno )
              WHERE lifnr = gs_final-lifnr.
*               AND  land1 = 'IN'. "Note 2062279
    ELSE.
      SELECT SINGLE kunnr FROM
        bseg INTO gs_final-kunnr
              WHERE bukrs = gs_witem-bukrs
              AND   belnr = gs_witem-belnr
              AND   gjahr = gs_witem-gjahr
              AND   kunnr NE space.

      SELECT SINGLE name1 j_1ipanno FROM                       "Note 1927352
         kna1 INTO ( gs_final-name , gs_final-j_1ipanno )
              WHERE kunnr = gs_final-kunnr
               AND  land1 = 'IN'.
    ENDIF.
    IF gs_witem-wt_qszrt NE 100.   " Note 1584640
      IF gs_bseg-ktosl = c_wit OR gs_bseg-ktosl = 'OFF'.
        IF gs_bseg-buzei NE gs_witem-j_1ibuzei.
*        gv_faultdocs = gv_faultdocs + 1."Note 1584640
          gs_final-line_color = c_color. " Note 1584640 faulty documents will come in red
        ENDIF.
      ENDIF.
    ENDIF.
    gs_final-belnr = gs_witem-belnr.
    gs_final-buzei = gs_witem-j_1ibuzei.
    READ TABLE gt_j_1iewt_ackn INTO gs_j_1iewt_ackn
              WITH KEY  bukrs      = gs_bseg-bukrs
                        gjahr      = year                      "Note 1596609
                        secco      = gs_bseg-secco
                        period     = gv_period
                        BINARY SEARCH.
    IF sy-subrc EQ 0.
      gs_final-ackn_number = gs_j_1iewt_ackn-ackn_number.
    ENDIF.

    gs_final-budat        = gs_bkpf-budat.
    gs_final-blart        = gs_bkpf-blart.

    LOOP AT gt_bseg INTO DATA(w_bseg) WHERE belnr = gs_bseg-belnr AND bukrs = gs_bseg-bukrs AND gjahr = gs_bseg-gjahr AND  qsshb NE '0.00'.

      gs_final-gsber        = w_bseg-gsber.

      EXIT.

    ENDLOOP.
*BREAK PPADHY.
**    IF gs_bseg-qsshb IS NOT INITIAL.
**
**    ENDIF.
    gs_final-secco        = gs_bseg-secco.                    "Note 1847679
    gs_final-witht        = gs_witem-witht.
    gs_final-wt_withcd    = gs_witem-wt_withcd.
    gs_final-qsatz        = gs_witem-qsatz.
    gs_final-wt_qsshh     = abs( gs_witem-wt_qsshh ).  "Base Amount
    gs_final-wt_qbshh     = abs( gs_witem-wt_qbshh ).  "Tax Amount
    gs_final-shkzg        = gs_bseg-shkzg.               "Note 1596609
    IF gs_final-shkzg = 'H' .
      gs_final-shkzg = 'C'.
    ELSEIF gs_final-shkzg = 'S'.
      gs_final-shkzg = 'D'.
    ENDIF.
    IF gs_BSEG-shkzg = 'H'.
*      gs_final-wt_qsshh     = gs_final-wt_qsshh * -1.         "note 1762701
      gs_final-wt_qbshh     = gs_final-wt_qbshh * -1.         "note 1762701
    ENDIF.

    if  gs_final-shkzg = 'D'.
  gs_final-wt_qsshh     = gs_final-wt_qsshh * -1.         "note 1762701
ENDIF.
    gs_final-j_1iintchln  = gs_witem-j_1iintchln.
    gs_final-j_1iintchdt  = gs_witem-j_1iintchdt.
    gs_final-ctnumber     = gs_witem-ctnumber.
    gs_final-j_1icertdt   = gs_witem-j_1icertdt.
    gs_final-j_1ibuzei    = gs_witem-j_1ibuzei.


    READ TABLE gt_t059z INTO gs_t059z
              WITH KEY witht = gs_witem-witht
                       wt_withcd = gs_witem-wt_withcd
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gs_final-qscod = gs_t059z-qscod.
    ENDIF.
    READ TABLE gt_j_1iewtchln INTO gs_j_1iewtchln
             WITH KEY bukrs       = gs_witem-bukrs
                      j_1iintchln = gs_witem-j_1iintchln
                      j_1iintchdt = gs_witem-j_1iintchdt.
    "                    BINARY SEARCH.                         Note 1592267
    IF sy-subrc EQ 0.
      gs_final-j_1iextchln = gs_j_1iewtchln-j_1iextchln.
      gs_final-j_1iextchdt = gs_j_1iewtchln-j_1iextchdt.
    ENDIF.
    IF p_pan EQ gc_x.
      CLEAR gs_movend.
      READ TABLE gt_movend INTO gs_movend
      WITH KEY lifnr = gs_final-lifnr.
      IF gs_movend-j_1ipanno IS INITIAL.
        APPEND gs_final TO gt_final.
      ENDIF.
    ELSEIF p_exemp = gc_x.
      IF gs_witem-wt_qszrt = 100.
        APPEND gs_final TO gt_final.
      ENDIF.
    ELSE.
      IF gs_witem-qscod = '206C'.
        IF gs_witem-wt_qbshh < 0. "WIT LINES ARE DEBIT LINE, so selecting OFFSET lines
          APPEND gs_final TO gt_final.
        ENDIF.
      ELSE.
        APPEND gs_final TO gt_final.
      ENDIF.
    ENDIF.
    CLEAR gs_final. "Note 1584640
**  ENDLOOP.

    IF p_bnkc EQ gc_x.
      DELETE gt_final WHERE j_1iextchln EQ space
                      AND   j_1iextchdt EQ space.
      DELETE gt_final WHERE j_1iextchln EQ space
                      AND   j_1iextchdt EQ gc_chdate.
      DELETE gt_final WHERE j_1iintchln EQ space
                      AND   j_1iintchdt EQ space.
      DELETE gt_final WHERE j_1iintchln EQ space
                      AND   j_1iintchdt EQ gc_chdate.
    ENDIF.
    IF p_intc EQ gc_x.
      DELETE gt_final WHERE j_1iintchln EQ space
                      AND   j_1iintchdt EQ space.
      DELETE gt_final WHERE j_1iintchln EQ space
                      AND   j_1iintchdt EQ gc_chdate.
    ENDIF.

    IF p_exemp IS INITIAL.
      DELETE gt_final WHERE wt_qbshh = 0.
    ENDIF.

  ENDLOOP.
*" Note 1584640 number of faulty documents
  LOOP AT gt_final INTO gs_final.
    IF gs_final-line_color IS NOT INITIAL.
      gv_faultdocs = gv_faultdocs + 1.
    ENDIF.
  ENDLOOP.
  CLEAR: gs_final, gs_bkpf, gs_bseg, gs_j_1iewtchln.
ENDFORM.                    " POPULATE_FINAL
*---------------------------------------------------------------------*
*       FORM line_selection                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  r_ucomm                                                       *
*  -->  rs_selfield                                                   *
*---------------------------------------------------------------------*
FORM line_selection USING r_ucomm     LIKE sy-ucomm
                          rs_selfield TYPE slis_selfield.
  DATA:ls_bkpf TYPE bkpf.
  DATA:lv_year TYPE bseg-gjahr.
  IF rs_selfield-fieldname = c_belnr.
    lv_year = p_year.
    IF  first_date+4(2)  = '01'.
      lv_year = first_date+0(4). "Note 2276083
    ENDIF.
    SELECT SINGLE * FROM bkpf INTO ls_bkpf WHERE bukrs = p_bukrs AND belnr = rs_selfield-value AND gjahr = lv_year.
    CASE   r_ucomm.
      WHEN c_ic1.
        SET PARAMETER ID c_bln  FIELD ls_bkpf-belnr.
        SET PARAMETER ID c_buk  FIELD ls_bkpf-bukrs.
        SET PARAMETER ID c_gjr  FIELD ls_bkpf-gjahr.
        CALL TRANSACTION c_fb03 AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDIF.                                                           "Note 1584640
ENDFORM.                               " LINE_SELECTION
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_FISCAL_YEAR_FOR_ACKN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM determine_fiscal_year_for_ackn .
  DATA : temp_date TYPE bkpf-budat VALUE '99999999',      "#EC VALUE_OK
         month     TYPE i.
  IF temp_date > startdate.
    temp_date = startdate.
  ENDIF.
  month = temp_date+4(2).
  year  = temp_date(4).

  IF month > 3 AND month <= 12.
    year = year + 1.
  ENDIF.
ENDFORM.                    " DETERMINE_FISCAL_YEAR_FOR_ACKN

*BOI NOTE 1592267
*&---------------------------------------------------------------------*
*&      Form  GET_YEAR_FROM_FISCALYEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_year_from_fiscalyear .
  DATA : ld_periv  TYPE t001-periv.
  DATA : gb_flex TYPE boole_d.
  IF gv_ledger EQ p_ledger. "Note 1615465
    SELECT SINGLE periv FROM t001 INTO ld_periv WHERE bukrs = p_bukrs.
    IF sy-subrc = 0.
      CALL FUNCTION 'FIRST_DAY_IN_PERIOD_GET'
        EXPORTING
          i_gjahr = p_year
*         I_MONMIT             = 00
          i_periv = ld_periv
          i_poper = '01'
        IMPORTING
          e_date  = first_date.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
  ELSE.
    CALL FUNCTION 'FAGL_CHECK_GLFLEX_ACTIVE'
      EXPORTING
        id_bukrs        = p_bukrs
      IMPORTING
        e_glflex_active = gb_flex.
    IF NOT gb_flex IS INITIAL.
      SELECT SINGLE periv FROM t882g INTO ld_periv WHERE rbukrs = p_bukrs AND rldnr = p_ledger.
      IF sy-subrc = 0.
        CALL FUNCTION 'FIRST_DAY_IN_PERIOD_GET'
          EXPORTING
            i_gjahr = p_year
*           I_MONMIT             = 00
            i_periv = ld_periv
            i_poper = '01'
          IMPORTING
            e_date  = first_date.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_YEAR_FROM_FISCALYEAR
*EOI NOTE 1592267
*EOI NOTE 1592267
*&---------------------------------------------------------------------*
*&      Form  FILL_LEDGER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_ledger .
  SELECT SINGLE rldnr FROM t881 INTO gv_ledger WHERE xleading = 'X'.
  IF sy-subrc = 0 AND p_ledger IS INITIAL.
    p_ledger = gv_ledger.
  ENDIF.
ENDFORM.                    " FILL_LEDGER
*&---------------------------------------------------------------------*
*&      Form  FILL_PROV_UTIL_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_prov_util_doc .

  DATA: lt_bkpf      TYPE TABLE OF bkpf, "Note 2045607
        lt_bseg      TYPE TABLE OF ty_bseg, "Note 2175802
        lt_with_item TYPE TABLE OF with_item.

  DATA: lt_budat TYPE TABLE OF selopt,
        ls_budat TYPE selopt.

  DATA lv_year TYPE gjahr.

  ls_budat-sign = 'I'.
  ls_budat-option = 'BT'.
  ls_budat-low = startdate.
  ls_budat-high = enddate.

  APPEND ls_budat TO lt_budat.
  CLEAR ls_budat.

  lv_year = p_year. "Note 2435008

  SELECT * FROM bkpf INTO TABLE lt_bkpf WHERE bukrs EQ p_bukrs
                                        AND gjahr EQ lv_year
                                        AND budat IN lt_budat
                                        AND  tcode IN ('J1INUT', 'J1INPR').

  IF lt_bkpf IS NOT INITIAL.

    SELECT bukrs belnr gjahr buzei koart shkzg qsskz ktosl secco           "Note 2175802
        FROM bseg INTO CORRESPONDING FIELDS OF TABLE lt_bseg
          FOR ALL ENTRIES IN lt_bkpf WHERE bukrs EQ lt_bkpf-bukrs
                             AND belnr EQ lt_bkpf-belnr
                             AND gjahr EQ lt_bkpf-gjahr
                             AND buzei NE '000'
                             AND ktosl EQ 'WIT'
                             AND lifnr IN s_lifnr           "2073106
                             AND secco IN s_secco.

    IF lt_bseg IS NOT INITIAL.

      SELECT * FROM with_item INTO TABLE lt_with_item
                   FOR ALL ENTRIES IN lt_bseg WHERE
                             bukrs EQ lt_bseg-bukrs
                         AND belnr EQ lt_bseg-belnr
                         AND gjahr EQ lt_bseg-gjahr
                         AND wt_withcd NE ''.
    ENDIF.

  ENDIF.

  APPEND LINES OF lt_bkpf TO gt_bkpf.
  APPEND LINES OF lt_bseg TO gt_bseg.
  APPEND LINES OF lt_with_item TO gt_witem.   "Note 2045607

ENDFORM.                    " FILL_PROV_UTIL_DOC
*&---------------------------------------------------------------------*
*&      Form  FETCH_PERIOD_INTERVAL
*&---------------------------------------------------------------------*
FORM fetch_period_interval USING p_first_date TYPE budat
                                 p_p_qrtr     TYPE j_1i_qrtr
                                 p_p_mnth     TYPE j_1i_month
                        CHANGING p_startdate  TYPE sydatum
                                 p_enddate    TYPE sydatum.

  DATA:lv_month(2) TYPE n,
       lv_year     TYPE gjahr,
       lv_total    TYPE c LENGTH 2,
       startdate1  TYPE sydatum.

  "This condition is required if fiscal year variant with 0 shift or
  "Calender year(Jan to Dec)
  IF p_year EQ first_date+0(4).
    IF p_p_qrtr IS NOT INITIAL.
      lv_month = p_first_date+4(2).
      CASE p_p_qrtr.
        WHEN c_q1.
          lv_total = lv_month.
        WHEN c_q2.
          lv_total = lv_month + 3.
        WHEN c_q3.
          lv_total = lv_month + 6.
        WHEN c_q4.
          lv_total = lv_month + 9.
      ENDCASE.

      IF lv_total LE 3.
        CONCATENATE p_year c_01 c_01 INTO startdate.
        CONCATENATE p_year c_03 c_31 INTO enddate.
      ELSEIF lv_total LE 6.
        CONCATENATE p_year c_04 c_01 INTO startdate.
        CONCATENATE p_year c_06 c_30 INTO enddate.
      ELSEIF lv_total LE 9.
        CONCATENATE p_year c_07 c_01 INTO startdate.
        CONCATENATE p_year c_09 c_30 INTO enddate.
      ELSEIF lv_total LE 12.
        CONCATENATE p_year c_10 c_01 INTO startdate.
        CONCATENATE p_year c_12 c_31 INTO enddate.
      ELSEIF lv_total GT 12.
        lv_year = p_year + 1.
        lv_month = lv_total - 12.
        CONCATENATE lv_year lv_month c_01 INTO startdate.

        lv_month = lv_month + 2.
        CONCATENATE lv_year lv_month c_01 INTO startdate1.

        CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = startdate1
          IMPORTING
            last_day_of_month = enddate.

      ENDIF.

    ELSEIF p_p_mnth IS NOT INITIAL.
      lv_month = p_first_date+4(2).

      CASE p_p_mnth.
        WHEN c_jan.
          IF lv_month GT c_01.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_01 c_01 INTO startdate.
            PERFORM fetch_last_day USING  startdate
                                 CHANGING enddate.
          ELSE.
            CONCATENATE p_year c_01 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_feb.
          IF lv_month GT c_02.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_02 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_02 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_mar.
          IF lv_month GT c_03.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_03 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_03 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_apr.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_04 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_04 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_may.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_05 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_05 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_jun.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_06 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_06 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_jul.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_07 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_07 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.


        WHEN c_aug.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_08 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_08 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_sep.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_09 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_09 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_oct.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_10 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_10 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_nov.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_11 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_11 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.

        WHEN c_dec.
          IF lv_month GT c_04.
            lv_year = p_year + 1.
            CONCATENATE lv_year c_12 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ELSE.
            CONCATENATE p_year c_12 c_01 INTO startdate.
            PERFORM fetch_last_day USING    startdate
                                 CHANGING   enddate.
          ENDIF.
      ENDCASE.

    ENDIF.
    "This condition is required if customer has maintained fiscal year variant
    " with +1 year shift. They have not used standard 0 shift or Calender year.
  ELSEIF p_year NE first_date+0(4).

    DATA: lv_date(8),
          lv_sdate(10),
          lv_edate(10),
          lv_startdate TYPE sy-datum.
    gv_prevyr = first_date+0(4).
    IF p_mnth IS NOT INITIAL.
      CASE p_mnth.
        WHEN c_apr.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_04 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q1.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_may.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_05 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q1.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_jun.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_06 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q1.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_jul.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_07 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q2.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_aug.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_08 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q2.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_sep.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_09 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q2.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_oct.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_10 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q3.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_nov.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_11 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q3.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_dec.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_12 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q3.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_jan.
          CLEAR lv_date.
          gv_prevyr = gv_prevyr + 1.
          CONCATENATE gv_prevyr c_01 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q4.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_feb.
          CLEAR lv_date.
          gv_prevyr = gv_prevyr + 1.
          CONCATENATE gv_prevyr c_02 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q4.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
        WHEN c_mar.
          CLEAR lv_date.
          gv_prevyr = gv_prevyr + 1.
          CONCATENATE gv_prevyr c_03 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q4.
          PERFORM fetch_last_day USING    p_startdate
                                 CHANGING p_enddate.
      ENDCASE.
    ELSEIF p_qrtr IS NOT INITIAL.
      gv_prevyr = first_date+0(4).
      CASE p_qrtr.
        WHEN c_q1.
          CLEAR: lv_startdate, lv_date.
          CONCATENATE gv_prevyr c_04 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q1.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_06 c_01 INTO lv_date.
          lv_startdate = lv_date.
          PERFORM fetch_last_day USING    lv_startdate
                                 CHANGING p_enddate.
        WHEN c_q2.
          CLEAR: lv_startdate, lv_date.
          CONCATENATE gv_prevyr c_07 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q2.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_09 c_01 INTO lv_date.
          lv_startdate = lv_date.
          gv_period = c_q3.
          PERFORM fetch_last_day USING    lv_startdate
                                 CHANGING p_enddate.
        WHEN c_q3.
          CLEAR: lv_startdate, lv_date.
          CONCATENATE gv_prevyr c_10 c_01 INTO lv_date.
          p_startdate = lv_date.
          gv_period = c_q4.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_12 c_01 INTO lv_date.
          lv_startdate = lv_date.
          PERFORM fetch_last_day USING    lv_startdate
                                 CHANGING p_enddate.
        WHEN c_q4.
          CLEAR: lv_startdate, lv_date.
          gv_prevyr = gv_prevyr + 1.
          CONCATENATE gv_prevyr c_01 c_01 INTO lv_date.
          p_startdate = lv_date.
          CLEAR lv_date.
          CONCATENATE gv_prevyr c_03 c_01 INTO lv_date.
          lv_startdate = lv_date.
          PERFORM fetch_last_day USING    lv_startdate
                                 CHANGING p_enddate.
      ENDCASE.
    ENDIF.
    IF p_startdate IS NOT INITIAL
      AND p_enddate IS NOT INITIAL.
      IF p_mnth IS NOT INITIAL.
        CONCATENATE p_startdate+6(2) c_dot
                    p_startdate+4(2) c_dot
                    p_startdate+0(4)
                    INTO lv_sdate.
        CONCATENATE p_enddate+6(2) c_dot
                    p_enddate+4(2) c_dot
                    p_enddate+0(4)
                    INTO lv_edate.
        CONCATENATE gc_from lv_sdate  gc_to
                           lv_edate
             INTO gv_text_period
             SEPARATED BY space.
        CLEAR: lv_sdate, lv_edate.
      ELSEIF p_qrtr IS NOT INITIAL.
        CONCATENATE p_startdate+6(2) c_dot
                    p_startdate+4(2) c_dot
                    p_startdate+0(4)
                    INTO lv_sdate.
        CONCATENATE p_enddate+6(2) c_dot
                    p_enddate+4(2) c_dot
                    p_enddate+0(4)
                    INTO lv_edate.
        CONCATENATE gc_from lv_sdate  gc_to
                           lv_edate
             INTO gv_text_month
             SEPARATED BY space.
        CLEAR: lv_sdate, lv_edate.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
