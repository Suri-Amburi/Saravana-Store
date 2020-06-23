*&---------------------------------------------------------------------*
*& Report ZHSN_TAX_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhsn_tax_report.
TABLES : marc.
SELECT-OPTIONS : s_matnr FOR marc-matnr.
SELECT-OPTIONS : s_steuc FOR marc-steuc.
PARAMETERS     : p_pur   RADIOBUTTON GROUP g1,
                 p_sales RADIOBUTTON GROUP g1.

IF p_sales IS NOT INITIAL.
  SELECT DISTINCT marc~matnr , marc~steuc, konp~mwsk1
    INTO TABLE @DATA(lt_hsn) FROM
    marc AS marc
    INNER JOIN a519 AS a519 ON marc~steuc = a519~steuc
    INNER JOIN konp AS konp ON a519~knumh = konp~knumh
    WHERE marc~matnr IN @s_matnr AND marc~steuc IN @s_steuc
    AND a519~datab LE @sy-datum AND a519~datbi GE @sy-datum AND konp~loevm_ko = @space.
ELSEIF p_pur IS NOT INITIAL.
  SELECT DISTINCT marc~matnr , marc~steuc, konp~mwsk1
    INTO TABLE @lt_hsn FROM
    marc AS marc
    INNER JOIN a792 AS a792 ON marc~steuc = a792~steuc
    INNER JOIN konp AS konp ON a792~knumh = konp~knumh
    WHERE marc~matnr IN @s_matnr AND marc~steuc IN @s_steuc
    AND a792~datab LE @sy-datum AND a792~datbi GE @sy-datum AND konp~loevm_ko = @space.
ENDIF.


CHECK lt_hsn IS NOT INITIAL.
*** FIELD CATLOG
DATA:
  ls_layout   TYPE slis_layout_alv,
  lt_fieldcat TYPE slis_t_fieldcat_alv,
  gs_fieldcat TYPE slis_fieldcat_alv,
  wvari       TYPE disvariant.

ls_layout-zebra       = abap_true.
ls_layout-colwidth_optimize  = abap_true.

APPEND VALUE #( fieldname = 'MATNR' seltext_m = 'Material' outputlen = 20 ) TO lt_fieldcat.
APPEND VALUE #( fieldname = 'STEUC' seltext_m = 'HSN'      outputlen = 10 ) TO lt_fieldcat.
APPEND VALUE #( fieldname = 'MWSK1' seltext_m = 'Tax Code' outputlen = 3  ) TO lt_fieldcat.

**** Dispalying ALV Report
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid         " Name of the calling program
    is_layout          = ls_layout        " List layout specifications
    it_fieldcat        = lt_fieldcat      " Field catalog with field descriptions
    i_default          = 'X'              " Initial variant active/inactive logic
    i_save             = 'A'              " Variants can be saved
  TABLES
    t_outtab           = lt_hsn         " Table with data to be displayed
  EXCEPTIONS
    program_error      = 1                " Program errors
    OTHERS             = 2.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
