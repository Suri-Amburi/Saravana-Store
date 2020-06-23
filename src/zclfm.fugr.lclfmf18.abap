*---------------------------------------------------------------------*
*       FORM OKB_AEDI                                                  *
*---------------------------------------------------------------------*
*       Änderungsnummernpop-up anfordern                              *
*---------------------------------------------------------------------*
form okb_aedi.

  if rmclf-aennr1 <> space.
    set parameter id c_param_aen field rmclf-aennr1.
    call transaction 'CC03' with authority-check               "1909745
                            and skip first screen.
  endif.

endform.
