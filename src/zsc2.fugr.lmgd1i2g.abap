*------------------------------------------------------------------
*    Module MARC-LZEIH.
*Prüfen ob eine ( richtige ) Zeiteinheit angegeben wurde.
*------------------------------------------------------------------
MODULE MARC-LZEIH.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_LZEIH'
       EXPORTING
            MARC_IN_MAXLZ   = MARC-MAXLZ
            MARC_IN_LZEIH   = MARC-LZEIH
       EXCEPTIONS
            ERROR_NACHRICHT = 01
            ERROR_LZEIH     = 02.

  IF SY-SUBRC NE 0.
    SET CURSOR FIELD 'MARC-LZEIH'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.
