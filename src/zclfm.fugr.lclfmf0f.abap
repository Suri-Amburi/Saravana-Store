*&---------------------------------------------------------------------*
*&      Form  OKB_SICH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_sich.

  zeile = zeile + index_neu - 1.
  if g_zuord ne c_zuord_4.
    read table klastab index zeile.
    zeile = zeile - index_neu + 1.
    if not syst-subrc eq 0.
      message i425.
    else.
      hzeile = zeile.
      g_sicht_akt           = klastab-sicht.
      pm_objek           = rmclf-objek.
      pm_class           = klastab-objek.
    endif.
  endif.
  if g_zuord eq c_zuord_4.
    describe table merkmal lines syst-tfill.
    if syst-tfill > 0.
      if pm_depart is initial.
        perform build_sicht tables merkmal using syst-subrc.
        pm_depart = kreuz.
        if syst-subrc = 0.
          call function 'CTMS_VIEW_DISPLAY'.
        else.
          message s538.
        endif.
      else.
        if department-sicht is initial.
          message s538.
        else.
          call function 'CTMS_VIEW_DISPLAY'.
        endif.
      endif.
    else.
      message s538.
    endif.
  else.
    refresh merktab.
    loop at viewk where class = pm_class
                    and klart = rmclf-klart.
      check not viewk-merkm is initial.
      if not viewk-posnr is initial.
        merktab-imerk = viewk-merkm.
        merktab-omerk = viewk-omerk.
        merktab-abtei = viewk-abtei.
        append merktab.
      endif.
    endloop.
    if syst-subrc = 0.
      perform build_sicht tables merktab using syst-subrc.
      if syst-subrc = 0.
        call function 'CTMS_VIEW_DISPLAY'.
      else.
        message s538.
      endif.
    else.
      message s538.
    endif.
  endif.

endform.                               " OKB_SICH
