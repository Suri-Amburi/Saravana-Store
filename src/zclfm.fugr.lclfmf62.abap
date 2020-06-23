*----------------------------------------------------------------------*
*   form select_classtype_to_copy
*
*   Options:
*   i_ref_all_types = ' ' : imported class type
*                   = X   : all class types for table
*                   = V   : all variant class types for table
*
*   range RKLART: class types with multobj = ' '.
*   range XKLART: class types with multobj = 'X'.
*----------------------------------------------------------------------*
form ref_classtypes
     using    value(i_ref_all_type)
              value(i_ptable)
     changing e_classtype
              e_exit
              e_chg_no.

  clear e_exit.
  refresh rklart.
  rklart-sign   = incl.
  rklart-option = equal.
  refresh xklart.
  xklart-sign   = incl.
  xklart-option = equal.

  if not i_ptable is initial.
*   table iklart has already class types for table,
*   add class types for ptable !
    call function 'CLCA_GET_CLASSTYPES_FROM_TABLE'
         exporting
              spras              = g_language
              table              = i_ptable
              with_text          = space
         tables
              iklart             = iklart
         exceptions
              no_classtype_found = 01.
  endif.

  if i_ref_all_type is initial.
*  1. take imported class type
    if e_classtype is initial.
      get parameter id c_param_kar field e_classtype.
    endif.
    if e_classtype is initial.
      read table iklart with key stand    = kreuz
                                 intklart = space.
    else.
      read table iklart with key klart    = e_classtype
                                 intklart = space.
    endif.

    if sy-subrc = 0.
*     just fill tcla structure
      select single * from tcla
                      where klart = e_classtype.
      authority-check object 'C_TCLA_BKA'
                      id 'KLART' field iklart-klart.
      if sy-subrc = 0.
        if iklart-multobj = space.
          rklart-low = iklart-klart.
          append rklart.
        else.
          xklart-low = iklart-klart.
          append xklart.
        endif.
        if iklart-aediezuord = kreuz.
*         change management activated for any class type
          e_chg_no = kreuz.
        endif.
        e_classtype = iklart-klart.
        set parameter id c_param_kar field e_classtype.
      endif.
    endif.

  else.
*   2. get all class types of imported table (object type)
    loop at iklart where intklart is initial.
      authority-check object 'C_TCLA_BKA'
                      id 'KLART' field iklart-klart.
      if sy-subrc = 0.
        if i_ref_all_type = 'V' and
           iklart-varklart = space.
*         take only variant class types
        else.
          if iklart-multobj = space.
            rklart-low = iklart-klart.
            append rklart.
          else.
            xklart-low = iklart-klart.
            append xklart.
          endif.
          if iklart-aediezuord = kreuz.
*           change management activated for any class type
            e_chg_no = kreuz.
          endif.
          if iklart-stand = kreuz.
*           get standard class type
            e_classtype = iklart-klart.
            set parameter id c_param_kar field e_classtype.
          endif.
        endif.
      endif.
    endloop.
  endif.

  if rklart[] is initial.
    if xklart[] is initial.
      if iklart[] is initial.
        message s522.
      else.
        message s546.
      endif.
      e_exit = kreuz.
    endif.
  endif.

endform.                               "  ref_classtypes
