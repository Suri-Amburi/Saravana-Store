*---------------------------------------------------------------------*
*       MODULE LOOPZIEHEN                                             *
*---------------------------------------------------------------------*
*       Setzen Loopfaktor   WFS ok                                    *
*---------------------------------------------------------------------*
module loopziehen.
  on change of anzloop.
    describe table klastab lines anzzeilen.
    check anzzeilen > 0.
    check anzloop   > 0.
    call function 'SCROLLING_IN_TABLE'
         exporting
              entry_act = index_neu
              page_act  = pag_page
              page_go   = pag_pages
              entry_to  = anzzeilen
              loops     = anzloop
              ok_code   = sokcode
         importing
              pages_sum = pag_pages
              page_new  = pag_page.
  endon.
endmodule.
