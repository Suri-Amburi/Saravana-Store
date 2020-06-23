*&---------------------------------------------------------------------*
*&      Module  SET_KLART  OUTPUT
*&---------------------------------------------------------------------*
*       ermitteln Klassenart
*----------------------------------------------------------------------*
module set_klart output.

  check g_sel_changed <> space.

  clear no_class.
  fromcl20 = g_zuord.
  if g_zuord = c_zuord_0.
*   CL20n
    g_modus  = zwei.
  else.
    g_modus  = eins.
  endif.

  if sy-binpt is initial.
    get parameter id c_param_kar field rmclf-klart.
    if not rmclf-klart is initial.
      select single * from tcla
             where klart = rmclf-klart.
    endif.
  endif.

* Falls G_SAVE_POBTAB gefüllt:
* Aufruf über call transaction (-> RCCLRELE).
* Lese notwendige Parameter.
  if g_save_pobtab is initial.
    import g_save_pobtab from memory id 'G_POBTAB_DATUV'.
    if not g_save_pobtab is initial.
      import rmclf-datuv1 from memory id 'G_POBTAB_DATUV'.    "1021112
      get parameter id c_param_kar field rmclf-klart.
      get parameter id c_param_aen1 field rmclf-aennr1.
      sobtab = g_save_pobtab.
    endif.
    free memory id 'G_POBTAB_DATUV'.
  endif.

*-- SOBTAB besorgen
  if sobtab is initial.
    get parameter id c_param_klt field sobtab.
    if sobtab is initial.
      sobtab = tcla-obtab.
    else.
*     does class type go with table ?
      if tcla-multobj <> space.
        select * from  tclao
                 where klart = rmclf-klart
                   and tracl = space.
        endselect.
        if sy-dbcnt = 1.
          sobtab = tclao-obtab.
        endif.
      endif.
    endif.
  endif.

  if sobtab is initial.
    dynpro1xx = dynpro199 .
    clear rmcbc-klart.
  else.
    if g_zuord = c_zuord_0.
      call function 'CLOB_SELECT_OBJECT_DATA'
        exporting
          table           = sobtab
          classtype       = save_klart
        importing
          dynnr1          = tclt-dynnr1
          dynnr4          = tclt-dynnr4
          object_text     = tcltt-obtxt
        exceptions
          table_not_found = 1.
      if syst-subrc = 1.
        message e521 with sobtab.
      endif.
      if tcltt-obtxt is initial.
        message s521 with sobtab.
      else.
        strlaeng = strlen( tcltt-obtxt ).
        assign tcltt-obtxt(strlaeng) to <length>.
      endif.
*     selection subscreen
      if  tclt-dynnr1 is initial.      "Dynpronummer 1 initial
        dynpro1xx = dynpro199.         "JA ---> allgemeines Objektbild
      else.
        dynpro1xx = tclt-dynnr1.       "NEIN --> Bildbaustein 01xx
        pm_header-dynnr = tclt-dynnr4.                      "H314444
      endif.
    endif.
    rmcbc-klart = rmclf-klart.
  endif.

  modify_s100 = kreuz.
  multi_obj   = tcla-multobj.
  clear change_subsc_act.
  if tcla-aediezuord <> space.
    change_subsc_act = kreuz.
    if tcla-multobj <> space.
*     check ecm flag of object !
      select single * from tclao where klart = rmclf-klart
                                   and obtab = sobtab.
      if sy-subrc = 0 and
         tclao-aediezuord = space.
        clear change_subsc_act.
      endif.
    endif.
    if change_subsc_act = kreuz.
      get parameter id c_param_aen1 field rmclf-aennr1.
    endif.
  endif.

* get function group having dynpros (CBCM*)
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
  g_prog_cbcm      = tclfm-repid.
  g_prog_object    = tclfm-repid.
  pm_header-report = tclfm-repid.

  call function tclfm-fbs_export
    exporting
      ermcbc      = rmcbc
      table       = sobtab
      modify      = modify_s100
      read_object = kreuz
      ok_code     = okcode.

* check custom. settings for change management
  if g_zuord = c_zuord_4.
    get parameter id c_param_kla field rmclf-clasn.
    if tcla-multobj = kreuz and change_subsc_act is initial.
      refresh redun.
      call function 'CLOB_SELECT_TABLE_FOR_CLASSTYP'
        exporting
          classtype      = rmclf-klart
          spras          = syst-langu
        tables
          itable         = redun
        exceptions
          no_table_found = 01.
      loop at redun where aediezuord = kreuz.
        change_subsc_act = 'Y'.
        exit.
      endloop.
    endif.
  elseif g_zuord = c_zuord_0.
*   determine change_subsc_act for selected object
    if tcla-multobj = kreuz.
      refresh redun.
      call function 'CLOB_SELECT_TABLE_FOR_CLASSTYP'
        exporting
          classtype      = rmclf-klart
          spras          = syst-langu
        tables
          itable         = redun
        exceptions
          no_table_found = 01.
      loop at redun where obtab = sobtab.
        change_subsc_act = redun-aediezuord.
        exit.
      endloop.
    endif.
  endif.

  cla-change = change_subsc_act.
  cla-aeblg  = tcla-aeblgzuord.
  export cla to memory id 'CL20AE'.

endmodule.                             " SET_KLART  OUTPUT
