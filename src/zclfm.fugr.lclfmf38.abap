*&---------------------------------------------------------------------*
*&      Form  SETUP_KLASTAB_INDEX
*&---------------------------------------------------------------------*
*       Sets up table G_OBJ_INDX_TAB for the first time.
*       Index table allkssk / klastab.
*----------------------------------------------------------------------*
form setup_klastab_index
     using value(p_multi_obj).

  data: l_tabix like sy-tabix.

  refresh g_obj_indx_tab.
  describe table klastab lines sy-tfill.
  if sy-tfill > 0.
    if p_multi_obj = kreuz.
*     still sorted by cuobj-value, done in CLSE !
      sort allkssk by objek obtab.
      sort klastab by objek obtab.
    endif.

    loop at klastab assigning <gf_klas>.
      l_tabix = sy-tabix.
      <gf_klas>-index_tab = l_tabix.
      modify klastab from <gf_klas> index l_tabix.

      read table redun with key <gf_klas>-obtab binary search.
      if redun-showo = kreuz.
        g_obj_indx_tab-showo = kreuz.
      else.
        clear g_obj_indx_tab-showo.
      endif.
      g_obj_indx_tab-index = l_tabix.
      append g_obj_indx_tab.
    endloop.
  endif.

endform.                               " SETUP_KLASTAB_INDEX
