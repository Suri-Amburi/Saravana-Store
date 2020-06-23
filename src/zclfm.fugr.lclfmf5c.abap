*&---------------------------------------------------------------------*
*&      Form  OK_HCLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form ok_hcla.

  data: l_class like klah-class.

  perform read_selected_line changing l_class.
  if l_class is initial.
    exit.
  endif.

*-- Strukturauflösung: 2 unterschiedliche Aufrufe!! Diese müssen in
*-- genau dieser Reihenfolge durchgeführt werden.
*-- ... 1.Aufruf: Aufbau der Hierarchietabelle
  call function 'CLHI_STRUCTURE_CLASSES'
       exporting
            i_klart              = rmclf-klart
            i_class              = l_class
            i_bup                = kreuz
            i_tdwn               = kreuz
            i_batch              = kreuz
*               I_ENQUEUE            = ' '
*               I_INCLUDING_TEXT     = 'X'
            i_language           = syst-langu
            i_no_classification  = kreuz
*               I_VIEW               = 'K'
            i_date               = rmclf-datuv1
            i_change_number      = rmclf-aennr1
*               I_SORT_BY_CLASS      = 'X'
*               I_STRUCTURED_LIST    = 'X'
       tables
            daten                = ghclh
       exceptions
            class_not_valid      = 1
            classtype_not_valid  = 2
            others               = 3.
  if sy-subrc <> 0.
  endif.

*-- ... 2.Aufruf: Ausgabe der Liste

  call function 'CLHI_STRUCTURE_CLASSES'
       exporting
            i_klart              = rmclf-klart
            i_class              = l_class
            i_bup                = kreuz
*               I_INCLUDING_TEXT     = 'X'
            i_language           = syst-langu
            i_no_classification  = kreuz
            i_view               = mafidk
            i_date               = rmclf-datuv1
            i_change_number      = rmclf-aennr1
*               I_SORT_BY_CLASS      = 'X'
*               I_CALLED_BY_CLASSIFY = ' '
*               I_STRUCTURED_LIST    = 'X'
       tables
            daten                = ghclh
       exceptions
            class_not_valid      = 1
            classtype_not_valid  = 2
            others               = 3.
  if sy-subrc <> 0.
  endif.

endform.                               " OK_HCLA
