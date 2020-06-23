*----------------------------------------------------------------------*
*       FORM READ_KSSK_ASSIGNMENTS
*----------------------------------------------------------------------*
* Es wird die Tabelle IKSSK mit allen Zuordnungen des
* referenzierten Objekts erstellt
*
* Mit Aenderungsnummer:
* i_r_aennr wird nicht verwendet
* i_r_datuv <> Tagesdatum :
* in CLSE-Select_kssk_0 wird erst ohne Datum selektiert
* und dann mit kssk-datuv > Key_date nachselektiert.
*
* Fall: In CLFM_O_CL ist Aennr mitgegeben, aber Klassenart ist
*       nicht für Aend.dienst zugelassen.
*       Dann werden die richtigen Saetze (datuv=000000) selektiert.
*       Also braucht nicht extra geprüft zu werden, ob die
*       Klassenart für Aend.dienst zugelassen ist !
*----------------------------------------------------------------------*
form read_kssk_assignments using value(i_table)
                                 value(i_r_obj)
                                 value(i_r_cuobj)
                                 value(i_r_datuv)
                                 value(i_r_aennr).

  field-symbols:
    <l_kssk>          like rmclkssk.

* do not consider CLFM-buffer with allocations
  call function 'CLSE_CLFM_BUF_FLAGS'
       exporting
            i_ausp_flg = g_buffer_clse_active
            i_kssk_flg = space
       exceptions
            others     = 1.

  describe table rklart lines syst-tfill.
  if syst-tfill > 0.
*-- Zu dem Referenzobjekt gibt es Klassenzuordnungen ohne MULTOBJ
    export rklart to memory id 'CL20'.
    call function 'CLSE_SELECT_KSSK_0'
         exporting
              impklart       = kreuz
              mafid          = mafido
              objek          = i_r_obj
              refresh        = kreuz
              key_date       = i_r_datuv
         tables
              exp_kssk       = ikssk
         exceptions
              no_entry_found = 01.
  endif.

  if i_r_cuobj is initial.
*-- Falls das Objekt in mehreren Klassenarten klassifiziert ist, kann
*-- es ja Klassenarten mit und ohne INOB-Verschlüsselung geben
    describe table xklart lines syst-tfill.
    if syst-tfill > 0.
*     Klassenarten mit multobj = x                           " 765409
      all_multi_obj  = kreuz.
      loop at xklart.
*-- Lesen der INOBs zu jeder KLassenart mit MULTOBJ
        call function 'CUOB_GET_NUMBER'
             exporting
                  class_type       = xklart-low
                  object_id        = i_r_obj
                  table            = i_table
             importing
                  object_number    = klartino-cuobj
             exceptions
                  lock_problem     = 01
                  object_not_found = 02.
        if syst-subrc = 2.
          continue.
        endif.
        klartino-klart = xklart-low.
        append klartino.
        pm_objek  = klartino-cuobj.
        call function 'CLSE_SELECT_KSSK_0'
             exporting
                  add_kssk       = kreuz
                  klart          = xklart-low
                  mafid          = mafido
                  objek          = pm_objek
                  key_date       = i_r_datuv
             tables
                  exp_kssk       = ikssk
             exceptions
                  no_entry_found = 01.
      endloop.
      sort klartino by klart.
    endif.

  else.
*-- I_R_CUOBJ ist übergeben worden, muß nicht mehr ermittelt werden
    call function 'CUOB_GET_OBJECT'
         exporting
              object_number = i_r_cuobj
         importing
              class_type    = klartino-klart
              object_id     = i_r_obj
         exceptions
              not_found     = 01.
    if syst-subrc = 0.
      all_multi_obj  = kreuz.
      klartino-cuobj = i_r_cuobj.
      append klartino.
      pm_objek  = klartino-cuobj.
      call function 'CLSE_SELECT_KSSK_0'
           exporting
                add_kssk       = kreuz
                klart          = klartino-klart
                mafid          = mafido
                objek          = pm_objek
                key_date       = i_r_datuv
           tables
                exp_kssk       = ikssk
           exceptions
                no_entry_found = 01.
    endif.
  endif.

* no data on DB, but perhaps temp. allocations
  loop at allkssk assigning <l_kssk>
                  where objek = i_r_obj
                    and mafid = mafido.
    if <l_kssk>-cuobj is initial.
      read table ikssk with key objek = <l_kssk>-objek
                                mafid = <l_kssk>-mafid
                                klart = <l_kssk>-klart
                                clint = <l_kssk>-clint.
      if sy-subrc > 0.                                      " 765409
        if not rklart[] is initial and
           <l_kssk>-klart in rklart.
          move-corresponding <l_kssk> to ikssk.
          append ikssk.
        endif.
      endif.
    else.
      read table ikssk with key objek = <l_kssk>-cuobj
                                clint = <l_kssk>-clint.
      if sy-subrc > 0.
        if not xklart[] is initial and
           <l_kssk>-klart in xklart.
          move-corresponding <l_kssk> to ikssk.
          ikssk-objek = <l_kssk>-cuobj.
          append ikssk.
        endif.
      endif.
    endif.
  endloop.

* reset buffer flags
  call function 'CLSE_CLFM_BUF_FLAGS'
       exporting
            i_ausp_flg = g_buffer_clse_active
            i_kssk_flg = g_buffer_clse_active
       exceptions
            others     = 1.

endform.
