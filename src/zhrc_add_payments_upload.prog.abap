REPORT ZHRC_ADD_PAYMENTS_UPLOAD
       NO STANDARD PAGE HEADING LINE-SIZE 255.


TYPE-POOLS TRUXS.
DATA:  IT_TYPE  TYPE TRUXS_T_TEXT_DATA.

INCLUDE ZHRC_ADD_PAYMENTS_UPLOAD_TOP.
INCLUDE ZHRC_ADD_PAYMENTS_UPLOAD_SEL.
INCLUDE ZHRC_ADD_PAYMENTS_UPLOAD_FORM.




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
  PERFORM CATALOG_DESIGN.
  PERFORM DISPLAY.
