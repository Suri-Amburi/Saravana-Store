*----------------------------------------------------------------------*
*   INCLUDE LMGD2I13                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  UEBERNAHME_VORGABEWERTE  INPUT
*&---------------------------------------------------------------------*
*       Übernehmen von Mengeneinheit und EAN-Typ in Puffer
*----------------------------------------------------------------------*
MODULE UEBERNAHME_VORGABEWERTE INPUT.

* CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* RMMWZ-NUMTP Dynprofelder in SET_DATEN_SUB direkt übernommen
* RMMWZ-MEINH                "
* RMMWZ-EAN_INTERN           "

  CHECK NOT RMMWZ-NUMTP IS INITIAL.

* Test, ob RMMWZ-EAN_INTERN mit eingegebenem EAN-Typ verträglich.
* Falls nicht, Fehlermeldung.
  CALL FUNCTION 'TNTP_SINGLE_READ'
       EXPORTING
*           KZRFB      = ' '
            TNTP_NUMTP = RMMWZ-NUMTP
       IMPORTING
            WTNTP      = TNTP
       EXCEPTIONS
            NOT_FOUND  = 1
            OTHERS     = 2.

  IF SY-SUBRC NE 0.
    MESSAGE E214(WE).
  ELSE.
    IF TNTP-NMKRS IS INITIAL       AND    " Typ nicht für int. EAN-Verg.
       NOT RMMWZ-EAN_INTERN IS INITIAL.   " int. Vergabe gewünscht
      MESSAGE E215(WE) WITH RMMWZ-NUMTP.
    ENDIF.

    IF NOT TNTP-NMKRS IS INITIAL AND
           TNTP-NMKRE IS INITIAL AND
           RMMWZ-EAN_INTERN IS INITIAL.
*     Wenn Typ nur für interne Vergabe, KZ EAN_INTERN automatisch setzen
      RMMWZ-EAN_INTERN = X.
    ENDIF.

  ENDIF.

ENDMODULE.                             " UEBERNAHME_VORGABEWERTE  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_RMMWZ_MEINH  INPUT
*&---------------------------------------------------------------------*
*       Testet, ob die eingegebene Mengeneinheit zum Material gehört.
*----------------------------------------------------------------------*
MODULE CHECK_RMMWZ_MEINH INPUT.

  CHECK NOT RMMWZ-MEINH IS INITIAL.

  READ TABLE MEINH WITH KEY RMMWZ-MEINH.
  IF SY-SUBRC NE 0.
    CLEAR RMMZU-OKCODE.
    BILDFLAG = X.
    MESSAGE E758 WITH RMMWZ-MEINH.
*   Mengeneinheit & zum Material ist nicht gepflegt
  ENDIF.

ENDMODULE.                             " CHECK_RMMWZ_MEINH  INPUT


*&---------------------------------------------------------------------*
*&      Module  RMMWZ-MEINH_HELP  INPUT
*&---------------------------------------------------------------------*
*       Aufruf der speziellen Eingabehilfe für Mengeneinheiten
*------------------------------------------------------------------
MODULE RMMWZ-MEINH_HELP INPUT.

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'SMEINH_MEINH_HELP'
       EXPORTING
            DISPLAY = DISPLAY
            P_MATNR = RMMW1_MATN
       IMPORTING
            MEINH   = RMMWZ-MEINH
       EXCEPTIONS
            OTHERS  = 1.

ENDMODULE.                             " RMMWZ-MEINH_HELP  INPUT
