*-------------------------------------------------------------------
***INCLUDE POSINF01 .
*-------------------------------------------------------------------

************************************************************************
FORM FILIA_GET TABLES PET_KUNNR STRUCTURE WDL_KUNNR
                      PET_FILIA STRUCTURE WPFILIA.
************************************************************************
* FUNKTION:
* Bestimme alle Filialen, die den angegebenen Selektionsbedingungen
* genügen und fülle sie in Tabelle PET_FILIA. Die Tabelle PET_LOCNR
* enhält die zugehörigen Kundennummern.
* ---------------------------------------------------------------------*
* PARAMETER:
* PET_KUNNR: Ergebnismenge der selektierten Kundennummern.

* PET_FILIA: Ergebnismenge der selektierten Filialen.
* ----------------------------------------------------------------------
* AUTOR(EN):
* Thomas Roth (CAS AG)
************************************************************************
  DATA: BEGIN OF T_T001W OCCURS 50.
          INCLUDE STRUCTURE T001W.
  DATA: END OF T_T001W.

  DATA: BEGIN OF T_kunnr OCCURS 0.
          include structure WPPDAT.
  DATA: END OF T_kunnr.


* Bestimme die Filialen, die dieser Vertriebsschiene angehören
* und den Selektionskriterien entsprechen.
  SELECT kunnr FROM t001w INTO CORRESPONDING FIELDS OF TABLE t_kunnr
         WHERE WERKS IN SO_FISEL
         AND   VKORG =  PA_VKORG
         AND   VTWEG =  PA_VTWEG.

* Fehlermeldung, falls keine Daten gefunden wurden.
  IF SY-SUBRC <> 0.
*   'Es wurden keine Empfänger selektiert'
    MESSAGE E004.
    STOP.
* Falls Filialen ermittelt wurden.
  ENDIF.                               " SY-SUBRC <> 0.

* Besorge alle POS-relevanten Filialen.
  CALL FUNCTION 'POS_FILIA_GET'
       TABLES
            PIT_kunnr_ONLY = T_kunnr
            PET_KUNNR      = PET_KUNNR
            PET_FILIA      = PET_FILIA
       EXCEPTIONS
            NO_DATA_FOUND  = 01.

* Fehlermeldung, falls keine Daten gefunden wurden.
  IF SY-SUBRC <> 0.
*   'Es wurden keine Empfänger selektiert'
    MESSAGE E004.
    STOP.
  ENDIF.                               " SY-SUBRC <> 0.

ENDFORM.
