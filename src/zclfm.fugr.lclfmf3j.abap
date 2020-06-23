*&---------------------------------------------------------------------*
*&      Form  CHECK_DELOB_ALL_TABS
*&---------------------------------------------------------------------*
*       Falls die Tabelle DELOB Einträge enthält, werden etwaige
*       Einträge zu den Objekten aus den Tabelle ALLKSSK und ALLAUSP
*       gelöscht.
*       Form darf nur innerhalb der ON-COMMIT-Routinen verwendet werden
*----------------------------------------------------------------------*
form check_delob_all_tabs.
  data: l_objek   like delob-objek.
  loop at delob.
    if not delob-cuobj is initial.
      l_objek = delob-cuobj.
    else.
      l_objek = delob-objek.
    endif.
*-- Löschen aus ALLKSSK
    delete allkssk where objek = l_objek
                    and  mafid = delob-mafid
                    and  klart = delob-klart
                    and  clint = delob-clint.

*-- Löschen aus ALLAUSP
    delete allausp where objek = l_objek
                    and  mafid = delob-mafid
                    and  klart = delob-klart.
*-- Löschen aus DELCL
*>>> DELCL: Ist das noch notwendig????
    delete delcl   where objek = l_objek
                     and mafid = delob-mafid
                     and klart = delob-klart .
  endloop.
endform.                               " CHECK_DELOB_ALL_TABS
