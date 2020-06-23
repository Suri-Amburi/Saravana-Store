*&---------------------------------------------------------------------*
*&      Form  CLFY_WITHOUT_DIALOGUE
*&---------------------------------------------------------------------*
*       Performs classification when dialogue is suppressed,
*       e.g. CO module loops over CLFM_OBJETC_CL. (class type 13/14).
*
*       Code is similar to that one in 'auswahl'.
*       Klastab has always only 1 entry.
*       Allkssk has all objects to be classified.
*       Import: ('Chargenextralogik' !)
*           batch = x  do not open a sreen for dialogue
*           nodisp= x  call screen, if status not o.k.
*       Return:
*           p_subrc = 0  status check o.k
*                   = 4               not o.k.
*----------------------------------------------------------------------*
form clfy_without_dialogue
     using    p_objek  like allkssk-objek
              p_batch  like sy-batch
              p_nodisp like sy-batch
     changing p_subrc  like sy-subrc.

  data: l_subrc      type sy-subrc,
        l_praus      type klah-praus.

  p_subrc = 0.
  read table allkssk with key objek = p_objek
                              klart = rmclf-klart.
  if sy-subrc = 0.
    pm_objek    = allkssk-objek.
    pm_class    = allkssk-class.
    g_sicht_akt = allkssk-sicht.
    pm_status   = allkssk-statu.
    pm_clint    = allkssk-clint.
    rmclf-class = allkssk-class.
    rmclf-kltxt = allkssk-kschl.
    pm_inobj    = allkssk-cuobj.
    rmclf-stdcl = allkssk-stdcl.
    l_praus     = allkssk-praus.
    g_allkssk_akt_index = sy-tabix.      " used in classify

    if allkssk-lock is initial.
      allkssk-lock = kreuz.
      modify allkssk index sy-tabix.
      perform build_viewtab using allkssk-clint pm_class.
    endif.

*   set pm_status = 1 for test:
*   causes CTMS to check status (classify, check-status)
    if pm_status <> cl_statusf.
      read table xtclc with key klart     = allkssk-klart
                                statu     = pm_status
                                clautorel = kreuz.
      if sy-subrc = 0.
        pm_status = cl_statusf.
      endif.
    endif.

*   assign character values:
*   Close val. ass. directly via CTMS, for we are possibly
*   in a subscreen. Form close_prev_value_assmnt creates
*   error messages.
    perform classify.
    call function 'CTMS_DDB_CLOSE'
       tables
            exp_selection  = sel
       exceptions
            inconsistency  = 1
            incomplete     = 2
            verification   = 3
            not_assigned   = 4
            another_object = 5
            other_objects  = 6
            display_mode   = 7
            others         = 8.
    l_subrc = sy-subrc.
    if l_subrc > 0.
      if l_subrc = 5 or l_subrc = 6.
*       identical classification
        if l_praus <> konst_e.
          l_subrc = 0.
        endif.
      endif.
      if l_subrc > 0.
        if p_batch = space and p_nodisp <> space.
          l_subrc = 4.
        else.
          l_subrc = 0.                 " 716271
          if NOT p_batch is initial  AND                "vv Note 1537443
             NOT nodisplay is initial.
            gv_no_message = 'X'.
          endif.                                        "^^ Note 1537443
        endif.
      endif.
    endif.

    perform build_allausp.
    if l_subrc = 0.
      perform save_all changing l_subrc.
    else.
*     status > 1, object data in CTMS yet
      p_subrc = 4.
    endif.

  endif.

endform.                               " CLFY_WITHOUT_DIALOGUE
