*---------------------------------------------------------------------*
*       MODULE HELP_TEXT    INPUT                                     *
*---------------------------------------------------------------------*
*       PF 1 auf Textfeld                                             *
*---------------------------------------------------------------------*
module help_text input.
  get cursor field fname line zeile offset offset.
  check syst-subrc = 0.
*-- Im Rahmen Table-CNTRL-Umstellung ersetzt
  zeile =  index_neu .
  read table g_obj_indx_tab index zeile.
  check syst-subrc = 0.
  read table klastab index g_obj_indx_tab-index.
  check syst-subrc = 0.
  if klastab-mafid = mafidk.
    call function 'HELP_DOCU_SHOW_FOR_FIELD'
         EXPORTING
              fieldname     = 'KTEXT'
              tabname       = 'RMCLF'
              help_in_popup = kreuz.
  else.
    select single textf from tclo into tclo-textf           "YMZ
*   SELECT SINGLE TCLO-TEXTF FROM TCLO INTO TCLO-TEXTF            "YMZ
      where obtab = klastab-obtab.
    if tclo-textf is initial.
      message s720(sh).
      exit.
    endif.
    call function 'HELP_DOCU_SHOW_FOR_FIELD'
         EXPORTING
              fieldname     = tclo-textf
              tabname       = tclo-txttab
              help_in_popup = kreuz.
  endif.
endmodule.
