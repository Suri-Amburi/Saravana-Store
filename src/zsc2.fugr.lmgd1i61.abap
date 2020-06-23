*&---------------------------------------------------------------------*
*&      Module  RM03E-MEGRP  INPUT
*&---------------------------------------------------------------------*
*     Pruefen Eintrag gegen Tabelle T006M.
*     Uebernahme der Daten in interne Tabelle.
*----------------------------------------------------------------------*
MODULE RM03E-MEGRP INPUT.

  DATA: BEGIN OF T006M_TAB      OCCURS 0.
          INCLUDE STRUCTURE T006M.
  DATA: END   OF T006M_TAB.

  CHECK RM03E-MEGRP NE SPACE.

*-------Pruefen Eintrag und Uebernahme der Daten-----------------

  CALL FUNCTION 'T006M_GENREAD_MEINH'
       EXPORTING
            T006M_MEGRP         = RM03E-MEGRP
       TABLES
            T006M_TAB_GEN_MEINH = T006M_TAB
       EXCEPTIONS
            NOT_FOUND           = 01.
  IF SY-SUBRC NE 0.
*   CLEAR RMMZU-OKCODE.       "cfo/20.1.97 wird nicht benötigt
    CHECK BILDFLAG IS INITIAL.
    MESSAGE E335 WITH RM03E-MEGRP.
  ELSE.
    LOOP AT T006M_TAB.
      CLEAR MEINH.                     "Korr. zu 2.1B      HAUCK
      MOVE-CORRESPONDING T006M_TAB TO MEINH.
      MEINH-DOPFLG = X.
      APPEND MEINH.
    ENDLOOP.
  ENDIF.

  CLEAR RM03E-MEGRP.

ENDMODULE.                             " RM03E-MEGRP  INPUT
