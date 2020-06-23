*------------------------------------------------------------------
*  Module MARC-DISPOMUSS.
*  Bestimmte Dispofelder müssen ausgefüllt sein.
*------------------------------------------------------------------
MODULE MARC-DISPOMUSS.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Feldauswahltabelle des aktuellen Bildbausteins nochmal aufbauen, da
* zum PAI-Zeitpunkt nicht mehr bekannt und diese für die folgende
* Prüfung benötigt wird. Von der Feldauswahl werden nur die Feldnamen
* benötigt.
  REFRESH FAUSWTAB.   CLEAR FAUSWTAB.
  LOOP AT SCREEN.
    FAUSWTAB-FNAME = SCREEN-NAME.
*   FAUSWTAB-KZINI = KZ_FIELD_INITIAL.
*   FAUSWTAB-KZACT = SCREEN-ACTIVE.
*   FAUSWTAB-KZINP = SCREEN-INPUT.
*   FAUSWTAB-KZINT = SCREEN-INTENSIFIED.
*   FAUSWTAB-KZINV = SCREEN-INVISIBLE.
*   FAUSWTAB-KZOUT = SCREEN-OUTPUT.
*   FAUSWTAB-KZREQ = SCREEN-REQUIRED.
    APPEND FAUSWTAB.
  ENDLOOP.
  SORT FAUSWTAB BY FNAME.

  CALL FUNCTION 'MARC_DISPOMUSS'
       EXPORTING
            FLG_UEBERNAHME = FLG_UEBERNAHME
            P_DISPO        = MARC-DISPO
            P_FHORI        = MARC-FHORI
            P_DISLS        = MARC-DISLS
            P_DISMM        = MARC-DISMM
            P_MINBE        = MARC-MINBE
            P_MABST        = MARC-MABST
            P_KZ_NO_WARN   = ' '
       TABLES
            P_FAUSWTAB     = FAUSWTAB.
*      EXCEPTIONS
*           P_ERR_MARC_DISPOMUSS = 01.
*           ERR_T438A            = 02.

ENDMODULE.
