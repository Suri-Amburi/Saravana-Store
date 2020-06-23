*§-----------------------------------------------------------------*
*        FORM BUILD_SICHT                                          *
*------------------------------------------------------------------*
*        Abteilungssicht aus Merkmalen zusammenstellen.
*        Wenn ein einziges Merkmal keine Sicht hat, ist
*        departmental-view = space (Normalfall ohne Sichten).
*------------------------------------------------------------------*
form build_sicht tables tab structure merktab
                 using  return like syst-subrc.

  data         : i, k,
                 l_char.
  data         : l_sicht like g_sicht_akt.

  department-klart = rmclf-klart.
  clear department-sicht.
  return = 4.

  if not g_sicht_akt is initial.
    l_sicht = g_sicht_akt.
    read table tab with key abtei = space.
*   = 0: some characteristic without view -> dep.-sicht = space
    if sy-subrc > 0.
      loop at tab where abtei ne space.
        do.
          if tab-abtei(1) = space.
            exit.
          endif.
          search l_sicht for tab-abtei(1).
          if syst-subrc = 0.
            write space to l_sicht+sy-fdpos(1).
          endif.
          shift tab-abtei.
        enddo.
      endloop.
*     l_sicht now contains all views not used for any characteristic.
      if sy-subrc = 0.
        department-sicht = g_sicht_akt.
        return = 0.
        condense l_sicht no-gaps.
        i = strlen( l_sicht ).
        do i times.
          l_char = l_sicht+k(1).
          replace l_char with space into department-sicht.
          k = k + 1.
        enddo.
        condense department-sicht no-gaps.
*       dep.-sicht now contains all views used for characteristics
      endif.
    endif.
  endif.

  call function 'CTMS_DEPARTMENTALVIEW'
       exporting
            ident                    = pm_ident
            object                   = department
            defaultview              = space
       exceptions
            function_view_active     = 0
            function_view_not_active = 1.

endform.                              " build_sicht
