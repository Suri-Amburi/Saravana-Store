*-----------------------------------------------------------------------
* MARC-PLNNR
*
* Prüfung Arbeitsplangruppe und Plangruppenzähler
* (sprich Arbeitsplanalternative)
*
* Die Prüfung läuft ab 2.1b folgendermaßen ab:
* Wird die Kombination vollständig eingegeben, so wird die Existenz
* überprüft unter Berücksichtigung der Losgröße.
* Anderenfalls wird zunächst über die Auflösungssteuerung der
* Kalkulation die Arbeitsplan-Anwendungs-ID zum Werk ermittelt.
* Anschließend wird die Liste der möglichen Alternativen in Abhängigkeit
* von dieser Anwendungs-ID ermittelt.
* mk/15.02.94 zu 2.1D: Losgröße mit in Kette aufgenommen (Prüfung
* bezog Losgröße bereits ein), jetzt auch neue Prüfung, wenn nur die
* Losgröße verändert wird. Außerdem werden Vorschlagsdaten übernommen
* mk/31.03.94 zu 2.1E: Wird die Alternative nicht vollständig
* qualifiziert, wird der Rest nicht zwangsweise gefüllt
* (Kalkulation kann mit spezieller Auflösungssteuerung durchgeführt
* werden)
*-----------------------------------------------------------------------
MODULE MARC-PLNNR.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_PLNNR'
       EXPORTING
            WMARC_PLNNR  = MARC-PLNNR
            WMARC_APLAL  = MARC-APLAL
            WMARC_LOSGR  = MARC-LOSGR
            WMARC_PLNTY  = MARC-PLNTY
            RET_PLNNR    = LMARC-PLNNR
            RET_APLAL    = LMARC-APLAL
            RET_LOSGR    = LMARC-LOSGR
            RET_PLNTY    = LMARC-PLNTY
            NEUFLAG      = NEUFLAG
            WRMMG1_MATNR = RMMG1-MATNR
            WRMMG1_WERKS = RMMG1-WERKS
       IMPORTING
            WMARC_PLNNR  = MARC-PLNNR
            WMARC_APLAL  = MARC-APLAL
            WMARC_LOSGR  = MARC-LOSGR
            WMARC_PLNTY  = MARC-PLNTY.
ENDMODULE.
