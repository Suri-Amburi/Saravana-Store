*------------------------------------------------------------------*
*       MODULE NEUE_EINTRAEGE OUTPUT                               *
*------------------------------------------------------------------*
*       Leere Einträge für Dynpro 500 502 505 510                  *
*------------------------------------------------------------------*
module neue_eintraege output.

*-- Anzahl Objektzeilen
  describe table klastab lines rmclf-paganz .

  if sokcode = okeint.

    clear klastab.
    describe table klastab lines steploop.
    if steploop > 0.
      anzloop = anzloop - 1.
    endif.
    steploop = steploop + 1.
    if g_zuord eq c_zuord_4 .
      do anzloop times.
        insert klastab index steploop.
      enddo.
    else.
*-- Bei MULTI_CLASS = " ": Nur eine Zeile darf offen sein!!!
      if multi_class is initial.
        if steploop = 1.
          clear klastab.
          insert klastab index steploop.
        endif.
      else.
*-- Bei MULTI_CLASS = "X": Viele Leerzeilen
        do anzloop times.
          insert klastab index steploop.
        enddo.
      endif.
    endif.

*   Setze Eintrag auf Zeile 1. (4.5A)
    steploop = steploop - 1.
    if steploop > 0.
      index_neu = steploop.
      rmclf-pagpos = index_neu.
    else.
*-- Coding aber nur, wenn STEPLOOP = 0
      index_neu = 1.
      rmclf-pagpos = 1.
    endif.
  else.
*-- Falls KLASTAB leer und MULTI_CLASS initial: einen Eintrag einfügen
*   ?? HL
*    if multi_class is initial.
*      describe table klastab lines steploop.
*      if steploop is initial.
*        clear klastab.
*        steploop = 1.
*        insert klastab index steploop.
*      endif.
*    endif.
  endif.

endmodule.
