*------------------------------------------------------------------
*  Module MARC-MRPPP.
*  Der Planungskalender muß im aktuellen oder im Refernzwerk definiert
*  sein.
*------------------------------------------------------------------
MODULE MARC-MRPPP.
  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Prüfung, ob gültiger Lieferrhythmus
  CALL FUNCTION 'MARC_MRPPP'
       EXPORTING
            P_MRPPP          = MARC-MRPPP
            P_WERKS          = MARC-WERKS
            P_MATNR          = MARC-MATNR
            P_DISLS          = MARC-DISLS     " JB/323673
            P_KZ_NO_WARN     = ' '
       EXCEPTIONS
            P_ERR_MARC_MRPPP = 1
            OTHERS           = 2.

  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    RMMZU-CURS_FELD = 'MARC-MRPPP'.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.
