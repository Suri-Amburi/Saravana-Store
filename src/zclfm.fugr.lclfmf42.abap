*&---------------------------------------------------------------------*
*&      Form  close_prev_value_assmnt
*&---------------------------------------------------------------------*
*       Saves previous char. value assignment.
*       Always necessary after CTMS-DDB_OPEN.
*
*       g_subrc : 0  CTMS checks ok
*                 1  continue processing
*                    (user answerd yes, status changed)
*                 2  stop processing
*                    (user corrects value assignments)
*
*       Note 543914
*       Update classification status after valuation check:
*       old    test status  ->  new: check ok   not ok
*       ----------------------------------------------
*        1         1        ->          1         5
*        2         2        ->          2         -
*        3         3        ->          3         -
*        5         1        ->          1         5
*----------------------------------------------------------------------*
FORM close_prev_value_assmnt
     CHANGING p_subrc.

  DATA: l_text(60),
        l_objek             TYPE rmclkssk-objek,
        l_status            TYPE kssk-statu,
        l_status_new        TYPE kssk-statu,
        l_subrc             LIKE sy-subrc,
        l_tabix             TYPE sy-tabix,
        lv_msgty            TYPE sy-msgty,
        ls_allkssk          LIKE LINE OF allkssk,
        lr_ret_gen_art_badi TYPE REF TO badi_retail_generic_art_classf.

* test status for CTMS
  l_status = g_val-status.

  IF classif_status <> c_display.
    IF l_status = cl_statusus.
      READ TABLE xtclc WITH KEY klart = rmclf-klart
                                statu = cl_statusus.
      IF sy-subrc = 0 AND xtclc-clautorel = kreuz.
        l_status = cl_statusf.
      ENDIF.
    ENDIF.

* inform ctms about status of previous object
    CALL FUNCTION 'CTMS_DDB_SET_CLASSIF_STATUS'
      EXPORTING
        imp_status = l_status.

    IF g_ok_exit = kreuz OR
       g_val-status = cl_statusus OR
       ( pm_batch = kreuz AND nodisplay = kreuz ) OR
       p_subrc = 9.
*     prevent popups asking for valuations
*     e.g.: exit ok codes, delete an allocation
    ELSE.
*     req. characteristics without valuations:  popups
      CALL FUNCTION 'CTMS_DDB_EXECUTE_FUNCTION'
        EXPORTING
          okcode = ok_back.
    ENDIF.
  ENDIF.
  p_subrc = 0.

  CALL FUNCTION 'CTMS_DDB_CLOSE'
    TABLES
      exp_selection  = sel
    EXCEPTIONS
      inconsistency  = 1
      incomplete     = 2
      verification   = 3
      not_assigned   = 4
      another_object = 5
      other_objects  = 6
      display_mode   = 7
      OTHERS         = 8.
  l_subrc = sy-subrc.                                    "begin 1141059
  lv_msgty = sy-msgty.
  IF sokcode = okloes.
    CLEAR:
      l_subrc.
  ENDIF.
* in case of leaving the current classified object
* check all assigned classes, if there are other objects
* with the same classification
  IF ( l_subrc IS INITIAL OR
       ( ( l_subrc = 5 OR l_subrc = 6 ) AND
         lv_msgty NE 'E' ) ) AND
     g_zuord EQ c_zuord_0 AND
     ( pm_batch = space OR nodisplay = space ).
*   check ok-code should leave the current object
    IF sokcode EQ okende OR
       sokcode EQ okabbr OR
       sokcode EQ okleav OR
       sokcode EQ okweit OR
       sokcode EQ okvobi OR
       sokcode EQ oksave.
*     process all class assignments for the current object
      LOOP AT allkssk
           INTO ls_allkssk
           WHERE objek EQ rmclf-objek AND
                 klart EQ rmclf-klart AND
                 statu EQ cl_statusf AND
                 praus NE 'X' AND
                 vbkz NE c_delete.
        CHECK ls_allkssk-praus NE 'W' OR
              lv_msgty NE 'W'.
        CALL FUNCTION 'CTMS_DDB_CHECK'
          EXPORTING
            iv_check_valuation      = space
            iv_check_classification = 'X'
          CHANGING
*           RETURN_CODE             =
            cv_class                = ls_allkssk-class
          EXCEPTIONS
            another_object          = 5
            other_objects           = 6
            OTHERS                  = 8.
        IF NOT sy-subrc IS INITIAL.                         "1439654
          l_subrc = sy-subrc.                               "1439654
        ENDIF.                                              "1439654
        lv_msgty = sy-msgty.
        IF lv_msgty EQ 'E'.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.                                                   "end 1141059

  IF l_subrc = 0.
*   valuation okay: possibly status 5 -> 1
    IF g_val-status <> l_status.
      IF g_zuord = c_zuord_4.
        READ TABLE allkssk WITH KEY objek = g_val-objek.
      ELSE.
        READ TABLE allkssk WITH KEY objek = g_val-objek
                                    klart = rmclf-klart
                                    class = g_val-class.
      ENDIF.
      IF sy-subrc = 0.
        l_tabix      = sy-tabix.
        l_status_new = cl_statusf.
      ENDIF.
    ENDIF.
  ELSE.
*   valuation not okay: possibly status 1 -> 5
    IF g_zuord = c_zuord_4.
      READ TABLE allkssk WITH KEY objek = g_val-objek.
    ELSE.
      READ TABLE allkssk WITH KEY objek = g_val-objek
                                  klart = rmclf-klart
                                  class = g_val-class.
    ENDIF.
    IF sy-subrc = 0.
      l_tabix = sy-tabix.
      IF g_val-status = cl_statusf.
        l_status_new = cl_statusus.
      ENDIF.
      PERFORM cust_exit_charcheck
              USING  space             " not from API
                     l_subrc.
    ENDIF.

    IF NOT l_status_new IS INITIAL AND
      ( pm_batch = space OR nodisplay = space ).

      l_objek = g_val-objek.
      IF sokcode = okabbr OR
         sokcode = oknezu OR
         sokcode = okobwe OR
         sokcode = ok_cls_stack.
*       ok codes of type EXIT
        CASE l_subrc.
          WHEN 1.
            l_text = TEXT-133.
          WHEN 2 OR 4.
            l_text = TEXT-134.
          WHEN 5.
            l_text = TEXT-135.
          WHEN 6.
            l_text = TEXT-136.
          WHEN OTHERS.
            l_text = space.
        ENDCASE .
        IF l_text <> space.
          CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
            EXPORTING
              defaultoption  = 'N'
              diagnosetext1  = TEXT-130
              diagnosetext2  = l_objek
              diagnosetext3  = l_text
              textline1      = TEXT-131
              textline2      = TEXT-132
              titel          = sy-title
              start_column   = 25
              start_row      = 6
              cancel_display = space
            IMPORTING
              answer         = antwort.
          CASE antwort.
            WHEN ja.
              p_subrc = c_continue.
              gv_no_message = 'X'.                          "1436346

*             CALL BADI BADI_RETAIL_GENERIC_ART_CLASSF
*             This internal single implementation BADI is only relevant in case of a retail generic article
*             The retail specific implementaion is loated in S4CORE
              TRY.
                  GET BADI lr_ret_gen_art_badi.
*                 In case of a inconsistency related to retail generic article and it's variants the SAVE operation is prevented.
                  IF lr_ret_gen_art_badi IS BOUND.
                    CALL BADI lr_ret_gen_art_badi->prevent_save_inconsistent_data
                      CHANGING
                        cv_subrc = p_subrc.
                  ENDIF.
                  IF p_subrc = c_break.
                    EXIT.
                  ENDIF.

                CATCH cx_badi_not_implemented
                      cx_badi_multiply_implemented
                      cx_sy_dyn_call_illegal_method
                      cx_badi_unknown_error.
              ENDTRY.

            WHEN nein OR abbr.
              gv_no_message = 'X'.                          "1448144
              p_subrc = c_break.
              EXIT.
          ENDCASE.
        ENDIF.

      ELSE.
        CASE l_subrc.
          WHEN 1.
            MESSAGE ID syst-msgid TYPE 'E' NUMBER syst-msgno
                    WITH syst-msgv1.
          WHEN 2 OR 4.
            MESSAGE i500 WITH l_objek.
*           'Status changed: mand. chars without values'
          WHEN 5.      " another object                  "begin 1141059
            PERFORM clear_praus_error_level(saplctms).      "1747640
* If not ALLKSSK-VBKZ = space - create e.t.c check and message executing
* will done in subroutine SAVE_ALL. This correction protect double
* executing message C1 818.
            IF allkssk-vbkz = space OR allkssk-praus = konst_e. "2135839
              MESSAGE ID syst-msgid TYPE lv_msgty NUMBER 818
                      WITH syst-msgv1.
            ENDIF.                                          "2135839
          WHEN 6.     " other objects
            PERFORM clear_praus_error_level(saplctms).      "1747640
* If not ALLKSSK-VBKZ = space - create e.t.c check and message executing
* will done in subroutine SAVE_ALL. This correction protect double
* executing message C1 819.
            IF allkssk-vbkz = space OR allkssk-praus = konst_e. "2135839
              MESSAGE ID syst-msgid TYPE lv_msgty NUMBER 819
                    WITH syst-msgv1.                       "end 1141059
            ENDIF.                                          "21358391
          WHEN OTHERS.
            MESSAGE ID syst-msgid TYPE syst-msgty NUMBER syst-msgno
                    WITH syst-msgv1.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT l_status_new IS INITIAL.
*   change classification status to l_status_new (1 or 5)
    IF ( l_subrc = '5' OR l_subrc = '6' ) AND
       ( allkssk-praus = konst_w OR klas_pruef = konst_w ).
*       just warning for equal classification
*       keep status = 1
    ELSE.
      allkssk-statu = l_status_new.
      IF allkssk-vbkz IS INITIAL.
        allkssk-vbkz = c_update.
      ENDIF.
      MODIFY allkssk INDEX l_tabix TRANSPORTING statu vbkz.
      IF g_zuord = c_zuord_4.
        READ TABLE klastab WITH KEY objek = allkssk-objek.
      ELSE.
        READ TABLE klastab WITH KEY clint = allkssk-clint.
      ENDIF.
      IF sy-subrc = 0.
        klastab-statu = l_status_new.
        MODIFY klastab INDEX sy-tabix TRANSPORTING statu.
      ENDIF.
      g_val-status = l_status_new.
    ENDIF.
  ENDIF.

  IF g_build_allausp = kreuz.
    PERFORM build_allausp.
  ENDIF.

ENDFORM.                               " close_prev_value_assmnt
