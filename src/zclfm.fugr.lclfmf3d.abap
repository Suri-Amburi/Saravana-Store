*&---------------------------------------------------------------------*
*&      Form  LEAVE_CLFY
*&---------------------------------------------------------------------*
*       Checks whether saving is necessary.
*       Popup with question how to leave.
*----------------------------------------------------------------------*
*       P_EXIT:  'X' exit allowed
*                ' ' exit not allowed
*----------------------------------------------------------------------*
form leave_clfy
     changing  p_exit like sy-batch.

  data: l_antwort type c,
        l_exit    type c,
        l_subrc   type sy-subrc.


  l_exit = kreuz.

* first save previous value assignment
  perform close_prev_value_assmnt changing l_subrc.
  if l_subrc = c_break.
    clear l_exit.
    g_subrc = 0.
  endif.

* Prüfen, ob irgendwelche Änderungen zu sichern sind.
  perform check_all_changes changing g_subrc.

  if g_zuord = space.
*   Objekt-TA: Bestätigungs-Popup wird dort generiert
    if g_subrc > 1.
      perform save_all changing l_subrc.
      if l_subrc <> 0.
        clear l_exit.
      endif.
    endif.

  else.
    if g_subrc = 1.
*     'no changes done'.
      message s524.
    endif.
    if g_subrc > 1  or  sy-tcode = tcodeclw1.
      call function 'POPUP_TO_CONFIRM_STEP'
           exporting
                titel     = text-100
                textline1 = text-101
           importing
                answer    = l_antwort.
      case l_antwort.
        when ja.
          perform save_all changing l_subrc.
          if l_subrc <> 0.
            clear l_exit.
          endif.
        when nein.
          if syst-calld = kreuz.
            if g_cl_ta = kreuz.
              export space to memory id tcodecl22.
              leave.
            endif.
          endif.
          message s524.
*         perform beenden_ohne.
        when abbr.
          clear l_exit.
      endcase.
    endif.

  endif.

  p_exit = l_exit.

endform.                               " LEAVE_CLFY
