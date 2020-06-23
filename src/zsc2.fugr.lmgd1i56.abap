*-----------------------------------------------------------------------
* Module MVKE-LFMNG
* Die Mindestliefermenge sollte nicht größer als die Mindestauftrags-
* menge sein.
*-----------------------------------------------------------------------
MODULE MVKE-LFMNG.

* kein'check bildflag = space' ,da Modul on request läuft
  CHECK BILDFLAG IS INITIAL.                              "mk/21.04.95
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.  "MK/21.04.95

  CALL FUNCTION 'MVKE_LFMNG'
       EXPORTING
            WMVKE_AUMNG = MVKE-AUMNG
            WMVKE_LFMNG = MVKE-LFMNG.

ENDMODULE.
