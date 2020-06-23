*------------------------------------------------------------------
*  Module MARC-DISMM.
*  Pruefung des Dispositionsmerkmals.
*------------------------------------------------------------------
MODULE MARC-DISMM.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*mk/3.0C Prüfung nur sinnvoll, wenn MARC überhaupt aktiv ist, speziell
*Fehlermeldung, wenn initial (analog zum material_update_all)
  CHECK AKTVSTATUS CA STATUS_D.
  CHECK NOT RMMG1-WERKS IS INITIAL.                     "cfo/4.0C

  CALL FUNCTION 'MARC_DISMM'
       EXPORTING
            P_LDISMM     = LMARC-DISMM
            P_DISMM      = MARC-DISMM
            P_FXHOR      = MARC-FXHOR
            P_DISGR      = MARC-DISGR
            P_AKTYP      = T130M-AKTYP
            P_WERKS      = RMMG1-WERKS
            P_MTART      = RMMG1-MTART
            P_KZ_NO_WARN = ' '
       IMPORTING
            WT438A       = T438A
            WV134W       = V134W
       TABLES
            MPTAB        = PTAB.       " AHE: 04.10.95
*      EXCEPTIONS
*           ERR_MARC_DISMM = 01
*           ERR_T438M      = 02
*           ERR_T438A      = 03.

  IF NOT RMMG2-FLG_RETAIL IS INITIAL AND
     FLG_PRUEFDUNKEL IS INITIAL.
    CALL FUNCTION 'SET_WRPL_LIKE_MARC'
         EXPORTING
              P_MARC  = MARC
              P_LMARC = LMARC.
  ENDIF.



ENDMODULE.
