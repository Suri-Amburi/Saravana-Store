*§-----------------------------------------------------------------*
*        FORM BUILD_ALLAUSP                                        *
*------------------------------------------------------------------*
*        Buffer table with characteristic values is build up:
*        table SEL (data from CTMS) -> table ALLAUSP
*------------------------------------------------------------------*
form build_allausp.

  data:
    l_adzhl           like ausp-adzhl,
    l_aennr           like ausp-aennr,
    l_atinn           like ausp-atinn,
    l_subrc           like sy-subrc,
    l_tabix           like sy-tabix,
    new_atzhl         type i.
  field-symbols:
    <lf_ausp>         like allausp.

  DATA: lv_subrc TYPE sy-subrc.                                "1529320
  DATA: ls_allausp TYPE rmclausp.                              "1736966
  DATA: lt_cabn like cabn occurs 0 with header line.           "2459614

  ranges: r_cabn for cabn-atinn.                               "2459614

* atcod = 0 entries control selection and are transient        v 1703651
* -> CLFM needs to ignore those entries
  DELETE sel WHERE atcod = '0'.                               "^ 1703651

* check if valuations are changed (statu = H/L)
  loop at sel transporting no fields
              where statu <> space.
    exit.
  endloop.

  if sy-subrc = 0.
    aenderflag = kreuz.
    if rmclf-klart <> tcla-klart.
      select single * from tcla where klart = rmclf-klart.
    endif.

    if tcla-ausp_new = kreuz.
*     table AUSP with new counter logic
      perform allausp_new.

    else.
      read table redun with key obtab = sobtab.
*     1. determine counter atzhl
*     do not sort sel now: initial atzhl not considered

      loop at sel where statu <> space.
        if not sel-attab is initial.
*         attab: master or text table, e.g. MARA or MAKT
          if not redun-redun = kreuz.
*           do not take over ref. characteristics
            clear sel-statu.
            modify sel transporting statu.
            continue.
          endif.
        endif.
        if sel-atzhl is initial and                            "1126765
           sel-statu <> loeschen.                              "1126765
          if sel-atinn = l_atinn.
            new_atzhl = new_atzhl + 1.
          else.
            l_atinn   = sel-atinn.
            new_atzhl = 1.
            l_tabix   = 1.
          endif.
          loop at allausp assigning <lf_ausp>
                          from l_tabix
                          where objek = pm_objek
                            and atinn = sel-atinn
                            and klart = rmclf-klart
                            and mafid = mafid.
            if new_atzhl < <lf_ausp>-atzhl.
*               gap found: take this new_atzhl
              l_tabix = sy-tabix.
              exit.
            else.
              if new_atzhl = <lf_ausp>-atzhl.
                new_atzhl = new_atzhl + 1.
              endif.
            endif.
          endloop.
          if new_atzhl < 1000.
            sel-atzhl = new_atzhl.
            modify sel transporting atzhl.
          else.
* more then 999 values for a multiple-value characteristic
            r_cabn-sign   = incl.                        "begin 2459614
            r_cabn-option = equal.
            r_cabn-low    = sel-atinn.
            append  r_cabn.
            CALL FUNCTION 'CLSE_SELECT_CABN'
              TABLES
                IN_CABN         = r_cabn
                T_CABN          = lt_cabn
              EXCEPTIONS
                NO_ENTRY_FOUND  = 00.
            delete sel.
            read table lt_cabn index 1.
            message e192 with lt_cabn-atnam.               "end 2459614
          endif.
        endif.                         " sel-atzhl
      endloop.                         " sel

*     2. take over changed valuations: sel -> allausp
      sort sel by atinn atzhl.
      loop at sel.
        clear allausp.
        read table allausp with key
                                objek = pm_objek
                                atinn = sel-atinn
                                atzhl = sel-atzhl
                                klart = rmclf-klart
                                mafid = mafid
                                binary search.
        lv_subrc = sy-subrc.                                   "1529320
        l_subrc = sy-subrc.
        l_tabix = sy-tabix.
        l_adzhl = allausp-adzhl.
        if sel-statu = loeschen.
*         delete valuation
          l_aennr = allausp-aennr.
        elseif sel-statu = hinzu.
*         new or changed valuation: add H-entry to ALLAUSP
*         change number to add in update task
          clear l_aennr.
          if l_subrc is initial.
*           This if-block is normally not entered.
*           Consider EHS (class type 100)
            if allausp-klart = '100'
               and G_FLG_EHS_MOD_ACTIVE = 'X'. "note 701214
              if not allausp-statu is initial and
                     allausp-statu <> hinzu.
                l_subrc = 4.
              endif.
            else.
              if allausp-statu <> hinzu.
                l_subrc = 4.
              endif.
            endif.
          endif.
        else.
*         valuation not changed, but allausp could be empty
          if l_subrc = 0.
*           compare current status of characteristic value
            if sel-statu EQ allausp-statu.               "begin 1254935
*             do nothing, in case of SEL and ALLAUSP are identical
              continue.
            endif.                                         "end 1254935
          endif.
          clear l_aennr.
        endif.

* A value is added that existed before, check wheter     "begin 1529320
* ATAUT has changed, if yes create delete entry in ALLAUSP
        IF l_subrc   =  4      AND
           lv_subrc  =  0      AND
           sel-statu =  hinzu  AND
           allausp-statu IS INITIAL AND
           sel-ataut NE allausp-ataut.
          allausp-statu = loeschen.
          MODIFY allausp INDEX l_tabix .
        ENDIF.                                             "end 1529320

        clear allausp.
        move-corresponding sel to allausp.
        allausp-objek = pm_objek.
        allausp-klart = rmclf-klart.
        allausp-mafid = mafid.
        allausp-obtab = sobtab.
        if not pm_inobj is initial.
          allausp-cuobj = pm_inobj.
        endif.
        if not l_aennr is initial.
          allausp-aennr = l_aennr.
          allausp-adzhl = l_adzhl.
        endif.
        if l_subrc = 0.
          modify allausp index l_tabix.
        else.
* Do not insert a new entry with statu H to allausp,     "begin 1736966
* if there is already the same entry with status SPACE
          IF l_subrc  =  4 AND
            lv_subrc  =  0 AND
            sel-statu =  hinzu.

             ls_allausp = allausp.
             CLEAR ls_allausp-statu.
             READ TABLE allausp FROM ls_allausp TRANSPORTING NO FIELDS.
             IF sy-subrc IS INITIAL.
               CONTINUE.
             ENDIF.

          ENDIF.                                           "end 1736966

          insert allausp index l_tabix.
        endif.
      endloop.                         " sel
    endif.                             " ausp_new
  else.
*   all changes rejected or no new changes               "begin 1426083
    loop at sel.
      clear allausp.
      read table allausp
           assigning <lf_ausp>
           with key objek = pm_objek
                    atinn = sel-atinn
                    atzhl = sel-atzhl
                    klart = rmclf-klart
                    mafid = mafid
           binary search.
      check sy-subrc is initial.
      check <lf_ausp>-statu eq loeschen.
*     characteristic value is selected, but ALLAUSP still has
*     the information for deletion -> delete all changes of this
*     characteristic and set the current value without STATU
      clear <lf_ausp>-statu.
      delete allausp
             where objek = pm_objek and
                   atinn = sel-atinn and
                   klart = rmclf-klart and
                   mafid = mafid and
                   atzhl <> sel-atzhl.
    endloop.                                               "end 1426083
  endif.                               " sy-subrc

* 3. check in opposite direction (nec. after build_sel_api):
* H-entries changed or removed ?
  loop at allausp assigning <lf_ausp>
                  where objek = pm_objek
                    and klart = rmclf-klart
                    and mafid = mafid
                    and statu = hinzu.
    read table sel transporting no fields
                   with key atinn = <lf_ausp>-atinn
                            atzhl = <lf_ausp>-atzhl
                            statu = hinzu.
    if sy-subrc <> 0.
*     keep a copy of deleted entries for later checks          v 1019672
*     on rejecting changes
      data: LT_ALLAUSP_OLD like ALLAUSP occurs 0 with header line,
            L_TABIX2       like SY-TABIX.
      LT_ALLAUSP_OLD = <LF_AUSP>.
      append LT_ALLAUSP_OLD.

      delete allausp.
      aenderflag = kreuz.
    endif.
  endloop.

* Begin of 1003665
  data: char_list like api_char occurs 0 with header line.

  sort LT_ALLAUSP_OLD by OBJEK ATINN KLART STATU.

* process only the object which is currently transferred
* from SEL (CTMS) to ALLAUSP
  read table REJECT_CHANGES with key
    OBJECT     = PM_OBJEK
    CLASS_TYPE = RMCLF-KLART.

  if SY-SUBRC is initial.
    perform CTMS_GET_CHARS_BY_VIEW(SAPLCTMS)
              tables char_list
              using  reject_changes-view.

    loop at char_list.
      read table allausp with key objek = reject_changes-object
                                  atinn = char_list-atinn
                                  klart = reject_changes-class_type
                                  statu = hinzu.
      if sy-subrc = 0.
        L_TABIX2 = SY-TABIX.
        read table LT_ALLAUSP_OLD
          with key OBJEK = REJECT_CHANGES-OBJECT
                   ATINN = CHAR_LIST-ATINN
                   KLART = REJECT_CHANGES-CLASS_TYPE
                   STATU = HINZU
          binary search.

        if SY-SUBRC is initial.
*         reject change at creation by reference
          ALLAUSP = LT_ALLAUSP_OLD.
          modify ALLAUSP index L_TABIX2.
        else.
*         reject change of an existing valuation
          delete allausp index L_TABIX2.
        read table allausp with key objek = reject_changes-object
                                    atinn = char_list-atinn
                                    klart = reject_changes-class_type
                                    statu = loeschen.
        if sy-subrc = 0.
          allausp-statu = space.
          modify allausp index sy-tabix.
          endif.
        endif.
      endif.
    endloop.
* End of 1003665
  endif.

  clear LT_ALLAUSP_OLD.
  clear LT_ALLAUSP_OLD[].                                     "^ 1019672

endform.                               " build_allausp

* Begin Correction 27.01.2004 0701214 *******************
*---------------------------------------------------------------------*
*       FORM FLAG_EHS_MOD_ACTIVE_SET                                  *
*---------------------------------------------------------------------*
FORM FLAG_EHS_MOD_ACTIVE_SET "#EC CALLED
* Purpose: Form to set the global flag G_FLG_EHS_MOD_ACTIVE (see the
*          comments at its declaration) via external PERFORM's (see
*          also note 701214).
     USING
        VALUE(I_FLAG_EHS_MOD_ACTIVE) TYPE C.
*       new value of the flag

* Function body -------------------------------------------------------
  G_FLG_EHS_MOD_ACTIVE = I_FLAG_EHS_MOD_ACTIVE.

ENDFORM.
* End Correction 27.01.2004 0701214 *********************
