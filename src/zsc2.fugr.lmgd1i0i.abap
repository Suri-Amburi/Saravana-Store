*------------------------------------------------------------------
*        Gewichte
* Das Nettogewicht wird in der Regel nicht größer sein als das
* Bruttogewicht.
*------------------------------------------------------------------
MODULE GEWICHTE.

  CHECK BILDFLAG IS INITIAL.           "MK/19.04.95
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ. "MK/19.04.95

* cfo/28.8.96 Prüfstatus ergänzt, damit Prüfung nicht mehrfach kommt
* Prüfstatus zurücksetzen, falls Felder geändert wurden.
  IF ( RMMZU-PS_BRGEW = X ) AND
     ( ( UMARA-BRGEW NE MARA-BRGEW ) OR
       ( UMARA-NTGEW NE MARA-NTGEW ) ).
    CLEAR RMMZU-PS_BRGEW.
  ENDIF.
* Wenn Prüfstatus = Space, Prüfbaustein aufrufen.
  IF RMMZU-PS_BRGEW = SPACE.
* note 1799356
*    CALL FUNCTION 'GEWICHT_PRUEFUNG'
*         EXPORTING
*              NTGEW      = MARA-NTGEW
*              BRGEW      = MARA-BRGEW
*              P_MESSAGE  = ' '
*         CHANGING
*              P_PS_BRGEW = RMMZU-PS_BRGEW.
    IF MARA-NTGEW GT MARA-BRGEW AND NOT MARA-BRGEW IS INITIAL.
      RMMZU-PS_BRGEW = 'X'.
*    IF RMMZU-PS_BRGEW NE SPACE.
* Warnung außerhalb als S-Meldung ausgeben, da mehrere Felder betroffen
* sind.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MARA-NTGEW'.

* note 1799356
      CALL FUNCTION 'ME_CHECK_T160M'
        EXPORTING
          I_ARBGB = 'M3'
          I_MSGNR = '176'
          I_MSGVS = '00'           " Messagevariante default '00'
          I_MSGTP_DEFAULT = 'S'
        EXCEPTIONS
          NOTHING     = 00
          SUCCESS     = 01
          WARNING     = 02
          ERROR       = 03.
      IF SY-SUBRC = 0.
        CLEAR BILDFLAG.                                                 " n_2147057
      ELSEIF SY-SUBRC = 2.
        MESSAGE W176(M3).
      ELSEIF SY-SUBRC = 3.
        MESSAGE E176(M3).
      ELSE.
        MESSAGE S176(M3).
      ENDIF.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMARA = MARA.
    ENDIF.
  ENDIF.

ENDMODULE.
