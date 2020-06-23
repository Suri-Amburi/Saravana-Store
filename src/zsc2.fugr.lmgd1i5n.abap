*&---------------------------------------------------------------------*
*&      Module  ME_SETZEN_NACHRICHT_I  INPUT
*&---------------------------------------------------------------------*
*       Prüfungen, die vor OKCODE_MEINH_I laufen müssen                *
*----------------------------------------------------------------------*
MODULE ME_SETZEN_NACHRICHT_I INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

*-----Prüfen, ob Kennungen BME, BSTME, VRKME, AUSME korrekt gesetzt.
  IF ME_FEHLERFLG = SPACE AND BILDFLAG IS INITIAL.
    PERFORM PRUEFEN_KZME.
    IF ME_FEHLERFLG NE SPACE.          "Fehler bei KZME
      CLEAR RMMZU-OKCODE.    "Löschen OKCODE, da diese Prüfung vor
      IF BILDFLAG IS INITIAL."Löschen ME durchgeführt wird und sonst
        BILDFLAG = X.        "Cursor ev. falsch poitioniert ist
*       MESSAGE ...       "wird in PRUEFEN_KZME gesetzt
      ENDIF.
    ENDIF.
  ENDIF.


ENDMODULE.                             " ME_SETZEN_NACHRICHT_I  INPUT
