*------------------------------------------------------------------
*  Module MARC-RGEKZ
*  Pruefung des Kennzeichen Retrograde Entnahme        neu zu 30e/ch
*------------------------------------------------------------------
MODULE MARC-RGEKZ.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_RGEKZ'
       EXPORTING
            P_SERNP = MARC-SERNP
            P_RGEKZ = MARC-RGEKZ
            P_BWTAR = MBEW-BWTAR.
*      EXCEPTIONS
*           SERNP_OBL = 1
*           OTHERS    = 2.

ENDMODULE.
