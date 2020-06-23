*-----------------------------------------------------------------------
* MARC-STLAL.
*
* Prüfung Stücklistenalternative und Verwendung
*
* Die Prüfung läuft ab 2.1b folgendermaßen ab:
* Wird die Kombination vollständig eingegeben, so wird die Existenz
* überprüft unter Berücksichtigung der Losgröße.
* Anderenfalls wird zunächst über die Auflösungssteuerung der
* Kalkulation die Stücklisten-Anwendungs-ID zum Werk ermittelt.
* Anschließend wird die Liste der möglichen Alternativen in Abhängigkeit
* von dieser Anwendungs-ID ermittelt.
* Es ist zu beachten, daß der FB CS_ALT_SELECT_MAT die vorgegebene
* Alternative nicht überprüft, wenn es genau eine gibt.
* mk/15.02.94 zu 2.1D: Losgröße mit in Kette aufgenommen (Prüfung
* bezog Losgröße bereits ein), jetzt auch neue Prüfung, wenn nur die
* Losgröße verändert wird. Außerdem Vorschlagsdaten übernehmen
* mk/31.03.94 zu 2.1E: Wird die Alternative nicht vollständig
* qualifiziert, wird der Rest nicht zwangsweise gefüllt
* (Kalkulation kann mit spezieller Auflösungssteuerung durchgeführt
* werden)
*-----------------------------------------------------------------------
MODULE MARC-STLAL.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_STLAL'
       EXPORTING
            WMARC_STLAL  = MARC-STLAL
            WMARC_STLAN  = MARC-STLAN
            WMARC_LOSGR  = MARC-LOSGR
            RET_STLAL    = LMARC-STLAL
            RET_STLAN    = LMARC-STLAN
            RET_LOSGR    = LMARC-LOSGR
            NEUFLAG      = NEUFLAG
            WRMMG1_WERKS = RMMG1-WERKS
            WRMMG1_MATNR = RMMG1-MATNR
            no_w653      = x                    "ch/4.6
       IMPORTING
            WMARC_STLAL  = MARC-STLAL
            WMARC_STLAN  = MARC-STLAN
            WMARC_LOSGR  = MARC-LOSGR
            mess_w653    = kz_smess.            "ch/4.6

  if not kz_smess is initial.                   "ch/4.6
    MESSAGE W653.                               "
  endif.                                        "

ENDMODULE.
