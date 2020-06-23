*------------------------------------------------------------------
*  Module MPOP-FIMON.
* Die Anzahl Fixierungsmonate darf nicht größer sein als die Anzahl
* der Prognoseperioden.
*------------------------------------------------------------------
MODULE MPOP-FIMON.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_FIMON'
       EXPORTING
            P_FIMON      = MPOP-FIMON
            P_ANZPR      = MPOP-ANZPR
            P_KZ_NO_WARN = ' '
* AHE: 29.10.98 - A (4.6a)
       IMPORTING
            P_FIMON      = MPOP-FIMON.
* AHE: 29.10.98 - E
*    EXCEPTIONS
*         P_ERR_MPOP_FIMON = 01.

ENDMODULE.
