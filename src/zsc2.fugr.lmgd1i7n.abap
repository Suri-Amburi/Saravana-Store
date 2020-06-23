*----------------------------------------------------------------------*
***INCLUDE LMGD1I7N .
*----------------------------------------------------------------------*
*------------------------------------------------------------------
*  Module MARC-EISLO.
*  Pruefung der unteren Schranke des Sicherheitsbestandes
*------------------------------------------------------------------
MODULE MARC-EISLO.

* AHE: 13.01.99 - A (4.6a)
* neues Include und Modul
* AHE: 12.01.99 - E

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

   CALL FUNCTION 'MARC_EISBE_EISLO'
        EXPORTING
             P_EISBE                = MARC-EISBE
             P_EISLO                = MARC-EISLO
             P_DISMM                = MARC-DISMM  "ERP2005 09.03.05
*       TABLES
*            RETURN                 =
        EXCEPTIONS
             P_ERR_MARC_EISBE_EISLO = 1
             OTHERS                 = 2.

  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    RMMZU-CURS_FELD = 'MARC-EISLO'.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                 " MARC-EISLO  INPUT
