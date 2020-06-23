*----------------------------------------------------------------------
*       FORM FUELLEN_VIEW_AUSP_FROM_HAUSP
*----------------------------------------------------------------------
*       Füllen der AUSP-Views
*----------------------------------------------------------------------
form fuellen_view_ausp_from_hausp.

*--------------------------------------------
*   call BADI to signal classification change
    cl_clf_dep_fields=>adjust_dependent_fields(
      CHANGING
        ct_ausp_insert = hausp[] ).

    if not gv_num_badi_clf_update_impl is initial.
      call badi gr_badi_clf_update->before_update
        exporting
          it_ausp_insert    = hausp[].
    endif.
*--------------------------------------------

  loop at hausp.
    if hausp-atwrt is initial and hausp-atflv is initial and
       hausp-atflb is initial.
      append hausp to hausp1.
      continue.
    endif.
    if hausp-atwrt is initial and hausp-atflb is initial and
       hausp-atflv < 0.
      if hausp-aennr is initial.
        move-corresponding hausp to auspnv3.
        append auspnv3.
      else.
        move-corresponding hausp to auspnv4.
        append auspnv4.
      endif.
      continue.
    endif.
    if hausp-atwrt is initial.
      if hausp-atflb is initial.
        if hausp-aennr is initial.
          move-corresponding hausp to auspnv1.
          append auspnv1.
        else.
          move-corresponding hausp to auspnv2.
          append auspnv2.
        endif.
      else.
        if hausp-aennr is initial.
          move-corresponding hausp to auspnv3.
          append auspnv3.
        else.
          move-corresponding hausp to auspnv4.
          append auspnv4.
        endif.
      endif.
    else.
      if not hausp-attlv is initial.
        move-corresponding hausp to auspcv3.
        append auspcv3.
      else.
        if hausp-aennr is initial.
          move-corresponding hausp to auspcv1.
          append auspcv1.
        else.
          move-corresponding hausp to auspcv2.
          append auspcv2.
        endif.
      endif.
    endif.
  endloop.
  refresh hausp.
endform.                    "FUELLEN_VIEW_AUSP_FROM_HAUSP

*----------------------------------------------------------------------
*       FORM INSERT_AUSP
*----------------------------------------------------------------------
*       Verbuchen AUSP mit Views
*----------------------------------------------------------------------
form insert_ausp.
  read table hausp1 index 1.
  if syst-subrc = 0.
    if dupl = kreuz.
      insert ausp client specified from table hausp1
                         accepting duplicate keys.
    else.
      insert ausp client specified from table hausp1.
      if syst-subrc ne 0.
        message a585 with tabausp.
      endif.
    endif.
    refresh hausp1.
  endif.
  read table auspcv1 index 1.
  if syst-subrc = 0.
    if dupl = kreuz.
      insert auspc_v1 client specified from table auspcv1
                             accepting duplicate keys.
    else.
      insert auspc_v1 client specified from table auspcv1.
      if syst-subrc ne 0.
        message a585 with tabausp.
      endif.
    endif.
    refresh auspcv1.
  endif.
  read table auspcv2 index 1.
  if syst-subrc = 0.
    if dupl = kreuz.
      insert auspc_v2 client specified from table auspcv2
                             accepting duplicate keys.
    else.
      insert auspc_v2 client specified from table auspcv2.
      if syst-subrc ne 0.
        message a585 with tabausp.
      endif.
    endif.
    refresh auspcv2.
  endif.
  read table auspcv3 index 1.
  if syst-subrc = 0.
    if dupl = kreuz.
      insert auspc_v3 client specified from table auspcv3
                             accepting duplicate keys.
    else.
      insert auspc_v3 client specified from table auspcv3.
      if syst-subrc ne 0.
        message a585 with tabausp.
      endif.
    endif.
    refresh auspcv3.
  endif.
  read table auspnv1 index 1.
  if syst-subrc = 0.
    if dupl = kreuz.
      insert auspn_v1 client specified from table auspnv1
                             accepting duplicate keys.
    else.
      insert auspn_v1 client specified from table auspnv1.
      if syst-subrc ne 0.
        message a585 with tabausp.
      endif.
    endif.
    refresh auspnv1.
  endif.
  read table auspnv2 index 1.
  if syst-subrc = 0.
    if dupl = kreuz.
      insert auspn_v2 client specified from table auspnv2
                             accepting duplicate keys.
    else.
      insert auspn_v2 client specified from table auspnv2.
      if syst-subrc ne 0.
        message a585 with tabausp.
      endif.
    endif.
    refresh auspnv2.
  endif.
  read table auspnv3 index 1.
  if syst-subrc = 0.
    if dupl = kreuz.
      insert auspn_v3 client specified from table auspnv3
                             accepting duplicate keys.
    else.
      insert auspn_v3 client specified from table auspnv3.
      if syst-subrc ne 0.
        message a585 with tabausp.
      endif.
    endif.
    refresh auspnv3.
  endif.
  read table auspnv4 index 1.
  if syst-subrc = 0.
    if dupl = kreuz.
      insert auspn_v4 client specified from table auspnv4
                             accepting duplicate keys.
    else.
      insert auspn_v4 client specified from table auspnv4.
      if syst-subrc ne 0.
        message a585 with tabausp.
      endif.
    endif.
    refresh auspnv4.
  endif.
endform.                    "INSERT_AUSP

*----------------------------------------------------------------------
*       FORM FUELLEN_VIEW_AUSP_FROM_VAUSP
*----------------------------------------------------------------------
*       Füllen der AUSP-Views
*----------------------------------------------------------------------
form fuellen_view_ausp_from_vausp.

*--------------------------------------------
*   call BADI to signal classification change
    cl_clf_dep_fields=>adjust_dependent_fields(
      CHANGING
        ct_ausp_update = vausp[] ).

    if not gv_num_badi_clf_update_impl is initial.
      call badi gr_badi_clf_update->before_update
        exporting
          it_ausp_update    = vausp[].
    endif.
*--------------------------------------------

  loop at vausp.
    if vausp-atwrt is initial.
*     numerical characteristics
      if vausp-atflv is initial and vausp-atflb is initial.
*       no values at all
        append vausp to vausp1.
      else.
        if vausp-aennr is initial.
          move-corresponding vausp to auspnv3.
          append auspnv3.
        else.
          move-corresponding vausp to auspnv4.
          append auspnv4.
        endif.
      endif.
    else.
*     character characteristics
      if vausp-attlv is initial.
        if vausp-aennr is initial.
          move-corresponding vausp to auspcv1.
          append auspcv1.
        else.
          move-corresponding vausp to auspcv2.
          append auspcv2.
        endif.
      else.
        move-corresponding vausp to auspcv3.
        append auspcv3.
      endif.
    endif.
  endloop.
  refresh vausp.

endform.                    "FUELLEN_VIEW_AUSP_FROM_VAUSP

*----------------------------------------------------------------------
*       FORM UPDATE_AUSP
*----------------------------------------------------------------------
*       Verbuchen AUSP mit Views
*----------------------------------------------------------------------
form update_ausp.
  read table vausp1 index 1.
  if syst-subrc = 0.
    update ausp client specified from table vausp1.
    if syst-subrc ne 0.
      message a586 with tabausp.
    endif.
    refresh vausp1.
  endif.
  read table auspcv1 index 1.
  if syst-subrc = 0.
    update auspc_v1 client specified from table auspcv1.
    if syst-subrc ne 0.
      message a586 with tabausp.
    endif.
    refresh auspcv1.
  endif.
  read table auspcv2 index 1.
  if syst-subrc = 0.
    update auspc_v2 client specified from table auspcv2.
    if syst-subrc ne 0.
      message a586 with tabausp.
    endif.
    refresh auspcv2.
  endif.
  read table auspcv3 index 1.
  if syst-subrc = 0.
    update auspc_v3 client specified from table auspcv3.
    if syst-subrc ne 0.
      message a586 with tabausp.
    endif.
    refresh auspcv3.
  endif.
  read table auspnv1 index 1.
  if syst-subrc = 0.
    update auspn_v1 client specified from table auspnv1.
    if syst-subrc ne 0.
      message a586 with tabausp.
    endif.
    refresh auspnv1.
  endif.
  read table auspnv2 index 1.
  if syst-subrc = 0.
    update auspn_v2 client specified from table auspnv2.
    if syst-subrc ne 0.
      message a586 with tabausp.
    endif.
    refresh auspnv2.
  endif.
  read table auspnv3 index 1.
  if syst-subrc = 0.
    update auspn_v3 client specified from table auspnv3.
    if syst-subrc ne 0.
      message a586 with tabausp.
    endif.
    refresh auspnv3.
  endif.
  read table auspnv4 index 1.
  if syst-subrc = 0.
    update auspn_v4 client specified from table auspnv4.
    if syst-subrc ne 0.
      message a586 with tabausp.
    endif.
    refresh auspnv4.
  endif.
endform.                    "UPDATE_AUSP
