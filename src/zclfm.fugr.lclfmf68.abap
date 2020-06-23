*----------------------------------------------------------------------*
*       FORM CHK_WITH_DIALOGUE
*----------------------------------------------------------------------*
*       Prüft die Existenz einer Klassenart und ggf.. Dialog
*----------------------------------------------------------------------*
*  -->  I_FLAG      KLART angegeben und Wechsel erwünscht
*  <--  E_EXIT      Wurde mit EXIT verlassen
*----------------------------------------------------------------------*
form chk_with_dialogue using value(i_classtype)
                             value(i_flag)
                    changing e_cancel
                             e_exit
                             e_ptable
                             e_table.


  data: l_batchi    like sy-binpt,
        l_intklart  like tcla-intklart,
        l_okcode    like sy-ucomm,
        l_ptable    like tclao-obtab,
        l_subrc     like sy-subrc.


  call function 'CLCA_PROCESS_CLASSTYPE'
       exporting
            classtype     = i_classtype
            mode          = zwei
            dynpros       = kreuz
            batchi        = l_batchi
            table         = e_table
            ptable        = l_ptable
       importing
            classtype     = rmclf-klart
            typetext      = rmclf-artxt
            multi_classif = multi_class
            mult_obj      = multi_obj
            imptcla       = tcla
            table         = e_table
            ptable        = l_ptable
            ok_abbr       = l_okcode
       exceptions
            not_found     = 1
            no_auth_klart = 2
            others        = 3.
  l_subrc = sy-subrc.
  if l_okcode = okabbr.
    clear okcode.
    e_cancel = kreuz.
    if not i_flag is initial.
*-- Bei OKWECH: Table wird zurückgeladen
      e_table = sobtab.
    else.
      clear sokcode.
      e_exit = kreuz.
      exit.
    endif.
  endif.
  if l_subrc = 2.
    message s546 raising no_auth_klart.
    e_exit = kreuz.
    exit.
  endif.
  if rmclf-klart is initial.
    e_exit = kreuz.
    exit.
  endif.
*-- Abhängig von KLART und OKCODE
  if i_flag is initial and not multi_obj is initial.
*-- Achtung: Hier wird die globale PTABLE verwendet
    if not e_ptable is initial.
      e_table = e_ptable.
    endif.
  endif.
endform.
