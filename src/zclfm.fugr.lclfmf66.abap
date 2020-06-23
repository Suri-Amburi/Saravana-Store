*----------------------------------------------------------------------*
*       FORM FILL_OBJ_FROM_ALLKSSK
*----------------------------------------------------------------------*
*       "Makro" zur Übernahme einiger ALLKSSK-Felder
*----------------------------------------------------------------------*
*   Nur in CLFM_OBJECT_CL. gebraucht.
*   Return: p_subrc = 0 : allkssk hat Einträge
*                   > 0 :             keine Einträge
*----------------------------------------------------------------------*
form fill_obj_from_allkssk using p_subrc .

  refresh klastab.
  clear p_subrc.
  loop at allkssk where objek =  rmclf-objek
                    and klart =  rmclf-klart
                    and vbkz  <> c_delete.
    clear klastab.
    move-corresponding allkssk to klastab.
    klastab-index_tab = sy-tabix.
    if multi_obj = kreuz.
      inobj = allkssk-cuobj.
    endif.
    if allkssk-stdcl = kreuz.
      standardklasse = 1.
      standardclass = allkssk-class.
    endif.
    if classif_status = ein.
*-- Hinzufügen
      append klastab.
    else.
*-- Sonderlogik für Anzeige/Ändern
      if suppressd = kreuz.
        if allkssk-class = rmclf-class.
          append klastab.
          exit.
        elseif classif_status eq zwei.
*-- Gleiches Objekt auch einer anderen Klasse dergleichen KLART zugeord.
          g_obj_not_dark = kreuz.
        endif.
      else.
        append klastab.
      endif.
    endif.
  endloop.

  p_subrc = sy-subrc .

endform.                    "fill_obj_from_allkssk

*----------------------------------------------------------------------*
*  FORM FILL_EMPTY_KLASTAB
*----------------------------------------------------------------------*
*  Create empty allocation table for display.
*----------------------------------------------------------------------*
form fill_empty_klastab
     using p_multi_class.

  refresh klastab.
  clear klastab.

  perform authority_check_classify
          using    okneuz
                   space
                   space                                       "1847519
          changing g_subrc.
  if g_subrc = 0.
    if p_multi_class is initial.
      append klastab.
    else.
      do 12 times.
        append klastab.
      enddo.
    endif.
  endif.

endform.                               " fill_empty_klastab
