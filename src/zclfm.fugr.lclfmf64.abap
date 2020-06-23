*----------------------------------------------------------------------*
*       FORM OLD_CLASS_HANDLING
*----------------------------------------------------------------------*
*       Handelt das Löschen einer Klasse beim Ändern
*----------------------------------------------------------------------*
form old_class_handling using value(i_entry_allkssk)
                              value(i_class)
                              value(i_old_class)
                        changing   e_stdclflg
                                   e_text.
  data: l_stdflag(1).
  if i_old_class is initial.
*-- ... keine Klassenzuordnung ist zu löschen
    if multi_class = kreuz.
      perform build_all_tabs using i_class
                                   l_stdflag e_text.
      standardklasse = 1.
    else.
*-- Es darf aber keine Mehrfachklassifizierung geben !!!!
      raise no_multi_classif.
    endif.
  else.
*-- Es soll eine der Zuordnungen gelöscht werden
    perform loeschen_dunkel using i_old_class e_stdclflg.
    if i_old_class eq i_class.
      okcode = okweit.
    else.
      perform build_all_tabs using i_class
                                   e_stdclflg e_text.
      standardklasse = 1.
    endif.
  endif.
endform.
