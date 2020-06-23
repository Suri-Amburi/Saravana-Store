*&---------------------------------------------------------------------*
*&      Form  OK_AL_SIZE
*&---------------------------------------------------------------------*
*       Switch size of allocation table control.
*----------------------------------------------------------------------*
form ok_al_size.

  if g_alloc_dynlg = space.
    g_alloc_dynlg = kreuz.
  else.
    g_alloc_dynlg = space.
  endif.

  if g_zuord = c_zuord_0  or
     g_zuord = c_zuord_2  or
     g_zuord = space.

    if g_alloc_dynnr = dynp1500.
      g_alloc_dynnr = dynp1600.
    else.
      g_alloc_dynnr = dynp1500.
    endif.

  elseif g_zuord = c_zuord_4.

    case g_alloc_dynnr.
      when dynp1511.
        g_alloc_dynnr = dynp1611.
      when dynp1611.
        g_alloc_dynnr = dynp1511.

      when dynp1510.
        g_alloc_dynnr = dynp1610.
      when dynp1610.
        g_alloc_dynnr = dynp1510.

      when dynp1512.
        g_alloc_dynnr = dynp1612.
      when dynp1612.
        g_alloc_dynnr = dynp1512.
    endcase.
  endif.

endform.                               " ok_al_size
