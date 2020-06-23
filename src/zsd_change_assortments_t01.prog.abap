*&---------------------------------------------------------------------*
*& Include          ZSD_HSN_UPLOAD_T01
*&---------------------------------------------------------------------*

*** Types
*** File Type
TYPES :
  BEGIN OF TY_FILE,
    SLNO(5),    " SL Number
    MATKL(9),   " Condtion Type
    ASSRT(10),   " Condtion Type
    MSGTYP(1),  " Message Type
    MSG(255),   " Message
  END OF TY_FILE.

DATA:
  GT_FILE     TYPE  STANDARD TABLE OF TY_FILE,
  FNAME       TYPE LOCALFILE,
  ENAME       TYPE CHAR4,
  GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
  GT_BDCDATA  TYPE TABLE OF BDCDATA,
  CTUMODE     LIKE CTU_PARAMS-DISMODE VALUE 'N',
  CUPDATE     LIKE CTU_PARAMS-UPDMODE VALUE 'S'.

CONSTANTS :
  C_X(1) VALUE 'X',
  C_E(1) VALUE 'E'.
