*----------------------------------------------------------------------*
*   INCLUDE LMGD2I11                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_PROW_SUB  INPUT
*&---------------------------------------------------------------------*
*       Analog GET_DATEN_SUB aber speziell für Prognosewerte         *
*----------------------------------------------------------------------*
MODULE get_prow_sub INPUT.
  CHECK NOT anz_subscreens IS INITIAL.

  IF NOT kz_ein_programm IS INITIAL.
    IF NOT kz_bildbeginn IS INITIAL.
      CALL FUNCTION 'MAIN_PARAMETER_GET_BILDPAI_SUB'
        IMPORTING
          rmmzu_okcode  = rmmzu-okcode
          bildflag      = bildflag
          rmmg2_vb_klas = rmmg2-vb_klas.
      CLEAR sub_zaehler.
      CLEAR kz_bildbeginn.
    ENDIF.
    sub_zaehler = sub_zaehler + 1.
  ENDIF.

  CHECK kz_ein_programm IS INITIAL.

  PERFORM zusatzdaten_get_sub.

  CALL FUNCTION 'PROW_GET_SUB'
    TABLES
      wprowm = tprowf
      xprowm = dtprowf
      yprowm = ltprowf.

  CALL FUNCTION 'MPOP_GET_SUB'
    IMPORTING
      wmpop = mpop
      xmpop = *mpop
      ympop = lmpop.

ENDMODULE.                             " GET_PROW_SUB  INPUT


*&---------------------------------------------------------------------*
*&      Module  SET_PROW_SUB  INPUT
*&---------------------------------------------------------------------*
*       Analog SET_DATEN_SUB aber speziell für Prognosewerte         *
*----------------------------------------------------------------------*
MODULE set_prow_sub INPUT.

  IF anz_subscreens IS INITIAL.
    PERFORM zusatzdaten_set_sub.
    CALL FUNCTION 'PROW_SET_SUB'
      EXPORTING
        matnr  = rmmg1-matnr
        werks  = rmmg1-werks
      TABLES
        wprowm = tprowf.

    mpop-mandt = sy-mandt.
    mpop-matnr = rmmg1-matnr.
    mpop-werks = rmmg1-werks.
    CALL FUNCTION 'MPOP_SET_SUB'
      EXPORTING
        wmpop = mpop.

  ELSEIF NOT kz_ein_programm IS INITIAL.
    IF sub_zaehler EQ anz_subscreens.
      PERFORM zusatzdaten_set_sub.
      CALL FUNCTION 'PROW_SET_SUB'
        EXPORTING
          matnr  = rmmg1-matnr
          werks  = rmmg1-werks
        TABLES
          wprowm = tprowf.

      mpop-mandt = sy-mandt.
      mpop-matnr = rmmg1-matnr.
      mpop-werks = rmmg1-werks.
      CALL FUNCTION 'MPOP_SET_SUB'
        EXPORTING
          wmpop = mpop.
    ENDIF.
  ELSE.
    PERFORM zusatzdaten_set_sub.
    CALL FUNCTION 'PROW_SET_SUB'
      EXPORTING
        matnr  = rmmg1-matnr
        werks  = rmmg1-werks
      TABLES
        wprowm = tprowf.

    mpop-mandt = sy-mandt.
    mpop-matnr = rmmg1-matnr.
    mpop-werks = rmmg1-werks.
    CALL FUNCTION 'MPOP_SET_SUB'
      EXPORTING
        wmpop = mpop.
  ENDIF.

ENDMODULE.                             " SET_PROW_SUB  INPUT

*&---------------------------------------------------------------------*
*&      Module  TPROWF_UEBERNEHMEN  INPUT
*&---------------------------------------------------------------------*
*       Übernahme der eingegebenen Werte in die interne Tabelle TPROWF
*----------------------------------------------------------------------*
MODULE tprowf_uebernehmen INPUT.

  IF sy-stepl = 1.
    pw_bildflag_old = bildflag.
  ENDIF.

  pw_akt_zeile = pw_erste_zeile + sy-stepl.
  READ TABLE tprowf INDEX pw_akt_zeile.
  MOVE rm03m-prwrt TO tprowf-prwrt.
  MOVE rm03m-saiin TO tprowf-saiin.
  MOVE rm03m-fixkz TO tprowf-fixkz.
  IF ( rm03m-koprw = tprowf-koprw ) AND
     ( ( NOT rm03m-antei IS INITIAL ) OR
       ( NOT tprowf-prwrt IS INITIAL ) ).
*   TPROWF-KOPRW = TPROWF-PRWRT * RM03M-ANTEI / 100.
*     "/ 100" fällt weg wegen Fließkommaarithmetik
    tprowf-koprw = tprowf-prwrt * rm03m-antei.
  ELSE.
    tprowf-koprw = rm03m-koprw.
  ENDIF.

  MODIFY tprowf INDEX pw_akt_zeile.  " alt: SY-TABIX

ENDMODULE.                             " TPROWF_UEBERNEHMEN  INPUT


*&---------------------------------------------------------------------*
*&      Module  ANZAHL_EINTRAEGE_PW  INPUT
*&---------------------------------------------------------------------*
MODULE anzahl_eintraege_pw INPUT.

* ------ Ermitteln Anzahl Prognoseeinträge ------------------------
* ------ hier zur Auswertung der Blätter-FCodes benötigt

  DESCRIBE TABLE tprowf LINES pw_lines.

ENDMODULE.                 " ANZAHL_EINTRAEGE_PW  INPUT


*&---------------------------------------------------------------------*
*&      Module  OKCODE_PROGNOSE  INPUT
*&---------------------------------------------------------------------*
MODULE okcode_prognose INPUT.

  IF NOT pw_bildflag_old IS INITIAL AND
     ( rmmzu-okcode = fcode_pwfp OR
       rmmzu-okcode = fcode_pwpp OR
       rmmzu-okcode = fcode_pwnp OR
       rmmzu-okcode = fcode_pwlp  ).
    CLEAR rmmzu-okcode.
  ENDIF.

  PERFORM ok_code_prognose.

ENDMODULE.                 " OKCODE_PROGNOSE  INPUT

*----------------------------------------------------------------------*
*       Module  PRDAT_VORSCHLAGEN
*
* Ermittlung eines Default-Prognosedatums, falls Prognosewerte gepflegt
* wurden und MPOP-PRDAT aber noch initial ist.
*                           (neu zu 2.1D / K11K067178 / 17.01.94 / CH)
*mk/24.04.95: Die Ermittlung erfolgt wie bisher zum PAI des Prognose-
*wertebildes
*----------------------------------------------------------------------*
MODULE prdat_vorschlagen.

  PERFORM prdat_ermitteln.

ENDMODULE.                              "PRDAT_VORSCHLAGEN
*#WSC 4.70 AHD-INTERFACE - B
*&---------------------------------------------------------------------*
*&      Module  ahd_interface  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ahd_interface INPUT.

  DATA:
    l_call_ahd_from  TYPE c,
    l_ahd_act        TYPE c.

  IF ex_badi_wahd IS INITIAL.
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
           EXIT_NAME                   = 'BADI_WAHD_INTF'
           NULL_INSTANCE_ACCEPTED      = SPACE
      IMPORTING
           ACT_IMP_EXISTING            = imp_badi_wahd
      CHANGING
           instance                    = ex_badi_wahd.
  ENDIF.

  check not imp_badi_wahd is initial.

  IF  rmmzu-okcode = 'PB31'       "Display consumption store
   OR rmmzu-okcode = 'PB32'.      "Display consumption DC

*   Special handling in case of create or change article
    IF t130m-aktyp EQ aktypn OR sy-tcode = 'MM41'.
      l_call_ahd_from = '1'.
    ELSEIF t130m-aktyp NE aktypa OR sy-tcode = 'MM42'.
      l_call_ahd_from = '2'.
    ELSE.
      l_call_ahd_from = '3'.
    ENDIF.

*   BAdI for display/change of AHD

    CALL METHOD ex_badi_wahd->ex_badi_wahd_intf_disp_chng
      EXPORTING
        i_matnr      = rmmg1-matnr
        i_werks      = rmmg1-werks
        i_dismm      = marc-dismm
        i_meins      = mara-meins
        i_call_from  = l_call_ahd_from
      IMPORTING
        e_ahd_active = l_ahd_act.

*   Return to last screen, if AHD is active
    IF NOT l_ahd_act IS INITIAL.
      CLEAR rmmzu-okcode.
      bildflag = x.
    ENDIF.

  ENDIF.

ENDMODULE.                 " ahd_interface  INPUT
*#WSC 4.70 AHD-INTERFACE - E
