*-------------------------------------------------------------------
***INCLUDE LMGD2I04 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  VKP_KALKULATION  INPUT
*&---------------------------------------------------------------------*
*       Durchführen VKP-Kalkulation nach Änderungen.                   *
*----------------------------------------------------------------------*
MODULE VKP_KALKULATION INPUT.

  CHECK ( NOT RMMG1-VKORG IS INITIAL  "Sollte eigentlich nicht vorkommen
        OR NOT RMMW2-BGINT IS INITIAL )  "cfo/23.1.97
        AND NOT RMMW2-VRKME IS INITIAL.
  CALL FUNCTION 'OKCODE_VERKAUF'
       EXPORTING
            P_RMMG1   = RMMG1
            P_AUFRUF  = KZPAI
            P_AKTYP   = T130M-AKTYP
            P_NEUFLAG = NEUFLAG
            P_PMATN   = MVKE-PMATN
            P_MARA    = MARA                      "wsc/4.6
       IMPORTING
            P_NEUKALK = FLG_NEUKALK
       TABLES
            MEINH     = MEINH
       CHANGING
            P_RMMW2   = RMMW2
            P_CALP    = CALP
            P_ERRO    = ERRO
       EXCEPTIONS
            VKP_ERROR = 1
            OTHERS    = 2.
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
  ELSEIF NOT FLG_NEUKALK IS INITIAL.
*   JH/02.04.02/4.7
    IF RMMZU-OKCODE = 'PB16'.  "VKP-Kalkulation
*     direkt in die Anzeige der VKP-Kalkulation wechseln ohne
*     Bildwiederholung und Bestätiging mit ENTER.
      MESSAGE S121(MH).
    ELSE.
      BILDFLAG = X.
      MESSAGE S121(MH).
    ENDIF.
  ELSE.
    RMMW1-EKORG = RMMW2-EKORG.
    RMMW1-LIFNR = RMMW2-LIFNR.
* AHE: 10.09.96 - A
* Puffer mit aktueller RMMW2-LIFNR versorgen wegen MLEA-Sätzen
* auf Zusatzbild EANs. cfo/4.0C in else-Fall reingezogen
    CALL FUNCTION 'SET_RMMW2_LIFNR'
         EXPORTING
              RMMW2_LIFNR = RMMW2-LIFNR.
* AHE: 10.09.96 - E
  ENDIF.
  RV61A-KOEIN = '3'.                   "Darstellung %-Felder


  ENDMODULE.                           " VKP_KALKULATION  INPUT
