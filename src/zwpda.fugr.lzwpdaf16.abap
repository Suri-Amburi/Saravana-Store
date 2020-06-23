*----------------------------------------------------------------------*
*   INCLUDE LWPDAF16                                                   *
*----------------------------------------------------------------------*
* Empfänger FORM-Routinen für Parallelisierung.
************************************************************************

************************************************************************
form return_filia_group_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der Aufbereitung einer Filialgruppe.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: anzahl_tasks like wpstruc-counter6.

* Tabelle der reorganisierbaren Pointer-ID's.
  data: begin of t_reorg_pointer_temp occurs 10.
          include structure bdicpident.
  data: end of t_reorg_pointer_temp.

* Tabelle zum speichern von Daten für spätere Listaufbereitung.
  data: begin of t_statistik occurs 1.
          include structure wplistdata.
  data: end of t_statistik.

* Tabelle der fehlerhaften parallelen Tasks.
  data: begin of t_rfcdest occurs 0.
          include structure wprfcdest.
  data: end of t_rfcdest.

* Tabelle zum speichern von Daten für spätere Listaufbereitung.
  data: begin of t_statistik_wdlsp occurs 1.
          include structure wpstatwdlsp.
  data: end of t_statistik_wdlsp.


* Empfange Ergebnisse der Filialgruppe.
  receive results from function 'POS_FILIA_GROUP_PREPARE'
         importing
              pe_anzahl_tasks       = anzahl_tasks
         tables
              pet_statistik         = t_statistik
              pet_statistik_wdlsp   = t_statistik_wdlsp
              pet_reorg_pointer     = t_reorg_pointer_temp
              pet_rfcdest           = t_rfcdest
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs.

*   Aktualisiere die Geamtanzahl der parallelen Tasks.
    add 1            to g_jobs_gesamt.
    add anzahl_tasks to g_jobs_gesamt.

*   Übernehme die reorganisierbaren Pointer-ID's in Ausgabetabelle.
    loop at t_reorg_pointer_temp.
      append t_reorg_pointer_temp to gt_reorg_pointer.
    endloop. " at t_reorg_pointer_temp

*   Übernehme Statistikdaten in die Ausgabetabellen.
    loop at t_statistik.
      append t_statistik to gt_statistik.
    endloop. " at t_statistik

    loop at t_statistik_wdlsp.
      append t_statistik_wdlsp to gt_statistik_wdlsp.
    endloop. " at t_statistik_wdlsp

*   Übernehme die Infos zu fehlerhaften Tasks in Ausgabetabelle
    loop at t_rfcdest.
      append t_rfcdest to gt_rfcdest_grp.
    endloop. " at t_rfcdest

* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest_grp.
      gt_rfcdest_grp-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator_grp with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest_grp-rfcdest = gt_rfc_indicator_grp-rfcdest.
      gt_rfcdest_grp-datum   = sy-datum.
      gt_rfcdest_grp-uzeit   = sy-uzeit.
      append gt_rfcdest_grp.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks_grp-taskname = pi_taskname.
    append gt_error_tasks_grp.
  endif. " sy-subrc = 0.


endform. " return_filia_group_prepare.


*eject.
************************************************************************
form return_filia_sub_group_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der Aufbereitung einer Filialuntergruppe.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: anzahl_tasks like wpstruc-counter6.

* Tabelle zum speichern von Daten für spätere Listaufbereitung.
  data: begin of t_statistik occurs 1.
          include structure wplistdata.
  data: end of t_statistik.

* Tabelle der fehlerhaften parallelen Tasks.
  data: begin of t_rfcdest occurs 0.
          include structure wprfcdest.
  data: end of t_rfcdest.

* Tabelle zum speichern von Daten für spätere Listaufbereitung.
  data: begin of t_statistik_wdlsp occurs 1.
          include structure wpstatwdlsp.
  data: end of t_statistik_wdlsp.


* Empfange Ergebnisse der Filialgruppe.
  receive results from function 'POS_FILIA_SUB_GROUP_PREPARE'
         importing
              pe_anzahl_tasks       = anzahl_tasks
         tables
              pxt_statistik         = t_statistik
              pxt_statistik_wdlsp   = t_statistik_wdlsp
              pet_rfcdest           = t_rfcdest
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs_sub2.

*   Aktualisiere die Geamtanzahl der parallelen Tasks pro Filialgruppe.
    add 1            to g_jobs_gesamt_grp.
    add anzahl_tasks to g_jobs_gesamt_grp.

*   Übernehme Statistikdaten in die Ausgabetabellen.
    loop at t_statistik.
      append t_statistik to gt_statistik.
    endloop. " at t_statistik

    loop at t_statistik_wdlsp.
      append t_statistik_wdlsp to gt_statistik_wdlsp.
    endloop. " at t_statistik_wdlsp

*   Übernehme die Infos zu fehlerhaften Tasks in Ausgabetabelle
    loop at t_rfcdest.
      append t_rfcdest to gt_rfcdest_sub.
    endloop. " at t_rfcdest

* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest_sub.
      gt_rfcdest_sub-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator_sub with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest_sub-rfcdest = gt_rfc_indicator_sub-rfcdest.
      gt_rfcdest_sub-datum   = sy-datum.
      gt_rfcdest_sub-uzeit   = sy-uzeit.
      append gt_rfcdest_sub.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks_sub-taskname = pi_taskname.
    append gt_error_tasks_sub.
  endif. " sy-subrc = 0.


endform. " RETURN_FILIA_SUB_GROUP_PREPARE


*eject.
************************************************************************
form return_condpt_analyse_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der Konditionsänderungszeigeranalyse für
* den Artikelstamm.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  data: anzahl_tasks like wpstruc-counter6.

* Tabelle der reorganisierbaren Pointer-ID's.
  data: begin of t_reorg_pointer_temp occurs 0.
          include structure bdicpident.
  data: end of t_reorg_pointer_temp.

* Tabelle der Filialabhängigen Änderungen.
  data: begin of t_ot1_f_artstm occurs 0.
          include structure gt_ot1_f_artstm.
  data: end of t_ot1_f_artstm.

* Tabelle der Filialunabhängigen Änderungen.
  data: begin of t_ot2_artstm occurs 0.
          include structure gt_ot2_artstm.
  data: end of t_ot2_artstm.


* Empfange Ergebnisse der Filialgruppe.
  receive results from function 'POS_ARTSTM_CONDPT_ANALYSE_PREP'
         tables
              pet_reorg_pointer          = t_reorg_pointer_temp
              pet_ot1_f_artstm           = t_ot1_f_artstm
              pet_ot2_artstm             = t_ot2_artstm
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs_cnd.

*   Aktualisiere die Geamtanzahl der parallelen Tasks pro Filialgruppe.
    add 1 to g_jobs_gesamt_grp.

*   Übernehme die reorganisierbaren Pointer-ID's in Ausgabetabelle.
    loop at t_reorg_pointer_temp.
      append t_reorg_pointer_temp to gt_reorg_pointer.
    endloop. " at t_reorg_pointer_temp

*   Übernehme das Ergebnis der Analyse in globale Tabelle.
    loop at t_ot1_f_artstm.
      append t_ot1_f_artstm to gt_ot1_f_artstm.
    endloop. " at t_ot1_f_artstm

*   Übernehme das Ergebnis der Analyse in globale Tabelle.
    loop at t_ot2_artstm.
      append t_ot2_artstm to gt_ot2_artstm.
    endloop. " at t_ot2_artstm


* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest_cnd.
      gt_rfcdest_cnd-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator_cnd with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest_cnd-rfcdest = gt_rfc_indicator_cnd-rfcdest.
      gt_rfcdest_cnd-datum   = sy-datum.
      gt_rfcdest_cnd-uzeit   = sy-uzeit.
      append gt_rfcdest_cnd.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks_cnd-taskname = pi_taskname.
    append gt_error_tasks_cnd.
  endif. " sy-subrc = 0.


endform. " RETURN_FILIA_SUB_GROUP_PREPARE


* eject.
************************************************************************
form return_wrgp_chg_mode_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der IDOC-Aufbereitung für Warengruppen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum Puffern von WDLSP-Daten.
  data: begin of t_wdlsp occurs 0.
          include structure wdlsp.
  data: end of t_wdlsp.

* Tabelle der EDIDC-Daten bei Verteilung über Kundenverteilungsmodell.
  data: begin of t_edidc occurs 0.
          include structure edidc.
  data: end of t_edidc.

* Tabelle der fehlerhaften, nachzubereitenden Objekte.
  data: begin of t_wdlso_parallel occurs 0.
          include structure wpwdlsopar.
  data: end of t_wdlso_parallel.

* Feldleiste für Filialunabhängigkeit.
  data: begin of i_independence_check.
          include structure gt_independence_check.
  data: end of i_independence_check.

* Feldleiste für Filialunabhängigkeit.
  data: begin of i_stat_counter.
          include structure gi_stat_counter.
  data: end of i_stat_counter.


* Empfange Ergebnisse der Warengruppenaufbereitung.
  receive results from function 'POS_WRGP_CHG_MODE_PREPARE'
         importing
              pe_independence_check  = i_independence_check
              pe_stat_counter        = i_stat_counter
         tables
              pet_edidc              = t_edidc
              pet_wdlsp_buf          = t_wdlsp
              pet_wdlso_parallel     = t_wdlso_parallel
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs_sub.

*   Aktualisiere Filialunabhängigkeitsstruktur.
    gi_independence_check-wrgp = i_independence_check-wrgp.

*   Aktualisiere Statisktikinformation.
    gi_stat_counter2-wrgp_ign = i_stat_counter-wrgp_ign.

*   Übernehme die EDIDC-Daten.
    loop at t_edidc.
      append t_edidc to gt_edidc_parallel.
    endloop. " at t_edidc

*   Übernehme die erzeugten WDLSP-Einträge in internen Puffer.
    loop at t_wdlsp.
      append t_wdlsp to gt_wdlsp_parallel.
    endloop. " at t_wdlsp.

*   Übernehme die erzeugten WDLSO-Einträge in internen Puffer.
    loop at t_wdlso_parallel.
      append t_wdlso_parallel to gt_wdlso_parallel.
    endloop. " at t_wdlso_parallel.

* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest.
      gt_rfcdest-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest-rfcdest = gt_rfc_indicator-rfcdest.
      gt_rfcdest-datum   = sy-datum.
      gt_rfcdest-uzeit   = sy-uzeit.
      gt_rfcdest-filia   = g_filia.
      append gt_rfcdest.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks-taskname = pi_taskname.
    append gt_error_tasks.
  endif. " sy-subrc = 0.


endform. " return_wrgp_chg_mode_prepare


* eject.
************************************************************************
form return_artstm_chg_mode_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der IDOC-Aufbereitung für Artikelstammdaten.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum Puffern von WDLSP-Daten.
  data: begin of t_wdlsp occurs 0.
          include structure wdlsp.
  data: end of t_wdlsp.

* Tabelle der EDIDC-Daten bei Verteilung über Kundenverteilungsmodell.
  data: begin of t_edidc occurs 0.
          include structure edidc.
  data: end of t_edidc.

* Tabelle der fehlerhaften, nachzubereitenden Objekte.
  data: begin of t_wdlso_parallel occurs 0.
          include structure wpwdlsopar.
  data: end of t_wdlso_parallel.

* Feldleiste für Filialunabhängigkeit.
  data: begin of i_independence_check.
          include structure gt_independence_check.
  data: end of i_independence_check.

* Feldleiste für Statistikinformation.
  data: begin of i_stat_counter.
          include structure gi_stat_counter.
  data: end of i_stat_counter.


* Empfange Ergebnisse der Artikelstammaufbereitung.
  receive results from function 'POS_ARTSTM_CHG_MODE_PREPARE'
         importing
              pe_independence_check  = i_independence_check
              pe_stat_counter        = i_stat_counter
         tables
              pet_edidc              = t_edidc
              pet_wdlsp_buf          = t_wdlsp
              pet_wdlso_parallel     = t_wdlso_parallel
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs_sub.

*   Aktualisiere Filialunabhängigkeitsstruktur.
    gi_independence_check-artstm = i_independence_check-artstm.

*   Aktualisiere Statisktikinformation.
    gi_stat_counter2-artstm_ign = i_stat_counter-artstm_ign.

*   Übernehme die EDIDC-Daten.
    loop at t_edidc.
      append t_edidc to gt_edidc_parallel.
    endloop. " at t_edidc

*   Übernehme die erzeugten WDLSP-Einträge in internen Puffer.
    loop at t_wdlsp.
      append t_wdlsp to gt_wdlsp_parallel.
    endloop. " at t_wdlsp.

*   Übernehme die erzeugten WDLSO-Einträge in internen Puffer.
    loop at t_wdlso_parallel.
      append t_wdlso_parallel to gt_wdlso_parallel.
    endloop. " at t_wdlso_parallel.

* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest.
      gt_rfcdest-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest-rfcdest = gt_rfc_indicator-rfcdest.
      gt_rfcdest-datum   = sy-datum.
      gt_rfcdest-uzeit   = sy-uzeit.
      gt_rfcdest-filia   = g_filia.
      append gt_rfcdest.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks-taskname = pi_taskname.
    append gt_error_tasks.
  endif. " sy-subrc = 0.


endform. " return_artstm_chg_mode_prepare


* eject.
************************************************************************
form return_ean_chg_mode_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der IDOC-Aufbereitung für EAN-Referenzen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum Puffern von WDLSP-Daten.
  data: begin of t_wdlsp occurs 0.
          include structure wdlsp.
  data: end of t_wdlsp.

* Tabelle der EDIDC-Daten bei Verteilung über Kundenverteilungsmodell.
  data: begin of t_edidc occurs 0.
          include structure edidc.
  data: end of t_edidc.

* Tabelle der fehlerhaften, nachzubereitenden Objekte.
  data: begin of t_wdlso_parallel occurs 0.
          include structure wpwdlsopar.
  data: end of t_wdlso_parallel.

* Feldleiste für Filialunabhängigkeit.
  data: begin of i_independence_check.
          include structure gt_independence_check.
  data: end of i_independence_check.

* Feldleiste für Statistikinformation.
  data: begin of i_stat_counter.
          include structure gi_stat_counter.
  data: end of i_stat_counter.


* Empfange Ergebnisse der EAN-Referenzen.
  receive results from function 'POS_EAN_CHG_MODE_PREPARE'
         importing
              pe_independence_check  = i_independence_check
              pe_stat_counter        = i_stat_counter
         tables
              pet_edidc              = t_edidc
              pet_wdlsp_buf          = t_wdlsp
              pet_wdlso_parallel     = t_wdlso_parallel
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs_sub.

*   Aktualisiere Filialunabhängigkeitsstruktur.
    gi_independence_check-ean = i_independence_check-ean.

*   Aktualisiere Statisktikinformation.
    gi_stat_counter2-ean_ign = i_stat_counter-ean_ign.

*   Übernehme die EDIDC-Daten.
    loop at t_edidc.
      append t_edidc to gt_edidc_parallel.
    endloop. " at t_edidc

*   Übernehme die erzeugten WDLSP-Einträge in internen Puffer.
    loop at t_wdlsp.
      append t_wdlsp to gt_wdlsp_parallel.
    endloop. " at t_wdlsp.

*   Übernehme die erzeugten WDLSO-Einträge in internen Puffer.
    loop at t_wdlso_parallel.
      append t_wdlso_parallel to gt_wdlso_parallel.
    endloop. " at t_wdlso_parallel.

* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest.
      gt_rfcdest-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest-rfcdest = gt_rfc_indicator-rfcdest.
      gt_rfcdest-datum   = sy-datum.
      gt_rfcdest-uzeit   = sy-uzeit.
      gt_rfcdest-filia   = g_filia.
      append gt_rfcdest.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks-taskname = pi_taskname.
    append gt_error_tasks.
  endif. " sy-subrc = 0.


endform. " return_ean_chg_mode_prepare


* eject.
************************************************************************
form return_sets_chg_mode_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der IDOC-Aufbereitung für Set-Zuordnungen.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum Puffern von WDLSP-Daten.
  data: begin of t_wdlsp occurs 0.
          include structure wdlsp.
  data: end of t_wdlsp.

* Tabelle der EDIDC-Daten bei Verteilung über Kundenverteilungsmodell.
  data: begin of t_edidc occurs 0.
          include structure edidc.
  data: end of t_edidc.

* Tabelle der fehlerhaften, nachzubereitenden Objekte.
  data: begin of t_wdlso_parallel occurs 0.
          include structure wpwdlsopar.
  data: end of t_wdlso_parallel.

* Feldleiste für Filialunabhängigkeit.
  data: begin of i_independence_check.
          include structure gt_independence_check.
  data: end of i_independence_check.

* Feldleiste für Statistikinformation.
  data: begin of i_stat_counter.
          include structure gi_stat_counter.
  data: end of i_stat_counter.


* Empfange Ergebnisse der Set-Zuordnungen.
  receive results from function 'POS_SETS_CHG_MODE_PREPARE'
         importing
              pe_independence_check  = i_independence_check
              pe_stat_counter        = i_stat_counter
         tables
              pet_edidc              = t_edidc
              pet_wdlsp_buf          = t_wdlsp
              pet_wdlso_parallel     = t_wdlso_parallel
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs_sub.

*   Aktualisiere Filialunabhängigkeitsstruktur.
    gi_independence_check-sets = i_independence_check-sets.

*   Aktualisiere Statisktikinformation.
    gi_stat_counter2-sets_ign = i_stat_counter-sets_ign.

*   Übernehme die EDIDC-Daten.
    loop at t_edidc.
      append t_edidc to gt_edidc_parallel.
    endloop. " at t_edidc

*   Übernehme die erzeugten WDLSP-Einträge in internen Puffer.
    loop at t_wdlsp.
      append t_wdlsp to gt_wdlsp_parallel.
    endloop. " at t_wdlsp.

*   Übernehme die erzeugten WDLSO-Einträge in internen Puffer.
    loop at t_wdlso_parallel.
      append t_wdlso_parallel to gt_wdlso_parallel.
    endloop. " at t_wdlso_parallel.

* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest.
      gt_rfcdest-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest-rfcdest = gt_rfc_indicator-rfcdest.
      gt_rfcdest-datum   = sy-datum.
      gt_rfcdest-uzeit   = sy-uzeit.
      gt_rfcdest-filia   = g_filia.
      append gt_rfcdest.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks-taskname = pi_taskname.
    append gt_error_tasks.
  endif. " sy-subrc = 0.


endform. " return_sets_chg_mode_prepare


* eject.
************************************************************************
form return_nart_chg_mode_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der IDOC-Aufbereitung für Nachzugsartikel.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum Puffern von WDLSP-Daten.
  data: begin of t_wdlsp occurs 0.
          include structure wdlsp.
  data: end of t_wdlsp.

* Tabelle der EDIDC-Daten bei Verteilung über Kundenverteilungsmodell.
  data: begin of t_edidc occurs 0.
          include structure edidc.
  data: end of t_edidc.

* Tabelle der fehlerhaften, nachzubereitenden Objekte.
  data: begin of t_wdlso_parallel occurs 0.
          include structure wpwdlsopar.
  data: end of t_wdlso_parallel.

* Feldleiste für Filialunabhängigkeit.
  data: begin of i_independence_check.
          include structure gt_independence_check.
  data: end of i_independence_check.

* Feldleiste für Statistikinformation.
  data: begin of i_stat_counter.
          include structure gi_stat_counter.
  data: end of i_stat_counter.


* Empfange Ergebnisse der Set-Zuordnungen.
  receive results from function 'POS_NART_CHG_MODE_PREPARE'
         importing
              pe_independence_check  = i_independence_check
              pe_stat_counter        = i_stat_counter
         tables
              pet_edidc              = t_edidc
              pet_wdlsp_buf          = t_wdlsp
              pet_wdlso_parallel     = t_wdlso_parallel
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs_sub.

*   Aktualisiere Filialunabhängigkeitsstruktur.
    gi_independence_check-nart = i_independence_check-nart.

*   Aktualisiere Statisktikinformation.
    gi_stat_counter2-nart_ign = i_stat_counter-nart_ign.

*   Übernehme die EDIDC-Daten.
    loop at t_edidc.
      append t_edidc to gt_edidc_parallel.
    endloop. " at t_edidc

*   Übernehme die erzeugten WDLSP-Einträge in internen Puffer.
    loop at t_wdlsp.
      append t_wdlsp to gt_wdlsp_parallel.
    endloop. " at t_wdlsp.

*   Übernehme die erzeugten WDLSO-Einträge in internen Puffer.
    loop at t_wdlso_parallel.
      append t_wdlso_parallel to gt_wdlso_parallel.
    endloop. " at t_wdlso_parallel.

* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest.
      gt_rfcdest-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest-rfcdest = gt_rfc_indicator-rfcdest.
      gt_rfcdest-datum   = sy-datum.
      gt_rfcdest-uzeit   = sy-uzeit.
      gt_rfcdest-filia   = g_filia.
      append gt_rfcdest.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks-taskname = pi_taskname.
    append gt_error_tasks.
  endif. " sy-subrc = 0.


endform. " return_nart_chg_mode_prepare


* eject.
************************************************************************
form return_pers_chg_mode_prepare using pi_taskname.
************************************************************************
* FUNKTION:
* Empfangen der Ergebnisse der IDOC-Aufbereitung für Personendaten.
* ---------------------------------------------------------------------*
* PARAMETER:
* PI_TASKNAME  : Identifiziernder Name des Tasks dessen Ergebnisse
*                empfangen werden.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
* Tabelle zum Puffern von WDLSP-Daten.
  data: begin of t_wdlsp occurs 0.
          include structure wdlsp.
  data: end of t_wdlsp.

* Tabelle der EDIDC-Daten bei Verteilung über Kundenverteilungsmodell.
  data: begin of t_edidc occurs 0.
          include structure edidc.
  data: end of t_edidc.

* Tabelle der fehlerhaften, nachzubereitenden Objekte.
  data: begin of t_wdlso_parallel occurs 0.
          include structure wpwdlsopar.
  data: end of t_wdlso_parallel.

* Feldleiste für Filialunabhängigkeit.
  data: begin of i_independence_check.
          include structure gt_independence_check.
  data: end of i_independence_check.

* Feldleiste für Statistikinformation.
  data: begin of i_stat_counter.
          include structure gi_stat_counter.
  data: end of i_stat_counter.


* Empfange Ergebnisse der Artikelstammaufbereitung.
  receive results from function 'POS_PERS_CHG_MODE_PREPARE'
         importing
              pe_independence_check  = i_independence_check
              pe_stat_counter        = i_stat_counter
         tables
              pet_edidc              = t_edidc
              pxt_kunnr_credit       = gt_kunnr_credit_buf
              pxt_credit_data        = gt_credit_data_buf
              pxt_kunnr_bank         = gt_kunnr_bank_buf
              pxt_bank_data          = gt_bank_data_buf
              pet_wdlsp_buf          = t_wdlsp
              pet_wdlso_parallel     = t_wdlso_parallel
         exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

* Falls die parallele Aufbereitung erfolgreich war.
  if sy-subrc = 0.
*   Aktualisiere die Anzahl der empfangenen Tasks.
    add 1 to g_rcv_jobs_sub.

*   Aktualisiere Filialunabhängigkeitsstruktur.
    gi_independence_check-pers = i_independence_check-pers.

*   Aktualisiere Statisktikinformation.
    gi_stat_counter2-pers_ign = i_stat_counter-pers_ign.

*   Übernehme die EDIDC-Daten.
    loop at t_edidc.
      append t_edidc to gt_edidc_parallel.
    endloop. " at t_edidc

*   Übernehme die erzeugten WDLSP-Einträge in internen Puffer.
    loop at t_wdlsp.
      append t_wdlsp to gt_wdlsp_parallel.
    endloop. " at t_wdlsp.

*   Übernehme die erzeugten WDLSO-Einträge in internen Puffer.
    loop at t_wdlso_parallel.
      append t_wdlso_parallel to gt_wdlso_parallel.
    endloop. " at t_wdlso_parallel.

* Falls Fehler bei der parallelen Aufbereitung auftraten.
  else. " sy-subrc <> 0.
*   Falls Probleme mit dem Zielsystem auftraten.
    if sy-subrc <> 3.
      clear: gt_rfcdest.
      gt_rfcdest-subrc = sy-subrc.

*     Bestimme die fehlerhafte Destination.
      read table gt_rfc_indicator with key
           taskname = pi_taskname.

*     Aktualisiere Fehlertabelle für Zielsysteme.
      gt_rfcdest-rfcdest = gt_rfc_indicator-rfcdest.
      gt_rfcdest-datum   = sy-datum.
      gt_rfcdest-uzeit   = sy-uzeit.
      gt_rfcdest-filia   = g_filia.
      append gt_rfcdest.
    endif. " sy-subrc <> 3.

*   Merke den fehlerhaften Tasksnamen.
    gt_error_tasks-taskname = pi_taskname.
    append gt_error_tasks.
  endif. " sy-subrc = 0.


endform. " return_pers_chg_mode_prepare
