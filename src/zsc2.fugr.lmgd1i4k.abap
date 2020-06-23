*------------------------------------------------------------------
*  Module MPOP-PRMAD.
* Der MAD/Fehlersumme ist nur bei bestimmten Prognosemodellen
* relevant. Ist er nicht relevant wird er mit einer
* Warnung zurückgesetzt.
*------------------------------------------------------------------
MODULE MPOP-PRMAD.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_PRMAD'
       EXPORTING
            P_PRMAD      = MPOP-PRMAD
            P_VMMAD      = MPOP-VMMAD
            P_FSUMM      = MPOP-FSUMM
            P_VMFSU      = MPOP-VMFSU
            P_PRMOD      = MPOP-PRMOD
            P_KZ_NO_WARN = ' '
       IMPORTING
            P_PRMAD      = MPOP-PRMAD
            P_VMMAD      = MPOP-VMMAD
            P_FSUMM      = MPOP-FSUMM
            P_VMFSU      = MPOP-VMFSU.
*      EXCEPTIONS
*           P_ERR_MPOP_PRMAD = 01.

ENDMODULE.
