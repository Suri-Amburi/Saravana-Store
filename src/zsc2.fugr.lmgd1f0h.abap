* JH/20.03.98/4.0C Neues Sperrobj. für die Basismengeneinheit (Anfang)
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_VARIANTS
*&---------------------------------------------------------------------*
*       Neu zu 4.0C
*       Entsperren der Basismengeneinheit für alle Varianten zum
*       Sammelartikel.
*       Anmerkung:
*       Das Sperren erfolgt über eine generische Sperre auf der MARM,
*       d.h. im Prinzip sind alle ME zum Material gesperrt. Dies ist
*       deshalb notwendig, weil im FB MATERIAL_READ bzw.
*       MATERIAL_PRE_READ_MT06E die MARA erst nach dem Sperren
*       gelesen wird. Würde man bzgl. der konkreten Basismengeneinheit
*       sperren, müßten die MARA-Daten vor dem Setzen der Sperre
*       schon vorab gelesen werden.
*       -> Das Entsperren erfolgt ebenfalls generisch
*----------------------------------------------------------------------*
FORM DEQUEUE_VARIANTS USING P_SATNR LIKE MARA-SATNR.

DATA: HVAR_TAB LIKE SVARTAB OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'MATERIAL_READ_VAR_TAB'
       EXPORTING
            IMP_SATNR   = P_SATNR
       TABLES
            EXP_VAR_TAB = HVAR_TAB
       EXCEPTIONS
            WRONG_SATNR = 1
            OTHERS      = 2.
  LOOP AT HVAR_TAB WHERE FLGNEU IS INITIAL.
    CALL FUNCTION 'DEQUEUE_EMMARME'
         EXPORTING
              MATNR     = HVAR_TAB-VARNR.    "generisch alle ME
  ENDLOOP.

ENDFORM.                    " DEQUEUE_VARIANTS
