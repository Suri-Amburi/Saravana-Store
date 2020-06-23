*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Nur Hauptdynpros Klassifizierung !
*       Dynpro-Feld-Modifikation
*
*       Status: - nicht anzeigen für Variantenklassenarten
*               - nur offen, wenn Bewertungssubscreen Daten
*                 zum selben Objekt enthält.
*----------------------------------------------------------------------*
form modify_screen.

  data: l_cols        type cxtab_column.

  data: l_inob_init like inob-cuobj,                           "1772310
        l_chgNr_Ok  like syst-subrc,                           "1772310
        l_save_objek  like kssk-objek.                         "1772310
  data: l_tcd_stat like tcd_stat,                              "1878179
        l_subrc like sy-subrc.                                 "1878179

  case g_zuord.

    when c_zuord_0 or
         c_zuord_2 or
         space.

      if tcla-varklart <> space and
         g_zuord = space.

*       variant class types (e.g. 300): do not display status

        loop at tc_obj_class-cols into l_cols
             where screen-name = 'RMCLF-STATU'
                or screen-name = 'RMCLF-ICON'.
          l_cols-invisible = 1.
          modify tc_obj_class-cols from l_cols.
        endloop.

        loop at screen.
          if screen-group1  = c_io_field.
            if screen-name = 'RMCLF-STATU'.

            elseif classif_status = c_display  or
                   classif_status = space.
*             Auf Anzeige stellen
              screen-input     = '0'.
              screen-output    = '1'.
              screen-invisible = '0'.
              modify screen.
            endif.
          elseif screen-group1  = c_key.
            if ( classif_status = c_display or
                 klastab-index_tab > 0 ).
*             Auf Anzeige stellen
              screen-input     = '0'.
              screen-output    = '1'.
              screen-invisible = '0'.
              modify screen.
            endif.
          endif.
        endloop.

      else.
*       normal case
        loop at screen.
          if ( screen-group1  = c_io_field  and
               (
                 ( classif_status = c_display or
                   classif_status = space )
                 or
                 ( screen-name = 'RMCLF-STATU' and
                   g_klastab_val_idx > 0       and
                   tc_obj_class-current_line <> g_klastab_val_idx )
               )
             ) or
             screen-group1  = c_key.
*           Auf Anzeige stellen
            screen-input     = '0'.
            screen-output    = '1'.
            screen-invisible = '0'.
            modify screen.
          endif.
        endloop.
      endif.

    clear l_subrc.                                       "Begin 1878179
    l_tcd_stat = tcd_stat.
    clear   iklah.
    refresh iklah.

    iklah-klart = rmclf-klart.
    iklah-class = rmclf-class.

    append iklah.

    call function 'CLSE_SELECT_KLAH'
         tables
              imp_exp_klah   = iklah
         exceptions
              no_entry_found = 1
              others         = 2.

    read table iklah index 1.
    check sy-subrc is initial.
    call function 'CLMA_AUTHORITY_CHK'
             exporting
                  i_mode       = mode
                  i_bgrkl      = iklah-bgrkl
                  i_cl_act     = l_tcd_stat
             exceptions
                  no_authority = 1
                  others       = 2.
    l_subrc = sy-subrc.
    if not sy-subrc is initial and tcd_stat is not initial.
      clear l_tcd_stat.
      call function 'CLMA_AUTHORITY_CHK'
               exporting
                    i_mode       = mode
                    i_bgrkl      = iklah-bgrkl
                    i_cl_act     = l_tcd_stat
               exceptions
                    no_authority = 1
                    others       = 2.
    endif.

    if not sy-subrc is initial or l_subrc is not initial.
      LOOP AT SCREEN.
        if screen-name = 'RMCLF-CLASS'.
          if l_tcd_stat is initial and sy-subrc is not initial.
                MOVE 'Keine Berechtigung für die Klasse'(150) TO RMCLF-KLTXT.
                screen-input     = '0'.
                screen-output    = '0'.
                screen-invisible = '1'.
          else.
                screen-input     = '0'.
                screen-output    = '1'.
                screen-invisible = '0'.
          endif.
        elseif screen-name = 'RMCLF-STDCL' or
                  screen-name = 'RMCLF-STATU' or
                  screen-name = 'RMCLF-ZAEHL'.
                screen-input     = '0'.
                screen-output    = '1'.
                screen-invisible = '0'.
        endif.
                   modify screen.
      ENDLOOP.
  endif.                                                   "End 1878179

    when c_zuord_4.

*     loop at screen.                                 beginn   "1772310
*        if ( screen-group1  = c_io_field and
*             (
*               ( classif_status = c_display or
*                 classif_status = space )
*               or
*               ( screen-name = 'RMCLF-STATU' and
*                 g_klastab_val_idx > 0       and
*                 tc_obj_class-current_line <> g_klastab_val_idx )
*             )
*           ) or
*
*           ( screen-group1     = c_key   and
*             klastab-index_tab > 0       ) or
*
*           ( not g_obj_scr is initial    and
*             klastab-index_tab > 0 ) .

     if allkssk-mafid = mafido.
       l_save_objek = klastab-objek.
     else.
       l_save_objek = allkssk-oclint.
     endif.

     perform check_kssk_count using
             l_save_objek  rmclf-klart  allkssk-mafid
             allkssk-obtab  l_inob_init  syst-subrc.
     l_chgNr_Ok = syst-subrc.
     if tc_obj_class-current_line = 1.
       clear g_change_item.
     endif.

     loop at screen.
       if ( screen-group1  = c_io_field and
              ( classif_status = c_display or
                classif_status = space ) ) or
           ( screen-group1     = c_key   and
             klastab-index_tab > 0       ) or

           ( not g_obj_scr is initial    and
            klastab-index_tab > 0 ) or

          ( l_chgNr_Ok > 0 and RMCLF-AENNR1 is INITIAL ). "Ende 1772310

          check screen-name ne 'RMCLF-KREUZ' .
*         Auf Anzeige stellen
          screen-input     = '0'.
          screen-output    = '1'.
          screen-invisible = '0'.
          modify screen.
        else.                                                  "1772310
          g_change_item = 'X'.                                 "1772310
        endif.
      endloop.

  endcase.

endform.                               " MODIFY_SCREEN
