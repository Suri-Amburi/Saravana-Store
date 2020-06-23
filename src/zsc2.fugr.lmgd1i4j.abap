*------------------------------------------------------------------
*  Module MPOP-PRMOD
*
*- Prüft, ob aufgrund des gewählten Prognosemodells die Prognosewerte
*  weggeworfen werden (bei PrModell 0)                   21.01.94 / CH
*------------------------------------------------------------------
MODULE MPOP-PRMOD.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* AHE: 26.09.97 - A (4.0A) HW 84314
  CHECK AKTVSTATUS CA STATUS_P.
* AHE: 26.09.97

  CALL FUNCTION 'MPOP_PRMOD'
       EXPORTING
            P_PRMOD        = MPOP-PRMOD
            P_MATNR        = MARA-MATNR
            P_WERKS        = MARC-WERKS
            P_KZRFB        = KZRFB
            P_KZ_NO_WARN   = ' '
       CHANGING
            P_FLGPROGWERTE = RMMG2-FLGPROGW. " vorher: FLGPROGWERTE
*    EXCEPTIONS
*         P_ERR_MPOP_PRMOD = 01.

* Speziell nur für Dialog-Fall:
* if rmmzu-okcode = fcode_prow and
*    mpop-prmod = mod_null.            " --> siehe Prüf-FB. MPOP_PRMOD
*mk/3.1G auf konfigurierbare fcodes darf nicht mehr codiert werden,
*außerdem fehlten noch die neuen Prognose-Funktionen
*(Prognose durchführen und Prognosewerte)
 CHECK MPOP-PRMOD = MOD_NULL.
 CALL FUNCTION 'T133D_ARRAY_READ'
      EXPORTING
           BILDSEQUENZ = BILDSEQUENZ
      TABLES
           TT133D      =  TT133D
      EXCEPTIONS
           WRONG_CALL  = 01.
 CLEAR FLAG1.
 LOOP AT TT133D WHERE ROUTN = FORM_PRGW OR ROUTN = FORM_PRGD OR
* fde: 24.03.00 - A (Mercury) HW 208328
                      ROUTN = FORM_PRGD_VZ OR ROUTN = FORM_PRGD_FI OR
* fde: 24.03.00 - E
                      ROUTN = FORM_PRGWO.
   IF RMMZU-OKCODE EQ TT133D-FCODE.
     FLAG1 = X.
     EXIT.
   ENDIF.
 ENDLOOP.
 CHECK  NOT FLAG1 IS INITIAL.
*mk/3.1G S-Meldung statt I-Meldung damit Feld eingabebereit wird
*und außerdem rmmzu-okcode aktualisiert wird über Datenbeschaffung
* MESSAGE I145 WITH MPOP-PRMOD.
 CLEAR RMMZU-OKCODE.                " vorher OK-CODE
 MESSAGE S145 WITH MPOP-PRMOD. " Pflege der Prog.Werte nicht erlaubt
 BILDFLAG = X.

ENDMODULE.
