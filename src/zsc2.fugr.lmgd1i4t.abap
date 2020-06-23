*------------------------------------------------------------------
*  Module MPOP-GLATT.
* Bie Glättungsfaktoren sind nur bei bestimmten Prognosemodellen
* relevant. Ist ein Glättungsfaktor nicht relevant wird er mit einer
* Warnung zurückgesetzt.
* Wird ein Faktor bei einem Modell benötigt, wurde aber nichts eingege-
* ben, erfolgt keine Warnung. Das Prognosemodul rechnet dann mit den
* Standardwerten.
*------------------------------------------------------------------
MODULE MPOP-GLATT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

* Prüfstatus zurücksetzen, falls relevante Felder geändert wurden.
  IF ( RMMZU-PS_ALPHA = X ) AND
     ( ( UMPOP-PRMOD NE MPOP-PRMOD ) OR
       ( UMPOP-ALPHA NE MPOP-ALPHA ) ).
    CLEAR RMMZU-PS_ALPHA.
  ENDIF.
  IF ( RMMZU-PS_BETA1 = X ) AND
     ( ( UMPOP-PRMOD NE MPOP-PRMOD ) OR
       ( UMPOP-MODAW NE MPOP-MODAW ) OR
       ( UMPOP-BETA1 NE MPOP-BETA1 ) ).
    CLEAR RMMZU-PS_BETA1.
  ENDIF.
  IF ( RMMZU-PS_GAMMA = X ) AND
     ( ( UMPOP-PRMOD NE MPOP-PRMOD ) OR
       ( UMPOP-MODAW NE MPOP-MODAW ) OR
       ( UMPOP-GAMMA NE MPOP-GAMMA ) ).
    CLEAR RMMZU-PS_GAMMA.
  ENDIF.
  IF ( RMMZU-PS_DELTA = X ) AND
     ( ( UMPOP-PRMOD NE MPOP-PRMOD ) OR
       ( UMPOP-DELTA NE MPOP-DELTA ) ).
    CLEAR RMMZU-PS_DELTA.
  ENDIF.
* Note 316843
* Da im Retail von einem auf einen anderen Betrieb bzw. von der VZ-Sicht
* auf die Filialsicht gewechselt werden kann, müssen auch die
* Schlüsselfelder in den Vergleich miteinbezogen werden, weil ansonsten
* die Prüfung für den anderen Betrieb nicht mehr läuft, wenn die Prüfung
* schon für den vorangegangen Betrieb gelaufen ist und die Daten bei
* beiden Betrieben den gleichen Stand haben.
  IF ( UMPOP-MATNR NE MPOP-MATNR ) OR
     ( UMPOP-WERKS NE MPOP-WERKS ) .
    CLEAR RMMZU-PS_ALPHA.
    CLEAR RMMZU-PS_BETA1.
    CLEAR RMMZU-PS_GAMMA.
    CLEAR RMMZU-PS_DELTA.
  ENDIF.

* Wenn einer der Prüfstatus nicht gesetzt ist, Prüfbaustein aufrufen.
* Bem.: Der Prüfstatus bezieht sich nur auf Warnungen.

* Bem.: weil die Prüfstatus das Setzen des Bildflags beeinflussen,
* muß der Aufruf des FBs MPOP_GLATT jeweils einzeln für jeden
* Prüfstatus ausgeführt werden (AHE: 31.05.95).

  IF RMMZU-PS_ALPHA IS INITIAL.
    CALL FUNCTION 'MPOP_GLATT'
         EXPORTING
              P_PRMOD      = MPOP-PRMOD
              P_PROPR      = MPOP-PROPR
              P_MODAW      = MPOP-MODAW
              P_KZRFB      = KZRFB
              P_ALPHA      = MPOP-ALPHA
              P_BETA1      = MPOP-BETA1
              P_GAMMA      = MPOP-GAMMA
              P_DELTA      = MPOP-DELTA
              P_PS_ALPHA   = RMMZU-PS_ALPHA
              P_PS_BETA1   = RMMZU-PS_BETA1
              P_PS_GAMMA   = RMMZU-PS_GAMMA
              P_PS_DELTA   = RMMZU-PS_DELTA
              P_KZ_NO_WARN = ' '
         IMPORTING
              P_ALPHA      = MPOP-ALPHA
              P_BETA1      = MPOP-BETA1
              P_GAMMA      = MPOP-GAMMA
              P_DELTA      = MPOP-DELTA
              P_PS_ALPHA   = RMMZU-PS_ALPHA
              P_PS_BETA1   = RMMZU-PS_BETA1
              P_PS_GAMMA   = RMMZU-PS_GAMMA
              P_PS_DELTA   = RMMZU-PS_DELTA.
*      EXCEPTIONS
*           P_ERR_MPOP_GLATT = 01.
* Warnungen als S-Meldung ausgeben, da mehrere Felder betroffen sind.
    IF RMMZU-PS_ALPHA NE SPACE.
      BILDFLAG = X.
      MESSAGE S469.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMPOP = MPOP.
    ENDIF.
  ELSE.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung
* durchführen, keine Warnung ausgeben (im Prüfbaustein wird nach den
* Warnungen aufgesetzt). Da nach der Warnung keine Aktionen im Prüf-
* baustein stattfinden, kann dieser Zweig hier entfallen.
  ENDIF.

  CHECK BILDFLAG = SPACE.
* Falls vorher eine Warnung ausgegben wurde, folgende Warnungen
* übergehen.
  IF RMMZU-PS_BETA1 IS INITIAL.
    CALL FUNCTION 'MPOP_GLATT'
         EXPORTING
              P_PRMOD      = MPOP-PRMOD
              P_PROPR      = MPOP-PROPR
              P_MODAW      = MPOP-MODAW
              P_KZRFB      = KZRFB
              P_ALPHA      = MPOP-ALPHA
              P_BETA1      = MPOP-BETA1
              P_GAMMA      = MPOP-GAMMA
              P_DELTA      = MPOP-DELTA
              P_PS_ALPHA   = RMMZU-PS_ALPHA
              P_PS_BETA1   = RMMZU-PS_BETA1
              P_PS_GAMMA   = RMMZU-PS_GAMMA
              P_PS_DELTA   = RMMZU-PS_DELTA
              P_KZ_NO_WARN = ' '
         IMPORTING
              P_ALPHA      = MPOP-ALPHA
              P_BETA1      = MPOP-BETA1
              P_GAMMA      = MPOP-GAMMA
              P_DELTA      = MPOP-DELTA
              P_PS_ALPHA   = RMMZU-PS_ALPHA
              P_PS_BETA1   = RMMZU-PS_BETA1
              P_PS_GAMMA   = RMMZU-PS_GAMMA
              P_PS_DELTA   = RMMZU-PS_DELTA.
*      EXCEPTIONS
*           P_ERR_MPOP_GLATT = 01.
    IF RMMZU-PS_BETA1 NE SPACE.
      BILDFLAG = X.
      MESSAGE S470.
      UMPOP = MPOP.
    ENDIF.
  ELSE.
* Dieser Zweig kann hier entfallen.
  ENDIF.

  CHECK BILDFLAG = SPACE.
* Falls vorher eine Warnung ausgegben wurde, folgende Warnungen
* übergehen.
  IF RMMZU-PS_GAMMA IS INITIAL.
    CALL FUNCTION 'MPOP_GLATT'
         EXPORTING
              P_PRMOD      = MPOP-PRMOD
              P_PROPR      = MPOP-PROPR
              P_MODAW      = MPOP-MODAW
              P_KZRFB      = KZRFB
              P_ALPHA      = MPOP-ALPHA
              P_BETA1      = MPOP-BETA1
              P_GAMMA      = MPOP-GAMMA
              P_DELTA      = MPOP-DELTA
              P_PS_ALPHA   = RMMZU-PS_ALPHA
              P_PS_BETA1   = RMMZU-PS_BETA1
              P_PS_GAMMA   = RMMZU-PS_GAMMA
              P_PS_DELTA   = RMMZU-PS_DELTA
              P_KZ_NO_WARN = ' '
         IMPORTING
              P_ALPHA      = MPOP-ALPHA
              P_BETA1      = MPOP-BETA1
              P_GAMMA      = MPOP-GAMMA
              P_DELTA      = MPOP-DELTA
              P_PS_ALPHA   = RMMZU-PS_ALPHA
              P_PS_BETA1   = RMMZU-PS_BETA1
              P_PS_GAMMA   = RMMZU-PS_GAMMA
              P_PS_DELTA   = RMMZU-PS_DELTA.
*      EXCEPTIONS
*           P_ERR_MPOP_GLATT = 01.
    IF RMMZU-PS_GAMMA NE SPACE.
      BILDFLAG = X.
      MESSAGE S471.
      UMPOP = MPOP.
    ENDIF.
  ELSE.
* Dieser Zweig kann hier entfallen.
  ENDIF.

  CHECK BILDFLAG = SPACE.
* Falls vorher eine Warnung ausgegben wurde, folgende Warnungen
* übergehen.
  IF RMMZU-PS_DELTA IS INITIAL.
    CALL FUNCTION 'MPOP_GLATT'
         EXPORTING
              P_PRMOD      = MPOP-PRMOD
              P_PROPR      = MPOP-PROPR
              P_MODAW      = MPOP-MODAW
              P_KZRFB      = KZRFB
              P_ALPHA      = MPOP-ALPHA
              P_BETA1      = MPOP-BETA1
              P_GAMMA      = MPOP-GAMMA
              P_DELTA      = MPOP-DELTA
              P_PS_ALPHA   = RMMZU-PS_ALPHA
              P_PS_BETA1   = RMMZU-PS_BETA1
              P_PS_GAMMA   = RMMZU-PS_GAMMA
              P_PS_DELTA   = RMMZU-PS_DELTA
              P_KZ_NO_WARN = ' '
         IMPORTING
              P_ALPHA      = MPOP-ALPHA
              P_BETA1      = MPOP-BETA1
              P_GAMMA      = MPOP-GAMMA
              P_DELTA      = MPOP-DELTA
              P_PS_ALPHA   = RMMZU-PS_ALPHA
              P_PS_BETA1   = RMMZU-PS_BETA1
              P_PS_GAMMA   = RMMZU-PS_GAMMA
              P_PS_DELTA   = RMMZU-PS_DELTA.
*      EXCEPTIONS
*           P_ERR_MPOP_GLATT = 01.
    IF RMMZU-PS_DELTA NE SPACE.
      BILDFLAG = X.
      MESSAGE S472.
      UMPOP = MPOP.
    ENDIF.
  ELSE.
* Dieser Zweig kann hier entfallen.
  ENDIF.

ENDMODULE.
