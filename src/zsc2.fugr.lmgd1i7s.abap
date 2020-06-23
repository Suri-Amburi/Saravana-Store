*----------------------------------------------------------------------*
*   INCLUDE LMGD1I7S                                                   *
*----------------------------------------------------------------------*
*RWA 6.7.99
* Neues PBO-Module, um zum Lagerplatz den Kommisionierbereich zu lesen
* Hinweis 160914
MODULE mlgt_kober_lesen OUTPUT.
  DATA hlagp LIKE lagp.
  CHECK NOT mlgt-lgpla IS INITIAL.
  CALL FUNCTION 'LAGP_SINGLE_READ'
    EXPORTING
      lagp_lgnum = mlgt-lgnum
      lagp_lgtyp = mlgt-lgtyp
      lagp_lgpla = mlgt-lgpla
    IMPORTING
      wlagp      = hlagp
    EXCEPTIONS
      not_found  = 1.

  IF sy-subrc EQ 0.
    mlgt-kober = hlagp-kober.
  ELSE.
    CLEAR mlgt-kober.
  ENDIF.

ENDMODULE.                 " MLGT_KOBER_LESEN  OUTPUT
*----------------------------------------------------------------------*
*  MODULE ipm_read_ip_data_pai
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE ipm_read_ip_data_pai INPUT.
  PERFORM ipm_read_ip_data USING mara-ipmipproduct.
ENDMODULE.                    "ipm_read_ip_data_pai
