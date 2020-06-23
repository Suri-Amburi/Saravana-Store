*&---------------------------------------------------------------------*
*&      Form  OK_CLS_STACK
*&---------------------------------------------------------------------*
*       Calls stack of classes entered by user.
*----------------------------------------------------------------------*
form ok_cls_stack.

  data: l_exit       type sy-batch,
        l_class      type klasse_d,
        l_klart      type klassenart.

  call function 'FUNCTION_EXISTS'
    exporting
      funcname           = 'CX_PDM_SHOW_OBJECTS_FROM_STACK'
    exceptions
      function_not_exist = 1
      others             = 2.
  if sy-subrc = 0.
    call function 'CX_PDM_SHOW_OBJECTS_FROM_STACK'          "#EC EXISTS
         exporting
              p_objtyp            = c_objclass
         importing
              p_class             = l_class
              p_klart             = l_klart
         exceptions
              objekttyp_not_found = 1
              others              = 2.
  endif.
  if sy-subrc = 0  and not l_klart is initial
                   and not l_class is initial.

    if classif_status = c_display.
      l_exit = kreuz.
    else.
      perform leave_clfy changing l_exit.
    endif.
    if l_exit = kreuz.
      rmclf-clasn = l_class.
      rmclf-klart = l_klart.
      set parameter id c_param_kla field rmclf-clasn.
      set parameter id c_param_kar field rmclf-klart.
      leave to transaction sy-tcode.
    endif.
  endif.

endform.                               " ok_cls_class
