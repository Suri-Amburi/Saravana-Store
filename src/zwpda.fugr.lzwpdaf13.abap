*----------------------------------------------------------------------*
* INCLUDE LWPDAF13                                                   *
* POS-Schnittstelle: FORM-Routinen für FB: POS_CONDITION_INTERVALS_MERGE
*----------------------------------------------------------------------*


************************************************************************
form higher_level_entry_check
     tables pit_periods     structure wpperiod
            pit_order       structure gt_order
            pxt_datab       structure wpdate
            pxt_knumh_datab structure wpperiod
     using  pi_maxlevel     type i
            pi_datum        like wpperiod-datab
            pi_level        type i
            pi_kschl        like wpperiod-kschl
            pe_returncode   like g_returncode.
************************************************************************
* FUNKTION:
* Rekursive Funktion!
* Überprüft, ob das Datum PI_DATUM durch einen Eintrag der
* Hierarchiestufe PI_LEVEL repräsentiert wird. Wenn ja, dann
* wird das Datum PI_DATUM mit in die Ergebnistabelle übernommen.
* Wenn nein, dann wird in der nächst höheren Hierarchiestufe gesucht.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_PERIODS    : Tabelle der Konditionsintervalle
*
* PIT_ORDER      : Tabelle der Zugriffsfolgen
*
* PXT_DATAB      : Ergebnistabelle der gefundenen Zeitpunkte an denen
*                  sich etwas ändert.
* PXT_KNUMH_DATAB: Wie PXT_DATAB aber falls vorhanden wird neben dem
*                  DATAB-Feld auch das Feld KNUMH gefüllt.
* PI_MAXLEVEL    : Anzahl der Hierarchiestufen.
*
* PI_DATUM       : Zeitpunkt der Überprüft werden soll.
*
* PI_LEVEL       : Hierarchiestufe, die überprüft werden soll.
*
* PI_KSCHL       : Konditionsart, für die gerade aufbereitet wird.
*
* PE_RETURNCODE  : <> 0, wenn kein Eintrag auf höchster Ebene vorhanden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: tabname like t682i-kotabnr,
        level   type i.

  data: begin of t_intervals occurs 10.
          include structure wpperiod.
  data: end of t_intervals.

  clear: pe_returncode.

* Besorge den Namen der Konditionstabelle dieser Hierarchiestufe.
  read table pit_order index pi_level.
  tabname = pit_order-kotabnr.

* Kopiere Intervalldaten für Stufe LEVEL.
  refresh: t_intervals.
  loop at pit_periods
       where kschl   = pi_kschl
       and   kotabnr = tabname.
    append pit_periods to t_intervals.
  endloop.                             " AT PIT_PERIODS

* Prüfe, ob ein Eintrag für dieses Datum existiert.
  loop at t_intervals
       where datab <= pi_datum
       and   datbi >= pi_datum.

*   Übernehme DATAB in Ausgabetabelle.
    append pi_datum to pxt_datab.

*   Übernehme das Datum und KNUMH in sekundäre
*   Ergebnistabelle.
    move pi_datum          to pxt_knumh_datab-datab.
    move t_intervals-kschl to pxt_knumh_datab-kschl.
    move t_intervals-knumh to pxt_knumh_datab-knumh.
    append pxt_knumh_datab.
  endloop.                             " AT T_INTERVALS.

  if sy-subrc = 0.
*   Routine verlassen.
    exit.

* Überprüfe die nächst höhere Hierarchiestufe.
  elseif sy-subrc <> 0 and pi_level < pi_maxlevel.
    level = pi_level + 1.
    perform higher_level_entry_check    tables pit_periods
                                        pit_order
                                        pxt_datab
                                        pxt_knumh_datab
                                 using  pi_maxlevel  pi_datum
                                        level        pi_kschl
                                        pe_returncode.
* Abbruchbedingung für Rekursion.
  elseif pi_level = pi_maxlevel.
*   Setze Returncode.
    pe_returncode = 1.
    exit.
  endif.                               " SY-SUBRC = 0.


endform.                               " HIGHER_LEVEL_ENTRY_CHECK


*eject
************************************************************************
form lower_level_entry_check
     tables pit_periods   structure wpperiod
            pit_order     structure gt_order
     using  pi_datum      like wpperiod-datab
            pi_level      type i
            pe_returncode like g_returncode
            pi_kschl      like wpperiod-kschl.
************************************************************************
* FUNKTION:
* Rekursive Funktion!
* Überprüft, ob das Datum PI_DATUM durch einen Eintrag der
* Hierarchiestufe PI_LEVEL repräsentiert wird. Wenn nein, dann
* wird in der nächst tieferen Hierarchiestufe gesucht.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_PERIODS     : Tabelle der Konditionsintervalle
*
* PIT_ORDER       : Tabelle der Zugriffsfolgen
*
* PI_DATUM        : Zeitpunkt der Überprüft werden soll.
*
* PI_LEVEL        : Hierarchiestufe, die überprüft werden soll.
*
* PE_RETURNCODE   : <> 0, wenn kein Eintrag auf tiefster Ebene vorhande.
*
* PI_KSCHL        : Konditionsart, für die gerade aufbereitet wird.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: tabname like t682i-kotabnr,
        level   type i.

  data: begin of t_intervals occurs 10.
          include structure wpperiod.
  data: end of t_intervals.

  clear: pe_returncode.

* Besorge den Namen der Konditionstabelle dieser Hierarchiestufe.
  read table pit_order index pi_level.
  tabname = pit_order-kotabnr.

* Kopiere Intervalldaten für Stufe LEVEL.
  refresh: t_intervals.
  loop at pit_periods
       where kschl   = pi_kschl
       and   kotabnr = tabname.
    append pit_periods to t_intervals.
  endloop.                             " AT PIT_PERIODS

* Prüfe, ob ein Eintrag für dieses Datum existiert.
  loop at t_intervals
       where datab <= pi_datum
       and   datbi >= pi_datum.
    exit.
  endloop.                             " AT T_INTERVALS.

  if sy-subrc = 0.
*   Routine verlassen.
    exit.

* Überprüfe die nächst tiefere Hierarchiestufe.
  elseif sy-subrc <> 0 and pi_level > 1.
    level = pi_level - 1.
    perform lower_level_entry_check tables pit_periods
                                           pit_order
                                    using  pi_datum    level
                                           pe_returncode
                                           pi_kschl.

* Abbruchbedingung für Rekursion.
  elseif pi_level = 1.
    pe_returncode = 1.
    exit.
  endif.                               " SY-SUBRC = 0.


endform.                               " LOWER_LEVEL_ENTRY_CHECK


*eject
************************************************************************
form level_analyse
     tables pit_periods              structure wpperiod
            pit_order                structure gt_order
            pxt_datab                structure wpdate
            pxt_knumh_datab          structure wpperiod
     using  pi_maxlevel              type i
            pi_datab                 like wpperiod-datab
            pi_datbi                 like wpperiod-datbi
            pi_level                 type i
            pi_kotabnr               like konh-kotabnr
            pi_inc_first_record      like wpstruc-modus
            pi_kschl                 like wpperiod-kschl
            pi_check_end_of_interval like wpstruc-modus
            pi_kotabnr_period_del    type loevm_ko. "1964825
************************************************************************
* FUNKTION:
* Analysiere die Hierarchiestufe PI_LEVEL.
* ---------------------------------------------------------------------*
* PARAMETER:
* PIT_PERIODS    : Tabelle der Konditionsintervalle
*
* PIT_ORDER      : Tabelle der Zugriffsfolgen
*
* PXT_DATAB      : Ergebnistabelle der gefundenen Zeitpunkte an denen
*                  sich etwas ändert.
* PXT_KNUMH_DATAB: Wie PXT_DATAB aber falls vorhanden wird neben dem
*                  DATAB-Feld auch das Feld KNUMH gefüllt.
* PI_MAXLEVEL    : Anzahl der Hierarchiestufen.
*
* PI_DATAB       : Beginn des Betrachtungszeitraums.
*
* PI_DATBI       : Ende des Betrachtungszeitraums.
*
* PI_LEVEL       : Hierarchiestufe, die überprüft werden soll.
*
* PI_KOTABNR     : Nummer der Konditionstabelle für Prüfung auf den
*                  ersten Datensatz.
* PI_INC_FIRST_RECORD: Prüfe, ob der erste Datensatz mit ausgegeben
*                      werden soll. Nur wenn H-Stufe der Kond.tabelle
*                      PI_KOTABNR entspricht.
* PI_KSCHL       : Konditionsart, für die gerade aufbereitet wird.
*                  PI_KOTABNR entspricht.
* PI_CHECK_END_OF_INTERVAL: Sonderüberprüfung der Intervallenden.
* PI_KOTABNR_PERIOD_DEL: PI_KOTABNR table condition period was deleted from PIT_PERIODS. "1964825
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: tabname like t682i-kotabnr,
        h_datum like sy-datum,
        level   type i,
        returncode type i.

  data: c_datmax like sy-datum value '99991231'.

  data: begin of t_intervals occurs 10.
          include structure wpperiod.
  data: end of t_intervals.


* Besorge den Namen der Konditionstabelle dieser Hierarchiestufe.
  read table pit_order index pi_level.
  tabname = pit_order-kotabnr.

* Kopiere Intervalldaten für Stufe LEVEL.
  refresh: t_intervals.
  loop at pit_periods
       where kschl   = pi_kschl
       and   kotabnr = tabname.
    append pit_periods to t_intervals.
  endloop.                             " AT PIT_PERIODS

* Beginn der Analyse dieser Hierarchiestufe.
  loop at t_intervals
       where datab <= pi_datbi
       and   datbi >= pi_datab.

*   Falls T_INTERVALS-DATAB innerhalb des zu untersuchenden
*   Bereichs liegt.
    if t_intervals-datab >= pi_datab or
       ( t_intervals-datab <  pi_datab and
         pi_inc_first_record <> space ).

*     Falls nicht gerade die Hierarchiestufe mit der höchsten
*     Priorität vorliegt.
      if pi_level > 1.
        if t_intervals-datab <  pi_datab.
          h_datum = pi_datab.
        else. " T_INTERVALS-DATAB >=  PI_DATAB.
          h_datum = t_intervals-datab.
        endif. " T_INTERVALS-DATAB <  PI_DATAB.

        clear: returncode.
        level = pi_level - 1.

*       Überprüfe Hierarchiestufen mit der höheren Priorität, ob es
*       ein Intervall gibt welches den Zeitpunkt H_DATUM überdeckt.
        perform lower_level_entry_check tables pit_periods
                                               pit_order
                                        using  h_datum     level
                                               returncode  pi_kschl.
*       Falls T_INTERVALS-DATAB nicht durch eine tiefere
*       Hierarchiestufe repräsentiert wird.
        if returncode <> 0.
*         Falls Schnittpunkte (Zeitpunkte) mit dem Beginn des
*         Betrachtungszeitraums nicht berücksichtigt werden
*         sollen sofern ihr DATAB-Zeitpunkt vor oder auf
*         dem Beginnzeitpunkt liegt.
          if pi_inc_first_record = space.
*           Übernehme das Datum in Ergebnistabelle.
            append h_datum to pxt_datab.

*           Übernehme das Datum und KNUMH in sekundäre
*           Ergebnistabelle.
            move   h_datum           to pxt_knumh_datab-datab.
            move   t_intervals-kschl to pxt_knumh_datab-kschl.
            move   t_intervals-knumh to pxt_knumh_datab-knumh.
            append pxt_knumh_datab.

*         Falls Schnittpunkte (Zeitpunkte) mit dem Beginn des
*         Betrachtungszeitraums berücksichtigt werden
*         sollen sofern ihr DATAB-Zeitpunkt vor oder auf
*         dem Beginnzeitpunkt liegt.
          else. " pi_inc_first_record <> space.
*           Falls ein solcher Schnittpunkt gerade vorliegt.
            if t_intervals-datab <= pi_datab.
*             Falls der SP zur richtigen Hierarchiestufe gehört
              if pi_kotabnr = tabname or pi_kotabnr_period_del = 'X'. "1964825
*               Übernehme den Beginn des Betrachtungszeitraums in
*               Ausgabetabelle.
                append pi_datab to pxt_datab.

*               Übernehme das Datum und KNUMH in sekundäre
*               Ergebnistabelle.
                move pi_datab          to pxt_knumh_datab-datab.
                move t_intervals-kschl to pxt_knumh_datab-kschl.
                move t_intervals-knumh to pxt_knumh_datab-knumh.
                append pxt_knumh_datab.
              endif. " pi_kotabnr = tabname.

*           Falls ein solcher Schnittpunkt gerade nicht vorliegt.
            else.                    " T_INTERVALS-DATAB > PI_DATAB.
*             Übernehme Zeitpunkt in Ausgabetabelle.
              append t_intervals-datab to pxt_datab.

*             Übernehme das Datum und KNUMH in sekundäre
*             Ergebnistabelle.
              move t_intervals-datab to pxt_knumh_datab-datab.
              move t_intervals-kschl to pxt_knumh_datab-kschl.
              move t_intervals-knumh to pxt_knumh_datab-knumh.
              append pxt_knumh_datab.

            endif.                   " T_INTERVALS-DATAB <= PI_DATAB.
          endif.                       " PI_INC_FIRST_RECORD = SPACE OR
        endif.                         " RETURNCODE <> 0.

*     Falls bereits die Hierarchiestufe mit der höchsten Priorität
*     vorliegt, dann brauchen keine höheren Hierarchiestufen
*     überprüft zu werden, da diese nicht existieren.
      else.                            " PI_LEVEL = 1.
*       Falls Schnittpunkte (Zeitpunkte) mit dem Beginn des
*       Betrachtungszeitraums nicht berücksichtigt werden
*       sollen sofern ihr DATAB-Zeitpunkt vor oder auf
*       dem Beginnzeitpunkt liegt.
        if pi_inc_first_record = space.
*         Übernehme Intervallbeginn in Ergebnistabelle.
          append t_intervals-datab to pxt_datab.

*         Übernehme das Datum und KNUMH in sekundäre
*         Ergebnistabelle.
          move t_intervals-datab to pxt_knumh_datab-datab.
          move t_intervals-kschl to pxt_knumh_datab-kschl.
          move t_intervals-knumh to pxt_knumh_datab-knumh.
          append pxt_knumh_datab.

*       Falls Schnittpunkte (Zeitpunkte) mit dem Beginn des
*       Betrachtungszeitraums berücksichtigt werden
*       sollen sofern ihr DATAB-Zeitpunkt vor oder auf
*       dem Beginnzeitpunkt liegt.
        else. " pi_inc_first_record <> space.
*         Falls ein solcher Schnittpunkt gerade vorliegt.
          if t_intervals-datab <= pi_datab.
*           Falls der Schnittpkt. zur richtigen Hierarchiestufe gehört.
            if pi_kotabnr = tabname or pi_kotabnr_period_del = 'X'. "1964825
*             Übernehme den Beginn des Betrachtungszeitraums in
*             Ausgabetabelle.
              append pi_datab to pxt_datab.

*             Übernehme das Datum und KNUMH in sekundäre
*             Ergebnistabelle.
              move pi_datab          to pxt_knumh_datab-datab.
              move t_intervals-kschl to pxt_knumh_datab-kschl.
              move t_intervals-knumh to pxt_knumh_datab-knumh.
              append pxt_knumh_datab.
            endif. " pi_kotabnr = tabname.

*         Falls ein solcher Schnittpunkt gerade nicht vorliegt.
          else.                    " T_INTERVALS-DATAB > PI_DATAB.
*           Übernehme Intervallbeginn in Ausgabetabelle.
            append t_intervals-datab to pxt_datab.

*           Übernehme das Datum und KNUMH in sekundäre
*           Ergebnistabelle.
            move t_intervals-datab to pxt_knumh_datab-datab.
            move t_intervals-kschl to pxt_knumh_datab-kschl.
            move t_intervals-knumh to pxt_knumh_datab-knumh.
            append pxt_knumh_datab.

          endif.                   " T_INTERVALS-DATAB <= PI_DATAB.
        endif.                       " PI_INC_FIRST_RECORD = SPACE OR
      endif.                           " PI_LEVEL > 1.
    endif.                      " T_INTERVALS-DATAB >= PI_DATAB OR...

    if t_intervals-datbi < c_datmax.
      h_datum = t_intervals-datbi + 1.
    else.                              " T_INTERVALS-DATBI = C_DATMAX.
      h_datum = t_intervals-datbi.
    endif.                             " T_INTERVALS-DATBI < C_DATMAX.

    if h_datum <= pi_datbi and t_intervals-datbi < c_datmax.
*     Falls weder die Hierarchiestufe mit der höchsten noch mit
*     niedrigsten Priorität vorliegt.
      if pi_level > 1 and pi_level < pi_maxlevel.
        clear: returncode.
        level = pi_level - 1.
*       Überprüfe die tieferen Hierarchiestufen, ob Eintrag vorhanden.
        perform lower_level_entry_check tables pit_periods
                                               pit_order
                                        using  h_datum
                                               level returncode
                                               pi_kschl.
*       Falls H_DATUM nicht durch eine tiefere Hierarchiestufe
*       repräsentiert wird.
        if returncode <> 0.
          clear: returncode.
          level = pi_level + 1.
*         Überprüfe die höheren Hierarchiestufen, ob Eintrag vorhanden.
          perform higher_level_entry_check tables pit_periods
                                                  pit_order
                                                  pxt_datab
                                                  pxt_knumh_datab
                                           using  pi_maxlevel  h_datum
                                                  level  pi_kschl
                                                  returncode.
*         Falls T_INTERVALS-DATBI nicht durch eine höhere
*         Hierarchiestufe repräsentiert wird aber trotzdem
*         übernommen werden soll.
          if returncode <> 0 and pi_check_end_of_interval <> space.
            append h_datum to pxt_datab.

            clear: pxt_knumh_datab.
            move   h_datum to pxt_knumh_datab-datab.
            append pxt_knumh_datab.
          endif.                         " RETURNCODE <> 0 and ...
        endif. " returncode <> 0.
*     Falls es sich um die Hierarchiestufe mit der höchsten
*     Priorität handelt.
      elseif pi_level = 1.
        clear: returncode.
        level = pi_level + 1.

*       Falls es nur eine Hierarchiestufe gibt, dann ist die erste
*       auch gleichzeitig die höchste. In diesem Falle ist überprüfen
*       von noch höheren Hierarchiestufen überflüssig.
        if pi_maxlevel = 1.
*         Setze Returncode zum Zeichen, dass kein Satz auf
*         höherer Hierarchiestufe existiert.
          returncode = 1.

        else.
*         Überprüfe die höheren Hierarchiestufen, ob Eintrag vorhanden.
          perform higher_level_entry_check tables pit_periods
                                                  pit_order
                                                  pxt_datab
                                                  pxt_knumh_datab
                                           using  pi_maxlevel  h_datum
                                                  level        pi_kschl
                                                  returncode.
        endif. " pi_maxlevel = 1.

*       Falls T_INTERVALS-DATBI nicht durch eine höhere
*       Hierarchiestufe repräsentiert wird, aber trotzdem
*       übernommen werden soll.
        if returncode <> 0 and pi_check_end_of_interval <> space.
          append h_datum to pxt_datab.

          clear: pxt_knumh_datab.
          move   h_datum to pxt_knumh_datab-datab.
          append pxt_knumh_datab.
        endif.                         " RETURNCODE <> 0...

*     Falls es sich um die Hierarchiestufe mit der kleinsten
*     Priorität handelt.
      elseif pi_level = pi_maxlevel.
*       Falls T_INTERVALS-DATBI übernommen werden soll.
        if pi_check_end_of_interval <> space.
          clear: returncode.
          level = pi_level - 1.
*         Überprüfe die tieferen Hierarchiestufen, ob Eintrag vorhanden.
          perform lower_level_entry_check tables pit_periods
                                                 pit_order
                                          using  h_datum
                                                 level returncode
                                                 pi_kschl.
*         Falls H_DATUM nicht durch eine tiefere Hierarchiestufe
*         repräsentiert wird.
          if returncode <> 0.
            append h_datum to pxt_datab.

            clear: pxt_knumh_datab.
            move   h_datum to pxt_knumh_datab-datab.
            append pxt_knumh_datab.
          endif.                         " RETURNCODE <> 0...
        endif. " pi_check_end_of_interval <> space.
      endif. " PI_LEVEL > 1 AND PI_LEVEL < PI_MAXLEVEL.
    endif.     "  h_datum <= pi_datbi and t_intervals-datbi < c_datmax.
  endloop.                             " AT T_INTERVALS.


endform.                               " LEVEL_ANALYSE


*eject
************************************************************************
form t685_get
     using  pi_verwendung  like t682i-kvewe
            pi_applikation like t682i-kappl
            pi_kschl       like t685-kschl
            pe_t685        structure t685.
************************************************************************
* FUNKTION:
* Besorge, die der Konditionsart, Applikation und Verwendung
* zugeordnete Zugriffsfolge. Die Daten werden intern gepuffert.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_VERWENDUNG:  Verwendung
*
* PI_APPLIKATION: Applikation
*
* PI_KSCHL      : Konditionsart
*
* PE_T685       : Gefundener Satz aus Tabelle T685
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Tabelle T685 mit Baustein lesen -------------------------------------*
  call function 'SD_T685_SINGLE_READ'
       exporting
            kvewe_i = pi_verwendung
            kappl_i = pi_applikation
            kschl_i = pi_kschl
       importing
            t685_o  = t685
       exceptions
            no_entry_found = 1
            others         = 2.


endform. " t685_get


*eject
************************************************************************
form t682i_get
     tables pet_t682i_tab  structure t682i
     using  pi_kvewe       like t682i-kvewe
            pi_applikation like t682i-kappl
            pi_kozgf       like t682i-kozgf.
************************************************************************
* FUNKTION:
* Einlesen der Zugriffsfolge. Die Daten werden intern gepuffert.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_T682I_TAB : Gefundene Zugriffsfolge
*
* PI_KVEWE      : Vervendung
*
* PI_APPLIKATION:  Applikation
*
* PI_KOZGF      : Name der Zugriffsfolge
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************

* Lese T682I mit Baustein --> T682I_TAB -------------------------------*
  call function 'SD_T682I_SINGLE_READ'
       exporting
            kvewe_i      = pi_kvewe
            kappl_i      = pi_applikation
            kozgf_i      = pi_kozgf
            count_i      = 10
       tables
            t682i_tab_io = pet_t682i_tab
       exceptions
            others       = 1.


 endform. " t682i_get
