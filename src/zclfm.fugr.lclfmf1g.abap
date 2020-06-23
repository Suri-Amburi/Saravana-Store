*----------------------------------------------------------------------*
*       FORM CHK_BATCH
*----------------------------------------------------------------------*
*       Prüft Chargenklassifizierung
*----------------------------------------------------------------------*
*  -->  i_table       object table
*       i_bi_dialog   call parameter from CLFM_O_CL
*  <--  e_class       class that mat/batch is allocated to
*----------------------------------------------------------------------*
form chk_batch     using     value(i_table)
                             value(i_bi_dialog)
                changing     e_class .

  data: l_class like rmclf-class.

  if rmclf-klart = '022' or
     rmclf-klart = '023'.
    if i_table = 'MARA' or i_table = 'MCHA' or i_table = 'MCH1'.
      try.
       call function 'CLFC_BATCH_ALLOCATION_TO_CLASS'       "#EC EXISTS
         exporting
           material            = rmclf-matnr
           classtype           = rmclf-klart
           i_ignore_matmaster  = kreuz
         importing
           class               = l_class
         exceptions
*          wrong_function_call = 1
           no_class_found      = 2
           no_classtype_found  = 3
           others              = 5.
        catch cx_sy_dyn_call_param_not_found
              cx_sy_dyn_call_illegal_func.
          message e001(cl) with 'CLFC_BATCH_ALLOCATION_TO_CLASS'.
      endtry.

      if g_zuord = c_zuord_4.
*       transaction CL24(n), do not change e_class !
        if l_class <> space and
           l_class <> e_class.
          message e112(lb) with rmclf-matnr l_class.        "#EC *
        endif.

      else.
*       transactions CL20(n), MM01, MM02
        if l_class <> space and
           l_class <> e_class.
          e_class = l_class.
          if sy-binpt is initial.
            message w415 with e_class.
          endif.
        endif.
        if classif_status = ein.
*         add mode
          rmclf-class = e_class.
        else.
*         change mode
          if not e_class is initial.
*           Diese Klasse für die aktuelle Charge übernehmen,
*           Zuordnungsbild überspringen ...
            suppressd = kreuz.
          endif.
          if sy-binpt = kreuz and
             i_bi_dialog is initial.
*             .. es sei denn,
*             im Batch-Input wird es ausdrücklich erwünscht
            clear suppressd.
          endif.
        endif.
      endif.

    endif.
  endif.

endform.                    "chk_batch
