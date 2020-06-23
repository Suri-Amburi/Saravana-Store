*&---------------------------------------------------------------------*
*&      Module  VERBRAUCH_ANZEIGEN  OUTPUT
*&---------------------------------------------------------------------*
*       Anzeigen der Verbrauchswerte.
*----------------------------------------------------------------------*
MODULE VERBRAUCH_ANZEIGEN OUTPUT.
*wk/4.0 field selection here now due to tc

"{ Begin ENHO AD_MPN_PUR2_LMGD1O0L IS-AD-MPN AD_MPN_IC }
* PIC: buffer sy-subrc
  data: save_subrc like sy-subrc.
* For IS-ADEC-MPN
  data: mpnkz type xfeld.
"{ End ENHO AD_MPN_PUR2_LMGD1O0L IS-AD-MPN AD_MPN_IC }

ENHANCEMENT-POINT VERBRAUCH_ANZEIGEN_01 SPOTS ES_LMGD1O0L STATIC INCLUDE BOUND.
  IF KZVERB = 'U'.
* AHE: 30.01.97 - A
    LOOP AT SCREEN.
*     if screen-group1 = '001'.  mk/4.0A
      IF SCREEN-GROUP1 = '001' OR SCREEN-GROUP2 = '001'.
*     Button für ungepl. Verbrauch deaktivieren
*       SCREEN-INPUT  = 0.    " schaltet auf "nur Ausgabe"
        SCREEN-OUTPUT = 1.             " schaltet auf "nur Ausgabe"
        SCREEN-ACTIVE = 0.             " schaltet auf "unsichtbar"
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
* AHE: 30.01.97 - E
  ELSE.
* AHE: 30.01.97 - A
    LOOP AT SCREEN.
*     if screen-group1 = '002'.   mk/4.0A
      IF SCREEN-GROUP1 = '002' OR SCREEN-GROUP2 = '002'.
*     Button für Gesamtverbrauch deaktivieren
*       SCREEN-INPUT  = 0.    " schaltet auf "nur Ausgabe"
        SCREEN-OUTPUT = 1.             " schaltet auf "nur Ausgabe"
        SCREEN-ACTIVE = 0.             " schaltet auf "unsichtbar"
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
* AHE: 30.01.97 - E
  ENDIF.

  IF SY-STEPL = 1.
    VW_ZLEPROSEITE = SY-LOOPC.
  ENDIF.

  VW_AKT_ZEILE = VW_ERSTE_ZEILE + SY-STEPL.
  IF KZVERB = 'U'.
    READ TABLE UNG_VERBTAB INDEX VW_AKT_ZEILE.
  ELSE.
    READ TABLE GES_VERBTAB INDEX VW_AKT_ZEILE.
  ENDIF.

"{ Begin ENHO AD_MPN_PUR2_LMGD1O0L IS-AD-MPN AD_MPN_IC }
*    A&D 3.0; MPN-Projekt; Cora Zimmermann; 24.11.1998
*    read tables for total consumption if displaying totals
*    (may change sy-subrc)
*  perform mpn_read_table using vw_akt_zeile kzverb.
* Wolfgang Kalthoff
  save_subrc = sy-subrc.

  CALL FUNCTION 'PIC_READ_TABLE'
       EXPORTING
            INDEX   = vw_akt_zeile
            KZVERB  = kzverb
       IMPORTING
            MPNKZ   = mpnkz
       EXCEPTIONS
            OTHERS = 1.

* SUBRAMANIANR: In the above case, if the number of consumption
* values is greater for the MRP set, as compared to the original
* part, sy-subrc will be 0, where as save_subrc <> 0. This will
* cause the system to exit from the STEP-LOOP, without processing
* the excess records!!!
    IF mpnkz <> 'X'.
      sy-subrc = save_subrc.
    ENDIF.
"{ End ENHO AD_MPN_PUR2_LMGD1O0L IS-AD-MPN AD_MPN_IC }

ENHANCEMENT-POINT VERBRAUCH_ANZEIGEN_02 SPOTS ES_LMGD1O0L INCLUDE BOUND.
  IF SY-SUBRC NE 0.
    IF T130M-AKTYP = AKTYPA OR
       T130M-AKTYP = AKTYPZ.
      EXIT FROM STEP-LOOP.
    ELSE.
      CLEAR T009B_ERROR.
      NO_T009B_ABEND = X.
* AHE: 08.04.98 - A (4.0c) HW 100826
* vorgezogen
      RM03M-ANTEI = 1.                 " wegen Fließkommaarithmetik
* AHE: 08.04.98 - E
      PERFORM VERBRAUCH_ERWEITERN.
      CLEAR NO_T009B_ABEND.
      IF T009B_ERROR = X.
        EXIT FROM STEP-LOOP.
      ENDIF.
      IF KZVERB = 'U'.
        MOVE-CORRESPONDING UNG_VERBTAB TO RM03M.
        PERFORM DATUMSAUFBEREITUNG USING UNG_VERBTAB-ERTAG RM03M-PRIOD.
      ELSE.
        MOVE-CORRESPONDING GES_VERBTAB TO RM03M.
        PERFORM DATUMSAUFBEREITUNG USING GES_VERBTAB-ERTAG RM03M-PRIOD.
      ENDIF.
*     RM03M-ANTEI = 100.   " Wert aus altem Mat-Stamm heißt: 1.00
* AHE: 08.04.98 - A (4.0c) HW 100826
* nach oben gezogen
*     RM03M-ANTEI = 1.                 " wegen Fließkommaarithmetik
* AHE: 08.04.98 - E
    ENDIF.
  ELSE.
    IF KZVERB = 'U'.
      MOVE-CORRESPONDING UNG_VERBTAB TO RM03M.
      PERFORM DATUMSAUFBEREITUNG USING UNG_VERBTAB-ERTAG RM03M-PRIOD.
    ELSE.
      MOVE-CORRESPONDING GES_VERBTAB TO RM03M.
      PERFORM DATUMSAUFBEREITUNG USING GES_VERBTAB-ERTAG RM03M-PRIOD.
    ENDIF.

"{ Begin ENHO AD_MPN_PUR2_LMGD1O0L IS-AD-MPN AD_MPN_IC }
*    A&D 3.0; MPN-Projekt; Cora Zimmermann; 24.11.1998
*    Fill tc-structure with data from total consumption table
*    perform mpn_fill_rm03m using kzverb changing rm03m.
*    Wolfgang Kalthoff: This needs to be changed (see email to
*    Patrick Mischo)
     CALL FUNCTION 'PIC_FILL_RM03M'
          EXPORTING
               KZVERB  = kzverb
          CHANGING
               P_RM03M = rm03m.

*     perform mpn_fill_rm03m(sy-repid) using kzverb changing rm03m
*             if found.
*   The above only solves syntax errors! It does not solve the general
*   problem!
"{ End ENHO AD_MPN_PUR2_LMGD1O0L IS-AD-MPN AD_MPN_IC }

ENHANCEMENT-POINT VERBRAUCH_ANZEIGEN_03 SPOTS ES_LMGD1O0L INCLUDE BOUND.
    IF RM03M-VBWRT NE 0.
*--- Feldüberlauf abgefragt;
*     RECHFELD = RM03M-KOVBW * 100 / RM03M-VBWRT.  " raus wg. Fließkomm.
      RECHFELD = RM03M-KOVBW / RM03M-VBWRT.
* AHE: 25.10.96 - A
* Falls Betrag von RECHFELD größer als MAX_ANTEI bei negativem
* Wert für RECHFELD
      IF RECHFELD < 0.
        RECHFELD = ABS( RECHFELD ).
      ENDIF.
* AHE: 25.10.96 - E
      IF RECHFELD GT MAX_ANTEI.
        CLEAR RM03M-ANTEI.
      ELSE.
*       RM03M-ANTEI = RM03M-KOVBW * 100 / RM03M-VBWRT. "raus wg. Fließko
        RM03M-ANTEI = RM03M-KOVBW / RM03M-VBWRT.
      ENDIF.
    ELSE.
      IF RM03M-KOVBW = 0.
*       RM03M-ANTEI = 100.   " Wert aus altem Mat-Stamm heißt: 1.00
        RM03M-ANTEI = 1.
      ELSE.
        CLEAR RM03M-ANTEI.      "hier müßte Anteil unendlich sein !
      ENDIF.
    ENDIF.

* AHE: 08.04.98 - A (4.0c) HW 100826
    IF KZVERB = 'U'.
      MOVE RM03M-ANTEI TO UNG_VERBTAB-ANTEI.
      MODIFY UNG_VERBTAB INDEX VW_AKT_ZEILE.
    ELSE.
      MOVE RM03M-ANTEI TO GES_VERBTAB-ANTEI.
      MODIFY GES_VERBTAB INDEX VW_AKT_ZEILE.
    ENDIF.
* AHE: 08.04.98 - E

  ENDIF.

ENDMODULE.                             " VERBRAUCH_ANZEIGEN  OUTPUT
