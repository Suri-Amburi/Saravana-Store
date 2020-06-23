*&---------------------------------------------------------------------*
*&      Form  EXPAND_UDEF   (neu zu 31I)
*&---------------------------------------------------------------------*
*       Ein UDEF wird in seine Einzelmerkmale aufgelöst und in der
*       Tabelle T_CABN zurückgegeben
*----------------------------------------------------------------------*
form expand_udef tables t_atinn structure tatinn
                 using  i_udef  like cabn-atinn
                        e_subrc like sy-subrc.
  ranges: l_atinn for cabn-atinn.
  data: l_ksml_tab like ksml occurs 0 with header line,
        l_cabn_tab like cabn occurs 0 with header line.

  e_subrc = 4.
  refresh t_atinn.
  l_atinn-sign   = 'I'.
  l_atinn-option = 'EQ'.
  l_atinn-low    = i_udef.
  append l_atinn.
*-- Merkmal lesen
  call function 'CLSE_SELECT_CABN'
       exporting
            key_date       = rmclf-datuv1
*            i_aennr        = rmclf-aennr1        "4.6.98 CF
       tables
            in_cabn        = l_atinn
            t_cabn         = l_cabn_tab
       exceptions
            no_entry_found = 00.

  describe table l_cabn_tab lines syst-tfill.
  if syst-tfill eq 0.
    exit.
  endif.
*.. Prüfung auf 'Benutzerdefinierter Datentyp' ........................
  read table l_cabn_tab index 1.
  if l_cabn_tab-atfor ne 'UDEF'.
    refresh t_atinn.
    exit.
  endif.
*-- Zu UDEF nun die zugeordneten Merkmale lesen
  clear l_ksml_tab.
  refresh l_ksml_tab.
  l_ksml_tab-clint = l_cabn_tab-clint.
  append l_ksml_tab.
  refresh t_atinn.

  call function 'CLSE_SELECT_KSML'
       EXPORTING
            key_date       = rmclf-datuv1
            i_aennr        = rmclf-aennr1
       TABLES
            imp_exp_ksml   = l_ksml_tab
       EXCEPTIONS
            no_entry_found = 00.

  if sy-subrc is initial.
    clear e_subrc.
    loop at l_ksml_tab where imerk gt 0 .
      move l_ksml_tab-imerk to t_atinn-atinn.
      append t_atinn.
    endloop.
  endif.
endform.                               " EXPAND_UDEF
