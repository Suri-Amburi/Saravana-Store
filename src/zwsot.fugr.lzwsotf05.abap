*----------------------------------------------------------------------*
***INCLUDE LWSOTF05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  listing_sales_check_multiple
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_pt_wlk1  text
*      -->P_PI_MATNR  text
*      -->P_PI_WERKS  text
*      -->P_PI_VKORG  text
*      -->P_PI_VTWEG  text
*      -->P_PI_DATAB  text
*      -->P_PI_DATBI  text
*      -->P_PI_CHECK_LISTING  text
*      -->P_PI_CHECK_SALES  text
*      <--P_WLK2_OUT  text
*----------------------------------------------------------------------*
FORM listing_sales_check_multiple
     TABLES   PT_WLK1         STRUCTURE wlk1
     USING    P_MATNR         type matnr
              P_WERKS         type werks_d
              P_DATAB         type wlk1-datab
              P_DATBI         type wlk1-datbi
              P_CHECK_LISTING type WTDY-TYP01
              P_CHECK_SALES   type WTDY-TYP01
     CHANGING P_VKORG         type vkorg
              P_VTWEG         type vtweg
              P_WLK2_OUT.


* call new FORM (listing_sales_check_mult2) below, but set the new control parameter
* for usage of plant specific buffer by default to true as it was originally:
  perform listing_sales_check_mult2
          tables   pt_wlk1
          using    p_matnr
                   p_werks
                   p_datab
                   p_datbi
                   p_check_listing
                   p_check_sales
                   abap_true
          changing p_vkorg
                   p_vtweg
                   p_wlk2_out.

endform.                    " listing_sales_check_multiple


form listing_sales_check_mult2
     tables   pt_wlk1               structure wlk1
     using    p_matnr               type matnr
              p_werks               type werks_d
              p_datab               type wlk1-datab
              p_datbi               type wlk1-datbi
              p_check_listing       type wtdy-typ01
              p_check_sales         type wtdy-typ01
              pi_werks_buffer_use   type mtcom-kzrfb
     changing p_vkorg               type vkorg
              p_vtweg               type vtweg
              p_wlk2_out.

  data ht_wlk1           type wlk1 occurs 0.
  data ht_wlk1_exclusion type wlk1 occurs 0.
  data h_wlk1            type wlk1.
  data h_wlk1_exclusion  type wlk1.
  data h_t001w           type t001w.
  data h_wpwlk2          type wpwlk2.
  data sales_entry_found(1).

  data ht_wrs1     type  table of wrs1.                     " 601878
  data h_wrs1      type  wrs1.                              " 601878
  data ht_wlk1_loc type  table of wlk1.                     " 601878



*  if p_vkorg is initial                                    " 601878
*  or p_vtweg is initial.                                   " 601878
  call function 'T001W_SINGLE_READ'
    exporting
      t001w_werks = p_werks
    importing
      wt001w      = h_t001w
    exceptions
      not_found   = 1
      others      = 2.
  if sy-subrc = 0.
    if p_vkorg is initial                                   " 601878
    or p_vtweg is initial.                                  " 601878
      p_vkorg = h_t001w-vkorg.
      p_vtweg = h_t001w-vtweg.
    endif.                                                  " 601878
  else.
    exit.
  endif.
*  endif.                                                   " 601878

* read wlk2 data
  if not p_check_sales is initial.
    perform read_wlk2_entry using    p_matnr
                                     p_vkorg
                                     p_vtweg
                                     p_werks
                                     p_datab
                                     p_datbi
                                     pi_werks_buffer_use
                            changing h_wpwlk2
                                     sy-subrc.
    if sy-subrc = 0.
      move-corresponding h_wpwlk2 to p_wlk2_out.
      sales_entry_found = 'X'.
    endif.
  endif.


************************************************************************
* read listing conditions
  if not p_check_listing is initial.
* begin of note 601878
    call function 'ASSORTMENT_GET_ASORT_OF_USER'
      exporting
        user            = h_t001w-kunnr
        user_type       = h_t001w-vlfkz
      tables
        assortment_data = ht_wrs1
      exceptions
        no_asort_found  = 1
        others          = 2.
    loop at ht_wrs1 into h_wrs1.
      h_wlk1-filia = h_wrs1-asort.
      h_wlk1-artnr = p_matnr.
      clear h_wlk1-datab.
      clear h_wlk1-datbi.
      call function 'WLK1_READ_MULTIPLE_FUNCTIONS'
        exporting
          wlk1_single_select = h_wlk1
          function           = 'H'
        tables
          wlk1_results       = ht_wlk1_loc
        exceptions
          no_rec_found       = 1
          others             = 2.
      if sy-subrc = 0.
        append lines of ht_wlk1_loc to ht_wlk1.
      endif.
    endloop.
* end of note 601878

    loop at ht_wlk1 into h_wlk1.
      if h_wlk1-negat = x.
        delete ht_wlk1 index sy-tabix.
        if h_wlk1-datbi > p_datab.
* Sammeln der Exclusionssätze in ht_wlk1_exclusion
          append h_wlk1 to ht_wlk1_exclusion.
        endif.
      endif.
    endloop.                                                "HT_WLK1

    describe table ht_wlk1_exclusion lines z1.
    if z1 = 0.

************************************************************************
* es gibt keine Exclusion -> lese alle gültigen Sätze
************************************************************************

      loop at ht_wlk1 into h_wlk1.

        if h_wlk1-sstat = '5'.
          continue.
        else.

          if h_wlk1-datbi >= h_wlk1-datab and
             p_datab <= h_wlk1-datbi and
             p_datbi >= h_wlk1-datab.

            append h_wlk1 to pt_wlk1.
          endif.
        endif.                         " H_WLK1-sstat
      endloop.                                              " HT_WLK1

    else.
************************************************************************
* dann ist erhöhte Vorsicht geboten!
* man muß prüfen ob gültigen WLK1-Sätze nicht durch excludierende
* Sätze ungültig werden
* -> Vorsicht mit Zeitintervall; ggf. müssen manche WLK1-Sätze
* aufgeteilt werden.
************************************************************************
      sort ht_wlk1_exclusion ascending by datab.

      loop at ht_wlk1 into h_wlk1.

        if t_wlk1_input-sstat = '5'.
          continue.
        else.

          move-corresponding h_wlk1 to pt_wlk1.

          if h_wlk1-datbi < p_datab.
            " Satz war früher gelistet              .
          else.
            loop at ht_wlk1_exclusion into h_wlk1_exclusion
                  where datab <= h_wlk1-datbi and
                        datbi >= h_wlk1-datab.

              if h_wlk1-datab >= h_wlk1_exclusion-datab
                and h_wlk1-datbi <= h_wlk1_exclusion-datbi.
* WLK1-Eintrag ist komplett ungültig ->
* PET_LIST_KOND - Eintrag mit DATAB > DATBI (unschön, wird aber später
* wieder gelöscht)
                h_wlk1-datbi = h_wlk1_exclusion-datbi - 1.
                h_wlk1-datab = h_wlk1_exclusion-datbi.
                exit.
              elseif h_wlk1-datab < h_wlk1_exclusion-datab
                and h_wlk1-datbi >= h_wlk1_exclusion-datab
                and h_wlk1-datbi <= h_wlk1_exclusion-datbi.
* das 'Ende' des Eintrages ist ungültig -> DATBI zurücksetzen
                h_wlk1-datbi = h_wlk1_exclusion-datab - 1.

              elseif h_wlk1-datbi > h_wlk1_exclusion-datbi
                and h_wlk1-datab >= h_wlk1_exclusion-datab
                and h_wlk1-datab <= h_wlk1_exclusion-datbi.
* der 'Anfang' des Eintrages ist ungültig -> DATAB hochsetzen
                h_wlk1-datab = h_wlk1_exclusion-datbi + 1.

              elseif h_wlk1-datab < h_wlk1_exclusion-datab
                 and h_wlk1-datbi > h_wlk1_exclusion-datbi.
* ein 'Zwischenstück' des Eintrages ist ungültig
* -> 2 Sätze weitergeben
                move h_wlk1 to pt_wlk1.
                pt_wlk1-datbi = h_wlk1_exclusion-datab - 1.
                " Es wird überprüft, ob dieses Zwischenstück noch im
                " zu suchenden Bereich liegt.
                if p_datab <= pt_wlk1-datbi and
                   p_datbi >= pt_wlk1-datab.
                  append pt_wlk1.
                endif.

                h_wlk1-datab = h_wlk1_exclusion-datbi + 1.

              endif.
            endloop.                   " PET_LIST_KOND_NEG
          endif.
          if h_wlk1-datbi >= h_wlk1-datab and
             p_datab <= h_wlk1-datbi and
             p_datbi >= h_wlk1-datab.
            append h_wlk1 to pt_wlk1.
          endif.
        endif.                         " H_wlk1-sstat
      endloop.                                              " HT_WLK1
    endif.                                                  " Z1 = 0
  endif.                            " if not pi_check_listing is initial

* check, if no listing condition exists => wlk2 entry must be empty
  if not sales_entry_found is initial
     and not p_check_listing is initial.
    read table ht_wlk1 index 1 transporting no fields.
    if sy-subrc <> 0.
      clear p_wlk2_out.
    endif.
  endif.

endform.                    " listing_sales_check_mult2
