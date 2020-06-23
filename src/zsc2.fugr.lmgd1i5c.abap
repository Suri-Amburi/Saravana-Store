*&---------------------------------------------------------------------*
*&      Module  BILDFLAG_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
* Wenn das Bildflag gesetzt ist, aber ein 'Blätter-OK-CODE' gesetzt,   *
* der für Kurztexte ist, muß das Bildflag temporär zurückgenommen werden
*----------------------------------------------------------------------*
MODULE BILDFLAG_BLAETTERN INPUT.

  IF NOT BILDFLAG IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_KTFP OR
       RMMZU-OKCODE = FCODE_KTPP OR
       RMMZU-OKCODE = FCODE_KTNP OR
       RMMZU-OKCODE = FCODE_KTLP OR
       RMMZU-OKCODE = FCODE_KTDE ).
    CLEAR BILDFLAG.
  ENDIF.

ENDMODULE.                             " BILDFLAG_BLAETTERN  INPUT
