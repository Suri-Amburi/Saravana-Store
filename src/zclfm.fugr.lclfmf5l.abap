*&---------------------------------------------------------------------*
*&      Form  ok_doc_graph
*&---------------------------------------------------------------------*
*       Show document to class, characteristic or char. value
*       if it is available.
*       First get the cursor position to determine the object
*       of which document is to be displayed.
*----------------------------------------------------------------------*
form ok_doc_graph.

  data:
    l_class        like klah-class,
    lt_klah        like klah occurs 0 with header line.

  get cursor field fname area g_tcname.

  if g_tcname = c_char_subscreen.
*     cursor in char subscreen:
*     show doc of characteristic
    call function 'CTMS_DDB_EXECUTE_FUNCTION'
      exporting
        okcode = ok_doku.

  else.
*   selection screen     (CL22n, CL24n)  or
*   allocation subscreen (CL20n, CL22n)
    perform read_selected_line changing l_class.
    if l_class <> space.
      call function 'FUNCTION_EXISTS'
        exporting
          funcname           = 'CVAPI_DOC_OPEN_VIEW'
        exceptions
          function_not_exist = 1
          others             = 2.

      if sy-subrc = 0.
        lt_klah-klart = rmclf-klart.
        lt_klah-class = l_class.
        append lt_klah.

        call function 'CLSE_SELECT_KLAH'
          tables
            imp_exp_klah = lt_klah
          exceptions
            others       = 0.

        read table lt_klah index 1.
        if sy-subrc = 0.
          if lt_klah-dokar = space or
             lt_klah-doknr = space.
            message i403 with l_class.
          else.
            call function 'CVAPI_DOC_OPEN_VIEW'             "#EC EXISTS
              exporting
                pf_dokar    = lt_klah-dokar
                pf_doknr    = lt_klah-doknr
                pf_dokvr    = lt_klah-dokvr
                pf_doktl    = lt_klah-doktl
              exceptions
                error       = 1
                not_found   = 4
                no_auth     = 5
                no_original = 8
                others      = 9.
            if sy-subrc > 0.
              message id sy-msgid type 'S' number sy-msgno
                      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            endif.
          endif.
        endif.
      endif.

    endif.                             "l_class
  endif.

endform.                    "ok_doc_graph

*&---------------------------------------------------------------------*
*&      Form  ok_doc_link
*&---------------------------------------------------------------------*
*       Show document link to class, characteristic or char. value
*       if it is available.
*       First get the cursor position to determine the object
*       of which document is to be displayed.
*----------------------------------------------------------------------*
form ok_doc_link.

  data:
    l_class        like klah-class.

  get cursor field fname area g_tcname.

  if g_tcname <> c_char_subscreen.
*   selection screen     (CL22n, CL24n)  or
*   allocation subscreen (CL20n, CL22n)
    perform read_selected_line changing l_class.
    if l_class <> space.
      call function 'FUNCTION_EXISTS'
        exporting
          funcname           = 'CLEX_CV_DOCUMENT_ASSIGNMENT'
        exceptions
          function_not_exist = 1
          others             = 2.

      if sy-subrc = 0.
        call function 'CLEX_CV_DOCUMENT_ASSIGNMENT'         "#EC EXISTS
          exporting
            p_class   = l_class
            p_klart   = rmclf-klart
            p_keydate = rmclf-datuv1
            p_opcode  = c_display.                          " = 3
      endif.
    endif.
  endif.

endform.                    "ok_doc_link

*&---------------------------------------------------------------------*
*&      Form  OK_EINT
*&---------------------------------------------------------------------*
*   CL24N: new object(s)
*   CL20N, CL22N, object transactions: new class(es)
*
*   CL24N: This form is called directly after fill-klastab.
*   Check status of new allocations, if several objects are
*   added ALL AT ONCE.
*   This cannot be processed in subscreen 02xx,
*   only on level of main screen 1110 (because of CTMS).
*----------------------------------------------------------------------*
form ok_eint.

  data:
    l_object_save         like kssk-objek,
    l_idx                 like sy-stepl,
    l_subrc               like sy-subrc.
* data l_klastab_akt_index  like sy-index.     "n_979874     "n_1139067

  l_object_save = klastab-objek.                          "n_1018459

* Update CTMS about change of class assignment                 "2360038
  CALL FUNCTION 'CTMS_DELETE_MEMORY'                           "2360038
    EXPORTING                                                  "2360038
      OBJECT        = l_object_save.                           "2360038

* first save previous value assignment
  perform close_prev_value_assmnt changing l_subrc.

  if g_zuord = c_zuord_4.

    check g_no_chars is initial.
    loop at gt_tmpkssk
            where objek <> l_object_save.
*     these objects have no values assigned !
*     sel is empty
      call function 'CLSE_CLFM_BUF_FLAGS'
        exporting
          i_ausp_flg = g_buffer_clse_active
          i_kssk_flg = space
        exceptions
          others     = 0.

      pm_objek  = gt_tmpkssk-objek.
      pm_inobj  = gt_tmpkssk-cuobj.
      pm_class  = gt_tmpkssk-class.
      pm_status = cl_statusf.
      mafid     = mafido.
      g_consistency_chk = kreuz.
      clear cl_status_neu.
      perform status_check using gt_tmpkssk-klart.
      if cl_status_neu is initial.
*       status remains
      else.
*       update status to 5
        klastab-statu = cl_statusus.
        modify klastab transporting statu
                       where objek = gt_tmpkssk-objek.
        allkssk-statu = cl_statusus.
        modify allkssk transporting statu
                       where objek = gt_tmpkssk-objek.
        message w500 with gt_tmpkssk-objek.
      endif.
    endloop.

    read table gt_tmpkssk with key objek = l_object_save.
    if sy-subrc = 0.
*     open val. subscreen for current object
      pm_objek  = gt_tmpkssk-objek.
      pm_inobj  = gt_tmpkssk-cuobj.
      pm_class  = gt_tmpkssk-class.
      pm_status = cl_statusf.
      mafid     = mafido.
      perform classify.
    endif.

    refresh gt_tmpkssk.
    clear   gt_tmpkssk.

  else.
*   CL20N, CL22N,  object transcations
    if g_klastab_akt_index > 0.
*     l_klastab_akt_index = g_klastab_akt_index. "n_979874   "n_1139067
*     while l_klastab_akt_index > 0.             "n_979874   "n_1139067
*     perform auswahl using antwort g_klastab_akt_index.
      perform auswahl using antwort g_klastab_akt_index.     "n_1139067
*perform auswahl using antwort l_klastab_akt_index. "n_979874"n_1139067
      if antwort is initial.
        perform classify.
      endif.
*      l_klastab_akt_index = l_klastab_akt_index - 1."n_979874"n_1139067
*      endwhile.                                     "n_979874"n_1139067
    endif.
  endif.

endform.                               " OK_EINT
