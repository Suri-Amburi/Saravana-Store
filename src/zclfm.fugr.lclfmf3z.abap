*----------------------------------------------------------------------*
form rmclf-atwrt_f4.

  data:
    l_display_only(1)   type c,        "flag for display
    l_dynnr             like sy-dynnr, "no. of screen
    l_repid             like sy-repid. "active program

*........ table fields on the screen ...................................

  data dynp_field_tab like dynpread occurs 1 with header line.

*....... init .........................................................*

  if tcd_stat is initial.
    clear: l_display_only.
  else.
    l_display_only = kreuz.
  endif.

*....... fill table with screen fields ................................*

  refresh dynp_field_tab.
  clear   dynp_field_tab.
  dynp_field_tab-fieldname = 'RMCLF-ATINN'.
  append dynp_field_tab.

*....... read input from screen .......................................*

  l_dynnr = sy-dynnr.
  l_repid = sy-repid.
  call function 'DYNP_VALUES_READ'
       EXPORTING
            dyname               = l_repid
            dynumb               = l_dynnr
       TABLES
            dynpfields           = dynp_field_tab
       EXCEPTIONS
            invalid_abapworkarea = 01
            invalid_dynprofield  = 02
            invalid_dynproname   = 03
            invalid_dynpronummer = 04
            invalid_request      = 05
            no_fielddescription  = 06
            undefind_error       = 07.

  read table dynp_field_tab index 1.
  rmclf-atnam = dynp_field_tab-fieldvalue.

*........ call function to display and select values ...................

  call function 'CTHE_VALUE_F4'
       EXPORTING
            i_atnam               = rmclf-atnam
            i_display_only        = l_display_only
            i_only_allowed_values = 'X'
       IMPORTING
            e_value               = rmclf-atwrt
       EXCEPTIONS
            no_selection          = 1
            charact_not_found     = 2
            no_values_found       = 3
            others                = 4.

*........ error handling ...............................................

  case sy-subrc.
    when 1.
    when 2.
      message e003(c1) with rmclf-atnam.
*    Merkmal & noch nicht vorhanden
    when 3.
      message e168(c1).
*    Kein Merkmalwert vorhanden
  endcase.

endform.                               " RMCLF-ATWRT_F4
