************************************************************************
*
* Include für Festwerte im Materialstammbereich
*
************************************************************************

*--- Dimensions-Ids zur F4-Hilfe für MEs einer bestimmten Dimension
constants:
        DIMID_MASS   LIKE T006-DIMID VALUE 'MASS',   "Masse bzw. Gewicht
        DIMID_LENGTH LIKE T006-DIMID VALUE 'LENGTH', "Länge
        DIMID_VOLUME LIKE T006-DIMID VALUE 'VOLUME', "Volumen
        DIMID_TIME   LIKE T006-DIMID VALUE 'TIME',   "Zeit
                                                    "K11K059421
*--- Revisionlevel
        KEY_TCC08 LIKE TCC08-AGBCC VALUE 'CC',

*--- Konfiguration
      T476_SICHT LIKE T476-SICHT VALUE 'M',
      T476_STRAT LIKE T476-STRAT VALUE '++',
      KONFWIN(4)                 VALUE '0120',  "Window-Koordinaten

*--- Klassifizierung (Merkmalsbewertung)
     SAPLCTMS        like rs37a-dynprog value 'SAPLCTMS',
     ctms4000        like feld-dynnr    value '4000',
     tcla_obtab_mara like tcla-obtab    value 'MARA',

*--- Maximales Datum im R/3
      MAX_DATE   LIKE SY-DATUM   VALUE '99991231'.
