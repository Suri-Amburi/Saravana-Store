*§-----------------------------------------------------------------*
*        FORM CHECK_STRUCTURE                                       *
*------------------------------------------------------------------*
*        Es wird geprüft, ob in der unterliegenden Zuordnung ein   *
*        Merkmal vorkommt, das von oben vererbt wurde. Wenn ja,    *
*        wird die Zuordnung nicht gelöscht.                        *
*
*        Diese form nicht von API's aus aufrufen, da g_zuord
*        dann unbekannt.
*------------------------------------------------------------------*
form check_structure using klart  like allkssk-klart
                           oclass like allkssk-class
                           oclint like allkssk-clint
                           uclass like allkssk-objek
                           uclint like allkssk-clint
                           rc     like syst-subrc
                           p_aennr like rmclf-aennr1
                           key_date like  RMCLF-DATUV1.      "897241


  data  : class          like rmclf-class,
          l_maint_ghcli  like sy-batch.

  if g_zuord = c_zuord_2.
*   CL22N: maintain table ghcli
    l_maint_ghcli = kreuz.
  endif.
  clear   rc.
  clear   inkonsi.
  clear   iatinn.
  refresh iatinn.
  class = uclass.

  call function 'CLFM_CHECK_STRUCTURE'
       exporting
            classtype       = klart
            oclass          = oclass
            oclint          = oclint
            uclass          = class
            uclint          = uclint
            i_aennr         = p_aennr
            key_date        = key_date                       "897241
            i_maint_ghcli   = l_maint_ghcli
       tables
            characteristics = iatinn
       exceptions
            inkonsistent    = 1
            used_in_ippe    = 2
            others          = 3.
  if sy-subrc > 0.
    rc = sy-subrc.
  endif.

endform.
