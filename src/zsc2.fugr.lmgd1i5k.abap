*&---------------------------------------------------------------------*
*&      Module  VERBR_UEBERNEHMEN  INPUT
*&---------------------------------------------------------------------*
*       Übernahme der eingegebenen Verbrauchswerte in die
*       internen Tabellen.
* FDE: 20.01.2000 - Begin Deletion (46c) HW 195819
*       internen Tabellen. Es muß sichergestellt werden, daß der
*       Gesamtverbrauch größer als der ungeplante Verbrauch bleibt.
* FDE: 20.01.2000 - End Deletion (46c) HW 195819
*----------------------------------------------------------------------*
MODULE VERBR_UEBERNEHMEN INPUT.

  IF SY-STEPL = 1.
    VW_BILDFLAG_OLD = BILDFLAG.
  ENDIF.

  VW_AKT_ZEILE = VW_ERSTE_ZEILE + SY-STEPL.
  IF KZVERB = 'U'.
    READ TABLE UNG_VERBTAB INDEX VW_AKT_ZEILE.
    MOVE RM03M-VBWRT TO UNG_VERBTAB-VBWRT.
    IF ( RM03M-KOVBW = UNG_VERBTAB-KOVBW ) AND
* AHE: 08.04.98 - A (4.0c) HW 100826
         RM03M-ANTEI NE UNG_VERBTAB-ANTEI  AND
* AHE: 08.04.98 - E
       ( ( NOT RM03M-ANTEI IS INITIAL ) OR
         ( NOT UNG_VERBTAB-VBWRT IS INITIAL ) ).
*     UNG_VERBTAB-KOVBW = UNG_VERBTAB-VBWRT * RM03M-ANTEI / 100.
*     "/ 100" fällt weg wegen Fließkommaarithmetik
      UNG_VERBTAB-KOVBW = UNG_VERBTAB-VBWRT * RM03M-ANTEI.
    ELSE.
* AHE: 08.04.98 - A (4.0c) HW 100826
      IF NOT RM03M-ANTEI IS INITIAL AND
         NOT UNG_VERBTAB-VBWRT IS INITIAL AND
             UNG_VERBTAB-KOVBW IS INITIAL.
        UNG_VERBTAB-KOVBW = UNG_VERBTAB-VBWRT * RM03M-ANTEI.
      ELSE.
* AHE: 08.04.98 - E
        UNG_VERBTAB-KOVBW = RM03M-KOVBW.
* AHE: 08.04.98 - A (4.0c) HW 100826
      ENDIF.
* AHE: 08.04.98 - E
    ENDIF.
    MODIFY UNG_VERBTAB INDEX VW_AKT_ZEILE.   " alt: SY-TABIX.
    CLEAR FLAG1.
    READ TABLE GES_VERBTAB INDEX VW_AKT_ZEILE.
* FDE: 20.01.2000 - Begin Deletion (46c) HW 195819
*                                      "  Gesamtverbrauch größer
*   IF GES_VERBTAB-VBWRT LT UNG_VERBTAB-VBWRT. "  ungepl.Verbrauch  ! !
*     GES_VERBTAB-VBWRT = UNG_VERBTAB-VBWRT.
*     FLAG1 = X.
*   ENDIF.
*   IF GES_VERBTAB-KOVBW LT UNG_VERBTAB-KOVBW.
*     GES_VERBTAB-KOVBW = UNG_VERBTAB-KOVBW.
*     FLAG1 = X.
*   ENDIF.
*   IF FLAG1 NE SPACE.
*     MODIFY GES_VERBTAB INDEX VW_AKT_ZEILE.
*   ENDIF.
* FDE: 20.01.2000 - End Deletion (46c) HW 195819
  ELSE.
    READ TABLE GES_VERBTAB INDEX VW_AKT_ZEILE.
    MOVE RM03M-VBWRT TO GES_VERBTAB-VBWRT.
    IF ( RM03M-KOVBW = GES_VERBTAB-KOVBW ) AND
* AHE: 08.04.98 - A (4.0c) HW 100826
         RM03M-ANTEI NE GES_VERBTAB-ANTEI  AND
* AHE: 08.04.98 - E
       ( ( NOT RM03M-ANTEI IS INITIAL ) OR
         ( NOT GES_VERBTAB-VBWRT IS INITIAL ) ).
*     GES_VERBTAB-KOVBW = GES_VERBTAB-VBWRT * RM03M-ANTEI / 100.
*     "/ 100" fällt weg wegen Fließkommaarithmetik
      GES_VERBTAB-KOVBW = GES_VERBTAB-VBWRT * RM03M-ANTEI.
    ELSE.
* AHE: 08.04.98 - A (4.0c) HW 100826
      IF NOT RM03M-ANTEI IS INITIAL AND
         NOT GES_VERBTAB-VBWRT IS INITIAL AND
             GES_VERBTAB-KOVBW IS INITIAL.
        GES_VERBTAB-KOVBW = GES_VERBTAB-VBWRT * RM03M-ANTEI.
      ELSE.
* AHE: 08.04.98 - E
        GES_VERBTAB-KOVBW = RM03M-KOVBW.
* AHE: 08.04.98 - A (4.0c) HW 100826
      ENDIF.
* AHE: 08.04.98 - E
    ENDIF.
    MODIFY GES_VERBTAB INDEX VW_AKT_ZEILE.  " alt: SY-TABIX.
    CLEAR FLAG1.
    READ TABLE UNG_VERBTAB INDEX VW_AKT_ZEILE.
* FDE: 20.01.2000 - Begin Deletion (46c) HW 195819
*                                      " Gesamtverbrauch größer
*   IF UNG_VERBTAB-VBWRT GT GES_VERBTAB-VBWRT. " ungepl.Verbrauch !!!
*     UNG_VERBTAB-VBWRT = GES_VERBTAB-VBWRT.
*     FLAG1 = X.
*   ENDIF.
*   IF UNG_VERBTAB-KOVBW GT GES_VERBTAB-KOVBW.
*     UNG_VERBTAB-KOVBW = GES_VERBTAB-KOVBW.
*     FLAG1 = X.
*   ENDIF.
*   IF FLAG1 NE SPACE.
*     MODIFY UNG_VERBTAB INDEX VW_AKT_ZEILE.
*   ENDIF.
* FDE: 20.01.2000 - End Deletion (46c) HW 195819
  ENDIF.

ENDMODULE.                             " VERBR_UEBERNEHMEN  INPUT
