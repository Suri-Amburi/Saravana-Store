*----------------------------------------------------------------------*
*   INCLUDE LMGD2O08                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  FAUSW_1040  OUTPUT
*&---------------------------------------------------------------------*
*       Spezialfeldauswahl Dynpro 1040 für Vorgabewerte Varianten EANs
*       Pushbutton PUSH_VAR_EAN wird über Sonderfeldauswahl gesteuert.
*       Er wird nur eingeblendet, wenn man einen Sammelartikel oder eine
*       Variante bearbeitet (Sonderfeldauswahlgruppe 060). Davon
*       abhängig werden alle anderen Felder mit ein- und ausgeblendet.
*       Dies bewirkt, daß das Dynpro nur erscheint, wenn man einen
*       Sammelartikel oder eine Variante bearbeitet.
*----------------------------------------------------------------------*
MODULE FAUSW_1040 OUTPUT.

  READ TABLE FAUSWTAB WITH KEY 'PUSH_VAR_EAN' BINARY SEARCH.
  IF SY-SUBRC = 0.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = '001'.        " alle Felder
        SCREEN-ACTIVE      = FAUSWTAB-KZACT.
        SCREEN-INPUT       = FAUSWTAB-KZINP.
        SCREEN-INTENSIFIED = FAUSWTAB-KZINT.
        SCREEN-INVISIBLE   = FAUSWTAB-KZINV.
*       SCREEN-OUTPUT      = FAUSWTAB-KZOUT. " Falsch aber irrelevant
        SCREEN-REQUIRED    = FAUSWTAB-KZREQ.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF T130M-AKTYP = AKTYPA OR T130M-AKTYP = AKTYPZ.
    LOOP AT SCREEN.
*     IF SCREEN-GROUP2 = '002'.        " Eingabefelder deaktivieren
*       SCREEN-ACTIVE      =
*       SCREEN-INPUT       = '0'.
*       SCREEN-INTENSIFIED = '0'.
*       SCREEN-INVISIBLE   =
*       SCREEN-OUTPUT      = '0'.
*       SCREEN-REQUIRED    = '0'.
*       MODIFY SCREEN.
*     ENDIF.
      IF SCREEN-GROUP1 = '001' OR
         SCREEN-GROUP2 = '002'.        " alle Felder ausblenden
        SCREEN-ACTIVE      = '0'.
        SCREEN-INPUT       = '0'.
        SCREEN-INTENSIFIED = '0'.
        SCREEN-INVISIBLE   = '1'.
        SCREEN-OUTPUT      = '0'.
        SCREEN-REQUIRED    = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                             " FAUSW_1040  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  ANZEIGEN_VORGABEWERTE  OUTPUT
*&---------------------------------------------------------------------*
*       Anzeigen: Mengeneinheit, Bezeichnung und EAN-Typ
*----------------------------------------------------------------------*
MODULE ANZEIGEN_VORGABEWERTE OUTPUT.

  CLEAR T006A.

  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Hier nur wegen Help-Modul 'SMEINH-MEINH_HELP' benötigt
  CALL FUNCTION 'GET_ZUS_RETAIL'
       IMPORTING
*     RMMW2_LIFNR =
      rmmw1_matnr = rmmw1_matn
*     RMMW2_VARNR =
  EXCEPTIONS
       OTHERS      = 1.

* CLEAR: MEAN-EANTP, SMEINH-MEINH.

* RMMWZ-NUMTP  angezeigte Dynprofelder
* RMMWZ-MEINH.         "
* RMMWZ-EAN_INTERN     "

  CALL FUNCTION 'ZUS_EAN_READ_DESCRIPTION'
       EXPORTING
            P_MEAN_MEINH = RMMWZ-MEINH
       IMPORTING
            WT006A       = T006A       " T006A-MSEHT belegt
       EXCEPTIONS
            OTHERS       = 1.


ENDMODULE.                             " ANZEIGEN_VORGABEWERTE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_SGT_VALUE  OUTPUT
*&---------------------------------------------------------------------*
* Standard table MEAN_TAB_SA and MEAN_TAB are modified to hold the     *
* the EANs of the corresponding segment value entered.                 *
* If no segment value is entered then all EANs are displayed.          *
* The global buffer tables GT_MEAN_TAB and GT_MEAN are filled for the  *
* first time.                                                          *
*----------------------------------------------------------------------*
MODULE GET_SGT_VALUE OUTPUT.

ENHANCEMENT-POINT LMGD2O08_01 SPOTS ES_MGD2_01 INCLUDE BOUND .


ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  TC_CHECK_SGT_INVISIBLE  OUTPUT
*&---------------------------------------------------------------------*
* Hide Segment field in the table control if the article is not        *
* segment relevant; Input disable the segment field if segment filter  *
* value is entered                                                     *
*----------------------------------------------------------------------*
MODULE TC_MODIFY_SEG OUTPUT.

ENHANCEMENT-POINT LMGD2O08_02 SPOTS ES_MGD2_01 INCLUDE BOUND .

ENDMODULE.
ENHANCEMENT-POINT LMGD2O08_03 SPOTS ES_MGD2_01 STATIC INCLUDE BOUND .
