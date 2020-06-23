*------------------------------------------------------------------*
*    FORM create_dispo_records
*------------------------------------------------------------------*
*    Dispo-Sätze erzeugen für Objekte aus MARA oder MARC.
*    Muß wegen Effectivity vor (!) Verbuchung erfolgen.
*      -> lt_ausp
*      -> lt_kssk
*      -> lt_viewk
*      <- lt_mdcp     enthält Dispo-Sätze
*------------------------------------------------------------------*
form create_dispo_records
     tables lt_ausp like allausp[]
            lt_kssk like allkssk[]
            lt_viewk like viewk[]
            lt_mdcp like gt_dispo[]
     using  value(l_datuv)
            value(l_aennr).

  data :
    l_mdcp       like gt_dispo,
    l_laenge     type i,
    l_objek      like kssk-objek.
  field-symbols:
    <lf_ausp>    like allausp.


  refresh lt_mdcp.
* check necessity to extract data for BOM
  if g_zuord = c_zuord_4.
    read table lt_kssk index 1.
    if lt_kssk-vwstl = space.
      exit.
    endif.
  else.
    read table lt_kssk with key vwstl = kreuz
                                transporting no fields.
    if sy-subrc > 0.
      exit.
    endif.
  endif.

* extract materials for BOM
  loop at lt_ausp assigning <lf_ausp>
           where statu <> space.
    check <lf_ausp>-objek <> l_objek.
    l_objek = <lf_ausp>-objek.

    loop at lt_kssk transporting no fields
                    where objek = <lf_ausp>-objek
                      and klart = <lf_ausp>-klart
                      and mafid = <lf_ausp>-mafid
                      and vwstl = kreuz.

*     vwstl = x : class usable in BOM
      read table lt_kssk index sy-tabix.
      clear l_mdcp.
      l_mdcp-class = lt_kssk-class.
      l_mdcp-klart = lt_kssk-klart.
      if lt_kssk-mafid = mafido.
        l_mdcp-matnr = lt_kssk-objek.
        if lt_kssk-obtab = tabmarc.
          describe field l_mdcp-matnr length l_laenge in character mode.
          l_mdcp-werks = lt_kssk-objek+l_laenge.
        endif.
      endif.
*     Dispo-Satz anlegen.
      append l_mdcp to lt_mdcp.

      call function 'CLHI_STRUCTURE_CLASSES'
        exporting
          i_klart             = lt_kssk-klart
          i_class             = lt_kssk-class
          i_bup               = kreuz
          i_tdwn              = ' '
          i_batch             = kreuz
          i_including_text    = space
          i_language          = syst-langu
          i_no_classification = kreuz
          i_change_number     = l_aennr
          i_no_objects        = kreuz
          i_structured_list   = space
        tables
          daten               = ghclh
        exceptions
          class_not_valid     = 1
          classtype_not_valid = 2
          others              = 3.
      if sy-subrc <> 0.
*      message id sy-msgid type sy-msgty number sy-msgno
*              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
      clear l_mdcp.
      loop at ghclh where clas1 <> lt_kssk-class.
        l_mdcp-class = ghclh-clas1.
        l_mdcp-klart = lt_kssk-klart.
        append l_mdcp to lt_mdcp.
      endloop.
      if g_zuord = c_zuord_4.
*       CL24: object once in table
        exit.
      endif.
    endloop.                           " lt_kssk
  endloop.                             " lt_ausp

  sort lt_mdcp ascending by class klart matnr werks.
  delete adjacent duplicates from lt_mdcp.

endform.                               " create_dispo_records
