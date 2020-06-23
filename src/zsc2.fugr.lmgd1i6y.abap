*------------------------------------------------------------------
*  Module SMEINH-MEINH_HELP
*  Aufruf der speziellen Eingabehilfe für Mengeneinheiten
*------------------------------------------------------------------
* AHE: 25.06.96 - neues Modul ! ! !
MODULE SMEINH-MEINH_HELP.

* AHE: 26.06.96 - A
  IF NOT RMMG2-FLG_RETAIL IS INITIAL.
* Retail-Fall
    HMATNR = RMMW1_MATN.
  ELSE.
    HMATNR = RMMG1-MATNR.
  ENDIF.
* AHE: 26.06.96 - E

  PERFORM SET_DISPLAY.

  CALL FUNCTION 'SMEINH_MEINH_HELP'
       EXPORTING
            DISPLAY = DISPLAY
            P_MATNR = HMATNR           " AHE: 26.06.96 Retail-Fall
       IMPORTING
            MEINH   = SMEINH-MEINH
       EXCEPTIONS
            OTHERS  = 1.

ENDMODULE.
