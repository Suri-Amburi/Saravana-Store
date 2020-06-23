*-------------------------------------------------------------------
***INCLUDE LMGD1F04 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  LESEN_BEZ_ME
*&---------------------------------------------------------------------*
*       Lesen der Bezeichnung zu einer Mengeneinheit aus T006A         *
*----------------------------------------------------------------------*
*  -->  SPRACHE        in der der Text gelesen werden soll
*       MENGENEINHEIT  zu der der Text gelesen werden soll
*  <--  MBEZ           untersch. Bezeichnungen zur ME
*----------------------------------------------------------------------*
FORM LESEN_BEZ_ME USING SPRACHE       type      sylangu
                        MENGENEINHEIT like      smeinh-meinh
                        MEBEZ         STRUCTURE T006A.

  IF MEBEZ-SPRAS NE SY-LANGU OR MEBEZ-MSEHI NE MENGENEINHEIT.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
         EXPORTING
              INPUT          = MENGENEINHEIT
              LANGUAGE       = SY-LANGU
         IMPORTING
              LONG_TEXT      = MEBEZ-MSEHL
              OUTPUT         = MEBEZ-MSEH3
              SHORT_TEXT     = MEBEZ-MSEHT
         EXCEPTIONS
              UNIT_NOT_FOUND = 01.
    MEBEZ-MSEHI = MENGENEINHEIT.
  ELSE.
    SY-SUBRC = 0.
  ENDIF.
  IF SY-SUBRC NE 0.
    CLEAR MEBEZ.
  ENDIF.

ENDFORM.                               " LESEN_BEZ_ME
