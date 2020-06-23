*------------------------------------------------------------------
*  Module MPOP-PERIODS
* Prüfung ob die Anzahl der Perioden <= 60 ist
*------------------------------------------------------------------
MODULE MPOP-PERIODS.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_PERIODS'
       EXPORTING
            P_ANZPR      = MPOP-ANZPR
            P_PERAN      = MPOP-PERAN
            P_PERIN      = MPOP-PERIN
            P_PERIO      = MPOP-PERIO
            P_FIMON      = MPOP-FIMON
            P_KZ_NO_WARN = ' '.

ENDMODULE.
