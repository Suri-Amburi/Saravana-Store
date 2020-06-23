*§-----------------------------------------------------------------*
*        FORM BEENDEN_OHNE                                         *
*------------------------------------------------------------------*
*        Beenden Klassifizierung                                   *
*------------------------------------------------------------------*
form beenden_ohne.

  case sokcode.
    when okleav.                                            "F15
      set screen dy000.
      leave screen.
    when okende.                                            "F3
      set screen dy000.
      leave screen.
    when okabbr.                                            "F12
*-- Sondersteuerung für POPUPs
      if sy-dynnr eq dy601 or sy-dynnr eq dy602.
        okcode = okabbr.
        set screen dy000.
        leave screen.
        exit.
      endif.
*     Abbrechen auf den Bildern 500 502 505 510 512
      if g_zuord eq c_zuord_4.
        clear cn_mark.
      endif.
      describe table allkssk lines syst-tfill.
      if syst-tfill ne 0.
        perform beenden_tab_loesch.
        refresh klastab.
      endif.
      set screen dy000.
      leave screen.
  endcase.
endform.
