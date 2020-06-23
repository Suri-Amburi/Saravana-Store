*-------------------------------------------------------------------
***INCLUDE LMGD2O04 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  VKP_KALKULATION  OUTPUT
*&---------------------------------------------------------------------*
*       Besorgen der Daten zur VKP-Kalkulation.                        *
*----------------------------------------------------------------------*
MODULE VKP_KALKULATION OUTPUT.

  CHECK BILDFLAG IS INITIAL OR ( NOT RMMZU-BILDPROZ IS INITIAL ).
                     "cfo/11.6.96 bei andere Orgeben sitzt Bildflag!
  CHECK ( NOT RMMG1-VKORG IS INITIAL  "Sollte eigentlich nicht vorkommen
          OR NOT RMMW2-BGINT IS INITIAL )  "cfo/23.1.97
        AND NOT RMMW2-VRKME IS INITIAL.

  RV61A-KOEIN = '3'.     "Darstellung %-Felder

  CALL FUNCTION 'OKCODE_VERKAUF'
       EXPORTING
            P_RMMG1    = RMMG1
            P_AUFRUF   = KZPBO
            P_AKTYP    = T130M-AKTYP
            P_NEUFLAG  = NEUFLAG
            P_PMATN    = MVKE-PMATN
            P_MARA     = MARA                    "wsc/4.6
       IMPORTING
            P_NEUKALK  = FLG_NEUKALK
       TABLES
            MEINH      = MEINH
       CHANGING
            P_RMMW2    = RMMW2
            P_CALP     = CALP
            P_ERRO     = ERRO
       EXCEPTIONS
            VKP_ERROR    = 1
            OTHERS       = 2.
  IF SY-SUBRC NE 0.
    BILDFLAG = X.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSEIF NOT ERRO IS INITIAL.
    BILDFLAG = X.
    MESSAGE ID ERRO-MSGID TYPE 'S'
            NUMBER ERRO-MSGNO
            WITH ERRO-MSGV1 ERRO-MSGV2
                 ERRO-MSGV3 ERRO-MSGV4.
  ELSE.
*   note 359754
*   Steuerung des Speicherkennzeichens abhängig von Feldauswahl
    read table fauswtab with key fname = 'CALP-VKABS' binary search.
    if fauswtab-KZINP = 0. clear CALP-VKABS. ENDIF.

*   EKOrg und Lieferant aus RMMW2 nach RMMW1 übernehmen,
*   wenn verschieden.
    CHECK RMMW2-EKORG NE RMMW1-EKORG OR RMMW2-LIFNR NE RMMW1-LIFNR.
    RMMW1-EKORG = RMMW2-EKORG.
    RMMW1-LIFNR = RMMW2-LIFNR.
    HUSRM3-EKORG = RMMW1-EKORG.
    HUSRM3-LIFNR = RMMW1-LIFNR.
*   Zusätzlich Bezeichnungen lesen und alles in den Puffer setzen.
    CHECK NOT RMMW1-EKORG IS INITIAL AND NOT RMMW1-LIFNR IS INITIAL.
    IF T024E-EKORG NE RMMW1-EKORG.
      CALL FUNCTION 'EKORG_INITIAL_CHECK'
           EXPORTING
                EKORG        = RMMW1-EKORG
                AKTYP        = T130M-AKTYP
*               KZ_BERPRF    = ' '
           IMPORTING
                WT024E       = T024E
           EXCEPTIONS
                NOT_FOUND    = 1
                NO_AUTHORITY = 2
                OTHERS       = 3.
      IF SY-SUBRC NE 0.
        CLEAR T024E.
      ENDIF.
    ENDIF.
    IF LFA1-LIFNR NE RMMW1-LIFNR.
      CALL FUNCTION 'LIFNR_INITIAL_CHECK'
           EXPORTING
                EKORG                 = RMMW1-EKORG
                LIFNR                 = RMMW1-LIFNR
           IMPORTING
                WLFA1                 = LFA1
*               WLFM1                 =
           EXCEPTIONS
                EKORG_IS_INITIAL      = 1
                LIFNR_NOT_FOUND       = 2
                WRONG_LIFNR_FOR_EKORG = 3
                OTHERS                = 4.
      IF SY-SUBRC NE 0.
      ENDIF.
    ENDIF.
    RMMW1_BEZ-EKOTX = T024E-EKOTX.
    RMMW1_BEZ-LFATX = LFA1-NAME1.
    CALL FUNCTION 'MAIN_PARAMETER_SET_KEYS_SUB'
         EXPORTING
              WRMMW2     = RMMW2
              WRMMW1     = RMMW1
              WRMMW1_BEZ = RMMW1_BEZ
              WUSRM3     = HUSRM3
         EXCEPTIONS
              OTHERS     = 1.
  ENDIF.

ENDMODULE.                             " VKP_KALKULATION  OUTPUT
