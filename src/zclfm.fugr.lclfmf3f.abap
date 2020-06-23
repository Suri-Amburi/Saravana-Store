*&---------------------------------------------------------------------*
*&      Form  GET_OBJECT_CUST_DATA
*&---------------------------------------------------------------------*
*       Gets customizing data of object to be classified.
*      -->P_TABLEA   obj. table from TCLA
*      -->P_TABLEAO  obj. table from TCLAO
*      -->P_KLART    class type
*----------------------------------------------------------------------*
form get_object_cust_data
     using    value(p_table_a)
              value(p_table_ao)
              value(p_klart)
     changing l_prog_object.

  data:
    l_objtype        type tclt-obtab.


* get program of include screens
  if sy-binpt is initial.
    l_objtype = p_table_ao.
  else.
    clear l_objtype.
  endif.
  call function 'CLTB_GET_FUNCTIONS'
    exporting
      i_obtab           = l_objtype
    importing
      e_function_import = tclfm-fbs_import
      e_function_export = tclfm-fbs_export
      e_function_pool   = tclfm-repid
    exceptions
      not_found         = 1
      others            = 2.

  call function 'CLOB_SELECT_OBJECT_DATA'
    exporting
      table           = p_table_ao
      classtype       = p_klart
    importing
      dynnr1          = tclt-dynnr1
      dynnr4          = tclt-dynnr4
      object_text     = tcltt-obtxt
    exceptions
      table_not_found = 1.
  if syst-subrc = 1.
    message e521 with sobtab.
  endif.

  if sy-binpt is initial.
    if pm_header-report is initial.
      clear pm_header.
      pm_header-report = tclfm-repid.
      l_prog_object    = tclfm-repid.
    else.
*     already set by dynpro_header
    endif.
    if pm_header-dynnr is initial.
      if tclt-dynnr1 is initial.
        d5xx_dynnr      = dynp0199.
        pm_header-dynnr = dynp0499.
      else.
        d5xx_dynnr      = tclt-dynnr1.
        pm_header-dynnr = tclt-dynnr4.
      endif.
    else.
      d5xx_dynnr      = pm_header-dynnr.
    endif.
  else.
    pm_header-report = tclfm-repid.
    pm_header-dynnr  = dynp0499.
    l_prog_object    = tclfm-repid.
    d5xx_dynnr       = dynp0199.
  endif.

  if tcltt-obtxt is initial.
    message s548 with p_table_a syst-langu.
  else.
    strlaeng = strlen( tcltt-obtxt ).
    assign tcltt-obtxt(strlaeng) to <length>.
  endif.

endform.                               " GET_OBJECT_CUST_DATA
