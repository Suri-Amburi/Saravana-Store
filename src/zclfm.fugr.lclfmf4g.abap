*&---------------------------------------------------------------------*
*&      Form  ok_XCLG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form ok_xclg.

  data: l_class like klah-class.

  perform read_selected_line changing l_class.
  if l_class is initial.
    message s501.
    exit.
  endif.

  call function 'CLHI_STRUCTURE_CLASSES'
       exporting
            i_klart              = rmclf-klart
            i_class              = l_class
            i_bup                = kreuz
            i_tdwn               = kreuz
            i_batch              = kreuz
            i_graphic            = kreuz
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

endform.                               " ok_XCLG
