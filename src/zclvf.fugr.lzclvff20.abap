*---------------------------------------------------------------------*
*       FORM REK_STUECKLISTE                                          *
*---------------------------------------------------------------------*
*       Rekursivitätsprüfung                                          *
*---------------------------------------------------------------------*
*  -->  SYST-SUBRC                                                    *
*---------------------------------------------------------------------*
form rek_stueckliste using objekt like kssk-objek
                           return like syst-subrc.
*
  data: uclass   like klah-class.
  data: material type matnr.
*
  data: begin of cltab occurs 0,
          class like klah-class.
  data: end of cltab.
*
  if rmclkssk-mafid = mafido.
    material = objekt.
  else.
    clear iklah.
    refresh iklah.
    iklah-clint = rmclkssk-clint.
    append iklah.
    call function 'CLSE_SELECT_KLAH'
      tables
        imp_exp_klah   = iklah
      exceptions
        no_entry_found = 01.
    read table iklah index 1.
    uclass = iklah-class.
  endif.

  call function 'FUNCTION_EXISTS'
    exporting
      funcname           = 'CS_RC_RECURSIVITY_CHECK'
    exceptions
      function_not_exist = 1
      others             = 2.
  if sy-subrc <> 0.
    clear return.
  else.

    call function 'CS_RC_RECURSIVITY_CHECK'
      exporting
        eclass            = uclass
        eidnrk            = material
        eklart            = rmclkssk-klart
        eclint            = rmclkssk-clint
        emode             = '2'
        erekrs            = space
        flg_vbtask        = kreuz
        flg_init          = space
      tables
        headertab         = cltab
      exceptions
        call_invalid      = 1
        recursivity_found = 2.
    if syst-subrc = 0.
      clear return.
    else.
      return = syst-subrc.
    endif.
  endif.
endform.                    "REK_STUECKLISTE

*---------------------------------------------------------------------*
*       FORM ausp_ecm
*---------------------------------------------------------------------*
*       Select AUSP entries with change number.
*       APPEND (!) entries to table AP2 (global).
*---------------------------------------------------------------------*
form ausp_ecm
     using value(p_object)
           p_rmcl    like rmcldel.

  data:
    lt_ausp      like ausp      occurs 0 with header line,
    lt_ausp_nam  like tablekey  occurs 0 with header line,
*   Tabelle der abh. Änderungsnummern
    lt_aennr     type cc01_liste3.


  if g_effectivity_used is initial.
*   normal change management
    select objek atinn atzhl mafid klart max( datuv )
           from ausp
           into (ap2-objek, ap2-atinn,
                 ap2-atzhl, ap2-mafid,
                 ap2-klart, ap2-datuv)
           where klart =  p_rmcl-klart
             and objek =  p_object
             and mafid =  p_rmcl-mafid
             and atinn =  p_rmcl-merkm
             and datuv <= xdatuv
           group by objek atinn atzhl mafid klart.
      append ap2.
    endselect.

  else.
*   Effectivity
    refresh lt_ausp.
    refresh lt_ausp_nam.
    lt_ausp_nam-obtab = c_ausp_nam.
    lt_ausp_nam-mafid = p_rmcl-mafid.
    lt_ausp_nam-klart = p_rmcl-klart.
    lt_ausp_nam-objek = p_rmcl-objek.
    append lt_ausp_nam.

    call function 'CLEF_ECM_PROCESSOR'
      tables
        t_tabkey     = lt_ausp_nam
        aennr_output = lt_aennr
      exceptions
        ecm_error    = 1
        others       = 2.

    describe table lt_aennr lines sy-tfill.
    if sy-tfill = 0.
      select objek atinn atzhl mafid klart datuv aennr
             from ausp
             into (lt_ausp-objek,
                   lt_ausp-atinn, lt_ausp-atzhl,
                   lt_ausp-mafid, lt_ausp-klart,
                   lt_ausp-datuv, lt_ausp-aennr)
             where klart  = p_rmcl-klart
               and objek  = p_object
               and mafid  = p_rmcl-mafid
               and atinn  = p_rmcl-merkm
               and ( datuv <= xdatuv  and
                     datuv <> g_effectivity_date ).
        append lt_ausp.
      endselect.
    else.
      select objek atinn atzhl mafid klart datuv aennr
             from ausp into (lt_ausp-objek,
                             lt_ausp-atinn, lt_ausp-atzhl,
                             lt_ausp-mafid, lt_ausp-klart,
                             lt_ausp-datuv, lt_ausp-aennr)
             for all entries in lt_aennr
             where klart  = p_rmcl-klart
               and objek  = p_object
               and mafid  = p_rmcl-mafid
               and atinn  = p_rmcl-merkm
               and ( ( datuv <= xdatuv  and
                       datuv <> g_effectivity_date )
                     or
                     aennr = lt_aennr-aennr ).
        append lt_ausp.
      endselect.
    endif.

*   Auswahl der gültigen Einträge
    call function 'CLEF_AUSP_DET_VALID'
      exporting
        i_effectivity_act = g_effectivity_used
        i_classtype       = p_rmcl-klart
        i_effe_datum      = g_effectivity_date
        i_change_mod      = kreuz
        i_ausp_new        = kreuz
      tables
        t_ausp_tab        = lt_ausp
        t_aennr_tab       = lt_aennr
      exceptions
        no_classtype      = 1
        others            = 2.
    if sy-subrc <> 0.
      message e001 with 'CLVF_VB_DELETE_CLASSIFICATION'
                        p_rmcl-klart .
    endif.

    loop at lt_ausp where klart <> space.
      move-corresponding lt_ausp to ap2.
      append ap2.
    endloop.
    sort ap2 by objek atinn atzhl mafid klart.
  endif.

endform.                               " ausp_ecm
