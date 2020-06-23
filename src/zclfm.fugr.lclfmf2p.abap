*&---------------------------------------------------------------------*
*&    Form  DDB_MULTIPLE_CLASSES
*&---------------------------------------------------------------------*
*     Takes care that temporary alloctions and valuations
*     are setup in CTMS.
*     Necessary for multiple allocations and if characteristics
*     are inherited.
*----------------------------------------------------------------------*
*     -->l_KLART   class type
*     -->l_CLASS   current class
*     -->l_OBJECT  current object
*     Global: ghcli
*----------------------------------------------------------------------*

form ddb_multiple_classes
     using    value(p_klart) like klah-klart
              value(p_class) like klah-class
              value(p_objek) like kssk-objek.

  data:
        l_tabix   like sy-tabix.

  data: begin of lt_ghclx occurs 0.
          include structure ghcl.
  data: end of lt_ghclx.


  loop at ghcli where klart =  p_klart
                  and clas2 <> p_class
                  and objek =  p_objek
                  and delkz =  space .
    l_tabix = sy-tabix.
*   Abgleich mit GHCLI-Löschsätzen
    read table ghcli with key klart = p_klart
                              clas2 = ghcli-clas2
                              objek = p_objek
                              delkz = kreuz  binary search.
    if sy-subrc is initial.
*     beide Sätze wieder löschen
      delete ghcli index sy-tabix.
      delete ghcli index l_tabix.
    else.
      move-corresponding ghcli to lt_ghclx.
      append lt_ghclx.
    endif.
  endloop.

  read table lt_ghclx index 1.
  if sy-subrc = 0.
    call function 'CLHI_DDB_SET_MULTIPLE_CLASSES'
         tables
              new_multiple_classes = lt_ghclx
         exceptions
              others               = 1.
  endif.

  refresh lt_ghclx.
  loop at ghcli where klart =  p_klart
                  and clas2 <> p_class
                  and objek =  p_objek
                  and delkz =  kreuz .
    move-corresponding ghcli to lt_ghclx.
    append lt_ghclx.
  endloop.
  if sy-subrc is initial.
    call function 'CLHI_DDB_DEL_MULTIPLE_CLASSES'
         tables
              del_multiple_classes = lt_ghclx
         exceptions
              others               = 1.
  endif.

endform.                                     " ddb_multiple_classes
