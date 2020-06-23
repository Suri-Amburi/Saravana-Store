*&---------------------------------------------------------------------*
*& Include          ZB1_S4_MAP_VENDOR_UPDATE_TOP
*&---------------------------------------------------------------------*

DATA:fname TYPE localfile,
     ename TYPE char4,
     cnt   TYPE i.

TYPES:BEGIN OF gty_file,
      b1_batch TYPE  char20,  "zb1_btch,
      lifnr    TYPE  char15,  "dmbtr_cs,
END OF gty_file,
gty_t_file TYPE STANDARD TABLE OF gty_file.

DATA: gwa_file    TYPE gty_file,
      git_file    TYPE STANDARD TABLE OF gty_file,
      wa_addf     TYPE zb1_s_price.
