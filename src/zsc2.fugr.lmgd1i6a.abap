*&---------------------------------------------------------------------*
*&      Module  INIT_EAN  INPUT
*&---------------------------------------------------------------------*
*       Sortiert die Loop-Tabelle MEAN_ME_TAB
*       Initialisiert diverse Flags u.a. BILDFLAG
*----------------------------------------------------------------------*
MODULE INIT_EAN INPUT.

  CLEAR: EAN_FEHLERFLG_ME, EAN_FEHLERFLG, MEAN_TAB_KEY,
* AHE: 23.08.96:
         MLEA_LFEAN_KEY, EAN_FEHLERFLG_LFEAN.

* Initialisieren von Fehlerflags und Key zum merken der Zeile mit Fehler

ENDMODULE.                             " INIT_EAN  INPUT
