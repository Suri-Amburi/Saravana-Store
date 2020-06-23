*&---------------------------------------------------------------------*
*& Include          ZB1_S4_MAP_S4BATCH_UPDATE_TOP
*&---------------------------------------------------------------------*

DATA:fname TYPE localfile,
     ename TYPE char4,
     cnt   TYPE i.

TYPES:BEGIN OF gty_file,
      b1_batch TYPE   char20,
      s4_batch TYPE   char10,
END OF gty_file,
gty_t_file TYPE STANDARD TABLE OF gty_file.

DATA: gwa_file    TYPE gty_file,
      git_file    TYPE STANDARD TABLE OF gty_file,
      wa_addf     TYPE zb1_s4_map.
