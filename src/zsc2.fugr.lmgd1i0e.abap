*&---------------------------------------------------------------------*
*&      Module  MARA_BMATN  INPUT               MK/4.0A Neu
*&---------------------------------------------------------------------*
* Prüfung der internen Materialnummer zum Herstellerteil
*----------------------------------------------------------------------*
MODULE mara_bmatn INPUT.
  CHECK bildflag = space.
  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.

  CALL FUNCTION 'MARA_BMATN'
    EXPORTING
      p_bmatn = mara-bmatn.

ENDMODULE.                             " MARA_BMATN  INPUT

* note 581171
*&---------------------------------------------------------------------*
*&      Module  MARA_MFRNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mara_mfrnr INPUT.

  DATA h_lfa1 LIKE lfa1.

  CHECK bildflag = space.
  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  CHECK mara-mfrnr NE lmara-mfrnr AND NOT mara-mfrnr IS INITIAL.

  CALL FUNCTION 'WY_LFA1_SINGLE_READ'
    EXPORTING
      pi_lifnr = mara-mfrnr
    IMPORTING
      po_lfa1  = h_lfa1
    EXCEPTIONS
      OTHERS   = 1.
** start_EoP_adaptation
** Read back internal guideline note 1998910 before starting delivering a correction
  IF NOT cl_vs_switch_check=>cmd_vmd_cvp_ilm_sfw_01( ) IS INITIAL AND
     NOT h_lfa1-cvp_xblck IS INITIAL.
    INCLUDE erp_cvp_mm_i3_c_trx0014 IF FOUND.
  ENDIF.
** end_EoP_adaptation
  IF NOT h_lfa1-loevm IS INITIAL.
*note 1473414
    CALL FUNCTION 'ME_CHECK_T160M'
      EXPORTING
        i_arbgb = 'ME'
        i_msgnr = '024'
        i_msgvs = '00'          " Messagevariante default '00'
      EXCEPTIONS
        nothing = 00
        warning = 01
        error   = 02.

    CASE sy-subrc.
      WHEN 1.
        MESSAGE w024(me) WITH mara-mfrnr.
      WHEN 2.
        MESSAGE e024(me) WITH mara-mfrnr.
    ENDCASE.


  ENDIF.




ENDMODULE.                 " MARA_MFRNR  INPUT
