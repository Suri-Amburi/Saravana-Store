*&---------------------------------------------------------------------*
*&      Form  STATUS_CHK_INSERT
*&---------------------------------------------------------------------*
*       Es wird - vor dem buchen- nochmals die Konsistenz der
*       Klassenzuordnungen und Bewertungen geprüft
*----------------------------------------------------------------------*
form status_chk_insert using p_status like rmclkssk-statu.

*-- Prüfung auf gleiche Klassifizierung, falls erforderlich  "31I
  if not aenderflag is initial or                           "31I
     not kssk_update is initial.                            "31I

    loop at allkssk where ( praus eq konst_e                "31I
                      or    praus eq konst_w )              "31I
                     and  statu eq p_status                 "31I
                     and  mafid eq mafido.                  "31I
      if g_zuord = space.
*       check only object called with CLFM_OBJECT_CL
        if allkssk-objek <> pm_objek.
          continue.
        endif.
      else.
        pm_objek = allkssk-objek.                           "31I
      endif.
      pm_class = allkssk-class.                             "31I
      pm_inobj = allkssk-cuobj.                             "31I
      mafid    = allkssk-mafid.                             "31I
      sobtab   = allkssk-obtab.                             "31I
      klas_pruef = allkssk-praus.
      clear cl_status_neu.                                  "31I
      g_consistency_chk = kreuz.
      perform status_check using allkssk-klart.
      if not cl_status_neu is initial
         and allkssk-praus eq konst_e .
*-- STATUS UMSETZEN                                          "31I
** VBKZ = C_INSERT: has ever been kept.
** VBKZ = C_DELETE: keep it, else update termination.
** VBKZ = C_UPDATE: no need to change to C_UPDATE.
** VBKZ = SPACE:    by now unchanged alloc, set C_UPDATE.
        if allkssk-vbkz eq space.
          allkssk-vbkz = c_update.                          "31I
        endif.
        allkssk-statu = cl_status_neu.                      "31I
        modify allkssk.                                     "31I
      endif.                                                "31I
    endloop.                                                "31I
  endif.                                                    "31I

endform.                               " STATUS_CHK_INSERT
