*&---------------------------------------------------------------------*
*& Include          ZB1_S4_MAP_INSERT_TOP
*&---------------------------------------------------------------------*

DATA:fname TYPE localfile,
     ename TYPE char4,
     cnt   TYPE i.

TYPES:BEGIN OF gty_file,
      s4_batch  TYPE   char10,
      matnr     TYPE   matnr,
      werks     TYPE   char4,
      b1_batch  TYPE   char20,
      b1_vendor TYPE   char10,
      amount    TYPE   char13,
END OF gty_file,
gty_t_file TYPE STANDARD TABLE OF gty_file.

DATA: gwa_file    TYPE gty_file,
      git_file    TYPE STANDARD TABLE OF gty_file,
      wa_addf     TYPE zb1_s4_map.
