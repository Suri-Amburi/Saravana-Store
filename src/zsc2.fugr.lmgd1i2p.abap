*------------------------------------------------------------------
*  Module MARC-LFRHY.
*  Der Disporythmus muß im aktuellen oder im Refernzwerk definiert
*  sein.
*  Bei rythmischer Dispo ist MARC-LFRHY ein Mußfeld
*------------------------------------------------------------------
MODULE MARC-LFRHY.
  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Prüfung, ob gültiger Lieferrhythmus
  CALL FUNCTION 'MARC_LFRHY'
       EXPORTING
            P_LFRHY          = MARC-LFRHY
            P_WERKS          = MARC-WERKS
            P_T438A_DISVF    = T438A-DISVF
       EXCEPTIONS
            P_ERR_MARC_LFRHY = 1
            OTHERS           = 2.

  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    RMMZU-CURS_FELD = 'MARC-LFRHY'.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.
