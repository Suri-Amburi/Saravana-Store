*&---------------------------------------------------------------------*
*&      Module  SMEINH-BRGEW  INPUT
*&---------------------------------------------------------------------*
*    Prüfen, ob das Bruttogewicht >= dem Nettogewicht ist              *
*----------------------------------------------------------------------*
MODULE SMEINH-BRGEW INPUT.

  DATA: HGEWEI LIKE MARA-GEWEI.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.
  CHECK SMEINH-MEINH NE SPACE.

  CHECK BILDFLAG IS INITIAL.
  CHECK RMMZU-OKCODE NE FCODE_MEDE.

*  CHECK SMEINH-KZBME IS INITIAL.       "cfo/10.8.96
  check mara-meins ne smeinh-meinh.       "jw/5.0/26.09.00/note 335937

  IF MARA-GEWEI IS INITIAL.            "cfo/14.8.96 MARA-GEWEI kann leer
*    READ TABLE MEINH WITH KEY ME_BME. "sein, falls BasisME geändert
*mk/15.08.96 Hilfsstruktur verwenden, da sonst aktuelle Eingabe-Zeile
*zerstört
    READ TABLE MEINH INTO H_MEINH WITH KEY ME_BME.
    IF SY-SUBRC = 0.
*      HGEWEI = MEINH-GEWEI.  MK/15.08.96
      HGEWEI = H_MEINH-GEWEI.
    ENDIF.
  ELSE.
    HGEWEI = MARA-GEWEI.
  ENDIF.
  CHECK NOT HGEWEI IS INITIAL.

  CALL FUNCTION 'MEINH_BRGEW'
       EXPORTING
            BME_NTGEW = MARA-NTGEW
            AME_BRGEW = SMEINH-BRGEW
            BME_GEWEI = HGEWEI
            AME_GEWEI = SMEINH-GEWEI
            UMREZ     = SMEINH-UMREZ
            UMREN     = SMEINH-UMREN
            P_MESSAGE = ' '.

ENDMODULE.                             " SMEINH-BRGEW  INPUT
