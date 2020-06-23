*&---------------------------------------------------------------------*
*&      Form  PRUEFEN_MARC_MEINH
*&---------------------------------------------------------------------*
FORM PRUEFEN_MEINH USING MSGID LIKE SY-MSGID   "cfo/11.9.96
                         MSGNO LIKE SY-MSGNO   "detailiertere Message
                         MSGV2 type clike
                         MSGV3 type clike
                         MSGV4 type clike.

  IF HMEINH = MEINH-MEINH.
*   CLEAR RMMZU-OKCODE.             "cfo/20.1.97 wird nicht benötigt
*   MESSAGE E342 WITH MEINH-MEINH.
    MESSAGE ID MSGID TYPE 'E'
            NUMBER MSGNO
            WITH MEINH-MEINH MSGV2 MSGV3 MSGV4.
  ENDIF.

ENDFORM.
