*&---------------------------------------------------------------------*
*&      Module  SET_INDEX_NEU  INPUT
*&---------------------------------------------------------------------*
*       Determine current indices for tables
*       klastab, allkssk.
*       Processed in loop: do nor delete global flags as mafid !
*----------------------------------------------------------------------*
module set_index_neu input.

* clear mafid.
  index_neu           = tc_obj_class-current_line.
  zeile               = index_neu .
  g_klastab_akt_index = index_neu.

*-- Nachlesen aktuelle Workareas
  if g_zuord <> c_zuord_4 or
     not g_obj_scr is initial.
*-- ... CL20/22 oder Objektzuordnungsscreen CL24
    read table klastab into klastab index index_neu.
  else.
    read table g_obj_indx_tab index index_neu .
    read table klastab into klastab index g_obj_indx_tab-index.
    g_klastab_akt_index = g_obj_indx_tab-index.
  endif.

  if klastab-index_tab is initial.
    clear allkssk.
    clear g_allkssk_found.
    clear g_allkssk_akt_index.
  else.
    read table allkssk  index klastab-index_tab.
    if not sy-subrc is initial.
      message e001 with 'set_index_neu'
                        klastab-objek klastab-index_tab.
    endif.
*   mafid = allkssk-mafid.
    g_allkssk_found = kreuz.
    g_allkssk_akt_index = sy-tabix.
  endif.

*-- MAFID ggf. noch festlegen
  if mafid is initial.
    case g_zuord.
      when c_zuord_2.
        mafid = mafidk.
      when c_zuord_4.
        if g_obj_scr is initial.
          mafid = mafidk.
        else.
          mafid = mafido.
        endif.
      when others.
        mafid = mafido.
    endcase.
  endif.

endmodule.                             " SET_INDEX_NEU  INPUT
