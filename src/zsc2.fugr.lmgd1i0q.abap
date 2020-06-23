*-----------------------------------------------------------------------
*  Module MARA-KUNNR
*  Prüfung des Wettbewerbers gegen den Kundenstamm. Das Kennzeichen
*  'Debitor ist Wettbewerber' muß gesetzt sein
*-----------------------------------------------------------------------
MODULE MARA-KUNNR.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARA_KUNNR'
       EXPORTING
            P_MARA_KUNNR = MARA-KUNNR
       EXCEPTIONS
            OTHERS  = 0.

** start_EoP_adaptation
** Read back internal guideline note 1998910 before starting delivering a correction
  IF NOT cl_vs_switch_check=>cmd_vmd_cvp_ilm_sfw_01( ) IS INITIAL.
    IF NOT mara-kunnr IS INITIAL     AND
           mara-kunnr NE lmara-kunnr.
      INCLUDE erp_cvp_mm_i3_c_trx0005 IF FOUND.
    ENDIF.
  ENDIF.
** end_EoP_adaptation

ENDMODULE.
