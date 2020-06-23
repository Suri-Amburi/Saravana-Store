*&---------------------------------------------------------------------
*&      Module  MARC-STRGR_HELP  INPUT
*&---------------------------------------------------------------------
MODULE MARC-STRGR_HELP INPUT.

  PERFORM SET_DISPLAY.

  CLEAR DYNPFIELDS. REFRESH DYNPFIELDS.
  DYNPFIELDS-FIELDNAME = 'MARC-STRGR'.
  APPEND DYNPFIELDS.

*  Lesen des akt. Wertes von MARC-STRGR auf dem Dynpro
  SY_REPID = SY-REPID.
  SY_DYNNR = SY-DYNNR.
  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME               = SY_REPID
            DYNUMB               = SY_DYNNR
       TABLES
            DYNPFIELDS           = DYNPFIELDS
       EXCEPTIONS
            OTHERS               = 01.

  READ TABLE DYNPFIELDS INDEX 1.
  IF SY-SUBRC = 0.
    MARC-STRGR =  DYNPFIELDS-FIELDVALUE.
  ENDIF.

*  Aufruf der selbstcodierten F4-Hilfe
  CALL FUNCTION 'STRATEGY_GROUP_SELECT'
       EXPORTING
            STRATEGY_GROUP = MARC-STRGR
            DISPLAY        = DISPLAY
       IMPORTING
            STRATEGY_GROUP = MARC-STRGR.
*           GROUP_TEXT     =.
ENDMODULE.                 " MARC-STRGR_HELP  INPUT
