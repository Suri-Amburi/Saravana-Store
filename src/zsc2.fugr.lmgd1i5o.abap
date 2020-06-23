*&---------------------------------------------------------------------*
*&      Module  MARA_EAN11_EXIST INPUT
*&---------------------------------------------------------------------*
*       Prüfen, ob eine EAN zum Material vorhanden ist. Falls nicht,
*       Meldung (E, W oder keine Meldung, abhängig von Einstellung
*       Customizing)
*----------------------------------------------------------------------*
* AHE: 02.04.96 - A
MODULE MARA_EAN11_EXIST INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  CALL FUNCTION 'MARA_EAN11_EXIST'
       EXPORTING
            P_MATNR       = MARA-MATNR
            P_ATTYP       = MARA-ATTYP
            P_MESSAGE     = ' '
       TABLES
            MEINH         = MEINH
       EXCEPTIONS
            EAN_NOT_EXIST = 1
            OTHERS        = 2.

  IF SY-SUBRC NE 0.
*   CLEAR RMMZU-OKCODE.   "cfo/20.1.97 wird nicht benötigt
    IF BILDFLAG IS INITIAL.
      BILDFLAG = X.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
ENDMODULE.                             " MARA_EAN11_EXIST INPUT
