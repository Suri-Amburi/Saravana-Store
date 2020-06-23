*---------------------------------------------------------------------*
*       FORM BUILD_CHARS                                              *
*---------------------------------------------------------------------*
*       Auftab der Merkmaltabelle.                                    *
*---------------------------------------------------------------------*
form build_chars tables chartab   like classes-merkm
                 using  untclass  like kssk-objek
                        oberclass like kssk-clint
                        klart     like kssk-klart
                        mafid     like kssk-mafid
                        datum     like kssk-datuv
                        p_aennr   like rmclf-aennr1.

  data: begin of hcl  occurs 0.
          include structure ghcl.
  data: end of hcl.

  data: begin of skssk occurs 0.
          include structure kssk.
  data: end of skssk.

  data: begin of pukssk occurs 0.
          include structure clzuord_pu.
  data: end of pukssk.

  ranges xatinn for ksml-imerk.

  clear   iklah.
  refresh iklah.
  if mafid = mafidk.
    iklah-clint = untclass.
    append iklah.
    call function 'CLSE_SELECT_KLAH'
         TABLES
              imp_exp_klah   = iklah
         EXCEPTIONS
              no_entry_found = 1
              others         = 2.
    read table iklah index 1.


    call function 'CLHI_STRUCTURE_CLASSES'
         EXPORTING
              i_klart             = klart
              i_class             = iklah-class
              i_bup               = kreuz
              i_tdwn              = ' '
              i_batch             = kreuz
              i_including_text    = space
              i_language          = space
              i_no_classification = kreuz
              i_view              = mafidk
              i_date              = datum
              i_change_number     = p_aennr
              i_exclude_clint     = oberclass
              i_structured_list   = space
         TABLES
              daten               = hcl
         EXCEPTIONS
              class_not_valid     = 1
              classtype_not_valid = 2
              others              = 3.
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.

  else.
    call function 'CLSE_SELECT_KSSK_0'
         EXPORTING
              clint          = oberclass
              klart          = klart
              mafid          = mafido
              objek          = untclass
              neclint        = kreuz
              key_date       = datum
         TABLES
              exp_kssk       = skssk
         EXCEPTIONS
              no_entry_found = 1
              set_classtype  = 2
              set_mafid      = 3
              others         = 4.
    if syst-subrc = 0.
      loop at skssk.
        if syst-tabix = 1.
          iklah-clint = skssk-clint.
          append iklah.
          call function 'CLSE_SELECT_KLAH'
               TABLES
                    imp_exp_klah   = iklah
               EXCEPTIONS
                    no_entry_found = 1
                    others         = 2.
          read table iklah index 1.
        endif.
        pukssk-oclint = skssk-clint.
        append pukssk.
      endloop.
      call function 'CTMS_FILL_CLASSIFY_BUFFER'
           TABLES
                buffer_kssk = pukssk
           EXCEPTIONS
                others      = 1.

      call function 'CLHI_STRUCTURE_CLASSES'
           EXPORTING
                i_klart             = klart
                i_class             = iklah-class
                i_bup               = kreuz
                i_tdwn              = ' '
                i_batch             = kreuz
                i_including_text    = space
                i_language          = space
                i_no_classification = kreuz
                i_view              = mafidk
                i_date              = datum
                i_change_number     = p_aennr
                i_structured_list   = ' '
           TABLES
                daten               = hcl
           EXCEPTIONS
                class_not_valid     = 1
                classtype_not_valid = 2
                others              = 3.
      if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      endif.

    endif.
  endif.
  xatinn-sign   = incl.
  xatinn-option = equal.
  delete hcl where eklas = kreuz.
  read table hcl index 1.
  check syst-subrc = 0.
  select imerk from ksml into xatinn-low
                         for all entries in hcl
    where clint = hcl-clin1.
    append xatinn.
  endselect.
  if syst-subrc = 0.
    delete chartab where imerk in xatinn.
  endif.
endform.
