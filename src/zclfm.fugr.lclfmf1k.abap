*§-----------------------------------------------------------------*
*        Form  REKURSION_PRÜFEN                                    *
*------------------------------------------------------------------*
form rekursion_pruefen using headclass like allkssk-class
                            sohnclass like rmclf-clasn
                            return    like syst-subrc.

call function 'CLSA_RECURSION_CHECK'
     exporting
          i_class              = sohnclass
          i_headclass          = headclass
          i_klart              = rmclf-klart
    EXCEPTIONS
         RECURSION            = 1
         CLASS_DOES_NOT_EXIST = 2
         OTHERS               = 3
          .
if sy-subrc = 1.
  return = 1.
endif.


*  call function 'CLSA_STRUCTURE_RECURSION'
*       EXPORTING
*            headclass        = headclass
*            class            = sohnclass
*            classtype        = rmclf-klart
*            refresh          = kreuz
*            mode             = ' '
*       EXCEPTIONS
*            err_rekursiv     = 1
*            err_no_subclass  = 2
*            err_overflow     = 3
*            err_inkonsistent = 4.
*  if syst-subrc = 1.
*    return = 1.
*  endif.

endform.
