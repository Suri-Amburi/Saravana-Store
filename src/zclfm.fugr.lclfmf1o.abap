*§-----------------------------------------------------------------*
*        FORM BLAETTERN                                            *
*------------------------------------------------------------------*
*        Blätterfunktionen                                         *
*------------------------------------------------------------------*
form blaettern.

  check anzzeilen > 0.
  check anzloop   > 0.
  call function 'SCROLLING_IN_TABLE'
       EXPORTING
            entry_act = index_neu
            entry_to  = anzzeilen
            loops     = anzloop
            ok_code   = sokcode
       IMPORTING
            entry_new = index_neu
            pages_sum = pag_pages
            page_new  = pag_page.
  rmclf-pagpos = index_neu.
endform.
