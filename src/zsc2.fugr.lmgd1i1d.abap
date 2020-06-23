* AHE: 17.04.98 - A (4.0c)
*&---------------------------------------------------------------------*
*&      Module  MARC-APOKZ  INPUT
*&---------------------------------------------------------------------*
*       Prüfung, ob Dispomerkmal oder Losgrößenverfahren konsistent
*       gefüllt, wenn APOKZ gesetzt ist.
*----------------------------------------------------------------------*
MODULE MARC-APOKZ INPUT.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Prüfstatus zurücksetzen, falls Felder geändert wurden.
  IF ( NOT RMMZU-PS_APOKZ IS INITIAL ) AND
     ( ( UMARC-APOKZ NE MARC-APOKZ )  " OR
*      ( UMARC-DISMM NE MARC-DISMM ) OR
*      ( UMARC-DISLS NE MARC-DISLS )
                                     ).
    CLEAR RMMZU-PS_APOKZ.
  ENDIF.

* Wenn Prüfstatus = Space, Prüfbaustein aufrufen.
  IF RMMZU-PS_APOKZ IS INITIAL.

    CALL FUNCTION 'MARC_APOKZ'
         EXPORTING
              P_APOKZ          = MARC-APOKZ
              P_DISMM          = MARC-DISMM
              P_DISLS          = MARC-DISLS
              P_PS_APOKZ       = RMMZU-PS_APOKZ
         IMPORTING
              P_PS_APOKZ       = RMMZU-PS_APOKZ
*        TABLES
*             RETURN           = TMESSAGE
         EXCEPTIONS
              P_ERR_MARC_APOKZ = 1
              OTHERS           = 2.

    IF SY-SUBRC NE 0.
      IF SY-MSGTY NE 'E'.
*       Falls z.B. eine Warnung ausgegeben wird, wir diese auch als
*       S-Meldung ausgegeben. Das Prüfflag muß dann hier gesetzt
*       werden.
*       Bemerkung: P_KZ_NO_WARN muß hier nicht ausgewertet werden !
        RMMZU-PS_APOKZ = '1'.   " erste Warnung
*       Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am
*       Ende des Bildes keine Aktualisierung von UMXXX erfolgt.
        UMARC = MARC.
      ENDIF.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MARC-APOKZ'.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
* Wenn Prüfstatus nicht init. und Felder wurden nicht geändert, Prüfung
* durchführen, keine Warnung ausgeben (im Prüfbaustein wird nach der
* 1. Warnung aufgesetzt).

    CALL FUNCTION 'MARC_APOKZ'
         EXPORTING
              P_APOKZ          = MARC-APOKZ
              P_DISMM          = MARC-DISMM
              P_DISLS          = MARC-DISLS
              P_PS_APOKZ       = RMMZU-PS_APOKZ
         IMPORTING
              P_PS_APOKZ       = RMMZU-PS_APOKZ
*        TABLES
*             RETURN           = TMESSAGE
         EXCEPTIONS
              P_ERR_MARC_APOKZ = 1
              OTHERS           = 2.

    IF SY-SUBRC NE 0.
      IF SY-MSGTY NE 'E'.
        IF RMMZU-PS_APOKZ = '1'.
          RMMZU-PS_APOKZ = '2'.
          BILDFLAG = X.
          UMARC = MARC.
          RMMZU-CURS_FELD = 'MARC-APOKZ'.
          MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ELSE.
          BILDFLAG = X.
          UMARC = MARC.
          RMMZU-CURS_FELD = 'MARC-APOKZ'.
          MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.                 " MARC-APOKZ  INPUT
