*&---------------------------------------------------------------------*
*&      Form  OKB_MEIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form okb_mein.

  clear markzeile1.
  case cn_mark.
    when 0.
      leave screen.
    when 1.
      clear cn_mark.
    when others.
      describe table klastab lines syst-tfill.
      if syst-tfill = cn_mark.
        loop at klastab where markupd = kreuz.
          clear klastab-markupd.
          modify klastab.
        endloop.
        clear cn_mark.
        leave screen.
      endif.
      clear cn_mark.
  endcase.
  if zeile = 0.
    message i516.
    describe table klastab lines steploop.
    steploop = steploop + 1.
  else.
    steploop = zeile + index_neu - 1.
  endif.
  read table klastab index steploop.
*-- Anmerkung: irgendeine komische Berechnung wird durchgeführt
  if syst-subrc = 0.
    ssytabix = syst-tabix.
    hzaehl = klastab-zaehl.
    steploop = steploop - 1.
    if steploop = 0.
      ssytabix = ein.
      szaehl = hzaehl / 2.
    else.
      read table klastab index steploop.
      if syst-subrc = 0.
        szaehl = klastab-zaehl.
      endif.
    endif.
  else.
    read table klastab index anzzeilen.
    szaehl = klastab-zaehl.
    ssytabix = anzzeilen + 1.
    hzaehl   = ssytabix * 100.
  endif.
  loop at klastab where markupd = kreuz.
    szaehl = ( szaehl + hzaehl ) / 2.
    klastab-zaehl = szaehl.
    klastab-markupd = konst_y.
    delete klastab.
    if ssytabix > syst-tabix.
      ssytabix = ssytabix - 1.
    endif.
*+  klastab-zeile = ssytabix.
    insert klastab index ssytabix.
    ssytabix = ssytabix + 1.
  endloop.
  if hzaehl = szaehl.
    reorgflag = konst_z.
  else.
    reorgflag = konst_y.
  endif.
  clear allksskanfang.

endform.                               " OKB_MEIN
