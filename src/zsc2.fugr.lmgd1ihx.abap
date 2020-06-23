  INCLUDE lmgd1i7p .  " mesub_help

  INCLUDE lmgd1i7h .  " MARA-PRDHA_HELP

  INCLUDE lmgd1i7g .  " MVKE-PRODH_HELP

  INCLUDE lmgd1i7f .  " MBEW-BKLAS_HELP

  INCLUDE lmgd1i7e .  " MEABM_HELP

  INCLUDE lmgd1i7d .  " MEALL_HELP

  INCLUDE lmgd1i7c .  " MEGEW_HELP

  INCLUDE lmgd1i7b .  " MEKFM_HELP


  INCLUDE lmgd1i7a .  " MARC-STRGR_HELP


  INCLUDE lmgd1i79 .  " MEVOL_HELP

  INCLUDE lmgd1i78 .  " MEZEI_HELP

  INCLUDE lmgd1i77 .  " MFHM-MGFORM_HELP

  INCLUDE lmgd1i76 .  " MFHM-EWFORM_HELP

  INCLUDE lmgd1i75 .  " MPOP-GEWGR_HELP

  INCLUDE lmgd1i74 .  " STEUER_TAXKM_HELP

  INCLUDE lmgd1i73 .  " STEUER_TAXIM_HELP

  INCLUDE lmgd1i72 .  " MARC-LFRHY_HELP


  INCLUDE lmgd1i71 .  " MARC-MRPPP_HELP


  INCLUDE lmgd1i70 .  " MARC-RDPRF_HELP


  INCLUDE lmgd1i6z .  " MARC-RWPRO_HELP


  INCLUDE lmgd1i6y .  " SMEINH-MEINH_HELP


  INCLUDE lmgd1i6x .  " MARC-EPRIO_HELP

  INCLUDE lmgd1i6w .  " DEST_VALUES

  INCLUDE lmgd1i6v .  " MARD_LWMKB_HELP

  INCLUDE lmgd1i6u .  " MARC_ABCIN_HELP

*------------------------------------------------------------------
*Module MBEW-KOSGR_HELP
*Aufruf der speziellen Eingabehilfe für Gemeinkostengruppe
*------------------------------------------------------------------
  MODULE mbew-kosgr_help.    "//br270996 neu zu 3.0f siehe Hinweis 50952
    "ch zu 4.0c nochmal eingebaut neuer H.109797
    PERFORM set_display.

    GET CURSOR FIELD feld1.

    CALL FUNCTION 'KK_F4_GKGRP_PER_BWKEY'
      EXPORTING
        p_bwkey        = rmmg1-bwkey
        display        = display
      IMPORTING
        gkgrp          = mbew-kosgr
      EXCEPTIONS
        no_entries     = 1
        internal_error = 2
        OTHERS         = 3.

  ENDMODULE.                     " MBEW-KOSGR_HELP

*------------------------------------------------------------------
*Module IPM_F4_IP_VALUE
*Call special value help in CRM system for IP
*------------------------------------------------------------------
  MODULE  ipm_f4_ip_value.

    CALL METHOD cl_ipm_erp_link_crm_ip=>get_ip_search_help
      EXPORTING
        iv_ip_id = mara-ipmipproduct
      IMPORTING
        ev_ip_id = mara-ipmipproduct.

  ENDMODULE.                    "ipm_f4_ip_value
