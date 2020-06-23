*&---------------------------------------------------------------------*
*&      Module  TC_CHECK_INVISIBLE  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_CHECK_INVISIBLE OUTPUT.

  CHECK FLG_TCFULL IS INITIAL.
  LOOP AT SCREEN.
    CHECK SCREEN-GROUP1(1) = 'F'.
    IF SCREEN-INVISIBLE = '0'.
      FLG_TCFULL = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.
                           " TC_CHECK_INVISIBLE  OUTPUT
ENDMODULE.
