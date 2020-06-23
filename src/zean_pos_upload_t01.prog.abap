*&---------------------------------------------------------------------*
*& Include          ZEAN_POS_UPLOAD_T01
*&---------------------------------------------------------------------*

*** Types
TYPES :BEGIN OF ty_file,
         matnr(40),
         ean(18),
         meins(3),
         type(1),
         message(60),
       END OF ty_file.

*** File Structure
DATA:
  gt_file TYPE TABLE OF ty_file,
  gt_ean  TYPE TABLE OF zean_pos,
  fname   TYPE localfile,
  ename   TYPE char4.

*** Consumer
 DATA:
   CL_PROXY TYPE REF TO ZCO_SAVE_ALTERNATE_UPC_S4HANA,     " Proxy Class
   DATA_IN  TYPE ZSAVE_ALTERNATE_UPC_S4HANA,               " Proxy Input
   DATA_OUT TYPE ZSAVE_ALTERNATE_UPC_S4HANA_RES,           " Proxy Output
   FAULT    TYPE REF TO CX_ROOT.                           " Generic Fault

CONSTANTS :
  c_x(1) VALUE 'X',
  c_s(1) VALUE 'S',
  c_e(1) VALUE 'E'.
