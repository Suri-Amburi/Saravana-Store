*&---------------------------------------------------------------------*
*&      Form  RMCLF_ABTEI_F4
*&---------------------------------------------------------------------*
*       F4-Hilfe der Sichten
*----------------------------------------------------------------------*
form rmclf_abtei_f4.
*-- Definitionen für F4-Baustein
  data: begin of l_inttab occurs 0,
          tabname      like dd08v-tabname,
          fieldname    like dd03l-fieldname,
          text         like tstct-ttext,
        end of l_inttab.
  data: l_fields_tab like help_value occurs 10 with header line.
  data: begin of l_fld_list occurs 10,
          feldname(70),
        end   of l_fld_list.
  data: l_fieldname like l_inttab-fieldname,
        l_ind       like sy-tabix.
*-- Ende der Definitionen für F4-Baustein

  data: begin of l_tcls_tab occurs 0,
          sicht like tcls-sicht,
          stext like tclst-stext,
        end of l_tcls_tab.
*-- Definitionen für Aktuelle Werte auf Dynpro
  data: l_repid   like sy-repid value 'SAPLCLFM'.
  data: begin of l_dynp_tab  occurs  0 .
          include structure dynpread .
  data: end of l_dynp_tab  .

*-- Wert für RMCLF-ABTEI von Dynpro lesen
  refresh l_dynp_tab .
  clear l_dynp_tab .
  rmclf-abtei = g_sicht_akt.
  l_dynp_tab-fieldname  = 'RMCLF-ABTEI'.
  l_dynp_tab-fieldvalue = rmclf-abtei.
  l_dynp_tab-stepl      = 0 .
  append l_dynp_tab .

  call function 'DYNP_VALUES_READ'
       EXPORTING
            dyname               = l_repid
            dynumb               = sy-dynnr
       TABLES
            dynpfields           = l_dynp_tab
       EXCEPTIONS
            invalid_abapworkarea = 01
            invalid_dynprofield  = 02
            invalid_dynproname   = 03
            invalid_dynpronummer = 04
            invalid_request      = 05
            no_fielddescription  = 06
            undefind_error       = 07.
*-- ... Wert in Ausgabefeld   übernehmen
  if sy-subrc is initial.
    rmclf-abtei = l_dynp_tab-fieldvalue.
  endif.
*-- Neue einträge selektieren
  select sicht stext from tclst into corresponding fields
         of table l_tcls_tab
   where spras = sy-langu
    and  klart = rmclf-klart.

  if not sy-subrc is initial.
*-- Keine Einträge gefunden
    exit.
  endif.

*-- bereits in RMCLF-ABTEI enthaltene Sichten aus TCLS löschen
  if not rmclf-abtei is initial.
    loop at l_tcls_tab.
      if rmclf-abtei cs l_tcls_tab-sicht.
        delete l_tcls_tab index sy-tabix.
      endif.
    endloop.
  endif.

*-- Eliminierung der doppelten Einträge
  SORT l_tcls_tab BY sicht.                                    "1859546
  delete adjacent duplicates from l_tcls_tab
                  comparing sicht.

  describe table l_tcls_tab lines l_ind.
  check not l_ind is initial.
*-- Anzeige
  l_fieldname = 'TCLST-SICHT'.
  refresh l_fields_tab.
  l_fields_tab-tabname    = 'TCLST'.
  l_fields_tab-fieldname  = 'SICHT'.
  l_fields_tab-selectflag = kreuz.
  append l_fields_tab.
  l_fields_tab-selectflag = space .
  l_fields_tab-tabname   = 'TCLST'.
  l_fields_tab-fieldname = 'STEXT'.
  append l_fields_tab.

  call function 'HELP_VALUES_GET_NO_DD_NAME'
       EXPORTING
            selectfield                  = l_fieldname
       IMPORTING
            ind                          = l_ind
       TABLES
            fields                       = l_fields_tab
            full_table                   = l_tcls_tab
       EXCEPTIONS
            full_table_empty             = 1
            no_tablestructure_given      = 2
            no_tablefields_in_dictionary = 3
            more_then_one_selectfield    = 4
            no_selectfield               = 5
            others                       = 6.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  if l_ind ne 0.
    read table l_tcls_tab index l_ind.
    if sy-subrc is initial.
      move l_tcls_tab-sicht to rmclf-abtei+9.
      condense rmclf-abtei no-gaps.
    endif.
  endif.
*-- In globale Variable übernehmen
  g_sicht_akt = rmclf-abtei.

endform.                               " RMCLF_ABTEI_F4
