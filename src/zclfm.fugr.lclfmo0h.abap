*------------------------------------------------------------------*
*       MODULE LIST_KLASTAB OUTPUT                                 *
*------------------------------------------------------------------*
*  Anzeigen Klastab:
*  CL20/22, Dynpro *500: loop at klastab with ...
*  CL24,    Dynpro *511: loop at g_obj_indx_tab with ...
*  Cl24,    Dynpro *2xx: loop at klastab with ...
*------------------------------------------------------------------*
module list_klastab output.

  anzloop = syst-loopc.

  if g_zuord = c_zuord_4  and
     g_obj_scr is initial and
     g_cls_scr is initial.
*    overview screen: KLASTAB anhand G_OBJ_INDX_TAB nachlesen
    klastab-index_tab = 0.
    read table klastab into klastab index g_obj_indx_tab-index.
  endif.

  if klastab-index_tab = 0.
    if klastab[] is initial.
      exit from step-loop.
    endif.
*   1. no allocations: inactivate all fields.
*   2. empty lines added in klastab: IO-fields open
*      variant class type: no status
    if g_46_ta <> space.
      if classif_status = c_display or
         classif_status = space     or
         ( tcla-varklart <> space and g_zuord = space ).
        perform modify_screen.
      endif.
    endif.
    exit.
  endif.

*-- Nachlesen Felder aus Tabelle ALLKSSK über KLASTAB-INDEX
  read table allkssk index klastab-index_tab.
  if not klastab-objek is initial.
    rmclf-kreuz = klastab-markupd.
    rmclf-zaehl = allkssk-zaehl.

*-- Objekt bzw. Klasse darstellen
*   Texte auseinandersteuern (CL20..CL23, CL24 u.CL25)
    if g_zuord = c_zuord_4.
      if g_cls_scr is initial.
        rmclf-objek = allkssk-objek.
        rmclf-obtxt = allkssk-kschl.
      else.
*       Klassen hinzufügen
        rmclf-class = allkssk-objek.
        rmclf-kltxt = allkssk-kschl.
      endif.
    else.
*-- ... CL20/22
      rmclf-class = allkssk-class.
      rmclf-kltxt = allkssk-kschl.
    endif.

    rmclf-stdcl = allkssk-stdcl.
    if allkssk-statu = cl_statusus.
      rmclf-statu = cl_statusum .
    else.
      rmclf-statu = allkssk-statu.
    endif.

    if allkssk-mafid = mafidk.
      rmclf-obtyp = text-300.
    else.
      rmclf-obtyp = allkssk-objtype.
    endif.

    if g_zuord = c_zuord_4.
      if g_obj_scr is initial.
*       alle Objekte incl. Klassen
        if allkssk-mafid = mafido.
          rmclf-obtyp = allkssk-objtype.
          call function 'CLCV_CONV_EXIT'
               exporting
                    ex_object      = allkssk-objek
                    table          = allkssk-obtab
               importing
                    im_object      = rmclf-objek
               exceptions
                    tclo_not_found = 1
                    others         = 2.
          check sy-subrc is initial.
        else.
          rmclf-obtyp = text-300.
        endif.
      else.
*       Objekte: screens 02xx
        call function 'CLCV_CONVERT_OBJECT_TO_FIELDS'
             exporting
                  table     = allkssk-obtab
                  rmclfstru = rmclf
             importing
                  rmclfstru = rmclf
             tables
                  lengthtab = laengtab.
      endif.
    endif.

    if tcla-varklart <> space and g_zuord = space.
*     variant class type: do not display status.
    else.
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
    endif.

  else.
    clear rmclf-zaehl.
    clear rmclf-kltxt.
    clear rmclf-objek.
    clear rmclf-obtxt.
    clear rmclf-statu.
    clear rmclf-kreuz.
  endif.

  perform modify_screen.

endmodule.
