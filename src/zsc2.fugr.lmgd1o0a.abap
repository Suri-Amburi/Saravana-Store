*&---------------------------------------------------------------------*
*&      Module  INITKTEXT  OUTPUT
*&---------------------------------------------------------------------*
MODULE INITKTEXT OUTPUT.

  CHECK RMMZU-KINIT = SPACE AND RMMG2-FLGKTREF NE SPACE.

*------Setzen Neuflag in bereits erfassten Kurztext-------------------
  LOOP AT KTEXT.
    KTEXT-DOPFLG = X.
    MODIFY KTEXT.
  ENDLOOP.

ENDMODULE.                             " INITKTEXT  OUTPUT
