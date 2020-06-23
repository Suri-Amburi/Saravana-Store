*---------------------------------------------------------------------*
*       MODULE CHECK_KLART INPUT                                      *
*---------------------------------------------------------------------*
*       Berechtigungsprüfung für Klassenart                           *
*       Wird prozessiert, wenn Existenzprüfung schon gelaufen.
*       Selektion Objekttyp findet hier nicht mehr statt !
*---------------------------------------------------------------------*
module check_klart.

  check not g_sel_changed is initial.

  call function 'CLCA_PROCESS_CLASSTYPE'
       exporting
            classtype          = rmclf-klart
            table              = sobtab
*           dynpros            = kreuz
*           objects_only       = kreuz
*           obj_only_classtype = kreuz
            multi_classif      = multi_class
            mode               = g_modus
            fromcl20           = fromcl20
       importing
            classtype          = rmclf-klart
            typetext           = rmclf-artxt
            multi_classif      = multi_class
            mult_obj           = multi_obj
            table              = sobtab
            ptable             = pobtab
            no_cl_trans        = no_class
            imptcla            = tcla
       exceptions
            no_auth_klart      = 02.

if sy-subrc = 2.                                 "begin_ note 1292623
* keine Berechtigung für Klassenart / no authorization for class type
   message e545 with rmclf-klart.
endif.                                           "end_note 1292623

  if g_zuord = c_zuord_2.
    if tcla-hierarchie is initial.
      message w571 with rmclf-klart.
      leave screen.
    endif.
  endif.

  if not sobtab is initial.
    if not pobtab is initial.
*-- POBTAB contains the selected object type
      sobtab = pobtab.
    endif.
    set parameter id c_param_klt field sobtab.
  endif.

endmodule.
