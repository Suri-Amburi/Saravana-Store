*&---------------------------------------------------------------------*
*&      Form  OK_CODE
*&---------------------------------------------------------------------*
*       Process ok codes of classification transactions.
*       ok-code forms are selected from table TCLOKCODE
*----------------------------------------------------------------------*
*       i_fcode : ok code to process
*----------------------------------------------------------------------*
form ok_code
     using    value(i_fcode)
     changing e_fcode.

  sokcode = okcode.
  clear okcode.
  if sokcode is initial.
    exit.
  else.
    clear inkonsi.
  endif.

  select single * from tclokcode
                  where progid  = c_prog_clfm
                    and fcode   = sokcode
                    and usetype = space.

  if sy-subrc is initial.
    perform (tclokcode-formname) in program saplclfm.
  endif.

  e_fcode = sokcode.

endform.                               " OK_CODE
