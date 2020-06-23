*&---------------------------------------------------------------------*
*&      Form  LESEN_MVKE_SEQ1
*&---------------------------------------------------------------------*
*       Lesen der Tabelle MVKE sequentiell
*------------------------------------------------------------------
FORM LESEN_MVKE_SEQ1.

  CALL FUNCTION 'MVKE_READ_WITH_MATNR'
       EXPORTING
            MATNR                = MARA-MATNR
*            KZRFB                = ' '
*            SPERRMODUS           = ' '
*            STD_SPERRMODUS       = ' '
       TABLES
            MVKE_TAB             = HMVKE_TAB
       EXCEPTIONS
            NOT_FOUND            = 1
            LOCK_ON_MVKE         = 2
            LOCK_SYSTEM_ERROR    = 3
            ENQUEUE_MODE_CHANGED = 4
            OTHERS               = 5.
  CHECK SY-SUBRC = 0.
  LOOP AT HMVKE_TAB WHERE VKORG NE MVKE-VKORG OR
                          VTWEG NE MVKE-VTWEG.
    MOVE HMVKE_TAB-VRKME TO HMEINH.
   PERFORM PRUEFEN_MEINH USING 'MM' 022 HMVKE_TAB-VKORG HMVKE_TAB-VTWEG
                                   SPACE.
    MOVE HMVKE_TAB-SCHME TO HMEINH.
   PERFORM PRUEFEN_MEINH USING 'MM' 027 HMVKE_TAB-VKORG HMVKE_TAB-VTWEG
                                   SPACE.
  ENDLOOP.

* CFO/09.01.96/umgestellt auf Puffer
*       SELECT * INTO HMVKE
*            FROM MVKE
*            WHERE MATNR = MARA-MATNR
*            AND ( VKORG  NE MVKE-VKORG OR VTWEG NE MVKE-VTWEG ).
*               MOVE HMVKE-VRKME TO HMEINH.
*               PERFORM PRUEFEN_MEINH.
*               MOVE HMVKE-SCHME TO HMEINH.
*               PERFORM PRUEFEN_MEINH.
*       ENDSELECT.

ENDFORM.
