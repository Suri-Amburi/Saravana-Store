*----------------------------------------------------------------------
* Module MLGT-KOBER                                    "4.0A  BE/140897
*
* Prüfen LVS Kommissionierbereich
*----------------------------------------------------------------------
MODULE MLGT-KOBER.                                     "4.0A  BE/140897

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MLGT_KOBER'
       EXPORTING
            WMLGT_LGNUM  = MLGT-LGNUM
            WMLGT_LGTYP  = MLGT-LGTYP
            WMLGT_LGPLA  = MLGT-LGPLA
            LMLGT_LGPLA  = LMLGT-LGPLA
       CHANGING
            WMLGT_KOBER  = MLGT-KOBER.

* JH/20.01.98/4.5B/KPr80027393 (Anfang)
* Durch Änderung im FB MLGT_KOBER wird Meldung sinnlos!
* IF MLGT-KOBER NE LMLGT-KOBER.
*   MESSAGE W061(MM).
* ENDIF.
* JH/20.01.98/4.5B/KPr80027393 (Ende)

ENDMODULE.
