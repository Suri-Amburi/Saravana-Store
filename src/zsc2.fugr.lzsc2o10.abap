*----------------------------------------------------------------------*
*   INCLUDE LMGD2O10                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  FELDAUSWAHL_2214  OUTPUT
*&---------------------------------------------------------------------*
*       Im Anzeigemodus soll das Subscreen Listung nicht erscheinen.
*----------------------------------------------------------------------*
MODULE feldauswahl_anzeigemodus OUTPUT.

CALL FUNCTION 'READ_G_LISTED'
      IMPORTING
        listed = g_listed.

  LOOP AT SCREEN.
    IF t130m-aktyp = aktypa OR t130m-aktyp = aktypz.   " Anzeigen
      IF screen-group1 = '001'.
        screen-input     = 0.
        screen-required  = 0.
        screen-invisible = 1.
        screen-active    = 0.
        screen-output    = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    IF multiple_assignment IS INITIAL.
      " Feld lokale Sortimente listen ausblenden
      IF screen-name = 'RMMWZ-LOSO'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF g_listed = 'X'.
      IF screen-name = 'RMMWZ-LOSO'
      OR screen-name = 'RMMWZ-LILI'
      OR screen-name = 'RMMWZ-ASSORTYP'.  "KSDP: new ASSORTYP
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  if flag_initial is initial.
    flag_initial = 'X'.
    RMMWZ-LILI = 'X'.
  endif.

ENDMODULE.                        " FELDAUSWAHL_ANZEIGEMODUS  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  FELDAUSWAHL_VORLAGE_WERTARTIKE  OUTPUT
*&---------------------------------------------------------------------*
*       Bei einem Vorlage- oder Wertartikel soll das Subscreen Listung
*       nicht erscheinen. Zudem wird der Button Sortimente ausgeblendet.
*----------------------------------------------------------------------*
MODULE feldauswahl_vorlage_wertart OUTPUT.

  CHECK t130m-aktyp NE aktypa OR t130m-aktyp NE aktypz.    " Anzeigen

  IF rmmw2-attyp = attyp_wgwert  OR
     rmmw2-attyp = attyp_wghier  OR
     rmmw2-attyp = attyp_wert    OR
     rmmw2-attyp = attyp_wgdef.

    LOOP AT SCREEN.
      IF screen-group1 = '001'.
        screen-input     = 0.
        screen-required  = 0.
        screen-invisible = 1.
        screen-active    = 0.
        screen-output    = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " FELDAUSWAHL_VORLAGE_WERTARTIKE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  assort_assignment_pruefen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE assort_assignment_pruefen OUTPUT.
* Feld multiple_assignment setzen
  CALL FUNCTION 'CHECK_MULTIPLE_ASSIGNMENT'
    IMPORTING
      multiple_assignment = multiple_assignment.

  if initialized is initial.
* Feld lokale Sortimente beim 1. Aufruf vorbelegen
    CALL FUNCTION 'READ_CHECK_LOCAL_ASSORTMENT'
     IMPORTING
       CHECK_LOCAL_ASSORTMENT       = CHECK_LOCAL_ASSORTMENT
            .
    initialized = 'X'.
    rmmwz-loso = CHECK_LOCAL_ASSORTMENT.
  endif.

ENDMODULE.                 " assort_assignment_pruefen  OUTPUT
