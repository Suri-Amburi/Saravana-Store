*&---------------------------------------------------------------------*
*&  Form  SET_EFFE_ICONS
*   Activates icon as a sign that paramter values of effectivity
*   are still in memory.
*   Only possible unless transaction is not left !
*&---------------------------------------------------------------------*
form  set_effe_icon.

  data: l_initial like sy-batch.

  call function 'ECM_PROC_MEMORY_CHECK'
       importing
            initial         = l_initial
       exceptions
            no_memory_found = 1
            others          = 2.

  if  sy-subrc = 0 and l_initial is initial.
    call function 'ICON_CREATE'
         exporting
              name                  = 'ICON_CHECKED'
         importing
              result                = g_para_set
         exceptions
              icon_not_found        = 01
              outputfield_too_short = 02.
  endif.

endform.                               " SET_EFFE_ICONS
