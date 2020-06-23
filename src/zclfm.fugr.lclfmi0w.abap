*---------------------------------------------------------------------*
*       MODULE NEW_SCREEN                                             *
*---------------------------------------------------------------------*
*       Nachdem Klassenart korrekt eingegeben, Bild nochmal senden.
*       Wird nur prozessiert, wenn Eingabedaten geändert wurden.
*       Klassenarten mit multobj=x:
*       Popup für Selektion Objekttyp wird aufgerufen.
*---------------------------------------------------------------------*
module new_screen.

  data:
    g_dynnr      like d020s-dnum,
    g_prog       like d020s-prog.

  if sy-binpt is initial.
    check not g_sel_changed is initial.
  endif.

  if rmclf-klart = tcla-klart.
    clear g_flag2.
  else.
    g_flag2 = kreuz.
  endif.

  if g_zuord = c_zuord_0.
*   CL20N, multobj=x: popup with object types
    g_flag = kreuz.
  else.
    g_flag = space.
  endif.
  call function 'CLCA_PROCESS_CLASSTYPE'
    exporting
      classtype          = rmclf-klart
      mode               = g_modus
      dynpros            = g_flag
      objects_only       = kreuz
      obj_only_classtype = kreuz
      fromcl20           = fromcl20
    importing
      classtype          = rmclf-klart
      typetext           = rmclf-artxt
      multi_classif      = multi_class
      mult_obj           = multi_obj
      no_cl_trans        = no_class
      table              = sobtab
      ptable             = pobtab
      imptcla            = tcla
    exceptions
      no_auth_klart      = 02
      not_found          = 03
      others             = 04.

  case sy-subrc.
    when 2.
      message e545 with rmclf-klart.   "Berechtigung Klassenart
    when 3 or 4.
      message e014 with rmclf-klart.   "nicht definiert
  endcase.

  if not no_class is initial.                               " 819588
*   "transaction not allowed ..."
    message e502 with rmclf-klart.
  endif.
  if tcla-intklart = kreuz or tcla-klart = '031'.
*   internal class type
    message e556 with rmclf-klart.
  endif.
  if sobtab is initial.
    message e653 with ' " " '.
  else.
*   does subscreen of object type exist ?
    clear tclt.
    select single * from tclt where obtab = sobtab.
    if sy-subrc = 0.
*     get function group again (CBCM*)
      call function 'CLTB_GET_FUNCTIONS'
        exporting
          i_obtab           = sobtab
        importing
          e_function_import = tclfm-fbs_import
          e_function_export = tclfm-fbs_export
          e_function_pool   = tclfm-repid
        exceptions
          not_found         = 1
          others            = 2.
      if sy-subrc = 0.
        if tclt-dynnr1 = 0.
          tclt-dynnr1 = dynpro199.
        endif.
        g_prog_cbcm      = tclfm-repid.
        g_prog_object    = tclfm-repid.
        pm_header-report = tclfm-repid.
        g_dynnr = tclt-dynnr1.
        g_prog  = tclfm-repid.
        call function 'RS_SCRP_GET_SCREEN_INFOS'
          exporting
            dynnr    = g_dynnr
            progname = g_prog
          exceptions
            others   = 4.
      endif.
      if sy-subrc > 0.
*       subscreen in 'CBCM' is missing
        message e502 with rmclf-klart.
      endif.
    else.
      message e521 with sobtab.
    endif.
  endif.

* store selection
  set parameter id c_param_kar field rmclf-klart.
  set parameter id c_param_klt field sobtab.
  if not pobtab is initial.
    g_save_pobtab = pobtab.
  endif.
  if tcla-aediezuord is initial.
    clear rmclf-aennr1.
  endif.

  if not g_flag2 is initial.
*   class type changed: new object screen necessary,
*   back to PBO part.
    leave screen.
  endif.

endmodule.                    "new_screen
