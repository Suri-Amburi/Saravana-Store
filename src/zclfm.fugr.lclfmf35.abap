*---------------------------------------------------------------------*
*       FORM SHOW_ALL_KSSK_FROM_OBJECT                                *
*---------------------------------------------------------------------*
*       Anzeige Klassifizierung mit anderen Klassenarten              *
*---------------------------------------------------------------------*
*  -->  MAFID                                                         *
*  -->  KLART                                                         *
*  -->  OBJECT                                                        *
*  -->  RC                                                            *
*---------------------------------------------------------------------*
form show_all_kssk_from_object using mafid  like mafido
                                     object like rmclf-objek
                                     rc     like syst-subrc
                                     eklart like kssk-klart.

  data: return.
  data: inobjnr      like inob-cuobj.


  call function 'CLCA_GET_CLASSTYPES_FROM_TABLE'
       EXPORTING
            table              = sobtab
            with_text          = space
       TABLES
            iklart             = iklart
       EXCEPTIONS
            no_classtype_found = 1.
  describe table iklart lines syst-tfill.
  if syst-tfill = 0.
    rc = 4.
    check 1 = 2.
  endif.
  sort iklart by klart.
  delete iklart where klart = rmclf-klart.
  return = 4.
  clear eklart.

  loop at iklart where intklart ne kreuz.
    authority-check object 'C_TCLA_BKA'
                    id 'KLART' field iklart-klart.
    check syst-subrc = 0.
    if iklart-aediezuord is initial.
      if iklart-multobj = kreuz.
        select count(*) from inob up to 1 rows
          where obtab = sobtab
            and klart = iklart-klart
            and objek = object.
        if syst-subrc = 0.
          return = 0.
          eklart = iklart-klart.
          exit.
        endif.
      else.
        select count(*) from kssk up to 1 rows
          where mafid = mafid
            and klart = iklart-klart
            and objek = object.
        if syst-subrc = 0.
          return = 0.
          eklart = iklart-klart.
          exit.
        endif.
      endif.
    else.
      if iklart-multobj = kreuz.
        call function 'CUOB_GET_NUMBER'
             EXPORTING
                  class_type       = iklart-klart
                  object_id        = object
                  table            = sobtab
             IMPORTING
                  object_number    = inobjnr
             EXCEPTIONS
                  lock_problem     = 01
                  object_not_found = 02.
        if syst-subrc > 0.
          continue.
        endif.
        ikssk-objek = inobjnr.
      else.
        ikssk-objek = object.
      endif.
      call function 'CLSE_SELECT_KSSK_0'
           EXPORTING
                klart          = iklart-klart
                mafid          = mafid
                objek          = ikssk-objek
                exit           = kreuz
                key_date       = rmclf-datuv1
           TABLES
                exp_kssk       = ikssk
           EXCEPTIONS
                no_entry_found = 01.
      if syst-subrc = 0.
        return = 0.
        eklart = iklart-klart.
        exit.
      endif.
    endif.
  endloop.
  rc = return.
endform.
