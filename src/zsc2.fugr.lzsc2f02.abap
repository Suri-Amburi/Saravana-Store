************************************************************************
* Include LMGD2F02 - Formroutinen Steuerabwicklung Retail
************************************************************************

*----------------------------------------------------------------------*
*       Form  ST_MODIF_ZEILE                                           *
* Für die existierenden Einträge in der Steuertabelle sind             *
* Länderschlüssel und Steuertyp nicht mehr eingabebereit.              *
*----------------------------------------------------------------------*
FORM ST_MODIF_ZEILE.

  LOOP AT SCREEN.
    IF SCREEN-GROUP2 = '001'.
      SCREEN-INPUT    = 0.
      SCREEN-REQUIRED = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ST_MODIF_ZEILE

*----------------------------------------------------------------------*
*       Form  OK_CODE_STEUERN                                          *
*----------------------------------------------------------------------*
FORM OK_CODE_STEUERN.

  CASE RMMZU-OKCODE.
*----- Verlassen des Bildes ------------------------------------------
       WHEN FCODE_BABA.
            CLEAR RMMG2-FLGSTEUER.     "Zurücksetzen Steuerflag
*----- Erste Seite - Steuern First Page ------------------------------
       WHEN FCODE_STFP.
            PERFORM FIRST_PAGE USING ST_ERSTE_ZEILE.
*----- Seite vor - Steuern Next Page ---------------------------------
       WHEN FCODE_STNP.
           PERFORM NEXT_PAGE USING ST_ERSTE_ZEILE ST_ZLEPROSEITE
                                   ST_LINES.
*----- Seite zurueck - Steuern Previous Page -------------------------
       WHEN FCODE_STPP.
            PERFORM PREV_PAGE USING ST_ERSTE_ZEILE ST_ZLEPROSEITE.
*----- Bottom - Steuern Last Page ------------------------------------
       WHEN FCODE_STLP.
           PERFORM LAST_PAGE USING ST_ERSTE_ZEILE ST_LINES
                                   ST_ZLEPROSEITE SPACE.
*----- SPACE - Enter -------------------------------------------------
       WHEN FCODE_SPACE.
            CLEAR RMMG2-FLGSTEUER.     "Zurücksetzen Steuerflag
* ---- Sonstige Funktionen wie Springen etc. --------------------------
       WHEN OTHERS.
            CLEAR RMMG2-FLGSTEUER.     "Zurücksetzen Steuerflag
  ENDCASE.

ENDFORM.                    " OK_CODE_STEUERN
*&---------------------------------------------------------------------*
*&      Form  MARA_TAKLV_ACTIVE
*&---------------------------------------------------------------------*
*       <<added by note 2533608>>
*       check, if MARA-TAKLV is hidden/display only or ready for input
*----------------------------------------------------------------------*
*  <->  P_ACTIVE    TRUE if MARA-TAKLV is active
*----------------------------------------------------------------------*
FORM MARA_TAKLV_ACTIVE CHANGING P_ACTIVE TYPE BOOLEAN.

  STATICS: LV_ACTIVE          TYPE BOOLEAN,
           LV_CHECKED         TYPE BOOLEAN,
           LV_ARTICLE_REF_RT  TYPE REF TO IF_EX_BADI_ARTICLE_REF_RT,
           LV_ARTICLE_REF_AKT LIKE SY-BATCH,
           LV_DO_NOT_REDUCE   LIKE SY-BATCH.

  DATA: BEGIN OF FGRUP_INACT OCCURS 50.
          INCLUDE STRUCTURE MFGRUP.
  DATA: END OF FGRUP_INACT.

  IF LV_CHECKED = X. "already checked
    P_ACTIVE = LV_ACTIVE.
    RETURN.
  ENDIF.

  "field selection
  READ TABLE IT130F WITH KEY FNAME = 'MARA-TAKLV' BINARY SEARCH.

  IF SY-SUBRC <> 0. "removed from further processing by field selection
    P_ACTIVE    = ''.
    LV_ACTIVE   = ''.
    LV_CHECKED  = 'X'.
    RETURN.
  ENDIF.

  "inactive field selection groups
  CALL FUNCTION 'MATERIAL_FIELD_SELECTION_INACT'
    TABLES
      FGRUP_INACT_TAB = FGRUP_INACT.

  IF FGRUP_INACT[] IS INITIAL. "no inactive field selection groups
    P_ACTIVE    = 'X'.
    LV_ACTIVE   = 'X'.
    LV_CHECKED  = 'X'.
    RETURN.
  ENDIF.

  "check for field selection group of MARA-TAKLV
  READ TABLE FGRUP_INACT WITH KEY FGRUP = IT130F-FGRUP BINARY SEARCH.

  IF sy-subrc <> 0. "MARA-TAKLV is ready for input
    P_ACTIVE    = 'X'.
    LV_ACTIVE   = 'X'.
    LV_CHECKED  = 'X'.
    RETURN.
  ENDIF.

*MARA-TAKLV not ready for input
*check if reactivated through Badi
  IF LV_ARTICLE_REF_RT IS INITIAL.
    "get object instance of Badi
    CALL METHOD CL_EXITHANDLER=>GET_INSTANCE           "#EC CI_BADI_OLD
      EXPORTING                                    "#EC CI_BADI_GETINST
          EXIT_NAME                   = 'BADI_ARTICLE_REF_RT'
       IMPORTING
        ACT_IMP_EXISTING              = LV_ARTICLE_REF_AKT
      CHANGING
        INSTANCE                      = LV_ARTICLE_REF_RT
      EXCEPTIONS
        OTHERS                        = 9
           .
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      "error occurred
      RETURN.
    ENDIF.
  ENDIF.

  CLEAR LV_DO_NOT_REDUCE.
  IF NOT LV_ARTICLE_REF_AKT IS INITIAL.
    CALL METHOD LV_ARTICLE_REF_RT->ADD_INACTIVE_FIELDS
      EXPORTING
        FIELD_NAME    = IT130F-FNAME
      CHANGING
        DO_NOT_REDUCE = LV_DO_NOT_REDUCE
        .
  ENDIF.

  IF SY-SUBRC = 0.
    IF LV_DO_NOT_REDUCE = X.
      P_ACTIVE    = 'X'.
      LV_ACTIVE   = 'X'.
      LV_CHECKED  = 'X'.
    ELSE.
      P_ACTIVE    = ''.
      LV_ACTIVE   = ''.
      LV_CHECKED  = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.
