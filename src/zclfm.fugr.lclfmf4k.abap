*&---------------------------------------------------------------------*
*&      Form  ok_view
*&---------------------------------------------------------------------*
*       Change view of characteristics.
*       Popup processed by CTMS,
*       displayed if value ass. subscreen is open.
*----------------------------------------------------------------------*
form ok_view.

  data: l_sicht   like  klah-sicht.

  check g_val-class <> space.

  if g_zuord = c_zuord_4.
    clear iklah.
    refresh iklah.
    iklah-klart = rmclf-klart.
    iklah-class = pm_class.
    append iklah.
    call function 'CLSE_SELECT_KLAH'
         TABLES
             IMP_EXP_KLAH   = iklah
         EXCEPTIONS
             NO_ENTRY_FOUND = 1
             OTHERS         = 2.
    l_sicht = iklah-sicht.
  else.
    read table allkssk with key class = g_val-class.
    l_sicht = allkssk-sicht.
  endif.
              .
  if l_sicht = space.
*   do not process okcode for char. assignment screen
*   'no views available'.
    message s204.
    clear sokcode.
  endif.

endform.                               " ok_view
