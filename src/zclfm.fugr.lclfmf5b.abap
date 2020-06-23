*&---------------------------------------------------------------------*
*&      Form  OK_HCLG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form ok_hclg.

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
            i_batch              = kreuz
            i_graphic            = kreuz
*               i_including_text     = 'X'
            i_language           = syst-langu
            i_no_classification  = kreuz
            i_date               = rmclf-datuv1
            i_change_number      = rmclf-aennr1
*               I_STRUCTURED_LIST    = 'X'
       tables
            daten                = ghclh
       exceptions
            class_not_valid      = 1
            classtype_not_valid  = 2
            others               = 3.
  if sy-subrc <> 0.
  endif.

endform.                               " OK_HCLG
