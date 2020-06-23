*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_FIELD_VALUE
*&---------------------------------------------------------------------*
*       Setzt den Wert eines Dynprofeldes vor jeder weiteren Operation
*----------------------------------------------------------------------*
FORM SET_SCREEN_FIELD_VALUE USING FIELD type clike
                                  VALUE type simple.

  CLEAR DYNPFIELDS. REFRESH DYNPFIELDS.
  DYNPFIELDS-FIELDNAME = FIELD.
  DYNPFIELDS-FIELDVALUE = VALUE.
  APPEND DYNPFIELDS.
* Setzen des akt. Wertes im Dynpro
  SY_REPID = SY-REPID.
  SY_DYNNR = SY-DYNNR.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
       EXPORTING
            DYNAME     = SY_REPID
            DYNUMB     = SY_DYNNR
       TABLES
            DYNPFIELDS = DYNPFIELDS
       EXCEPTIONS
            OTHERS     = 1.

ENDFORM.                               " SET_SCREEN_FIELD_VALUE
