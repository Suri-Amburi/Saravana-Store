*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_CLASS
*       get class name in selected line
*&---------------------------------------------------------------------*
*      -->  L_ENTRIES_NEW   list with new entries yes/no
*      -->  L_ZUORD         which transaction/dynpro
*      -->  L_ZEILE         selected line in list
*      -->  L_ZEILE         index in list
*      <--  l_class         name of selected class
*----------------------------------------------------------------------*
form get_selected_class
     using    value(l_zuord)
              value(l_zeile)
              value(l_index)
     changing l_class        like klah-class.

  clear l_class.
  l_zeile = l_zeile + l_index - 1.

  if l_zuord = c_zuord_4.
    read table g_obj_indx_tab index l_zeile.
    read table klastab  index g_obj_indx_tab-index.
  else.
    read table klastab index l_zeile.
  endif.
  check sy-subrc = 0.
  if g_zuord = c_zuord_4.
    if klastab-mafid = mafido.
      exit.
    endif.
  endif.
  l_class = klastab-objek.

endform.                               " GET_SELECTED_CLASS
