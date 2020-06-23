*§-----------------------------------------------------------------*
*        Form  REK_STUECKLISTEN                                    *
*------------------------------------------------------------------*
form rek_stueckliste using init         type c
                           klart        like rmclf-klart
                           class        like rmclf-clasn
                           rmclf_matnr  type rmclf-matnr
                           uclass       like klah-class
                           syst_subrc   like syst-subrc.

  data: flg_ini like csdata-xfeld.

  data: begin of cltab occurs 1,
          class like klah-class,
        end of cltab.

  if rmclf_matnr is initial and uclass is initial.
    clear syst-subrc.
    exit.
  endif.
  cltab-class = class.
  append cltab.
  flg_ini = init.
  call function 'CS_RC_RECURSIVITY_CHECK'                   "#EC EXISTS
       exporting
            eclass            = uclass
            eidnrk            = rmclf_matnr
            eklart            = klart
            emode             = '2'
            erekrs            = space
            flg_init          = flg_ini
       importing
            astlnr            = stueli
       tables
            headertab         = cltab
       exceptions
            call_invalid      = 1
            recursivity_found = 2.
  syst_subrc = syst-subrc.

endform.                    "rek_stueckliste
