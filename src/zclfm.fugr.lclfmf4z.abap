*&---------------------------------------------------------------------*
*&      Form  ok_OBWE
*&---------------------------------------------------------------------*
*       Only CL20:
*       change object type in selection screen
*       for class types with multiple objects (multobj=x)
*----------------------------------------------------------------------*
form ok_obwe.

  data: l_exit   type sy-batch,
        l_klart  type rmclf-klart.

  if multi_obj is initial.
*   'classtype & has exactly one object type: '&'.
    message s179 with rmclf-klart tcltt-obtxt.
    exit.
  endif.

  if classif_status = c_display.
    l_exit = kreuz.
  else.
    perform leave_clfy changing l_exit.
  endif.

  if l_exit = kreuz.

    call function 'CLCA_PROCESS_CLASSTYPE'
         exporting
              classtype          = rmclf-klart
              mode               = zwei" only cl20
              fromcl20           = kreuz       " only cl20
              dynpros            = kreuz
              objects_only       = kreuz
              obj_only_classtype = kreuz
         importing
              classtype          = l_klart
*             typetext           = rmclf-artxt
*             multi_classif      = multi_class
              mult_obj           = multi_obj
              table              = sobtab
              ptable             = pobtab
*             imptcla            = tcla
         exceptions
              no_auth_klart      = 02.
    if not pobtab is initial.
      sobtab = pobtab.
    endif.
    set parameter id c_param_klt field sobtab.
    leave to transaction sy-tcode.
  endif.

endform.                               " ok_OBWE
