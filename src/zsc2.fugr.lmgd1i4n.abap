*------------------------------------------------------------------
*  Module MPOP-PERIN.
* Die Anzahl Initialisierungsperioden darf nicht größer sein als die
* Anzahl der Verbräuche.
*------------------------------------------------------------------
MODULE MPOP-PERIN.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_PERIN'
       EXPORTING
            P_PERIN      = MPOP-PERIN
            P_PERAN      = MPOP-PERAN
            P_KZ_NO_WARN = ' '.
*    EXCEPTIONS
*         P_ERR_MPOP_PERIN = 01.

ENDMODULE.
