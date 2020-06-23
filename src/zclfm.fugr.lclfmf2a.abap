*------------------------------------------------------------------*
*        form modify_standardclass
*------------------------------------------------------------------*
* Set/reset flag standard class.
* Classification screens: 1500, 1600, 500
*------------------------------------------------------------------*
form modify_standardclass.

  data:
    l_old_tabix       type sy-tabix.

  check rmclf-class <> space.
  if rmclf-stdcl = kreuz.
*   set flag
*   allocation possibly new, no enter -> read klastab
    read table klastab index index_neu.
    if klastab-stdcl = space.
      if standardklasse = 1.
*       if flag in other allocation, delete it there
        read table klastab with key stdcl = kreuz
                           transporting no fields.
        if sy-subrc = 0.
          l_old_tabix = sy-tabix.
          message i520.
          read table klastab index l_old_tabix.
          clear klastab-stdcl.
          modify klastab index l_old_tabix.
          read table allkssk index klastab-index_tab.
          clear allkssk-stdcl.
          if allkssk-vbkz <> c_insert.
            allkssk-vbkz = c_update.
          endif.
          modify allkssk index klastab-index_tab.
*         reset work area
          read table klastab index index_neu.
        endif.
      endif.

*     set flag newly in selected allocation
      klastab-stdcl = kreuz.
      modify klastab index index_neu
                     transporting stdcl.
      read table allkssk index klastab-index_tab.
      allkssk-stdcl = kreuz.
      if allkssk-vbkz <> c_insert.
        allkssk-vbkz = c_update.
      endif.
      modify allkssk index klastab-index_tab
                     transporting stdcl vbkz.
      standardklasse = 1.
    else.
*     selected class is already standard class
      standardklasse = 1.
    endif.

  else.
*   reset flag
    if klastab-stdcl = kreuz.
      clear klastab-stdcl.
      modify klastab index index_neu transporting stdcl.
      clear allkssk-stdcl.
      if allkssk-vbkz <> c_insert.
        allkssk-vbkz = c_update.
      endif.
      modify allkssk index g_allkssk_akt_index
                     transporting stdcl vbkz.
      standardklasse = 0.
    endif.
  endif.

endform.                               " modify_standardclass
