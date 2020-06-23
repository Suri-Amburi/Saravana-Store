*&---------------------------------------------------------------------*
*& Include          ZSALFORMS_SUB
*&---------------------------------------------------------------------*

FORM GET_TABLEDATA.
  SELECT  PERNR
          BEGDA
          FROM PA0000 INTO TABLE IT_PA0000
          WHERE PERNR = PERNR-PERNR.

  IF IT_PA0000 IS NOT INITIAL.
    SELECT  PERNR
            ENAME
            PERSK
            PERSG
            FROM PA0001 INTO TABLE IT_PA0001
            FOR ALL ENTRIES IN IT_PA0000
            WHERE PERNR = IT_PA0000-PERNR.

    SELECT  PERNR
            SCHKZ
            FROM PA0007 INTO TABLE IT_PA0007
            FOR ALL ENTRIES IN IT_PA0000
            WHERE PERNR = IT_PA0000-PERNR.

    SELECT  PERNR
            FAMSA
            FAVOR
            FANAM
            FROM PA0021 INTO TABLE IT_PA0021
            FOR ALL ENTRIES IN IT_PA0000
            WHERE PERNR = IT_PA0000-PERNR.

    SELECT  PERNR
            LTIME
            FROM TEVEN INTO TABLE IT_TEVEN
            FOR ALL ENTRIES IN IT_PA0000
            WHERE PERNR = IT_PA0000-PERNR.

    SELECT  SPRSL
            INFTY
            SUBTY
            STEXT
            FROM T591S INTO TABLE IT_T591S
            FOR ALL ENTRIES IN IT_PA0021
            WHERE SPRSL = SY-LANGU
            AND INFTY = '0021'
            AND SUBTY  = IT_PA0021-FAMSA.

    SELECT PERSG
           PTEXT
           FROM T501T INTO TABLE IT_T501T
           FOR ALL ENTRIES IN IT_PA0001
           WHERE PERSG = IT_PA0001-PERSG.

    SELECT PERSK
           PTEXT
           FROM T503T INTO TABLE IT_T503T
           FOR ALL ENTRIES IN IT_PA0001
           WHERE PERSK  = IT_PA0001-PERSK.

  ENDIF.
ENDFORM.

FORM GET_FINAL.
*  IF IT_PA0000 IS NOT INITIAL.
*    CLEAR : SL.

  LOOP AT IT_PA0000 INTO WA_PA0000.
    SL = SL + 1.
    WA_FINAL-SL    = SL.
    WA_FINAL-PERNR = WA_PA0000-PERNR.
    WA_FINAL-BEGDA = WA_PA0000-BEGDA.
    WA_FINAL-HOLIDAY = ''.
    WA_FINAL-MAXIMUM = ''.

    READ TABLE IT_PA0001 INTO WA_PA0001 WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
      WA_FINAL-ENAME = WA_PA0001-ENAME.
*      WA_FINAL-PERSK = WA_PA0001-PERSK.
*      WA_FINAL-PERSG = WA_PA0001-PERSG.
    ENDIF.

    READ TABLE IT_PA0007 INTO WA_PA0007 WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
      WA_FINAL-SCHKZ = WA_PA0007-SCHKZ.
    ENDIF.

*    BREAK-POINT.
    READ TABLE IT_PA0021 INTO WA_PA0021
     WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
*      WA_FINAL-FAMSA = WA_PA0021-FAMSA.
      CONCATENATE WA_PA0021-FAVOR WA_PA0021-FANAM INTO WA_FINAL-NOMINEE SEPARATED BY ' '.
    ENDIF.

    READ TABLE IT_TEVEN INTO WA_TEVEN WITH KEY PERNR = WA_PA0000-PERNR.
    IF SY-SUBRC = 0.
      WA_FINAL-LTIME = WA_TEVEN-LTIME.
    ENDIF.
*
*    READ TABLE IT_T591S INTO WA_T591S WITH KEY SUBTY  = WA_PA0021-FAMSA.
*    IF SY-SUBRC = 0.
**      WA_FINAL-NAME = WA_T591S-STEXT.
**      CONCATENATE WA_FINAL-NAME WA_FINAL-NOMINEE INTO WA_FINAL-RELATION SEPARATED BY '/'.    "relation of nominee
*    ENDIF.

    READ TABLE IT_T501T INTO WA_T501T WITH KEY PERSG  = WA_PA0001-PERSG.
    IF SY-SUBRC = 0.
      WA_FINAL-PTEXT = WA_T501T-PTEXT.
    ENDIF.

    READ TABLE IT_T503T INTO WA_T503T WITH KEY PERSK  = WA_PA0001-PERSK.
    IF SY-SUBRC = 0.
      WA_FINAL-PTEXT1 = WA_T503T-PTEXT.
    ENDIF.

    APPEND WA_FINAL TO IT_FINAL.
    CLEAR WA_FINAL.

  ENDLOOP.
ENDFORM.


FORM FIELD_CATALOG.
*  REFRESH IT_FCAT.
*  DATA LV_COL TYPE I VALUE 0.
*  IF IT_FINAL IS NOT INITIAL.

*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'sl'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'SERIAL NUMBER'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'PERNR'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'EMPLOYEE NUMBER'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'ENAME'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'NAME OF THE PERSON EMPLOYEED'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'NOMINEE'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'FATHERS/HUSBAND NAME'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'PTEXT1'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'DESIGNATION'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'BEGDA'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'DATE OF ENTRY'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'BLANK'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'Adult/ Adolescent/Child'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'SCHKZ'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'Shift No'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'LTIME'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'Time of Commencement'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'BLANK'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'Rest Interval'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'ENDUZ'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'Time at which Work'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'BLANK'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'Weekly Holiday'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'PTEXT'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'Class of Workers'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.
*
*    LV_COL            = LV_COL + 1.
*    WA_FCAT-COL_POS   = LV_COL.
*    WA_FCAT-FIELDNAME = 'BLANK'.
*    WA_FCAT-TABNAME   = 'IT_FINAL'.
*    WA_FCAT-SELTEXT_L = 'Maximum'.
*    APPEND WA_FCAT TO IT_FCAT.
*    CLEAR WA_FCAT.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
*     I_INTERNAL_TABNAME     = it_final
      I_STRUCTURE_NAME       = 'ZSAL_STR'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      CT_FIELDCAT            = IT_FCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

*  ENDIF.
ENDFORM.