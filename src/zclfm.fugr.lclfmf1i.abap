*---------------------------------------------------------------------*
* Prüfen, ob sich die Einheit zur Klasse und die Basiseinheiten der   *
* Materialien der Klasse auf die gleiche Dimension beziehen           *
*---------------------------------------------------------------------*
form unit_check using matnr   like rmclf-matnr
                      meins   like klah-meins
                      return  like syst-subrc.

*
  clear return.
  check not matnr is initial.

* check with material master
  call function 'FUNCTION_EXISTS'
    exporting
      funcname           = 'CLEX1_CHECK_UNIT_IN_MARA'
    exceptions
      function_not_exist = 1
      others             = 2.
  if sy-subrc = 0.
    call function 'CLEX1_CHECK_UNIT_IN_MARA'      "#EC EXISTS
      exporting
        i_matnr                  = matnr
        i_unit                   = meins
      exceptions
        material_not_found       = 1
        dimensions_are_different = 2
        unit_in_not_found        = 3
        unit_out_not_found       = 4
        others                   = 5.

    if sy-subrc > 0.
*     check with MARC

      call function 'FUNCTION_EXISTS'
        exporting
          funcname           = 'CLEX1_CHECK_UNIT_IN_MARC'
        exceptions
          function_not_exist = 1
          others             = 2.
      if sy-subrc = 0.
        call function 'CLEX1_CHECK_UNIT_IN_MARC'    "#EC EXISTS
          exporting
            p_matnr    = matnr
            p_meins    = meins
          exceptions
            unit_error = 1.
        if sy-subrc > 0.
          return = 1.
        endif.
      endif.

    endif.
  endif.

endform.                               " unit_check
