*------------------------------------------------------------------
*  Module MARC-LOSGR
*  Prüfung der Kalkulationslosgröße
*------------------------------------------------------------------
MODULE MARC-LOSGR.
  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_LOSGR_KALKULATION'
       EXPORTING
            WMBEW_PEINH     = MBEW-PEINH
            WMARC_LOSGR     = MARC-LOSGR
       EXCEPTIONS
            ERROR_NACHRICHT = 01.

  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    RMMZU-CURS_FELD = 'MARC-LOSGR'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMODULE.
