*&---------------------------------------------------------------------*
*& Report ZSALFORMD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSALFORMD.
INCLUDE ZSALFORMD_TOP.

START-OF-SELECTION.
  GET PERNR.
  INCLUDE ZSALFORMD_FORM.
  INCLUDE ZSALFORMD_SUB.

END-OF-SELECTION.

  DATA F_NAME TYPE RS38L_FNAM.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZSAL_FORMD'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = F_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  CALL FUNCTION F_NAME
*    EXPORTING
    TABLES
      IT_ITEM          = IT_ITEM
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      USER_CANCELED    = 4
      OTHERS           = 5.

  IF SY-SUBRC <> 0.
*     Implement suitable error handling here
  ENDIF.
  IF SY-SUBRC <> 0.
*     Implement suitable error handling here
  ENDIF.
