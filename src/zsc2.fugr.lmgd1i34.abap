*------------------------------------------------------------------
*           MARC-QMATV.
* Im Dialogfall soll eine Warnung hochkommen, wenn die QM-Prüfdaten
* nicht vom Vorlagematerial übernommen wurden.             ch zu 3.0C
*------------------------------------------------------------------
MODULE MARC-QMATV.

 CHECK BILDFLAG IS INITIAL.
 CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*CHECK RMMZU-OKCODE NE FCODE_PB01.   mk/3.0F pb01 = qmpd einheitlich
*mk/3.1G konfigurierbare Funktion - fcode ist variabel, dazu wegen
*Performance Checks aus FB auch hier
*CHECK RMMZU-OKCODE NE FCODE_QMPD.
 CHECK  NOT RMMG1_REF-MATNR IS INITIAL.                         "mk/3.1G
 CHECK MARC-QMATV IS INITIAL AND NOT RMMZU-REF_QMATV IS INITIAL. "mk/31G
 CALL FUNCTION 'T133D_ARRAY_READ'
      EXPORTING
           BILDSEQUENZ = BILDSEQUENZ
      TABLES
           TT133D      =  TT133D
      EXCEPTIONS
           WRONG_CALL  = 01.
 CLEAR FLAG1.
 LOOP AT TT133D WHERE ROUTN = FORM_QMPD.
   IF RMMZU-OKCODE EQ TT133D-FCODE.
     FLAG1 = X.
     EXIT.
   ENDIF.
 ENDLOOP.
 CHECK  FLAG1 IS INITIAL.

 IF RMMZU-PS_QMATV IS INITIAL.                "cfo/3.1H
   CALL FUNCTION 'MARC_QMATV'
        EXPORTING
             P_MARC_QMATV = MARC-QMATV
             REF_QMATV    = RMMZU-REF_QMATV
             HERKUNFT     = HERKUNFT_DIAL
             REF_MATNR    = RMMG1_REF-MATNR
             P_MESSAGE    = ' '
        IMPORTING
             P_PS_QMATV   = RMMZU-PS_QMATV
        EXCEPTIONS
             OTHERS       = 1.
   IF NOT RMMZU-PS_QMATV IS INITIAL.          "cfo/3.1H
     BILDFLAG = X.                            "Meldung außerhalb,
     MESSAGE S819.                            "damit Prüfdaten an-
   ENDIF.                                     "gewählt werden können
 ENDIF.                                       "

ENDMODULE.
