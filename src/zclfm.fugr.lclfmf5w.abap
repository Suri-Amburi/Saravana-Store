*------------------------------------------------------------------*
*        FORM OK_ABBR
*------------------------------------------------------------------*
*        Abbrechen Klassifizierung
*------------------------------------------------------------------*
form ok_abbr.

  data: l_antwort type c,
        l_exit    type c,
        l_datar   like sy-datar,
        l_subrc   type sy-subrc.

  l_exit = kreuz.
  if classif_status is initial.
*     we are in selection screen, no allocation data now.
    set screen dy000.
    leave screen.
  endif.

  if classif_status <> c_display.
*-- Abfrage, ob Änderungen irgendwo existieren
    if sy-datar is initial.
*-- Abfrage in CTMS
      call function 'CTMS_DDB_HAS_CHANGES'
           exceptions
                no_changes = 1
                changes    = 0.
      if not sy-subrc is initial.
        read table delcl index 1.
        if not sy-subrc is initial.
          read table delob index 1.
          if not sy-subrc is initial.
            loop at allkssk transporting no fields
                            where vbkz <> space.
              exit.
            endloop.
            if not sy-subrc is initial.
              loop at allausp transporting no fields
                              where statu <> space.
                exit.
              endloop.
            endif.
          endif.
        endif.
      endif.
    else.
*-- Sy-datar war gesetzt
      l_datar = kreuz.
      clear sy-subrc.
    endif.

    if sy-subrc is initial.
*-- es gab Änderungen
      if g_zuord = space.
*       aks user, if he wants to leave without saving    "begin 1022419
        call function 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
             exporting
                  titel     = text-100
                  textline1 = text-102
             importing
                  answer    = l_antwort.
*       react on user's answer
        case l_antwort.
          when ja.
*           user wants to cancel the current valuation
          when nein.
*           user doesn't want to leave the classification
            clear l_exit.
        endcase.                                           "end 1022419
      else.
*       CL-transaction
        l_antwort = ja.
        call function 'POPUP_TO_CONFIRM_STEP'
             exporting
                  titel     = text-100
                  textline1 = text-101
             importing
                  answer    = l_antwort.

        case l_antwort.
          when ja.
*       first save previous value assignment
            if l_datar is initial.
              perform close_prev_value_assmnt changing l_subrc.
              IF l_subrc <> C_BREAK.                           "1448144
               perform save_all changing l_subrc.              "1448144
              ENDIF.                                           "1448144
              if l_subrc <> 0.
                clear l_exit.
              endif.
            else.
*-- Es muss noch ganz normal verprobt werden ...
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
          when abbr.
            clear l_exit.
        endcase.
      endif.
    endif.
  endif.

  if l_exit = kreuz.
    if g_cl_ta is initial  or
       not sy-binpt is initial.
*     object transactions or BI
      set screen dy000.
      leave screen.
    else.
      export sokcode to MEMORY ID 'WWSCL24'.                   "2688521
      leave.                           " leave in call mode
      leave to transaction sy-tcode.
    endif.
  endif.

endform.                               " ok_abbr
