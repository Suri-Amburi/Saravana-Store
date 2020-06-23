*&---------------------------------------------------------------------*
*&      Module  SMEINH-KZME  INPUT
*&---------------------------------------------------------------------*
*       Prüfungen zu den Kennzeichen BasisME, BestellME, LieferME,     *
*       und VerkaufsME.
*----------------------------------------------------------------------*
MODULE SMEINH-KZME INPUT.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  IF SY-STEPL = 1.
    CLEAR: ME_BME, ME_BSTME, ME_AUSME, ME_VRKME, ME_FEHLERFLG.
  ENDIF.
  IF BILDFLAG IS INITIAL.
   IF ( NOT SMEINH-KZBME IS INITIAL OR NOT SMEINH-KZBSTME IS INITIAL OR
       NOT SMEINH-KZAUSME IS INITIAL OR NOT SMEINH-KZVRKME IS INITIAL )
               AND SMEINH-MEINH IS INITIAL AND ME_FEHLERFLG IS INITIAL.
      MESSAGE W883.                    "Daten werden zurückgesetzt
      CLEAR SMEINH.
    ENDIF.
    IF NOT SMEINH-KZBME IS INITIAL AND ME_FEHLERFLG IS INITIAL.
*---ME ist als BasisME gekennzeichnet.----------------------------------
*   Umrechnungsfaktoren der BasisMe müssen 1 sein.
      IF ( SMEINH-UMREN NE 1 OR SMEINH-UMREZ NE 1 )
        and smeinh-azsub ne 1.           "JW/4.6A
        MESSAGE W882.   "Umrechnungsfaktoren werden = 1 gesetzt
        SMEINH-UMREZ = 1.
        SMEINH-UMREN = 1.
        smeinh-azsub = 1.                "JW/4.6A
        smeinh-mesub = smeinh-meinh.     "JW/4.6A
      ENDIF.
      IF ME_BME IS INITIAL AND ME_FEHLERFLG IS INITIAL.
        ME_BME = SMEINH-MEINH.
      ELSEIF ME_FEHLERFLG IS INITIAL.
*     BasisME wurde doppelt gekennzeichnet.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = SMEINH-MEINH.
        MESSAGE S711.
      ENDIF.
    ENDIF.
    IF NOT SMEINH-KZBSTME IS INITIAL AND ME_FEHLERFLG IS INITIAL.
*---ME ist als BestellME gekennzeichent.--------------------------------
      IF ME_BSTME IS INITIAL.
        ME_BSTME = SMEINH-MEINH.
      ELSE.
*     BestellME wurde doppelt gekennzeichent.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = SMEINH-MEINH.
        MESSAGE S888.
      ENDIF.
    ENDIF.
    IF NOT SMEINH-KZAUSME IS INITIAL AND ME_FEHLERFLG IS INITIAL.
*---ME ist als LieferME gekennzeichent.---------------------------------
      IF ME_AUSME IS INITIAL.
        ME_AUSME = SMEINH-MEINH.
      ELSE.
*       LieferME wurde doppelt gekennzeichent.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = SMEINH-MEINH.
        MESSAGE S838.
      ENDIF.
    ENDIF.
    IF NOT SMEINH-KZVRKME IS INITIAL AND ME_FEHLERFLG IS INITIAL.
*---ME ist als VerkaufsME gekennzeichent.-------------------------------
      IF ME_VRKME IS INITIAL.
        ME_VRKME = SMEINH-MEINH.
      ELSE.
*     VerkaufsME wurde doppelt gekennzeichent.
        ME_FEHLERFLG = KZMEINH.
        SAVMEINH = SMEINH-MEINH.
        MESSAGE S839.
      ENDIF.
    ENDIF.

    IF NOT ME_FEHLERFLG IS INITIAL.
*     CLEAR RMMZU-OKCODE.        "cfo/20.1.97 wird nicht benötigt
      BILDFLAG = X.
    ENDIF.
  ENDIF.

* Eingaben übernehmen nach MEINH
  MEINH-KZBME = SMEINH-KZBME.
  MEINH-KZBSTME = SMEINH-KZBSTME.
  MEINH-KZAUSME = SMEINH-KZAUSME.
  MEINH-KZVRKME = SMEINH-KZVRKME.
  MEINH-UMREN = SMEINH-UMREN.
  MEINH-UMREZ = SMEINH-UMREZ.
  meinh-azsub = smeinh-azsub.            "JW/4.6A
  meinh-mesub = smeinh-mesub.            "JW/4.6A

  MODIFY MEINH INDEX ME_AKT_ZEILE.

ENDMODULE.                             " SMEINH-KZME  INPUT
