*----------------------------------------------------------------------*
*   INCLUDE LMGD1F03                                                   *
*----------------------------------------------------------------------*
*-----------------------------------------------------------------------
*  TPROWF_ERWEITERN
*Erweitern der internen Tabelle TPROWF
*-----------------------------------------------------------------------
FORM TPROWF_ERWEITERN.

  DATA: H_PW_AKT_ZEILE LIKE PW_AKT_ZEILE.

  DESCRIBE TABLE TPROWF LINES H_PW_AKT_ZEILE.

  IF H_PW_AKT_ZEILE = 0.
    CLEAR TPROWF.
*   MOVE SY-DATUM TO DATUM.                       "ch zu 3.0d  - TIZO
    MOVE SY-DATLO TO DATUM.                       "
    PERFORM ERSTER_TAG_PERIODE USING DATUM ' '.
    MOVE DATUM TO TPROWF-ERTAG.
    APPEND TPROWF.
  ELSE.
    READ TABLE TPROWF INDEX H_PW_AKT_ZEILE.
    MOVE TPROWF-ERTAG TO DATUM.
    PERFORM NAECHSTE_PERIODE USING DATUM.
    CHECK T009B_ERROR = SPACE.
    CLEAR TPROWF.
    MOVE DATUM TO TPROWF-ERTAG.
    APPEND TPROWF.
  ENDIF.

ENDFORM.
