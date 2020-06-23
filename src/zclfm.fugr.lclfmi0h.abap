*§--------------------------------------------------------------------*
*       MODULE OK_CODE INPUT
*---------------------------------------------------------------------*
*       Abfrage der OK-Code - Eingabe
*---------------------------------------------------------------------*
* 8.4.97: Sortierung der OK-Codes nach Alphabet
*---------------------------------------------------------------------*
module ok_code.

  if suppressd = kreuz.
    if okcode is initial.
      zeile = 1.
      okcode = okausw.
    endif.
  endif.
  if syst-binpt = kreuz .
    if okcode is initial.
      zeile = 1.
      okcode = okausw.
    endif.
  endif.
  sokcode = okcode.
  clear okcode.
  if not sokcode is initial.
    clear inkonsi.
  endif.
*-- zunächst die Leerzeilen entfernen
  delete klastab where objek is initial.
  check not sokcode is initial.
*-- Ansteuerung OK-Code-FORM über TCLOKCODE
  select single * from tclokcode
    where progid  = 'SAPLCLFM'
     and  fcode   = sokcode
     and  usetype = c_batch.

  if sy-subrc is initial.
    perform (tclokcode-formname) in program saplclfm .
    exit.
  else.
* >>> Retail Cloud Enablement
    if sy-dynnr = dy520  and ( sokcode = okleav or sokcode = okabbr ).
      try.
          if gr_badi is not bound.
            get badi gr_badi.
          endif.
          if gr_badi is bound.
            call badi gr_badi->is_cloud
              receiving
                rv_is_cloud = gv_s4h_is_cloud.
          endif.
        catch cx_badi_not_implemented
          cx_badi_multiply_implemented
          cx_sy_dyn_call_illegal_method
          cx_badi_unknown_error.
      endtry.
      if gv_s4h_is_cloud = abap_true.
        select single * from tclokcode
          where progid  = 'SAPLCLFM'
           and  fcode   = sokcode
           and  usetype = ''.
        if sy-subrc is initial.
          perform (tclokcode-formname) in program saplclfm .
          exit.
        else.
          message w100.
          set screen sy-dynnr.
          leave screen.
        endif.
      endif.
    endif.
* <<< Retail Cloud Enablement
  endif.

endmodule.
