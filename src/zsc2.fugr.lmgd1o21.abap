*----------------------------------------------------------------------*
***INCLUDE LMGD1O21.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  DPP_MARA_KUNNR  OUTPUT
*&---------------------------------------------------------------------*
*       This module checks if the competitor is blocked. If it is
*       blocked and the user doesn't have auditor authorization, the
*       competitor is initialized. Auditor will receive a warning
*       message.
*----------------------------------------------------------------------*
MODULE dpp_mara_kunnr OUTPUT.

** start_EoP_adaptation
** Read back internal guideline note 1998910 before starting delivering a correction
  IF NOT cl_vs_switch_check=>cmd_vmd_cvp_ilm_sfw_01( ) IS INITIAL AND
     NOT mara-kunnr                                    IS INITIAL.
    INCLUDE erp_cvp_mm_i3_c_trx0002 IF FOUND.
  ENDIF.
** end_EoP_adaptation

ENDMODULE.
