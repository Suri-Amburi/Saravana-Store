*----------------------------------------------------------------------*
***INCLUDE LMGD2O11.
*       Material Master: PBO Modules for Material Ledger
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHECK_SUB_ML  OUTPUT
*&---------------------------------------------------------------------*
* If T001K entry for material ledger is active and the other
* customizing settings are not against it, instead of the
* three standard valuation Subscreens, the ML subscreens are
* processed.
*----------------------------------------------------------------------*

MODULE CHECK_SUB_ML OUTPUT.

* S4: Use of value-only articles is not supported in ML.    A
 DATA: iv_value_only  TYPE Boolean.
 clear iv_value_only.
* S4: Use of value-only articles is not supported in ML.    E

 CHECK mbew-bwkey NE space.
 CLEAR: t001k, t134m.

* S4: Use of Material Ledger is mandatory. In case of inactive ML, show
*     at least the old MBEW screens
  prog1_val = 'SAPLMGD2'.
  sub1_val  = '2801'.
  prog2_val = 'SAPLWRF_ARTICLE_SCREENS'.
  sub2_val  = '2812'.
  prog3_val = 'SAPLMGD2'.
  sub3_val  = '2804'.

  CALL FUNCTION 'T001K_SINGLE_READ'
       EXPORTING
            bwkey      = mbew-bwkey
       IMPORTING
            wt001k     = t001k.

  CALL FUNCTION 'T134M_SINGLE_READ'
       EXPORTING
            t134m_bwkey = mbew-bwkey
            t134m_mtart = mara-mtart
       IMPORTING
            wt134m      = t134m
       EXCEPTIONS
            OTHERS      = 1.


* S4: Use of value-only articles is not supported in ML.    A
*  In this case the MBEW subscreens are used
  If RMMW2-BWKEY is initial.
      iv_value_only = 'X'.
  Endif.
* S4: Use of value-only articles is not supported in ML.    E


  IF t001k-mlbwa = 'X'
    AND iv_value_only IS initial
    AND NOT ( t130m-verar = 'PL' OR t130m-verar = 'AD' ).
    CALL FUNCTION 'CKML_F_CKML1_2_NECESSARY'
         EXPORTING
              l_matnr        = mbew-matnr
              l_bwtar        = mbew-bwtar
              l_bwkey        = mbew-bwkey
              l_bwtty        = mbew-bwtty
              s_wertu_valid  = 'X'
              s_wertu        = t134m-wertu
         EXCEPTIONS
              no_ml_records  = 1
              only_ckmlpr    = 2
              internal_error = 3.
    IF sy-subrc EQ 0 OR sy-subrc = 2.
      prog1_val = 'SAPLWRF_CKMMAT'.
      sub1_val  = '0010'.
      prog2_val = 'SAPLWRF_CKMMAT'.
      sub2_val  = '0001'.
      prog3_val = 'SAPLWRF_CKMMAT'.
      sub3_val  = '0001'.

    ENDIF.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CHECK_SUB_ML_STORE OUTPUT
*&---------------------------------------------------------------------*
* If T001K entry for material ledger is active and the other
* customizing settings are not against it, instead of the
* three standard valuation Subscreens, the ML subscreens are
* processed.
*&---------------------------------------------------------------------*
MODULE CHECK_SUB_ML_STORE OUTPUT.

* S4: Use of value-only articles is not supported in ML.    A
  clear iv_value_only.
* S4: Use of value-only articles is not supported in ML.    E

  CHECK mbew-bwkey NE space.
  CLEAR: t001k, t134m.

* S4: Use of Material Ledger is mandatory. In case of inactive ML, show
*     at least the old MBEW screens
  prog1_val = 'SAPLMGD2'.
  sub1_val  = '2801'.
  prog2_val = 'SAPLWRF_ARTICLE_SCREENS'.
  sub2_val  = '2802'.
  prog3_val = 'SAPLMGD2'.
  sub3_val  = '2806'.

  CALL FUNCTION 'T001K_SINGLE_READ'
       EXPORTING
            bwkey      = mbew-bwkey
       IMPORTING
            wt001k     = t001k.

  CALL FUNCTION 'T134M_SINGLE_READ'
       EXPORTING
            t134m_bwkey = mbew-bwkey
            t134m_mtart = mara-mtart
       IMPORTING
            wt134m      = t134m
       EXCEPTIONS
            OTHERS      = 1.

* S4: Use of value-only articles is not supported in ML.    A
*  In this case the MBEW subscreens are used
  If RMMG1-BWKEY is initial.
      iv_value_only = 'X'.
  Endif.
* S4: Use of value-only articles is not supported in ML.    E


  IF t001k-mlbwa = 'X'
    AND iv_value_only IS initial
    AND NOT ( t130m-verar = 'PL' OR t130m-verar = 'AD' ).
    CALL FUNCTION 'CKML_F_CKML1_2_NECESSARY'
         EXPORTING
              l_matnr        = mbew-matnr
              l_bwtar        = mbew-bwtar
              l_bwkey        = mbew-bwkey
              l_bwtty        = mbew-bwtty
              s_wertu_valid  = 'X'
              s_wertu        = t134m-wertu
         EXCEPTIONS
              no_ml_records  = 1
              only_ckmlpr    = 2
              internal_error = 3.
    IF sy-subrc EQ 0 OR sy-subrc = 2.
      prog1_val = 'SAPLWRF_CKMMAT'.
      sub1_val  = '0010'.
      prog2_val = 'SAPLWRF_CKMMAT'.
      sub2_val  = '0001'.
      prog3_val = 'SAPLWRF_CKMMAT'.
      sub3_val  = '0001'.
    ENDIF.
  ENDIF.

ENDMODULE.
MODULE MODIFY_SCREEN_INCOTERMS OUTPUT.

* note 2389622
* Only needed for dialog processing as ALE case runs via INFREC IDoc

  DATA LS_TINCVMAP    TYPE TINCVMAP.
  DATA LV_SCREEN_NAME TYPE C LENGTH 132.

  LOOP AT SCREEN.
*   Logic similar to screen SAPMM06I/0102 in ME1x but taking OMSR
*   field selection settings in addition into account
    IF SCREEN-GROUP1 = '063'.
*     T130F uses EINE fields, screen uses MMPUR_INCOTERMS_INFORECORDS fields
      LV_SCREEN_NAME = SCREEN-NAME.
      IF LV_SCREEN_NAME CS 'MMPUR_INCOTERMS_INFORECORDS'.
        REPLACE 'MMPUR_INCOTERMS_INFORECORDS' IN LV_SCREEN_NAME WITH 'EINE'.
      ENDIF.

*     Apply standard field control to the incoterm fields
      READ TABLE FAUSWTAB WITH KEY FNAME = LV_SCREEN_NAME BINARY SEARCH.
      IF SY-SUBRC = 0.
        SCREEN-ACTIVE      = FAUSWTAB-KZACT.
        SCREEN-INPUT       = FAUSWTAB-KZINP.
        SCREEN-INTENSIFIED = FAUSWTAB-KZINT.
        SCREEN-INVISIBLE   = FAUSWTAB-KZINV.
        SCREEN-OUTPUT      = FAUSWTAB-KZOUT.
        SCREEN-REQUIRED    = FAUSWTAB-KZREQ.
      ENDIF.

      IF CL_OPS_SWITCH_CHECK=>MM_SFWS_INCO_VERSIONS( ) EQ ABAP_TRUE.
        IF SCREEN-NAME EQ 'EINE-INCO1' OR SCREEN-NAME EQ 'EINE-INCO2'.
          SCREEN-INPUT     = 0.
          SCREEN-INVISIBLE = 1.
          SCREEN-OUTPUT    = 0.
        ENDIF.
        IF SCREEN-NAME EQ 'MMPUR_INCOTERMS_INFORECORDS-INCO3_L'.
*         Check whether Incoterm Location 2 field is disabled
*         (independent from any other field selection settings)
          SELECT SINGLE * FROM TINCVMAP
                          INTO LS_TINCVMAP
                         WHERE INCO1 EQ EINE-INCO1
                           AND INCOV EQ EINE-INCOV.
          IF SY-SUBRC EQ 0 AND LS_TINCVMAP-BSTOB IS INITIAL.
            SCREEN-INPUT = 0.
          ENDIF.
        ENDIF.
      ELSE.
        IF SCREEN-NAME EQ 'MMPUR_INCOTERMS_INFORECORDS-INCO2_L' OR
           SCREEN-NAME EQ 'MMPUR_INCOTERMS_INFORECORDS-INCO3_L' OR
           SCREEN-NAME EQ 'MMPUR_INCOTERMS_INFORECORDS-INCOV'   OR
           SCREEN-NAME EQ 'MMPUR_INCOTERMS_INFORECORDS-INCO1'.
          SCREEN-INPUT     = 0.
          SCREEN-INVISIBLE = 1.
          SCREEN-OUTPUT    = 0.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MAP_INCOTERMS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MAP_INCOTERMS OUTPUT.

  PERFORM MAP_INCOTERMS_PBO.     "note 2389622

ENDMODULE.
