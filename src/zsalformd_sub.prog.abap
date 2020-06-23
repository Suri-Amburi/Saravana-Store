*&---------------------------------------------------------------------*
*& Include          ZSALFORMD_SUB
*&---------------------------------------------------------------------*

FORM GET_TABLEDATA.

  SELECT
        PERNR
        PERSG
        FROM PA0001 INTO TABLE IT_PA0001
        WHERE PERNR = PERNR-PERNR.

  SELECT PERSG
         PTEXT
          FROM T501T INTO TABLE IT_T501T
          FOR ALL ENTRIES IN IT_PA0001
          WHERE PERSG = IT_PA0001-PERSG.

ENDFORM.

FORM GET_FINAL.
*  BREAK-POINT.

  LOOP AT IT_PA0001 INTO WA_PA0001.
    SL = SL + 1.
    WA_FINAL-SL    = SL.
    WA_FINAL-PERNR = WA_PA0001-PERNR.
    WA_FINAL-PERSG = WA_PA0001-PERSG.

    IF WA_PA0001-PERSG = 'A'.
      COUNT = COUNT + 1.
      ELSEIF WA_PA0001-PERSG = 'B'.
        COUNT = COUNT + 1.
        ELSE.
           COUNT = COUNT + 1.
    ENDIF.

    READ TABLE IT_T501T INTO WA_T501T
    WITH KEY PERSG  = WA_PA0001-PERSG.
    IF SY-SUBRC = 0.
      WA_FINAL-PTEXT = WA_T501T-PTEXT.
    ENDIF.
*    COUNT = SL.
    WA_FINAL-COUNT = COUNT.
    APPEND WA_FINAL TO IT_FINAL.
    CLEAR:  WA_FINAL, COUNT.
  ENDLOOP.

  LOOP AT IT_FINAL INTO WA_FINAL.
    WA_ITEM-SL = WA_FINAL-SL.
    WA_ITEM-PTEXT = WA_FINAL-PTEXT.
    WA_ITEM-COUNT = WA_FINAL-COUNT.
    APPEND WA_ITEM TO IT_ITEM.
    CLEAR WA_ITEM.
  ENDLOOP.
  REFRESH IT_FINAL.

ENDFORM.
