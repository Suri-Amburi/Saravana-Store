*&---------------------------------------------------------------------*
*& Report ZQR_CODE_LABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZQR_CODE_LABLE.

DATA : FORM_NAME TYPE RS38L_FNAM.

PARAMETERS: P_QR TYPE CHAR10.

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    FORMNAME           = 'ZQR_CODE_LABLE'
  IMPORTING
    FM_NAME            = FORM_NAME
  EXCEPTIONS
    NO_FORM            = 1
    NO_FUNCTION_MODULE = 2
    OTHERS             = 3.

IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION FORM_NAME
  EXPORTING
    I_QR_CODE        = P_QR
  EXCEPTIONS
    FORMATTING_ERROR = 1
    INTERNAL_ERROR   = 2
    SEND_ERROR       = 3
    USER_CANCELED    = 4
    OTHERS           = 5.
IF SY-SUBRC <> 0.
ENDIF.
