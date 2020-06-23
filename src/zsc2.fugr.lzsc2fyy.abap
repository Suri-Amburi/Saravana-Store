************************************************************
* Include LMGD2FYY
************************************************************
FORM MAIN_PARAMETER_GET.

     CALL FUNCTION 'MAIN_PARAMETER_GET_RETAIL'
          IMPORTING
               NEUFLAG       =  NEUFLAG
               FLGNUMINT     =  FLGNUMINT
               FLGDARK       =  FLGDARK
*              flg_cad_aktiv =  flg_cad_aktiv mk/4.0A in RMMG2 integr.
               WRMMG1        =  RMMG1
               WRMMG2        =  RMMG2
               WRMMG1_REF    =  RMMG1_REF
               WRMMG1_BEZ    =  RMMG1_BEZ
               WRMMZU        =  RMMZU
               WRMMW1        =  RMMW1
               WRMMW2        =  RMMW2
               WRMMW1_BEZ    =  RMMW1_BEZ
               WRMMW1_EINST  =  RMMW1_EINST
               WRMMW3        =  RMMW3
               WRMMWZ        =  RMMWZ
               WUSRM3        =  HUSRM3         "mk/17.06.96
               WT130M        =  T130M
               WT133S        =  T133S
               WT134         =  T134
               AKTVSTATUS    =  AKTVSTATUS
               TRANSSTATUS   =  TRANSTATUS
               SPERRMODUS    =  SPERRMODUS
               BILDSEQUENZ   =  BILDSEQUENZ
          TABLES
               MTAB          =  PTAB
               MTAB_RT       =  PTAB_RT
               BILDTAB       =  BILDTAB
               REFTAB        =  REFTAB.

ENDFORM.

FORM T130F_LESEN_KOMPLETT.

  DESCRIBE TABLE IT130F LINES ZAEHLER.
  IF ZAEHLER EQ 0.
    CALL FUNCTION 'T130F_ARRAY_READ'
         TABLES
              TT130F = IT130F.
    LOOP AT IT130F.
*Tabelle der Felder mit SFGRUP aufbauen
      IF NOT IT130F-SFGRU  IS INITIAL.
          FTAB_SFGRUP-FNAME  = IT130F-FNAME.
          APPEND FTAB_SFGRUP.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.

*------------------------------------------------------------------
* EANDATEN_BME.
* Es wird geprüft, ob EAN-Spezifische Daten zur bisherigen Basis-ME
* vorhanden sind.
*------------------------------------------------------------------
FORM EANDATEN_BME USING FLAG.

CLEAR FLAG.
IF ( NOT MARA-EAN11 IS INITIAL ) OR ( NOT MARA-NUMTP IS INITIAL ) OR
   ( NOT MARA-BRGEW IS INITIAL ) OR ( NOT MARA-GEWEI IS INITIAL ) OR
   ( NOT MARA-VOLUM IS INITIAL ) OR ( NOT MARA-VOLEH IS INITIAL ) OR
   ( NOT MARA-LAENG IS INITIAL ) OR ( NOT MARA-BREIT IS INITIAL ) OR
   ( NOT MARA-HOEHE IS INITIAL ) OR ( NOT MARA-MEABM IS INITIAL ) .
     FLAG = X.
ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  RMMw1_SET_VRKME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM RMMW1_SET_VRKME USING ME_VRKME LIKE  SMEINH-MEINH
                           DLMEINH  LIKE SMEINH-MEINH.
* Set the sales unit to area of validity if it was delted
* Note 805246
  IF RMMW1-VRKME = DLMEINH.
     RMMW1-VRKME = ME_VRKME.
  ENDIF.

ENDFORM.                    " RMMw1_SET_VRKME
