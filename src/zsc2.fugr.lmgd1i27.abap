*------------------------------------------------------------------
*  Module MARC-SHFLG                    "ch zu 3.0d
*  Prüfung der Kalkulationslosgröße
*------------------------------------------------------------------
MODULE MARC-SHFLG.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_SHFLG'
       EXPORTING
            P_MARC_SHFLG = MARC-SHFLG
            P_MARC_SHZET = MARC-SHZET
            P_MARC_SHPRO = MARC-SHPRO
       EXCEPTIONS
            ERR_MESSAGE  = 1
            OTHERS       = 2.

  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    RMMZU-CURS_FELD = 'MARC-SHFLG'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMODULE.
