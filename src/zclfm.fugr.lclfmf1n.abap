*------------------------------------------------------------------*
*        FORM OHNE_BEWERTUNG                                       *
*------------------------------------------------------------------*
*        Klassifizierung ohne Bewertung                            *
*------------------------------------------------------------------*
form ohne_bewertung.

  data: l_klas_prf   like klah-praus .

  clear cl_status_neu.
  if allkssk-statu eq cl_statusf.
*   KLAS_PRUEF setzen wg. Status_check
    l_klas_prf = klas_pruef.
    klas_pruef = konst_w.
    g_consistency_chk = kreuz.
    perform status_check using allkssk-klart.
    klas_pruef = l_klas_prf.
*    if not cl_status_neu is initial.
*      check syst-subrc = 0.
*      allkssk-statu = cl_status_neu.
*      modify allkssk index g_allkssk_akt_index.
*    endif.
  endif.

endform.
