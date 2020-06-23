*&---------------------------------------------------------------------*
*&      Form  OKB_MALL
*&---------------------------------------------------------------------*
*       Marks all lines in table control.
*----------------------------------------------------------------------*
form okb_mall.

  if  g_zuord = c_zuord_4.
*-- nur einzelne Objekttypen in CL24
    loop at g_obj_indx_tab.
      read table klastab index g_obj_indx_tab-index.
      if klastab-markupd is initial.
        klastab-markupd = kreuz.
        modify klastab index g_obj_indx_tab-index.
        cn_mark = cn_mark + 1.
      endif.
    endloop.
  else.
    klastab-markupd = kreuz.
    modify klastab transporting markupd
                         where markupd is initial.
    describe table klastab lines cn_mark.
  endif.

endform.                               " OKB_MALL
