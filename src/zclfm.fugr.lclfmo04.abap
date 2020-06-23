*---------------------------------------------------------------------*
*       MODULE rebuild_obj_indx OUTPUT                                 *
*---------------------------------------------------------------------*
*       Aufbau g_obj_indx_tab
*---------------------------------------------------------------------*
module rebuild_obj_indx output.
  check not sokcode is initial.
  check not sokcode = okfilt.
  describe table klastab lines x2.
  describe table g_obj_indx_tab lines syst-tfill.
  if x2 ne syst-tfill.
    perform rebuild_obji.
  else.
    if sokcode = okloes.
      perform rebuild_obji.
    endif.
  endif.
endmodule.
