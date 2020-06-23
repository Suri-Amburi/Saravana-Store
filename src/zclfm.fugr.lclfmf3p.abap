*&---------------------------------------------------------------------*
*&      Form  DELETE_DELCL
*&---------------------------------------------------------------------*
*       Zu P_ALLKSSK wird ein Satz aus DELCL gelöscht
*----------------------------------------------------------------------*
*      -->P_ALLKSSK  text
*----------------------------------------------------------------------*
form delete_delcl using    p_allkssk structure rmclkssk .

  read table delcl with key
        mafid = p_allkssk-mafid
        klart = rmclf-klart
        objek = p_allkssk-objek
        clint = p_allkssk-clint
        merkm = space
        obtab = p_allkssk-obtab.

  if sy-subrc is initial.
    delete delcl index sy-tabix.
  endif.

endform.                               " DELETE_DELCL
