*&---------------------------------------------------------------------*
*&      Form  OKB_HCLG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_hclg.

  perform get_selected_class
          using     g_zuord
                    zeile
                    index_neu
          changing  pm_class.
  check not pm_class is initial.
  call function 'CLHI_STRUCTURE_CLASSES'
       exporting
            i_klart              = rmclf-klart
            i_class              = pm_class
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

endform.                               " OKB_HCLG
