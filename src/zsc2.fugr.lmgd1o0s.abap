*-------------------------------------------------------------------
***INCLUDE LMGD1O04 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  SONFAUSW_MEGRP  OUTPUT
*&---------------------------------------------------------------------*
*       Das Feld Mengeneinheitengruppe wird ausgeblendet, wenn der     *
*       Aktivitätstyp Anzeigen, Anzeigen alter/neuer Stand oder        *
*       Hinzufügen (nicht Erstanlage) ist.                             *
*----------------------------------------------------------------------*
MODULE SONFAUSW_MEGRP OUTPUT.

  IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ
  OR RMMG2-MANBR NE SPACE.             "ch zu 3.0F
*---- cfo/9.2.95/Hinzufügen gleichbehandeln wie Ändern
*    or ( T130M-AKTYP = AKTYPH AND NEUFLAG IS INITIAL ).
    LOOP AT SCREEN.
*     if screen-group1 = '003'.         "cfo/4.0 statt 003.
*mk/4.0A 003 war schon belegt durch kzbstme, außerdem generell jetzt
*group2 zuätzlich, da group1 in fausw_bezeichnungen benutzt wird
      IF SCREEN-GROUP1 = '006' OR SCREEN-GROUP2 = '006'.
        SCREEN-INPUT = 0.
        SCREEN-REQUIRED = 0.
        SCREEN-INVISIBLE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                             " SONFAUSW_MEGRP  OUTPUT
