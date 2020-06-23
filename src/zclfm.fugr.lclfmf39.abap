*&---------------------------------------------------------------------*
*&      Form  SELECT_ALLOC_OBJTYPE
*&---------------------------------------------------------------------*
*       Displays list with object type and type class:
*       Selection will be shown in allocation list.
*       p_obtab = space: type class selected
*----------------------------------------------------------------------*
form select_alloc_objtype
     using    value(p_multi_obj)
     changing p_obtab.

  data: l_strlaeng(2) type n.

  import rmclindx from database indx(cf) id relid.
  if rmclindx-zeile1 = 0.
    describe table redun1 lines x2.
    index_neu1 = 1.
    x2 = x2 + 10.
    call screen dy602                  "rufe Auswahlbild
        starting at 32 8
        ending   at 79 x2.
    if sokcode = okabbr.
      clear okcode.
      leave screen.
    endif.
    read table redun1 index zeile1.
    read table redun  index redun1-index.
  else.
    zeile1 = rmclindx-zeile1.
    read table redun1 index zeile1.
    read table redun  index redun1-index.
    if p_multi_obj = kreuz.
      if redun-dynnr2 is initial.
*       sm_dynnr        = dynp0499.
        redun-dynnr4    = dynp0499.
        d5xx_dynnr      = dynp0299.
      else.
*       sm_dynnr        = redun-dynnr4.
        d5xx_dynnr      = redun-dynnr2.
      endif.
      l_strlaeng = strlen( redun-obtxt ).
      assign redun-obtxt(l_strlaeng) to <length>.
    endif.
  endif.
  p_obtab = redun-obtab.

endform.                               " SELECT_ALLOC_OBJTYPE
