*&---------------------------------------------------------------------*
*       Module  CHECK_AENNR_SEL  INPUT
*----------------------------------------------------------------------*
*       CL20/22/24N.
*       Prüfe Änderungsnummer aus Selektionsfeld:
*       Existenz, Datum übernehmen, ...
*----------------------------------------------------------------------*
module check_aennr_sel input.

  check g_sel_changed <> space.
  perform check_aennrf_sel using cl_status.

  check not change_subsc_act is initial.
  check rmclf-aennr1 is initial.
* ECM active, change number not supplied:
* check if object already maintained with change number

  if g_zuord <> c_zuord_4.
    if cl_status = c_change.
      if g_zuord = 2.
        refresh iklah.
        iklah-klart = rmclf-klart.
        iklah-class = rmclf-clasn.
        append iklah.
        call function 'CLSE_SELECT_KLAH'
             tables
                  imp_exp_klah   = iklah
             exceptions
                  no_entry_found = 01.
        read table iklah index 1.
        kssk-objek = klah-clint.
        g_flag2    = mafidk.
      else.
        kssk-objek = rmclf-objek.
        g_flag2    = mafido.
      endif.
      perform check_kssk_count
              using kssk-objek
                    rmclf-klart
                    g_flag2
                    sobtab
                    inobj              " formal parm.
                    g_subrc.
      if g_subrc > 0.
*       'change number necessary'
        message e562.
      endif.
    endif.
  endif.

endmodule.                             " check_aennr_sel
