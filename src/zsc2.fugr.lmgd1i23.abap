*------------------------------------------------------------------
* MARC-STDPD
*
* Prüfung des Standardprodukts zur lagerhaltigen Type
*------------------------------------------------------------------
MODULE MARC-STDPD.
  DATA: KZ_SMESS1 LIKE SY-DATAR.
  DATA: LV_OKCODE like RMMZU-OKCODE.
  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
*note 1109936
  CLEAR LV_OKCODE.
  IF MARC-STDPD IS INITIAL AND NOT RMMZU-OKCODE IS INITIAL.
    CALL FUNCTION 'T133D_ARRAY_READ'
         EXPORTING
              BILDSEQUENZ = BILDSEQUENZ
         TABLES
              TT133D      = TT133D
         EXCEPTIONS
              WRONG_CALL  = 01.

    LOOP AT TT133D WHERE ROUTN = FORM_KUSA.
      IF RMMZU-OKCODE EQ TT133D-FCODE.
        MARC-STDPD = MARA-SATNR.
      ENDIF.
    ENDLOOP.

    LV_OKCODE = RMMZU-OKCODE.
    CLEAR RMMZU-OKCODE.
  ENDIF.


  CALL FUNCTION 'MARC_STDPD'
       EXPORTING
            P_STDPD          = MARC-STDPD
            P_LSTDPD         = LMARC-STDPD
            P_MEINS          = MARA-MEINS
            P_WERKS          = RMMG1-WERKS
            P_MATNR          = MARA-MATNR         " ch zu 3.0C
            P_KZKFG          = MARA-KZKFG         " ch zu 3.0C
            P_VB_FLAG_KONF   = RMMG2-VB_KONF
            P_CUOBJ          = MARC-CUOBJ
            P_NEW_INSTANCE   = RMMG2-NEW_INST    " ch zu 3.0C
            P_VB_FLAG_KONF_V = RMMG2-VB_KONF_V  " ch zu 3.0C
            P_CUOBV          = MARC-CUOBV       " ch zu 3.0C
            P_NEW_INSTANCE_V = RMMG2-NEW_INST_V " ch zu 3.0C
            P_STRGR          = MARC-STRGR        " ch zu 3.0C
            P_OKCODE         = RMMZU-OKCODE      " ch zu 3.0C
            P_KZ_NO_WARN     = ' '
            P_BILDS          = BILDSEQUENZ       "mk/3.1G
       IMPORTING
            P_NEW_INSTANCE   = RMMG2-NEW_INST    " vorher: NEW_INSTANCE
            P_NEW_INSTANCE_V = RMMG2-NEW_INST_V " ch zu 3.0C
*           P_UPD_SPDATA     = RMMG2-UPD_SPDATA  " ch zu 3.0C
            P_CUOBJ          = MARC-CUOBJ
            P_KZ_SMESS1      = KZ_SMESS1.
*    EXCEPTIONS
*         P_ERR_MARC_STDPD = 01.
  IF  RMMG2-NEW_INST IS INITIAL AND    "ch zu 3.0C
      MARC-CUOBJ IS INITIAL .          " ch/25.01.96
    CLEAR RMMZU-XLTYP.                 "ch zu 3.0C
  ENDIF.                               "ch zu 3.0C
  IF RMMG2-NEW_INST_V IS INITIAL AND   "ch zu 3.0C
     MARC-CUOBV IS INITIAL .           " ch/25.01.96
    CLEAR RMMZU-XVPLB.                 "ch zu 3.0C
  ENDIF.                               "ch zu 3.0C

  IF LV_OKCODE IS NOT INITIAL.                                "note 1109936
     RMMZU-OKCODE = LV_OKCODE.
  ENDIF.

*mk/3.1G fcode ist konfigurierbar - Abfrage auf zugehörige okcode-Rout.
* IF NOT KZ_SMESS1 IS INITIAL   AND
*    RMMZU-OKCODE NE FCODE_KONF AND        "ch zu 3.0C
*    RMMZU-OKCODE NE FCODE_KONV.           "ch zu 3.0C
*   Eine S-Message soll ausgegeben werden
*   MESSAGE S494.                      "Bitte Bewertung durchführen
*   BILDFLAG = X.
*   RMMZU-OKCODE = FCODE_KONF.         ch zu 3.0C
*   CLEAR KZ_SMESS1.
* ENDIF.
  IF NOT KZ_SMESS1 IS INITIAL.
    CALL FUNCTION 'T133D_ARRAY_READ'
         EXPORTING
              BILDSEQUENZ = BILDSEQUENZ
         TABLES
              TT133D      = TT133D
         EXCEPTIONS
              WRONG_CALL  = 01.
    CLEAR: FLAG1, HFCODE.
*  LOOP AT TT133D WHERE ROUTN = FORM_KONF OR ROUTN = FORM_KONV. "ch/3.1I
   LOOP AT TT133D WHERE ROUTN = FORM_KONF OR ROUTN = FORM_KONV  "H:88836
                     OR    ROUTN = FORM_KUSA.
      IF TT133D-ROUTN = FORM_KONF.
        HFCODE = TT133D-FCODE.
      ENDIF.
      IF RMMZU-OKCODE EQ TT133D-FCODE.
        FLAG1 = X.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF FLAG1 IS INITIAL.
      MESSAGE S494.                    "Bitte Bewertung durchführen
      BILDFLAG = X.
      RMMZU-OKCODE = HFCODE.
      CLEAR KZ_SMESS1.
    ENDIF.
  ENDIF.

* Wenn Konfiguration für lagerhaltige Typen (OK-CODE = KONF)
* dann muß das Standardprodukt angegeben sein.
* Meldung wurde ursprünglich im Form OKCODE_KONF ausgegeben.
  CLEAR RMMZU-CURS_FELD.
* IF RMMZU-OKCODE = FCODE_KONF OR
*    RMMZU-OKCODE = FCODE_KONV.          "ch zu 3.0C
*   IF MARC-STDPD IS INITIAL.
*     RMMZU-CURS_FELD = MARC_STDPD.    " Cursor positionieren
*     MESSAGE S495.
*     BILDFLAG = X.
*     CLEAR RMMZU-OKCODE.         " AHE: 20.01.97 ausgesternt
*   ENDIF.
* ENDIF.
  IF MARC-STDPD IS INITIAL AND NOT RMMZU-OKCODE IS INITIAL.
    CALL FUNCTION 'T133D_ARRAY_READ'
         EXPORTING
              BILDSEQUENZ = BILDSEQUENZ
         TABLES
              TT133D      = TT133D
         EXCEPTIONS
              WRONG_CALL  = 01.
    CLEAR FLAG1.
    LOOP AT TT133D WHERE ROUTN = FORM_KONF OR ROUTN = FORM_KONV.
      IF RMMZU-OKCODE EQ TT133D-FCODE.
        FLAG1 = X.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF NOT FLAG1 IS INITIAL.
      RMMZU-CURS_FELD = MARC_STDPD.    " Cursor positionieren
      MESSAGE S495.
      BILDFLAG = X.
      CLEAR RMMZU-OKCODE.
    ENDIF.
  ENDIF.

ENDMODULE.
