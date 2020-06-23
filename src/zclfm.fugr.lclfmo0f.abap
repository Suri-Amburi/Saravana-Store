*------------------------------------------------------------------*
*       MODULE SET_PFSTATUS OUTPUT                                 *
*------------------------------------------------------------------*
*       Setzen Status und TITLEBAR für alle Dynpros                *
*------------------------------------------------------------------*
module set_pfstatus output.

  data: lv_subrc            type syst_subrc,
        lt_pfstatus_ex      like ex_pfstatus occurs 1 with header line.

  case syst-dynnr.

    when dynp1100.
*--   CL-TA: Objekt zu Klassen
      if g_sel_changed <> space.
        call function 'DEQUEUE_ALL'.
        ex_pfstatus1v-func = ok_cls_stack.
        append ex_pfstatus1v.
      endif.
      if g_val-objek = space.
*       no valuation subscreen
        set pf-status pfstatd1100 excluding ex_pfstatus1v.
      else.
        set pf-status pfstatd1100 excluding ex_pfstatus1.
      endif.

      if classif_status = drei.
        set titlebar title030 with text-001.
      else.
        set titlebar title030 with text-002.
      endif.

      if rmclf-matnr is not initial.
*       CALL BADI BADI_RETAIL_GENERIC_ART_CLASSF
*       This internal single implementation BADI is only relevant in case of a retail generic article
*       The retail specific implementaion is located in S4CORE
        try.
            get badi gr_ret_gen_art_badi.

            if gr_ret_gen_art_badi is bound.
*             Method CHECK_INPUT_FOR_RETAIL if the action would have an impact on retail generic articles and variants
              call badi gr_ret_gen_art_badi->check_input_for_retail
                exporting
                  is_rmclf = rmclf
                receiving
                  r_result = lv_subrc.
            endif.

          catch cx_badi_not_implemented
                cx_badi_multiply_implemented
                cx_sy_dyn_call_illegal_method
                cx_badi_unknown_error.
        endtry.
*       In case the result of the method returns a sy-subrc <> 0 means a retail article or variant was entered at UI.
*       In this case disable the menu entries "New assignments" or "Delete"
        if lv_subrc <> 0.
          lt_pfstatus_ex-func = okneuz.
          append lt_pfstatus_ex.
          lt_pfstatus_ex-func = okloes.
          append lt_pfstatus_ex.
          set pf-status pfstatd1100 excluding lt_pfstatus_ex.
        endif.
      endif.

    when dynp1101.
*--   Aufruf aus Objekt-Transaktion
      set pf-status pfstatd1101 excluding ex_pfstatus1.
      set titlebar title011 with  <cua>.

    when dynp1102.
*--   Aufruf aus Objekt-Transaktion, nur Subscreen Bewertung
      set pf-status pfstatd1102 excluding ex_pfstatus1.
      set titlebar title011 with  <cua>.

    when dynp1110.
      if g_sel_changed <> space.
        call function 'DEQUEUE_ALL'.
      endif.
      if g_zuord = c_zuord_4.
*--     CL-TA: Objekte einer Klasse
        if classif_status = c_display.
          if g_val-objek = space.
            set pf-status pfstatd1110 excluding ex_pfstatusv.
          else.
            set pf-status pfstatd1110 excluding ex_pfstatus.
          endif.
          set titlebar title034 with text-001.
        else.
          if g_alloc_dynnr = dynp1511 or
             g_alloc_dynnr = dynp1611.
*         overview subscreen
            clear g_cls_scr.
            clear g_obj_scr.
            if g_val-objek = space.
              set pf-status pfstatd1110 excluding ex_pfstatusv.
            else.
              set pf-status pfstatd1110 excluding ex_pfstatus.
            endif.
          else.
*         subscreen objects/classes
            if g_val-objek = space.
              set pf-status pfstatd1512 excluding ex_pfstatusv.
            else.
              set pf-status pfstatd1512 excluding ex_pfstatus.
            endif.
          endif.
          set titlebar title034 with text-002.
        endif.

      elseif g_zuord = c_zuord_2.
*--     CL-TA: Klasse zu Klassen
        if g_val-objek = space.
*         no valuation subscreen
          set pf-status pfstatd1100 excluding ex_pfstatus1v.
        else.
          set pf-status pfstatd1100 excluding ex_pfstatus1.
        endif.
        if classif_status = drei.
          set titlebar title032 with text-001.
        else.
          set titlebar title032 with text-002.
        endif.
      endif.

*----------------------------------------------------------------------

    when dy500.
      if not g_cl_ta is initial.
*-- Aufruf aus CL-Transaktion: "Übersicht" statt "N.Bild"
        if classif_status eq c_display.
*-- ... Anzeige
          set pf-status pfstatd500cldis excluding ex_pfstatus1.
        else.
          set pf-status pfstatd500cl excluding ex_pfstatus1.
        endif.
      else.
*-- Aufruf aus einer anderen Transaktion heraus: "N.Bild"
        if classif_status eq c_display.
          set pf-status pfstatd500dis   excluding ex_pfstatus1.
        else.
          set pf-status pfstatd500   excluding ex_pfstatus1.
        endif.
      endif.
      if g_zuord eq c_zuord_0.
        if classif_status = drei.
          set titlebar title001 with  <length> text-001.
        else.
          set titlebar title001 with  <length> text-002.
        endif.
      else.
        set titlebar title011 with  <cua>.
      endif.

    when dy510.
      g_cls_scr = kreuz.
      set pf-status pfstatd510 excluding ex_pfstatus.
      if classif_status = drei.
        set titlebar title007 with text-001.
      else.
        set titlebar title007 with text-002.
      endif.

    when dy511.
      if classif_status = drei.
        set pf-status pfstatd511dis excluding ex_pfstatus.
        set titlebar title006 with text-001.
      else.
        set pf-status pfstatd511 excluding ex_pfstatus.
        set titlebar title006 with text-002.
      endif.

    when dy512.
      g_obj_scr = kreuz.
      set pf-status pfstatd512 excluding ex_pfstatus.
      if classif_status = drei.
        set titlebar title003 with <length> text-001.
      else.
        set titlebar title003 with <length> text-002.
      endif.

    when dy520.
      sokcode = 'EINT'.            "geändert ST 4.6A
      if classif_status = drei.
        set titlebar title016.
      else.
        set titlebar title015.
      endif.
* >>> Retail Cloud Enablement
* Exclude Graphic in case of WEBGUI
      CALL METHOD cl_gfw_products=>get_frontend
        IMPORTING
          platform = g_platform.
      IF g_platform = cl_gfw_products=>co_its.
        ex_pfstatus-func = okhclg. APPEND ex_pfstatus.
        ex_pfstatus-func = okuclg. APPEND ex_pfstatus.
        ex_pfstatus-func = okxclg. APPEND ex_pfstatus.
      ENDIF.
*     Check if the system is a cloud system
      TRY.
          IF gr_badi IS NOT BOUND.
            GET BADI gr_badi.
          ENDIF.
          IF gr_badi IS BOUND.
            CALL BADI gr_badi->is_cloud
              RECEIVING
                rv_is_cloud = gv_s4h_is_cloud.
          ENDIF.
        CATCH cx_badi_not_implemented
          cx_badi_multiply_implemented
          cx_sy_dyn_call_illegal_method
          cx_badi_unknown_error.
      ENDTRY.
      IF gv_s4h_is_cloud = abap_false.
        SET PF-STATUS pfstatd520 EXCLUDING ex_pfstatus.
      ELSE.
        SET PF-STATUS pfstatd520_rtc EXCLUDING ex_pfstatus.
      ENDIF.
* <<< Retail Cloud Enablement
    when dy600.
      set pf-status pfstatd600.
      if g_first_chg_scr = kreuz.
        set titlebar title019.
      else.
        set titlebar title018.
      endif.
    when dy601.
      set pf-status pfstatd601.
      set titlebar title010.
    when dy602.
      set pf-status pfstatd602.
      set titlebar title008.
    when dy603.
      set pf-status pfstatd603.
      set titlebar title012.
    when dy604.
      set pf-status pfstatd604.
      set titlebar title017.
    when dy605.
      set pf-status pfstatd605.
      set titlebar title020.
  endcase.
endmodule.
