*-------------------------------------------------------------------
***INCLUDE LWPDAF12 .
*-------------------------------------------------------------------
* FORM-Routinen für Reorg-Funktion der Änderungspointer
* der POS-Schnittstelle.
************************************************************************


************************************************************************
form pos_filia_data_get
         tables pet_filia_data structure gt_filia_data
         using  pi_systype     like wdls-systp.
************************************************************************
* FUNKTION:
* Besorge alle POS-relevanten Filialen mit zugehörigen
* benötigten Sekundärdaten.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_FILIA_DATA: Tabelle der benötigten Filialdaten.
*
* PI_SYSTYPE    : Systemtyp ('POS' für POS-Daten, ' ' für Bestellbuch)
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: key1 like wdls-empfn,
        key2 like wdls-empfn.

  data: begin of i_twpfi.
          include structure twpfi.
  data: end of i_twpfi.

  data: begin of t_kunnr occurs 500.   " Selektionstabelle für KUNNR's.
          include structure wdl_kunnr.
  data: end of t_kunnr.

  data: begin of t_filia_kopro occurs 500. " Tabelle für Kopro's
          include structure wpfilkopro.
  data: end of t_filia_kopro.

  data: begin of t_t001w occurs 500.   " Tabelle für Filialstammdaten
          include structure t001w.
  data: end of t_t001w.


* Falls dieser Systemtyp bereits aufbereitet wurde, dann keine weitere
* Aufbereitung nötig.
  if pi_systype = g_systype_buf.
    exit.
* Falls dieser Systemtyp noch nicht aufbereitet wurde, dann merken
* dieses Systemtyps.
  else. " pi_systype <> g_systype_buf.
    g_systype_buf = pi_systype.
  endif. " pi_systype = g_systype_buf.

* Prüfe, ob die POS-relevanten Filialen bereits eingelesen wurden.
  read table gt_filia_const_reorg index 1.

* Falls die POS-relevanten Filialen bereits eingelesen wurden.
  if sy-subrc = 0.
*   Übernehme Kundennummern in T_KUNNR.
    refresh: t_kunnr.
    loop at gt_filia_const_reorg.
      t_kunnr-empfn = gt_filia_const_reorg-kunnr.
      append t_kunnr.
    endloop. " at gt_filia_const_reorg.

* Falls die POS-relevanten Filialen noch nicht eingelesen wurden.
  else. "  sy-subrc <> 0.
*   Rücksetze interne Tabellen.
    refresh: t_kunnr, t_filia_kopro.
    clear:   t_kunnr, t_filia_kopro.

*   Besorge alle POS-relevanten Filialen.
    call function 'POS_FILIA_GET'
         exporting
              pi_with_t001w_data = 'X'
         tables
              pet_kunnr          = t_kunnr
              pet_filia_kopro    = t_filia_kopro
              pet_t001w          = t_t001w
         exceptions
              no_data_found      = 01.

    loop at t_t001w.
*     Fülle Filialkonstanten in temporäre Tabelle.
      move t_t001w-werks to gt_filia_const_reorg-filia.
      move t_t001w-kunnr to gt_filia_const_reorg-kunnr.

*     Übernehme Kommunikationsprofil.
      read table t_filia_kopro index sy-tabix.
      move t_filia_kopro-kopro to gt_filia_const_reorg-kopro.
      append gt_filia_const_reorg.
    endloop.                             " AT T_T001W.

*   Daten sortieren.
    sort gt_filia_const_reorg by kunnr.
  endif. " sy-subrc = 0.

* Prüfe, ob die WDLS-Sätze bereits eingelesen wurden.
  read table gt_wdls_reorg index 1.

* Falls die WDLS-Sätze noch nicht bereits eingelesen wurden.
  if sy-subrc <> 0.
*   Besorge die zuletzt erzeugten Kopfzeilen dieser Filialen
*   mit Status OK.
    call function 'DOWNLOAD_STATUS_READ'
         exporting
              pi_last_only_flag     = 'X'
              pi_systp              = ' '
         tables
              pe_t_wdls             = gt_wdls_reorg
              pi_t_kunnr            = t_kunnr
         exceptions
              no_status_found       = 01
              status_item_not_found = 02
              status_not_found      = 03.
  endif. " sy-subrc <> 0.

* Rücksetze interne Tabellen.
  refresh: pet_filia_data.
  clear:   pet_filia_data.

* Falls Bestellbuch selektiert wurde, dann dürfen POS-Einträge nicht
* beachtet werden.
  if pi_systype = space.
*   Daten sortieren.
    sort gt_wdls_reorg by empfn erzdt erzzt.
* ### vielleicht nicht löschen. Jörg fragen, warum Löschen möglich.
*   Lösche überflüssige Einträge.
    loop at gt_wdls_reorg
         where systp <> c_pos.

      key2 = gt_wdls_reorg-empfn.
      if key1 = key2.
        delete gt_wdls_reorg.
      else. "  key1 <> key2.
        key1 = key2.
      endif. "  key1 = key2.

    endloop. " at gt_wdls_reorg

*   Besorge die zugehörigen Sekundärdaten.
    loop at gt_wdls_reorg
         where systp <> c_pos.
*     Übernehme Daten in Ausgabetabelle.
      read table gt_filia_const_reorg with key
                 kunnr = gt_wdls_reorg-empfn
                 binary search.

      pet_filia_data-filia = gt_filia_const_reorg-filia.

*     Bestimme das Kommunikationsprofil der Filiale.
      call function 'POS_CUST_COMM_PROFILE_READ'
           exporting
                i_locnr               = gt_filia_const_reorg-kunnr
                i_flag_wrf1_lesen     = ' '
                i_kopro               = gt_filia_const_reorg-kopro
           importing
                o_twpfi               = i_twpfi
           exceptions
                filiale_unbekannt     = 01
                komm_profil_unbekannt = 02.

      if sy-subrc = 0.
*       Übernehme Daten aus Statustabelle.
        pet_filia_data-datp1  = gt_wdls_reorg-ersbi.
        pet_filia_data-timep1 = gt_wdls_reorg-erzbi.

*       Bestimme das Datum: Letztes Vers. + Vorlaufzeit.
        pet_filia_data-datp3 = pet_filia_data-datp1 + i_twpfi-vzeit.

        append pet_filia_data.
      endif.                             " SY-SUBRC = 0.

    endloop.                             " gt_wdls_reorg.

* Falls POS-Schnittstelle selektiert wurde, dann müssen alle
* Bestellbucheinträge ignoriert werden.
  else. " pi_systype <> space.
    loop at gt_wdls_reorg
         where systp = c_pos.
*     Übernehme Daten in Ausgabetabelle.
      read table gt_filia_const_reorg with key
                 kunnr = gt_wdls_reorg-empfn
                 binary search.

      pet_filia_data-filia = gt_filia_const_reorg-filia.

*     Bestimme das Kommunikationsprofil der Filiale.
      call function 'POS_CUST_COMM_PROFILE_READ'
           exporting
                i_locnr               = gt_filia_const_reorg-kunnr
                i_flag_wrf1_lesen     = ' '
                i_kopro               = gt_filia_const_reorg-kopro
           importing
                o_twpfi               = i_twpfi
           exceptions
                filiale_unbekannt     = 01
                komm_profil_unbekannt = 02.

      if sy-subrc = 0.
*       Übernehme Daten aus Statustabelle.
        pet_filia_data-datp1  = gt_wdls_reorg-ersbi.
        pet_filia_data-timep1 = gt_wdls_reorg-erzbi.

*       Bestimme das Datum: Letztes Vers. + Vorlaufzeit.
        pet_filia_data-datp3 = pet_filia_data-datp1 + i_twpfi-vzeit.

        append pet_filia_data.
      endif.                             " SY-SUBRC = 0.

    endloop.                             " gt_wdls_reorg.
  endif. " pi_systype = space.


endform.                               " POS_FILIA_CONST_GET


* EJECT.
************************************************************************
form reorg_pointer_get
     tables pet_pointer    structure gt_pointer
     using  pi_datp1       like sy-datum
            pi_timep1      like sy-uzeit
            pi_datp3       like sy-datum
            pi_msgtype     like edmsg-msgtyp.
************************************************************************
* FUNKTION:
* Selektiere alle Änderungspointer, die bis zum Zeitpunkt P1
* erzeugt wurden und die bis zum Zeitpunkt P3 aktiv werden.
* (Siehe auch Dokument: 'Detailkonzept für den
* Download zum POS im SAP-Handelssystem', Abschnitt 16.2)
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_POINTER  : Tabelle der selektierten Änderungspointer.
*
* PI_DATP1     : Datum des Zeitpunktes P1.
*
* PI_TIMEP1    : Uhrzeit des Zeitpunktes P1.
*
* PI_DATP3     : Datum des Zeitpunktes P3.
*
* PI_MSGTYPE   : Nachrichtentyp (z. B.: 'W_PDLD')
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_mindat  like sy-datum,
        h_date    like sy-datum,
        h_mintime like sy-uzeit.
data: t_pointer like bdcp occurs 0 with header line.

* Subtrahiere vom Zeitpunkt P3 einen Tag, weil die Pointerselektion
* alle Pointer selektieren soll, die VOR dem Zeitpunkt P3 aktiv
* wurden.
  h_date = pi_datp3 - 1.

* Rücksetze Variablen.
  clear: h_mindat, h_mintime.

* Selektiere Änderungspointer.
  call function 'CHANGE_POINTERS_READ'
       exporting
            creation_date_high       = pi_datp1
            creation_date_low        = h_mindat
            creation_time_high       = pi_timep1
            creation_time_low        = h_mintime
            message_type             = pi_msgtype
       tables
            change_pointers          = pet_pointer.

* Daten sortieren.
  sort pet_pointer by cpident.


endform.                               " REORG_POINTER_GET


* EJECT.
************************************************************************
form wind_reorg
     using  pi_datp1       like sy-datum
            pi_timep1      like sy-uzeit
            pi_datp3       like sy-datum
            pi_bltyp       like wind-bltyp.
************************************************************************
* FUNKTION:
* Reorganisiere die zugehörigen WIND-Daten, falls notwendig.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_DATP1     : Datum des Zeitpunktes P1.
*
* PI_TIMEP1    : Uhrzeit des Zeitpunktes P1.
*
* PI_DATP3     : Datum des Zeitpunktes P3.
*
* PI_BLTYP     : Belegtyp für WIND-Reorganisation:
*                = 55, wenn POS-Ausgang
*                = 50, wenn Sortimentsliste.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: h_mindat  like sy-datum,
        h_mintime like sy-uzeit,
        h_counter like sy-tabix.

  data: t_wind  like windvb occurs 0 with header line.

  ranges: ra_cretime   for wind-cretime.


* Falls bereits eine WIND-Reorganisation stattfand, dann keine
* weitere Aufbereitung nötig.
  if g_wind_reorganized = pi_bltyp.
    exit.
  endif. " g_wind_reorganized = pi_bltyp.

* Prüfe, ob es in der Tabelle WIND zu reorganisierende Daten gibt.
  select single * from wind
         where bltyp = pi_bltyp.

* Falls es keine Daten zum reorganisieren gibt, dann keine
* weitere Aufbereitung nötig.
  if sy-subrc <> 0.
    exit.
  endif. " sy-subrc <> 0.

* Rücksetze Variablen.
  clear: h_mindat, h_mintime.

* Besorge die zu reorganisierenden WIND-Daten
* Setze Intervallgrenzen für Zeitstempel.
  refresh: ra_cretime, t_wind.
  clear:   ra_cretime, t_wind.
  ra_cretime-sign      = c_inclusive.
  ra_cretime-option    = C_between.
  ra_cretime-low(8)    = h_mindat.
  ra_cretime-low+8(6)  = h_mintime.
  ra_cretime-high(8)   = pi_datp1.
  ra_cretime-high+8(6) = pi_timep1.
  append ra_cretime.

  DO.
* Besorge die WIND-Daten
  call function 'MM_WIND_INDEX_READ'
       EXPORTING
            I_BLTYP                 = pi_bltyp
            I_BLOCK_SIZE            = '10000'
       tables
            pt_wind                 = t_wind
            PT_CRETIMERANGE         = ra_cretime
       EXCEPTIONS
            NO_DATA_SELECT          = 1
            OTHERS                  = 2.

  IF t_wind[] IS INITIAL.
    EXIT.
  ENDIF.

  delete wind from table t_wind.
  commit work.
  refresh t_wind.
  ENDDO.

* Merker für Reorganisation der WIND-Daten setzen.
  g_wind_reorganized = pi_bltyp.

endform.                               " wind_reorg
