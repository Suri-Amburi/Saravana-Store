*------------------------------------------------------------------
*    Module MARA-GEWEI.
*Prüfen ob eine ( richtige ) Gewichtseinheit angegeben wurde.
*------------------------------------------------------------------
MODULE MARA-GEWEI.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CALL FUNCTION 'MARA_GEWEI'
       EXPORTING
            NTGEW = MARA-NTGEW
            BRGEW = MARA-BRGEW
*mk/4.0 Kopie LMGD2I05 wieder mit Original LMGD1I01 vereint
*Im Retail-Fall erfolgen die Meldungen als S-Meldungen, im Industriefall
*wie bisher als Error-Meldungen
*           gewei = mara-gewei.
            GEWEI = MARA-GEWEI
       EXCEPTIONS
            MISSING_DIMENSION = 1
            WRONG_DIMENSION   = 2
            OTHERS            = 3.
  IF SY-SUBRC NE 0.
    IF RMMG2-FLG_RETAIL IS INITIAL.
      MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      BILDFLAG = X.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.
