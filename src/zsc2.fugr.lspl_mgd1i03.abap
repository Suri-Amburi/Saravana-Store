*----------------------------------------------------------------------*
***INCLUDE LSPL_MGD1I03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SMEINH-TY2TQ  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_meinh_2tq INPUT.

  IF rmmzu-okcode = fcode_mede.
    GET CURSOR LINE me_zeilen_nr.
    me_akt_zeile = me_erste_zeile + me_zeilen_nr.
    READ TABLE meinh INDEX me_akt_zeile.
    IF sy-subrc = 0 AND NOT meinh-ty2tq IS INITIAL.
      CLEAR rmmzu-okcode.
      MESSAGE s023(scm_md_r3_pi) WITH meinh-meinh.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_MEINH_2TQ  INPUT

MODULE smeinh-ty2tq INPUT.

DATA:
*     lv_tabix               TYPE sytabix
     lt_meinh               TYPE TABLE OF smeinh
     ,lv_meins               TYPE meins
     .
FIELD-SYMBOLS:
      <ls_meinh>             TYPE smeinh
     .
ENHANCEMENT-POINT EHP606_LSPL_MGD1I03_01 SPOTS ES_LSPL_MGD1I03 INCLUDE BOUND .

*Check copy of actual table
lt_meinh = meinh[].
lv_meins = mara-meins.
IF lv_meins IS INITIAL.
  READ TABLE lt_meinh INDEX 1 ASSIGNING <ls_meinh>.
  IF sy-subrc IS INITIAL.
    IF NOT <ls_meinh>-kzbme IS INITIAL.
      lv_meins = <ls_meinh>-meinh.
    ENDIF.
  ENDIF.
ENDIF.

IF lv_meins IS NOT INITIAL.
CALL FUNCTION 'EWM_MD_CHECK_MARM_TY2TQ'
  EXPORTING
    iv_matnr                     = mara-matnr
    iv_attyp                     = mara-attyp
    iv_meins                     = lv_meins
    iv_meinh                     = smeinh-meinh
    iv_ty2tq                     = smeinh-ty2tq
  CHANGING
    ct_meinh                     = lt_meinh
  EXCEPTIONS
    alternative_2tq_without_base = 01
    base_2tq_has_same_dimension  = 02
    invalid_2tq_base_unit        = 03
    invalid_2tq_alternative_unit = 04
    multiple_2tq_base_units      = 05
    disable_not_possible         = 06
    enable_not_possible          = 07
    change_not_possible          = 08
    other_error_see_message      = 09
    OTHERS                       = 99.
ENDIF.

*Reset on error
IF sy-subrc IS INITIAL.
  meinh[] = lt_meinh.
ELSE.
  bildflag = X.  "Stay on screen
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

ENDMODULE.                 " SMEINH-TY2TQ  INPUT

MODULE smeinh-ty2tq_multi INPUT.

CONSTANTS:
      lc_verflg_del           TYPE verflg VALUE 'D'
     .

DATA: lt_meinh_check          TYPE TABLE OF smeinh
     ,lv_verflg_sav           TYPE verflg
     .
ENHANCEMENT-POINT EHP606_LSPL_MGD1I03_02 SPOTS ES_LSPL_MGD1I03 INCLUDE BOUND .

lt_meinh_check = meinh[].

IF rmmzu-okcode = fcode_mede.
*----PF14-Loeschen Eintrag------------------------------------------
  GET CURSOR LINE me_zeilen_nr.
  me_akt_zeile = me_erste_zeile + me_zeilen_nr.
* A UoM will be deleted --> Mark it and save old value to be restored
  READ TABLE lt_meinh_check ASSIGNING <ls_meinh> INDEX me_akt_zeile.
  IF sy-subrc IS INITIAL.
    lv_verflg_sav     = <ls_meinh>-verflg.
    <ls_meinh>-verflg = lc_verflg_del.
  ENDIF.
ENDIF.

lv_meins = mara-meins.
IF lv_meins IS INITIAL.
  READ TABLE lt_meinh_check INDEX 1 ASSIGNING <ls_meinh>.
  IF sy-subrc IS INITIAL.
    IF NOT <ls_meinh>-kzbme IS INITIAL.
      lv_meins = <ls_meinh>-meinh.
    ENDIF.
  ENDIF.
ENDIF.

IF lv_meins IS NOT INITIAL.
CALL FUNCTION 'EWM_MD_CHECK_MARM_TY2TQ_MULTI'
  EXPORTING
    iv_matnr                     = mara-matnr
    iv_attyp                     = mara-attyp
    iv_meins                     = lv_meins
    iv_xmatnr_new                = neuflag
  CHANGING
    cv_cwqrel                    = mara-cwqrel
    cv_logunit                   = mara-logunit
    cv_cwqtolgr                  = mara-cwqtolgr
    cv_cwqproc                   = mara-cwqproc
*     only TY2TQ will be changed, no other table operations
    ct_meinh                     = lt_meinh_check
  EXCEPTIONS
    alternative_2tq_without_base = 01
    base_2tq_has_same_dimension  = 02
    invalid_2tq_base_unit        = 03
    invalid_2tq_alternative_unit = 04
    multiple_2tq_base_units      = 05
    disable_not_possible         = 06
    enable_not_possible          = 07
    change_not_possible          = 08
    other_error_see_message      = 09
    OTHERS                       = 99.
ENDIF.

*Reset on error
IF sy-subrc IS INITIAL.
  IF <ls_meinh> IS ASSIGNED.
    <ls_meinh>-verflg = lv_verflg_sav.
  ENDIF.
  meinh[] = lt_meinh_check.
ELSE.
  IF rmmzu-okcode = fcode_mede.
    CLEAR rmmzu-okcode.
  ENDIF.
  bildflag = X.  "Stay on screen
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

ENDMODULE.                 " SMEINH-TY2TQ  INPUT
