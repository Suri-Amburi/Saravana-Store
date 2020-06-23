*------------------------------------------------------------------*
*       MODULE SET_CURSOR OUTPUT                                   *
*------------------------------------------------------------------*
*       Positionieren Cursor                                       *
*------------------------------------------------------------------*
module set_cursor output.

  if syst-dynnr = dy602.
    if zeile1 is initial.
      set cursor field 'RMCLF-TEXTO' line ein offset 0.
    else.
      set cursor field 'RMCLF-TEXTO' line zeile1 offset 0.
    endif.
    exit.
  endif.

  if sokcode = okeint.
    read table klastab index 1.
    if syst-subrc = 0.
      zeile = 2.
    else.
      clear fname.
      zeile = 1.
    endif.
    Perform MARKIEREN_OKNEUZ IN PROGRAM SAPLCTMS.          "Note 1320208
  endif.

  if g_46_ta = kreuz.
*   Rel. >= 4.6
    if zeile > 0.
      if fname is initial.
        if g_zuord = c_zuord_4 and g_cls_scr = space.
          fname = 'RMCLF-OBJEK'.
        else.
          fname = 'RMCLF-CLASS'.
        endif.
      endif.
      set cursor field fname line zeile.
    elseif classif_status <> space.
      if g_zuord = c_zuord_4 .
        fname = 'RMCLF-OBJEK'.
      else.
        fname = 'RMCLF-CLASS'.
      endif.
      set cursor field fname line 1.
    endif.

*------------------------------------------------------
  else.
    if not zeile is initial.
      if cn_mark > 0.
        fname = 'RMCLF-KREUZ'.
      else.
        if fname is initial.
*       if syst-dynnr = dy511.
          if g_zuord = c_zuord_4 and g_cls_scr = space.
            fname = 'RMCLF-OBJEK'.
          else.
            fname = 'RMCLF-CLASS'.
          endif.
        endif.
      endif.
      set cursor field fname line zeile offset 0.
    else.
      if g_zuord = c_zuord_4 .
        fname = 'RMCLF-OBJEK'.
      else.
        fname = 'RMCLF-CLASS'.
      endif.
      set cursor field fname line ein offset 0.
    endif.
  endif.

endmodule.
