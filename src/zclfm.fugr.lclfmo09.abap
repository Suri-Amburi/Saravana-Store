*------------------------------------------------------------------*
*       MODULE LIST_ITCLC OUTPUT                                   *
*------------------------------------------------------------------*
*       Anzeigen Status der Klassifizierung Dynpro 601             *
*------------------------------------------------------------------*
module list_itclc output.

* Lesen Tabelle ITCLC
  anzloop = syst-loopc.
  rmclf-radio   = punkt.
  rmclf-statu   = itclc-statu.
  rmclf-stattxt = itclc-stattxt.
*  if klastab-statu = cl_statusus.
*    klastab-statu = cl_statusum.
*  endif.
*  if rmclf-statu = klastab-statu.
  if allkssk-statu = cl_statusus.
    allkssk-statu = cl_statusum.
  endif.
  if rmclf-statu = allkssk-statu.
    rmclf-radio = kreuz.
    loop at screen.
      if screen-group3 = group3int.
        screen-intensified = on.
        modify screen.
      endif.
    endloop.
  endif.

  if icon1 is initial.
    perform create_icon.
  endif.
  case rmclf-statu.
    when cl_statusf.
      rmclf-icon = icon1.
    when cl_statusge.
      rmclf-icon = icon2.
    when cl_statusum.
      rmclf-icon = icon3.
    when cl_statusus.
      rmclf-icon = icon4.
    when space.
      clear rmclf-icon.
  endcase.
endmodule.
