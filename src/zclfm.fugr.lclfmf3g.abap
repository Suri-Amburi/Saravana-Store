*&---------------------------------------------------------------------*
*&      Form  CHECK_ALL_CHANGES
*&---------------------------------------------------------------------*
*       Checks whether any changes were done that are to be
*       saved in DB.
*       return: p-subrc = 0 : no changes, empty tables
*                       = 1 : no changes, at least 1 entry in any table
*                       = 4 : changes done
*----------------------------------------------------------------------*
form check_all_changes changing p_subrc.

  data: l_save type sy-subrc.

  l_save = 0.
  read table allkssk index 1.
  if sy-subrc = 0.
    l_save = 1.
  endif.

  if l_save > 0.
    loop at allausp where statu <> space.
      l_save = 4.
      exit.
    endloop.
    if l_save < 4.
      loop at allkssk where vbkz <> space .
*       Änderungen in Zuordnungen vorhanden.
        l_save = 4.
        exit.
      endloop.
      if l_save < 4.
        read table klastab with key statuaen = kreuz.
        if sy-subrc = 0.
*         Änderungen in Status vorhanden.
          l_save = 4.
        endif.
      endif.
    endif.
  endif.

  p_subrc = l_save.

endform.                               " CHECK_ALL_CHANGES
