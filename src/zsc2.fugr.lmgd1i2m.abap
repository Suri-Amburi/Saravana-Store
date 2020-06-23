*------------------------------------------------------------------
*  Module MARC-DISVFN.
*  Bei Dispoverfahren N werden alle Dispofelder zurückgesetzt
*  Ausnahmen:- allgemeine Felder zur Verfügbarkeitsprüfung wie
*               WEBAZ, PLIFZ, WZEIT, MTVFP. DZEIT
*            - Quotierungsverwendung  (übergreifend verwendet)
*            - Disponent, Einkäufergruppe
*            - Periodenkz. und Geschäftsjahresvariante
*            - Beschaffungsart und Sonderbeschaffungsart
*            - Daten zur Lagerortdisposition (auf MARD-Ebene)
*            - Dispositionsgruppe
*  Achtung: Modul lief vor 2.1 nur auf dem ersten Dispobild ab, d.h.
*           nachträgliche Pflege auf den weiteren Bildern war
*           möglich
*------------------------------------------------------------------
MODULE MARC-DISVFN.

* AHE: 23.06.97 - A
* Modul deaktiviert zu 3.1H; s. Hinweis: 77568
  CHECK 1 = 0.
* AHE: 23.06.97 - E

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

* Feldauswahltabelle des aktuellen Bildbausteins nochmal aufbauen, da
* zum PAI-Zeitpunkt nicht mehr bekannt und diese für die folgende
* Prüfung benötigt wird. Von der Feldauswahl werden nur die Feldnamen
* benötigt.
  REFRESH FAUSWTAB.   CLEAR FAUSWTAB.
  LOOP AT SCREEN.
    FAUSWTAB-FNAME = SCREEN-NAME.
*     FAUSWTAB-KZINI = KZ_FIELD_INITIAL.
*     FAUSWTAB-KZACT = SCREEN-ACTIVE.
*     FAUSWTAB-KZINP = SCREEN-INPUT.
*     FAUSWTAB-KZINT = SCREEN-INTENSIFIED.
*     FAUSWTAB-KZINV = SCREEN-INVISIBLE.
*     FAUSWTAB-KZOUT = SCREEN-OUTPUT.
*     FAUSWTAB-KZREQ = SCREEN-REQUIRED.
    APPEND FAUSWTAB.
  ENDLOOP.
  SORT FAUSWTAB BY FNAME.

* Prüfstatus zurücksetzen, falls Felder geändert wurden.
* Bei dieser Prüfung ist nur die Veränderung des Dispoverfahrens
* relevant.
  IF ( RMMZU-PS_DISVFN = X ) AND
     ( UMARC-DISMM NE MARC-DISMM ).
    CLEAR RMMZU-PS_DISVFN.
  ENDIF.
* Wenn Prüfstatus = Space, Prüfbaustein aufrufen.
  IF ( RMMZU-PS_DISVFN = SPACE ).
    CALL FUNCTION 'MARC_DISVFN'
         EXPORTING
              FLG_UEBERNAHME = FLG_UEBERNAHME
              W_MARC         = MARC
              P_MTART        = RMMG1-MTART
              P_VPMAT        = MPGD-PRGRP
              P_VPWRK        = MPGD-PRWRK
              P_VPREF        = MPGD-UMREF
              P_PS_DISVFN    = RMMZU-PS_DISVFN
              P_KZ_NO_WARN   = ' '
         IMPORTING
              W_T439A        = T439A
              W_MARC         = MARC
              P_VPMAT        = MPGD-PRGRP
              P_VPWRK        = MPGD-PRWRK
              P_VPREF        = MPGD-UMREF
              P_PS_DISVFN    = RMMZU-PS_DISVFN
         TABLES
              P_FAUSWTAB     = FAUSWTAB.

    IF MPGD-PRGRP IS INITIAL.
      CLEAR RMMZU-VPBME.
    ENDIF.

    IF RMMZU-PS_DISVFN NE SPACE.
      BILDFLAG = X.
      RMMZU-CURS_FELD = 'MARC-DISMM'.
      MESSAGE S073.
* Aktuellen Stand UMXXX aktualisieren, da bei Bildwiederholung am Ende
* des Bildes keine Aktualisierung von UMXXX erfolgt.
      UMARC = MARC.
    ENDIF.
* Wenn Prüfstatus = X und Felder wurden nicht geändert, Prüfung durch-
* führen, keine Warnung ausgeben (im Prüfbaustein wird nach der Warnung
* aufgesetzt).
  ELSE.
    CALL FUNCTION 'MARC_DISVFN'
         EXPORTING
              FLG_UEBERNAHME = FLG_UEBERNAHME
              W_MARC         = MARC
              P_MTART        = RMMG1-MTART
              P_VPMAT        = MPGD-PRGRP
              P_VPWRK        = MPGD-PRWRK
              P_VPREF        = MPGD-UMREF
              P_PS_DISVFN    = RMMZU-PS_DISVFN
              P_KZ_NO_WARN   = ' '
         IMPORTING
              W_T439A        = T439A
              W_MARC         = MARC
              P_VPMAT        = MPGD-PRGRP
              P_VPWRK        = MPGD-PRWRK
              P_VPREF        = MPGD-UMREF
              P_PS_DISVFN    = RMMZU-PS_DISVFN
         TABLES
              P_FAUSWTAB     = FAUSWTAB.

    IF MPGD-PRGRP IS INITIAL.
      CLEAR RMMZU-VPBME.
    ENDIF.
  ENDIF.

ENDMODULE.
