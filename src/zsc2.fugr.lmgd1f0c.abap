*----------------------------------------------------------------------*
*               PRDAT_ERMITTELN
*
* Ermittlung eines Default-Prognosedatums, falls Prognosewerte gepflegt
* wurden und MPOP-PRDAT aber noch initial ist.
*                           (neu zu 2.1D / K11K067178 / 17.01.94 / CH)
*mk/12.04.95: ret_prdat ersetzt durch *mpop-prdat, da DB-Stand benötigt
*----------------------------------------------------------------------*
FORM prdat_ermitteln.

  CHECK t130m-aktyp NE aktypa AND t130m-aktyp NE aktypz.
  IF ( *mpop-prdat IS INITIAL ) AND  ( NOT rmmg2-flgprogw IS INITIAL ).
    CLEAR flag4.
    LOOP AT tprowf.
      IF ( NOT tprowf-prwrt IS INITIAL ) OR
         ( NOT tprowf-koprw IS INITIAL ).
        flag4 = x.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF flag4 = x.
      READ TABLE tprowf INDEX 1.
      mpop-prdat = tprowf-ertag.
    ENDIF.
  ENDIF.

ENDFORM.                    "PRDAT_ERMITTELN

*&---------------------------------------------------------------------*
*&      Form  ipm_read_ip_data
*&---------------------------------------------------------------------*
* Check that IP exists in CRM system
*----------------------------------------------------------------------*
FORM ipm_read_ip_data USING iv_ip_id TYPE crm_product_id_ip.

  IF iv_ip_id IS NOT INITIAL.
    CALL METHOD cl_ipm_erp_link_crm_ip=>get_ip_with_id
      EXPORTING
        iv_ip_id           = iv_ip_id
      EXCEPTIONS
        comm_failure       = 1
        sys_failure        = 2
        product_not_unique = 3.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE i004(ipm_crm).
      WHEN 2.
        MESSAGE i004(ipm_crm).
      WHEN 3.
        MESSAGE e003(ipm_crm) WITH iv_ip_id.
    ENDCASE.
  ENDIF.

ENDFORM.                    "ipm_read_ip_data
