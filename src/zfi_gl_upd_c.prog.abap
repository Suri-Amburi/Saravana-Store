*&---------------------------------------------------------------------*
*& Report ZFI_GL_UPD_C
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_GL_UPD_C.

TYPE-POOLS TRUXS.
DATA:  IT_TYPE  TYPE TRUXS_T_TEXT_DATA.

INCLUDE ZFI_GL_UPD_TOP.
INCLUDE ZFI_GL_UPD_SEL.
INCLUDE ZFI_GL_UPD_FORM.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SYST-CPROG
      DYNPRO_NUMBER = SYST-DYNNR
      FIELD_NAME    = 'P_FILE'
    IMPORTING
      FILE_NAME     = P_FILE.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM BDC_DATA.
  PERFORM FIELDCATLOG_DESIGN.
  PERFORM DISPLAY.
