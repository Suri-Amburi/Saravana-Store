*&---------------------------------------------------------------------*
*&      Form  LESEN_MARC_SEQ2
*&---------------------------------------------------------------------*
*       Lesen der Tabelle MARC sequentiell
*------------------------------------------------------------------
FORM LESEN_MARC_SEQ2.

  CALL FUNCTION 'MARC_READ_WITH_MATNR'
       EXPORTING
            MATNR  = MARA-MATNR
       EXCEPTIONS
            OTHERS = 1.
  CALL FUNCTION 'LESEN_MARC_PUFFER_ZU_MATNR'
       EXPORTING
            MATNR           = MARA-MATNR
*      IMPORTING
*           MATNR_MARC_READ =
       TABLES
*           MARC_MATNR_TAB  = HMARC_TAB     "cfo/29.6.96 war falsch
            MARC_TAB        = HMARC_TAB
       EXCEPTIONS
            OTHERS          = 1.
  CHECK SY-SUBRC = 0.
  LOOP AT HMARC_TAB.
    MOVE HMARC_TAB-AUSME TO HMEINH.
    PERFORM PRUEFEN_MEINH USING 'MM' 021 HMARC_TAB-WERKS SPACE SPACE.
    MOVE HMARC_TAB-EXPME TO HMEINH.
    PERFORM PRUEFEN_MEINH USING 'MM' 024 HMARC_TAB-WERKS SPACE SPACE.
    MOVE HMARC_TAB-FRTME TO HMEINH.                         "K11K077621
    PERFORM PRUEFEN_MEINH USING 'MM' 023 HMARC_TAB-WERKS    "K11K077621
                                 SPACE SPACE.
  ENDLOOP.

*CFO/09.01.96/umstellen auf Lesen aus Puffer
*      SELECT * INTO HMARC
*           FROM MARC
*           WHERE MATNR = HMARA-MATNR.
*              MOVE HMARC-AUSME TO HMEINH.
*              PERFORM PRUEFEN_MEINH.
*              MOVE HMARC-EXPME TO HMEINH.
*              PERFORM PRUEFEN_MEINH.
*              MOVE HMARC-FRTME TO HMEINH.             "K11K077621
*              PERFORM PRUEFEN_MEINH.                  "K11K077621
*      ENDSELECT.

ENDFORM.
