*&---------------------------------------------------------------------*
*& Include          ZSD_HSN_UPLOAD_T01
*&---------------------------------------------------------------------*

*** Types
*** File Type
TYPES :
  BEGIN OF TY_FILE,
    SLNO(5),    " SL Number
    KSCHL(4),   " Condtion Type
    ALAND(2),   " Country
    WKREG(2),   " Region in which plant is located
    REGIO(2),   " Region
    STEUC(18),  " HSN Code
    MWSK1(2),   " Tax on sales/purchases code
  END OF TY_FILE,

*** For display results
  BEGIN OF TY_FINAL,
    SLNO(5),    " SL Number
    KSCHL(4),   " Condtion Type
    ALAND(2),   " Country
    WKREG(2),   " Region in which plant is located
    REGIO(2),   " Region
    STEUC(18),  " HSN Code
    MWSK1(2),   " Tax on sales/purchases code
    MSGTYP    TYPE TEXT1,
    MSG       TYPE TEXT255,
  END OF TY_FINAL.

DATA:
  GT_FILE     TYPE  STANDARD TABLE OF TY_FILE,
  GT_FINAL    TYPE STANDARD TABLE OF TY_FINAL,
  FNAME       TYPE LOCALFILE,
  ENAME       TYPE CHAR4,
  GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
  GT_BDCDATA  TYPE TABLE OF BDCDATA,
  CTUMODE     LIKE CTU_PARAMS-DISMODE VALUE 'N',
  CUPDATE     LIKE CTU_PARAMS-UPDMODE VALUE 'S'.

CONSTANTS :
  C_X(1) VALUE 'X'.
