*------------------------------------------------------------------
*  Module MARC-VRMOD
*  Verrechnungsintervalle zur Bedarfverrechnung sind nur sinnvoll,
*  wenn ein Verrechnungsmodus eingegeben wurde.
*  Ist ein Verrechnungsmodus ungleich '0' (0 heißt keine Verrechnung)
*  und ist eines der Intervalle ungepflegt, erfolgt eine Warnung
*  Besonderheit für die Intervallwerte: 999 heißt 'unbegrenzt'
*
*  Alternativ können die Daten auch in T438M gepflegt werden (T438M
*  wird nur genutzt, wenn marc-vrmod initial ist. In diesem Fall werden
*  auch die Intervalle aus der T438M gezogen)
*------------------------------------------------------------------
MODULE MARC-VRMOD.

  CHECK BILDFLAG IS INITIAL.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_VRMOD'
       EXPORTING
            P_VRMOD      = MARC-VRMOD
            P_LVRMOD     = LMARC-VRMOD
            P_VINT1      = MARC-VINT1
            P_LVINT1     = LMARC-VINT1
            P_VINT2      = MARC-VINT2
            P_LVINT2     = LMARC-VINT2
            P_KZ_NO_WARN = ' '.
*      EXCEPTIONS
*           P_ERR_MARC_VRMOD = 01.

ENDMODULE.
