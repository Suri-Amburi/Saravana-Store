*&---------------------------------------------------------------------*
*&      Module  CLEAN_MEINH  INPUT
*&---------------------------------------------------------------------*
*       Löscht die Einträge zu denjenigen Mengeneinheiten, für die
*       außer der Mengeneinheit nichts erfaßt wurde, wieder raus,
*       damit keine "leeren" Sätze auf die DB gelangen
*----------------------------------------------------------------------*
MODULE CLEAN_MEINH INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK BILDFLAG IS INITIAL.

  LOOP AT MEAN_ME_TAB.
    IF NOT MEAN_ME_TAB-MEINH IS INITIAL AND
*      MEAN_ME_TAB-HPEAN     IS INITIAL AND
       MEAN_ME_TAB-EAN11     IS INITIAL AND
       MEAN_ME_TAB-NUMTP     IS INITIAL.
      DELETE MEAN_ME_TAB.
    ENDIF.
  ENDLOOP.

ENDMODULE.                             " CLEAN_MEINH  INPUT
