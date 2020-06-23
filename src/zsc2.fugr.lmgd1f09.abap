*&---------------------------------------------------------------------*
*&      Form  PRUEFEN_EINTRAG
*&---------------------------------------------------------------------*
*- Wurde ein gueltiger Sprachenschluessel eingegeben
*- Ist Sprachenschluessel gesetzt
*- Ist ein Kurztext gesetzt
*------------------------------------------------------------------
FORM PRUEFEN_EINTRAG.

  CHECK SKTEXT-SPRAS NE SPACE OR SKTEXT-MAKTX NE SPACE.
  KTEXT-VERFLG = AKTYPR.
  CHECK RMMZU-OKCODE NE FCODE_KTDE.
  CLEAR KTEXT-VERFLG.

  CHECK BILDFLAG_OLD IS INITIAL.

*------Sprachenschluessel gesetzt ?-----------------------------------
  IF SKTEXT-SPRAS = SPACE.
    BILDFLAG = X.
    MESSAGE S323(M3).
  ENDIF.

*------Kurztext gesetzt ?---------------------------------------------
  IF SKTEXT-MAKTX = SPACE.
    BILDFLAG = X.
    MESSAGE S324(M3).
  ENDIF.

* note 381890
  CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_INIT'
         EXCEPTIONS
              OTHERS  = 1.
  CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_SWITCH'
       EXPORTING
            NEED_LANG            = SKTEXT-SPRAS
       EXCEPTIONS
            LANGUAGE_NOT_ALLOWED = 1
            OTHERS               = 2.
  IF SY-SUBRC NE 0.
    MESSAGE S899(M3) WITH TEXT-005 SKTEXT-SPRAS TEXT-006 SY-HOST.
  ENDIF.
  CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_NORMAL'
       EXCEPTIONS
            OTHERS  = 1.
  CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_FINISH'
       EXCEPTIONS
            OTHERS              = 1.

ENDFORM.                    " PRUEFEN_EINTRAG
