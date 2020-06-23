*&---------------------------------------------------------------------*
*&      Module  SMEINH-VOLEH  INPUT
*&---------------------------------------------------------------------*
*  Prüfen ob eine ( richtige ) Volumeneinheit angegeben wurde.
*  Analog zu SMEINH-GEWEI
*----------------------------------------------------------------------*
MODULE SMEINH-VOLEH INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK SMEINH-MEINH NE SPACE.

*--- Festhalten der Eingaben -------------------------------------
  MEINH-VOLUM = SMEINH-VOLUM.
  MEINH-VOLEH = SMEINH-VOLEH.

  CHECK RMMZU-OKCODE NE FCODE_MEDE.

  CALL FUNCTION 'MARA_VOLEH'
       EXPORTING
            VOLUM = SMEINH-VOLUM
            VOLEH = SMEINH-VOLEH.

*      EXCEPTIONS                     "cfo/29.10.95/besser positionieren
*           MISSING_VOLUME = 01
*           WRONG_VOLUME   = 02.
* IF SY-SUBRC NE 0.
*   CLEAR RMMZU-OKCODE.
*   IF BILDFLAG IS INITIAL.
*     BILDFLAG = X.
*     MOVE SY-STEPL TO ME_ZEILEN_NR.
*     MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   ENDIF.
* ENDIF.

ENDMODULE.                             " SMEINH-VOLEH  INPUT
