*&---------------------------------------------------------------------*
*&      Module  BILDFLAG_BLAETTERN_EAN_ZUS  INPUT
*&---------------------------------------------------------------------*
* Bildflag wird bei Blätter-Okcode außerhalb in anderen Subscreens
* immer gesetzt, damit beim Blättern keine Warnungen kommen,
* die aus anderen Subscreens herrühren. Ist Blättern für diesen
* Subscreen bestimmt, Bildflag zurücksetzen, damit Prüfungen für
* diesen Subscreen ablaufen können.
*----------------------------------------------------------------------*
MODULE BILDFLAG_BLAETTERN_EAN_ZUS INPUT.

  IF NOT BILDFLAG IS INITIAL AND
     ( RMMZU-OKCODE = FCODE_EAFP OR
       RMMZU-OKCODE = FCODE_EAPP OR
       RMMZU-OKCODE = FCODE_EANP OR
       RMMZU-OKCODE = FCODE_EALP OR
       RMMZU-OKCODE = FCODE_EADE ).
    CLEAR BILDFLAG.
  ENDIF.
* Wenn man auf diesem Subscreen blättert, sollen keine Warnungen aus
* anderen Subscreens hochkommen.

*---Bildflag merken, weil Blättern nicht durchgeführt wird, wenn
*---Bildflag außerhalb gesetzt wurde.
  EAN_BILDFLAG_OLD = BILDFLAG.

ENDMODULE.                 " BILDFLAG_BLAETTERN_EAN_ZUS  INPUT
