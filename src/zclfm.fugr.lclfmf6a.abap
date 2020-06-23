*&---------------------------------------------------------------------*
*&      Form  ok_typ_chg
*&---------------------------------------------------------------------*
*       Change and eventually save the object type
*       in that popup displayed when inserting a new object.
*       Used in transaction CL24n.
*----------------------------------------------------------------------*
form ok_typ_chg.

  if classif_status <> space.
    read table redun with key radio = punkt.
    if sy-subrc = 0.
*     object type already selected in this transaction
    else.
      import rmclindx from database indx(cf) id relid.
      zeile1 = rmclindx-zeile1.
      if zeile1 > 0.
        read table redun1 index zeile1.
        read table redun  index redun1-index.
        redun-radio = punkt.
        modify redun index redun1-index.
      endif.
    endif.
    index_neu1 = 1.
    describe table redun1 lines x2.
    x2 = x2 + 10.

* popup with object type list
    call screen dy602
        starting at 32 8
        ending   at 79 x2.

    clear okcode.
  endif.

endform.                               " ok_typ_chg
