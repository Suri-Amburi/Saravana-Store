*&---------------------------------------------------------------------*
*&      Module  RM03E-ZEANS  OUTPUT
*&---------------------------------------------------------------------*
*   Setzen Kennzeichen 'referentielle EANs vorhanden' auf dem Popup    *
*   'Europäische Artikelnummer'                                        *
*----------------------------------------------------------------------*
MODULE RM03E-ZEANS OUTPUT.

  CLEAR RM03E-ZEANS.
  CHECK NOT SMEINH-EAN11 IS INITIAL.
  READ TABLE MEAN_ME_TAB WITH KEY SMEINH-MEINH BINARY SEARCH.
  IF SY-SUBRC = 0.
    HTABIX = SY-TABIX + 1.
    READ TABLE MEAN_ME_TAB INDEX HTABIX.
    IF MEAN_ME_TAB-MEINH = SMEINH-MEINH AND SY-SUBRC = 0.
*     Zur ME existieren mind. 2 EANs ==> entspr. Kennz. setzen
      RM03E-ZEANS = X.
    ENDIF.
  ENDIF.

ENDMODULE.                             " RM03E-ZEANS  OUTPUT
