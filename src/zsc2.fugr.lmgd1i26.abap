*------------------------------------------------------------------
*  Module MARC-SOBSK.                  neu zu 3.0   ch/14.11.94
*  Pruefung des Sonderbeschaffungsschlüssels für die Kalkulation
*  - keine Eingabe bei Prozeß-Materialien
*  - Warnung bei Dummybaugruppen
*------------------------------------------------------------------
MODULE MARC-SOBSK.

  CHECK BILDFLAG = SPACE.
  CHECK T130M-AKTYP NE AKTYPA AND T130M-AKTYP NE AKTYPZ.

  CALL FUNCTION 'MARC_SOBSK'
       EXPORTING
            WMARC_SOBSK  = MARC-SOBSK
            WMARC_SOBSL  = MARC-SOBSL
            WMARC_WERKS  = MARC-WERKS
            WMARC_STLAL  = MARC-STLAL
            WMARC_STLAN  = MARC-STLAN
            WMARC_PLNNR  = MARC-PLNNR
            WMARC_APLAL  = MARC-APLAL
            WMARC_PLNTY  = MARC-PLNTY
            WRMMG1_MTART = MARA-MTART
       IMPORTING
            WMARC_SOBSK  = MARC-SOBSK.

ENDMODULE.
