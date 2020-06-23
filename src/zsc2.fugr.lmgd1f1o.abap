FORM MEAN_ME_TAB_AKT.
*   Verarbeitung im Dialog
* alt:  MEAN_ME_TAB-EAN11 = MEAN-EAN11.
* alt:  MEAN_ME_TAB-NUMTP = MEAN-EANTP.

* AHE: 19.07.96 - A
* wegen Fall: Falsche Meinh eingegeben und dann gelöscht -> es soll
* keine ganz leere Zeile in MEAN_ME_TAB übernommen werden !
  IF NOT SMEINH-MEINH IS INITIAL OR
     NOT MEAN-EAN11 IS INITIAL OR
     NOT MEAN-EANTP IS INITIAL.
* AHE: 19.07.96 - E
    MEAN_ME_TAB-MEINH     = SMEINH-MEINH.
    MEAN_ME_TAB-EAN11     = MEAN-EAN11.
    MEAN_ME_TAB-NUMTP     = MEAN-EANTP.
    MEAN_ME_TAB-HPEAN     = MEAN-HPEAN.
*   MEAN_ME_TAB-EAN_GEPRF = X.           " hier falsch
    IF EAN_AKT_ZEILE > EAN_LINES.
      APPEND MEAN_ME_TAB.
      EAN_LINES = EAN_LINES + 1.
    ELSE.
      MODIFY MEAN_ME_TAB INDEX EAN_AKT_ZEILE.
    ENDIF.

    MEAN_TAB_CHECK = X.

  ENDIF.                               " AHE: 19.07.96

ENDFORM.
