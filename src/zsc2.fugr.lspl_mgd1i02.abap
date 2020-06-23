
*&---------------------------------------------------------------------*
*&      Module  SMEINH-NEST_FTR  INPUT
*&---------------------------------------------------------------------*
*   Check whether a Unit Of Measure was specified                      *
*   similarly to SMEINH-GEWEI                                          *
*----------------------------------------------------------------------*
MODULE smeinh-nest_ftr INPUT.

ENHANCEMENT-POINT ehp606_lspl_mgd1i02_01 SPOTS es_lspl_mgd1i02 .

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  CHECK smeinh-meinh NE space.

*--- Festhalten der Eingaben -------------------------------------
  meinh-nest_ftr = smeinh-nest_ftr.

ENDMODULE.                             " SMEINH-MEABM  INPUT
*&---------------------------------------------------------------------*
*&      Module  SMEINH-MAX_STACK  INPUT
*&---------------------------------------------------------------------*
*   Check whether a Unit Of Measure was specified                      *
*   similarly to SMEINH-GEWEI                                          *
*----------------------------------------------------------------------*
MODULE smeinh-max_stack INPUT.

ENHANCEMENT-POINT ehp606_lspl_mgd1i02_02 SPOTS es_lspl_mgd1i02 .

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  CHECK smeinh-meinh NE space.

*--- Festhalten der Eingaben -------------------------------------
  meinh-max_stack = smeinh-max_stack.

ENDMODULE.                             " SMEINH-MAX_STACK  INPUT
*&---------------------------------------------------------------------*
*&      Module  SMEINH-CAPAUSE  INPUT
*&---------------------------------------------------------------------*
*   Check whether a Unit Of Measure was specified                      *
*   similarly to SMEINH-GEWEI                                          *
*----------------------------------------------------------------------*
MODULE smeinh-capause INPUT.

ENHANCEMENT-POINT ehp606_lspl_mgd1i02_03 SPOTS es_lspl_mgd1i02 .

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  CHECK smeinh-meinh NE space.

*--- Festhalten der Eingaben -------------------------------------
  meinh-capause = smeinh-capause.

ENDMODULE.                             " SMEINH-CAPAUSE  INPUT
*&---------------------------------------------------------------------*
*&      Module  SMEINH-TOP_LOAD_FULL INPUT
*&---------------------------------------------------------------------*
*   Check whether a Unit Of Measure was specified                      *
*   similarly to SMEINH-GEWEI                                          *
*----------------------------------------------------------------------*
MODULE smeinh-top_load_full INPUT. "16.04.2018

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  CHECK smeinh-meinh NE space.

  CALL FUNCTION 'MARM_TOP_LOAD_FULL'
    CHANGING
      cv_top_load_full     = smeinh-top_load_full
      cv_top_load_full_uom = smeinh-top_load_full_uom
    EXCEPTIONS
      error                = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING wrong_dimension.
  ENDIF.

*--- Festhalten der Eingaben -------------------------------------
  meinh-top_load_full     = smeinh-top_load_full.
  meinh-top_load_full_uom = smeinh-top_load_full_uom.

ENDMODULE.                             " SMEINH-TOP_LOAD_FULL INPUT
