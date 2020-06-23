*&---------------------------------------------------------------------*
*& Include          ZMM_SCAN_BATCH_T01
*&---------------------------------------------------------------------*

DATA :
  gt_batches TYPE TABLE OF zscan_batches,
  gs_batches TYPE zscan_batches,
  ok_9000    TYPE sy-ucomm.

CONSTANTS :
  c_save   TYPE syucomm VALUE 'SAVE',
  c_enter  TYPE syucomm VALUE 'ENTER',
  c_space  TYPE syucomm VALUE space,
  c_back   TYPE syucomm VALUE 'BACK',
  c_exit   TYPE syucomm VALUE 'EXIT',
  c_cancel TYPE syucomm VALUE 'CANCEL',
  c_x(1)   VALUE 'X',
  c_E(1)   VALUE 'E',
  c_d(1)   VALUE 'D'.

DATA:
  custom_container TYPE REF TO cl_gui_custom_container,
  grid             TYPE REF TO cl_gui_alv_grid,
  gs_print         TYPE lvc_s_prnt,
  gs_layout        TYPE lvc_s_layo,
  mycontainer      TYPE scrfname VALUE 'CONTAINER',
  gt_fieldcat      TYPE lvc_t_fcat,
  gt_tlbr_excl     TYPE ui_functions,
  gv_mode(1)       VALUE 'C'.
