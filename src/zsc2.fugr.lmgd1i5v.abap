*&---------------------------------------------------------------------*
*&      Module  SMEINH-MEABM  INPUT
*&---------------------------------------------------------------------*
*   Prüfen ob eine Mengeneinheit angegeben wurde                       *
*   analog zu SMEINH-GEWEI                                             *
*----------------------------------------------------------------------*
MODULE SMEINH-MEABM INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK SMEINH-MEINH NE SPACE.

*--- Festhalten der Eingaben -------------------------------------
  MEINH-LAENG = SMEINH-LAENG.
  MEINH-BREIT = SMEINH-BREIT.
  MEINH-HOEHE = SMEINH-HOEHE.
  MEINH-MEABM = SMEINH-MEABM.

  CHECK RMMZU-OKCODE NE FCODE_MEDE.

  CALL FUNCTION 'MEINH_MEABM'
       EXPORTING
            LAENG = SMEINH-LAENG
            BREIT = SMEINH-BREIT
            HOEHE = SMEINH-HOEHE
            MEABM = SMEINH-MEABM.
*      EXCEPTIONS       "cfo/29.10.95/besser positionieren
*           MISSING_DIMENSION = 01
*           WRONG_DIMENSION   = 02.
* IF SY-SUBRC NE 0.
*   CLEAR RMMZU-OKCODE.
*   IF BILDFLAG IS INITIAL.
*     BILDFLAG = X.
*     MOVE SY-STEPL TO ME_ZEILEN_NR.
*     MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   ENDIF.
* ENDIF.

ENDMODULE.                             " SMEINH-MEABM  INPUT
