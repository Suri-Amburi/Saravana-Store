*------------------------------------------------------------------
*           MARC-QMATA.
*
*Prüfung, ob der Benutzer berectigt ist
*- den bisherigen Wert zu ändern und
*- den neuen Wert anzugeben.
*------------------------------------------------------------------
MODULE MARC-QMATA.

 CHECK BILDFLAG IS INITIAL.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

 CALL FUNCTION 'MARC_QMATA'
      EXPORTING
           I_WERKS         = MARC-WERKS
           I_QMATAUTH      = MARC-QMATA
           I_QMATAUTH_RET  = LMARC-QMATA
      EXCEPTIONS
           ERROR_NACHRICHT = 01.
 IF SY-SUBRC NE 0.
    SET CURSOR FIELD 'MARC-QMATA'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 .
 ENDIF.


ENDMODULE.
