*&---------------------------------------------------------------------*
*&      Form  SET_UPDATE_TAB
*&---------------------------------------------------------------------*
*       Setzt Updatekennzeichen für angegebene Tabelle in PTAB
*----------------------------------------------------------------------*
FORM SET_UPDATE_TAB USING TAB.

  READ TABLE PTAB WITH KEY TAB.
  IF SY-SUBRC = 0.
    HTABIX = SY-TABIX.
    IF PTAB-UPDKZ IS INITIAL.
      PTAB-UPDKZ = X.
      MODIFY PTAB INDEX HTABIX.
    ENDIF.
  ENDIF.

ENDFORM.                               " SET_UPDATE_TAB
