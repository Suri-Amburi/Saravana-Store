*---------------------------------------------------------------------*
*       FORM SEND_CHANGE_DYNPRO                                       *
*---------------------------------------------------------------------*
*       Pop-UP Änderungsnummer                                        *
*---------------------------------------------------------------------*
form send_change_dynpro
     using  return like syst-subrc.


  clear g_display_values.
  return = 0.
  read table allkssk index 1 transporting no fields.
  if sy-subrc = 0.
*   allocations already read:
*   changing date or change number not allowed
    if classif_status <> c_display.
      clear rmclf-datuv1.                                       "872017
      message w562.
      g_display_values = kreuz.
    endif.

  else.
*   no data read, popup for change number
    call screen dy600
         starting at   5 5
         ending   at  45 10.
    if sokcode = okabbr.
      return = 1.
      clear rmclf-aennr1.
    else.
      return = 0.
      if rmclf-aennr1 is initial.
        if classif_status <> c_display.
          clear rmclf-datuv1.
          message w562.
        endif.
      endif.
    endif.
  endif.

endform.                               " send_change_dynpro
