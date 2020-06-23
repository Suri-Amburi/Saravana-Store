*------------------------------------------------------------------
*  Module D250_PERKZ
* Will der Benutzer Verbrauchswerte pflegen, muß das Periodenkenn-
* zeichen gesetzt sein.
* Will der Benutzer Prognosewerte pflegen, muß das Periodenkenn-
* zeichen gesetzt sein.
*------------------------------------------------------------------
MODULE D250_PERKZ.

  CHECK BILDFLAG IS INITIAL.           "mk/18.04.95
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.  "mk/18.04.95

  CALL FUNCTION 'D_250_PERKZ'
       EXPORTING
            P_PERKZ    = MARC-PERKZ
            P_OK_CODE  = RMMZU-OKCODE  " vorher OK-CODE
            P_BILDS    = BILDSEQUENZ   "mk/3.1G neu
       IMPORTING
            P_BILDFLAG = BILDFLAG      "mk/3.1G neu
       CHANGING
            MPOP_PERKZ = MPOP-PERKZ.   " AHE: 14.01.97
*    EXCEPTIONS
*         P_ERR_D_250_PERKZ = 01.
*mk/3.1G okcode zurücksetzen, damit man nach der S-Meldung bei DF
*weiterkommt
  IF NOT BILDFLAG IS INITIAL.
    CLEAR RMMZU-OKCODE.
  ENDIF.

ENDMODULE.
